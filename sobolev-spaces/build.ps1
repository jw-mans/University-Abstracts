# Локальная сборка конспекта.
#   .\build.ps1          — полная сборка (два прохода, нужны ссылки и оглавление)
#   .\build.ps1 -Fast    — один проход, без рисунков (черновик)
param([switch]$Fast)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# TinyTeX ставится в профиль пользователя и может не лежать в PATH
$tinytex = Join-Path $env:APPDATA "TinyTeX\bin\windows"
if (Test-Path $tinytex) { $env:PATH = "$tinytex;$env:PATH" }

$pdflatex = (Get-Command pdflatex -ErrorAction SilentlyContinue).Source
if (-not $pdflatex) { throw "pdflatex не найден. Проверь установку TinyTeX или MiKTeX." }

$common = @("-interaction=nonstopmode", "-halt-on-error", "-file-line-error")

if ($Fast) {
    # Рисунки выключаются через \showfiguresfalse, объявленный до \input{preamble}
    $jobname = "main-draft"
    $src = '\PassOptionsToPackage{draft}{graphicx}\input{main.tex}'
    & $pdflatex @common "-jobname=$jobname" $src
} else {
    & $pdflatex @common main.tex
    if ($LASTEXITCODE -ne 0) { throw "первый проход pdflatex завершился с ошибкой" }
    & $pdflatex @common main.tex
}

if ($LASTEXITCODE -ne 0) { throw "pdflatex завершился с ошибкой" }

$pdf = if ($Fast) { "main-draft.pdf" } else { "main.pdf" }
$size = [math]::Round((Get-Item $pdf).Length / 1KB, 1)
"Готово: $pdf ($size KB)"
