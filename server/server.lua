local ESX = exports["es_extended"]:getSharedObject()

local function dropTableForWipe(identifierTarget)
    MySQL.rawExecute('DELETE FROM users WHERE identifier = ?', { identifierTarget })
    MySQL.rawExecute('DELETE FROM user_licenses WHERE id = ?', { identifierTarget })
    MySQL.rawExecute('DELETE FROM billing WHERE identifier = ?', { identifierTarget })
    MySQL.rawExecute('DELETE FROM banking WHERE identifier = ?', { identifierTarget })
    MySQL.rawExecute('DELETE FROM owned_vehicles WHERE identifier = ?', { identifierTarget })

    --MySQL.rawExecute('DELETE FROM owned_properties WHERE identifier = ?', { identifierTarget })
end

local function banFunction(src, msg)
    if not Shared.Anticheat then
        DropPlayer(src, msg)
    elseif Shared.Anticheat == "fiveguard" then
        exports[Shared.AnticheatRessourceName]:fg_BanPlayer(src, msg , true )
    else
        print("Your anticheat name is not add by defautl, add your export un server/server.lua")
    end
end

lib.callback.register('LeMWipe:checkPlayersInDB', function(source)
    local playersTable = {}
    local playersInfos = MySQL.query.await('SELECT `identifier`, `firstname`, `lastname` FROM `users`', {})
    local xPlayers = ESX.GetExtendedPlayers() 
    local serverId = {}

    for _, xPlayer in pairs(xPlayers) do
        serverId[xPlayer.identifier] = xPlayer.source
    end

    if playersInfos then
        for i = 1, #playersInfos do
            local row = playersInfos[i]
            table.insert(playersTable, {
                identifier = row.identifier,
                firstname = row.firstname,
                lastname = row.lastname,
                serverId = serverId[row.identifier] or nil
            })
        end
    end

    return playersTable
end)

RegisterNetEvent("LeMWipe:wipePlayer", function (action, playerInfos)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not playerInfos or not action or type(playerInfos) ~= "table" then return print("playerInfos params its not a table or its nil") end

    if xPlayer.getGroup() == "user" then 
        banFunction(src, "Execution d'un event via un LUA Exectutor (Wipe Menu)")
        return
    end

    if action == "all" then
        dropTableForWipe(playerInfos.identifier)
        if playerInfos.serverId then
            DropPlayer(playerInfos.serverId, "Vous avez été WIPE, reconnectez-vous pour crée un nouveau personnage")
        end
        TriggerClientEvent("LeM:ServerNotify", src, {
            title = "Wipe Menu",
            description = "Vous avez WIPE "..playerInfos.firstname.." "..playerInfos.lastname
        })
    elseif action == "vehicle" then
        MySQL.rawExecute('DELETE FROM owned_vehicles WHERE owner = ?', { playerInfos.identifier }, 
        function(response)
            if playerInfos.serverId then
                TriggerClientEvent("LeM:ServerNotify", src, {
                    title = "Wipe Menu",
                    description = "Tout les véhicules que vous possédez vous on été supprimé par un membre du staff, si vous pensez que cela est un erreur, ouvrez un ticket sur notre Discord"
                })
            end
            TriggerClientEvent("LeM:ServerNotify", src, {
                title = "Wipe Menu",
                description = "L'intégralité des véhicule du joueur on été supprimé, total ("..response.affectedRows..")"
            })
        end)    
    end
end)

-------------------------------------------------------------------

lib.addCommand('wipeMenu', {
    help = 'Accéder au menu WIPE',
    restricted = 'group.admin'
}, 
function(source, args, raw)
    TriggerClientEvent("openWipeMenu", source)
end)