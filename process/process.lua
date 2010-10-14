--[[
NAME
    wowlua.vim - generate vim syntax file for wow lua apis

SYNOPSIS
    lua process.lua [args]

DESCRIPTION
    args:
        nppp    - generate syntax file for notepad++ editor

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
--}}}

--{{{
local apis = {}

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
end
--}}}}

--{{{
local function parse(raw, re, type_str)
    local rawstrings = {}

    -- get the api out
    local raw_file = open(raw)
    for line in raw_file:lines() do
        if(valid(line)) then
            local str = line:match(re)
            if(valid(str) and not findDuplicate(rawstrings, str)) then
                table.insert(rawstrings, str)
            end
        end
    end
    raw_file:close() -- close file

    table.sort(rawstrings)

    -- add them together
    for i, v in ipairs(rawstrings) do
        table.insert(apis, string.format('syn keyword %s %s', type_str, v))
    end

    table.insert(apis, '') -- make a empty line
end
--}}}

--{{{ go go rock
table.insert(apis, '\n')
parse('raw_api', '^([a-z,A-Z_]+)', 'luaWoWAPI')
parse('raw_event', '^([A-Z_]+)', 'luaWoWEvent')
parse('raw_widget', ':(%w+)%(', 'luaWoWWidget')
--}}}

--{{{ write to the file
local file = open('chunk.vim', 'w')
for i, v in ipairs(apis) do
   file:write(v)
   file:write'\n'
end
file:flush()
file:close()
--}}}

--{{{ notepad++
if(isEnabled'nppp') then
    -- god I hate xml
    local file = open('chunk.xml', 'w')
    local type1, type2 = {}, {}

    local function toRaw(str)
        local ind, word = str:match'([a-zA-Z_]+) ([a-zA-Z_]+)$'
        if(valid(ind) and valid(word)) then
            return ind, word
        end
    end

    local function doWriteFile(t, f)
        for i, v in ipairs(t) do
            if(i~=1) then f:write(' ') end
            f:write(v)
        end
    end

    for i, v in ipairs(apis) do
        local ind, word = toRaw(v)
        if(ind) then
            if(ind == 'luaWoWEvent') then
                table.insert(type2, word)
            else
                table.insert(type1, word)
            end
        end
    end

    file:write[==[
<Language name="lua" ext="lua" commentLine="--" commentStart="--[[" commentEnd="]]">
    <Keywords name="instre1">and arg break do else elseif end false for function if in ipairs local nil not or repeat return then true until while</Keywords>
    <Keywords name="instre2">_G _ERRORMESSAGE _VERSION abs acos asin assert atan atan2 byte ceil char collectgarbage concat cos date debugbreak debugdump debuginfo debugload debugprint debugprofilestart debugprofilestop debugstack debugtimestamp deg difftime dofile dump error exp find floor foreach foreachi format frexp gcinfo geterrorhandler getfenv getglobal getmetatable getn gfind gmatch gsub hooksecurefunc insert ipairs issecure issecurevariable ldexp len loadfile loadlib loadstring log log10 lower max message min mod newproxy next out pairs pcall pow print rad random randomseed rawequal rawget rawset remove rep require securecall select seterrorhandler setfenv setglobal setmetatable sin sort sqrt strbyte strchar strconcat strfind strjoin strlen strlower strmatch strrep strreplace strrev strsplit strsub strtrim strupper sub tan time tinsert tonumber tostring tremove type unpack xpcall</Keywords>
]==]

    file:write'    <Keywords name="type1">'
    doWriteFile(type1, file)
    file:write'</Keywords>\n'

    file:write'    <Keywords name="type2">'
    doWriteFile(type2, file)
    file:write'</Keywords>\n</Language>\n'

    file:flush()
    file:close()
end
--}}}

