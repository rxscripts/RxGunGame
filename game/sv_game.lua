--[[
BY Rejox#7975 © RX
--]]

GlobalState[States.Global.GameActive] = false
GlobalState[States.Global.CurrentMap] = nil
GlobalState[States.Global.PlayersInGame] = 0
GlobalState[States.Global.RoundTimeLeft] = nil

GunGame = {}
GunGame.Players = {}

local function leaveGunGame(src)
    if GunGame.Players[src] then
        GunGame.Players[src] = nil
    end

    TriggerClientEvent("cl_game:leaveGunGame", src)
    Wait(300)

    SetPlayerRoutingBucket(src, Config.DefaultRoutingBucket)

    Server.SetInGame(src, false)
    Server.UpdatePlayersInGame(-1)
    Database.UpdatePlayerStats(src)
    Server.ResetPlayerStates(src)
end 

local function finishGame(winnerId)
    if not winnerId then
        TriggerClientEvent("chat:addMessage", -1, { args = { "^1GunGame", "Nobody won the game!" } })
    else
        TriggerClientEvent("chat:addMessage", -1, { args = { "^1GunGame", GetPlayerName(winnerId) .. " won the game!" } })
    end

    for src, player in pairs(GunGame.Players) do
        leaveGunGame(src)
    end
    
    GlobalState[States.Global.GameActive] = false
end

local function startGame(map)
    GlobalState[States.Global.CurrentMap] = map
    GlobalState[States.Global.PlayersInGame] = 0
    GlobalState[States.Global.RoundTimeLeft] = Config.Maps[map].RoundTime
    GlobalState[States.Global.GameActive] = true

    CreateThread(function()
        while GetIsGameActive() and GetRoundTimeLeft() > 0 do
            Wait(1000)
            GlobalState[States.Global.RoundTimeLeft] = GlobalState[States.Global.RoundTimeLeft] - 1
        end

        finishGame()
    end)
end

RegisterNetEvent("sv_game:joinGunGame", function ()
    local src = source
    
    if not GunGame.Players[src] then
        GunGame.Players[src] = true
    end

    Server.ResetPlayerStates(src)

    TriggerClientEvent("cl_game:joinGunGame", src)
    Wait(300)

    SetPlayerRoutingBucket(src, Config.GunGameRoutingBucket)

    Server.SetInGame(src, true)
    Server.UpdatePlayersInGame(1)
end)

RegisterNetEvent("sv_game:leaveGunGame", function ()
    local src = source

    leaveGunGame(src)
end)

RegisterNetEvent("sv_game:onDeath", function(victimId, killerId)
    Server.SetKills(killerId, Server.GetKills(killerId) + 1)
    Server.SetDeaths(victimId, Server.GetDeaths(victimId) + 1)

    local currentKillerLevel = Server.GetCurrentLevel(killerId)

    if currentKillerLevel == #Config.Levels then
        finishGame(killerId)
        return
    end

    if currentKillerLevel < #Config.Levels then
        Server.SetCurrentLevel(killerId, currentKillerLevel + 1)
    end

    local currentVictimLevel = Server.GetCurrentLevel(victimId)

    if currentVictimLevel > 1 then
        Server.SetCurrentLevel(victimId, currentVictimLevel - 1)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        if not GetIsGameActive() then
            startGame("Island")
        end 
    end
end)

Citizen.CreateThread(function()
    print("^2Successfully loaded ^9GunGame_RX ^2by ^9Rejox#7975 ^6(https://discord.gg/fyzcj8dAkq)")
end)