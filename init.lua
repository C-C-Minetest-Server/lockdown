-- lockdown/init.lua
-- Keep non-admin players away during maintainence
--[[
    Server Lockdown: Keep non-admin players away during maintainence
    Copyright (C) 2024  1F616EMO

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]

local S = minetest.get_translator("lockdown")
local FL = minetest.get_worldpath() .. "/lockdown.txt"

lockdown = {}

function lockdown.set_lockdown(reason)
    reason = reason or ""

    local f = io.open(FL, "w")
    f:write(reason)
    f:close()
end

function lockdown.unset_lockdown()
    os.remove(FL)
end

function lockdown.check_lockdown()
    if minetest.is_singleplayer() then return end
    local f = io.open(FL, "r")

    if f == nil then return end
    return f:read("*a")
end

function lockdown.get_kick_reason(reason)
    if reason == "" then
        return "The server is under maintainence."
    end
    return "The server is under maintainence. Reason: " .. reason
end

minetest.register_on_prejoinplayer(function(name)
    local reason = lockdown.check_lockdown()
    if reason then
        local privs = minetest.get_player_privs(name)
        if not (privs.server or privs.privs) then
            return lockdown.get_kick_reason(reason)
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    if not lockdown.check_lockdown() then return end
    local name = player:get_player_name()
    minetest.chat_send_player(name, minetest.colorize("orange",
        "*** " .. S("The server is under lockdown mode. To unlock it, do /lockdown off")
    ))
end)

minetest.register_chatcommand("lockdown", {
    description = S("Control server lockdown state"),
    params = S("on/off [<reason>]"),
    privs = {server = true},
    func = function(name, param)
        local res = string.split(param, " ")

        local state = res[1] and string.lower(res[1])
        if state == "on" then
            local reason = res[2] or ""
            lockdown.set_lockdown(reason)
            return true, S("Lockdown mode set.")
        elseif state == "off" then
            lockdown.unset_lockdown()
            return true, S("Lockdown unset.")
        end

        local reason = lockdown.check_lockdown()
        if reason == "" then
            return true, S("The server is under lockdown mode. Reason: Not Given")
        elseif reason then
            return true, S("The server is under lockdown mode. Reason: @1", reason)
        else
            return true, S("The server is not under lockdown mode.")
        end
    end,
})
