set "params=%*" && cd /d "%CD%" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/C cd ""%CD%"" && %~s0 %params%", "", "runas", 1 >>"%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@ECHO OFF
TITLE Close [TCP_139�B445]�B[UDP_137�B138](Administrator)

GOTO MAIN

:MAIN
CLS
ECHO.
ECHO ==============================================================
ECHO                            ��ܥ\��
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] �޲zRDP(Remote Desktop Services)�A��
ECHO [2] �޲zRPC(Remote Procedure Call)�A��
ECHO [3] �޲zNetBios(NetBIOS over TCP/IP)�A��
ECHO [4] �޲zSMB(Server Message Block)[NetBios] UDP_137�B138 Port
ECHO [5] �޲zSMB(Server Message Block) TCP_139[NetBios]�B445 Port
ECHO [6] �޲zSMBv1�BSMBv2�BSMBv3
ECHO [7] �d��TCP/UDP�s���𪬺A
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 7654321 /N /M "��ܥ\��[1~7]: "
IF ERRORLEVEL 7 (
	GOTO RDP_Service_Ask
)ELSE IF ERRORLEVEL 6 (
	GOTO RPC_Info
)ELSE IF ERRORLEVEL 5 (
	GOTO NetBIOS_Service_Info
)ELSE IF ERRORLEVEL 4 (
	GOTO SMB_UDP_Ask
)ELSE IF ERRORLEVEL 3 (
	GOTO SMB_TCP_Ask
)ELSE IF ERRORLEVEL 2 (
	GOTO SMB_Service_Ask
)ELSE (
	GOTO Check_TCP_UDP
)


::REM =====================================================================================================================
::REM =========================================================RDP=========================================================
::REM =====================================================================================================================


:RDP_Service_Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 4321 /N /M "[1]���RDP�s���� [2]����RDP�A�� [3]�}��RDP�A�� [4]��^�D���: "
IF ERRORLEVEL 4 (
	GOTO RDP_Info
)ELSE IF ERRORLEVEL 3 (
	GOTO Close-RDP_Service-REG-A
)ELSE IF ERRORLEVEL 2 (
	GOTO Open-RDP_Service-REG-A
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)

::REM ====================================Change_RDP_Port====================================

:RDP_Info
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :RDP_Port
ECHO.
CHOICE /C ENY /N /M "�O�_���s����( [Y]��� [N]��^ [E]���} ): "
IF ERRORLEVEL 3 (
	GOTO Change-RDP_Port-Ask
)ELSE IF ERRORLEVEL 2 (
	GOTO RDP_Service_Ask
)ELSE IF ERRORLEVEL 1 (
	GOTO Exit
)

:Change-RDP_Port-Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :RDP_Port
ECHO.
SET "RDP-Port="
SET /P RDP-Port="�п�J�s���s����(1001~254535)(���UEnter�ϥ��q�{��3389)[B/b:��^]: "
IF NOT DEFINED RDP-Port (
	SET RDP-Port=3389
)ELSE IF /I "%RDP-Port%" EQU "B" (
	GOTO RDP_Info
)
CALL :Check_Port_Scope %RDP-Port% REM �T�{�s�����J�O�_���T
IF "%Scope%"=="False" (
	ECHO.
	PAUSE
	GOTO Change-RDP_Port-Ask
)
ECHO.
GOTO Change-RDP_Port

:Change-RDP_Port
ECHO --------------------------------------------
ECHO ���s����...
ECHO.
Powershell -command Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" -Value %RDP-Port%
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ��異��! )ELSE (ECHO. && ECHO ��令�\! )
ECHO.
GOTO RDP_TCP

:RDP_TCP
ECHO --------------------------------------------
ECHO [1/2]�]�m������W�h��[TCP]...
ECHO.
CALL :Check_Rule RDPPORTLatest-TCP-In
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO �T�{���إ߳W�h�A�إߤ�...
)ELSE (
	ECHO. && ECHO �w�إ߳W�h�A��s��... && ECHO.
	Powershell -command Remove-NetFirewallRule -DisplayName "RDPPORTLatest-TCP-In"
)
ECHO.
Powershell -command New-NetFirewallRule -DisplayName 'RDPPORTLatest-TCP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort %RDP-Port%
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! )ELSE (ECHO. && ECHO �]�m���\! )
ECHO.
GOTO RDP_UDP

:RDP_UDP
ECHO --------------------------------------------
ECHO [2/2]�]�m������W�h��[UDP]...
ECHO.
CALL :Check_Rule RDPPORTLatest-UDP-In
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO �T�{���إ߳W�h�A�إߤ�...
)ELSE (
	ECHO. && ECHO �w�إ߳W�h�A��s��... && ECHO.
	Powershell -command Remove-NetFirewallRule -DisplayName "RDPPORTLatest-UDP-In"
)
ECHO.
Powershell -command New-NetFirewallRule -DisplayName 'RDPPORTLatest-UDP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort %RDP-Port%
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! )ELSE (ECHO. && ECHO �]�m���\! )
ECHO.
GOTO Show_RDP_Port

:Show_RDP_Port
ECHO --------------------------------------------
Powershell -command '���᪺RDP�s����:'+("Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" | Select-Object -ExpandProperty PortNumber")
ECHO.
PAUSE
GOTO RDP_Info

::REM ====================================Close-RDP_Service==================================

:Close-RDP_Service-REG-A
ECHO --------------------------------------------
ECHO �ק���U��fDenyTSConnections[SYSTEM]�A�������ݪA�Ȥ�...
ECHO.
CALL :Is_Exist_fDenyTS_Entries REM �ˬd���U��fDenyTSConnections���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �������ݪA�Ȩ�w��...
	ECHO.
	powershell -command Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value "1"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)
ECHO.
GOTO Close-RDP_Firewall

:Close-RDP_Service-REG-B
ECHO --------------------------------------------
ECHO �ק���U��fDenyTSConnections[SOFTWARE]�A�������ݪA�Ȥ�...
ECHO.
CALL :Is_Exist_fDenyTS_Entries-B
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �������ݪA�Ȩ�w��...
	ECHO.
	powershell -command Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name "fDenyTSConnections" -Value "1"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)
ECHO.
GOTO Close-RDP_Firewall

:Close-RDP_Firewall
ECHO --------------------------------------------
ECHO �������ݪA�ȳq�L������...
netsh advfirewall firewall set rule group="Remote Desktop" new enable=No
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO �D�^��y�t�A�ϥ��c�餤��y�t
	ECHO.
	netsh advfirewall firewall set rule group="���ݮୱ" new enable=No
)
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO �������ѡA�i�ର�W�ٿ��~!
)ELSE (
	ECHO.
	ECHO �]�m���\!
	ECHO.
)
ECHO.
GOTO Close-RDP_Service

:Close-RDP_Service
ECHO --------------------------------------------
ECHO [1/12]�������ݪA�Ȥ�[Termservice]...
ECHO.
Sc stop Termservice
CALL :Result_Service_Close_A
ECHO.
ECHO --------------------------------------------
ECHO [2/12]�]�m���Τ�...
ECHO.
Sc config Termservice start=disabled
CALL :Result_Service_Close_B
ECHO.
ECHO --------------------------------------------
ECHO [3/12]�������ݪA�Ȥ�[SessionEnv]...
ECHO.
sc stop SessionEnv
CALL :Result_Service_Close_A
ECHO.
ECHO --------------------------------------------
ECHO [4/12]�]�m���Τ�...
ECHO.
sc config SessionEnv start=disabled
CALL :Result_Service_Close_B
ECHO.
ECHO --------------------------------------------
ECHO [5/12]�������ݪA�Ȥ�[UmRdpService]...
ECHO.
sc stop UmRdpService
CALL :Result_Service_Close_A
ECHO.
ECHO --------------------------------------------
ECHO [6/12]�]�m���Τ�...
ECHO.
sc config UmRdpService start=disabled
CALL :Result_Service_Close_B
ECHO.
ECHO --------------------------------------------
ECHO [7/12]�������ݪA�Ȥ�[RemoteRegistry]...
ECHO.
sc stop RemoteRegistry
CALL :Result_Service_Close_A
ECHO.
ECHO --------------------------------------------
ECHO [8/12]�]�m���Τ�...
ECHO.
sc config RemoteRegistry start=disabled
CALL :Result_Service_Close_B
ECHO.
ECHO --------------------------------------------
ECHO [9/12]�������ݪA�Ȥ�[RasMan]...
ECHO.
sc stop RasMan
CALL :Result_Service_Close_A
ECHO.
ECHO --------------------------------------------
ECHO [10/12]�]�m���Τ�...
ECHO.
sc config RasMan start=disabled
CALL :Result_Service_Close_B
ECHO.
ECHO --------------------------------------------
ECHO [11/12]�������ݪA�Ȥ�[RasAuto]...
ECHO.
sc stop RasAuto
CALL :Result_Service_Close_A
ECHO.
ECHO --------------------------------------------
ECHO [12/12]�]�m���Τ�...
ECHO.
sc config RasAuto start=disabled
CALL :Result_Service_Close_B
ECHO.
PAUSE
GOTO RDP_Service_Ask

::REM ====================================Open-RDP_Service===================================

:Open-RDP_Service-REG-A
ECHO --------------------------------------------
ECHO �ק���U��fDenyTSConnections[SYSTEM]�A�}�һ��ݪA�Ȥ�...
CALL :Is_Exist_fDenyTS_Entries REM �ˬd���U��fDenyTSConnections���جO�_�s�b
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �ҥλ��ݪA�Ȩ�w��...
	ECHO.
	powershell -command Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value "0"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)
ECHO.
GOTO Open-RDP_Firewall

:Open-RDP_Service-REG-B
ECHO --------------------------------------------
ECHO �ק���U��fDenyTSConnections[SOFTWARE]�A�}�һ��ݪA�Ȥ�...
CALL :Is_Exist_fDenyTS_Entries-B
IF %ERRORLEVEL% NEQ 0 (
	SET ERRORLEVEL=
)ELSE (
	ECHO.
	ECHO �ҥλ��ݪA�Ȩ�w��...
	ECHO.
	powershell -command Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name "fDenyTSConnections" -Value "0"
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
)
ECHO.
GOTO Open-RDP_Firewall

:Open-RDP_Firewall
ECHO --------------------------------------------
ECHO �}�һ��ݪA�ȳq�L������...
Netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO �D�^��y�t�A�ϥ��c�餤��y�t
	ECHO.
	netsh advfirewall firewall set rule group="���ݮୱ" new enable=Yes
)
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	ECHO �}�ҥ��ѡA�i�ର�W�ٿ��~!
)ELSE (
	ECHO.
	ECHO �]�m���\!
	ECHO.
)
ECHO.
GOTO Open-RDP_Service

:Open-RDP_Service
ECHO --------------------------------------------
ECHO [1/12]�N���ݪA�ȳ]�m��ʤ�[Termservice]...
ECHO.
Sc config Termservice start=demand
CALL :Result_Service_Active_B
ECHO.
ECHO --------------------------------------------
ECHO [2/12]�ҥλ��ݪA�Ȥ�...
ECHO.
Sc start Termservice
CALL :Result_Service_Active_A
ECHO.
ECHO --------------------------------------------
ECHO [3/12]�N���ݪA�ȳ]�m��ʤ�[SessionEnv]...
ECHO.
sc config SessionEnv start=demand
CALL :Result_Service_Active_B
ECHO.
ECHO --------------------------------------------
ECHO [4/12]�ҥλ��ݪA�Ȥ�...
ECHO.
sc start SessionEnv
CALL :Result_Service_Active_A
ECHO.
ECHO --------------------------------------------
ECHO [5/12]�N���ݪA�ȳ]�m��ʤ�[UmRdpService]...
ECHO.
sc config UmRdpService start=demand
CALL :Result_Service_Active_B
ECHO.
ECHO --------------------------------------------
ECHO [6/12]�ҥλ��ݪA�Ȥ�...
ECHO.
sc start UmRdpService
CALL :Result_Service_Active_A
ECHO.
ECHO --------------------------------------------
ECHO [7/12]�N���ݪA�ȳ]�m��ʤ�[RemoteRegistry]...
ECHO.
sc config RemoteRegistry start=demand
CALL :Result_Service_Active_B
ECHO.
ECHO --------------------------------------------
ECHO [8/12]�ҥλ��ݪA�Ȥ�...
ECHO.
sc start RemoteRegistry
CALL :Result_Service_Active_A
ECHO.
ECHO --------------------------------------------
ECHO [9/12]�N���ݪA�ȳ]�m��ʤ�[RasMan]...
ECHO.
sc config RasMan start=demand
CALL :Result_Service_Active_B
ECHO.
ECHO --------------------------------------------
ECHO [10/12]�ҥλ��ݪA�Ȥ�...
ECHO.
sc start RasMan
CALL :Result_Service_Active_A
ECHO.
ECHO --------------------------------------------
ECHO [11/12]�N���ݪA�ȳ]�m��ʤ�[RasAuto]...
ECHO.
sc config RasAuto start=demand
CALL :Result_Service_Active_B
ECHO.
ECHO --------------------------------------------
ECHO [12/12]�ҥλ��ݪA�Ȥ�...
ECHO.
sc start RasAuto
CALL :Result_Service_Active_A
ECHO.
PAUSE
GOTO RDP_Service_Ask


::REM =====================================================================================================================
::REM ========================================================RPC==========================================================
::REM =====================================================================================================================


:RPC_Info
CLS
ECHO.
ECHO =======================================================
ECHO.
ECHO ---------------------------------------
ECHO �ثeRPC(135)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
CALL :Check_Port 135
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A!)
ECHO.
GOTO RPC_Ask

:RPC_Ask
ECHO.
CHOICE /C 321 /N /M "[1]����RPC [2]�}��RPC [3]��^�D���: "
IF ERRORLEVEL 3 (
	CALL :RPC_Close
)ELSE IF ERRORLEVEL 2 (
	CALL :RPC_Open
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)
ECHO.
PAUSE
GOTO RPC_Info

:RPC_Close
CALL :Check_Rule Block_RPC-TCP-135-In
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �T�{���إ߳W�h�A�إߤ�... && ECHO.)ELSE (ECHO. && ECHO �w�إ߳W�h�A�L���إ�! && ECHO. && PAUSE && GOTO RPC_Info)
powershell -command New-NetFirewallRule -DisplayName "Block_RPC-TCP-135-In" -Direction Inbound -LocalPort 135 -Action Block -Protocol TCP
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall add rule name="Block_RPC-TCP-135-In" dir=in protocol=tcp localport=135 action=block
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall set portopening protocol=tcp port=135 mode=disable name="Block_RPC-TCP-135-In"
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! )ELSE (ECHO. && ECHO �]�m���\! )
	)ELSE (
		ECHO. && ECHO �]�m���\! 
	)
)ELSE (
	ECHO. && ECHO �]�m���\! 
)
EXIT /B

:RPC_Open
CALL :Check_Rule Block_RPC-TCP-135-In
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ���إ߳W�h�A�L������! && ECHO. && PAUSE && GOTO RPC_Info)
powershell -command Remove-NetFirewallRule -DisplayName "Block_RPC-TCP-135-In"
IF %ERRORLEVEL% NEQ 0 (
	ECHO.
	netsh advfirewall firewall delete rule name="Block_RPC-TCP-135-In" dir=in
	IF %ERRORLEVEL% NEQ 0 (
		ECHO.
		netsh firewall delete portopening protocol=tcp port=135
		IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ��������! )ELSE (ECHO. && ECHO �������\! )
	)ELSE (
		ECHO. && ECHO �������\!
	)
)ELSE (
	ECHO. && ECHO �������\!
)
EXIT /B


::REM =====================================================================================================================
::REM ==================================================NetBIOS_Service====================================================
::REM =====================================================================================================================

:NetBIOS_Service_Info
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Check_NetBios
ECHO.
GOTO NetBIOS_Service_Ask

:NetBIOS_Service_Ask
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 321 /N /M "[1]�]�m���w�����d [2]�]�m���������d [3]��^�D���: "
IF ERRORLEVEL 3 (
	GOTO NetBIOS_Service_Specific_Ask
)ELSE IF ERRORLEVEL 2 (
	GOTO NetBIOS_Service_ALL_Ask
)ELSE IF ERRORLEVEL 1 (
	GOTO MAIN
)
ECHO.
PAUSE
GOTO RPC_Info

:NetBIOS_Service_Specific_Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Check_NetBios
ECHO.
ECHO -------------------------------------------------------
SET "Network_Adapter_Name="
SET /P Network_Adapter_Name="�п�J���������dindex���X[B/b:��^]: "
IF NOT DEFINED Network_Adapter_Name (
	ECHO.
	ECHO �|����J!
	ECHO.
	PAUSE
	GOTO NetBIOS_Service_Specific_Ask
)ELSE IF /I "%Network_Adapter_Name%" EQU "B" (
	GOTO NetBIOS_Service_Ask
)
ECHO.
CALL :Check_NetBios_Correct %Network_Adapter_Name% REM �ˬd��J��index���X�O�_�s�b
IF NOT DEFINED Ans (
	ECHO.
	ECHO ��J���Ȥ��s�b�A�Э��s��J!
	ECHO.
	PAUSE
	GOTO NetBIOS_Service_Specific_Ask
)ELSE (
	GOTO NetBIOS_Service_on-off_Ask
)

:NetBIOS_Service_on-off_Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Check_NetBios
ECHO.
ECHO.
ECHO.
Powershell -command '���w�����������d: '+("wmic nicconfig get Caption,index | find ' %Network_Adapter_Name% '")
ECHO.
ECHO -------------------------------------------------------
CHOICE /C B210 /N /M "�п�JTcpipNetbiosOptions�ﶵ[0,1,2][B/b:��^]: "
IF ERRORLEVEL 4 (
	CALL :NetBIOS_Service_Specific_SET 0
)ELSE IF ERRORLEVEL 3 (
	CALL :NetBIOS_Service_Specific_SET 1
)ELSE IF ERRORLEVEL 2 (
	CALL :NetBIOS_Service_Specific_SET 2
)ELSE (
	GOTO NetBIOS_Service_Specific_Ask
)
ECHO.
PAUSE
GOTO NetBIOS_Service_Info

:NetBIOS_Service_ALL_Ask
CLS
ECHO.
ECHO =======================================================
ECHO.
CALL :Check_NetBios
ECHO.
CHOICE /C B210 /N /M "�п�JTcpipNetbiosOptions�ﶵ[0,1,2][B/b:��^]: "
IF ERRORLEVEL 4 (
	CALL :NetBIOS_Service_ALL_SET 0
)ELSE IF ERRORLEVEL 3 (
	CALL :NetBIOS_Service_ALL_SET 1
)ELSE IF ERRORLEVEL 2 (
	CALL :NetBIOS_Service_ALL_SET 2
)ELSE (
	GOTO NetBIOS_Service_Info
)
ECHO.
PAUSE
GOTO NetBIOS_Service_Info

:NetBIOS_Service_Specific_SET
ECHO.
ECHO �]�m��...
ECHO.
WMIC nicconfig where index=%Network_Adapter_Name% call SetTcpipNetbios %~1
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
EXIT /B

:NetBIOS_Service_ALL_SET
ECHO.
ECHO �]�m��...
ECHO.
powershell -command $base = 'HKLM:SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' ; $interfaces = Get-ChildItem $base ^| Select -ExpandProperty PSChildName ; foreach($interface in $interfaces) {Set-ItemProperty -Path "$base\$interface" -Name "NetbiosOptions" -Value "%~1"}
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
EXIT /B


::REM =====================================================================================================================
::REM =============================================Close SMB(NetBIOS)_139�B445==============================================
::REM =====================================================================================================================


:NetBIOS_SMB
CLS
ECHO.
ECHO =======================================================
ECHO.
ECHO ---------------------------------------
ECHO �ثeSMB(139)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
CALL :Check_Port 139
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A!)
ECHO.

ECHO ---------------------------------------
ECHO �ثeSMB(445)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
CALL :Check_Port 445
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A! && GOTO Switch_SMB)

:Switch_SMB
ECHO.
ECHO =======================================================
ECHO.
CHOICE /C 4321 /N /M "[1]����SMB(139) [2]����SMB(445) [3]�������� [4]��^�D���: "
IF ERRORLEVEL 4 (
	GOTO Close_SMB
)ELSE IF ERRORLEVEL 3 (
	GOTO Open_SMB
)ELSE IF ERRORLEVEL 2 (
	GOTO Open_SMB
)ELSE (
	GOTO MAIN
)

:Close_SMB
ECHO.
ECHO =======================================================
ECHO.

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
ECHO [1/2]����TCP/IP NetBIOS Helper�A�Ȥ�...
ECHO.
sc stop lmhosts
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)

ECHO.
ECHO [2/2]�NTCP/IP NetBIOS Helper�A�ȳ]�m�T�Τ�...
ECHO.
sc config lmhosts start=disabled
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)
ECHO.

ECHO [1/2]����NetBios�A�Ȥ�...
ECHO.
sc stop netbios
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)

ECHO.
ECHO [2/2]�NNetBios�A�������]�m���Τ�...
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

ECHO.
ECHO �]�m���������139��J�W�h��...
ECHO.
CALL :Check_Rule Block_TCP-139
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �T�{���إ߳W�h�A�إߤ�... && ECHO.)ELSE (ECHO. && ECHO �w�إ߳W�h�A�L���إ�! && ECHO. && PAUSE && GOTO Close_Port_445)
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
GOTO Close_Port_445

::REM ========================================Close Port_445======================================

:Close_Port_445
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

ECHO [1/2]����lanmanserver�A�Ȥ�...
ECHO.
sc stop lanmanserver
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)

ECHO.
ECHO [2/2]�Nlanmanserver�A�ȳ]�m���Τ�...
ECHO.
sc config lanmanserver start=disabled
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �L�k�����A��!)ELSE (ECHO. && ECHO �����A�Ȧ��\!)

ECHO.
ECHO �]�m���������445��J�W�h��...
ECHO.
CALL :Check_Rule Block_TCP-445
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �T�{���إ߳W�h�A�إߤ�... && ECHO.)ELSE (ECHO. && ECHO �w�إ߳W�h�A�L���إ�! && ECHO. && PAUSE && GOTO NetBIOS_SMB)
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
ECHO [1/2]�NTCP/IP NetBIOS Helper�A�ȳ]�m��ʤ�...
ECHO.
sc config lmhosts start=demand
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)

ECHO.
ECHO [2/2]�}��TCP/IP NetBIOS Helper�A�Ȥ�...
ECHO.
sc start lmhosts
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �}�ҪA�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�}�ҪA��!
)

ECHO.
ECHO [1/2]�NNetBios�A�������]�m�}�Ҥ�...
ECHO.
sc config netbios start=auto
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����!)ELSE (ECHO. && ECHO �]�m���\!)

ECHO.
ECHO [2/2]�}��NetBios�A�Ȥ�...
ECHO.
sc start netbios
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
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


ECHO.
ECHO �������������139��J�W�h��...
ECHO.
CALL :Check_Rule Block_TCP-139
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ���إ߳W�h�A�L������! && ECHO. && PAUSE && GOTO Open_Port_445)
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
GOTO Open_Port_445

::REM ========================================Open Port_445=======================================

:Open_Port_445
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
	powershell -command Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" -Name "TransportBindName" -Value '"\Device"\'
	IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �]�m����! && ECHO.)ELSE (ECHO. && ECHO �]�m���\! && ECHO.)
)

ECHO.
ECHO [1/2]�Nlanmanserver�A�ȳ]�m�ҥΤ�...
ECHO.
sc config lanmanserver start=auto
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �L�k�}�ҪA��!)ELSE (ECHO. && ECHO �}�ҪA�Ȧ��\!)

ECHO.
ECHO [2/2]�}��lanmanserver�A�Ȥ�...
ECHO.
sc start lanmanserver
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
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
CALL :Check_Rule Block_TCP-445
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO ���إ߳W�h�A�L������! && ECHO. && PAUSE && GOTO NetBIOS_SMB)
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

:RDP_Port
Powershell -command '�ثeRDP���s����:'+("Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "PortNumber" | Select-Object -ExpandProperty PortNumber")
EXIT /B

:Is_Exist_fDenyTS_Entries
ECHO �ˬd���U��fDenyTSConnections���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" ^| findstr fDenyTSConnections > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_fDenyTS_Entries)ELSE (ECHO. && ECHO �T�{�s�bfDenyTSConnections����!)
EXIT /B

:Is_Exist_fDenyTS_Entries-B
ECHO �ˬd���U��fDenyTSConnections���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -name "fDenyTSConnections" ^| findstr fDenyTSConnections > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_fDenyTS_Entries-B)ELSE (ECHO. && ECHO �T�{�s�bfDenyTSConnections����!)
EXIT /B

:Is_Exist_139_Entries_RA
ECHO �ˬd���U��RestrictAnonymous���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -name "restrictanonymous" ^| findstr restrictanonymous > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_139_Entries_RA)ELSE (ECHO. && ECHO �T�{�s�bRestrictAnonymous����!)
EXIT /B

:Is_Exist_139_Entries_ShareServer
ECHO �ˬd���U��AutoShareServer���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -name "AutoShareServer" ^| findstr AutoShareServer > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_139_Entries_ShareServer)ELSE (ECHO. && ECHO �T�{�s�bAutoShareServer����!)
EXIT /B

:Is_Exist_139_Entries_ShareWks
ECHO �ˬd���U��AutoShareWks���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -name "AutoShareWks" ^| findstr AutoShareWks > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_139_Entries_ShareWks)ELSE (ECHO. && ECHO �T�{�s�bAutoShareWks����!)
EXIT /B

:Is_Exist_445_Entries_SMBD
ECHO �ˬd���U��SMBDeviceEnabled���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -name "SMBDeviceEnabled" ^| findstr SMBDeviceEnabled > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_445_Entries_SMBD)ELSE (ECHO. && ECHO �T�{�s�bSMBDeviceEnabled����!)
EXIT /B

:Is_Exist_445_Entries_TB
ECHO �ˬd���U��TransportBindName���ؤ�...
powershell -command Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' -name "TransportBindName" ^| findstr TransportBindName > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO Create_445_Entries_TB)ELSE (ECHO. && ECHO �T�{�s�bTransportBindName����!)
EXIT /B

:Create_fDenyTS_Entries
ECHO.
ECHO ���s�bfDenyTSConnections���ءA�Ыؤ�...
ECHO.
powershell -command New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -PropertyType "DWORD" -Value "1"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�ҥλ��ݮୱ�s�u��w! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
EXIT /B

:Create_fDenyTS_Entries-B
ECHO.
ECHO ���s�bfDenyTSConnections���ءA�Ыؤ�...
ECHO.
powershell -command New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -name "fDenyTSConnections" -PropertyType "DWORD" -Value "1"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �Ыإ��ѡA�L�k�ҥλ��ݮୱ�s�u��w! && SET ERRORLEVEL=1)ELSE (ECHO. && ECHO �Ыئ��\!)
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

:Check_NetBios
ECHO �ثe�U���������d��Netbios�ҥΪ��A:
ECHO.
WMIC nicconfig get caption,index,TcpipNetbiosOptions
ECHO.
ECHO TcpipNetbiosOptions �ﶵ����:
ECHO.
ECHO 0 = �bDHCP���A���W�ҥ�NetBios�]�w
ECHO 1 = �ҥ�NetBios(NetBIOS over TCP/IP)
ECHO 2 = �T��NetBios(NetBIOS over TCP/IP)
EXIT /B

:Check_NetBios_Correct
FOR /F %%i in ('wmic nicconfig get index') do IF %%i==%~1 ( SET Ans=True && EXIT /B ) > nul 2>&1
EXIT /B

:Check_Port_Scope
SET "Scope="
IF 1%~1 NEQ +1%~1  (
	ECHO.
	ECHO �п�J�Ʀr!
	ECHO.
	SET Scope=False
	EXIT /B
)
IF %~1 LSS 1001 (
	ECHO.
	ECHO �s����p��1001!
	ECHO.
	SET Scope=False
)ELSE IF %~1 GTR 254535 (
	ECHO.
	ECHO �s����W�L254535!
	ECHO.
	SET Scope=False
)
EXIT /B

:Check_OS
IF %PROCESSOR_ARCHITECTURE% == "AMD64" (
	SET OS_Type=x64
)ElSE (
	SET OS_Type=x86
)
EXIT /B

:Check_Rule
powershell -command Get-NetFirewallRule -DisplayName "%~1" > nul 2>&1
EXIT /B

:Check_Port
netstat -ano | find "%~1 "
EXIT /B

:Result_Service_Close_A
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g����!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �����A�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�����A��!
)
EXIT /B

:Result_Service_Active_A
IF %ERRORLEVEL% == 1062 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 1052 (
	ECHO.
	ECHO �A�Ȥw�g�}��!
)ELSE IF %ERRORLEVEL% == 0 (
	ECHO.
	ECHO �}�ҪA�Ȧ��\!
)ELSE (
	ECHO.
	ECHO �L�k�}�ҪA��!
)
EXIT /B

:Result_Service_Close_B
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO �L�k���ΪA��!
)ELSE (
	ECHO. && ECHO ���ΪA�Ȧ��\!
)
EXIT /B

:Result_Service_Active_B
IF %ERRORLEVEL% NEQ 0 (
	ECHO. && ECHO �L�k�]�m�A��!
)ELSE (
	ECHO. && ECHO �]�m���\!
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
CALL :Check_Port 137
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �����s�����A!)
ECHO.

ECHO ---------------------------------------
ECHO �ثeSMB(138)���s���𪬺A:
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
CALL :Check_Port 138
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
	GOTO NetBIOS_UDP
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
GOTO NetBIOS_UDP

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
	GOTO NetBIOS_UDP
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
GOTO NetBIOS_UDP

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
ECHO ==============================================================
ECHO.
SET "Port="
SET "Check-Port="
SET /P Check-Port="�п�J�n�ʬݪ��s����( [Q]��^�D��� [E]���} [A]�d�ݩҦ��s���� ): "
IF "%Check-Port%"=="" (
	ECHO. && ECHO ��J���šA�Э��s��J! && ECHO. && PAUSE && GOTO Check_TCP_UDP
)
IF /I "%Check-Port%" EQU "Q" (
	GOTO MAIN
)ELSE IF /I "%Check-Port%" EQU "E" (
	GOTO Exit
)ELSE IF /I "%Check-Port%" EQU "A" (
	GOTO Check_TCP_UDP_Proto
)
SET "Port=^| find ':%Check-Port% '"
GOTO Check_TCP_UDP_Proto

:Check_TCP_UDP_Proto
ECHO.
ECHO ==============================================================
ECHO.
SET "Proto="
SET "Proto_Type="
CHOICE /C 321 /N /M "�п�ܨ�ĳ( [1]TCP [2]UDP [3]ALL ): "
IF ERRORLEVEL 3 (
	SET Proto_Type=TCP
)ELSE IF ERRORLEVEL 2 (
	SET Proto_Type=UDP
)ELSE (
	GOTO Check_TCP_UDP-State
)
SET "Proto=^| findstr %Proto_Type%"
GOTO Check_TCP_UDP-State

:Check_TCP_UDP-State
ECHO.
ECHO.
ECHO ==============================================================
ECHO                           ��ܳs�u���A
ECHO ==============================================================
ECHO.
ECHO �`�N:UDP��ĳ�A�S���s�u���A�A�Ъ�����K�ﶵ�A�_�h�N�L��X�C
ECHO.
ECHO --------------------------------------------------------------
ECHO [A]  LISTEN: 		���ݳs�u���A�B���ť���A�C
ECHO [B]  ESTABLISHED: 	�w�s�u���A�C
ECHO [C]  CLOSING: 		�w�������A�C
ECHO [D]  TIMED_WAIT: 	�ڤ�w�D�������s�u�C
ECHO [E]  CLOSE_WAIT: 	���w�D�������s�u�A�κ������`�Ӥ��_�C
ECHO [F]  FIN_WAIT_1: 
ECHO [G]  FIN_WAIT_2: 
ECHO [H]  LAST_ACK: 
ECHO [I]  SYN_SEND: 	�ШD�s�u���A(Send first SYN)�C
ECHO [J]  SYN_RECEIVED: �����s�u����l���A�A�õ��ݳ̫�T�{(Send SYN+ACK�Abut not receive last ACK)�C
ECHO [K]  ALL_State:	��ܥ������A�C
ECHO --------------------------------------------------------------
ECHO.
SET "State="
SET "State_Type="
CHOICE /C KJIHGFEDCBA /N /M "��ܥ\��[A~K]: "
IF ERRORLEVEL 11 (
	SET State_Type=LISTEN
)ELSE IF ERRORLEVEL 10 (
	SET State_Type=ESTABLISHED
)ELSE IF ERRORLEVEL 9 (
	SET State_Type=CLOSING
)ELSE IF ERRORLEVEL 8 (
	SET State_Type=TIMED_WAIT
)ELSE IF ERRORLEVEL 7 (
	SET State_Type=CLOSE_WAIT
)ELSE IF ERRORLEVEL 6 (
	SET State_Type=FIN_WAIT_1
)ELSE IF ERRORLEVEL 5 (
	SET State_Type=FIN_WAIT_2
)ELSE IF ERRORLEVEL 4 (
	SET State_Type=LAST_ACK
)ELSE IF ERRORLEVEL 3 (
	SET State_Type=SYN_SEND
)ELSE IF ERRORLEVEL 2 (
	SET State_Type=SYN_RECEIVED
)ELSE (
	GOTO Check_TCP_UDP-Run
)
SET "State=^| findstr %State_Type%"
GOTO Check_TCP_UDP-Run

:Check_TCP_UDP-Run
ECHO.
ECHO.
ECHO ==============================================================
ECHO.
ECHO  ��w    ������}               �~����}               ���A            PID
ECHO.
SET "RUN=%Proto% %Port% %State%"
powershell -command netstat -ano %RUN%
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

