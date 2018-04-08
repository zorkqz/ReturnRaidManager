
function ReturnRaidManager:CreateNameBox(idx)

    local editbox = CreateFrame("Editbox", "NameBox"..idx, ReturnRaidManager.UI, "InputBoxTemplate")
    editbox:SetHeight(20)
	editbox:SetWidth(75)
    editbox:SetAutoFocus(nil)

    local x = 20 + floor((idx - 1) / 5) * (15 + 75)
    local y = -70 - math.mod(idx - 1, 5) * 25
    editbox:SetPoint("TOPLEFT", ReturnRaidManager.UI, "TOPLEFT", x, y)

    editbox:SetScript("OnTextChanged", function() self:CheckName(editbox) end)
    editbox:SetScript("OnTabPressed", function() ReturnRaidManager.UI["NameBox" .. (math.mod(idx, 40) + 1)]:SetFocus() end)

    if math.mod(idx - 1, 5) == 0 then
        editbox.title = editbox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        editbox.title:SetPoint("TOP", editbox, "TOP", 0, 15)
        editbox.title:SetShadowColor(0, 0, 0)
        editbox.title:SetShadowOffset(0.8, -0.8)
        editbox.title:SetTextColor(1, 1, 0)
        editbox.title:SetText("Group " .. (floor((idx - 1) / 5) + 1))
    end

    return editbox
end


function ReturnRaidManager:CreateSavedLayoutButton(name, idx)

    button = ReturnRaidManager.UI["SavedLayoutButton" .. idx]

    if not button then
        button = CreateFrame('Button', "SavedLayoutButton" .. idx, ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI["SavedLayoutButton" .. idx] = button

        local x = 20 + floor(idx / 4) * 110
        local y = -210 + math.mod(idx, 4) * -25
    
        button:SetPoint('TOPLEFT', ReturnRaidManager.UI, 'TOPLEFT', x, y)
        button:SetHeight(20)
        button:SetWidth(100)

        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    end

    button:Show()
    button:SetText(name)
    button:SetScript("OnClick", function()
        if arg1 == "RightButton" then
            self:ToggleQuestionFrame("Do you really want to delete\nthe '" .. name .. "' layout?",
                                     function() self:RemoveSavedRaidLayout(name) end)
        else
            self:LoadSavedRaidLayout(name)
        end
    end)

end

function ReturnRaidManager:CreateSavedLayoutButtons()

    local names = {}
    for name, layout in pairs(self.db.account.SavedLayouts) do
        if layout then
            table.insert(names, name)
        end
    end

    table.sort(names)

    local idx = 0
    button = ReturnRaidManager.UI["SavedLayoutButton" .. idx]
    while button do
        button:Hide()
        idx = idx + 1
        button = ReturnRaidManager.UI["SavedLayoutButton" .. idx]
    end

    ReturnRaidManager.UI.SavedLayoutIdx = 0
    for _, name in ipairs(names) do
        self:CreateSavedLayoutButton(name, ReturnRaidManager.UI.SavedLayoutIdx)
        ReturnRaidManager.UI.SavedLayoutIdx = ReturnRaidManager.UI.SavedLayoutIdx + 1
    end
end

function ReturnRaidManager:ToggleUI()

    if not ReturnRaidManager.UI then
 
        ReturnRaidManager.UI = CreateFrame("Frame", "ReturnRaidManagerUI", UIParent);
        ReturnRaidManager.UI:SetWidth(745)
        ReturnRaidManager.UI:SetHeight(360)
        ReturnRaidManager.UI:SetPoint("CENTER", 0, 0)
        ReturnRaidManager.UI:SetFrameStrata("DIALOG")
        
        ReturnRaidManager.UI:Hide()

        ReturnRaidManager.UI:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            tile = true,
            tileSize = 16,
            insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
        })
        ReturnRaidManager.UI:SetBackdropColor(0, 0, 0, 1)

        ReturnRaidManager.UI:EnableMouse(true)
        ReturnRaidManager.UI:SetMovable(true)
        ReturnRaidManager.UI:SetScript("OnMouseDown", function() this:StartMoving() end)
        ReturnRaidManager.UI:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)

        ReturnRaidManager.UI.title = ReturnRaidManager.UI:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
        ReturnRaidManager.UI.title:SetPoint("TOP", ReturnRaidManager.UI, "TOP", 0, -10)
        ReturnRaidManager.UI.title:SetShadowColor(0, 0, 0)
        ReturnRaidManager.UI.title:SetShadowOffset(0.8, -0.8)
        ReturnRaidManager.UI.title:SetTextColor(1,1,1)
        ReturnRaidManager.UI.title:SetText("Return Raid Manager")
        
        for i = 1,40 do
            ReturnRaidManager.UI["NameBox" .. i] = self:CreateNameBox(i)
        end

        self:CreateSavedLayoutButtons()

        ReturnRaidManager.UI.CloseButton = CreateFrame("Button", "CloseButton", ReturnRaidManager.UI, "UIPanelCloseButton")
        ReturnRaidManager.UI.CloseButton:SetPoint("TOPRIGHT", ReturnRaidManager.UI, "TOPRIGHT", 0, 0)
        
        ReturnRaidManager.UI.LoadCurrentButton = CreateFrame("Button", "LoadCurrentButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.LoadCurrentButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -460, 10)
        ReturnRaidManager.UI.LoadCurrentButton:SetHeight(20)
        ReturnRaidManager.UI.LoadCurrentButton:SetWidth(100)
        ReturnRaidManager.UI.LoadCurrentButton:SetText("Load Current")
        ReturnRaidManager.UI.LoadCurrentButton:SetScript("OnClick", function() self:LoadCurrentRaidLayout() end)

        ReturnRaidManager.UI.SaveButton = CreateFrame("Button", "SaveButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.SaveButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -350, 10)
        ReturnRaidManager.UI.SaveButton:SetHeight(20)
        ReturnRaidManager.UI.SaveButton:SetWidth(100)
        ReturnRaidManager.UI.SaveButton:SetText("Save")
        ReturnRaidManager.UI.SaveButton:SetScript("OnClick", function() self:ToggleSaveCurrentRaidLayoutFrame() end)

        ReturnRaidManager.UI.ImportButton = CreateFrame("Button", "ImportButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.ImportButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -240, 10)
        ReturnRaidManager.UI.ImportButton:SetHeight(20)
        ReturnRaidManager.UI.ImportButton:SetWidth(100)
        ReturnRaidManager.UI.ImportButton:SetText("Import")
        ReturnRaidManager.UI.ImportButton:SetScript("OnClick", function() self:ToggleImportLayoutFrame() end)

        ReturnRaidManager.UI.KickInvButton = CreateFrame("Button", "KickInvButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.KickInvButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -130, 10)
        ReturnRaidManager.UI.KickInvButton:SetHeight(20)
        ReturnRaidManager.UI.KickInvButton:SetWidth(100)
        ReturnRaidManager.UI.KickInvButton:SetText("Kick/Invite")
        ReturnRaidManager.UI.KickInvButton:SetScript("OnClick", function()
            self:ToggleQuestionFrame("Do you really want to remove all players\nnot in the current layout from the raid?",
                                     function() self:KickInvitePlayers() end)
        end)

        ReturnRaidManager.UI.ExecuteButton = CreateFrame("Button", "ExecuteButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.ExecuteButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -20, 10)
        ReturnRaidManager.UI.ExecuteButton:SetHeight(20)
        ReturnRaidManager.UI.ExecuteButton:SetWidth(100)
        ReturnRaidManager.UI.ExecuteButton:SetText("Execute")
        ReturnRaidManager.UI.ExecuteButton:SetScript("OnClick", function() self:ExecuteLayout() end)
    end

    if ReturnRaidManager.UI:IsVisible() then
        ReturnRaidManager.UI:Hide()
    else
        ReturnRaidManager.UI:Show()
    end

end

function ReturnRaidManager:ToggleQuestionFrame(text, func)

    if not ReturnRaidManager.QuestionFrame then

        ReturnRaidManager.QuestionFrame = CreateFrame("Frame", "QuestionFrame", ReturnRaidManager.UI);
        ReturnRaidManager.QuestionFrame:SetWidth(300)
        ReturnRaidManager.QuestionFrame:SetHeight(80)
        ReturnRaidManager.QuestionFrame:SetPoint("CENTER", 0, 0)
        ReturnRaidManager.QuestionFrame:SetFrameStrata("FULLSCREEN")

        ReturnRaidManager.QuestionFrame:Hide()

        ReturnRaidManager.QuestionFrame:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16, edgeSize = 16, 
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        ReturnRaidManager.QuestionFrame:SetBackdropColor(0, 0, 0, 1)

        ReturnRaidManager.QuestionFrame:SetBackdropColor(0, 0, 0, 1)

        ReturnRaidManager.QuestionFrame.title = ReturnRaidManager.QuestionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ReturnRaidManager.QuestionFrame.title:SetPoint("TOP", ReturnRaidManager.QuestionFrame, "TOP", 0, -10)
        ReturnRaidManager.QuestionFrame.title:SetShadowColor(0, 0, 0)
        ReturnRaidManager.QuestionFrame.title:SetShadowOffset(0.8, -0.8)
        ReturnRaidManager.QuestionFrame.title:SetTextColor(1,1,1)

        ReturnRaidManager.QuestionFrame.CloseButton = CreateFrame("Button", "QuestionFrameCloseButton", ReturnRaidManager.QuestionFrame, "UIPanelCloseButton")
        ReturnRaidManager.QuestionFrame.CloseButton:SetPoint("TOPRIGHT", ReturnRaidManager.QuestionFrame, "TOPRIGHT", 0, 0)

        ReturnRaidManager.QuestionFrame.YesButton = CreateFrame("Button", "QuestionFrameYesButton", ReturnRaidManager.QuestionFrame, "UIPanelButtonTemplate")
        ReturnRaidManager.QuestionFrame.YesButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.QuestionFrame, "BOTTOMRIGHT", -130, 10)
        ReturnRaidManager.QuestionFrame.YesButton:SetHeight(20)
        ReturnRaidManager.QuestionFrame.YesButton:SetWidth(100)
        ReturnRaidManager.QuestionFrame.YesButton:SetText("Yes")

        ReturnRaidManager.QuestionFrame.CancelButton = CreateFrame("Button", "QuestionFrameCancelButton", ReturnRaidManager.QuestionFrame, "UIPanelButtonTemplate")
        ReturnRaidManager.QuestionFrame.CancelButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.QuestionFrame, "BOTTOMRIGHT", -20, 10)
        ReturnRaidManager.QuestionFrame.CancelButton:SetHeight(20)
        ReturnRaidManager.QuestionFrame.CancelButton:SetWidth(100)
        ReturnRaidManager.QuestionFrame.CancelButton:SetText("Cancel")
        ReturnRaidManager.QuestionFrame.CancelButton:SetScript("OnClick", function() 
                self:ToggleQuestionFrame()
            end)
    end

    if ReturnRaidManager.QuestionFrame:IsVisible() then
        ReturnRaidManager.QuestionFrame:Hide()
    else
        ReturnRaidManager.QuestionFrame.title:SetText(text)

        ReturnRaidManager.QuestionFrame.YesButton:SetScript("OnClick", function() 
            func()
            self:ToggleQuestionFrame()
        end)

        ReturnRaidManager.QuestionFrame:Show()
    end

end

function ReturnRaidManager:ToggleSaveCurrentRaidLayoutFrame()

    if not ReturnRaidManager.SaveLayoutFrame then

        ReturnRaidManager.SaveLayoutFrame = CreateFrame("Frame", "ReturnRaidManagerSaveLayoutFrame", ReturnRaidManager.UI);
        ReturnRaidManager.SaveLayoutFrame:SetWidth(140)
        ReturnRaidManager.SaveLayoutFrame:SetHeight(120)
        ReturnRaidManager.SaveLayoutFrame:SetPoint("CENTER", 0, 0)
        ReturnRaidManager.SaveLayoutFrame:SetFrameStrata("FULLSCREEN")

        ReturnRaidManager.SaveLayoutFrame:Hide()

        ReturnRaidManager.SaveLayoutFrame:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16, edgeSize = 16, 
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        ReturnRaidManager.SaveLayoutFrame:SetBackdropColor(0, 0, 0, 1)

        ReturnRaidManager.SaveLayoutFrame.title = ReturnRaidManager.SaveLayoutFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
        ReturnRaidManager.SaveLayoutFrame.title:SetPoint("TOP", ReturnRaidManager.SaveLayoutFrame, "TOP", 0, -10)
        ReturnRaidManager.SaveLayoutFrame.title:SetShadowColor(0, 0, 0)
        ReturnRaidManager.SaveLayoutFrame.title:SetShadowOffset(0.8, -0.8)
        ReturnRaidManager.SaveLayoutFrame.title:SetTextColor(1,1,1)
        ReturnRaidManager.SaveLayoutFrame.title:SetText("Save")


        ReturnRaidManager.SaveLayoutFrame.SaveNameBox = CreateFrame("Editbox", "SaveNameBox", ReturnRaidManager.SaveLayoutFrame, "InputBoxTemplate")
        ReturnRaidManager.SaveLayoutFrame.SaveNameBox:SetHeight(20)
        ReturnRaidManager.SaveLayoutFrame.SaveNameBox:SetWidth(100)
        ReturnRaidManager.SaveLayoutFrame.SaveNameBox:SetAutoFocus(true)
        ReturnRaidManager.SaveLayoutFrame.SaveNameBox:SetPoint("TOPLEFT", ReturnRaidManager.SaveLayoutFrame, "TOPLEFT", 20, -50)
        
        ReturnRaidManager.SaveLayoutFrame.CloseButton = CreateFrame("Button", "SaveLayoutFrameCloseButton", ReturnRaidManager.SaveLayoutFrame, "UIPanelCloseButton")
        ReturnRaidManager.SaveLayoutFrame.CloseButton:SetPoint("TOPRIGHT", ReturnRaidManager.SaveLayoutFrame, "TOPRIGHT", 0, 0)

        ReturnRaidManager.SaveLayoutFrame.SaveButton = CreateFrame("Button", "SaveLayoutFrameSaveButton", ReturnRaidManager.SaveLayoutFrame, "UIPanelButtonTemplate")
        ReturnRaidManager.SaveLayoutFrame.SaveButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.SaveLayoutFrame, "BOTTOMRIGHT", -20, 10)
        ReturnRaidManager.SaveLayoutFrame.SaveButton:SetHeight(20)
        ReturnRaidManager.SaveLayoutFrame.SaveButton:SetWidth(100)
        ReturnRaidManager.SaveLayoutFrame.SaveButton:SetText("Save")
        ReturnRaidManager.SaveLayoutFrame.SaveButton:SetScript("OnClick", function() 
                self:SaveCurrentRaidLayout(ReturnRaidManager.SaveLayoutFrame.SaveNameBox:GetText())
                self:ToggleSaveCurrentRaidLayoutFrame()
            end)
    end

    if ReturnRaidManager.SaveLayoutFrame:IsVisible() then
        ReturnRaidManager.SaveLayoutFrame:Hide()
    else
        ReturnRaidManager.SaveLayoutFrame.SaveNameBox:SetText(ReturnRaidManager.UI.LoadedRaidLayout or "")
        ReturnRaidManager.SaveLayoutFrame:Show()
        ReturnRaidManager.SaveLayoutFrame.SaveNameBox:SetFocus()
    end

end


function ReturnRaidManager:ToggleImportLayoutFrame()

    if not ReturnRaidManager.ImportLayoutFrame then

        ReturnRaidManager.ImportLayoutFrame = CreateFrame("Frame", "ReturnRaidManagerImportLayoutFrame", ReturnRaidManager.UI);
        ReturnRaidManager.ImportLayoutFrame:SetWidth(520)
        ReturnRaidManager.ImportLayoutFrame:SetHeight(180)
        ReturnRaidManager.ImportLayoutFrame:SetPoint("CENTER", 0, 0)
        ReturnRaidManager.ImportLayoutFrame:SetFrameStrata("FULLSCREEN")

        ReturnRaidManager.ImportLayoutFrame:Hide()

        ReturnRaidManager.ImportLayoutFrame:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16, edgeSize = 16, 
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        ReturnRaidManager.ImportLayoutFrame:SetBackdropColor(0, 0, 0, 1)

        ReturnRaidManager.ImportLayoutFrame.title = ReturnRaidManager.ImportLayoutFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
        ReturnRaidManager.ImportLayoutFrame.title:SetPoint("TOP", ReturnRaidManager.ImportLayoutFrame, "TOP", 0, -10)
        ReturnRaidManager.ImportLayoutFrame.title:SetShadowColor(0, 0, 0)
        ReturnRaidManager.ImportLayoutFrame.title:SetShadowOffset(0.8, -0.8)
        ReturnRaidManager.ImportLayoutFrame.title:SetTextColor(1,1,1)
        ReturnRaidManager.ImportLayoutFrame.title:SetText("Import")

        ReturnRaidManager.ImportLayoutFrame.ImportBox = CreateFrame("Editbox", "ImportBox", ReturnRaidManager.ImportLayoutFrame)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetTextInsets(10, 10, 10, 10)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetBackdropColor(0, 0, 0)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetBackdropBorderColor(0.3, 0.3, 0.3)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetMultiLine(true)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetHeight(200)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetWidth(665)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetPoint("TOPLEFT", ReturnRaidManager.ImportLayoutFrame, "TOPLEFT", 20, -50)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetPoint("BOTTOMRIGHT", ReturnRaidManager.ImportLayoutFrame, "BOTTOMRIGHT", -20, 50)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetAutoFocus(true)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetFont("Fonts/FRIZQT__.TTF", 10)
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetJustifyH("LEFT")
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetJustifyV("CENTER")
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)

        ReturnRaidManager.ImportLayoutFrame.CloseButton = CreateFrame("Button", "ImportLayoutFrameCloseButton", ReturnRaidManager.ImportLayoutFrame, "UIPanelCloseButton")
        ReturnRaidManager.ImportLayoutFrame.CloseButton:SetPoint("TOPRIGHT", ReturnRaidManager.ImportLayoutFrame, "TOPRIGHT", 0, 0)

        ReturnRaidManager.ImportLayoutFrame.ImportButton = CreateFrame("Button", "ImportLayoutFrameImportButton", ReturnRaidManager.ImportLayoutFrame, "UIPanelButtonTemplate")
        ReturnRaidManager.ImportLayoutFrame.ImportButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.ImportLayoutFrame, "BOTTOMRIGHT", -20, 10)
        ReturnRaidManager.ImportLayoutFrame.ImportButton:SetHeight(20)
        ReturnRaidManager.ImportLayoutFrame.ImportButton:SetWidth(100)
        ReturnRaidManager.ImportLayoutFrame.ImportButton:SetText("Import")
        ReturnRaidManager.ImportLayoutFrame.ImportButton:SetScript("OnClick", function()
                self:ImportLayout()
                self:ToggleImportLayoutFrame()
            end)
    end

    if ReturnRaidManager.ImportLayoutFrame:IsVisible() then
        ReturnRaidManager.ImportLayoutFrame:Hide()
    else
        ReturnRaidManager.ImportLayoutFrame:Show()
        ReturnRaidManager.ImportLayoutFrame.ImportBox:SetFocus()
    end
end



function ReturnRaidManager:LoadSavedRaidLayout(name)

    for i = 1, 40 do
        ReturnRaidManager.UI["NameBox"..i]:SetText("")
    end

    layout = self.db.account.SavedLayouts[name]

    for i = 1, 40 do
        ReturnRaidManager.UI["NameBox"..i]:SetText(layout[i])
    end

    ReturnRaidManager.UI.LoadedRaidLayout = name
end

function ReturnRaidManager:RemoveSavedRaidLayout(name)
    if  self.db.account.SavedLayouts[name] then 
        self.db.account.SavedLayouts[name] = nil
        self:CreateSavedLayoutButtons()
    end
end

function ReturnRaidManager:SaveCurrentRaidLayout(name)

    layout = {}
    for i = 1, 40 do
        text = ReturnRaidManager.UI["NameBox"..i]:GetText()
        table.insert(layout, text)
    end

    local isNew = self.db.account.SavedLayouts[name] == nil

    self.db.account.SavedLayouts[name] = layout
    ReturnRaidManager.UI.LoadedRaidLayout = name

    if isNew then
        self:CreateSavedLayoutButtons()
    end

end


function ReturnRaidManager:ImportLayout()

    for i = 1, 40 do
        ReturnRaidManager.UI["NameBox"..i]:SetText("")
    end

    text = ReturnRaidManager.ImportLayoutFrame.ImportBox:GetText()

    words = {}
    for word in string.gfind(text, "(%w+)") do
        table.insert(words, word)
    end

    for i, w in words do 
        local idx = math.mod(i - 1, 8) * 5 + floor((i - 1) / 8) + 1
        ReturnRaidManager.UI["NameBox"..idx]:SetText(w)
    end

end

function ReturnRaidManager:LoadCurrentRaidLayout()

    for i = 1, 40 do
        ReturnRaidManager.UI["NameBox"..i]:SetText("")
    end

    local subGroupIdxs = {0, 0, 0, 0, 0, 0, 0, 0}
    
    for i = 1, 40 do
        name, _, subgroup, _, _, class = GetRaidRosterInfo(i);

        if name then
            subGroupIdxs[subgroup] = subGroupIdxs[subgroup] + 1
            nameBoxIdx = subGroupIdxs[subgroup] + 5 * (subgroup - 1)
            ReturnRaidManager.UI["NameBox"..nameBoxIdx]:SetText(name)
        end
    end
end