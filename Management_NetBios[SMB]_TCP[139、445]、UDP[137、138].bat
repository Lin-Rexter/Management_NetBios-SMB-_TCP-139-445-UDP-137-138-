set "params=%*" && cd /d "%CD%" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/C cd ""%CD%"" && %~s0 %params%", "", "runas", 1 >>"%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@ECHO OFF
TITLE Close [TCP_139�B445]�B[UDP_137�B138](Administrator)

GOTO MAIN

:MAIN
CLS
ECHO.
ECHO ==============================================================
ECHO                           ��ܥ\��
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] ���RDP�� (Change RDP Port)
ECHO [2] �޲zNetBIOS[SMB] TCP 139�B445 (Management NetBIOS[SMB] TCP 139�B445)
ECHO [3] �޲zNetBIOS UDP 137�B138 (Management NetBIOS[SMB] UDP 137�B138)
ECHO [4] �d��TCP�BUDP�s���� (Check TCP�BUDP Port)
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 4321 /N /M "��ܥ\��(Choose Function)[1~4]: "
IF ERRORLEVEL 4 (
	GOTO RDP_Info
)ELSE IF ERRORLEVEL 3 (
	GOTO NetBIOS_SMB
)ELSE IF ERRORLEVEL 2 (
	GOTO NetBIOS_UDP
)ELSE (
	GOTO Check_TCP_UDP
)

::REM =========================================================RDP=========================================================

:RDP_Info
CLS
ECHO.
ECHO =======================================================
ECHO.
powershell -command '�ثeRDP���s����(Current RDP Port):'+("Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" | Select-Object -ExpandProperty PortNumber")
ECHO.
CHOICE /C NYE /N /M "�O�_���s����(���UE���};���UN��^�D���)/Do you Want to Change Port(Press E to Exit; N to Home): "
IF ERRORLEVEL 3 (
	GOTO Exit
)ELSE IF ERRORLEVEL 2 (
	GOTO Change-RDP_Port
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)

:Change-RDP_Port
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P RDP-Port="�п�J�n�N�s�����אּ(���UEnter�ϥ��q�{��3389): "
IF "%RDP-Port%" EQU "" set rdp_port=3389
ECHO.

ECHO.
powershell -command Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value %RDP-Port%
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! )ELSE (ECHO. && ECHO �]�m���\! )
ECHO.
ECHO �]�m������W�h��...
powershell -command New-NetFirewallRule -DisplayName 'RDPPORTLatest-TCP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort %RDP-Port%
ECHO.
powershell -command New-NetFirewallRule -DisplayName 'RDPPORTLatest-UDP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort %RDP-Port%
ECHO.
Net stop Termservice
ECHO.
Net start Termservice
ECHO.
ECHO ��粒��!
ECHO.
powershell -command '�ثeRDP���s����:'+("Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" | Select-Object -ExpandProperty PortNumber")
GOTO Exit

::REM ==================================================Close NetBIOS(SMB)=================================================

:NetBIOS_SMB
CLS
ECHO.
ECHO =======================================================
ECHO.
ECHO ---------------------------------------
ECHO �ثeSMB(139)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
netstat -ano | findstr LISTEN | findstr 139
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A!)
ECHO.

ECHO ---------------------------------------
ECHO �ثeSMB(445)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
netstat -ano | findstr LISTEN | findstr 445
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A! && GOTO Switch_SMB)

:Switch_SMB
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 321 /N /M "[1]����SMB�s���� [2]�}��SMB�s���� [3]��^�D���: "
IF ERRORLEVEL 3 (
	GOTO Close_SMB
)ELSE IF ERRORLEVEL 2 (
	GOTO Open_SMB
)ELSE (
	GOTO MAIN
)

:Close_SMB
ECHO.
ECHO =======================================================
ECHO.

::REM ========================================Close NetBIOS=======================================

ECHO ---------------------------------------
ECHO ---------------�iNetBios�j---------------
ECHO ---------------------------------------
ECHO ����NetBios�\�त...
powershell -command $base = 'HKLM:SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' ; $interfaces = Get-ChildItem $base ^| Select -ExpandProperty PSChildName ; foreach($interface in $interfaces) {Set-ItemProperty -Path "$base\$interface" -Name "NetbiosOptions" -Value 2}
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ��������!)ELSE (ECHO. && ECHO �������\)

::REM ========================================Close Port_139======================================

ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 139�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_139_Entries_RA REM �ˬd���U��Restrictanonymous���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U����ΦW�s����...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "restrictanonymous" -Value "2"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)

ECHO.
ECHO ����TCP/IP NetBIOS Helper�A�Ȥ�...
ECHO.
sc stop lmhosts
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�����A�]���A�Ȥw�]�m���Τ�!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)

ECHO.
ECHO �NTCP/IP NetBIOS Helper�A�ȳ]�m��ʤ�...
ECHO.
sc config lmhosts start=demand
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
ECHO.

ECHO ����NetBios�A�Ȥ�...
ECHO.
sc stop netbios
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�����A�]���A�Ȥw�]�m���Τ�!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)

ECHO.
ECHO �NNetBios�A�������]�m���Τ�...
ECHO.
sc config netbios start=disabled
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
ECHO.

CALL :Is_Exist_139_Entries_ShareServer REM �ˬd���U��AutoShareServer���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U����t�κϺФ��ɤ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -Value "0"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)

CALL :Is_Exist_139_Entries_ShareWks REM �ˬd���U��AutoShareWks���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U����t�θ�Ƨ����ɤ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Value "0"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)

ECHO �]�m���������139��J�W�h��...
ECHO.
powershell -command New-NetFirewallRule -DisplayName "Block_TCP-139" -Direction Inbound -LocalPort 139 -Protocol TCP -Action Block
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall add rule name="Block_TCP-139" dir=in protocol=tcp localport=139 action=block
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall set portopening protocol=tcp port=139 mode=disable name="Block_TCP-139"
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! )ELSE (ECHO. && ECHO �]�m���\! )
	)ELSE (
		ECHO. && ECHO �]�m���\! 
	)
)ELSE (
	ECHO. && ECHO �]�m���\! 
)

::REM ========================================Close Port_445======================================

ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 445�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_445_Entries_SMBD REM �ˬd���U��SMBDeviceEnabled���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �������U����SMBDeviceEnabled�Ȥ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "SMBDeviceEnabled" -Value "0"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ��������! && ECHO.)ELSE (ECHO. && ECHO �������\! && ECHO.)
)

CALL :Is_Exist_445_Entries_TB REM �ˬd���U��TransportBindName���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �M�ŵ��U����TransportBindName�Ȥ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "TransportBindName" -Value "$null"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �M�ť���! && ECHO.)ELSE (ECHO. && ECHO �M�Ŧ��\! && ECHO.)
)

ECHO ����lanmanserver�A�Ȥ�...
ECHO.
sc stop lanmanserver
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�����A�]���A�Ȥw�]�m���Τ�!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)

ECHO.
ECHO �Nlanmanserver�A�ȳ]�m���Τ�...
ECHO.
sc config lanmanserver start=disabled
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �L�k�����A��!)ELSE (ECHO. && ECHO �����A�Ȧ��\!)

ECHO.
ECHO �]�m���������445��J�W�h��...
ECHO.
powershell -command New-NetFirewallRule -DisplayName "Block_TCP-445" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Block
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall add rule name="Block_TCP-445" dir=in protocol=tcp localport=445 action=block
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall set portopening protocol=tcp port=445 mode=disable name="Block_TCP-445"
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
	)ELSE (
		ECHO. && ECHO �]�m���\! 
	)
)ELSE (
	ECHO. && ECHO �]�m���\! 
)
ECHO.
PAUSE
GOTO MAIN

::REM ==================================================Open NetBIOS(SMB)==================================================

:Open_SMB
ECHO.
ECHO =======================================================
ECHO.

::REM ========================================Open NetBIOS========================================

ECHO ---------------------------------------
ECHO ---------------�iNetBios�j---------------
ECHO ---------------------------------------
ECHO �}��NetBios�\�त...
powershell -command $base = 'HKLM:SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' ; $interfaces = Get-ChildItem $base ^| Select -ExpandProperty PSChildName ; foreach($interface in $interfaces) {Set-ItemProperty -Path "$base\$interface" -Name "NetbiosOptions" -Value 0}
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �}�ҥ���!)ELSE (ECHO. && ECHO �}�Ҧ��\)

::REM ========================================Open Port_139=======================================

ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 139�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_139_Entries_RA REM �ˬd���U��Restrictanonymous���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U����ΦW�s����...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "restrictanonymous" -Value "0"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)
ECHO.
ECHO �NTCP/IP NetBIOS Helper�A�ȳ]�m��ʤ�...
ECHO.
sc config lmhosts start=demand
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)

ECHO.
ECHO �}��TCP/IP NetBIOS Helper�A�Ȥ�...
ECHO.
sc start lmhosts
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}�ҡA�]���A�Ȥw�]�m��ʤ�!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �}�ҪA�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�}�ҪA��!
)

ECHO.
ECHO �NNetBios�A�������]�m�}�Ҥ�...
ECHO.
sc config netbios start=auto
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)

ECHO.
ECHO �}��NetBios�A�Ȥ�...
ECHO.
sc start netbios
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}�ҡA�]���A�Ȥw�]�m�}�Ҥ�!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �}�ҪA�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�}�ҪA��!
)
ECHO.

CALL :Is_Exist_139_Entries_ShareServer REM �ˬd���U��AutoShareServer���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U��ҥΨt�κϺФ��ɤ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -Value "1"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)

CALL :Is_Exist_139_Entries_ShareWks REM �ˬd���U��AutoShareWks���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U��ҥΨt�θ�Ƨ����ɤ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Value "1"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)

ECHO �������������139��J�W�h��...
ECHO.
powershell -command Remove-NetFirewallRule -DisplayName "Block_TCP-139"
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall delete rule name="Block_TCP-139" dir=in
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall delete portopening protocol=tcp port=139
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! )ELSE (ECHO. && ECHO �]�m���\! )
	)ELSE (
		ECHO. && ECHO �]�m���\!
	)
)ELSE (
	ECHO. && ECHO �]�m���\!
)

::REM ========================================Open Port_445=======================================

ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 445�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_445_Entries_SMBD REM �ˬd���U��SMBDeviceEnabled���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �}�ҵ��U����SMBDeviceEnabled�Ȥ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "SMBDeviceEnabled" -Value "1"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �}�ҥ���! && ECHO.)ELSE (ECHO. && ECHO �}�Ҧ��\! && ECHO.)
)

CALL :Is_Exist_445_Entries_TB REM �ˬd���U��TransportBindName���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �]�m���U����TransportBindName�Ȥ�...
	ECHO.
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "TransportBindName" -Value "\Device\"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! && ECHO.)ELSE (ECHO. && ECHO �]�m���\! && ECHO.)
)

ECHO.
ECHO �Nlanmanserver�A�ȳ]�m�ҥΤ�...
ECHO.
sc config lanmanserver start=auto
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �L�k�}�ҪA��!)ELSE (ECHO. && ECHO �}�ҪA�Ȧ��\!)

ECHO.
ECHO �}��lanmanserver�A�Ȥ�...
ECHO.
sc start lanmanserver
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}�ҡA�]���A�Ȥw�]�m�}�Ҥ�!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �}�ҪA�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�}�ҪA��!
)

ECHO.
ECHO �������������445��J�W�h��...
ECHO.
powershell -command Remove-NetFirewallRule -DisplayName "Block_TCP-445"
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall delete rule name=��Block_TCP-445�� dir=in
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall delete portopening protocol=tcp port=445
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)	
	)ELSE (
		ECHO. && ECHO �]�m���\! 
	)
)ELSE (
	ECHO. && ECHO �]�m���\! 
)
ECHO.
PAUSE
GOTO MAIN

:Is_Exist_139_Entries_RA
ECHO �ˬd���U��RestrictAnonymous���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -name "restrictanonymous" ^| findstr restrictanonymous > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_139_Entries_RA)ELSE (ECHO �T�{�s�bRestrictAnonymous����!)
EXIT /B

:Is_Exist_139_Entries_ShareServer
ECHO �ˬd���U��AutoShareServer���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -name "AutoShareServer" ^| findstr AutoShareServer > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_139_Entries_ShareServer)ELSE (ECHO �T�{�s�bAutoShareServer����!)
EXIT /B

:Is_Exist_139_Entries_ShareWks
ECHO �ˬd���U��AutoShareWks���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -name "AutoShareWks" ^| findstr AutoShareWks > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_139_Entries_ShareWks)ELSE (ECHO �T�{�s�bAutoShareWks����!)
EXIT /B

:Is_Exist_445_Entries_SMBD
ECHO �ˬd���U��SMBDeviceEnabled���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -name "SMBDeviceEnabled" ^| findstr SMBDeviceEnabled > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_445_Entries_SMBD)ELSE (ECHO �T�{�s�bSMBDeviceEnabled����!)
EXIT /B

:Is_Exist_445_Entries_TB
ECHO �ˬd���U��TransportBindName���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -name "TransportBindName" ^| findstr TransportBindName > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_445_Entries_TB)ELSE (ECHO �T�{�s�bTransportBindName����!)
EXIT /B

:Create_139_Entries_RA
ECHO.
ECHO ���s�bRestrictanonymous���ءA�Ыؤ�...
ECHO.
powershell -command New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "restrictanonymous" -PropertyType "DWORD" -Value "0"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�]�m���U����ΦW�s��! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
EXIT /B

:Create_139_Entries_ShareServer
ECHO.
ECHO ���s�bAutoShareServer���ءA�Ыؤ�...
ECHO.
powershell -command New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -PropertyType "DWORD" -Value "0"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�]�m���U��t�κϺФ���! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
EXIT /B

:Create_139_Entries_ShareWks
ECHO.
ECHO ���s�bAutoShareWks���ءA�Ыؤ�...
ECHO.
powershell -command New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -PropertyType "DWORD" -Value "0"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�]�m���U��t�θ�Ƨ�����! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
EXIT /B

:Create_445_Entries_SMBD
ECHO.
ECHO ���s�bSMBDeviceEnabled���ءA�Ыؤ�...
ECHO.
CALL :Check_OS
IF %OS_Type% == x64 (SET REG_WORD=QWORD)ELSE (SET REG_WORD=DWORD)
powershell -command New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "SMBDeviceEnabled" -PropertyType "%REG_WORD%" -Value "1"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�]�m���U����SMBDeviceEnabled��! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
EXIT /B

:Create_445_Entries_TB
ECHO.
ECHO ���s�bTransportBindName���ءA�Ыؤ�...
ECHO.
powershell -command New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "TransportBindName" -PropertyType "String" -Value "1"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�]�m���U����TransportBindName��! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
EXIT /B

:Check_OS
IF %PROCESSOR_ARCHITECTURE% == "AMD64" (
	SET OS_Type=x64
)ElSE (
	SET OS_Type=x86
)
EXIT /B

::REM ==================================================Close NetBIOS(UDP)=================================================

:NetBIOS_UDP
CLS
ECHO.
ECHO =======================================================
ECHO.
ECHO ---------------------------------------
ECHO �ثeSMB(137)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
netstat -ano | findstr LISTEN | findstr 137
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A!)
ECHO.

ECHO ---------------------------------------
ECHO �ثeSMB(138)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
netstat -ano | findstr LISTEN | findstr 138
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A! && GOTO Switch_UDP)

:Switch_UDP
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 321 /N /M "[1]����UDP(137~8)�s���� [2]�}��UDP(137~8)�s���� [3]��^�D���: "
IF ERRORLEVEL 3 (
	GOTO Close_NetBIOS_UDP_137
)ELSE IF ERRORLEVEL 2 (
	GOTO Open_NetBIOS_UDP_137
)ELSE (
	GOTO MAIN
)

::REM ========================================Close Port_137_138===================================

:Close_NetBIOS_UDP_137
CLS
ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 137�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_Port_137 REM �ˬd������O�_�w���]�mPort 137�W�h��
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	GOTO Close_NetBIOS_UDP_138
)
ECHO.
ECHO �]�m���������137��J�W�h��...
ECHO.
powershell -command New-NetFirewallRule -DisplayName "Block_UDP-137" -Direction Inbound -LocalPort 137 -Protocol UDP -Action Block
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall add rule name="Block_UDP-137" dir=in protocol=udp localport=137 action=block
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall set portopening protocol=udp port=137 mode=disable name="Block_UDP-137"
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
	)ELSE (
		ECHO. && ECHO �]�m���\!
	)
)ELSE (
	ECHO. && ECHO �]�m���\!
)

:Close_NetBIOS_UDP_138
ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 138�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_Port_138 REM �ˬd������O�_�w���]�mPort 138�W�h��
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	PAUSE
	GOTO MAIN
)
ECHO.
ECHO �]�m���������138��J�W�h��...
ECHO.
powershell -command New-NetFirewallRule -DisplayName "Block_UDP-138" -Direction Inbound -LocalPort 138 -Protocol UDP -Action Block
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall add rule name="Block_UDP-138" dir=in protocol=udp localport=138 action=block
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall set portopening protocol=udp port=138 mode=disable name="Block_UDP-138"
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
	)ELSE (
		ECHO. && ECHO �]�m���\!
	)
)ELSE (
	ECHO. && ECHO �]�m���\!
)
ECHO.
PAUSE
GOTO MAIN

::REM ========================================Open Port_137_138====================================

:Open_NetBIOS_UDP_137
CLS
ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 137�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_Port_137 REM �ˬd������O�_�w���]�mPort 137�W�h��
IF %ERRORLEVEL% NEQ 0 (
	GOTO Open_NetBIOS_UDP_138
)ELSE (
	SET ERRORLEVEL=
)
ECHO.
ECHO �������������137��J�W�h��...
ECHO.
powershell -command Remove-NetFirewallRule -DisplayName "Block_UDP-137"
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall delete rule name=��Block_UDP-137�� dir=in
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall delete portopening protocol=udp port=137
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
	)ELSE (
		ECHO. && ECHO �]�m���\!
	)
)ELSE (
	ECHO. && ECHO �]�m���\!
)

:Open_NetBIOS_UDP_138
ECHO.
ECHO ---------------------------------------
ECHO --------------�iPort 138�j---------------
ECHO ---------------------------------------
CALL :Is_Exist_Port_138 REM �ˬd������O�_�w���]�mPort 138�W�h��
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	PAUSE
	GOTO MAIN
)ELSE (
	SET ERRORLEVEL=
)
ECHO.
ECHO �������������138��J�W�h��...
ECHO.
powershell -command Remove-NetFirewallRule -DisplayName "Block_UDP-138"
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall delete rule name=��Block_UDP-138�� dir=in
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall delete portopening protocol=udp port=138
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
	)ELSE (
		ECHO. && ECHO �]�m���\!
	)
)ELSE (
	ECHO. && ECHO �]�m���\!
)
ECHO.
PAUSE
GOTO MAIN

:Is_Exist_Port_137
ECHO �ˬd������O�_�w���]�m137�W�h��...
powershell -command Get-NetFirewallRule -DisplayName "Block_UDP-137" > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �T�{���s�b�W�h! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �T�{�w�g�s�b�W�h!) 
EXIT /B

:Is_Exist_Port_138
ECHO �ˬd������O�_�w���]�m138�W�h��...
powershell -command Get-NetFirewallRule -DisplayName "Block_UDP-138" > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �T�{���s�b�W�h! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �T�{�w�g�s�b�W�h!)
EXIT /B

::REM ==================================================Check_TCP_UDP_Port=================================================

:Check_TCP_UDP
CLS
ECHO.
ECHO =======================================================
ECHO.
SET /P Check-Port="�п�J�n�ʬݪ��s����(��JQ��^�D���;��JE���};����J��ܩҦ��s����): "
IF /I "%Check-Port%" EQU "Q" (
	GOTO MAIN
)ELSE IF /I "%Check-Port%" EQU "E" (
	GOTO Exit
)ELSE IF "%Check-Port%" EQU "" (
	SET RUN=^| findstr LISTEN
)ELSE (
	SET RUN=^| findstr LISTEN ^| findstr "%Check-Port%"
)
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
netstat -ano %RUN%
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO �ثe�S�����s���� && ECHO. && PAUSE && GOTO Check_TCP_UDP
)ELSE (
	ECHO. && PAUSE && GOTO Check_TCP_UDP
)

::REM =========================================================EXIT========================================================

:Exit
ECHO.
ECHO.
PAUSE
EXIT

