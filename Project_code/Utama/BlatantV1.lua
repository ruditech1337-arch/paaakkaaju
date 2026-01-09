-- ⚡ ULTRA BLATANT AUTO FISHING - OPTIMIZED FOR MAXIMUM SPEED
-- OPTIMIZED VERSION FOR 10+ FISH PER SECOND
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Network initialization (cached)
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

-- Module table
local UltraBlatant = {}
UltraBlatant.Active = false
UltraBlatant.Stats = {
    castCount = 0,
    startTime = 0
}

-- Optimized default settings for maximum speed
UltraBlatant.Settings = {
    CompleteDelay = 0.2,      -- Optimized: reduced for faster cycle
    CancelDelay = 0.15        -- Optimized: reduced for faster cycle
}

----------------------------------------------------------------
-- OPTIMIZED CORE FUNCTIONS
----------------------------------------------------------------

-- Direct invocation without spawn for better performance
local function safeInvoke(func)
    local success, err = pcall(func)
    if not success then
        warn("⚠️ BlatantV1 Network error:", err)
    end
end

-- OPTIMIZED MAIN SPAM LOOP - Maximum speed
local function ultraSpamLoop()
    while UltraBlatant.Active do
        local currentTime = tick()
        
        -- Batch network calls together for better performance
        safeInvoke(function()
            RF_ChargeFishingRod:InvokeServer({[1] = currentTime})
            RF_RequestMinigame:InvokeServer(1, 0, currentTime)
        end)
        
        UltraBlatant.Stats.castCount = UltraBlatant.Stats.castCount + 1
        
        -- Wait CompleteDelay then fire complete
        task.wait(UltraBlatant.Settings.CompleteDelay)
        
        -- Direct invoke for faster response
        safeInvoke(function()
            RE_FishingCompleted:FireServer()
        end)
        
        -- Cancel with minimal delay
        task.wait(UltraBlatant.Settings.CancelDelay)
        safeInvoke(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
        
        -- Minimal delay before next cycle (removed unnecessary wait)
    end
end

-- OPTIMIZED BACKUP LISTENER - Faster response
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not UltraBlatant.Active then return end
    
    -- Direct execution instead of spawn for faster response
    task.wait(UltraBlatant.Settings.CompleteDelay)
    
    safeInvoke(function()
        RE_FishingCompleted:FireServer()
    end)
    
    task.wait(UltraBlatant.Settings.CancelDelay)
    safeInvoke(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
end)

----------------------------------------------------------------
-- PUBLIC API (Compatible dengan pattern GUI kamu)
----------------------------------------------------------------

-- ⭐ NEW: Update Settings function
function UltraBlatant.UpdateSettings(completeDelay, cancelDelay)
    if completeDelay ~= nil then
        UltraBlatant.Settings.CompleteDelay = completeDelay
        print("✅ UltraBlatant CompleteDelay updated:", completeDelay)
    end
    
    if cancelDelay ~= nil then
        UltraBlatant.Settings.CancelDelay = cancelDelay
        print("✅ UltraBlatant CancelDelay updated:", cancelDelay)
    end
end

-- Start function
function UltraBlatant.Start()
    if UltraBlatant.Active then 
        print("⚠️ Ultra Blatant already running!")
        return
    end
    
    UltraBlatant.Active = true
    UltraBlatant.Stats.castCount = 0
    UltraBlatant.Stats.startTime = tick()
    
    task.spawn(ultraSpamLoop)
end

-- ⭐ ENHANCED Stop function - Optimized
function UltraBlatant.Stop()
    if not UltraBlatant.Active then 
        return
    end
    
    UltraBlatant.Active = false
    
    -- ⭐ Nyalakan auto fishing game (biarkan tetap nyala)
    safeInvoke(function()
        RF_UpdateAutoFishingState:InvokeServer(true)
    end)
    
    -- Reduced wait time from 0.2 to 0.1
    task.wait(0.1)
    
    -- Cancel fishing inputs untuk memastikan karakter berhenti
    safeInvoke(function()
        RF_CancelFishingInputs:InvokeServer()
    end)
    
    print("✅ Ultra Blatant stopped - Game auto fishing enabled, can change rod/skin")
end

-- Return module
return UltraBlatant
