set "params=%*" && cd /d "%CD%" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/C cd ""%CD%"" && %~s0 %params%", "", "runas", 1 >>"%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
@ECHO OFF
TITLE Git�۰ʤƺ޲z�u��(Administrator)

:MAIN
CLS
net.exe session 1>NUL 2>NUL && (
    echo ========================�w����޲z���v��========================
) || (
    echo ========================������޲z���v��========================
)

ECHO.
ECHO �ثe��������|: "%CD%"

ECHO.
ECHO ==============================================================
ECHO                         ���Git�\��
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] �d��Git�ޱ����A��T
ECHO [2] �إ�Git�ޱ����a�ݤλ����x�s�w(Repository)
ECHO [3] ����Git�b��
ECHO [4] Git���e
ECHO [5] �]�mSSH-Key(�]�m���_)
ECHO [6] �]�mSSH�N�z(�Ω�޲z�h�Өp�_)
ECHO [7] ����SSH�s��
ECHO [8] ��sGit
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 7654321 /N /M "���Git�\��[1~7]: "
IF ERRORLEVEL 7 (
 GOTO Info
)ELSE IF ERRORLEVEL 6 (
 GOTO Create_File_Ask
)ELSE IF ERRORLEVEL 5 (
 GOTO Global-Info
)ELSE IF ERRORLEVEL 4 (
 GOTO rm
)ELSE IF ERRORLEVEL 3 (
 GOTO Show-Key
)ELSE IF ERRORLEVEL 2 (
 GOTO SSH-Agent
)ELSE IF ERRORLEVEL 1 (
 GOTO SSH-Test
)

::REM ===============================�d��Git�ޱ����A��T================================

:Info
ECHO.
ECHO ====================================================================
ECHO 1.Git����
Git version
ECHO.
ECHO ------------------------------------------------------------------
ECHO 2.�˵��ثe�u�@�ؿ����p
Git status
IF %ERRORLEVEL% NEQ 0 (ECHO ���~: �ثe�ؿ����s�bGit�x�s�w)
ECHO.
ECHO ------------------------------------------------------------------
ECHO 3.�˵����a�P���{�Ҧ�����
Git branch -a
IF %ERRORLEVEL% NEQ 0 (ECHO ���~: �ثe�ؿ����s�bGit�x�s�w)
ECHO.
ECHO ------------------------------------------------------------------
ECHO 4.�˵����檺���v�O��
Git log
IF %ERRORLEVEL% NEQ 0 (ECHO ���~: �ثe�ؿ����s�bGit�x�s�w)
GOTO EXIT
::REM ================================�إ�Git�ޱ��x�s�w=================================

:Create_File_Ask
ECHO.
ECHO ====================================================================
ECHO [0/8] ---�إߥ��a�x�s�w��Ƨ�---
CHOICE /C YN /N /M "�O�_�إߥ��a��Ƨ�?(Y/N):"
IF ERRORLEVEL 2 (
 GOTO Upload
)ELSE IF ERRORLEVEL 1 (  
 GOTO Create_File
)

:Create_File
ECHO.
ECHO ====================================================================
ECHO [0/8] ---�إߥ��a�x�s�w��Ƨ�---
SET /p "File_Name=�п�J��Ƨ��W��(Ex: Github_Test):"
mkdir "%File_Name%"
IF %ERRORLEVEL% NEQ 0 (ECHO ��Ƨ��Ыإ���! GOTO Create_Filed)ELSE ( GOTO Create_Success)


:Create_File
ECHO.
ECHO ��Ƨ��Ыإ���!
GOTO Create_File_Ask


:Create_Success
ECHO.
CD %File_Name%
ECHO �w���ʨ��Ƨ��U
ECHO �ثe��������|: %CD%
GOTO Upload


:Upload
ECHO.
ECHO ====================================================================
ECHO [1/8] ---�إ� Markdown �������---
SET /p "Commit=�п�J������󪺼��D(Ex: Practicing):"
ECHO # %Commit% > README.md
IF %ERRORLEVEL% NEQ 0 (ECHO �ɮ׳Ыإ���! && GOTO Upload)ELSE (GOTO Init)


:Init
ECHO.
ECHO ====================================================================
ECHO [2/8] ---�ܮw��l�ơA�إߥ��a�ƾڮw�A�i�檩������---
ECHO �N�i��ܮw��l�ơA�����N���~��
PAUSE...
Git init
IF %ERRORLEVEL% NEQ 0 (ECHO �ܮw��l�ƥ���! && GOTO Init)ELSE (GOTO MD)


:Add-Ask
ECHO.
ECHO ====================================================================
ECHO [3/8] ---�N�ɮץ[�ܼȦs��---
CHOICE /C 12 /N /M "[1]�Ҧ��ɮ� [2]�ؿ��U�Τl�ؿ��Ҧ��ɮ�(1,2):"
IF ERRORLEVEL 2 (
 GOTO Add-Current_Directory
)ELSE IF ERRORLEVEL 1 (  
 GOTO Add-All
)


:Add-All
ECHO.
ECHO ====================================================================
ECHO [3/8] ---�N�Ҧ��ɮץ[�ܼȦs��---
Git add -all
IF %ERRORLEVEL% NEQ 0 (ECHO �ɮץ[�J����! && GOTO Add-Ask)ELSE (GOTO Commit)


:Add-Current_Directory
ECHO.
ECHO ====================================================================
ECHO [3/8] ---�N�ؿ��U�Τl�ؿ��Ҧ��ɮץ[�ܼȦs��---
Git add .
IF %ERRORLEVEL% NEQ 0 (ECHO �ɮץ[�J����! && GOTO Add-Ask)ELSE (GOTO Commit)


:Commit
ECHO.
ECHO ====================================================================
ECHO [4/8] ---���满��---
SET /p "Commit=�п�J�n���檺�������e:"
Git commit -m "%Commit%"
IF %ERRORLEVEL% NEQ 0 (ECHO ���椺�e����! && GOTO Commit)ELSE (GOTO Branch-ASK)


:Branch-ASK
ECHO.
ECHO ====================================================================
ECHO [5/8] ---�s�W����---
CHOICE /C YN /N /M "�O�_�s�W����?(Y/N):"
IF ERRORLEVEL 2 (
 GOTO Remote
)ELSE IF ERRORLEVEL 1 (
 GOTO Branch
)


:Branch
ECHO.
ECHO ====================================================================
ECHO [6/8] ---�s�W����---
SET /p "Branch_Name=�п�J����W��(�i�ϥ�main):"
Git branch -M "%Branch_Name%"
IF %ERRORLEVEL% NEQ 0 (ECHO �s�W���䥢��! && GOTO Branch)ELSE (GOTO Remote)


:Remote
ECHO.
ECHO ====================================================================
ECHO [7/8] ---�s�W�@�ӻ��ݼƾڮw���`�I---
SET /p "Remote_name=�п�J�ƾڮw²��(Ex: origin):"
SET /p "Remote_Url=�п�J���ݼƾڮw��m(Ex: https://github.com/user/repo.git):"
Git remote add %Remote_name% %Remote_Url%
IF %ERRORLEVEL% NEQ 0 (ECHO �s�W���{�ƾڮw�`�I����! && GOTO Remote)ELSE (ECHO. && ECHO ���ݼƾڮw�C��: && git remove -v && GOTO Push)


:Push
ECHO.
ECHO ====================================================================
ECHO [8/8] ---�N�ɮױ��e�ܻ��ݼƾڮw---
SET /p "Push_Remote_name=�п�J���ݼƾڮw²��(Ex: origin):"
SET /p "Push_Branch_name=�п�J���ݼƾڮw����W��(Ex: main):"
Git push -u %Push_Remote_name% %Push_Branch_name%
IF %ERRORLEVEL% NEQ 0 (ECHO ���e�ܻ��ݼƾڮw����! && GOTO Remote)ELSE (ECHO. && ECHO ���ݼƾڮw�C��: && git remove -v && GOTO Push)
GOTO END

:END
ECHO ���a�x�s�w�P���ݤw���\�إ����Y
PAUSE...

::REM ====================================����Git�b��====================================

:Global-Info
ECHO.
ECHO ===========================�d�ݥ����]�w��T==============================
ECHO.
git config --list --show-origin
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �L�k�d�ݥ����]�w��T! && pause && GOTO Global-Info)ELSE (GOTO Switch_Account-unset-user.name)

:Switch_Account-unset-user.name
ECHO.
ECHO ========================�M��user.name�����]�w===========================
ECHO.
git config --global --unset user.name
IF %ERRORLEVEL% NEQ 0 (
	IF %ERRORLEVEL% NEQ 5 (
		ECHO. && ECHO �L�k�M��User.Name�����]�w! && pause && GOTO Switch_Account-unset-user.name
	)ELSE (
		ECHO ���\�M��User.Name�����]�w! && GOTO Switch_Account-unset-user.email
	)
)ELSE (
	ECHO ���\�M��User.Name�����]�w! && GOTO Switch_Account-unset-user.email
)

:Switch_Account-unset-user.email
ECHO.
ECHO ========================�M��user.name�����]�w===========================
ECHO.
git config --global --unset user.email
IF %ERRORLEVEL% NEQ 0 (
	IF %ERRORLEVEL% NEQ 5 (
		ECHO. && ECHO �L�k�M��User.email�����]�w! && pause && GOTO Switch_Account-unset-user.email
	)ELSE (
		ECHO ���\�M��User.Name�����]�w! && GOTO Switch_Account-Email
	)
)ELSE (
	ECHO ���\�M��User.Name�����]�w! && GOTO Switch_Account-Email
)

:Switch_Account-Email
ECHO.
ECHO ==========================����Git�b��[Email]===========================
ECHO.
SET /P Email="[1/2] �п�J�n������Github��GitLab�b��Email: "
git config --global user.email "%Email%"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �п�J���T�b��Email && pause && GOTO Switch_Account-Email)ELSE (ECHO. && ECHO ��������! && GOTO Switch_Account-Name)

:Switch_Account-Name
ECHO.
ECHO ==========================����Git�b��[Name]===========================
ECHO.
SET /P Name="[2/2] �п�J�n������Github��GitLab�b���W��: "
git config --global user.name "%Name%"
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �п�J���T�b���W�� && pause && GOTO Switch_Account-Name)ELSE (ECHO. && ECHO ��������! && GOTO Switch_Account-Info)

:Switch_Account-Info
ECHO.
ECHO =======================�d�ݧ��᪺�����]�w��T==========================
ECHO.
git config --list --show-origin
IF %ERRORLEVEL% NEQ 0 (ECHO. && ECHO �L�k�d�ݧ��᪺�����]�w��T! && pause && GOTO Global-Info)ELSE (GOTO EXIT)

::REM =====================================Git���e=======================================

:rm
ECHO.
ECHO ---------�M���w�s(�ѩ�Q��w���ɮ�)---------
ECHO.
TIMEOUT /NOBREAK /T 1 1>nul 2>nul
git rm -r --cached .

:add
ECHO.
ECHO --------------�ɮ״����Ȧs��--------------
ECHO.
git add .

:commit
ECHO.
ECHO -----------------����T��-------------------
ECHO.
set /p message="�п�J����T��(�i���UEnter�ϥιw�] Upgrade):"
ECHO.
git commit -m "%message%"
if %errorlevel% NEQ 0 (git commit -m Upgrade)

:push
ECHO.
ECHO -------------�ɮױ��e�컷�ݭܮw-------------	
ECHO.
set /p message="�п�J���ݭܮw����W��(�i���UEnter�ϥιw�] main):"
ECHO.
git push -u origin "%message%"
if %errorlevel% NEQ 0 (git push -u origin main)

::REM ================================SSH-Key(�]�m���_)================================

:SSH-Key-Show-KeyFile
SET Git_Bash="C:\Program Files\Git\bin\bash.exe" --login -i -c
SET Git_Bash2="C:\Program Files\Git\bin\sh.exe" --login -i -c
ECHO.
ECHO ==============================================================
ECHO                       �{��SSH���_�ɮ�
ECHO ==============================================================
ECHO.
%Git_Bash% "ls -al ~/.ssh"
REM ECHO ls -al ~/.ssh | %Git_Bash% //�u�A�Ω���X
GOTO SET-Email

:SET-Email
ECHO.
ECHO ==============================================================
ECHO                      SSH���_�ͦ���Ƴ]�w
ECHO ==============================================================
ECHO.
SET /P email="[1/2] �п�JGithub�Ϊ�GitLab��Email: "
IF %ERRORLEVEL% NEQ 0 (CLS && ECHO �п�J���Temail && GOTO SSH-Key-Show-KeyFile)

:SET-Email
ECHO.
ECHO ==============================================================
ECHO                      SSH���_�ͦ���Ƴ]�w
ECHO ==============================================================
ECHO.
SET /P Key-FileName="[2/2] �п�J�n�ͦ����K�_���W��: "
IF %ERRORLEVEL% NEQ 0 (CLS && ECHO �п�J���T�W�� && GOTO SSH-Key-Show-KeyFile)ELSE (GOTO Choice_SSH-key)

:Choice_SSH-key
ECHO.
ECHO ==============================================================
ECHO                         SSH�K�_����
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] ED25519(�u��)
ECHO [2] RSA(�䦸)
ECHO --------------------------------------------------------------
ECHO.
CHOICE /C 21 /N /M "��ܥ[�K����[1,2]: "
IF ERRORLEVEL 2 (
 GOTO ED25519
)ELSE IF ERRORLEVEL 1 (
 GOTO RSA
)

:ED25519
ECHO.
ECHO ==============================================================
ECHO.
ECHO ��ܥ[�K����: ED25519
ECHO.
%Git_Bash% "ssh-keygen -t ed25519 -N '' -f id_ed25519_"%Key-FileName%" -C "%email%""
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-ED25519)ELSE (GOTO EXIT)

:RSA
ECHO.
ECHO ==============================================================
ECHO.
ECHO ��ܥ[�K����: RSA
ECHO.
%Git_Bash% "ssh-keygen -t rsa -b 4096 -C "%email%""
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-RSA)ELSE (GOTO EXIT)

:FAIL-ED25519
ECHO.
ECHO ==============================================================
ECHO.
ECHO ED25519�[�K����!
CHOICE /C NY /N /M "�O�_���RSA�[�K[Y,N]: "
IF ERRORLEVEL 2 (
 GOTO RSA
)ELSE IF ERRORLEVEL 1 (
 GOTO EXIT
)

:FAIL-RSA
ECHO.
ECHO ==============================================================
ECHO.
ECHO RSA�[�K����!
CHOICE /C NY /N /M "�O�_���ED25519�[�K[Y,N]: "
IF ERRORLEVEL 2 (
 GOTO ED25519
)ELSE IF ERRORLEVEL 1 (
 GOTO EXIT
)

::REM ====================================SSH-Agent====================================

:SSH-Agent-Show-SSHFile
ECHO.
ECHO ==============================================================
ECHO                        �{��SSH���_�ɮ�
ECHO ==============================================================
ECHO.
%Git_Bash% "ls -al ~/.ssh"
GOTO SSH-Agent

:SET-Email
ECHO.
ECHO ==============================================================
ECHO                      	   ��Ƴ]�w
ECHO ==============================================================
ECHO.
SET /P SSH-FileName="�п�J�n�����_�ɦW: "
IF %ERRORLEVEL% NEQ 0 (CLS && ECHO �п�J���T���_�ɦW && GOTO SSH-Agent-Show-SSHFile && GOTO SSH-Agent)

:SSH-Agent
CLS
ECHO.
ECHO ====================�Ұ�SSH�N�z�òK�[SSH�p�_=====================
ECHO.
%Git_Bash% "eval `ssh-agent -s`" || "ssh-add ~/.ssh/%SSH-FileName%"
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-SSH-Agent)

:FAIL-SSH-Agent
ECHO.
ECHO ==============================================================
ECHO.
ECHO �Ұ�SSH�N�z���ѩάOSSH�K�_�K�[����
GOTO EXIT

::REM ====================================����SSH�s��====================================

:SSH-Test
ECHO.
ECHO ==========================����SSH�s��===========================
ECHO.
SET /P Host-Name="�п�J�n�s�u���D���W��(Ex: github.com or github-B11056051): "
ECHO.
ECHO �p�G�X�{ĵ�i�T���A����JYes�C
ECHO.
%Git_Bash% "ssh -T git@"%Host-Name%""
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-SSH-Test)ELSE (GOTO EXIT)

:FAIL-SSH-Test
ECHO.
ECHO ==============================================================
ECHO.
ECHO ����SSH�s�����ѡA�нT�{�D���W�٬O�_���~�άO���N���_�s�W��Github�άOGitLab�b���W!
GOTO SSH-Agent-B

::REM ======================================�w��Git======================================

:Install-Git-Choose
CLS
ECHO.
ECHO ==============================================================
ECHO                         �w��Git�ﶵ
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] �i�J�x���U��
ECHO [2] �U�������(Github)
ECHO [3] �ϥ�Winget�u��(Windows)
ECHO [4] �ϥ�Choco(Chocolatey)
ECHO --------------------------------------------------------------

:Install-Official
ECHO.
ECHO ===========================�w��Git============================
ECHO.
ECHO �}�ҩx����...
Start "" "https://git-scm.com/download/win"
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Install-Official)ELSE (GOTO Update-Git-Finish)

:Install-Source
ECHO.
ECHO ========================�w��Git�����==========================
ECHO.
ECHO �}�Һ��}��...
Start "" "https://github.com/git-for-windows/git/releases"
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Install-Official)ELSE (GOTO Update-Git-Finish)

:Install-Winget
Call :Confirm-Winget REM �ˬdWinget�O�_�w��
ECHO.
ECHO =======================�ϥ�Winget�w��Git=======================
ECHO.
ECHO �w�ˤ�...
ECHO.
Winget install --id Git.Git -e --source winget
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Install-Winget)ELSE (GOTO Update-Git-Finish)

:Install-Choco
Call :Confirm-Choco REM �ˬdChocolatey�O�_�w��
ECHO.
ECHO =======================�ϥ�Choco�w��Git========================
ECHO.
ECHO �w�ˤ�...
ECHO.
Choco install git
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Install-Choco)ELSE (GOTO Update-Git-Finish)

:FAIL-Install-Official_AND_Source
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "�}�ҥ���!���}�i��w���A�O�_�^����ϥΨ�L�覡�U��[Y,N]? : "
IF ERRORLEVEL 2 (
 GOTO Install-Git-Choose
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:FAIL-Install-Winget
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "�w�˥���! �O�_�^����ϥΨ�L�覡�U��[Y,N]? : "
IF ERRORLEVEL 2 (
 GOTO Install-Git-Choose
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:Install-Git-Finish
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "�w�˥���! �O�_�^����ϥΨ�L�覡�U��[Y,N]? : "
IF ERRORLEVEL 2 (
 GOTO Install-Git-Choose
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:Install-Git-Finish
ECHO.
ECHO ==============================================================
ECHO. 
ECHO �w�˦��\! ������:
Git version
ECHO �w�˦�m:
Where.exe Git
GOTO Finish-Back

::REM ====================================�w��Winget=====================================

:Install-Winget
ECHO.
ECHO ==========================�w��Winget==========================
ECHO.
ECHO �w�ˤ�...

::REM ======================================��sGit======================================

:Update-Git-Ask
CLS
Call :Confirm-Git REM �ˬdGit�O�_�w��
ECHO.
ECHO ===========================��sGit============================
ECHO.
ECHO �ثe��������:
Git version
ECHO �̷s��������:
Winget search --id Git.Git -e --source winget
ECHO.
CHOICE /C NY /N /M "�O�_�i���s[Y,N]?: "
IF ERRORLEVEL 2 (
 GOTO Update-Git-Choose
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:Update-Git-Choose
CLS
ECHO.
ECHO ==============================================================
ECHO                         ��sGit�ﶵ
ECHO ==============================================================
ECHO.
ECHO --------------------------------------------------------------
ECHO [1] �ϥ�Git���ث��O��s
ECHO [2] �ϥ�Winget�u��(Windows)
ECHO [3] �ϥ�Choco(Chocolatey)
ECHO --------------------------------------------------------------
CHOICE /C 321 /N /M "�п�ܧ�s�覡[1,2,3]: "
IF ERRORLEVEL 3 (
 GOTO Update-Git-Git
)ELSE IF ERRORLEVEL 2 (
 Call :Confirm-Winget REM �ˬdWinget�O�_�w��
 GOTO Update-Git-Winget
)ELSE IF ERRORLEVEL 1 (
 Call :Confirm-Choco REM �ˬdChocolatey�O�_�w��
 GOTO Update-Git-Choco
)

:Update-Git-Git
ECHO.
ECHO =========================�ϥ�Git��s===========================
ECHO.
ECHO ��s��...
ECHO.
Git update-git-for-windows
IF %ERRORLEVEL% == 0(GOTO Update-Git-Finish)
ECHO.
ECHO.
Git update
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Update-Git-Back)ELSE (GOTO Update-Git-Finish)

:Update-Git-Winget
ECHO.
ECHO ========================�ϥ�Winget��s=========================
ECHO.
ECHO ��s��...
ECHO.
Winget upgrade --id Git.Git -e --source winget
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Update-Git-Back)ELSE (GOTO Update-Git-Finish)

:Update-Git-Choco
ECHO.
ECHO ========================�ϥ�Choco��s==========================
ECHO.
ECHO ��s��...
ECHO.
Choco upgrade git
IF %ERRORLEVEL% NEQ 0(GOTO FAIL-Update-Git-Back)ELSE (GOTO Update-Git-Finish)

:FAIL-Update-Git-Back
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "�w�˥���! �O�_�^����ϥΨ�L�覡�U��[Y,N]? : "
IF ERRORLEVEL 2 (
 GOTO Update-Git-Choose
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:Update-Git-Finish
ECHO.
ECHO ==============================================================
ECHO. 
ECHO ��s���\! ������:
Git version
GOTO Finish-Back

::REM ===================================�ˬd�O�_�w��=====================================

:Confirm-Git
Git --help > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-Confirm-Git)
EXIT /B

:Confirm-Winget
Winget -? > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-Confirm-Winget)
EXIT /B

:Confirm-Choco
Choco help > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (GOTO FAIL-Confirm-Choco)
EXIT /B

:FAIL-Confirm-Git
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "���w��Git�A�O�_�i��w�˵{��? : "
IF ERRORLEVEL 2 (
 GOTO Install-Git
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:FAIL-Confirm-Winget
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "���w��Winget�A�O�_�i��w�˵{��(Windows10 1709(�ի� 16299)�H�W�~�䴩Winget)? : "
IF ERRORLEVEL 2 (
 GOTO Install-Winget
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

:FAIL-Confirm-Choco
ECHO.
ECHO ==============================================================
ECHO.
CHOICE /C NY /N /M "���w��Chocolatey�A�O�_�i��w�˵{��? : "
IF ERRORLEVEL 2 (
 GOTO Install-Chocolatey
)ELSE IF ERRORLEVEL 1 (
 GOTO Finish-Back
)

::REM =====================================Finish========================================

:Finish-Back
ECHO.
ECHO ==============================================================
ECHO. 
CHOICE /C NY /N /M "�O�_�^��D���[Y,N]?: "
IF ERRORLEVEL 2 (
 GOTO MAIN
)ELSE IF ERRORLEVEL 1 (
 GOTO EXIT
)

:EXIT
ECHO.
ECHO.
PAUSE
EXIT
