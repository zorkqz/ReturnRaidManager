
ReturnRaidManager = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0")
ReturnRaidManager:RegisterChatCommand({"/ReturnRaidManager", "/rrm"}, {type = 'execute', func = "ToggleUI"})


ReturnRaidManager.PlayerInfoByName = {}
ReturnRaidManager.PlayerInfoByRaidIndex = {}
function ReturnRaidManager:UpdatePlayerInfo()

    ReturnRaidManager.PlayerInfoByName = {}
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
                --class = ReturnRaidManager.PlayerInfoByName[name].class,
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

    for i = 1,39 do
        pi1 = ReturnRaidManager.PlayerInfoByRaidIndex[i]

        if pi1 and pi1.newSubGroupId and pi1.currentSubGroupId ~= pi1.newSubGroupId then

            found = false
            for j = i,40 do
                pi2 = ReturnRaidManager.PlayerInfoByRaidIndex[j]
                
                if pi2 and pi2.currentSubGroupId == pi1.newSubGroupId then
                    SwapRaidSubgroup(pi1.raidIndex, pi2.raidIndex)
                    pi2.currentSubGroupId = pi1.currentSubGroupId;
                    pi1.currentSubGroupId = pi1.newSubGroupId;
                    found = true
                end
            end

            if not found then
                SetRaidSubgroup(pi1.raidIndex, pi1.newSubGroupId)
                pi1.currentSubGroupId = pi1.newSubGroupId;
            end
        end
    end

end