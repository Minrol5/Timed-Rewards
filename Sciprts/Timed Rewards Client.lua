-- Note that getting AIO is done like this since AIO is defined on client
-- side by default when running addons and on server side it may need to be
-- required depending on the load order.
local AIO = AIO or require("AIO")

-- This will add this file to the server side list of addons to send to players.
-- The function is coded to get the path and file name automatically,
-- but you can also provide them yourself. AIO.AddAddon will return true if the
-- addon was added to the list of loaded addons, this means that if the
-- function returns true the file is being executed on server side and we
-- return since this is a client file. On client side the file will be executed
-- entirely.
if AIO.AddAddon() then
    return
end

-- AIO.AddHandlers adds a new table of functions as handlers for a name and returns the table.
-- This is used to add functions for a specific "channel name" that trigger on specific messages.
-- At this point the table is empty, but MyHandlers table will be filled soon.
local MyHandlers = AIO.AddHandlers("Rewards", {})


--Creating the Main Frame
Mainframe = CreateFrame("Frame", "BackgroundFrame", UIParent)
local frame = Mainframe
frame:SetSize(600, 300)
frame:SetPoint("CENTER", 0, 0)
frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0, 0, 0, 0.7)

-- Enable dragging of frame
frame:RegisterForDrag("LeftButton")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnHide", frame.StopMovingOrSizing)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

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
