@echo off

set host=%1
set user=%2
set pass=%3
set server_root_path=%4
set local_root_path=%5
set backup_name=backup.sync.tar.gz
set extra_params_include=
set extra_params_exclude=
set string_include=--include
set string_exclude=--exclude

rem Archiving on server

:while
if not [%1] == [] (
   if "%1" == "%string_exclude%" (
       set extra_params_exclude=%extra_params_exclude% %string_exclude%=%2
       shift
       shift
       goto :while
   ) else if "%1" == "%string_include%" (
       set extra_params_include=%extra_params_include% %2
       shift
       shift
       goto :while
   ) else (
       shift
       goto :while
   )
)

if "%extra_params_include%" == "" (
    set extra_params_include=./
)

echo cd %server_root_path% > commands.dat
echo tar %extra_params_exclude% -zcvf ../%backup_name% %extra_params_include% >> commands.dat
echo exit >> commands.dat
D:\0-MediaXP\Development\Tools\SSH\putty.exe -ssh %user%@%host% -pw %pass% -m commands.dat
del commands.dat

rem Download archive
echo option confirm off > commands.dat
echo option transfer binary >> commands.dat
echo open sftp://%user%:%pass%@%host%:22 -hostkey="ssh-rsa " >> commands.dat
echo get %server_root_path%/../%backup_name% %local_root_path%\..\%backup_name% >> commands.dat
echo exit >> commands.dat
D:\0-MediaXP\Development\Tools\SSH\winscp432\WinSCP.exe /console /script=commands.dat
del commands.dat

rem Unzipping
7z x "%local_root_path%\..\%backup_name%" -so | 7z x -aoa -si -ttar -o"%local_root_path%"
del %local_root_path%\..\%backup_name%

rem Delete archive on server
echo rm %server_root_path%/../%backup_name% > commands.dat
echo exit >> commands.dat
D:\0-MediaXP\Development\Tools\SSH\putty.exe -ssh %user%@%host% -pw %pass% -m commands.dat
del commands.dat
