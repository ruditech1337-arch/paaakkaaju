-- UPDATED SECURITY LOADER - Includes EventTeleportDynami
-- Replace your SecurityLoader.lua with this

local SecurityLoader = {}

-- ============================================
-- CONFIGURATION
-- ============================================
local CONFIG = {
    VERSION = "2.3.1",
    GITHUB_REPO = "ruditech1337-arch/pa",
    GITHUB_BRANCH = "main",
    BASE_PATH = "Project_code",
    MAX_LOADS_PER_SESSION = 100,
    ENABLE_RATE_LIMITING = true
}

-- ============================================
-- RATE LIMITING
-- ============================================
local loadCounts = {}
local lastLoadTime = {}

local function checkRateLimit()
    if not CONFIG.ENABLE_RATE_LIMITING then
        return true
    end
    
    local identifier = game:GetService("RbxAnalyticsService"):GetClientId()
    local currentTime = tick()
    
    loadCounts[identifier] = loadCounts[identifier] or 0
    lastLoadTime[identifier] = lastLoadTime[identifier] or 0
    
    if currentTime - lastLoadTime[identifier] > 3600 then
        loadCounts[identifier] = 0
    end
    
    if loadCounts[identifier] >= CONFIG.MAX_LOADS_PER_SESSION then
        warn("⚠️ Rate limit exceeded. Please wait before reloading.")
        return false
    end
    
    loadCounts[identifier] = loadCounts[identifier] + 1
    lastLoadTime[identifier] = currentTime
    
    return true
end

-- ============================================
-- MODULE PATH MAPPING (Direct from Project_code)
-- ============================================
local modulePaths = {
    -- Fishing modules
    instant = "Project_code/Instant.lua",
    instant2 = "Project_code/Instant2.lua",
    blatantv1 = "Project_code/Utama/BlatantV1.lua",
    UltraBlatant = "Project_code/Utama/BlatantV2.lua",
    blatantv2 = "Project_code/BlatantV2.lua",
    blatantv2fix = "Project_code/Utama/BlatantV2.lua", -- Using same as UltraBlatant
    
    -- Support features
    NoFishingAnimation = "Project_code/Utama/NoFishingAnimation.lua",
    LockPosition = "Project_code/Utama/LockPosition.lua",
    AutoEquipRod = "Project_code/Utama/AutoEquipRod.lua",
    DisableCutscenes = "Project_code/Utama/DisableCutscenes.lua",
    DisableExtras = "Project_code/Utama/DisableExtras.lua",
    AutoTotem3X = "Project_code/Utama/AutoTotem3x.lua",
    SkinAnimation = "Project_code/Utama/SkinSwapAnimation.lua",
    WalkOnWater = "Project_code/Utama/WalkOnWater.lua",
    GoodPerfectionStable = "Project_code/Utama/PerfectionGood.lua",
    
    -- Teleport modules
    TeleportModule = "Project_code/TeleportModule.lua",
    TeleportToPlayer = "Project_code/TeleportSystem/TeleportToPlayer.lua",
    SavedLocation = "Project_code/TeleportSystem/SavedLocation.lua",
    EventTeleportDynamic = "Project_code/TeleportSystem/EventTeleportDynamic.lua",
    
    -- Quest modules
    AutoQuestModule = "Project_code/Quest/AutoQuestModule.lua",
    AutoTemple = "Project_code/Quest/LeverQuest.lua", -- Using LeverQuest as AutoTemple
    TempleDataReader = "Project_code/Quest/TempleDataReader.lua",
    
    -- Shop modules
    AutoSell = "Project_code/ShopFeatures/AutoSell.lua",
    AutoSellTimer = "Project_code/ShopFeatures/AutoSellTimer.lua",
    RemoteBuyer = "Project_code/ShopFeatures/RemoteBuyer.lua",
    AutoBuyWeather = "Project_code/ShopFeatures/AutoBuyWeather.lua",
    MerchantSystem = "Project_code/ShopFeatures/OpenShop.lua", -- Using OpenShop as MerchantSystem
    
    -- Camera modules
    FreecamModule = "Project_code/Camera View/FreecamModule.lua",
    UnlimitedZoomModule = "Project_code/Camera View/UnlimitedZoom.lua",
    
    -- Misc modules
    AntiAFK = "Project_code/Misc/AntiAFK.lua",
    UnlockFPS = "Project_code/Misc/UnlockFPS.lua",
    FPSBooster = "Project_code/Misc/FpsBooster.lua",
    HideStats = "Project_code/Misc/HideStats.lua",
    Webhook = "Project_code/Misc/Webhook.lua",
    DisableRendering = "Project_code/Misc/DisableRendering.lua",
    PingFPSMonitor = "Project_code/Misc/PingPanel.lua",
    MovementModule = "Project_code/Misc/MovementModule.lua",
    
    -- Notification
    Notify = "Project_code/Notification.lua",
    
    -- AutoFavorite
    AutoFavorite = "Project_code/AutoFavorite.lua",
}

-- ============================================
-- LOAD MODULE FUNCTION (Direct from Project_code)
-- ============================================
function SecurityLoader.LoadModule(moduleName)
    if not checkRateLimit() then
        return nil
    end
    
    local filePath = modulePaths[moduleName]
    if not filePath then
        warn("❌ Module not found:", moduleName)
        return nil
    end
    
    -- Build GitHub URL directly
    local url = string.format(
        "https://raw.githubusercontent.com/%s/%s/%s",
        CONFIG.GITHUB_REPO,
        CONFIG.GITHUB_BRANCH,
        filePath
    )
    
    local success, result = pcall(function()
        local scriptContent = game:HttpGet(url)
        if not scriptContent or #scriptContent == 0 then
            error("Empty response from GitHub")
        end
        return loadstring(scriptContent)()
    end)
    
    if not success then
        warn("❌ Failed to load", moduleName, "from", filePath)
        warn("   Error:", tostring(result))
        warn("   URL:", url)
        return nil
    end
    
    return result
end

-- ============================================
-- ANTI-DUMP PROTECTION (COMPATIBLE VERSION)
-- ============================================
function SecurityLoader.EnableAntiDump()
    local mt = getrawmetatable(game)
    if not mt then 
        warn("⚠️ Anti-Dump: Metatable not accessible")
        return 
    end
    
    local oldNamecall = mt.__namecall
    
    -- Check if newcclosure is available
    local hasNewcclosure = pcall(function() return newcclosure end) and newcclosure
    
    local success = pcall(function()
        setreadonly(mt, false)
        
        local protectedCall = function(self, ...)
            local method = getnamecallmethod()
            
            if method == "HttpGet" or method == "GetObjects" then
                local caller = getcallingscript and getcallingscript()
                if caller and caller ~= script then
                    warn("🚫 Blocked unauthorized HTTP request")
                    return ""
                end
            end
            
            return oldNamecall(self, ...)
        end
        
        -- Use newcclosure if available, otherwise use regular function
        mt.__namecall = hasNewcclosure and newcclosure(protectedCall) or protectedCall
        
        setreadonly(mt, true)
    end)
    
    if success then
        print("🛡️ Anti-Dump Protection: ACTIVE")
    else
        warn("⚠️ Anti-Dump: Failed to apply (executor limitation)")
    end
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
function SecurityLoader.GetSessionInfo()
    local moduleCount = 0
    for _ in pairs(modulePaths) do
        moduleCount = moduleCount + 1
    end
    
    local info = {
        Version = CONFIG.VERSION,
        LoadCount = loadCounts[game:GetService("RbxAnalyticsService"):GetClientId()] or 0,
        TotalModules = moduleCount,
        RateLimitEnabled = CONFIG.ENABLE_RATE_LIMITING,
        GitHubRepo = CONFIG.GITHUB_REPO,
        BasePath = CONFIG.BASE_PATH
    }
    
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("📊 Session Info:")
    for k, v in pairs(info) do
        print(k .. ":", v)
    end
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    return info
end

function SecurityLoader.ResetRateLimit()
    local identifier = game:GetService("RbxAnalyticsService"):GetClientId()
    loadCounts[identifier] = 0
    lastLoadTime[identifier] = 0
    print("✅ Rate limit reset")
end

-- Count modules
local moduleCount = 0
for _ in pairs(modulePaths) do
    moduleCount = moduleCount + 1
end

print("━━━━━━━━━━━━━━━━━━━━━━")
print("🔒 Lynx Security Loader v" .. CONFIG.VERSION)
print("✅ Loading from: " .. CONFIG.GITHUB_REPO .. "/" .. CONFIG.BASE_PATH)
print("✅ Total Modules: " .. tostring(moduleCount))
print("✅ Rate Limiting:", CONFIG.ENABLE_RATE_LIMITING and "ENABLED" or "DISABLED")
print("━━━━━━━━━━━━━━━━━━━━━━")

return SecurityLoader
