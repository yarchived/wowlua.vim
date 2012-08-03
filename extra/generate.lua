#!/usr/bin/env lua


local function open(path, mode, func)
    local f = io.open(path, mode or 'r')
    if(f) then
        func(f)
    end
    return f:close()
end

local function valid(str)
    return str and str~='' and str~=' '
end

local parseRaw = function(filename, re)
    local kw = {}


    open(filename, 'r', function(f)
        for line in f:lines() do
            if(valid(line)) then
                local str = line:match(re)
                if(valid(str)) then
                    kw[str] = true
                end
            end
        end
    end)

    local ret = {}
    local tinsert = table.insert
    for k in next, kw do
        tinsert(ret, k)
    end

    table.sort(ret)
    return ret
end


local function main()
    local apis = {
         api = parseRaw('raw_api', '^([a-z,A-Z_]+)'),
         event = parseRaw('raw_event', '^([A-Z_]+)'),
         widget = parseRaw('raw_widget', ':(%w+)%('),
    }

    -- vim
    do
        local printSyntax = function(apis, kw)
            for i, v in ipairs(apis) do
                io.stdout:write(('syn keyword %s %s\n'):format(v, kw))
            end

            io.stdout:write'\n'
        end

        printSyntax(apis.api, 'luaWoWAPI')
        printSyntax(apis.event, 'luaWoWEvent')
        printSyntax(apis.widget, 'luaWoWWidget')
    end

    print'\n\n'
    print[[---------------------------------------------------------]]
    print'\n\n'

    do
        local dump_words = function(apis)
            for i, v in ipairs(apis) do
                io.stdout:write(v)
                io.stdout:write'\n'
            end
            io.stdout:write'\n'
        end

        dump_words(apis.api)
        dump_words(apis.event)
        dump_words(apis.widget)
    end

    print'\n\n'
    print[[---------------------------------------------------------]]
    print'\n\n'

    do
        local joinPrint = function(t, sep)
            local len = #t
            for i, v in ipairs(t) do
                io.stdout:write(v)
                if(i ~= len) then
                    io.stdout:write' '
                end
            end
        end


        print[==[
<Language name="lua" ext="lua" commentLine="--" commentStart="--[[" commentEnd="]]">
    <Keywords name="instre1">and arg break do else elseif end false for function if in ipairs local nil not or repeat return then true until while</Keywords>
    <Keywords name="instre2">_G _ERRORMESSAGE _VERSION abs acos asin assert atan atan2 byte ceil char collectgarbage concat cos date debugbreak debugdump debuginfo debugload debugprint debugprofilestart debugprofilestop debugstack debugtimestamp deg difftime dofile dump error exp find floor foreach foreachi format frexp gcinfo geterrorhandler getfenv getglobal getmetatable getn gfind gmatch gsub hooksecurefunc insert ipairs issecure issecurevariable ldexp len loadfile loadlib loadstring log log10 lower max message min mod newproxy next out pairs pcall pow print rad random randomseed rawequal rawget rawset remove rep require securecall select seterrorhandler setfenv setglobal setmetatable sin sort sqrt strbyte strchar strconcat strfind strjoin strlen strlower strmatch strrep strreplace strrev strsplit strsub strtrim strupper sub tan time tinsert tonumber tostring tremove type unpack xpcall</Keywords>
]==]

        print'    <Keywords name="type1">'
        joinPrint(apis.api , ' ')
        print' '
        joinPrint(apis.widget, ' ')
        print'</Keywords>\n'

        print'    <Keywords name="type2">'
        joinPrint(apis.event, ' ')
        print'</Keywords>\n</Language>\n'
    end

end

main()


