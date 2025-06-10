@echo off
set CONTAINER=cs1.6_server-plugin

echo Verificando plugins e configs dentro do container %CONTAINER%...

docker exec %CONTAINER% bash -c ^
"echo '=== plugins.ini ===' && ls -l /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini && cat /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini && ^
echo '=== galileo.amxx ===' && ls -l /home/steam/hlds/cstrike/addons/amxmodx/plugins/galileo.amxx && ^
echo '=== galileo.cfg ===' && ls -l /home/steam/hlds/cstrike/addons/amxmodx/configs/galileo.cfg && cat /home/steam/hlds/cstrike/addons/amxmodx/configs/galileo.cfg && ^
echo '=== Últimas 30 linhas plugins.log ===' && tail -n 30 /home/steam/hlds/cstrike/addons/amxmodx/logs/plugins.log || echo 'plugins.log não encontrado' && ^
echo '=== Últimas 30 linhas amxmodx.log ===' && tail -n 30 /home/steam/hlds/cstrike/addons/amxmodx/logs/amxmodx.log || echo 'amxmodx.log não encontrado'"

pause
