
--{{{
local function open(path, mode)
    local f = io.open(path, mode or 'r')
    if(not f ) then
        error('Cannot open file ' .. rawname)
    else
        return f
    end
end
--}}}}

--{{{
local function go(rawname, chunkname, reg, type_str)
    local raw_file = open(rawname)

    -- get the api out
    local rawstrings = {}
    for line in raw_file:lines() do
        if(line~='' and line ~= ' ') then
            local str = line:match(reg)
            if(str and str~='' and str~=' ') then
                rawstrings[str] = true
            end
        end
    end
    raw_file:close() -- close file

    -- write to the file
    local chunk_file = open(chunkname, 'r')
    for k, v in pairs(rawstrings) do
        chunk_file:write(string.format('syn keyword %s %s\n', type_str, k))
    end

    chunk_file:flush()
    chunk_file:close()
end
--}}}

--{{{
go('raw_api', 'chunk_api', '^([a-z,A-Z_]+)', 'luaWoWAPI')
go('raw_event', 'chunk_event', '^([A-Z_]+)', 'luaWoWEvent')
go('raw_widget', 'chunk_widget', ':(%w+)%(', 'luaWoWWidget')
--}}}

--{{{ cat the file together
local cmd = [[

]]

-- os run



--}}}


