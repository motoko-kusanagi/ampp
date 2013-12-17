;General

;Name and file
  Name "PS PORTAL"
  OutFile "PS_PORTAL.exe"
  Caption "Predictive Solutions - PS PORTAL"
  Icon "icon\spss.ico"
  UninstallIcon "icon\un-spss.ico"
  BrandingText "PS PORTAL"

; The default installation directory
  InstallDir "$PROGRAMFILES\PS_PORTAL\"

  CRCCheck on
  ShowInstDetails hide
  
  SetCompress off

;Request application privileges for Windows Vista and Windows 7
  RequestExecutionLevel admin

;--------------------------------
;Include UltraModernUI

  !include "Registry.nsh" ; rejestr
  !include "FileFunc.nsh"
  !include "UMUI.nsh" ; interfejs
  !include "MUI.nsh" ; scroll licencji
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

;--------------------------------
;Interface Settings
    
  !define UMUI_SKIN "gray"
  
  !define UMUI_ULTRAMODERN_SMALL
  !define MUI_ICON "icon\spss.ico"
  !define MUI_UNICON "icon\un-spss.ico"
  ;!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\UltraModernUI\Skins\blue\Wizard.bmp"
  ;!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\UltraModernUI\Skins\blue\Wizard.bmp"
    
  !define UMUI_WELCOMEFINISHABORTPAGE_USE_IMAGE
    
  !define UMUI_PAGEBGIMAGE

  !define MUI_ABORTWARNING
  !define MUI_UNABORTWARNING

  !define UMUI_USE_ALTERNATE_PAGE
  !define UMUI_USE_UNALTERNATE_PAGE
    
;--------------------------------
;Pages
  !define MUI_TEXT_WELCOME_INFO_TITLE "Witamy w kreatorze instalacji systemu PS PORTAL – komponent kliencki."
  !define MUI_TEXT_WELCOME_INFO_TEXT "Ten kreator pomo¿e Ci zainstalowaæ system PS PORTAL – komponent kliencki. $\r$\n$\r$\nZalecane jest zamkniêcie wszystkich uruchomionych programów przed rozpoczêciem instalacji. Pozwoli to na uaktualnienie niezbêdnych plików systemowych bez koniecznioœci ponownego uruchamiania komputera$\r$\n$\r$\nKliknij Dalej, aby kontynuowaæ."

  !define MUI_COMPONENTSPAGE_SMALLDESC
  !insertmacro MUI_PAGE_WELCOME
  !define MUI_PAGE_CUSTOMFUNCTION_SHOW LicenseShow
  !insertmacro MUI_PAGE_LICENSE "license\licencja.txt"
  
  Page Custom MySQL_settings
  
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY  
  !define MUI_TEXT_COMPONENTS_SUBTITLE "Wybierz typ licencji dla instalowanego programu IBM SPSS Modeler."
  !define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "Skontaktuj siê z opiekunem licencji, je¿eli nie wiesz jakiego typu licencjê posiadasz."
  !insertmacro MUI_PAGE_INSTFILES

  !define MUI_TEXT_FINISH_INFO_REBOOT "Twój komputer musi zostaæ ponownie uruchomiony, aby zakoñczyæ instalacjê systemu PS PORTAL – komponent kliencki. Czy chcesz zrobiæ to teraz?"
  !define MUI_UNTEXT_FINISH_INFO_REBOOT "Twój komputer musi zostaæ ponownie uruchomiony, aby zakoñczyæ instalacjê systemu PS PORTAL – komponent kliencki. Czy chcesz zrobiæ to teraz?"
  !define MUI_UNTEXT_WELCOME_INFO_TEXT "Kreator poprowadzi Ciê poprzez proces deinstalacji systemu PS PORTAL – komponent kliencki.$\r$\n$\r$\nW wyniku procesu deinstalacji bezpowrotnie zostan¹ usuniête nastêpuj¹ce komponenty:$\r$\n- IBM SPSS Modeler 15.0 Client$\r$\n- IBM SPSS Modeler 15.0 Fix Pack"
  
  !define MUI_TEXT_FINISH_REBOOTLATER "Uruchomiê ponownie komputer póŸniej"
  
  !define UMUI_TEXT_ABORT_INFO_TITLE "Koñczenie deinstalacji systemu PS PORTAL – komponent kliencki."
  !define UMUI_TEXT_ABORT_INFO_TEXT "Praca instalatora systemu PS PORTAL komponent kliencki zosta³a przerwana przed zakoñczeniem instalcji.$\r$\n$\r$\nAby póŸniej zainstalowaæ system, proszê uruchomiæ instaltor ponownie.$\r$\n$\r$\n$\r$\n$\r$\nKliknij $(^CloseBtn) aby opuœciæ instalator."
  
  !define UMUI_UNTEXT_ABORT_INFO_TITLE "Koñczenie deinstalacji systemu PS PORTAL – komponent kliencki."
  !define UMUI_UNTEXT_ABORT_INFO_TEXT "Praca deinstalatora systemu PS PORTAL – komponent kliencki zosta³a przerwana przed zakoñczeniem deinstalcji.$\r$\n$\r$\nAby póŸniej odinstalowaæ system, proszê uruchomiæ deinstaltor ponownie.$\r$\n$\r$\n$\r$\n$\r$\nKliknij $(^CloseBtn) aby opuœciæ deinstalator."
  
  !define MUI_TEXT_LICENSE_SUBTITLE "Przed instalacj¹ programu PS PORTAL – komponent kliencki zapoznaj siê z warunkami licencji."
  !define MUI_INNERTEXT_LICENSE_BOTTOM "Niniejsze warunki zastêpuj¹ warunki licencji na sk³adniki Rozwi¹zania PS prezentowane w dalszej czêœci procesu instalacji. Akceptacja przedstawionych warunków jest niezbêdna do przeprowadzenia instalacji. Naciœnij przycisk Akceptujê, aby kontynuowaæ instalacjê."
  
  !define MUI_TEXT_FINISH_INFO_TITLE "Koñczenie pracy kreatora instalacji PS PORTAL"
  
  !define MUI_TEXT_INSTALLING_SUBTITLE "Proszê czekaæ, podczas gdy PS PORTAL"

  !insertmacro MUI_PAGE_FINISH

  !define UMUI_ABORTPAGE_LINK "Predictive Solutions"
  !define UMUI_ABORTPAGE_LINK_LOCATION "http://predictivesolutions.pl/"
  !insertmacro UMUI_PAGE_ABORT

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_INSTFILES
  
  !define MUI_FINISHPAGE_LINK "Predictive Solutions"
  !define MUI_FINISHPAGE_LINK_LOCATION "http://predictivesolutions.pl/"
  !insertmacro MUI_UNPAGE_FINISH

  !define UMUI_ABORTPAGE_LINK "Predictive Solutions"
  !define UMUI_ABORTPAGE_LINK_LOCATION "http://predictivesolutions.pl/"
  !insertmacro UMUI_UNPAGE_ABORT
    
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "Polish"

;--------------------------------
;Variables

  var RegVer
  var ServName
  
  var MySQL_Passwd
  var MySQL_Port
  var DataDir_Path
  var BaseDir_Path
  
;--------------------------------
;Installer Sections

  ${StrCase}
  
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

  Function .onInit ; podczas inicjacji okna
    SetRebootFlag true
    call registry_check
  FunctionEnd

  Function Apache
    ReadRegStr $0 HKLM "System\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"
    StrCpy $ServName $0
  
    SetOutPath "$TEMP\portal\"
    File "apache\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
    DetailPrint "Instaluj Apache HTTP Server..."
    ExecCmd::exec 'msiexec /i "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi" /qb! INSTALLDIR="$INSTDIR\Apache2" SERVERNAME=$ServName SERVERADMIN="admin@$ServName" ALLUSERS=1 RebootYesNo=No /L*V "$INSTDIR\Log\apach2.log"'
    
    ;StrCpy $replace_what "DocumentRoot "$INSTDIR\Apache2\htdocs""
    ;StrCpy $replace_with "DocumentRoot "$INSTDIR\Apache2\www-root""
    DetailPrint "Konfiguruj Apache HTTP Server..."
    ${textreplace::ReplaceInFile} "$INSTDIR\Apache2\conf\httpd.conf" "$INSTDIR\Apache2\conf\httpd.conf" "htdocs" "www-root" "/S=1 /C=1 /AO=1" $0
    ${textreplace::ReplaceInFile} "$INSTDIR\Apache2\conf\httpd.conf" "$INSTDIR\Apache2\conf\httpd.conf" "index.html" "index.html index.php" "/S=1 /C=1 /AO=1" $0
    
    ExecWait '"$INSTDIR\Apache2\bin\httpd.exe" -k restart'
    
  FunctionEnd
  
  Function PHP
    SetOutPath "$TEMP\portal\"
    File "php\php-5.3.28-Win32-VC9-x86.msi"
    DetailPrint "Instaluj PHP..."
    ExecCmd::exec 'msiexec /i "$TEMP\portal\php-5.3.28-Win32-VC9-x86.msi" /qb! INSTALLDIR="$INSTDIR\PHP" APACHEDIR="$INSTDIR\Apache2\conf" ADDLOCAL="ScriptExecutable,cgi,apache22,ext_php_mysqli,ext_php_mysql,ext_php_mbstring" /L*V "$INSTDIR\Log\php.log"'
  FunctionEnd

  Function CreateWWW
    SetOutPath "$INSTDIR\Apache2\www-root\"
    File "www\index.html"
    File "www\PS_PORTAL.png"
  FunctionEnd

  Function phpMyAdmin
    CreateDirectory "$INSTDIR\Apache2\www-root\"
    SetOutPath "$TEMP\portal\"
    File "www\phpMyAdmin-4.0.9-english.zip"
    DetailPrint "Instaluj phpMyAdmin..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\portal\phpMyAdmin-4.0.9-english.zip" "$INSTDIR\Apache2\www-root" "<ALL>"
    
    CreateDirectory "$INSTDIR\Apache2\www-root\debug"
    SetOutPath "$INSTDIR\Apache2\www-root\debug"
    File "www\system.php"
  FunctionEnd
  
  Function MySQL
    StrCpy $MySQL_PASSWD "spssspss1!"
    StrCpy $MySQL_PORT "3306"
    
    SetOutPath "$TEMP\portal\"
    File "mysql\mysql-5.6.15-win32.zip"
    DetailPrint "Instaluj MySQL Server..."
    !insertmacro ZIPDLL_EXTRACT "$TEMP\portal\mysql-5.6.15-win32.zip" "$INSTDIR\MySQL" "<ALL>"
    
    DetailPrint "Konfiguruj MySQL Server..."
    
    SetOutPath "$INSTDIR\MySQL"
    File "mysql-settings\my.ini"
    
    ${StrReplace} "$INSTDIR\MySQL" "\" "\\"
    StrCpy $BaseDir_Path $0
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "basedir-path" "$BaseDir_Path" "/S=1 /C=1 /AO=1" $0 ; replaces basedir path in my.ini config    
    
    ${StrReplace} "$INSTDIR\MySQL\data" "\" "\\"
    StrCpy $DataDir_Path $0
    ${textreplace::ReplaceInFile} "$INSTDIR\MySQL\my.ini" "$INSTDIR\MySQL\my.ini" "datadir-path" "$DataDir_Path" "/S=1 /C=1 /AO=1" $0 ; replaces datadir path in my.ini config
    
    DetailPrint "Instauj MySQL Server jako serwis..."
    ExecWait '"$INSTDIR\MySQL\bin\mysqld.exe" --install' ; mysql as a service
    
    DetailPrint "Uruchom us³ugê MySQL Server..."
    ExecWait '"net" start mysql' ; starts mysql service
    
    SetOutPath "$TEMP\portal\"
    File "mysql-settings\passwd.sql"
    ${textreplace::ReplaceInFile} "$TEMP\portal\passwd.sql" "$TEMP\portal\passwd.sql" "my-new-password" "$MySQL_PASSWD" "/S=1 /C=1 /AO=1" $0 ; replaces my-new-password with specific user password
    ExecCmd::exec '"$INSTDIR\MySQL\bin\mysql.exe" -u root < "$TEMP\portal\passwd.sql"' ; changes root password

  FunctionEnd
  
  Function dotNET
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" 'TargetVersion'
    ${If} $0 != "4.0.0"
      SetOutPath "$TEMP\portal\"
      File ".net\dotNetFx40_Full_x86_x64.exe"
      DetailPrint "Instaluj .NET Framework v.4.0..."
      ExecCmd::exec '"$TEMP\portal\dotNetFx40_Full_x86_x64.exe" /passive /norestart'
    ${EndIf}
  FunctionEnd
  
  Function CleanUpFiles
    Delete "$TEMP\portal\dotNetFx40_Full_x86_x64.exe"
    Delete "$TEMP\portal\mysql-5.6.15-win32.zip"
    Delete "$TEMP\portal\phpMyAdmin-4.0.9-english.zip"
    Delete "$TEMP\portal\php-5.3.28-Win32-VC9-x86.msi"
    Delete "$TEMP\portal\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"
  FunctionEnd

  Section "Instalacja standardowa" {section1}
  SectionEnd
  
  Section /o "Instalacja zaawansowana" {section2}
  SectionEnd

  Section "" main ; default section
    SetShellVarContext all

    CreateDirectory "$INSTDIR\Log"    
    call Apache
    call PHP
    call phpMyAdmin
    call CreateWWW
    call dotNET
    call MySQL

    ${OpenUrl} "localhost"

    ;call CleanUpFiles
    WriteUninstaller "$INSTDIR\PS_PORTAL_Uninstaller.exe"      
  SectionEnd

/** CUSTOM PAGES BEGiN **/
  
  Function MySQL_settings
    ;ReserveFile "pages\mysql_settings.ini"
    ;!insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL – komponent kliencki."
    ;!insertmacro MUI_INSTALLOPTIONS_EXTRACT "pages\mysql_settings.ini"
    ;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "pages\mysql_settings.ini"
  FunctionEnd
  
  Function summary
    ;MessageBox MB_OK "PODSUMOWANIE"
    ReserveFile "page_summary.ini"
    !insertmacro MUI_HEADER_TEXT "Informacje" "W wyniku tej instalacji zostanie zainstalowany system PS PORTAL – komponent kliencki."
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "page_summary.ini"
    !insertmacro MUI_INSTALLOPTIONS_DISPLAY "page_summary.ini"
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