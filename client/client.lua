
local function openSubMenu(playerInfo)
    local menuOptions = {
        {
            title = "Retour",
            onSelect = function ()
                openWipeMenu()
            end
        },
        {
            title = "",
            readOnly = true,
        },
        {
            title = "Wipe le joueur",
            description = "Supprimer définitivement le joueur, il perdras tout !",
            onSelect = function()
                TriggerServerEvent('LeMWipe:wipePlayer', "all", playerInfo)
            end,
        },
        {
            title = "Wipe ses véhicules",
            description = "Supprimer l'intégralité des véhicule du joueur!",
            onSelect = function()
                TriggerServerEvent('LeMWipe:wipePlayer', "vehicle",  playerInfo)
            end,
        }
    }

    lib.registerContext({
        id = 'wipe-submenu',
        title = playerInfo.firstname.." "..playerInfo.lastname,
        options = menuOptions
    })
    
    lib.showContext('wipe-submenu')
end

local function subMenuSearch(resutlResearch)
    local wipeSearchPlayer = {}

    for i=1, #resutlResearch do
        local getPlayer = resutlResearch[i]
        local isOnline = resutlResearch.serverId or nil
        local descOprions = isOnline and "En ligne: ID "..isOnline or "Joueur hors ligne"

        table.insert(wipeSearchPlayer, {
            title = getPlayer.firstname.." "..getPlayer.lastname,
            description = descOprions,
            onSelect = function()
                openSubMenu(getPlayer)
            end,
        })
    end

    lib.registerContext({
        id = 'search-wipe-menu',
        title = 'Resultat de votre recherche',
        options = wipeSearchPlayer
    })

    lib.showContext('search-wipe-menu')
end

RegisterNetEvent("openWipeMenu", function ()
    local allRegisteredPlayer = lib.callback.await('LeMWipe:checkPlayersInDB', false)
    local wipeOptions = {
        {  
            title = "Recherche",
            onSelect = function ()
                local searchInput = lib.inputDialog('Recherche d\'un joueur', {'Nom RP / Prenom RP'})
                if searchInput and searchInput[1] then
                    local resutlResearch = searchPlayer(searchInput[1], allRegisteredPlayer)
                    if not resutlResearch or #resutlResearch == 0 then 
                        clNotify({
                            title = "Wipe Menu",
                            description = "Aucun nom ou prenom trouvé",
                            type  = "error"
                        })
                    else
                        subMenuSearch(resutlResearch)
                    end
                end
            end,
        }
    }

    for i=1, #allRegisteredPlayer do
        local getPlayer = allRegisteredPlayer[i]
        local isOnline = allRegisteredPlayer[i].serverId or nil
        local descOprions = isOnline and "En ligne: ID "..isOnline or "Joueur hors ligne"

        table.insert(wipeOptions, {
            title = getPlayer.firstname.." "..getPlayer.lastname,
            description = descOprions,
            onSelect = function()
                openSubMenu(getPlayer)
            end,
        })
    end


    lib.registerContext({
        id = 'wipe-menu',
        title = 'Menu WIPE',
        options = wipeOptions
    })

    lib.showContext('wipe-menu')
end)







