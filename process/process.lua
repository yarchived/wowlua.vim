--[[
NAME
    wowlua.vim - generate vim syntax file for wow lua apis

SYNOPSIS
    lua process.lua [args]

DESCRIPTION
    args:
        nppp    - generate syntax file for notepad++ editor
        novim   - don't generate vim syntax file

LICENSE
    Copyright (C) 2010 yaroot (yaroot@gmail.com)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--]]

--{{{
local argv = {...}
local function isEnabled(what)
    for i, v in ipairs(argv) do
        if(string.upper(v) == string.upper(what)) then
            return true
        end
    end

    return false
end

local function open(path, mode)
    local f = io.open(path, mode or 'r')
    if(not f ) then
        error('Cannot open file ' .. path or '')
    else
        return f
    end
end

local function valid(str)
    return str and str~='' and str~=' '
end

local function findDuplicate(t, s)
    for i, v in ipairs(t) do
        if(v) == s then
            return true
        end
    end

    return false
end

local function parse(filename, re)
    local res = {}

    local file = open(filename)
    for line in file:lines() do
        if(valid(line)) then
            local str = line:match(re)
            if(valid(str) and not findDuplicate(res, str)) then
                table.insert(res, str)
            end
        end
    end
    file:close()

    table.sort(res)
    return res
end
--}}}

--{{{
local function main(argv)
    local apis = {
         api = parse('raw_api', '^([a-z,A-Z_]+)'),
         event = parse('raw_event', '^([A-Z_]+)'),
         widget = parse('raw_widget', ':(%w+)%('),
    }

    if(not isEnabled'novim') then

        local function fmt(t1, t2, tt)
            t2 = t2 or {}


            for i, v in ipairs(t1) do
                table.insert(t2, string.format('syn keyword %s %s', tt, v))
            end
            table.insert(t2, '')

            return t2
        end

        local tmp = fmt(apis.api, nil, 'luaWoWAPI')
                    fmt(apis.event, tmp, 'luaWoWEvent')
                    fmt(apis.widget, tmp, 'luaWoWWidget')

        local file = open('chunk.vim', 'w')

        for i, v in ipairs(tmp) do
           file:write(v)
           file:write'\n'
        end

        file:flush()
        file:close()
    end

    if(isEnabled'nppp') then
        local function joinString(t)
            local s
            for i, v in ipairs(t) do
                s = s and (s..' '..v) or v
            end

            return s
        end


        local file = open('chunk.xml', 'w')

        file:write[==[
<Language name="lua" ext="lua" commentLine="--" commentStart="--[[" commentEnd="]]">
    <Keywords name="instre1">and arg break do else elseif end false for function if in ipairs local nil not or repeat return then true until while</Keywords>
    <Keywords name="instre2">_G _ERRORMESSAGE _VERSION abs acos asin assert atan atan2 byte ceil char collectgarbage concat cos date debugbreak debugdump debuginfo debugload debugprint debugprofilestart debugprofilestop debugstack debugtimestamp deg difftime dofile dump error exp find floor foreach foreachi format frexp gcinfo geterrorhandler getfenv getglobal getmetatable getn gfind gmatch gsub hooksecurefunc insert ipairs issecure issecurevariable ldexp len loadfile loadlib loadstring log log10 lower max message min mod newproxy next out pairs pcall pow print rad random randomseed rawequal rawget rawset remove rep require securecall select seterrorhandler setfenv setglobal setmetatable sin sort sqrt strbyte strchar strconcat strfind strjoin strlen strlower strmatch strrep strreplace strrev strsplit strsub strtrim strupper sub tan time tinsert tonumber tostring tremove type unpack xpcall</Keywords>
]==]

        file:write'    <Keywords name="type1">'
        file:write(joinString(apis.api) .. ' ' .. joinString(apis.widget))
        file:write'</Keywords>\n'

        file:write'    <Keywords name="type2">'
        file:write(joinString(apis.event))
        file:write'</Keywords>\n</Language>\n'

        file:flush()
        file:close()
    end

end

main(argv)
--}}}

