    @echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: 
::   make.bat
::
::   This script is part of ars scriptum build wrappers.
:: 
::   Example:  To build in Debug, x64:
::             .\Build.bat
::
::   VERSION:  1.0.1
::
:: ==============================================================================
::   arsccriptum - made in quebec 2020 <guillaumeplante.qc@gmail.com>
:: ==============================================================================

goto :init

:header
    echo. %__script_name% v%__script_version%
    echo.    This script is part of ars scriptum build wrappers.
    echo.
    goto :eof

:usage
    echo. Usage:
    echo. %__script_name%
    echo.
    goto :eof

:notes
    echo.
    goto :eof


:init
    set "__script_name=%~n0"
    set "__script_version=1.0"

    set "__script_file=%~0"
    set "__script_path=%~dp0"

    set "__opt_help="
    set "__opt_version="
    set "__opt_verbose="
    set "__path_cd=%cd%"

    set "__scripts_root=%AutomationScriptsRoot%"
    call :read_script_root development\build-automation  BuildAutomation
    echo %__scripts_root%
    set "__ahk_compiler="%AHK_COMPILER%"
    set "__log_path=%__script_path%log"
    set "__bin_path=%cd%\bin"
    set __log_file=""
    
    set "__lib_out=%__scripts_root%\batlibs\out.bat"
    set "__lib_date=%__scripts_root%\batlibs\date.bat"
	::for /f %%i in ('C:\\Programs\\Git\\cmd\\git.exe rev-parse HEAD') do (
     ::       set "__current_git_revision=%%i"
      ::  )
      goto :build
:parse
    if "%~1"=="" goto :checklibs

    if /i "%~1"=="/?"         call :header & call :usage & call :notes "%~2" & goto :end
    if /i "%~1"=="-?"         call :header & call :usage & call :notes "%~2" & goto :end
    if /i "%~1"=="/h"         call :header & call :usage & call :notes "%~2" & goto :end
    if /i "%~1"=="-h"         call :header & call :usage & call :notes "%~2" & goto :end
    if /i "%~1"=="--help"     call :header & call :usage & call :notes "%~2" & goto :end

    shift
    goto :parse

:checklibs
     if not exist %__lib_out%  call :error_missing_lib %__lib_out% & goto :end
     if not exist %__lib_date% call :error_missing_lib %__lib_date% & goto :end
     if not exist %AHK_COMPILER% call :error_missing_lib %AHK_COMPILER% & goto :end     

:setdefaults
    if "" == "%TEMP%" set "TEMP=%SYSTEMDRIVE%\Windows\Temp"


:validate
    if not exist %AHK_COMPILER%  call :error_missing_compiler & goto :end
    goto :build

:: ==============================================================================
::   build
:: ==============================================================================
:build
    echo.
	call %__lib_out% :__out_d_blu " ==================================================================" 
	call %__lib_out% :__out_n_d_cya "  CURRENT GIT REVISION  "
	call %__lib_out% :__out_d_whi "  %__current_git_revision% "
	call %__lib_out% :__out_n_d_cya "  COMPILATION AHK COMPILER "
	call %__lib_out% :__out_d_whi "    %AHK_COMPILER% "
	call %__lib_out% :__out_d_blu " ================================================================== "    
    

    set "__ahk_src=%__path_cd%\RegEx-Tester.ahk"
    set "__ahk_exe=%__path_cd%\RegEx-Tester.exe"
    set "__ahk_ico=%__path_cd%\ico\app.ico"


    call %__lib_out% :__out_n_d_red "Source:    "
    call %__lib_out% :__out_d_yel "%__ahk_src%"
    call %__lib_out% :__out_n_d_red "Out file   "
    call %__lib_out% :__out_d_yel "%__ahk_exe%"
    call %__lib_out% :__out_n_d_red "Icone:     "
    call %__lib_out% :__out_d_yel "%__ahk_ico%"    
    "%AHK_COMPILER%" /in "%__ahk_src%" /out "%__ahk_exe%" /icon "%__ahk_ico%"
    
    if "%ERRORLEVEL%"=="0"         call :build_success & goto :end
    call :error_msbuild_failed %ERRORLEVEL%
    goto :eof




:read_script_root
    set regpath=%OrganizationHKCU::=%
    for /f "tokens=2,*" %%A in ('C:\WINDOWS\system32\reg.exe query %regpath%\%1 /v %2') do (
            set "__scripts_root=%%B"
        )
    goto :eof


:: ==============================================================================
::   errors
:: ==============================================================================
:error_missing_arguments
    echo.
    call %__lib_out% :__out_l_red "   make error"
    call %__lib_out% :__out_d_yel "   Missing aguments"
    echo.
    goto :end

:error_missing_compiler
    echo.
    call %__lib_out% :__out_l_red "   make error"
    call %__lib_out% :__out_d_yel "   Missing AHK COMPILER: %AHK_COMPILER%."
    echo.
    goto :end

:error_missing_configuration
    echo.
    call %__lib_out% :__out_l_red "   make error"
    call %__lib_out% :__out_d_yel "   Missing build configuration. Specify using /c. Type /h for usage."
    echo.
    goto :end

:error_missing_target
    echo.
    call %__lib_out% :__out_l_red "   make error"
    call %__lib_out% :__out_d_yel "   Missing build target. Specify using /t. Type /h for usage."
    echo.
    goto :end

:error_missing_platform
    echo.
    call %__lib_out% :__out_l_red "   make error"
    call %__lib_out% :__out_d_yel "   Missing build platform. Specify using /p. Type /h for usage."
    echo.
    goto :end

:error_msbuild_failed
    echo.
    call %__lib_out% :__out_l_red "   make error: build failed with error %~1"
    if not %__log_file% == "" (
        echo "   make error: build failed with error %~1" >> %__log_file%
        )
    echo.
    goto :end

:error_missing_lib
    echo.
    call %__lib_out% :__out_l_red "   Error"
    call %__lib_out% :__out_d_yel "   Missing bat lib: %~1"
    echo.
    goto :end


:build_success
    echo.
    call %__lib_out% :__out_l_grn "Build Completed!"
    echo.
    goto :end

:end
    exit /B


 