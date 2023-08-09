@echo off
echo Uninstall and Cleanup Zalo
echo.
if exist %localappdata%\ZaloPC\ ( echo ZaloPC .... found! ) else ( echo ZaloPC .... cannot found! )
if exist %localappdata%\zalo-updater\ ( echo zalo-updater .... found! ) else  (echo zalo-updater .... cannot found! )
if exist %appdata%\ZaloData\ ( echo ZaloData .... found! ) else ( echo ZaloData .... cannot found! )
echo.
echo Start Cleanup ... Please waiting.....!
echo.
echo Deleting ZaloPC
rmdir %localappdata%\ZaloPC\ /s /q
echo Deleting zalo-updater
rmdir %localappdata%\zalo-updater\ /s /q
echo Deleting ZaloData
rmdir %appdata%\ZaloData\ /s /q
echo.
echo Check again...
if exist %localappdata%\ZaloPC\ ( echo ZaloPC .... found! ) else ( echo ZaloPC .... cannot found! )
if exist %localappdata%\zalo-updater\ ( echo zalo-updater .... found! ) else  (echo zalo-updater .... cannot found! )
if exist %appdata%\ZaloData\ ( echo ZaloData .... found! ) else ( echo ZaloData .... cannot found! )
pause