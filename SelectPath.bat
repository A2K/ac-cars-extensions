<# : chooser.bat
:: launches a File... Open sort of file chooser and outputs choice(s) to the console

@echo off
setlocal

for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
    echo %%~I
)
goto :EOF

: end Batch portion / begin PowerShell hybrid chimera #>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.FolderBrowserDialog
[void]$f.ShowDialog()
$f.SelectedPath

