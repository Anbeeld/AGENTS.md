$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$Source = Join-Path $RepoDir "AGENTS.md"

$AgentsTargets = @()
$ClaudeTargets = @()
$DryRun = $false

function Assert-SourceExists {
    if (-not (Test-Path -Path $Source -PathType Leaf)) {
        Write-Error "Source file not found: $Source"
        exit 1
    }
}

function Assert-TargetParentExists {
    param([string]$Target)

    $parent = Split-Path -Parent $Target
    if (-not (Test-Path -Path $parent -PathType Container)) {
        Write-Error "Target directory not found: $parent"
        exit 1
    }
}

function Show-Help {
    Write-Host "Usage: sync.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Sync the canonical AGENTS.md to all coding agent configs."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -TargetsOpenCode PATH   OpenCode AGENTS.md location"
    Write-Host "  -TargetsCodex PATH      Codex AGENTS.md location"
    Write-Host "  -TargetsClaude PATH     Claude Code CLAUDE.md location"
    Write-Host "  -DryRun                 Show what would be synced without making changes"
    Write-Host "  -Help                   Show this help message"
    Write-Host ""
    Write-Host "Auto-detected locations:"
    Write-Host "  OpenCode:   ~/.config/opencode/AGENTS.md"
    Write-Host "  Codex:      ~/.codex/AGENTS.md"
    Write-Host "  Claude:     ~/.claude/CLAUDE.md"
}

function Assert-HasTargetArgs {
    param(
        [string]$Flag,
        [int]$Index
    )

    if ($Index + 1 -ge $args.Count -or $args[$Index + 1] -like "-*") {
        Write-Error "Missing path after $Flag"
        exit 1
    }
}

function Detect-Targets {
    $home = $env:USERPROFILE
    if (-not $home) { $home = $env:HOME }
    if (-not $home) {
        Write-Error "Could not determine the home directory from USERPROFILE or HOME."
        exit 1
    }
    $appdata = $env:APPDATA
    if (-not $appdata) { $appdata = Join-Path $home "AppData\Roaming" }

    if (Test-Path (Join-Path $home ".config\opencode")) {
        $AgentsTargets += Join-Path $home ".config\opencode\AGENTS.md"
    }
    if (Test-Path (Join-Path $appdata "codex")) {
        $AgentsTargets += Join-Path $appdata "codex\AGENTS.md"
    }
    if (Test-Path (Join-Path $appdata "claude")) {
        $ClaudeTargets += Join-Path $appdata "claude\CLAUDE.md"
    }
}

function Sync-Targets {
    Assert-SourceExists

    if ($AgentsTargets.Count -eq 0 -and $ClaudeTargets.Count -eq 0) {
        Write-Error "No agent config directories found. Create them first or use -Targets* flags."
        exit 1
    }

    $total = 0

    foreach ($target in $AgentsTargets) {
        Assert-TargetParentExists -Target $target
        if ($target -like "*opencode*") {
            Write-Host "  -> $target (OpenCode)"
        }
        else {
            Write-Host "  -> $target (Codex)"
        }
        Copy-Item -Path $Source -Destination $target -Force
        $total++
    }

    foreach ($target in $ClaudeTargets) {
        Assert-TargetParentExists -Target $target
        Write-Host "  -> $target (Claude Code)"
        Copy-Item -Path $Source -Destination $target -Force
        $total++
    }

    Write-Host "Synced to $total target(s)."
}

function DryRun-Sync {
    Assert-SourceExists

    if ($AgentsTargets.Count -eq 0 -and $ClaudeTargets.Count -eq 0) {
        Write-Error "No agent config directories found."
        exit 1
    }

    Write-Host "Would write to:"

    foreach ($target in $AgentsTargets) {
        Assert-TargetParentExists -Target $target
        if ($target -like "*opencode*") {
            Write-Host "  -> $target (OpenCode)"
        }
        else {
            Write-Host "  -> $target (Codex)"
        }
    }

    foreach ($target in $ClaudeTargets) {
        Assert-TargetParentExists -Target $target
        Write-Host "  -> $target (Claude Code)"
    }
}

$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        "-TargetsOpenCode" {
            Assert-HasTargetArgs -Flag $args[$i] -Index $i
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $AgentsTargets += $args[$i]
                $i++
            }
        }
        "-TargetsCodex" {
            Assert-HasTargetArgs -Flag $args[$i] -Index $i
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $AgentsTargets += $args[$i]
                $i++
            }
        }
        "-TargetsClaude" {
            Assert-HasTargetArgs -Flag $args[$i] -Index $i
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $ClaudeTargets += $args[$i]
                $i++
            }
        }
        "-DryRun" {
            $DryRun = $true
            $i++
        }
        "-Help" {
            Show-Help
            exit 0
        }
        "--help" {
            Show-Help
            exit 0
        }
        default {
            Write-Host "Unknown option: $($args[$i]). Use -Help for usage."
            exit 1
        }
    }
}

if ($AgentsTargets.Count -eq 0 -and $ClaudeTargets.Count -eq 0) { Detect-Targets }

if ($DryRun) {
    DryRun-Sync
}
else {
    Sync-Targets
}
