--[[
  Orig by http://www.wowwiki.com/User:Mikk/Scripts

]]
local window = CreateFrame('EditBox', nil, UIParent)
window:SetHeight(150)
window:SetWidth(500)
window:SetPoint('CENTER', UIParent, 0, 100)
window:SetFontObject(GameFontHighlightSmall)
window:SetMultiLine(true)
window:SetScript('OnEscapePressed', window.Hide)

function window.show(str)
    window:SetText(str)
    window:Show()
    window:SetFocus()
    window:HighlightText(0, 9999999)
end




local function funcaddr(func)
    if(type(func) == 'string') then
        func = _G[func]
    end

    return tonumber(strsub(tostring(func), 10), 16)
end

local refpoint={}
local function setref(funcname)
  refpoint[funcname]=funcaddr(funcname)
end

setref("DeclineGroup")
setref("FlagTutorial")
setref("ConvertToRaid")
setref("FlagTutorial")
setref("ShowLFG")
setref("asin")
setref("pairs")
setref("AcceptQuest")

local res = {}
for k,v in pairs(_G) do
    if type(v)=="function"	--[[ and strfind(k, "^_*[A-Za-z0-9]+$") or ]] then
  	local addr = funcaddr(v)
  	for _,refaddr in pairs(refpoint) do
  		if abs(addr-refaddr)<300000 then
  			tinsert(res, k)
  			break
  		end
  	end
    end
end

table.sort(res)

for k,v in pairs(refpoint) do
  table.insert(res, 1, format("# %-15s %10u (0x%08x)", k, v, v))
end

local str = table.concat(res, "\n")


--[[
--  api done here
--  so begins the widgets
--]]

-- wipe table first
for k,v in pairs(res) do
    res[k] = nil
end

local widgets = {
    Font = function() end,
    Frame = 'CreateFrame',
    Button = 'CreateFrame',
    Slider = 'CreateFrame',
}






-- cmd / funcs
SLASH_WOWLUA1 = '/wowlua'
SlashCmdList.WOWLUA = function()
    window.show(str)
end

print'wowlua.vim is running, you should disable it when you are done'


