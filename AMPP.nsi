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

  !include "Registry.nsh"
  !include "FileFunc.nsh"
  !include "Sections.nsh"
  !include "LogicLib.nsh"
  !include "nsDialogs.nsh"
  !include "StrFunc.nsh"
  !include "TextReplace.nsh"
  !include "ZipDLL.nsh"
  !include "StrRep.nsh"
  !include "Ports.nsh"

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
  var mysql_passwdfile
  
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
  var apache_server_name_w_domain
  var apache_admin_email

;--------------------------------
; installer Sections
  
  ${StrCase}

  Function .onVerifyInstDir
  FunctionEnd
  
  Function add_remove
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "DisplayName" "AMPP - Apache2, MySQL, PHP, phpMyAdmin"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "DisplayIcon" "$INSTDIR\un-ampp.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "Publisher" ""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "HelpLink" "https://github.com/motoko-kusanagi/ampp"                 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "URLInfoAbout" "https://github.com/motoko-kusanagi/ampp/blob/master/README.md"                 
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "HelpTelephone" ""        
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "DisplayVersion" "1.0"                     
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AMPP" \ 
                     "UninstallString" "$\"$INSTDIR\un-ampp.exe$\""
  FunctionEnd

  Section "Express" section_one
  SectionEnd
  
  Section /o "Advanced" section_two
  SectionEnd
   
  Section "" main ; default section
    SetShellVarContext all

    CreateDirectory "$INSTDIR\Logs"    
    call apache_install
    call php_install
    call phpmyadmin_install
    call create_www
    call dotnet_install
    call mysql_install

    call add_remove

    ; start memnu shortcuts
    CreateDirectory "$SMPROGRAMS\AMPP"
    CreateShortCut "$SMPROGRAMS\AMPP\PHP.ini.lnk" "$INSTDIR\PHP\php.ini" "" ""
    CreateShortCut "$SMPROGRAMS\AMPP\MySQL.ini.lnk" "$INSTDIR\MySQL\my.ini" "" ""
    CreateShortCut "$SMPROGRAMS\AMPP\Uninstaller.lnk" "$INSTDIR\un-ampp.exe" "" ""    

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
    StrCpy "$apache_server_name_w_domain" "$apache_server_name.$apache_domain"

    System::Call "advapi32::GetUserName(t .r0, *i ${NSIS_MAX_STRLEN} r1) i.r2"
    StrCpy $apache_admin_email $0
    StrCpy $apache_admin_email "$apache_admin_email@$apache_domain"  
  FunctionEnd

  Function apache_install
    ${If} ${SectionIsSelected} ${section_one}    
      call detect_apache_settings
    ${EndIf}
    
    ${If} ${TCPPortOpen} 80
        MessageBox MB_YESNO|MB_ICONQUESTION "port 80 is used... apache won't work. continue?" IDYES yes IDNO no
        no:
          MessageBox MB_OK|MB_ICONEXCLAMATION "bye bye!"
          Quit
        yes:
          Pop $0
    ${EndIf}
  
    SetOutPath "$TEMP\ampp\"
    File "inst-files\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
    DetailPrint "Install Apache HTTP Server..."
    ExecWait 'msiexec /i "$TEMP\ampp\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi" /qb! INSTALLDIR="$INSTDIR\Apache2" SERVERNAME=$apache_server_name SERVERADMIN="$apache_admin_email" ALLUSERS=1 RebootYesNo=No /L*V "$INSTDIR\Logs\apache2.log"'
    
    DetailPrint "Configure apache HTTP Server..."
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "htdocs" "www-root" "/S=1 /C=1 /AO=1" $0
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "index.html" "index.html index.php" "/S=1 /C=1 /AO=1" $0
    
    ExecWait '"$INSTDIR\apache2\bin\httpd.exe" -k restart'
    
    Delete "$TEMP\ampp\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
  FunctionEnd
  
  Function php_install
    SetOutPath "$TEMP\ampp\"
    File "inst-files\php-5.3.28-Win32-VC9-x86.msi"
    DetailPrint "Install PHP..."
    ExecWait 'msiexec /i "$TEMP\ampp\php-5.3.28-Win32-VC9-x86.msi" /qb! INSTALLDIR="$INSTDIR\PHP" apacheDIR="$INSTDIR\apache2\conf" ADDLOCAL="ScriptExecutable,cgi,apache22,ext_php_mysqli,ext_php_mysql,ext_php_mbstring" /L*V "$INSTDIR\Logs\php.log"'

    DetailPrint "Restart Apache HTTP Server..."
    ExecWait '"$INSTDIR\apache2\bin\httpd.exe" -k restart'
    
    Delete "$TEMP\ampp\php-5.3.28-Win32-VC9-x86.msi"
  FunctionEnd

  Function create_www
    SetOutPath "$INSTDIR\apache2\www-root\"
    File "inst-files\index.php"
  FunctionEnd

  Function phpmyadmin_install
    CreateDirectory "$INSTDIR\apache2\www-root\"
    SetOutPath "$TEMP\ampp\"
    File "inst-files\phpMyAdmin-4.0.9-english.zip"
    DetailPrint "Install phpMyAdmin..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\ampp\phpMyAdmin-4.0.9-english.zip" "$INSTDIR\apache2\www-root" "<ALL>"
    
    Delete "$TEMP\ampp\phpMyAdmin-4.0.9-english.zip"
  FunctionEnd
  
  Function mysql_install
    ${If} ${SectionIsSelected} ${section_one}
      StrCpy $mysql_service_name "MySQL56"
      StrCpy $mysql_port "3306"
      StrCpy $mysql_log_general "1"
      StrCpy $mysql_log_slow "1"
      StrCpy $mysql_log_bin "1"
    ${EndIf}
    
    ${If} ${TCPPortOpen} 3306
      MessageBox MB_YESNO|MB_ICONQUESTION "port 3306 is used... mysql won't work. continue?" IDYES yes IDNO no
      no:
        MessageBox MB_OK|MB_ICONEXCLAMATION "bye bye!"
        Quit
      yes:
        Pop $0
    ${EndIf}
    
    SetOutPath "$TEMP\ampp\"
    File "inst-files\mysql-5.6.15-win32.zip"
    DetailPrint "Install MySQL Server..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\ampp\mysql-5.6.15-win32.zip" "$INSTDIR\MySQL" "<ALL>"
    
    DetailPrint "Configure MySQL Server..."
    
    Delete "$INSTDIR\MySQL\my-default.ini"
    SetOutPath "$INSTDIR\MySQL"
    File "mysql-conf\my.ini"
    
    ${StrReplace} "$INSTDIR\MySQL" "\" "\\"
    StrCpy $mysql_basedir_path $0
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "basedir-path" "$mysql_basedir_path" "/S=1 /C=1 /AO=1" $0 ; replaces basedir path in my.ini config    
    
    ${StrReplace} "$INSTDIR\MySQL\data" "\" "\\"
    StrCpy $mysql_datadir_path $0
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "datadir-path" "$mysql_datadir_path" "/S=1 /C=1 /AO=1" $0 ; replaces datadir path in my.ini config

    ; mysql logs...

    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "error.log" "$apache_server_name.err" "/S=1 /C=1 /AO=1" $0

    ${If} $mysql_log_general == "1"
      ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "general-log=0" "general-log=1" "/S=1 /C=1 /AO=1" $0 ; turns on general log
      ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "general.log" "$apache_server_name.log" "/S=1 /C=1 /AO=1" $0
    ${EndIf}
    
    ${If} $mysql_log_slow == "1"
      ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "slow-query-log=0" "slow-query-log=1" "/S=1 /C=1 /AO=1" $0 ; turns on slow log
      ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "slow.log" "$apache_server_name-slow.log" "/S=1 /C=1 /AO=1" $0
    ${EndIf}

    ${If} $mysql_log_bin == "1"
      ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "bin.log" "$apache_server_name-bin.log" "/S=1 /C=1 /AO=1" $0 ; turns on slow log
    ${Else}
      ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "log-bin" "# log-bin" "/S=1 /C=1 /AO=1" $0 ; turns on slow log
    ${EndIf}    
    
    FileOpen $4 "$INSTDIR\MySQL\service.info" w
    FileWrite $4 "$mysql_service_name"
    FileClose $4
    
    DetailPrint "Instauj MySQL Server jako serwis..."
    ExecWait '"$INSTDIR\MySQL\bin\mysqld.exe" --install $mysql_service_name' ; mysql as a service
    
    DetailPrint "Run service $mysql_service_name..."
    ExecWait '"net" start $mysql_service_name' ; starts mysql service
    
    
    
    SetOutPath "$TEMP\ampp"
    File "mysql-conf\passwd.sql"
    ${textreplace::ReplaceInFile} "$TEMP\ampp\passwd.sql" "$TEMP\ampp\passwd.sql" "my-new-password" "$mysql_passwd" "/S=1 /C=1 /AO=1" $0 ; replaces my-new-password with specific user password
    
    sleep 6000
    StrCpy $mysql_passwdfile "$TEMP\ampp\passwd.sql"
    ExecWait '"cmd.exe" /C "$INSTDIR\MySQL\bin\mysql.exe" -uroot < $mysql_passwdfile' $0 ; changes root password
    MessageBox MB_OK $0
    
    ;Delete "$TEMP\ampp\passwd.sql"
    Delete "$TEMP\ampp\mysql-5.6.15-win32.zip"
  FunctionEnd
  
  Function dotnet_install
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" 'TargetVersion'
    ${If} $0 != "4.0.0"
      SetOutPath "$TEMP\ampp\"
      File "inst-files\dotNetFx40_Full_x86_x64.exe"
      DetailPrint "Install .NET Framework v.4.0..."
      ExecCmd::exec '"$TEMP\ampp\dotNetFx40_Full_x86_x64.exe" /passive /norestart'
      Delete "$TEMP\ampp\dotNetFx40_Full_x86_x64.exe"
    ${EndIf}
  FunctionEnd
  
  Function apache2_config_adv_one
    ${If} ${SectionIsSelected} ${section_two}
      call detect_apache_settings
      nsDialogs::Create /NOUNLOAD 1018
      Pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
      
      ${NSD_CreateLabel} 0 0 200 20 "Apache2 settings."

      ${NSD_CreateLabel} 0 30 200 20 "Domain name:"
      ${NSD_CreateText} 0 50 200 20 "$apache_domain"
      Pop $text0

      ${NSD_CreateLabel} 0 80 200 20 "Server name:"
      ${NSD_CreateText} 0 100 200 20 "$apache_server_name"
      Pop $text1
      
      ${NSD_CreateLabel} 0 130 200 20 "Administrator e-mail address:"
      ${NSD_CreateText} 0 150 200 20 "$apache_admin_email"
      Pop $text2

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
      Pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
      
      ${NSD_CreateLabel} 0 0 200 20 "MySQL settings."
      
      ${NSD_CreateLabel} 0 30 200 20 "Service name:"
      ${NSD_CreateText} 0 50 200 20 "MySQL56"
      Pop $text0
        
      ${NSD_CreateLabel} 0 80 200 20 "Server port:"
      ${NSD_CreateNumber} 0 100 200 20 "3306"
      Pop $text1
      
      ${NSD_CreateCheckbox} 0 140 100% 8u "General log"
      Pop $checkbox_log_general
      
      ${NSD_CreateCheckbox} 0 160 100% 8u "Slow query log"
      Pop $checkbox_log_slow
      
      ${NSD_CreateCheckbox} 0 180 100% 8u "Bin log"
      Pop $checkbox_log_bin
      
      nsDialogs::Show    
    ${EndIf}
  FunctionEnd
  
  Function get_val_mysql_config_adv_one
    ${NSD_GetText} $text0 $mysql_service_name
    ${NSD_GetText} $text1 $mysql_port
    
    ${NSD_GetState} $checkbox_log_general $mysql_log_general 
    ${NSD_GetState} $checkbox_log_slow $mysql_log_slow 
    ${NSD_GetState} $checkbox_log_bin $mysql_log_bin  
    
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
      Pop $dialog
      
      ${If} $dialog == error
        abort
      ${EndIf}
          
      ${NSD_CreateLabel} 0 0 200 20 "MySQL settings."
      
      ${NSD_CreateLabel} 0 30 200 20 "root password:"
      ${NSD_CreatePassword} 0 50 200 20 ""
      Pop $text0
        
      ${NSD_CreateLabel} 0 80 200 20 "repeat password:"
      ${NSD_CreatePassword} 0 100 200 20 ""
      Pop $text1
    
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
    StrCmp $mysql_passwd_rep "" mustcomplete
    
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
    DetailPrint "Uninstall Apache HTTP Server..."
    ExecCmd::exec 'msiexec /X{85262A06-2D8C-4BC1-B6ED-5A705D09CFFC} /norestart /qb! ALLUSERS=1 REMOVE="ALL" >ExecCmd.log'
    
    ; php5
    DetailPrint "Uninstall PHP..."
    ExecCmd::exec 'msiexec /X{F1294EED-6F8E-4C87-B34A-AB045356531D} /norestart /qb! ALLUSERS=1 REMOVE="ALL" >ExecCmd.log'
    
    ; mysql
    FileOpen $4 "$INSTDIR\MySQL\service.info" r
    FileRead $4 $1
    StrCpy $mysql_service_name $1
    FileClose $4
    MessageBox MB_OK $mysql_service_name
    
    DetailPrint "Stop MySQL service..."
    ExecWait '"net" stop $mysql_service_name'
    DetailPrint "Remove MySQL service..."
    ExecWait '"MySQL\bin\mysqld.exe" --remove $mysql_service_name'
    
    ; start menu shortcuts
    Delete "$SMPROGRAMS\AMPP\php.ini"
    Delete "$SMPROGRAMS\AMPP\my.ini"
    Delete "$SMPROGRAMS\AMPP\un-ampp.exe"  
    RMDIR /r "$SMPROGRAMS\AMPP"
    
    RMDir /r "PHP"
    RMDir /r "Apache2"
    ;RMDir /r "MySQL"
    RMDir /r "Logs"
    Delete "un-ampp.exe"
    
   SectionEnd
   
  Function un.onInit ; uninstaller init
    SetRebootFlag true
  FunctionEnd
  
  Function .onInit ; podczas inicjacji okna
    SetRebootFlag true
    SectionSetSize ${main} 1289000
  FunctionEnd