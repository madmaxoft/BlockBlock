
-- main.lua

-- Implements the main plugin entrypoint

--[[
  This plugin will prevent players from placing and breaking certain blocks.
  
Configuration is read from BlockedBlocks.ini file. Player's won't be able to place or break blocks specified
there, unless they have a "blockedblocks.bypass" permission. The blocks can be specified as blocktype, or
blocktype with meta.
--]]




--- The prefix that will be added to all log messages
g_LogPrefix = ""

--- Names of worlds where the blocking is active
g_WorldNames = {}

--- Blocks that are blocked.
-- Each item is a table, first item is the numerical block type, second item, if present, is the meta. 
-- If the item doesn't have a meta, all metas are blocked
g_Blocks = {}




function Initialize(a_Plugin)
	g_LogPrefix = "[" .. a_Plugin:GetName() .. "] "
	
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_PLACING_BLOCK,  OnPlayerPlacingBlock)
	
	if not(LoadBlocks("BlockedBlocks.ini")) then
		LOGWARN("Could not load the blocks properly. Plugin is not loaded")
		return false
	end

	return true
end





--- Loads the blocked blocks from the INI file specified
-- Returns true if successful, false in case of failure
function LoadBlocks(a_FileName)
	local SettingsIni = cIniFile()
	SettingsIni:ReadFile(a_FileName)
	local BlockedWorlds = SettingsIni:GetValueSet("General", "ActiveWorlds", "")
	g_WorldNames = StringSplitAndTrim(BlockedWorlds, ",")
	local BlockedBlocks = SettingsIni:GetValueSet("General", "Blocks", "tnt, piston")
	SettingsIni:WriteFile(a_FileName)
	local Blocks = StringSplitAndTrim(BlockedBlocks, ",")
	local TempItem = cItem()
	for i = 1, #Blocks do
		local BlockDef = StringSplitAndTrim(Blocks[i])
		if not(StringToItem(BlockDef[1], TempItem)) then
			LOGWARNING(g_LogPrefix .. "Unknown block type: \"" .. BlockDef[1] .. "\". Block will NOT be blocked.")
		else
			local NewBlock = {}
			NewBlock[1] = TempItem.m_ItemType
			if (TempItem.m_ItemDamage ~= 0) then
				NewBlock[2] = TempItem.m_ItemDamage
			elseif (type(BlockDef[2]) == "string") then
				local Damage = tonumber(BlockDef[2])
				if (Damage == nil) then
					LOGWARNING(g_LogPrefix .. "Unknown block meta: \"" .. BlockDef[2] .. "\". The block will be blocked for all METAs.")
				else
					NewBlock[2] = Damage
				end
			end
			table.insert(g_Blocks, NewBlock)
		end
	end
	return (#g_Blocks > 0)
end





--- Returns true if the specified world name is among the active worlds
function IsActiveWorld(a_WorldName)
	assert(type(a_WorldName) == "string")
	
	if (#g_WorldNames == 0) then
		-- No worlds are explicitly given, so all worlds are active
		return true
	end
	
	for idx, name in ipairs(g_WorldNames) do
		if (a_WorldName == name) then
			return true
		end
	end
	return false
end





--- Returns true if the specified block type and meta should be blocked
function IsBlockedBlock(a_BlockType, a_BlockMeta)
	assert(type(a_BlockType) == "number")
	assert(type(a_BlockMeta) == "number")
	
	for idx, blk in ipairs(g_Blocks) do
		if (blk[1] == a_BlockType) then  -- block type match
			if ((blk[2] == nil) or (blk[2] == a_BlockMeta)) then  -- block meta don't care, or match
				return true
			end
		end
	end
	return false
end





function OnPlayerPlacingBlock(
	a_Player,
	a_BlockX, a_BlockY, a_BlockZ, a_BlockFace,
	a_CursorX, a_CursorY, a_CursorZ,
	a_BlockType, a_BlockMeta
)
	if (a_Player:HasPermission("blockblocks.bypass")) then
		return false
	end
	if not(IsActiveWorld(a_Player:GetWorld():GetName())) then
		return false
	end
	if (IsBlockedBlock(a_BlockType, a_BlockMeta)) then
		a_Player:SendMessage(cChatColor.Rose .. "You are not allowed to place this")
		return true
	end
end





function OnPlayerBreakingBlock(
	a_Player,
	a_BlockX, a_BlockY, a_BlockZ, a_BlockFace,
	a_BlockType, a_BlockMeta
)
	if (a_Player:HasPermission("blockblocks.bypass")) then
		return false
	end
	if not(IsActiveWorld(a_Player:GetWorld():GetName())) then
		return false
	end
	if (IsBlockedBlock(a_BlockType, a_BlockMeta)) then
		a_Player:SendMessage(cChatColor.Rose .. "You are not allowed to break this")
		return true
	end
end



