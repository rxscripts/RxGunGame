--[[
BY Rejox#7975 © RX
--]]

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if Client.GetInGame() then
        TriggerServerEvent("sv_game:leaveGunGame")
    end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
        if not IsEntityAPed(victim) or not IsEntityAPed(attacker) or not IsPedAPlayer(victim) or not IsPedAPlayer(attacker) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
            if Client.GetInGame() then
                OnDeath(victim, attacker)
            end
        end
    end
end)