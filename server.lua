ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local onTimer       = {}
local savedCoords   = {}
local warnedPlayers = {}
local deadPlayers   = {}


RegisterCommand("reportar", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
  if onTimer[source] and onTimer[source] > GetGameTimer() then
      local timeLeft = (onTimer[source] - GetGameTimer()) / 1000
      TriggerServerEvent('pama_reports:reportar')
      TriggerClientEvent('chatMessage', xPlayer.source, _U('report_cooldown', tostring(ESX.Math.Round(timeLeft))))
      return
  end
  if args[1] then
      local message = string.sub(rawCommand, 8)
      local xAll = ESX.GetPlayers()
      for i=1, #xAll, 1 do
            local xTarget = ESX.GetPlayerFromId(xAll[i])
            if havePermission(xTarget) then		
              if xPlayer.source ~= xTarget.source then
                  TriggerClientEvent('chatMessage', xTarget.source, _U('report', xPlayer.source, message))
              end
            end
      end
      TriggerClientEvent('chatMessage', xPlayer.source, _U('report', xPlayer.source, message))
      onTimer[source] = GetGameTimer() + (Config.reportCooldown * 1000)
  else
      TriggerClientEvent('chatMessage', xPlayer.source, _U('invalid_input', 'REPORT'))
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


RegisterServerEvent('pama_admin:reportar')
AddEventHandler('pama_admin:reportar', function()
    print('Log mandado')
	local _source = source
		local connect = {
			{
				["color"] = "16753920",
				["title"] = 'Moderador: '.. '['..GetPlayerName(_source).. ']',
				["description"] = 'Abre el menu Moderador',
				["footer"] = {
				["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
				["icon_url"] = "",
				},
			}
		}
	PerformHttpRequest(Config.webhook, function(err, text, headers) end, 'POST', json.encode({username = "Me gusta tu abuela", embeds = connect, avatar_url = 'https://i.ibb.co/nPm4bLq/Logo-Tienda-Prueba.gif'}), { ['Content-Type'] = 'application/json' })
end)