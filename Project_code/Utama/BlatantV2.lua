-- ⚡ ULTRA BLATANT AUTO FISHING MODULE - OPTIMIZED VERSION
-- Optimized for maximum speed and minimal overhead

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Network initialization (cached for performance)
local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    
local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = netFolder:WaitForChild("RF/UpdateAutoFishingState")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishingStopped = netFolder:WaitForChild("RE/FishingStopped")

-- Module
local UltraBlatant = {}
UltraBlatant.Active = false
UltraBlatant.Stats = {
    castCount = 0,
    startTime = 0
}

-- Optimized default settings for maximum speed
UltraBlatant.Settings = {
    CompleteDelay = 0.5,      -- Reduced from 0.73
    CancelDelay = 0.05,       -- Reduced from 0.3
    ReCastDelay = 0.001       -- Keep minimal
}

-- State tracking (optimized)
local FishingState = {
    lastCompleteTime = 0,
    completeCooldown = 0.2,   -- Reduced from 0.4
    isInCycle = false,
    loopThread = nil
}

----------------------------------------------------------------
-- OPTIMIZED CORE FUNCTIONS
----------------------------------------------------------------

-- Direct invocation without spawn for better performance
local function safeInvoke(func)
    local success, err = pcall(func)
    if not success then
        warn("⚠️ Ultra Blatant Network error:", err)
    end
end

-- Optimized complete function
local function protectedComplete()
    local now = tick()
    
    if now - FishingState.lastCompleteTime < FishingState.completeCooldown then
        return false
    end
    
    FishingState.lastCompleteTime = now
    safeInvoke(function()
        RE_FishingCompleted:FireServer()
    end)
    
    return true
end

-- Optimized cast function - batch network calls
local function performCast()
    local now = tick()
    
    UltraBlatant.Stats.castCount = UltraBlatant.Stats.castCount + 1
    
    -- Batch calls together for better performance
    safeInvoke(function()
        RF_ChargeFishingRod:InvokeServer({[1] = now})
        RF_RequestMinigame:InvokeServer(1, 0, now)
    end)
end

-- Optimized fishing loop - reduced overhead
local function fishingLoop()
    while UltraBlatant.Active do
        FishingState.isInCycle = true
        
        -- 1. CAST
        performCast()
        
        -- 2. WAIT CompleteDelay (optimized)
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        -- 3. COMPLETE
        if UltraBlatant.Active then
            protectedComplete()
        end
        
        -- 4. WAIT CancelDelay (optimized)
        task.wait(UltraBlatant.Settings.CancelDelay)
        
        -- 5. CANCEL
        if UltraBlatant.Active then
            safeInvoke(function()
                RF_CancelFishingInputs:InvokeServer()
            end)
        end
        
        FishingState.isInCycle = false
        
        -- 6. INSTANT RE-CAST (minimal delay)
        task.wait(UltraBlatant.Settings.ReCastDelay)
    end
    
    FishingState.isInCycle = false
end

-- Optimized event listener - reduced cooldown checks
local lastEventTime = 0

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not UltraBlatant.Active then return end
    
    local now = tick()
    
    -- Reduced cooldown check from 0.2 to 0.1
    if now - lastEventTime < 0.1 then
        return
    end
    lastEventTime = now
    
    -- Reduced cooldown check from 0.3 to 0.15
    if now - FishingState.lastCompleteTime < 0.15 then
        return
    end
    
    -- Use task.spawn for non-blocking but optimized
    task.spawn(function()
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        if UltraBlatant.Active and protectedComplete() then
            task.wait(UltraBlatant.Settings.CancelDelay)
            safeInvoke(function()
                RF_CancelFishingInputs:InvokeServer()
            end)
        end
    end)
end)

----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------

-- Optimized Update Settings function (merged duplicate)

function UltraBlatant.Start()
    if UltraBlatant.Active then 
        return false
    end
    
    UltraBlatant.Active = true
    UltraBlatant.Stats.castCount = 0
    UltraBlatant.Stats.startTime = tick()
    
    FishingState.lastCompleteTime = 0
    
    print("🎣 [Ultra Blatant] Enabling game auto fishing...")
    safeInvoke(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    -- Reduced wait time from 0.2 to 0.1
    task.wait(0.1)
    
    -- Store loop thread for cleanup
    FishingState.loopThread = task.spawn(fishingLoop)
    print("✅ [Ultra Blatant] Started!")
    return true
end

function UltraBlatant.Stop()
    if not UltraBlatant.Active then 
        return false
    end
    
    UltraBlatant.Active = false
    
    -- Enable game auto fishing (biarkan tetap nyala)
    safeInvoke(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    -- Reduced wait time from 0.2 to 0.1
    task.wait(0.1)
    
    -- Cancel fishing inputs
    safeInvoke(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    return true
end

-- Optimized Update Settings function
function UltraBlatant.UpdateSettings(completeDelay, cancelDelay, reCastDelay)
    if completeDelay ~= nil then
        UltraBlatant.Settings.CompleteDelay = completeDelay
    end
    if cancelDelay ~= nil then
        UltraBlatant.Settings.CancelDelay = cancelDelay
    end
    if reCastDelay ~= nil then
        UltraBlatant.Settings.ReCastDelay = reCastDelay
    end
end

function UltraBlatant.GetStats()
    local runtime = math.floor(tick() - UltraBlatant.Stats.startTime)
    local cps = runtime > 0 and math.floor(UltraBlatant.Stats.castCount / runtime * 10) / 10 or 0
    
    return {
        castCount = UltraBlatant.Stats.castCount,
        runtime = runtime,
        cps = cps,
        isActive = UltraBlatant.Active,
        isInCycle = FishingState.isInCycle
    }
end


return UltraBlatant
