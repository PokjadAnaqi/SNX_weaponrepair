Config = Config or {}
local W = Config.Weapon
if not W then
    print('^1[SNX_weaponrepairv2] Config.Weapon missing!^7')
    return
end

-- =========================
-- NOTIFY / HELP UI
-- =========================
local function normalizeType(t)
    t = tostring(t or 'inform'):lower()
    if t == 'info' or t == 'information' then return 'inform' end
    if t == 'warn' then return 'warning' end
    if t ~= 'inform' and t ~= 'success' and t ~= 'error' and t ~= 'warning' then
        return 'inform'
    end
    return t
end

local function Notify(title, msg, typ, duration)
    typ = normalizeType(typ)
    duration = tonumber(duration) or 5000

    local ok_lib = pcall(function()
        lib.notify({
            title = title or 'Notice',
            description = msg or '',
            type = typ,
            duration = duration
        })
    end)
    if ok_lib then return end

    local ok_okok = pcall(function()
        exports['okokNotify']:Alert(title or 'Notice', msg or '', duration, typ)
    end)
    if ok_okok then return end

    print(('[Notify][fallback] (%s) %s - %s'):format(typ, tostring(title or ''), tostring(msg or '')))
end

local function HelpUI(key, msg)
    lib.showTextUI(('[%s] %s'):format(key, msg))
end
local function HideHelpUI()
    lib.hideTextUI()
end

-- =========================
-- OX_TARGET / BENCH SUPPORT
-- =========================
local spawnedBenches = {}
local hasOxTarget = (GetResourceState('ox_target') == 'started')

local function spawnBenchAt(cfg)
    if not cfg.bench or not cfg.bench.enabled then return nil end
    local model = cfg.bench.model
    if not model then return nil end

    local pos = cfg.coords + (cfg.bench.offset or vec3(0,0,0))
    local hdg = cfg.bench.heading or 0.0

    lib.requestModel(model, 5000)
    local obj = CreateObject(model, pos.x, pos.y, pos.z, false, false, false)
    if not obj or obj == 0 then return nil end

    SetEntityHeading(obj, hdg)
    PlaceObjectOnGroundProperly(obj)
    if cfg.bench.freeze ~= false then FreezeEntityPosition(obj, true) end
    if cfg.bench.invincible ~= false then SetEntityInvincible(obj, true) end
    SetEntityAsMissionEntity(obj, true, true)

    spawnedBenches[#spawnedBenches+1] = obj
    return obj
end

-- =========================
-- REPAIR MENU (COMMON)
-- =========================
local function openRepairMenuForCoord(repairCfg)
    local cur = exports.ox_inventory:getCurrentWeapon()
    if not cur then
        return Notify(W.language.city, W.language.no_weapon, 'error')
    end

    local durability = (cur.metadata and cur.metadata.durability) or 0
    if durability >= 100 then
        return Notify(W.language.city, W.language.not_damaged:format(cur.name or 'Weapon'), 'warning')
    end

    local weaponprice = math.max(0, 100 - durability)
    local price = weaponprice * 100
    local moneyType  = repairCfg.money
    local moneyLabel = repairCfg.money_label

    lib.registerContext({
        id = 'repair_menu',
        title = W.language.menu_title,
        options = {
            {
                title = cur.label or cur.name or 'Weapon',
                description = ('Repair your weapon for %s %s'):format(price, moneyLabel),
                progress = durability,
                icon = 'gun',
                image = ('nui://ox_inventory/web/images/%s.png'):format(cur.name),
                onSelect = function()
                    if lib.progressCircle({
                        duration = W.progressbar.duration,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = { car = true, move = true },
                        anim = { dict = 'mini@repair', clip = 'fixing_a_player' },
                    }) then
                        local account = lib.callback.await('bl_core:getMoney', false, moneyType)
                        if not account or type(account.money) ~= 'number' then
                            return Notify(W.language.city, W.language.error, 'error')
                        end

                        if account.money >= price then
                            TriggerServerEvent('bl_core:repairWeapon', cur.slot, 100)
                            TriggerServerEvent('bl_core:removeMoney', moneyType, price)
                            Notify(W.language.city, W.language.repaired:format(cur.name or 'Weapon', price, moneyLabel), 'success')
                        else
                            local lacking = price - account.money
                            Notify(W.language.city, W.language.not_enough:format(lacking, moneyLabel), 'warning')
                        end
                    else
                        Notify(W.language.city, W.language.cancelled:format(cur.name or 'Weapon'), 'error')
                    end
                end,
            }
        }
    })
    lib.showContext('repair_menu')
end

-- VIP: sama seperti openRepairMenuForCoord tetapi ikut config vip (akaun + diskaun)
local function VipWeaponMenuWithDiscount(cur, moneyType, moneyLabel, discountPct)
    if not cur then return end
    local durability = (cur.metadata and cur.metadata.durability) or 0
    if durability >= 100 then
        return Notify(W.language.city, W.language.not_damaged:format(cur.name or 'Weapon'), 'warning')
    end

    local baseRepair = math.max(0, 100 - durability)
    local basePrice  = baseRepair * 100
    discountPct = tonumber(discountPct) or 0
    local price = (discountPct > 0) and math.floor(basePrice * (100 - discountPct) / 100) or basePrice

    lib.registerContext({
        id = 'repair_menu',
        title = W.language.menu_title,
        options = {
            {
                title = cur.label or cur.name or 'Weapon',
                description = (discountPct > 0)
                    and (('Repair your weapon for %s %s (VIP %d%% off)'):format(price, moneyLabel or 'Cash', discountPct))
                    or  (('Repair your weapon for %s %s'):format(price, moneyLabel or 'Cash')),
                progress = durability,
                icon = 'gun',
                image = ('nui://ox_inventory/web/images/%s.png'):format(cur.name),
                onSelect = function()
                    if lib.progressCircle({
                        duration = W.progressbar.duration,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = { car = true, move = true },
                        anim = { dict = 'mini@repair', clip = 'fixing_a_player' },
                    }) then
                        local account = lib.callback.await('bl_core:getMoney', false, moneyType or 'money')
                        local have = (account and account.money) or 0
                        if have >= price then
                            TriggerServerEvent('bl_core:repairWeapon', cur.slot, 100)
                            TriggerServerEvent('bl_core:removeMoney', moneyType or 'money', price)
                            Notify(W.language.city,
                                W.language.repaired:format(cur.name or 'Weapon', price, moneyLabel or 'Cash'), 'success')
                        else
                            Notify(W.language.city,
                                W.language.not_enough:format(price - have, moneyLabel or 'Cash'), 'warning')
                        end
                    else
                        Notify(W.language.city, W.language.cancelled:format(cur.name or 'Weapon'), 'error')
                    end
                end,
            }
        }
    })
    lib.showContext('repair_menu')
end

-- =========================
-- MAIN: setup lokasi
-- =========================
CreateThread(function()
    Wait(1000)
    print('^4[BL_CORE] - DEBUG | WEAPON REPAIR LOADED^7')

    if not W.coords or #W.coords == 0 then
        print('^1[SNX_weaponrepairv2] No repair coords configured.^7')
        return
    end

    for i = 1, #W.coords do
        local repairCfg = W.coords[i]
        local benchObj = spawnBenchAt(repairCfg)

        -- ox_target path
        if hasOxTarget and repairCfg.target then
            local options = {
                {
                    name = ('snx_repair_%s'):format(i),
                    icon = 'fa-solid fa-screwdriver-wrench',
                    label = W.language.menu_title,
                    distance = 2.0,
                    onSelect = function() openRepairMenuForCoord(repairCfg) end
                }
            }

            if benchObj and benchObj ~= 0 then
                exports.ox_target:addLocalEntity(benchObj, options)
            else
                exports.ox_target:addSphereZone({
                    coords = repairCfg.coords,
                    radius = 1.5,
                    debug = false,
                    options = options
                })
            end

        else
            -- Fallback: E + marker
            local marker
            if (W.marker.enabled ~= false) then
                marker = lib.marker.new({
                    type = W.marker.type,
                    coords = repairCfg.coords,
                    color = W.marker.color,
                })
            end

            local point = lib.points.new({
                coords = repairCfg.coords,
                distance = W.marker.DrawDistance,
            })

            function point:onExit()
                HideHelpUI()
            end

            function point:nearby()
                if marker then marker:draw() end
                if self.currentDistance < 1.5 then
                    HelpUI('E', W.language.HelpUI)
                    if IsControlJustPressed(0, 51) then  -- INPUT_CONTEXT
                        openRepairMenuForCoord(repairCfg)
                    end
                else
                    HideHelpUI()
                end
            end
        end
    end
end)

-- =========================
-- BLIP SETUP (global + per-lokasi override)
-- =========================
CreateThread(function()
    local W = Config.Weapon
    if not (W and W.blip and W.blip.enabled) then return end

    for i = 1, #W.coords do
        local c = W.coords[i]
        local b = c.blip or W.blip

        local blip = AddBlipForCoord(c.coords.x, c.coords.y, c.coords.z)
        SetBlipSprite(blip, b.sprite or 110)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, b.scale or 0.8)
        SetBlipAsShortRange(blip, b.shortRange ~= false)
        SetBlipColour(blip, b.color or 1)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(b.name or 'Weapon Repair')
        EndTextCommandSetBlipName(blip)
    end
end)

-- =========================
-- VIP MENU EVENT
-- =========================
RegisterNetEvent('SNX_weaponrepairv2:client:openFromVIP', function()
    local WW = Config.Weapon
    local L  = (WW and WW.language) or {}
    if not (WW and WW.vipRepair and WW.vipRepair.enabled) then
        return Notify(L.city or 'SYSTEM', L.error or 'VIP repair not configured', 'error')
    end

    local cur = exports.ox_inventory:getCurrentWeapon()
    if not cur then
        return Notify(L.city or 'SYSTEM', L.no_weapon or 'You have no weapon in your hand', 'error')
    end

    local moneyType  = WW.vipRepair.money or 'money'
    local moneyLabel = WW.vipRepair.money_label or 'Cash'
    local discount   = WW.vipRepair.discount or 0
    VipWeaponMenuWithDiscount(cur, moneyType, moneyLabel, discount)
end)

-- =========================
-- CLEANUP
-- =========================
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, obj in ipairs(spawnedBenches) do
        if DoesEntityExist(obj) then DeleteEntity(obj) end
    end
end)