ESX = nil
local _CreateThread, _RegisterServerEvent = CreateThread, RegisterServerEvent

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.OLDESX then 
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local onTimer       = {}

RegisterCommand("report", function(source, args, rawCommand)    -- /report [MESSAGE]        send report message to all online admins
    local xPlayer = ESX.GetPlayerFromId(source)
  if onTimer[source] and onTimer[source] > GetGameTimer() then
      local timeLeft = (onTimer[source] - GetGameTimer()) / 1000
      xPlayer.triggerEvent('chatMessage', _U('report_cooldown', tostring(ESX.Math.Round(timeLeft))))
      return
  end
  if args[1] then
      local message = string.sub(rawCommand, 8)
      local xAll = ESX.GetPlayers()
      for i=1, #xAll, 1 do
            local xTarget = ESX.GetPlayerFromId(xAll[i])
            if havePermission(xTarget) then        -- you can exclude some ranks to NOT reciveing reports
              if xPlayer.playerId ~= xTarget.playerId then
                  xTarget.triggerEvent('chatMessage', _U('report', GetPlayerName(source), xPlayer.playerId, message))
              end
            end
      end  -- LOGS DISCORD --
              local logs = ""
              local communityname = "Logs"
              local communtiylogo = "" --Must end with .png or .jpg
              local connect = {
              {
              ["color"] = "16711680",
              ["title"] = "Reportes",
              ["description"] = "Jugador: **"..GetPlayerName(source).."**\nID: **"..xPlayer.playerId.."**\n Msg: **"..message.."**",
              ["footer"] = {
              ["text"] = communityname,
              ["icon_url"] = communtiylogo,
              },
              }}
              PerformHttpRequest(Config.webhook, function(err, text, headers) end, 'POST', json.encode({username = "Reportes", embeds = connect}), { ['Content-Type'] = 'application/json' })
      xPlayer.triggerEvent('chatMessage', _U('report', GetPlayerName(source), xPlayer.playerId, message))
      onTimer[source] = GetGameTimer() + (Config.reportCooldown * 1000)
  else
      xPlayer.triggerEvent('chatMessage', _U('invalid_input', 'REPORT'))
  end
end, false)

function havePermission(xPlayer, exclude)	
	if exclude and type(exclude) ~= 'table' then exclude = nil;print("^3[Reportes] ^1ERROR ^0exclude argument is not table..^0") end

	local playerGroup = xPlayer.getGroup()
	for k,v in pairs(Config.adminRanks) do
		if v == playerGroup then
			if not exclude then
				return true
			else
				for a,b in pairs(exclude) do
					if b == v then
						return false
					end
				end
				return true
			end
		end
	end
	return false
end

_CreateThread(function()
    local name = "[^4pama_reports^7]"
    checkVersion = function(error, latestVersion, headers)
        local currentVersion = Config.scriptVersion            
        
        if tonumber(currentVersion) < tonumber(latestVersion) then
            print(name .. " ^1esta desactualizado.\nTu versión: ^8" .. currentVersion .. "\nVersión nueva: ^2" .. latestVersion .. "\n^3Actualiza^7: https://github.com/pamacinco/pama_reports")
        elseif tonumber(currentVersion) > tonumber(latestVersion) then
            print(name .. " te saltaste una version ^2" .. latestVersion .. ". o github esta offline o cambiaste el archivo de versions.")
        else
            print(name .. " esta en la version correspondiente.")
            print(name.. [[
                Versión: 1.0
                - Se añadieron los logs en discord
                - Se optimizo el script
            ]])
        end
    end

    PerformHttpRequest("https://raw.githubusercontent.com/pamacinco/versions/master/report_version.txt", checkVersion, "GET")
end)