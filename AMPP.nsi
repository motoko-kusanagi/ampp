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
  SetCompressor bzip2

; request application privileges for Windows Vista and Windows 7
  RequestExecutionLevel admin

; includes

  !include "Registry.nsh" ; rejestr
  !include "FileFunc.nsh"
  
  !include "Sections.nsh" ; opcje sekcji
  !include "logiclib.nsh" ; operatory logiczne
  ;!include "nsProcess.nsh" ; sprawdzanie procesu
  !include "nsDialogs.nsh"
  ;!include "x64.nsh" ; wersje x64
  !include "StrFunc.nsh"
  !include "TextReplace.nsh" ; zamiana tekstu
  !include "ZipDLL.nsh" ; zip extractor
  !include "StrRep.nsh" ; string replace

; interface settings
    
;--------------------------------
; pages
  
  page license
  page components
  page directory
  
  page custom apache2_config_adv_one get_val_apache2_config_adv_one
  page custom mysql_config_adv_one get_val_mysql_config_adv_one
  page custom mysql_config_adv_two get_val_mysql_config_adv_two
  
  page instfiles
  uninstpage uninstConfirm
  uninstpage instfiles
  
; Languages
 
;--------------------------------
; variables

  ; global for ns dialog plugin
  var dialog
  
  var text0
  var text1
  var text2
  
  ; custom pages
  var checkbox_log_general
  var checkbox_log_slow
  var checkbox_log_bin
  
  ; mysql variables
  var mysql_service_name
  var mysql_port
  var mysql_passwd
  var mysql_passwd_rep
  var mysql_datadir_path
  var mysql_basedir_path

  var mysql_log_general
  var mysql_log_slow
  var mysql_log_bin
  
  ; apache2 variables
  var apache_domain
  var apache_server_name
  var apache_admin_email

;--------------------------------
; installer Sections
  
  ${StrCase}

  Function .onVerifyInstDir
  FunctionEnd
  
  ;Function add_remove ; dodaje klucze do dodaj / usun w panelu sterowania
;  FunctionEnd

  Section "Express" section_one
  SectionEnd
  
  Section /o "Advanced" section_two
  SectionEnd
   
  Section "" main ; default section
    SetShellVarContext all

    CreateDirectory "$INSTDIR\Log"    
    call apache_install
    call php_install
    call phpmyadmin_install
    call create_www
    call dotnet_install
    call mysql_install

    WriteUninstaller "$INSTDIR\un-ampp.exe"      
  SectionEnd
 
  Function .onSelChange
    !insertmacro StartRadioButtons $1
    !insertmacro RadioButton ${section_one}
    !insertmacro RadioButton ${section_two}
    !insertmacro EndRadioButtons
  FunctionEnd

  Function detect_apache_settings
    ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\services\Tcpip\Parameters" "Domain"
    StrCpy $apache_domain $0
      
    ${If} $apache_domain == ""
    ${EndIf}

    ReadRegStr $0 HKLM "System\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"
    StrCpy $apache_server_name $0
    ${StrCase} "$apache_server_name" "$apache_server_name" "L"
    StrCpy "$apache_server_name" "$apache_server_name.$apache_domain"

    System::Call "advapi32::GetUserName(t .r0, *i ${NSIS_MAX_STRLEN} r1) i.r2"
    StrCpy $apache_admin_email $0
    StrCpy $apache_admin_email "$apache_admin_email@$apache_domain"  
  FunctionEnd

  Function apache_install
    ${If} ${SectionIsSelected} ${section_one}    
      call detect_apache_settings
    ${EndIf}
  
    SetOutPath "$TEMP\portal\"
    File "inst-files\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
    DetailPrint "Instaluj apache HTTP Server..."
    ExecCmd::exec 'msiexec /i "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi" /qb! INSTALLDIR="$INSTDIR\apache2" SERVERNAME=$apache_server_name SERVERADMIN="$apache_admin_email" ALLUSERS=1 RebootYesNo=No /L*V "$INSTDIR\Log\apach2.log"'
    
    DetailPrint "Konfiguruj apache HTTP Server..."
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "htdocs" "www-root" "/S=1 /C=1 /AO=1" $0
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "index.html" "index.html index.php" "/S=1 /C=1 /AO=1" $0
    
    ExecWait '"$INSTDIR\apache2\bin\httpd.exe" -k restart'
    
    Delete "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
  FunctionEnd
  
  Function php_install
    SetOutPath "$TEMP\portal\"
    File "inst-files\php-5.3.28-Win32-VC9-x86.msi"
    DetailPrint "Instaluj php..."
    ExecWait 'msiexec /i "$TEMP\portal\php-5.3.28-Win32-VC9-x86.msi" /qb! INSTALLDIR="$INSTDIR\php" apacheDIR="$INSTDIR\apache2\conf" ADDLOCAL="ScriptExecutable,cgi,apache22,ext_php_mysqli,ext_php_mysql,ext_php_mbstring" /L*V "$INSTDIR\Log\php.log"'
    
    Delete "$TEMP\portal\php-5.3.28-Win32-VC9-x86.msi"
  FunctionEnd

  Function create_www
    SetOutPath "$INSTDIR\apache2\www-root\"
    File "inst-files\index.php"
  FunctionEnd

  Function phpmyadmin_install
    CreateDirectory "$INSTDIR\apache2\www-root\"
    SetOutPath "$TEMP\portal\"
    File "inst-files\phpMyAdmin-4.0.9-english.zip"
    DetailPrint "Instaluj phpMyAdmin..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\portal\phpMyAdmin-4.0.9-english.zip" "$INSTDIR\apache2\www-root" "<ALL>"
    
    Delete "$TEMP\portal\phpMyAdmin-4.0.9-english.zip"
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
    File "inst-files\mysql-5.6.15-win32.zip"
    DetailPrint "Instaluj MySQL Server..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\portal\mysql-5.6.15-win32.zip" "$INSTDIR\MySQL" "<ALL>"
    
    DetailPrint "Konfiguruj MySQL Server..."
    
    Delete "$INSTDIR\MySQL\my-default.ini"
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
    
    ExecWait '"cmd.exe" /S /C ""$INSTDIR\MySQL\bin\mysql.exe" -u root < "passwd.sql""' ; changes root password
    
    Delete "$INSTDIR\MySQL\bin\passwd.sql"
    Delete "$TEMP\portal\mysql-5.6.15-win32.zip"
  FunctionEnd
  
  Function dotnet_install
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" 'TargetVersion'
    ${If} $0 != "4.0.0"
      SetOutPath "$TEMP\portal\"
      File "inst-files\dotNetFx40_Full_x86_x64.exe"
      DetailPrint "Instaluj .NET Framework v.4.0..."
      ExecCmd::exec '"$TEMP\portal\dotNetFx40_Full_x86_x64.exe" /passive /norestart'
      Delete "$TEMP\portal\dotNetFx40_Full_x86_x64.exe"
    ${EndIf}
  FunctionEnd
  
  Function apache2_config_adv_one
    ${If} ${SectionIsSelected} ${section_two}
      call detect_apache_settings
      nsDialogs::Create /NOUNLOAD 1018
      pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
      
      ${NSD_CreateLabel} 0 0 200 20 "Apache2 settings."

      ${NSD_CreateLabel} 0 30 200 20 "Domain name:"
      ${NSD_CreateText} 0 50 200 20 "$apache_domain"
      pop $text0

      ${NSD_CreateLabel} 0 80 200 20 "Server name:"
      ${NSD_CreateText} 0 100 200 20 "$apache_server_name"
      pop $text1
      
      ${NSD_CreateLabel} 0 130 200 20 "Administrator e-mail address:"
      ${NSD_CreateText} 0 150 200 20 "$apache_admin_email"
      pop $text2

      nsDialogs::Show  
    ${EndIf}
  FunctionEnd
  
  Function get_val_apache2_config_adv_one
    ${NSD_GetText} $text0 $apache_domain
    ${NSD_GetText} $text1 $apache_server_name
    ${NSD_GetText} $text2 $apache_admin_email
    
    StrCmp $apache_domain "" mustcomplete
    StrCmp $apache_server_name "" mustcomplete
    StrCmp $apache_admin_email "" mustcomplete
    goto exit

    mustcomplete:
      MessageBox MB_OK|MB_ICONEXCLAMATION "please fill all fields!"
      Abort
    exit:
      Pop $0
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
      ${NSD_CreateNumber} 0 100 200 20 "3306"
      pop $text1
      
      ${NSD_CreateCheckbox} 0 140 100% 8u "General log"
      pop $checkbox_log_general
      
      ${NSD_CreateCheckbox} 0 160 100% 8u "Slow query log"
      pop $checkbox_log_slow
      
      ${NSD_CreateCheckbox} 0 180 100% 8u "Bin log"
      pop $checkbox_log_bin
      
      nsDialogs::Show    
    ${EndIf}
  FunctionEnd
  
  Function get_val_mysql_config_adv_one
    ${NSD_GetText} $text0 $mysql_service_name
    ${NSD_GetText} $text1 $mysql_port
    
    ${NSD_GetState} $checkbox_log_general $checkbox_log_general
    ${NSD_GetState} $checkbox_log_slow $checkbox_log_slow
    ${NSD_GetState} $checkbox_log_bin $checkbox_log_bin    
    
    StrCmp $mysql_service_name "" mustcomplete
    StrCmp $mysql_port "" mustcomplete
    goto exit

    mustcomplete:
      MessageBox MB_OK|MB_ICONEXCLAMATION "please fill all fields!"
      Abort
    exit:
      Pop $0    
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
      ${NSD_CreatePassword} 0 50 200 20 ""
      pop $text0
        
      ${NSD_CreateLabel} 0 80 200 20 "repeat password:"
      ${NSD_CreatePassword} 0 100 200 20 ""
      pop $text1
    
      nsDialogs::Show    
    ${EndIf}
  FunctionEnd
  
  Function get_val_mysql_config_adv_two
    ${NSD_GetText} $text0 $mysql_passwd
    ${NSD_GetText} $text1 $mysql_passwd_rep
    
    ${If} $mysql_passwd != $mysql_passwd_rep
      MessageBox MB_OK|MB_ICONEXCLAMATION "blah password is incorrect!"
      Abort
    ${EndIf}

    StrCmp $mysql_passwd "" mustcomplete
    StrCmp $mysql_passwd "" mustcomplete
    
    goto exit
    
    mustcomplete:
      MessageBox MB_OK|MB_ICONEXCLAMATION "damn! password can't be empty!"
      Abort
    exit:
      Pop $0    
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
   
  Function un.onInit ; uninstaller init
    SetRebootFlag true
  FunctionEnd
  
  Function .onInit ; podczas inicjacji okna
    SetRebootFlag true
    SectionSetSize ${main} 1289000
  FunctionEnd