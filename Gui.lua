
ReturnRaidManager.Constants = {}
ReturnRaidManager.Constants.ClassColors = {
    HUNTER = {r = 0.67, g = 0.83, b = 0.45},
    WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
    PRIEST = {r = 1.0, g = 1.0, b = 1.0},
    PALADIN = {r = 0.96, g = 0.55, b = 0.73},
    MAGE = {r = 0.41, g = 0.8, b = 0.94},
    ROGUE = {r = 1.0, g = 0.96, b = 0.41},
    DRUID = {r = 1.0, g = 0.49, b = 0.04},
    SHAMAN = {r = 0.14, g = 0.35, b = 1.0},
    WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
}


ReturnRaidManager.UI = nil
ReturnRaidManager.ImportLayoutFrame = nil


function ReturnRaidManager:CheckName(editbox)

    text = editbox:GetText()

    if string.len(text) < 3 then
        return
    end

    for i = 1,40 do
        name, _, _, _, _, class = GetRaidRosterInfo(i)
        if text == name then
            color = ReturnRaidManager.Constants.ClassColors[class]
            editbox:SetTextColor(color.r, color.g, color.b)
            return
        end
    end

    editbox:SetTextColor(1, 0, 0)
end


function ReturnRaidManager:CreateNameBox(idx)

    local editbox = CreateFrame("Editbox", "NameBox"..idx, ReturnRaidManager.UI, "InputBoxTemplate")
    editbox:SetHeight(20)
	editbox:SetWidth(75)
    editbox:SetAutoFocus(nil)

    local x = 20 + floor((idx - 1) / 5) * (15 + 75)
    local y = -70 - math.mod(idx - 1, 5) * 25
    
    editbox:SetPoint("TOPLEFT", ReturnRaidManager.UI, "TOPLEFT", x, y)
    editbox:SetScript("OnTextChanged", function() self:CheckName(editbox) end)

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
        ReturnRaidManager.UI.title:SetText("Return Raid Manger")
        
        for i = 1,40 do
            ReturnRaidManager.UI["NameBox" .. i] = self:CreateNameBox(i)
        end


        ReturnRaidManager.UI.ImportBox = CreateFrame("Editbox", "ImportBox", ReturnRaidManager.UI)
        ReturnRaidManager.UI.ImportBox:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        ReturnRaidManager.UI.ImportBox:SetTextInsets(10, 10, 10, 10)
        ReturnRaidManager.UI.ImportBox:SetBackdropColor(0, 0, 0)
        ReturnRaidManager.UI.ImportBox:SetBackdropBorderColor(0.3, 0.3, 0.3)
        ReturnRaidManager.UI.ImportBox:SetMultiLine(true)
        ReturnRaidManager.UI.ImportBox:SetHeight(200)
        ReturnRaidManager.UI.ImportBox:SetWidth(665)
        ReturnRaidManager.UI.ImportBox:SetPoint("TOPLEFT", ReturnRaidManager.UI, "TOPLEFT", 20, -220)
        ReturnRaidManager.UI.ImportBox:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -20, 50)
        ReturnRaidManager.UI.ImportBox:SetAutoFocus(nil)
        ReturnRaidManager.UI.ImportBox:SetFont("Fonts/FRIZQT__.TTF", 14)
        ReturnRaidManager.UI.ImportBox:SetJustifyH("LEFT")
        ReturnRaidManager.UI.ImportBox:SetJustifyV("CENTER")
		ReturnRaidManager.UI.ImportBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)

        ReturnRaidManager.UI.ImportBox.title = ReturnRaidManager.UI.ImportBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        ReturnRaidManager.UI.ImportBox.title:SetPoint("TOPLEFT", ReturnRaidManager.UI.ImportBox, "TOPLEFT", 0, 15)
        ReturnRaidManager.UI.ImportBox.title:SetShadowColor(0, 0, 0)
        ReturnRaidManager.UI.ImportBox.title:SetShadowOffset(0.8, -0.8)
        ReturnRaidManager.UI.ImportBox.title:SetTextColor(1, 1, 0)
        ReturnRaidManager.UI.ImportBox.title:SetText("Import String")


        ReturnRaidManager.UI.CloseButton = CreateFrame("Button", "CloseButton", ReturnRaidManager.UI, "UIPanelCloseButton")
        ReturnRaidManager.UI.CloseButton:SetPoint("TOPRIGHT", ReturnRaidManager.UI, "TOPRIGHT", 0, 0)
        
        ReturnRaidManager.UI.LoadCurrentButton = CreateFrame("Button", "LoadCurrentButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.LoadCurrentButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -240, 10)
        ReturnRaidManager.UI.LoadCurrentButton:SetHeight(20)
        ReturnRaidManager.UI.LoadCurrentButton:SetWidth(100)
        ReturnRaidManager.UI.LoadCurrentButton:SetText("Load Current")
        ReturnRaidManager.UI.LoadCurrentButton:SetScript("OnClick", function() self:LoadCurrentRaidLayout() end)

        ReturnRaidManager.UI.ImportButton = CreateFrame("Button", "ImportButton", ReturnRaidManager.UI, "UIPanelButtonTemplate")
        ReturnRaidManager.UI.ImportButton:SetPoint("BOTTOMRIGHT", ReturnRaidManager.UI, "BOTTOMRIGHT", -130, 10)
        ReturnRaidManager.UI.ImportButton:SetHeight(20)
        ReturnRaidManager.UI.ImportButton:SetWidth(100)
        ReturnRaidManager.UI.ImportButton:SetText("Import")
        ReturnRaidManager.UI.ImportButton:SetScript("OnClick", function() self:ImportLayout() end)

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


function ReturnRaidManager:ImportLayout()

    text = ReturnRaidManager.UI.ImportBox:GetText()

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

            --color = ReturnRaidManager.Constants.ClassColors[class]
            --ReturnRaidManager.UI["NameBox"..nameBoxIdx]:SetTextColor(color.r, color.g, color.b)
        end
    end
end