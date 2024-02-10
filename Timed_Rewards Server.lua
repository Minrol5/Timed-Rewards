local AIO = AIO or require("AIO")

-- Table to store reward data during server startup
local rewardData = {
    Daily = {},
    Weekly = {},
}

-- Table to store player timestamps in memory
local playerTimestamps = {}

-- Function to load reward data from the database during server startup
local function LoadRewardData()
    local query = WorldDBQuery("SELECT Type, Item1, Amount1, Item2, Amount2, Item3, Amount3, Item4, Amount4 FROM timed_rewards")

    if query then
        repeat
            local rewardType = query:GetString(0)
            local reward = {
                item1 = query:GetUInt32(1),
                amount1 = query:GetUInt32(2),
                item2 = query:GetUInt32(3),
                amount2 = query:GetUInt32(4),
                item3 = query:GetUInt32(5),
                amount3 = query:GetUInt32(6),
                item4 = query:GetUInt32(7),
                amount4 = query:GetUInt32(8),
            }

            if not rewardData[rewardType] then
                rewardData[rewardType] = {}
            end

            table.insert(rewardData[rewardType], reward)
        until not query:NextRow()
    end
end

-- Call the function to load reward data during server startup
LoadRewardData()

local MyHandlers = AIO.AddHandlers("Rewards", {})

-- Function to check and create a player entry in memory
local function CheckAndCreatePlayerEntry(player)
    --local playerGuid = player:GetGUIDLow()
    local playerGuid = player:GetGetGUIDLow()

    if not playerTimestamps[playerGuid] then
        playerTimestamps[playerGuid] = {
            Daily = 0,
            Weekly = 0,
        }

        -- Load player timestamps from the database on login
        local query = WorldDBQuery("SELECT id, daily, weekly FROM timed_times WHERE id = " .. playerGuid)
        if not query then
            -- If there is no entry in the database, create a new one
            WorldDBExecute("INSERT INTO timed_times (id, daily, weekly) VALUES (" .. playerGuid .. ", 0, 0)")
        else
            local row = query:GetRow()
            if row then
                playerTimestamps[playerGuid].Daily = tonumber(row["daily"]) or 0
                playerTimestamps[playerGuid].Weekly = tonumber(row["weekly"]) or 0
            end
        end
    end
end

-- Function to save execution time in memory and update the database
local function SaveExecutionTime(player, timestamp, rewardType)
    --local playerGuid = player:GetGUIDLow()
    local playerGuid = player:GetGUIDLow()
    playerTimestamps[playerGuid][rewardType] = timestamp

    -- Update the database with the new timestamp
    local queryStr = string.format("UPDATE timed_times SET %s = %d WHERE id = %d", rewardType, timestamp, playerGuid)
    WorldDBExecute(queryStr)
end

-- Function to get the last execution time from memory
local function GetLastExecutionTime(player, rewardType)
    --local playerGuid = player:GetGUIDLow()
    local playerGuid = player:GetGetGUIDLow()
    return playerTimestamps[playerGuid][rewardType] or 0
end

-- Function to give daily/weekly rewards to the player via mail
local function HandleRewardsViaMail(player, rewardType)
    -- Check if there are rewards defined for the given rewardType
    if rewardData[rewardType] and #rewardData[rewardType] > 0 then
        -- Iterate through the rewards and send them to the player via mail
        for _, reward in ipairs(rewardData[rewardType]) do
            for i = 1, 4 do
                local item = reward["item" .. i]
                local amount = reward["amount" .. i]

                -- Check if the item and amount are valid
                if item and amount and item ~= 0 and amount ~= 0 then
                    local itemGUIDLow = SendMail("Reward", "Congratulations! You have received a reward.", player:GetGUIDLow(), 0, 61, 0, 0, 0, item, amount)
                end
            end
        end
    end
end

-- Function to handle daily rewards using memory instead of DB queries
function MyHandlers.Daily(player, ...)
    CheckAndCreatePlayerEntry(player)

    local currentTimestamp = os.time()
    local lastExecutionTime = GetLastExecutionTime(player, "Daily")

    if (currentTimestamp - lastExecutionTime) >= (24 * 60 * 60) then
        SaveExecutionTime(player, currentTimestamp, "Daily")
        HandleRewardsViaMail(player, "Daily")
        player:SendBroadcastMessage("You have been awarded your daily items via Mail! :)")
    else
        local remainingTime = (24 * 60 * 60) - (currentTimestamp - lastExecutionTime)
        local remainingHours = math.floor(remainingTime / 3600)
        local remainingMinutes = math.floor((remainingTime % 3600) / 60)
        local remainingSeconds = remainingTime % 60
        local remainingTimeString = string.format("%d hours, %d minutes, and %d seconds", remainingHours, remainingMinutes, remainingSeconds)

        SendWorldMessage("You still need to wait " .. remainingTimeString .. " before claiming this reward again.", player)
    end
end

-- Function to handle weekly rewards using memory instead of DB queries
function MyHandlers.Weekly(player, ...)
    CheckAndCreatePlayerEntry(player)

    local currentTimestamp = os.time()
    local lastExecutionTime = GetLastExecutionTime(player, "Weekly")

    if (currentTimestamp - lastExecutionTime) >= (7 * 24 * 60 * 60) then
        SaveExecutionTime(player, currentTimestamp, "Weekly")
        HandleRewardsViaMail(player, "Weekly")
        player:SendBroadcastMessage("You have been awarded your weekly items via Mail! :)")
    else
        local remainingTime = (7 * 24 * 60 * 60) - (currentTimestamp - lastExecutionTime)
        local remainingDays = math.floor(remainingTime / (24 * 60 * 60))
        local remainingHours = math.floor((remainingTime % (24 * 60 * 60)) / 3600)
        local remainingMinutes = math.floor((remainingTime % 3600) / 60)
        local remainingSeconds = remainingTime % 60
        local remainingTimeString = string.format("%d days, %d hours, %d minutes, and %d seconds", remainingDays, remainingHours, remainingMinutes, remainingSeconds)

        SendWorldMessage("You still need to wait " .. remainingTimeString .. " before claiming this reward again.", player)
    end
end

local function OnCommand(event, player, command)
    if command == "rewards" or command == "rw" then
        AIO.Handle(player, "Rewards", "RewardFrame")
        return false
    end
end

RegisterPlayerEvent(42, OnCommand)  -- Use the correct event for player login (Event: PLAYER_LOGIN)
