

local function process(rawname, chunkname, reg, type)
    local raw_file = io.open(rawname, 'r')
    if(not raw_file) then
        print('Cannot open file ' .. rawname)
        return
    end

    local rawstrings = {}
    for line in raw_file:lines() do
        if(line~='' and line ~= ' ') then
            local str = line:match(reg)
            if(str and str~='' and str~=' ') then
                rawstrings[str] = true
            end
        end
    end

    raw_file:close()

    local chunk_file = io.open(chunkname, 'w')
    if(not chunk_file) then
        print('Cannot open file ' .. chunkname)
        return
    end
    for k, v in pairs(rawstrings) do
        chunk_file:write(string.format('syn keyword %s %s\n', type, k))
    end

    chunk_file:flush()
    chunk_file:close()
end

process('raw_api', 'chunk_api', '^([a-z,A-Z_]+)', 'luaWoWAPI')
process('raw_event', 'chunk_event', '^([A-Z_]+)', 'luaWoWEvent')
process('raw_widget', 'chunk_widget', ':(%w+)%(', 'luaWoWWidget')

