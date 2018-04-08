
function ReturnRaidManagerButton_OnClick()
	ReturnRaidManager:ToggleUI()
end

function ReturnRaidManagerButton_Init()
    ReturnRaidManagerButtonFrame:Show()
end

function ReturnRaidManagerButton_UpdatePosition()

    radius = ReturnRaidManager.db.char.MinimapButtonRadius
    position = ReturnRaidManager.db.char.MinimapButtonPosition

	ReturnRaidManagerButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		54 - (radius * cos(position)),
		(radius * sin(position)) - 55
    )

end

function ReturnRaidManagerButton_BeingDragged()
    local xpos,ypos = GetCursorPosition() 
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom() 
    xpos = xmin-xpos/UIParent:GetScale()+70 
    ypos = ypos/UIParent:GetScale()-ymin-70
    ReturnRaidManagerButton_SetPosition(math.sqrt(xpos * xpos + ypos * ypos), math.deg(math.atan2(ypos,xpos)))
end

function ReturnRaidManagerButton_SetPosition(r, p)
    if(p < 0) then
        p = p + 360
    end

    ReturnRaidManager.db.char.MinimapButtonRadius = r
    ReturnRaidManager.db.char.MinimapButtonPosition = p
    ReturnRaidManagerButton_UpdatePosition()
end

function ReturnRaidManagerButton_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("Return Raid Manager")
	GameTooltipTextLeft1:SetTextColor(1, 1, 1)
    GameTooltip:AddLine("Left-click to open Return Raid Manager.\nRight-click to move icon.")
    GameTooltip:Show()
end