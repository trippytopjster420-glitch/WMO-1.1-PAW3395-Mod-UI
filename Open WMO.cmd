@echo off
rem Opens the mouse app in its own window (no tabs or address bar), using Edge or Chrome.
setlocal
set "FILE=%~dp0WMO1.1_Jster_Mod.html"
set "URL=file:///%FILE:\=/%"
set "SIZE=--window-size=1100,900"

for %%B in (
  "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
  "%LocalAppData%\Google\Chrome\Application\chrome.exe"
) do if exist "%%~B" (
  start "" "%%~B" --app="%URL%" %SIZE%
  exit /b
)

rem Neither browser found where expected: fall back to whatever opens .html files.
start "" "%FILE%"
