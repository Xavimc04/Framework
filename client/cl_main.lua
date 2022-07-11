Core = {}
Core.PlayerLoaded = false 
Core.PlayerData = nil 
Core.PickUps = {} 
Core.Functions = {} 
Core.SvPlayers = {} 
Core.Callbacks = {}
Core.RegisteredItems = {}
Events = {}

-- @ Pickups loop
CreateThread(function()
    while true do
        local msec = 1000 
        
        if Core.PlayerLoaded then 
            local Player = PlayerPedId()
            local pCoords = GetEntityCoords(Player) 
    
            for i,v in pairs(Core.PickUps) do  
                if #(pCoords - v.coords.xyz) < 2.5 then  
                    msec = 0

                    local label = Core.Functions.GetItemLabel(v.value) or v.value   

                    if Core.Functions.GetItemData(v.value) then
                        if Core.Functions.GetItemData(v.value).specialId then  
                            label = Core.Functions.GetItemLabel(v.value)..'~w~ (~p~'..v.complete.identifier..'~w~)'
                        end 
                    end

                    Core.Functions.FloatingText('Presiona ~p~E~w~ para coger ~p~'..label, vector3(v.coords.x, v.coords.y, v.coords.z - 0.7))

                    if IsControlJustPressed(0, 38) then 
                        TriggerServerEvent('core:deletePickUp', i, v, v.object) 
                        Core.Functions.PlayAnimation('pickup_object', 'pickup_low', 2000) 
                        Wait(2000)
                    end
                end
            end
        end

        Wait(msec) 
    end
end)

-- @ Main loop
-- @ Don't touch the wait, pls...
CreateThread(function()
    while true do
        local msec = 1000
        local Player = PlayerPedId()

        -- @ Set bullets when shooting and remove weapon if does not exist...
        if IsPedArmed(Player, 4) then
            msec = 10
            if IsPedShooting(Player) then  
                local weaponFounded = false 

                for i,v in pairs(Core.Glovebox) do 
                    if v.using then 
                        weaponFounded = true 
                        local newBullets = GetPedAmmoByType(Player, GetPedAmmoTypeFromWeapon(Player, GetHashKey(v.data.item)))
                        TriggerServerEvent(Events['core:setWeaponComponent'], v.data.slot, 'bullets', newBullets)
                        Core.Functions.Glovebox().ModifyBulletsFromSlot(i, newBullets)
                    end
                end

                if not weaponFounded then  
                    RemoveAllPedWeapons(PlayerPedId(), false)
                end
            end
        end 

        -- @ Anti get weapons
        if IsPedArmed(Player, 4) then
            local weaponFounded = false 

            for i,v in pairs(Core.Glovebox) do 
                if v.using then 
                    weaponFounded = true
                end
            end

            if not weaponFounded then  
                RemoveAllPedWeapons(PlayerPedId(), false)
            end
        end

        -- onPlayerDeath 
        if IsEntityDead(Player) or IsPlayerDead(Player) then
            Core.Functions.KillPlayer()
        end 

        Wait(msec)
    end
end)

-- @import
getCoreData = function()
    return Core 
end

-- @securityEvents
RegisterNetEvent('fm_security:sync', function(ev)
    Events = ev
end)