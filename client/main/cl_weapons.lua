Citizen.CreateThread(function()
    Wait(1000)
    print('^4[BL_CORE] - DEBUG | WEAPON REPAIR LOADED')
    for i = 1, #Config.Weapon.coords do 
        local marker = lib.marker.new({
            type = Config.Weapon.marker.type,
            coords = Config.Weapon.coords[i].coords,
            color = Config.Weapon.marker.color,
        })
        local point = lib.points.new({
            coords = Config.Weapon.coords[i].coords,
            distance = Config.Weapon.marker.DrawDistance,
        })

        function point:nearby()
            marker:draw()
            if self.currentDistance < 1.5 then
                HelpUI('E', Config.Weapon.language.HelpUI)
                if IsControlJustPressed(0, 51) then  
                    if exports.ox_inventory:getCurrentWeapon() == nil then 
                        return Notify('BLACKLINE CITY', 'You have no weapon in your hand', 'error') 
                    end
                    if exports.ox_inventory:getCurrentWeapon().metadata.durability == 100 then 
                        return Notify('BLACKLINE CITY', 'Your weapon ['..exports.ox_inventory:getCurrentWeapon().name..'] cannot be repaired because it is not damaged!', 'warning') 
                    end
                    local getCurrentWeapon = exports.ox_inventory:getCurrentWeapon()
                    local weaponprice = 100 - getCurrentWeapon.metadata.durability
                    local price = weaponprice * 100
                    lib.registerContext({
                        id = 'repair_menu',
                        title = Config.Weapon.language.menu_title,
                        options = {
                          {
                            title = getCurrentWeapon.label,
                            description = 'Repair your weapon for '..price..'$ '..Config.Weapon.coords[i].money_label,
                            progress = getCurrentWeapon.metadata.durability,
                            colorScheme = '#1864AB',
                            icon = 'gun',
                            image = 'nui://ox_inventory/web/images/'..exports.ox_inventory:getCurrentWeapon().name..'.png',
                            onSelect = function()
                                local weapon = getCurrentWeapon.name
                                if lib.progressCircle({
                                    duration = Config.Weapon.progressbar.duration,
                                    position = 'bottom',
                                    useWhileDead = false,
                                    canCancel = true,
                                    disable = {
                                        car = true,
                                        move = true,
                                    },
                                    anim = {
                                        dict = 'mini@repair',
                                        clip = 'fixing_a_player'
                                    },
                                }) then 
                                    local account = lib.callback.await('bl_core:getMoney', false, Config.Weapon.coords[i].money)
                                    if account == nil then 
                                        return Notify('BLACKLINE CITY', 'An error occurred!', 'error') 
                                    end
                                    if account.money >= price then 
                                        TriggerServerEvent('bl_core:repairWeapon', getCurrentWeapon.slot, 100)
                                        TriggerServerEvent('bl_core:removeMoney', Config.Weapon.coords[i].money, price)
                                        Notify('BLACKLINE CITY', 'You repaired your weapon ['..exports.ox_inventory:getCurrentWeapon().name..'] for '..price..'$ '..Config.Weapon.coords[i].money_label..'!', 'success')
                                    else
                                        Notify('BLACKLINE CITY', 'You don’t have enough money! You are missing '..price-account.money..'$ '..Config.Weapon.coords[i].money_label, 'warning')
                                    end
                                else 
                                    Notify('BLACKLINE CITY', 'You cancelled repairing your weapon ['..exports.ox_inventory:getCurrentWeapon().name..']!', 'error')
                                end
                              end,
                          }
                        }
                    })
                    lib.showContext('repair_menu')
                end
            end
        end
    end
end)

function OpenWeaponMenu(getCurrentWeapon)
    lib.registerContext({
        id = 'repair_menu',
        title = Config.Weapon.language.menu_title,
        options = {
          {
            title = getCurrentWeapon.label,
            description = 'Repair your weapon for '..price..'$ Black Money',
            progress = getCurrentWeapon.metadata.durability,
            colorScheme = '#1864AB',
            icon = 'gun',
            image = 'nui://ox_inventory/web/images/'..exports.ox_inventory:getCurrentWeapon().name..'.png',
            onSelect = function()
                local weapon = getCurrentWeapon.name
                if lib.progressCircle({
                    duration = Config.Weapon.progressbar.duration,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                    },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_player'
                    },
                }) then 
                    local account = lib.callback.await('bl_core:getMoney', false, Config.Weapon.money)
                    if account.money >= price then 
                        TriggerServerEvent('bl_core:repairWeapon', getCurrentWeapon.slot, 100)
                        TriggerServerEvent('bl_core:removeMoney', 'black_money', price)
                        Notify('BLACKLINE CITY', 'You repaired your weapon ['..exports.ox_inventory:getCurrentWeapon().name..'] for '..price..'$ Black Money!', 'success')
                    else
                        Notify('BLACKLINE CITY', 'You don’t have enough money! You are missing '..price-account.money..'$ Black Money', 'warning')
                    end
                else 
                    Notify('BLACKLINE CITY', 'You cancelled repairing your weapon ['..exports.ox_inventory:getCurrentWeapon().name..']!', 'error')
                end
              end,
          }
        }
    })
    lib.showContext('repair_menu')
end