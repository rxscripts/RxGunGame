--[[
BY Rejox#7975 © RX
--]]

local zone = nil

function InitializeZone()
    if zone ~= nil then
        return
    else
        zone = {}
    end

    local currentMap = GetCurrentMap()

    zone = PolyZone:Create(currentMap.Zone, { 
        name = currentMap.Label,
        minZ = 0,
        maxZ = 150,
        debugPoly = true,
        debugColors = {
            walls = { 255, 0, 0 },
            outline = { 0, 0, 0 },
            grid = { 0, 255, 0 },
        }
    })

    zone:onPlayerInOut(function(inside, point)
        if inside then
            Client.SetOutsideZone(false)

            StopScreenEffect("Rampage")
        else
            Client.SetOutsideZone(true)

            StartScreenEffect("Rampage", 0, false)

            local maximumOutOfZoneTime = GetCurrentMap().MaximumOutOfZoneTime

            CreateThread(function()
                while maximumOutOfZoneTime > 0 and Client.GetInGame() and Client.GetOutsideZone() do
                    Wait(0)
                    DrawScreenText("~s~Leaving GunGame in ~r~" .. maximumOutOfZoneTime .. " ~s~seconds", 0.5, 0.83, 0.7, 4, true, true)
                end
            end)
        
            CreateThread(function()
                while maximumOutOfZoneTime > 0 and Client.GetInGame() and Client.GetOutsideZone() do
                    Wait(1000)
                    maximumOutOfZoneTime = maximumOutOfZoneTime - 1
                end
    
                if Client.GetInGame() and Client.GetOutsideZone() then
                    TriggerServerEvent("sv_game:leaveGunGame")
                    Wait(100)
                    StopScreenEffect("Rampage")
                end
            end)
        end
    end)
end

function DeleteZone()
    if zone then
        zone:destroy()
        zone = nil
    end
end