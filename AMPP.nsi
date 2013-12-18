; general

; name and file
  Name "AMPP"
  OutFile "ampp.exe"
  Caption "AMPP"
  ;Icon "icon\icon.ico"
  ;UninstallIcon "icon\un-icon.ico"
  BrandingText "AMPP"

; the default installation directory
  InstallDir "$PROGRAMFILES\AMPP\"

  CRCCheck on
  ShowInstDetails hide
  
  SetCompress off

; request application privileges for Windows Vista and Windows 7
  RequestExecutionLevel admin

; includes

  !include "Registry.nsh" ; rejestr
  !include "FileFunc.nsh"
  
  !include "Sections.nsh" ; opcje sekcji
  !include "logiclib.nsh" ; operatory logiczne
  !include "nsProcess.nsh" ; sprawdzanie procesu
  !include nsDialogs.nsh
  !include "EnumUsersReg.nsh" ; reg hive
  !include "x64.nsh" ; wersje x64
  !include "StrFunc.nsh"
  !include "TextReplace.nsh" ; zamiana tekstu
  !include "ZipDLL.nsh" ; zip extractor
  !include "WriteToFile.nsh" ; write lines to file
  !include "StrRep.nsh" ; string replace
  !include "OpenLinkNewWindow.nsh" ; opens link in default wrobser

; interface settings
    
;--------------------------------
; pages
  
  page license
  page components
  page directory
  
  page custom apache2_config_adv_one
  page custom mysql_config_adv_one
  page custom mysql_config_adv_two
  
  page instfiles
  uninstpage uninstConfirm
  uninstpage instfiles
  
; Languages
 
;--------------------------------
; variables

  ; global
  var dialog
  
  var text0
  var text1
  var text2
  var temp1
  
  var RegVer
  
  ; mysql variables
  var mysql_service_name
  var mysql_port
  var mysql_passwd
  var mysql_datadir_path
  var mysql_basedir_path

  var mysql_log_general
  var mysql_log_slow
  var mysql_log_bin
  
  ; apache2 variables
  var apache_port
  var apache_domain
  var apache_server_name
  var apache_admin_email

;--------------------------------
; installer Sections

  Function LicenseShow
    ScrollLicense::Set /NOUNLOAD
  FunctionEnd
  
  Function un.onInit ; uninstaller init
    SetRebootFlag true
  FunctionEnd
  
  Function .onVerifyInstDir
  FunctionEnd
  
  Function registry_check ; sprawdzanie rejestru (64 czy 32 bity)
    GetVersion::WindowsPlatformArchitecture
    Pop $R1
    ${If} $R1 == "32"
      SetRegView 32 ; ustawia czytanie rejestru na 32bity
      StrCpy $RegVer "32"
    ${ElseIf} $R1 == "64"
      SetRegView 64 ; ustawia czytanie rejestru na 64bity
      StrCpy $RegVer "64"
    ${EndIf}
  FunctionEnd
  
  Function add_remove ; dodaje klucze do dodaj / usun w panelu sterowania

  FunctionEnd

  Function apache_install
    ${If} ${SectionIsSelected} ${section_one}
      StrCpy $apache_port "80"
      StrCpy $apache_domain ""
      
      ReadRegStr $0 HKLM "System\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"
      StrCpy $apache_server_name $0
      StrCpy $apache_admin_email "admin@localhost.pl"
    ${EndIf}
  
    SetOutPath "$TEMP\portal\"
    File "inst-files\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
    DetailPrint "Instaluj apache HTTP Server..."
    ;ExecCmd::exec 'msiexec /i "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi" /qb! INSTALLDIR="$INSTDIR\apache2" SERVERNAME=$apache_server_name SERVERADMIN="admin@$ServName" ALLUSERS=1 RebootYesNo=No /L*V "$INSTDIR\Log\apach2.log"'
    
    DetailPrint "Konfiguruj apache HTTP Server..."
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "htdocs" "www-root" "/S=1 /C=1 /AO=1" $0
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "index.html" "index.html index.php" "/S=1 /C=1 /AO=1" $0
    
    ExecWait '"$INSTDIR\apache2\bin\httpd.exe" -k restart'
    
  FunctionEnd
  
  Function php_install
    SetOutPath "$TEMP\portal\"
    ;File "inst-files\php-5.3.28-Win32-VC9-x86.msi"
    DetailPrint "Instaluj php..."
    ExecCmd::exec 'msiexec /i "$TEMP\portal\php-5.3.28-Win32-VC9-x86.msi" /qb! INSTALLDIR="$INSTDIR\php" apacheDIR="$INSTDIR\apache2\conf" ADDLOCAL="ScriptExecutable,cgi,apache22,ext_php_mysqli,ext_php_mysql,ext_php_mbstring" /L*V "$INSTDIR\Log\php.log"'
  FunctionEnd

  Function create_www
    SetOutPath "$INSTDIR\apache2\www-root\"
    File "inst-files\index.php"
  FunctionEnd

  Function phpmyadmin_install
    CreateDirectory "$INSTDIR\apache2\www-root\"
    SetOutPath "$TEMP\portal\"
    ;File "inst-files\phpMyAdmin-4.0.9-english.zip"
    DetailPrint "Instaluj phpMyAdmin..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\portal\phpMyAdmin-4.0.9-english.zip" "$INSTDIR\apache2\www-root" "<ALL>"
  FunctionEnd
  
  Function mysql_install
    ${If} ${SectionIsSelected} ${section_one}
      StrCpy $mysql_service_name "MySQL56"
      StrCpy $mysql_port "3306"
      StrCpy $mysql_log_general "1"
      StrCpy $mysql_log_slow "1"
      StrCpy $mysql_log_bin "1"
    ${EndIf}
    
    
    SetOutPath "$TEMP\portal\"
    ;File "inst-files\mysql-5.6.15-win32.zip"
    DetailPrint "Instaluj MySQL Server..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\portal\mysql-5.6.15-win32.zip" "$INSTDIR\MySQL" "<ALL>"
    
    DetailPrint "Konfiguruj MySQL Server..."
    
    SetOutPath "$INSTDIR\MySQL"
    File "mysql-conf\my.ini"
    
    ${StrReplace} "$INSTDIR\MySQL" "\" "\\"
    StrCpy $mysql_basedir_path $0
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "basedir-path" "$mysql_basedir_path" "/S=1 /C=1 /AO=1" $0 ; replaces basedir path in my.ini config    
    
    ${StrReplace} "$INSTDIR\MySQL\data" "\" "\\"
    StrCpy $mysql_datadir_path $0
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "datadir-path" "$mysql_datadir_path" "/S=1 /C=1 /AO=1" $0 ; replaces datadir path in my.ini config
    
    DetailPrint "Instauj MySQL Server jako serwis..."
    ExecWait '"$INSTDIR\MySQL\bin\mysqld.exe" --install $mysql_service_name' ; mysql as a service
    
    DetailPrint "Uruchom us³ugê MySQL Server..."
    ExecWait '"net" start mysql' ; starts mysql service
    
    SetOutPath "$INSTDIR\MySQL\bin\"
    File "mysql-conf\passwd.sql"
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\bin\passwd.sql" "$INSTDIR\MySQL\bin\passwd.sql" "my-new-password" "$mysql_passwd" "/S=1 /C=1 /AO=1" $0 ; replaces my-new-password with specific user password
    
    ;ExpandEnvStrings $ComSpec %COMSPEC%
    ExecWait '"cmd.exe" /S /C ""$INSTDIR\MySQL\bin\mysql.exe" -u root < "passwd.sql""' ; changes root password
    
    Delete "$INSTDIR\MySQL\bin\passwd.sql"
  FunctionEnd
  
  Function dotnet_install
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" 'TargetVersion'
    ${If} $0 != "4.0.0"
      SetOutPath "$TEMP\portal\"
      ;File "inst-files\dotNetFx40_Full_x86_x64.exe"
      DetailPrint "Instaluj .NET Framework v.4.0..."
      ExecCmd::exec '"$TEMP\portal\dotNetFx40_Full_x86_x64.exe" /passive /norestart'
    ${EndIf}
  FunctionEnd
  
  Function clean_up_files
    Delete "$TEMP\portal\dotNetFx40_Full_x86_x64.exe"
    Delete "$TEMP\portal\mysql-5.6.15-win32.zip"
    Delete "$TEMP\portal\phpMyAdmin-4.0.9-english.zip"
    Delete "$TEMP\portal\php-5.3.28-Win32-VC9-x86.msi"
    Delete "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
  FunctionEnd

  Section "Simple" section_one
  SectionEnd
  
  Section /o "Advanced" section_two
  SectionEnd
  
  Function .onSelChange
    SectionSetSize ${section_one} 1289000
    SectionSetSize ${section_two} 1299000
  
    !insertmacro StartRadioButtons $1
    !insertmacro RadioButton ${section_one}
    !insertmacro RadioButton ${section_two}
    !insertmacro EndRadioButtons
  FunctionEnd
  
  Function .onInit ; podczas inicjacji okna
    SetRebootFlag true
    call registry_check

    StrCpy $1 ${section_one}
  FunctionEnd
  

  Section "" main ; default section
    SetShellVarContext all

    CreateDirectory "$INSTDIR\Log"    
    ;call apache_install
    ;call php_install
    ;call phpmyadmin_install
    ;call create_www
    ;call dotnet_install
    ;call mysql_install

    ;WriteUninstaller "$INSTDIR\un-ampp.exe"      
  SectionEnd

  Function apache2_config_adv_one
    ${If} ${SectionIsSelected} ${section_two}
      nsDialogs::Create /NOUNLOAD 1018
      pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
      
      ${NSD_CreateLabel} 0 0 200 20 "Apache2 settings."
      
      ${NSD_CreateLabel} 0 30 200 20 "Domain name:"

      ${NSD_CreateText} 0 50 200 20 ""
      pop $text0
        
     ${NSD_CreateLabel} 0 80 200 20 "Server name:"

     ${NSD_CreateText} 0 100 200 20 ""
     pop $text1
     
     ${NSD_CreateLabel} 0 130 200 20 "Administrator e-mail address:"
     ${NSD_CreateText} 0 150 200 20 ""
     pop $text2
     
    nsDialogs::Show  
    ${EndIf}
  FunctionEnd

  Function mysql_config_adv_one
    ${If} ${SectionIsSelected} ${section_two}
      nsDialogs::Create /NOUNLOAD 1018
      pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
      
      ${NSD_CreateLabel} 0 0 200 20 "MySQL settings."
      
      ${NSD_CreateLabel} 0 30 200 20 "Service name:"
      ${NSD_CreateText} 0 50 200 20 "MySQL56"
      pop $text0
        
      ${NSD_CreateLabel} 0 80 200 20 "Server port:"
      ${NSD_CreateText} 0 100 200 20 "3306"
      pop $text1
      
      ${NSD_CreateCheckbox} 0 140 100% 8u "General log"
      ${NSD_CreateCheckbox} 0 160 100% 8u "Slow query log"
      ${NSD_CreateCheckbox} 0 180 100% 8u "Bin log"
      
      nsDialogs::Show    
    ${EndIf}
  FunctionEnd

  Function mysql_config_adv_two
    ${If} ${SectionIsSelected} ${section_two}
      nsDialogs::Create /NOUNLOAD 1018
      pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
          
      ${NSD_CreateLabel} 0 0 200 20 "MySQL settings."
      
      ${NSD_CreateLabel} 0 30 200 20 "root password:"
      ${NSD_CreateText} 0 50 200 20 ""
      pop $text0
        
      ${NSD_CreateLabel} 0 80 200 20 "repeat password:"
      ${NSD_CreateText} 0 100 200 20 ""
      pop $text1
    
      nsDialogs::Show    
    ${EndIf}
  FunctionEnd
  
  Section "Uninstall"
    SetShellVarContext all ; menu start from all users

    ; apache2
    ExecCmd::exec 'msiexec /X{85262A06-2D8C-4BC1-B6ED-5A705D09CFFC} /norestart /qb! ALLUSERS=1 REMOVE="ALL" >ExecCmd.log'
    
    ; php5
    ExecCmd::exec 'msiexec /X{F1294EED-6F8E-4C87-B34A-AB045356531D} /norestart /qb! ALLUSERS=1 REMOVE="ALL" >ExecCmd.log'
    
    ; mysql
    ExecWait '"net" stop mysql'
    ExecWait '"MySQL\bin\mysqld.exe" --remove'
        
   SectionEnd