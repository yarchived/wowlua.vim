--[[
  Orig by http://www.wowwiki.com/User:Mikk/Scripts

  Up to date for WoW 2.4. Produces some extras but that gets filtered out by later scripts.
]]
if(not GlobFuncEdit) then
    GlobFuncEdit = CreateFrame("Editbox")
end
GlobFuncEdit:SetFontObject(GameFontHighlightSmall)
GlobFuncEdit:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
GlobFuncEdit:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -250, -10)
GlobFuncEdit:SetHeight("500")
GlobFuncEdit:SetMultiLine(true)
GlobFuncEdit:SetScript("OnEscapePressed", function(self) self:Hide() end)

local function funcaddr(func)
  return tonumber(strsub(tostring(func), 10), 16)
end

local refpoint={}
local function point(funcname)
  refpoint[funcname]=funcaddr(_G[funcname])
end

point("DeclineGroup")
point("FlagTutorial")
point("ConvertToRaid")
point("FlagTutorial")
point("ShowLFG")
point("asin")
point("pairs")
point("AcceptQuest")

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
table.insert(res, "# END")
local str = table.concat(res, "\n")
DEFAULT_CHAT_FRAME:AddMessage("GlobFuncScan: Found " .. #res .. " functions. Total output length is " .. strlen(str) .. " bytes.")
GlobFuncEdit:SetText(str)

GlobFuncEdit:Show()
GlobFuncEdit:SetFocus(true)
GlobFuncEdit:HighlightText(0, 999999)
