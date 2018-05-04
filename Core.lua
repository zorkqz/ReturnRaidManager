
-- TODO: Version number
-- TODO: Autocomplete names
-- TODO: Bug - Guild Tab
-- TODO: ScrollPane for saved layouts

ReturnRaidManager = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0")
ReturnRaidManager:RegisterChatCommand({"/ReturnRaidManager", "/rrm"}, {type = 'execute', func = "ToggleUI"})
ReturnRaidManager:RegisterDB("ReturnRaidManagerDB", "ReturnRaidManagerDBPerChar")

ReturnRaidManager:RegisterDefaults("account", {
    SavedLayouts = {}
})
ReturnRaidManager:RegisterDefaults("char", {
    MinimapButtonPosition = 336,
    MinimapButtonRadius = 78
})

ReturnRaidManager.PlayerInfoByName = {}
ReturnRaidManager.PlayerInfoByRaidIndex = {}
function ReturnRaidManager:UpdatePlayerInfo()

    ReturnRaidManager.PlayerInfoByName = {}
    ReturnRaidManager.PlayerInfoByRaidIndex = {}

    for i = 1,40 do
        name, _, subgroup, _, _, class = GetRaidRosterInfo(i)

        if name then 
            playerInfo = {}
            playerInfo.name = name
            playerInfo.raidIndex = i
            playerInfo.currentSubGroupId = subgroup
            playerInfo.newSubGroupId = nil
            playerInfo.class = class
            ReturnRaidManager.PlayerInfoByName[name] = playerInfo
            ReturnRaidManager.PlayerInfoByRaidIndex[i] = playerInfo
        end
    end
    
end

ReturnRaidManager.RaidConfigByName = {}
function ReturnRaidManager:LoadRaidConfig()

    ReturnRaidManager.RaidConfigByName = {}
    for i = 1,40 do
        name = ReturnRaidManager.UI["NameBox"..i]:GetText()

        if ReturnRaidManager.PlayerInfoByName[name] then
            ReturnRaidManager.RaidConfigByName[name] = {
                name = name,
                subGroup = floor((i - 1) / 5) + 1
            }
        end
    end

end

function ReturnRaidManager:ExecuteLayout()
    self:UpdatePlayerInfo()
    self:LoadRaidConfig()

    for name, playerInfo in pairs(ReturnRaidManager.PlayerInfoByName) do

        config = ReturnRaidManager.RaidConfigByName[name]
        if config then
            ReturnRaidManager.PlayerInfoByName[name].newSubGroupId = config.subGroup
        end
        
    end

    for i = 1,40 do
        local pi1 = ReturnRaidManager.PlayerInfoByRaidIndex[i]

        if pi1 and pi1.newSubGroupId and pi1.currentSubGroupId ~= pi1.newSubGroupId then

            found = false

            for j = 1,40 do
                local pi2 = ReturnRaidManager.PlayerInfoByRaidIndex[j]
                
                if pi2 and pi2.currentSubGroupId == pi1.newSubGroupId and pi2.newSubGroupId == pi1.currentSubGroupId and pi2.currentSubGroupId ~= pi2.newSubGroupId then
                    SwapRaidSubgroup(pi1.raidIndex, pi2.raidIndex)
                    pi2.currentSubGroupId = pi1.currentSubGroupId;
                    pi1.currentSubGroupId = pi1.newSubGroupId;
                    found = true
                end
            end

            if not found then
                for j = 1,40 do
                    local pi2 = ReturnRaidManager.PlayerInfoByRaidIndex[j]

                    if pi2 and pi2.currentSubGroupId == pi1.newSubGroupId and pi2.currentSubGroupId ~= pi2.newSubGroupId then
                        SwapRaidSubgroup(pi1.raidIndex, pi2.raidIndex)
                        pi2.currentSubGroupId = pi1.currentSubGroupId;
                        pi1.currentSubGroupId = pi1.newSubGroupId;
                        found = true
                    end
                end
            end

            if not found then
                SetRaidSubgroup(pi1.raidIndex, pi1.newSubGroupId)
                pi1.currentSubGroupId = pi1.newSubGroupId;
            end
        end
    end

end


function ReturnRaidManager:CheckName(editbox)

    text = editbox:GetText()

    if string.len(text) < 3 then
        return
    end

    for i = 1,40 do
        name, _, _, _, _, class = GetRaidRosterInfo(i)
        if text == name then
            local color = ReturnRaidManager.Constants.ClassColors[class]
            editbox:SetTextColor(color.r, color.g, color.b, 1)
            return
        end
    end

    numTotalMembers = GetNumGuildMembers();
    for i = 1,numTotalMembers do
        name, _, _, _, class = GetGuildRosterInfo(i)
        if text == name then
            local color = ReturnRaidManager.Constants.ClassColors[class]
            editbox:SetTextColor(color.r, color.g, color.b, 0.5)
            return
        end
    end

    editbox:SetTextColor(1, 0, 0)
end

function ReturnRaidManager:KickInvitePlayers()

    playerName = UnitName("player")
    playerRank = 0
    for i = 1,40 do
        name, rank = GetRaidRosterInfo(i)
        if name == playerName then
            playerRank = rank
        end
    end

    if playerRank == 0 then
        self:Print("Removing and Inviting players to the raid requires raid lead or assist.")
        return
    end

    layout = {}
    for i = 1, 40 do
        name = ReturnRaidManager.UI["NameBox"..i]:GetText()
        if name and string.len(name) > 2 then
            layout[name] = name
        end
    end

    raid = {}
    for i = 1,40 do
        name, rank = GetRaidRosterInfo(i)
        if name then
            if layout[name] then
                raid[name] = name
            else               
                if rank > playerRank then
                    self:Print("Can't remove raid leader " .. name .. " from the raid.")
                else
                    UninviteByName(name)
                end
            end
        end
    end

    for i, name in layout do
        if raid[name] == nil then  
            InviteByName(name)
        end
    end

end