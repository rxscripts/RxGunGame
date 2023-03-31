--[[
BY Rejox#7975 © RX
--]]

GlobalState[States.Global.GameActive] = false
GlobalState[States.Global.CurrentMap] = nil
GlobalState[States.Global.PlayersInGame] = 0
GlobalState[States.Global.RoundTimeLeft] = nil

GunGame = {}
GunGame.Players = {}

local finishing = false

function LeaveGunGame(src)
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
    finishing = true
    GlobalState[States.Global.GameActive] = false

    if not winnerId then
        Server.Notify(-1, "Nobody won the game!")
    else
        Server.Notify(-1, string.format("%s won the game!", GetPlayerName(winnerId)))
    end

    for src, player in pairs(GunGame.Players) do
        ShowScoreboard(src, true)
    end

    Wait(10000)

    for src, player in pairs(GunGame.Players) do
        HideBoard(src)
    end

    for src, player in pairs(GunGame.Players) do
        LeaveGunGame(src)
    end
    
    finishing = false
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

    LeaveGunGame(src)
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
        Server.Notify(killerId, string.format("You are now level %s!", currentKillerLevel + 1))
    end

    local currentVictimLevel = Server.GetCurrentLevel(victimId)

    if currentVictimLevel > 1 then
        Server.SetCurrentLevel(victimId, currentVictimLevel - 1)
        Server.Notify(victimId, string.format("You are now level %s!", currentVictimLevel - 1))
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        if not finishing and not GetIsGameActive() then
            startGame("Island")
        end 
    end
end)

Citizen.CreateThread(function()
    print("^2Successfully loaded ^9" .. GetCurrentResourceName() .. " ^2by ^9Rejox#7975 ^6(https://discord.gg/fyzcj8dAkq)")
end)