AMPP
====

AMPP - Apache2, MySQL, PHP, phpMyAdmin.

AMPP is an script written in NSIS (Nullsoft Scriptable Install System - http://nsis.sourceforge.net/).
It can be used to create easy to install HTTP server with PHP and MySQL extensions.
To handle MySQL administration phpMyAdmin package is also included.

AMPP script was created with:
* Apache2 2.2.25 (msi)
* MySQL 5.6.15 (zip)
* PHP 5.3.28 (msi)
* phpMyAdmin 4.0.9 (zip)

How-To
======

Because the 'zip' and 'msi' files are not included you have to download them manualy.
* Apache2 - http://httpd.apache.org/download.cgi
* MySQL - http://dev.mysql.com/downloads/mysql/
* PHP - http://windows.php.net/download/ (keep in mind that only 'thread safe' version is working with apache2!)
* phpMyAdmin - http://www.phpmyadmin.net/home_page/downloads.php

You have to put all downloaded files inside 'inst-files' folder. For MySQL database you will have download Microsoft .NET Framework 4.0 (http://www.microsoft.com/en-us/download/details.aspx?id=17718) and put it inside 'inst-files' folder as well.


Author
======
Marcin Szymkowski :: https://github.com/motoko-kusanagi
