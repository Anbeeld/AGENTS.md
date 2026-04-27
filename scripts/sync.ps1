$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$Source = Join-Path $RepoDir "AGENTS.md"

$AgentsTargets = @()
$ClaudeTargets = @()
$GeminiTargets = @()
$RulesDirTargets = @()
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

function Assert-TargetDirWritable {
    param([string]$Target)

    $parent = Split-Path -Parent $Target
    if (-not (Test-Path -Path $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Get-TargetLabel {
    param([string]$Target)

    switch -Wildcard ($Target) {
        "*\opencode\*"  { "OpenCode" }
        "*\.codex\*"    { "Codex CLI" }
        "*\amp\*"             { "Amp" }
        "*\.config\goose\*"    { "Goose" }
        "*\.claude\*"         { "Claude Code" }
        "*\.gemini\*"   { "Gemini CLI" }
        "*\Cline\*"     { "Cline" }
        "*\.roo\*"      { "Roo Code / Kilo Code" }
        "*\.augment\*"  { "Augment Code" }
        default         { $Target }
    }
}

function Show-Help {
    Write-Host "Usage: sync.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Sync the canonical AGENTS.md to all coding agent configs."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -TargetsOpenCode PATH   OpenCode AGENTS.md location"
    Write-Host "  -TargetsCodex PATH      Codex CLI AGENTS.md location"
    Write-Host "  -TargetsAmp PATH        Amp AGENTS.md location"
    Write-Host "  -TargetsGoose PATH      Goose AGENTS.md location"
    Write-Host "  -TargetsClaude PATH     Claude Code CLAUDE.md location"
    Write-Host "  -TargetsGemini PATH     Gemini CLI GEMINI.md location"
    Write-Host "  -TargetsRooCode PATH    Roo Code global rules path"
    Write-Host "  -TargetsCline PATH      Cline global rules path"
    Write-Host "  -TargetsAugment PATH    Augment Code global rules path"
    Write-Host "  -DryRun                 Show what would be synced without making changes"
    Write-Host "  -Help                   Show this help message"
    Write-Host ""
    Write-Host "Auto-detected locations:"
    Write-Host "  OpenCode:       ~/.config/opencode/AGENTS.md"
    Write-Host "  Codex CLI:      ~/.codex/AGENTS.md"
    Write-Host "  Amp:            ~/.config/amp/AGENTS.md"
    Write-Host "  Goose:          ~/.config/goose/AGENTS.md"
    Write-Host "  Claude Code:    ~/.claude/CLAUDE.md"
    Write-Host "  Gemini CLI:     ~/.gemini/GEMINI.md"
    Write-Host "  Roo Code:       ~/.roo/rules/AGENTS.md"
    Write-Host "  Cline:          ~/Documents/Cline/Rules/AGENTS.md"
    Write-Host "  Augment Code:   ~/.augment/rules/AGENTS.md"
}

function Detect-Targets {
    $home = $env:USERPROFILE
    if (-not $home) { $home = $env:HOME }
    if (-not $home) {
        Write-Error "Could not determine the home directory from USERPROFILE or HOME."
        exit 1
    }

    if (Test-Path (Join-Path $home ".config\opencode")) {
        $script:AgentsTargets += Join-Path $home ".config\opencode\AGENTS.md"
    }
    if (Test-Path (Join-Path $home ".codex")) {
        $script:AgentsTargets += Join-Path $home ".codex\AGENTS.md"
    }
    if (Test-Path (Join-Path $home ".config\amp")) {
        $script:AgentsTargets += Join-Path $home ".config\amp\AGENTS.md"
    }
    if (Test-Path (Join-Path $home ".config\goose")) {
        $script:AgentsTargets += Join-Path $home ".config\goose\AGENTS.md"
    }
    if (Test-Path (Join-Path $home ".claude")) {
        $script:ClaudeTargets += Join-Path $home ".claude\CLAUDE.md"
    }
    if (Test-Path (Join-Path $home ".gemini")) {
        $script:GeminiTargets += Join-Path $home ".gemini\GEMINI.md"
    }
    if (Test-Path (Join-Path $home ".roo")) {
        $script:RulesDirTargets += Join-Path $home ".roo\rules\AGENTS.md"
    }
    if (Test-Path (Join-Path $home ".augment")) {
        $script:RulesDirTargets += Join-Path $home ".augment\rules\AGENTS.md"
    }
    if (Test-Path (Join-Path $home "Documents\Cline")) {
        $script:RulesDirTargets += Join-Path $home "Documents\Cline\Rules\AGENTS.md"
    }
}

function No-TargetsFound {
    return ($script:AgentsTargets.Count -eq 0 -and
            $script:ClaudeTargets.Count -eq 0 -and
            $script:GeminiTargets.Count -eq 0 -and
            $script:RulesDirTargets.Count -eq 0)
}

function Sync-Targets {
    Assert-SourceExists

    if (No-TargetsFound) {
        Write-Error "No agent config directories found. Create them first or use -Targets* flags."
        exit 1
    }

    $total = 0

    foreach ($target in $AgentsTargets) {
        Assert-TargetParentExists -Target $target
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
        Copy-Item -Path $Source -Destination $target -Force
        $total++
    }

    foreach ($target in $ClaudeTargets) {
        Assert-TargetParentExists -Target $target
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
        Copy-Item -Path $Source -Destination $target -Force
        $total++
    }

    foreach ($target in $GeminiTargets) {
        Assert-TargetParentExists -Target $target
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
        Copy-Item -Path $Source -Destination $target -Force
        $total++
    }

    foreach ($target in $RulesDirTargets) {
        Assert-TargetDirWritable -Target $target
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
        Copy-Item -Path $Source -Destination $target -Force
        $total++
    }

    Write-Host "Synced to $total target(s)."
}

function DryRun-Sync {
    Assert-SourceExists

    if (No-TargetsFound) {
        Write-Error "No agent config directories found."
        exit 1
    }

    Write-Host "Would write to:"

    foreach ($target in $AgentsTargets) {
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
    }

    foreach ($target in $ClaudeTargets) {
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
    }

    foreach ($target in $GeminiTargets) {
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
    }

    foreach ($target in $RulesDirTargets) {
        Write-Host "  -> $target ($(Get-TargetLabel $target))"
    }
}

$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        "-TargetsOpenCode" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsOpenCode"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $AgentsTargets += $args[$i]
                $i++
            }
        }
        "-TargetsCodex" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsCodex"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $AgentsTargets += $args[$i]
                $i++
            }
        }
        "-TargetsAmp" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsAmp"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $AgentsTargets += $args[$i]
                $i++
            }
        }
        "-TargetsGoose" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsGoose"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $AgentsTargets += $args[$i]
                $i++
            }
        }
        "-TargetsClaude" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsClaude"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $ClaudeTargets += $args[$i]
                $i++
            }
        }
        "-TargetsGemini" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsGemini"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $GeminiTargets += $args[$i]
                $i++
            }
        }
        "-TargetsRooCode" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsRooCode"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $RulesDirTargets += $args[$i]
                $i++
            }
        }
        "-TargetsCline" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsCline"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $RulesDirTargets += $args[$i]
                $i++
            }
        }
        "-TargetsAugment" {
            if ($i + 1 -ge $args.Count -or $args[$i + 1] -like "-*") {
                Write-Error "Missing path after -TargetsAugment"
                exit 1
            }
            $i++
            while ($i -lt $args.Count -and $args[$i] -notlike "-*") {
                $RulesDirTargets += $args[$i]
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
        default {
            Write-Host "Unknown option: $($args[$i]). Use -Help for usage."
            exit 1
        }
    }
}

if (No-TargetsFound) { Detect-Targets }

if ($DryRun) {
    DryRun-Sync
}
else {
    Sync-Targets
}
