function searchPlayer(enteredInput, searchInTable)
    local resultReturn = {}
    
    for _, player in ipairs(searchInTable) do
        if string.lower(enteredInput) == (string.lower(player.firstname) or string.lower(player.lastname)) then
            table.insert(resultReturn, player)
        end
    end
    
    print(json.encode(resultReturn))
    return resultReturn or false
end

function clNotify(data)
    lib.notify({
        title = data.title or "Notification",
        description = data.description or "Aucune donnée",
        position = data.position or "top-right",
        type = data.type or "inform",
        duration = data.duration or 5000
    })
end

RegisterNetEvent("LeM:ServerNotify", function(data)
    clNotify(data)
end)