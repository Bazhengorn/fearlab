[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$validatorPath = Join-Path $PSScriptRoot 'Test-ServerConfig.ps1'
$powerShellPath = (Get-Process -Id $PID).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

function Invoke-ValidatorCase {
    param(
        [string] $Name,
        [string] $Json,
        [int] $ExpectedExitCode,
        [string] $ExpectedMessage,
        [switch] $MissingFile
    )

    $casePath = Join-Path $tempRoot "$Name.json"
    if (-not $MissingFile) {
        Set-Content -LiteralPath $casePath -Value $Json -Encoding UTF8
    }
    $encodedPath = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($casePath))
    $encodedValidator = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($validatorPath))
    $command = "`$ErrorActionPreference='Continue'; & ([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('$encodedValidator'))) -Path ([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('$encodedPath'))) 2>&1 | ForEach-Object { `$_.ToString() }; exit `$LASTEXITCODE"
    $output = @(& $powerShellPath -NoProfile -Command $command)
    $actualExitCode = $LASTEXITCODE
    $combinedOutput = $output -join "`n"

    if ($actualExitCode -ne $ExpectedExitCode) {
        throw "Case '$Name': expected exit code $ExpectedExitCode, got $actualExitCode. Output: $combinedOutput"
    }
    if ($combinedOutput -notmatch [regex]::Escape($ExpectedMessage)) {
        throw "Case '$Name': expected output to contain '$ExpectedMessage'. Output: $combinedOutput"
    }

    Write-Output "PASS: $Name (exit $actualExitCode)"
}

try {
    Invoke-ValidatorCase 'valid-json' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":false,"logLevel":"info"}' 0 'is valid'
    Invoke-ValidatorCase 'players-zero' '{"serverName":"Test","maxPlayers":0,"loggingEnabled":false}' 1 'in the range 1 to 64'
    Invoke-ValidatorCase 'players-one' '{"serverName":"Test","maxPlayers":1,"loggingEnabled":false}' 0 'is valid'
    Invoke-ValidatorCase 'players-sixty-four' '{"serverName":"Test","maxPlayers":64,"loggingEnabled":false}' 0 'is valid'
    Invoke-ValidatorCase 'invalid-syntax' '{"serverName":' 1 'Invalid JSON'
    Invoke-ValidatorCase 'missing-file' '' 1 'Configuration file not found' -MissingFile
    Invoke-ValidatorCase 'missing-field' '{"serverName":"Test","maxPlayers":32}' 1 "Missing required field 'loggingEnabled'"
    Invoke-ValidatorCase 'wrong-server-name-type' '{"serverName":7,"maxPlayers":32,"loggingEnabled":false}' 1 "Field 'serverName' must be a non-empty string"
    Invoke-ValidatorCase 'wrong-player-count-type' '{"serverName":"Test","maxPlayers":"32","loggingEnabled":false}' 1 "Field 'maxPlayers' must be an integer"
    Invoke-ValidatorCase 'player-count-out-of-range' '{"serverName":"Test","maxPlayers":65,"loggingEnabled":false}' 1 'in the range 1 to 64'
    Invoke-ValidatorCase 'wrong-boolean-type' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":"false"}' 1 'must be a JSON boolean'
    Invoke-ValidatorCase 'numeric-boolean-type' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":1}' 1 'must be a JSON boolean'
    Invoke-ValidatorCase 'null-boolean-type' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":null}' 1 'must be a JSON boolean'
    Invoke-ValidatorCase 'empty-server-name' '{"serverName":" ","maxPlayers":32,"loggingEnabled":false}' 1 'must be a non-empty string'
    Invoke-ValidatorCase 'wrong-log-level-type' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":false,"logLevel":1}' 1 "Field 'logLevel' must be a string"
    Invoke-ValidatorCase 'invalid-log-level' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":false,"logLevel":"trace"}' 1 'Invalid ''logLevel'' value'
    Invoke-ValidatorCase 'uppercase-log-level' '{"serverName":"Test","maxPlayers":32,"loggingEnabled":false,"logLevel":"INFO"}' 1 'Invalid ''logLevel'' value'

    Push-Location $tempRoot
    try {
        $defaultOutput = @(& $powerShellPath -NoProfile -File $validatorPath)
        if ($LASTEXITCODE -ne 0 -or ($defaultOutput -join "`n") -notmatch 'is valid') {
            throw "Default path failed outside repository: $($defaultOutput -join '`n')"
        }
        Write-Output 'PASS: default-path-outside-repository (exit 0)'
    }
    finally {
        Pop-Location
    }
}
finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
}
