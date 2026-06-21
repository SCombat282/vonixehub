-- [ VONIXE HUB - BOOTSTRAPPER ]

warn("[Vonixe Hub] Start Loading...")

local function get(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    if not res or res == "" then return nil end
    return res
end

local BETA_KEY = "TEST" -- GANTI KEY BETA NYA DISINI BANG

-- Load VonixeLib
local libSrc = get("https://raw.githubusercontent.com/SCombat282/vonixehub/refs/heads/main/vonixe-library")
if not libSrc then return end
local VonixeLib = loadstring(libSrc)()
warn("[Vonixe Hub] Library Loaded")

local function verifyBetaKey(key)
    -- Clean the key to prevent trailing spaces
    key = string.gsub(key, "^%s*(.-)%s*$", "%1")
    
    if key == BETA_KEY then
        return true
    end
    return false
end

local function loadSavedKey()
    local path = "VonixeHub/vonixe.key"
    if isfile and isfile(path) then
        local ok, content = pcall(function() return readfile(path) end)
        return ok and content or nil
    end
    return nil
end

local savedKey = loadSavedKey()
  if type(getgenv) == "function" and getgenv().script_key then 
      savedKey = getgenv().script_key 
  end
local alreadyVerified = false

if savedKey then
    warn("[Vonixe Hub] Found saved key, verifying...")
    if verifyBetaKey(savedKey) then
        getgenv().SCRIPT_KEY = savedKey
        alreadyVerified = true
        warn("[Vonixe Hub] Auto-verified successfully!")
    else
        warn("[Vonixe Hub] Saved key expired or invalid.")
    end
end

local function loadPortal()
    task.spawn(function()
        while true do
            task.wait(1800)
            if not verifyBetaKey(getgenv().SCRIPT_KEY) then
                game:GetService("Players").LocalPlayer:Kick("[Vonixe Hub] Your key expired! Get a new key!")
                return
            end
        end
    end)

    local HttpService = game:GetService("HttpService")
    local MANIFEST_URL = "https://raw.githubusercontent.com/SCombat282/vonixehub/main/beta_script.json"

    local finalUrl = MANIFEST_URL .. "?t=" .. tostring(os.time())

    local ok, raw = pcall(function() return game:HttpGet(finalUrl) end)
    if ok then
        raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
        local okD, list = pcall(function() return HttpService:JSONDecode(raw) end)
        if okD and type(list) == "table" then
            local currentPlaceId = tostring(game.PlaceId)
            
            for _, s in pairs(list) do
                if s.PlaceId and tostring(s.PlaceId) == currentPlaceId and s.Url then
                    warn("[Vonixe Hub] Game supported! Auto-executing script...")
                    local scriptUrl = s.Url
                    if scriptUrl:find("githubusercontent") then
                        scriptUrl = scriptUrl .. "?t=" .. tostring(os.time())
                    end
                    loadstring(game:HttpGet(scriptUrl))()
                    return 
                end
            end
        end
    end

    -- Fallback kalau game nggak disupport
    game:GetService("Players").LocalPlayer:Kick("[Vonixe Hub] Game not supported or failed to load manifest.")
end

if alreadyVerified then
    loadPortal()
else
    local isVerified = VonixeLib:CreateKeySystem({
        Title = "Vonixe Hub Access",
        Desc = "Enter the beta key to continue.",
        Folder = "VonixeHub",

        OnGetKey = function()
            setclipboard("Ask the developer for the Beta Key")
        end,

        OnVerify = function(key)
            warn("[Vonixe Hub] Verifying Key: " .. tostring(key))
            local valid = verifyBetaKey(key)
            if valid then
                getgenv().SCRIPT_KEY = key
                pcall(function()
                    if not isfolder("VonixeHub") then makefolder("VonixeHub") end
                    writefile("VonixeHub/vonixe.key", key)
                end)
            else
                warn("[Vonixe Hub] Invalid key!")
            end
            return valid
        end,
    })

    if isVerified then
        loadPortal()
    end
end