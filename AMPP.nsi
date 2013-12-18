; General

; Name and file
  Name "AMPP"
  OutFile "ampp.exe"
  Caption "AMPP"
  ;Icon "icon\icon.ico"
  ;UninstallIcon "icon\un-icon.ico"
  BrandingText "AMPP"

; The default installation directory
  InstallDir "$PROGRAMFILES\AMPP\"

  CRCCheck on
  ShowInstDetails hide
  
  SetCompress off

; Request application privileges for Windows Vista and Windows 7
  RequestExecutionLevel admin

; Includes

  !include "Registry.nsh" ; rejestr
  !include "FileFunc.nsh"
  
  !include "Sections.nsh" ; opcje sekcji
  !include "logiclib.nsh" ; operatory logiczne
  !include "nsProcess.nsh" ; sprawdzanie procesu
  !include "EnumUsersReg.nsh" ; reg hive
  !include "x64.nsh" ; wersje x64
  !include "StrFunc.nsh"
  !include "TextReplace.nsh" ; zamiana tekstu
  !include "ZipDLL.nsh" ; zip extractor
  !include "WriteToFile.nsh" ; write lines to file
  !include "StrRep.nsh" ; string replace
  !include "OpenLinkNewWindow.nsh" ; opens link in default wrobser

; Interface Settings
   
    
;--------------------------------
; Pages
  
  page license
  page components
  page directory
  page instfiles
  uninstpage uninstConfirm
  uninstpage instfiles
 
  page custom apache2-page-one  
  page custom mysql-page-one
  page custom mysql-page-two
  page custom mysql-page-three
  page custom ps-portal-summary
  
; Languages
 
;--------------------------------
;Variables

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
;Installer Sections

  Function LicenseShow ; przewijanie licencji
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
    ExecCmd::exec 'msiexec /i "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi" /qb! INSTALLDIR="$INSTDIR\apache2" SERVERNAME=$apache_server_name SERVERADMIN="admin@$ServName" ALLUSERS=1 RebootYesNo=No /L*V "$INSTDIR\Log\apach2.log"'
    
    DetailPrint "Konfiguruj apache HTTP Server..."
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "htdocs" "www-root" "/S=1 /C=1 /AO=1" $0
    ${textreplace::ReplaceInFile} "$INSTDIR\apache2\conf\httpd.conf" "$INSTDIR\apache2\conf\httpd.conf" "index.html" "index.html index.php" "/S=1 /C=1 /AO=1" $0
    
    ExecWait '"$INSTDIR\apache2\bin\httpd.exe" -k restart'
    
  FunctionEnd
  
  Function php_install
    SetOutPath "$TEMP\portal\"
    File "inst-files\php-5.3.28-Win32-VC9-x86.msi"
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
    File "inst-files\phpMyAdmin-4.0.9-english.zip"
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
    File "inst-files\mysql-5.6.15-win32.zip"
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
      File "inst-files\dotNetFx40_Full_x86_x64.exe"
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
    call apache_install
    call php_install
    call phpmyadmin_install
    call create_www
    call dotnet_install
    call mysql_install

    WriteUninstaller "$INSTDIR\un-ampp.exe"      
  SectionEnd

/** CUSTOM PAGES BEGiN **/

  Function apache2-page-one
    ${If} ${SectionIsSelected} ${section_two}
      ;ReserveFile "ps_portal-apache_page-1.ini"
      ;!insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL."
      ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT "ps_portal-apache_page-1.ini"
      ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ps_portal-apache_page-1.ini"
      
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R0 "ps_portal-apache_page-1.ini" "Field 3" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R1 "ps_portal-apache_page-1.ini" "Field 5" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R2 "ps_portal-apache_page-1.ini" "Field 7" "State"
      
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R3 "ps_portal-apache_page-1.ini" "Field 8" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R4 "ps_portal-apache_page-1.ini" "Field 9" "State"      

      StrCpy $apache_domain $R0
      StrCpy $apache_server_name $R1
      StrCpy $apache_admin_email $R2
      
      StrCmp $R0 "" mustcomplete
      StrCmp $R1 "" mustcomplete
      StrCmp $R2 "" mustcomplete
      
      ${If} $R3 == 0
        ${If} $R4 == 0
          MessageBox MB_OK|MB_ICONEXCLAMATION "Aby kontynuowaæ instalacjê wybierz port us³ugi apache2!"
          call apache2-page-one
        ${EndIf}
      ${EndIf}
      
      ${If} $R3 == 1
        StrCpy $apache_port "80"
      ${EndIf}
      
      ${If} $R4 == 1
        StrCpy $apache_port "8080"
      ${EndIf}
      
      Goto exit

      mustcomplete:
        MessageBox MB_OK|MB_ICONEXCLAMATION "Aby kontynuowaæ instalacjê nale¿y uzupe³niæ wszystkie pola!"
        call apache2-page-one   
      exit:
        Pop $R0
    ${EndIf}
  FunctionEnd

  Function mysql-page-one
    ${If} ${SectionIsSelected} ${section_two}
      ;ReserveFile "ps_portal-mysql_page-1.ini"
      ;!insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL."
      ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT "ps_portal-mysql_page-1.ini"
      ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ps_portal-mysql_page-1.ini"
      
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R0 "ps_portal-mysql_page-1.ini" "Field 1" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R1 "ps_portal-mysql_page-1.ini" "Field 2" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R2 "ps_portal-mysql_page-1.ini" "Field 3" "State"     
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R3 "ps_portal-mysql_page-1.ini" "Field 4" "State"
      
      StrCmp $R0 "" mustcomplete
      StrCmp $R1 "" mustcomplete
      StrCmp $R2 "" mustcomplete
      StrCmp $R3 "" mustcomplete
       
      ${If} $R2 != $R3
        Goto incorrect_passwd
      ${EndIf}

      StrCpy $mysql_service_name $R0
      StrCpy $mysql_port $R1
      StrCpy $mysql_passwd $R3
      
      Goto exit
      
      incorrect_passwd:
        MessageBox MB_OK|MB_ICONEXCLAMATION "Podane has³a ró¿ni¹ siê od siebie! Spróbuj ponownie!"
        call mysql-page-one      
      mustcomplete:
        MessageBox MB_OK|MB_ICONEXCLAMATION "Aby kontynuowaæ instalacjê nale¿y uzupe³niæ wszystkie pola!"
        call mysql-page-one   
      exit:
        Pop $R0      
    ${EndIf}
  FunctionEnd
  
  Function mysql-page-two
    StrCpy $R0 "0"
    StrCpy $R1 "0"
    StrCpy $R2 "0"
    
    ${If} ${SectionIsSelected} ${section_two}
      ;ReserveFile "ps_portal-mysql_page-2.ini"
      ;!insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL."
      ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT "ps_portal-mysql_page-2.ini"
      ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ps_portal-mysql_page-2.ini"
      
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R0 "ps_portal-mysql_page-2.ini" "Field 2" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R1 "ps_portal-mysql_page-2.ini" "Field 3" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R2 "ps_portal-mysql_page-2.ini" "Field 4" "State"
      
      ${If} $R0 == 1
        StrCpy $mysql_log_general "1"
      ${EndIf}
     
      ${If} $R1 == 1
        StrCpy $mysql_log_slow "1"
      ${EndIf}
      
      ${If} $R2 == 1
        StrCpy $mysql_log_bin "1"      
      ${EndIf}
      
    ${EndIf}
  FunctionEnd
  
  Function mysql-page-three
    ${If} ${SectionIsSelected} ${section_one}
      ;ReserveFile "ps_portal-mysql_page-3.ini"
      ;!insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL."
      ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT "ps_portal-mysql_page-3.ini"
      ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ps_portal-mysql_page-3.ini"
      
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R0 "ps_portal-mysql_page-3.ini" "Field 1" "State"
      ;!insertmacro MUI_INSTALLOPTIONS_READ $R1 "ps_portal-mysql_page-3.ini" "Field 2" "State"
     
      StrCmp $R0 "" mustcomplete
      StrCmp $R1 "" mustcomplete
     
      ${If} $R0 != $R1
        goto incorrect_passwd
      ${EndIf}
      goto exit
      
     incorrect_passwd:
        MessageBox MB_OK|MB_ICONEXCLAMATION "Podane has³a ró¿ni¹ siê od siebie! Spróbuj ponownie!"
        call mysql-page-three      
      mustcomplete:
        MessageBox MB_OK|MB_ICONEXCLAMATION "Aby kontynuowaæ instalacjê nale¿y uzupe³niæ wszystkie pola!"
        call mysql-page-three   
      exit:
        Pop $R0  
    ${EndIf}
  FunctionEnd
  
  Function ps-portal-summary
    ;ReserveFile "ps_portal-summary.ini"
    ;!insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL."
    ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT "ps_portal-summary.ini"
    ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ps_portal-summary.ini"
  FunctionEnd
  
/** CUSTOM PAGES END **/  

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