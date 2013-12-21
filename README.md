AMPP
====

AMPP - Apache2, MySQL, PHP, phpMyAdmin.

AMPP is an script written in [NSIS] (Nullsoft Scriptable Install System - http://nsis.sourceforge.net/).
It can be used to create easy to install HTTP server with PHP and MySQL extensions. To handle MySQL administration phpMyAdmin package is also included.

AMPP script is based on:
* Apache2 2.2.25 (msi)
* MySQL 5.6.15 (zip)
* PHP 5.3.28 (msi)
* phpMyAdmin 4.0.9 (zip)

How-To
======

Because the 'zip' and 'msi' files are not included you have to download them manualy and put them inside **inst-files** folder.
* [Apache2] (http://httpd.apache.org/download.cgi)
* [MySQL] (http://dev.mysql.com/downloads/mysql/) (for MySQL database you will have download [Microsoft .NET Framework 4.0] (http://www.microsoft.com/en-us/download/details.aspx?id=17718) and put it inside "inst-files" folder as well)
* [PHP] (http://windows.php.net/download/) (only 'thread safe' version is working with apache2!)
* [phpMyAdmin] (http://www.phpmyadmin.net/home_page/downloads.php)


Keep in mind that if version of your Apache2, MySQL, PHP or phpMyAdmin is different you have to edit one or all of those lines:
* `File "inst-files\httpd-2.2.25-win32-x86-openssl-0.9.8y.msi"`
* `File "inst-files\php-5.3.28-Win32-VC9-x86.msi"`
* `File "inst-files\phpMyAdmin-4.0.9-english.zip"`
* `File "inst-files\mysql-5.6.15-win32.zip"`
* `File "inst-files\dotNetFx40_Full_x86_x64.exe"`

To compile this script you have to download [NSIS] (http://nsis.sourceforge.net/Download). After installation copy all files from **nsis-include** into your **NSIS\Include** directory.
