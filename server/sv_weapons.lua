local USING_QBX    = GetResourceState('qbx_core') == 'started'
local USING_QBCORE = GetResourceState('qb-core')  == 'started'

-- ox_lib callback: return { money = <number> } for given account key
lib.callback.register('bl_core:getMoney', function(source, accountKey)
    accountKey = accountKey or 'money'

    if USING_QBX then
        local player = exports.qbx_core:GetPlayer(source)
        if not player then return { money = 0 } end

        if accountKey == 'money' or accountKey == 'cash' then
            return { money = player.PlayerData.money.cash or 0 }
        elseif accountKey == 'bank' then
            return { money = player.PlayerData.money.bank or 0 }
        elseif accountKey == 'black_money' then
            local bm = (player.PlayerData.money.black_money or 0)
            return { money = bm }
        else
            return { money = 0 }
        end

    elseif USING_QBCORE then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return { money = 0 } end

        if accountKey == 'money' or accountKey == 'cash' then
            return { money = player.Functions.GetMoney('cash') or 0 }
        elseif accountKey == 'bank' then
            return { money = player.Functions.GetMoney('bank') or 0 }
        elseif accountKey == 'black_money' then
            return { money = player.Functions.GetMoney('black_money') or 0 }
        else
            return { money = 0 }
        end
    end

    return { money = 0 }
end)

RegisterNetEvent('bl_core:removeMoney', function(accountKey, amount)
    local src = source
    accountKey = accountKey or 'money'
    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    if USING_QBX then
        local player = exports.qbx_core:GetPlayer(src)
        if not player then return end

        if accountKey == 'money' or accountKey == 'cash' then
            exports.qbx_core:RemoveMoney(src, 'cash', amount, 'weapon-repair')
        elseif accountKey == 'bank' then
            exports.qbx_core:RemoveMoney(src, 'bank', amount, 'weapon-repair')
        elseif accountKey == 'black_money' then
            if player.PlayerData.money.black_money and player.PlayerData.money.black_money >= amount then
                player.PlayerData.money.black_money = player.PlayerData.money.black_money - amount
            end
        end

    elseif USING_QBCORE then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(src)
        if not player then return end

        if accountKey == 'money' or accountKey == 'cash' then
            player.Functions.RemoveMoney('cash', amount, 'weapon-repair')
        elseif accountKey == 'bank' then
            player.Functions.RemoveMoney('bank', amount, 'weapon-repair')
        elseif accountKey == 'black_money' then
            player.Functions.RemoveMoney('black_money', amount, 'weapon-repair')
        end
    end
end)

RegisterNetEvent('bl_core:repairWeapon', function(slot, durability)
    local src = source
    slot = tonumber(slot)
    durability = tonumber(durability) or 100
    if not slot then return end

    -- ox_inventory durability setter
    exports.ox_inventory:SetDurability(src, slot, durability)
end)