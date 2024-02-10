
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local MyHandlers = AIO.AddHandlers("Rewards", {})

-- Creating the Main Frame
local MainFrame = CreateFrame("Frame", "BackgroundFrame", UIParent)
local frame = MainFrame
local minWidth, minHeight = 500, 150  -- Mindestgröße des Frames
frame:SetSize(500, 200)  -- Startgröße des Frames
frame:SetPoint("TOPLEFT", UIParent, "CENTER", -150, 100)  -- Startposition des Frames
frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0, 0, 0, 0.7)

-- Enable Mouse on Window
frame:RegisterForDrag("LeftButton")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetResizable(true) 
frame:SetMinResize(minWidth, minHeight)
frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
frame:Hide()

-- Enables Moving the Window
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
frame:SetScript("OnHide", function(self)
    self:StopMovingOrSizing()
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Enabling resizing of the frame
frame:SetScript("OnSizeChanged", function(self, width, height)
    -- Set a max and min Size
    if width < minWidth then
        self:SetSize(minWidth, height)
    end
    if height < minHeight then
        self:SetSize(width, minHeight)
    end
end)

-- Mini resizing icon in the corner
local resizeButton = CreateFrame("Button", nil, frame)
resizeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
resizeButton:SetSize(16, 16)
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight", "ADD")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeButton:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        frame:StartSizing("BOTTOMRIGHT")
        self:GetHighlightTexture():Hide()
    end
end)

resizeButton:SetScript("OnMouseUp", function(self, button)
    frame:StopMovingOrSizing()
    self:GetHighlightTexture():Show()
end)


---Creating a Title for the box
local fs = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
fs:SetFont("Fonts\\FRIZQT__.TTF", 14)
fs:SetShadowOffset(1, -1)
fs:SetPoint("TOP", 0, -10)
fs:SetText("|cffedd100Daily And Weekly Reward|r")

-- Adding in the closure button
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function(self)
    frame:Hide()
end)

-- First 24/H Reward Button
local button = CreateFrame("Button", "Test", frame, "UIPanelButtonTemplate")
button:SetPoint("Bottomleft", 50, 50)
button:SetSize(200, 40)
button:SetText("Click for Daily Reward")
button:SetPoint("CENTER", frame, "CENTER")
button:EnableMouse(true)
--First Button // Daily Reward Button Function
local function OnClickButton(btn)
    AIO.Handle("Rewards", "Daily")
    frame:Hide()
end
button:SetScript("OnClick", OnClickButton)

--Seocond Button Weekly Reward
local button1 = CreateFrame("Button", "Test", frame, "UIPanelButtonTemplate")
button1:SetPoint("Bottomright", -30, 50)
button1:SetSize(200, 40)
button1:SetText("Click for Weekly Reward")
button1:SetPoint("CENTER", frame, "CENTER")
button1:EnableMouse(true)
--Second Button // Weekly Reward Button Function
local function OnClickButton(btn)
    AIO.Handle("Rewards", "Weekly")
    frame:Hide()
end
button1:SetScript("OnClick", OnClickButton)

-- This enables saving of the position of the frame over reload of the UI or restarting game
AIO.SavePosition(frame)

function MyHandlers.RewardFrame(player)
    frame:Show()
end

