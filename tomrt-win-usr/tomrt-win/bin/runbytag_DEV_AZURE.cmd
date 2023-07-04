@echo off

set OPEN_REPORTS_IN_BROWSER_FLAG=0

set TOMRT_HOME=c:\tomrt-win
set CART_HOME=%TOMRT_HOME%\cart
set CART_LIB_DIR=%CART_HOME%\lib
set JAVA_HOME=%TOMRT_HOME%\bamboo-agent\jdk1.8.0_144
rem set TOMCART_WS=c:\tomwork\tom-tests
set TOMCART_WS=c:\tomwork\cart-tests
set CHROME_BIN="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
set ENV_PROPS=TOM_DEV_AZURE
set SSH_PATH=C:\Users\gummarajum\.ssh\azure\gs_app_docker_key
set REPLACE_VBS_PATH=C:\tomrt-win\cart\conf
set EXTENT_REPORT_PATH=%TOMCART_WS%\testout\report\summary\ExtentReports.html


set PATH=%JAVA_HOME%\bin;%PATH%
set TOMCART_HOME=%TOMRT_HOME%\cart
set PICKLESDOC_HOME=%TOMCART_HOME%\Pickles-exe-2.16.2
set PICKLESDOC_OPTS=--feature-directory=.\demo --output-directory=.\docs --system-under-test-name=TOM_Project_R3 --system-under-test-version=3.0 --include-experimental-features --test-results-format=cucumberjson --link-results-file=report\summary\*.json

setlocal enableextensions

echo cd %TOMCART_WS%
cd %TOMCART_WS%

rmdir testout /s /q
mkdir testout\docs
mkdir testout\report
mkdir testout\evidence

set TOMCART_LIB_DIR=%TOMCART_WS%\lib
set CLASSPATH=%JAVA_HOME%\jre\lib;%JAVA_HOME%\jre\lib\ext;.

%JAVA_HOME%\bin\java -Dwebdriver.chrome.headless=false -Dtomcart.env.name=%ENV_PROPS% -Dtomcart.ssh.key.path=%SSH_PATH% -cp %CART_LIB_DIR%\shared\bcprov-jdk15on-1.56.jar;%CART_LIB_DIR%\shared\bcpkix-jdk15on-1.56.jar;%CART_LIB_DIR%\cart-bdd.jar com.eastspring.tom.cart.bdd.Main --plugin html:testout/report/summary --plugin json:testout/report/summary/report.json --tags %1 %2 %3 %4 %5 %6 %7 %8 %9

rem %PICKLESDOC_HOME%\Pickles.exe %PICKLESDOC_OPTS%

rem %CHROME_BIN% %TOMCART_WS%\testout\docs\index.html
rem %CHROME_BIN% %TOMCART_WS%\testout\report\summary\index.html



cscript %REPLACE_VBS_PATH%\replace.vbs %EXTENT_REPORT_PATH% "<title>ExtentReports</title>" "<title>CART-AUTOMATION</title>"
cscript %REPLACE_VBS_PATH%\replace.vbs %EXTENT_REPORT_PATH% "<span class='report-name'>ExtentReports</span>" "<span class='report-name'>ENVIRONMENT: %ENV_PROPS%</span>"

%CHROME_BIN% %EXTENT_REPORT_PATH%


endlocal


