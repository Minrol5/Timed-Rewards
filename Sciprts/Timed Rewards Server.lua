local AIO = AIO or require("AIO")

local MyHandlers = AIO.AddHandlers("Rewards", {})

local function CheckAndCreateTimedTimesEntry(player, rewardType)
    local playerGuid = player:GetGUIDLow()

    -- Checks if the player has an DB entry
    local existingEntry = WorldDBQuery("SELECT id FROM timed_times WHERE id = " .. playerGuid)

    if not existingEntry then
        -- When the player has no DB entry it will be created
        WorldDBExecute("INSERT INTO timed_times (id, Daily, Weekly) VALUES (" .. playerGuid .. ", 0, 0)")
    end
    
    -- Choose the right time stamp for the given reward type
    local defaultTimestamp = os.time()
    WorldDBExecute("UPDATE timed_times SET " .. rewardType .. " = " .. defaultTimestamp .. " WHERE id = " .. playerGuid)
end


local function SaveExecutionTime(player, timestamp, rewardType)
    --Get the player guid
    local playerGuid = player:GetGUIDLow()

    --Check if the player has a DB entry
    local existingEntry = WorldDBQuery("SELECT id FROM timed_times WHERE id = " .. playerGuid)

    if existingEntry then
        --When the player has an entry, update the time stamp based on the reward type
        local queryStr = "UPDATE timed_times SET " .. rewardType .. " = " .. timestamp .. " WHERE id = " .. playerGuid
        WorldDBExecute(queryStr)
    else
        --When the player has no entry, insert with the time stamp for the specific reward type
        local queryStr = "INSERT INTO timed_times (id, " .. rewardType .. ") VALUES (" .. playerGuid .. ", " .. timestamp .. ")"
        WorldDBExecute(queryStr)
    end
end

--Function to call the last timestamp from the DB
local function GetLastExecutionTime(player, rewardType)
    --Get the player GUID
    local playerGuid = player:GetGUIDLow()

    --Get the timestamp from the database
    local query = WorldDBQuery("SELECT " .. rewardType .. " FROM timed_times WHERE id = " .. playerGuid)

    if query then
        local row = query:GetRow()
        return row and tonumber(row[rewardType]) or 0
    else
        return 0
    end
end


local function DailyRewards(player)

    --Check the timed_rewards for the Daily item rewards line
    local query = WorldDBQuery("SELECT Item, Amount, Item1, Amount1, Item2, Amount2, Item3, Amount3 FROM timed_rewards WHERE Type = 'daily'")
    local playerGuid = player:GetGUIDLow()
    if query then
        repeat
            local DailyItem = query:GetUInt32(0)
            local DailyAmount = query:GetUInt32(1)
            local DailyItem1 = query:GetUInt32(2)
            local DailyAmount1 = query:GetUInt32(3)
            local DailyItem2 = query:GetUInt32(4)
            local DailyAmount2 = query:GetUInt32(5)
            local DailyItem3 = query:GetUInt32(6)
            local DailyAmount3 = query:GetUInt32(7)

            --Adding the items to the player
            SendMail("Daily Reward", "Thank you for your daily login and have fun claiming your reward :)", playerGuid, 1, 61, 0, 0, 0, DailyItem, DailyAmount, DailyItem1, DailyAmount1, DailyItem2, DailyAmount2, DailyItem3, DailyAmount3)
        until not query:Next()
    end
end

local function WeeklyRewards(player)

    --Check the timed_rewards for the Weekly item rewards line
    local query = WorldDBQuery("SELECT Item, Amount, Item1, Amount1, Item2, Amount2, Item3, Amount3 FROM timed_rewards WHERE Type = 'Weekly'")
    local playerGuid = player:GetGUIDLow()
    if query then
        repeat
            local WeeklyItem = query:GetUInt32(0)
            local WeeklyAmount = query:GetUInt32(1)
            local WeeklyItem1 = query:GetUInt32(2)
            local WeeklyAmount1 = query:GetUInt32(3)
            local WeeklyItem2 = query:GetUInt32(4)
            local WeeklyAmount2 = query:GetUInt32(5)
            local WeeklyItem3 = query:GetUInt32(6)
            local WeeklyAmount3 = query:GetUInt32(7)

            --Adding the weekly items
            SendMail("Daily Reward", "Thank you for your daily login and have fun claiming your reward :)", playerGuid, 1, 61, 0, 0, 0, WeeklyItem, WeeklyAmount, WeeklyItem1, WeeklyAmount1, WeeklyItem2, WeeklyAmount2, WeeklyItem3, WeeklyAmount3)

        until not query:Next()
    end
end

--Function for the daily rewards (24 Hours Timer)
function MyHandlers.Daily(player, ...)
    CheckAndCreateTimedTimesEntry(player, "Daily")

    local currentTimestamp = os.time()
    local lastExecutionTime = GetLastExecutionTime(player, "Daily")

    -- Checking if when the last time was when the player got his reward
    if (currentTimestamp - lastExecutionTime) >= (24 * 60 * 60) then
        SaveExecutionTime(player, currentTimestamp, "Daily")
        player:SendBroadcastMessage("You have been awarded your daily items via Mail! :)")
        DailyRewards(player)
    else
        local remainingTime = (24 * 60 * 60) - (currentTimestamp - lastExecutionTime)
        local remainingHours = math.floor(remainingTime / 3600)
        local remainingMinutes = math.floor((remainingTime % 3600) / 60)
        local remainingSeconds = remainingTime % 60
        local remainingTimeString = string.format("%d hours, %d minutes und %d seconds", remainingHours, remainingMinutes, remainingSeconds)

        -- Sending the remaining time to the player
        SendWorldMessage("You still need to wait " .. remainingTimeString .. " before claiming this reward again.", player)
    end
end

-- Function for the weekly reward (7 days timer)
function MyHandlers.Weekly(player, ...)
    CheckAndCreateTimedTimesEntry(player, "Weekly")

    local currentTimestamp = os.time()
    local lastExecutionTime = GetLastExecutionTime(player, "Weekly")

    -- Checking if when the last time was when the player got his reward
    if (currentTimestamp - lastExecutionTime) >= (7 * 24 * 60 * 60) then
        SaveExecutionTime(player, currentTimestamp, "Weekly")
        player:SendBroadcastMessage("You have been awarded your weekly items via Mail! :)")
        WeeklyRewards(player)
    else
        local remainingTime = (7 * 24 * 60 * 60) - (currentTimestamp - lastExecutionTime)
        local remainingDays = math.floor(remainingTime / (24 * 60 * 60))
        local remainingHours = math.floor((remainingTime % (24 * 60 * 60)) / 3600)
        local remainingMinutes = math.floor((remainingTime % 3600) / 60)
        local remainingSeconds = remainingTime % 60
        local remainingTimeString = string.format("%d days, %d hours, %d minutes und %d seconds", remainingDays, remainingHours, remainingMinutes, remainingSeconds)

        -- Sending the remaining time to the player
        SendWorldMessage("You still need to wait " .. remainingTimeString .. " before claiming this reward again.", player)
    end
end

--Command to call the AIO menu

local function OnCommand(event, player, command)
    if command == "rewards" or command == "rw" then
            AIO.Handle(player, "Rewards", "RewardFrame")
            return false
        end
    end

RegisterPlayerEvent(42, OnCommand)
