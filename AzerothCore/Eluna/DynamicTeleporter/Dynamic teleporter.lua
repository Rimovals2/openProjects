--[[
  Project: Dynamic Teleporter NPC & Item
  Author: Slavomir Strnad
  GitHub: https://github.com/Rimovals2

  Description:
    - Unified Lua-based teleport system for AzerothCore using both NPC and item.
    - Features multi-level menu, teleport confirmation with cost,
      faction filtering, and icon support.

  License: GNU General Public License v3.0
    - You must retain this header when modifying or redistributing the code.
    - See LICENSE file for more details.

  Special Thanks:
    - AzerothCore community for their contributions to open-source.
]]

-- Definujte ID pro předmět a/nebo NPC
local ItemEntry = 701007 -- NPC ID
local UnitEntry = 400000 -- ITEM ID

local CONFIRM_SENDER = 9999  -- hodnota pro potvrzovací dialog 

-- Globální proměnná pro zjištění, zda se událost spouští pro předmět
local isItemEvent = false

-- Tabulka s hlavním menu 
local T = {
    [1] = { "|TInterface/icons/spell_arcane_teleporttheramore:30:30:-25:1|t MENU 1", 1,
        {"|TInterface/icons/inv_misc_bag_09_blue:30:30:-25:1|t Dalaran Shop", 571, 5801.53, 424.91, 658.78, 1.075, 0},

    },
    [2] = { "|TInterface/icons/spell_arcane_teleporttheramore:30:30:-25:1|t MENU 2", 0,
        {"|TInterface/icons/inv_misc_bag_09_blue:30:30:-25:1|t Dalaran Shop", 571, 5801.53, 424.91, 658.78, 1.075, 0},

    },
}

local pendingTeleport = {}

--------------------------------------------------
-- Funkce pro zobrazení hlavního menu (Gossip)
--------------------------------------------------
local function OnGossipHello(event, player, unit)
    for i, v in ipairs(T) do
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, v[1], i, 0)
        end
    end
    player:GossipSendMenu(1, unit)
end

--------------------------------------------------
-- Hlavní funkce pro zpracování gossip volby
--------------------------------------------------
local function OnGossipSelect(event, player, unit, sender, intid, code)
    -- Pokud jsme v hlavním menu (sender == 0), znovu zobrazíme hlavní menu
    if (sender == 0) then
        OnGossipHello(event, player, unit)
        return
    end

    -- Zpracování potvrzovacího dialogu 
    if (sender == CONFIRM_SENDER) then
        if (intid == 1) then  -- Hráč kliknul "YES"
            local pending = pendingTeleport[player:GetGUIDLow()]
            if not pending then
                player:SendNotification("Není nastavena žádná teleportace ke schválení.")
                player:GossipComplete()
                return
            end
            local s = pending.sender
            local i = pending.intid
            local text, map, x, y, z, o, cost = table.unpack(T[s][i])
            cost = cost or 0
            -- Pokud se jedná o item, cost vynulujeme (teleportace bez ceny)
            if isItemEvent then
                cost = 0
            end
            if player:GetCoinage() < cost then
                player:SendNotification("Nemáš dostatek peněz!")
                pendingTeleport[player:GetGUIDLow()] = nil
                player:GossipComplete()
                return
            end
            player:ModifyMoney(-cost)
            player:Teleport(map, x, y, z, o)
            pendingTeleport[player:GetGUIDLow()] = nil
            player:GossipComplete()
        elseif (intid == 2) then  -- Hráč kliknul "NO" nebo "CLOSE TELEPORT MENU"
            pendingTeleport[player:GetGUIDLow()] = nil
            OnGossipHello(event, player, unit)
        elseif (intid == 3) then  -- Hráč kliknul "BACK TO MENU"
            pendingTeleport[player:GetGUIDLow()] = nil
            OnGossipHello(event, player, unit)
        else
            player:GossipComplete()
        end
        return
    end

    -- Zpracování výběru kategorie (podmenu) – pokud intid == 0, zobrazíme položky dané kategorie
    if (intid == 0) then
        if T[sender] == nil then
            player:SendNotification("Chyba: neexistující menu.")
            player:GossipComplete()
            return
        end
        for i, v in ipairs(T[sender]) do
            if (i > 2) then
                player:GossipMenuAddItem(0, v[1], sender, i)
            end
        end
        player:GossipMenuAddItem(0, "Back", 0, 0)
        player:GossipSendMenu(1, unit)
        return
    else
        -- Hráč vybral konkrétní teleportaci
        local text, map, x, y, z, o, cost = table.unpack(T[sender][intid])
        cost = cost or 0
        if isItemEvent then
            cost = 0
        end

        if cost > 0 then
            pendingTeleport[player:GetGUIDLow()] = { sender = sender, intid = intid }
            local priceGold = cost / 10000  -- coppers na gold
            local plainText = text:gsub("|T.-|t", "")
            local confirmText = "|TInterface/Icons/inv_misc_coin_01:30:30|t      PRICE = " .. string.format("%.2f", priceGold) .. " Gold"
            player:GossipMenuAddItem(0, confirmText, CONFIRM_SENDER, 0)
            player:GossipMenuAddItem(0, "|TInterface/ICONS/spell_holy_silence:40:40:-25:1|t [Y] YES TELEPORT ME", CONFIRM_SENDER, 1)
            player:GossipMenuAddItem(0, "<<< BACK TO MENU", CONFIRM_SENDER, 3)
            player:GossipMenuAddItem(0, "[CLOSE TELEPORT MENU]", CONFIRM_SENDER, 2)
            player:GossipSendMenu(1, unit)
            return
        else
            player:Teleport(map, x, y, z, o)
        end
    end

    player:GossipComplete()
end

-- Registrace pro NPC
if UnitEntry then
    RegisterCreatureGossipEvent(UnitEntry, 1, OnGossipHello)
    RegisterCreatureGossipEvent(UnitEntry, 2, function(event, player, unit, sender, intid, code)
        if sender == CONFIRM_SENDER then
            OnGossipSelect(event, player, unit, sender, intid, code)
        else
            OnGossipSelect(event, player, unit, sender, intid, code)
        end
    end)
end

-- Registrace pro item
if ItemEntry then
    RegisterItemGossipEvent(ItemEntry, 1, function(event, player, item, sender, intid, code)
        isItemEvent = true
        OnGossipHello(event, player, item)
        isItemEvent = false
    end)
    RegisterItemGossipEvent(ItemEntry, 2, function(event, player, item, sender, intid, code)
        isItemEvent = true
        OnGossipSelect(event, player, item, sender, intid, code)
        isItemEvent = false
    end)
    -- U položek u itemů není nutné registrovat potvrzovací dialog zvlášť,
    -- pokud chcete, můžete jej vložit do funkce OnGossipSelect jak je to výše.
end