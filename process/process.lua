
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
        table.insert(apis, string.format('syn keyword %s %s\n', type_str, v))
    end

    table.insert(apis, '\n') -- make a empty line
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
end
file:flush()
file:close()
--}}}


