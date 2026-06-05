if game.PlaceId ~= 93978595733734 then
    game:GetService("Players").LocalPlayer:Kick("salah map goblok")
    return
end
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait() end
while not workspace.CurrentCamera do task.wait() end
local v3 = Vector3.new
local t_insert = table.insert
local t_remove = table.remove
local m_floor = math.floor
local s_format = string.format
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats             = game:GetService("Stats")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- ══ OPTIMIZATION: Cache System ══════════════════════════════
local _LocalChar, _LocalRoot, _LocalHum
local _CachedPlayers = {}

local function _CacheChar(char)
    _LocalChar = char
    _LocalRoot = nil; _LocalHum = nil
    if not char then return end
    task.spawn(function()
        pcall(function() _LocalRoot = char:WaitForChild("HumanoidRootPart", 8) end)
        pcall(function()
            _LocalHum = char:FindFirstChildOfClass("Humanoid")
                     or char:WaitForChild("Humanoid", 8)
        end)
    end)
end

local function _RebuildPlayerList()
    _CachedPlayers = Players:GetPlayers()
end

LocalPlayer.CharacterAdded:Connect(_CacheChar)
if LocalPlayer.Character then task.defer(_CacheChar, LocalPlayer.Character) end
Players.PlayerAdded:Connect(function() task.defer(_RebuildPlayerList) end)
Players.PlayerRemoving:Connect(function() task.defer(_RebuildPlayerList) end)
task.defer(_RebuildPlayerList)
-- ════════════════════════════════════════════════════════════

local LastTriggerTick = 0
local LastGoalRotation = 0
local LastSkillHit = 0
local GenConnection = nil
local AutoGenerator = false
local AutoGeneratorMode = "Perfect"
getgenv().GeneratorPerfectOffsetStart = 102
getgenv().GeneratorPerfectOffsetEnd   = 116
local IsMobile =
    UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled
local function PressSkill()
    if tick()-LastTriggerTick<0.08 then return end
    LastTriggerTick=tick()
    local btn = PlayerGui:FindFirstChild("check", true)
    local fired = false
    if btn and btn:IsA("GuiObject") then
        pcall(function()
            if firesignal and btn.MouseButton1Click then
                firesignal(btn.MouseButton1Click)
                fired = true
            end
        end)
    end
    if fired then return end
    if IsMobile then
        if btn and btn:IsA("GuiObject") then
            local pos   = btn.AbsolutePosition
            local size  = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local x = pos.X + (size.X/2) + inset.X
            local y = pos.Y + (size.Y/2) + inset.Y
            pcall(function()
                VirtualInputManager:SendTouchEvent(
                    8822, Enum.UserInputState.Begin.Value, x, y)
                task.wait()
                VirtualInputManager:SendTouchEvent(
                    8822, Enum.UserInputState.End.Value, x, y)
            end)
        end
    else
        pcall(function()
            VirtualInputManager:SendKeyEvent(
                true, Enum.KeyCode.Space, false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(
                false, Enum.KeyCode.Space, false, game)
        end)
    end
end
local function GetSkillCheck()
    for _,guiName in ipairs({
        "SkillCheckPromptGui",
        "SkillCheckPromptGui-con"
    }) do
        local gui = PlayerGui:FindFirstChild(guiName, true)
        if gui then
            local check = gui:FindFirstChild("Check", true)
            if check and check.Visible then
                local line = check:FindFirstChild("Line", true)
                local goal = check:FindFirstChild("Goal", true)
                if line and goal then
                    return line, goal
                end
            end
        end
    end
end
if GenConnection then
    GenConnection:Disconnect()
end
GenConnection = RunService.Heartbeat:Connect(function()
    if not AutoGenerator then return end
    local line, goal = GetSkillCheck()
    if not (line and goal) then return end
    local lr = line.Rotation % 360
    local gr = goal.Rotation % 360
    local goalVelocity = math.abs(gr - LastGoalRotation)
    LastGoalRotation = gr
    local dynamicOffset = math.clamp(goalVelocity * 0.35, 0, 8)
    local startPos, endPos
    if AutoGeneratorMode == "Neutral" then
        startPos = (gr + 96 - dynamicOffset) % 360
        endPos   = (gr + 122 + dynamicOffset) % 360
    else
        startPos = (gr + (getgenv().GeneratorPerfectOffsetStart or 102) - dynamicOffset) % 360
        endPos   = (gr + (getgenv().GeneratorPerfectOffsetEnd   or 108) + dynamicOffset) % 360
    end
    local inside = false
    if startPos > endPos then
        inside = (lr >= startPos or lr <= endPos)
    else
        inside = (lr >= startPos and lr <= endPos)
    end
    if inside then
        LastSkillHit = tick()
        PressSkill()
    end
end)
local ESP_Enabled       = false
local ESP_Name          = true
local ESP_ItemIcon      = false
local ESP_ModeOutline   = false
local ESP_Skeleton      = false
local ESP_KillerWarn    = false
local KillerWarnGui     = nil
local _kwBlinkTimer     = 0
local _kwBlinkState     = true
local ESP_SCP           = true
local ESP_Player        = true
local ESP_Killer        = true
local ESP_Generator     = true
local ESP_Pallet        = true
local ESP_Window        = true
local ESP_Gate          = true
local ESP_Hook          = true
local ESP_AutoSkillCheck = false
local ESP_COLORS = {
    SCP       = Color3.fromRGB(170, 0, 255),
    Player    = Color3.fromRGB(0, 255, 34),
    Killer    = Color3.fromRGB(255, 50, 50),
    Generator = Color3.fromRGB(255, 165, 0),
    Pallet    = Color3.fromRGB(53, 189, 166),
    Window    = Color3.fromRGB(0, 100, 255),
    Hook      = Color3.fromRGB(255, 0, 128),
    Gate      = Color3.fromRGB(80, 80, 80),
}
local MaskNames = {
    ["Abysswalker"] = "ABYSSWALKER",
    ["Cure"]        = "CURE",
    ["Hidden"]      = "HIDDEN",
    ["Killer"]      = "THE KILLER",
    ["Masked"]      = "MASKED",
    ["Stalker"]     = "STALKER",
    ["Veil"]        = "VEIL",
    ["Slasher"]     = "SLASHER",
}
local MaskColors = {
    ["Abysswalker"] = Color3.fromRGB(110, 20, 255),
    ["Cure"]        = Color3.fromRGB(0, 54, 156),
    ["Hidden"]      = Color3.fromRGB(170, 170, 170),
    ["Killer"]      = Color3.fromRGB(255, 40, 40),
    ["Masked"]      = Color3.fromRGB(255, 90, 20),
    ["Stalker"]     = Color3.fromRGB(255, 0, 140),
    ["Veil"]        = Color3.fromRGB(0, 140, 255),
    ["Slasher"]     = Color3.fromRGB(180, 0, 255),
}
local CachedMapObjects = {
    Generators = {},
    Pallets    = {},
    Hooks      = {},
    Gates      = {},
    Windows    = {},
    SCPs       = {},
}
local PrevESPState = { Generator = false, Hook = false, Pallet = false, Gate = false, Window = false, SCP = false }
local ActiveGenerators = {}
local AutoParry         = false
local ParryDistance     = 10
local ShowParryRing     = false
local LastParryTick     = 0
local CFG_BurstAmount   = 8
local CFG_ParryCooldown = 0.06
local ParryRing         = nil
local Aimbot           = false
local TargetPartCache  = {}
local WallCheck        = true
local ShowFOVCircle    = false
local AimRadius        = 60
local AimDistance      = 80
local CachedAimTarget  = nil
local LastTargetCheck  = 0
local lastRenderCheck  = 0
local cachedIsCarrying = false
getgenv().AimbotSmoothness = 8
getgenv().AimbotPart       = "Torso"
getgenv().AimbotTrigger    = "Hold to Lock"
local aimRayParams = RaycastParams.new()
aimRayParams.FilterType = Enum.RaycastFilterType.Blacklist
getgenv().ParryMatchup     = "Auto"
getgenv().ParryDelayOffset = 0
local IgnoreSkills = {
    "Veil","Masked","Stalker","Invisible",
    "Ghost","Phase","Dash","Warp","Teleport"
}
local KillerProfiles = {
    Killer      = { Delay = 0.04, EffectiveRange = 7.8 },
    Abysswalker = { Delay = 0.12, EffectiveRange = 7.8 },
    Hidden      = { Delay = 0,    EffectiveRange = 7.8 },
    Masked      = { Delay = 0.05, EffectiveRange = 7.8 },
    Stalker     = { Delay = 0,    EffectiveRange = 7.8 },
    Veil        = { Delay = 0.04, EffectiveRange = 7.8 },
    Slasher     = { Delay = 0.05, EffectiveRange = 7.8 },
    Cure        = { Delay = 0.03, EffectiveRange = 7.8 },
}
local function GetGameValue(obj, name)
    if typeof(obj) ~= "Instance" then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child and child:IsA("ValueBase") then return child.Value end
    return nil
end
local function GetPing()
    local ping = 0.09
    pcall(function()
        ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    return math.clamp(ping, 0.04, 0.22)
end

local function GetKillerProfile(char)
    local detect = string.upper(tostring(
        char:GetAttribute("KillerType")
        or char:GetAttribute("Mask")
        or char.Name
    ))
    for profile, mask in pairs(MaskNames) do
        if detect:find(mask) then
            return KillerProfiles[profile]
        end
    end
    return { Delay = 0 }
end
local function ApplyHighlight(object, color)
    local h = object:FindFirstChild("VESP_H")
    if not h then
        h = Instance.new("Highlight")
        h.Name = "VESP_H"
        h.Adornee = object
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = object
    end
    if ESP_ModeOutline then
        h.FillTransparency = 1
        h.OutlineTransparency = 0
    else
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0.05
    end
    if h.FillColor ~= color then
        h.FillColor = color
        h.OutlineColor = color:Lerp(Color3.new(1,1,1), 0.15)
    end
    if not h.Enabled then h.Enabled = true end
end
local function RemoveHighlight(object)
    if object then
        local h = object:FindFirstChild("VESP_H")
        if h then h:Destroy() end
    end
end
local function ApplyVaultESP(part, color)
    if not part then return end
    local box = part:FindFirstChild("VESP_Vault")
    if not box then
        box = Instance.new("BoxHandleAdornment")
        box.Name = "VESP_Vault"
        box.Adornee = part
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Parent = part
    end
    box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
    box.Color3 = color
end
local function RemoveVaultESP(part)
    if not part then return end
    local box = part:FindFirstChild("VESP_Vault")
    if box then box:Destroy() end
end
local function CreateBillboardTag(text, color, size, textSize)
    local bb = Instance.new("BillboardGui")
    bb.Name = "TagESP"
    bb.AlwaysOnTop = true
    bb.Size = size or UDim2.new(0, 150, 0, 40)
    bb.LightInfluence = 0
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = textSize or 13
    lbl.TextWrapped = false
    lbl.RichText = true
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Transparency = 0.2
    stroke.Parent = lbl
    lbl.Parent = bb
    return bb
end
local function ApplyMapTag(part, text, color)
    if not part then return end
    local bg = part:FindFirstChild("MapTagESP")
    if not bg then
        bg = CreateBillboardTag(text, color, UDim2.new(0, 100, 0, 30), 13)
        bg.Name = "MapTagESP"
        bg.StudsOffset = Vector3.new(0, 2, 0)
        bg.MaxDistance = 500
        bg.Adornee = part
        bg.Parent = part
    else
        local lbl = bg:FindFirstChild("Label")
        if lbl then
            lbl.Text = text
            lbl.TextColor3 = color
        end
    end
end
local function RemoveMapTag(part)
    if part then
        local bg = part:FindFirstChild("MapTagESP")
        if bg then bg:Destroy() end
    end
end
local function UpdateMapCache()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    local newGens = {}
    local newPallets = {}
    local newHooks = {}
    local newGates = {}
    local newWindows = {}
    local newSCPs = {}
    for i, obj in ipairs(map:GetDescendants()) do
        local n = obj.Name
        local ln = string.lower(n)
        if n == "GeneratorBody" then
            t_insert(newGens, obj)
        elseif n == "Model" and obj.Parent and obj.Parent.Name == "Hook" then
            t_insert(newHooks, obj)
        elseif n == "ExitLever" or n == "LeftGate" or n == "RightGate" then
            t_insert(newGates, obj)
        elseif n == "PrimaryPartPallet" then
            t_insert(newPallets, obj)
        elseif n == "Bottom" and obj.Parent and (string.find(string.lower(obj.Parent.Name), "window") or string.find(string.lower(obj.Parent.Name), "vault")) then
            t_insert(newWindows, obj)
        elseif obj:IsA("Model") and (string.sub(ln, 1, 3) == "scp" or string.sub(ln, 1, 6) == "zombie") then
            t_insert(newSCPs, obj)
        end
        if i % 1500 == 0 then task.wait() end
    end
    CachedMapObjects.Generators = newGens
    CachedMapObjects.Pallets    = newPallets
    CachedMapObjects.Hooks      = newHooks
    CachedMapObjects.Gates      = newGates
    CachedMapObjects.Windows    = newWindows
    CachedMapObjects.SCPs       = newSCPs
end
getgenv().VONIXE_VD_RUNNING = true
task.spawn(function()
    local mapWasEmpty = true
    local lastScanTime = 0
    while task.wait(0.5) do
        if not getgenv().VONIXE_VD_RUNNING then break end
        local currentMap = workspace:FindFirstChild("Map")
        local hasContents = currentMap and #currentMap:GetChildren() > 0
        if hasContents then
            mapWasEmpty = false
            if tick() - lastScanTime >= 2.5 then
                lastScanTime = tick()
                task.spawn(function() UpdateMapCache() end)
            end
        elseif not hasContents and not mapWasEmpty then
            mapWasEmpty = true
            CachedMapObjects.Generators = {}
            CachedMapObjects.Pallets    = {}
            CachedMapObjects.Hooks      = {}
            CachedMapObjects.Gates      = {}
            CachedMapObjects.Windows    = {}
            if ActiveGenerators then table.clear(ActiveGenerators) end
            PrevESPState.Generator = false
            PrevESPState.Hook      = false
            PrevESPState.Pallet    = false
            PrevESPState.Gate      = false
            PrevESPState.Window    = false
        end
    end
end)
local function CreatePlayerESP(player, isKiller)
    if not ESP_Enabled then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    local myRoot = _LocalRoot
    if not myRoot then return end
    local dist = (root.Position - myRoot.Position).Magnitude
    local color = isKiller and ESP_COLORS.Killer or ESP_COLORS.Player
    local statusText = ""
    if isKiller then
        local detectedMask = char:GetAttribute("CachedMask")
            or GetGameValue(char, "SelectedKiller")
            or GetGameValue(player, "SelectedKiller")
            or GetGameValue(char, "Mask")
            or GetGameValue(player, "Mask")
            or char.Name
        if detectedMask then char:SetAttribute("CachedMask", detectedMask) end
        statusText = MaskNames[detectedMask] or "KILLER"
    else
        local function IsActive(v) return v == true or (type(v) == "number" and v > 0) end
        local hooked   = IsActive(GetGameValue(char, "IsHooked"))  or IsActive(GetGameValue(player, "IsHooked"))
        local carried  = IsActive(GetGameValue(char, "Carried"))   or IsActive(GetGameValue(char, "IsCarried"))
        local knocked  = IsActive(GetGameValue(char, "Knocked"))   or IsActive(GetGameValue(char, "IsKnocked"))
        if hooked then color = Color3.fromRGB(255, 70, 140);  statusText = "HOOKED"
        elseif carried then color = Color3.fromRGB(190, 90, 255); statusText = "CARRIED"
        elseif knocked then color = Color3.fromRGB(255, 170, 0);  statusText = "KNOCKED"
        elseif hum.Health < hum.MaxHealth then color = Color3.fromRGB(255, 225, 80); statusText = "INJURED"
        else statusText = nil; color = ESP_COLORS.Player end
    end
    ApplyHighlight(char, color)
    if ESP_Name then
        local bottomText
        if isKiller then
            bottomText = s_format('<font color="#DCDCDC">%.1fm</font> â€¢ <font color="#%s">[%s]</font>', dist, color:ToHex(), string.upper(statusText or "KILLER"))
        elseif statusText then
            bottomText = s_format('<font color="#DCDCDC">%.1fm</font> â€¢ <font color="#%s">%s</font>', dist, color:ToHex(), statusText)
        else
            bottomText = s_format('<font color="#DCDCDC">%.1fm</font>', dist)
        end
        local finalName = s_format('<b>@%s</b>\n%s', player.Name, bottomText)
        local bg = root:FindFirstChild("TagESP")
        if not bg then
            bg = Instance.new("BillboardGui")
            bg.Name = "TagESP"; bg.Parent = root; bg.Adornee = root
            bg.AlwaysOnTop = true; bg.LightInfluence = 0; bg.ResetOnSpawn = false
            bg.MaxDistance = 1800; bg.Size = UDim2.new(0, 165, 0, 34)
            bg.StudsOffset = v3(0, 3.8, 0)
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Label"; lbl.Parent = bg; lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.fromScale(1, 1); lbl.RichText = true
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 8
            lbl.TextColor3 = color; lbl.Text = finalName
            local stk = Instance.new("UIStroke"); stk.Parent = lbl
            stk.Thickness = 1.2; stk.Transparency = 0.2; stk.Color = Color3.new(0, 0, 0)
        else
            local lbl = bg:FindFirstChild("Label")
            if lbl then lbl.Text = finalName; lbl.TextColor3 = color end
        end
    else
        local bg = root:FindFirstChild("TagESP")
        if bg then bg:Destroy() end
    end
end
local function RemovePlayerESP(player)
    local char = player.Character
    if char then
        RemoveHighlight(char)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bg = root:FindFirstChild("TagESP")
            if bg then bg:Destroy() end
        end
    end
end
local function RemoveKillerWarn()
    if KillerWarnGui and KillerWarnGui.Parent then
        KillerWarnGui:Destroy()
    end
    KillerWarnGui = nil
    _kwBlinkState = true
end
local function UpdateKillerWarn()
    if not ESP_KillerWarn then RemoveKillerWarn(); return end
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then RemoveKillerWarn(); return end
    local closestDist = math.huge
    for _, p in ipairs(_CachedPlayers) do
        if p ~= LocalPlayer then
            local teamName = p.Team and string.lower(p.Team.Name) or ""
            if string.find(teamName, "killer") then
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (root.Position - myRoot.Position).Magnitude
                    if d < closestDist then closestDist = d end
                end
            end
        end
    end
    local warnLevel = 0
    if     closestDist <= 25 then warnLevel = 2
    elseif closestDist <= 70 then warnLevel = 1
    end
    if warnLevel == 0 then RemoveKillerWarn(); return end
    if not KillerWarnGui or not KillerWarnGui.Parent then
        KillerWarnGui               = Instance.new("BillboardGui")
        KillerWarnGui.Name          = "KillerWarnESP"
        KillerWarnGui.AlwaysOnTop   = true
        KillerWarnGui.LightInfluence = 0
        KillerWarnGui.Size          = UDim2.new(0, 80, 0, 50)
        KillerWarnGui.StudsOffset   = Vector3.new(0, 3.5, 0)
        KillerWarnGui.Adornee       = myRoot
        KillerWarnGui.Parent        = myRoot
        local lbl                   = Instance.new("TextLabel")
        lbl.Name                    = "WarnLabel"
        lbl.Parent                  = KillerWarnGui
        lbl.Size                    = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency  = 1
        lbl.Font                    = Enum.Font.GothamBold
        lbl.TextSize                = 32
        lbl.TextStrokeTransparency  = 0.05
        lbl.TextStrokeColor3        = Color3.new(0, 0, 0)
        local stk        = Instance.new("UIStroke")
        stk.Thickness    = 2.5
        stk.Color        = Color3.new(0, 0, 0)
        stk.Transparency = 0.05
        stk.Parent       = lbl
    end
    local lbl = KillerWarnGui:FindFirstChild("WarnLabel")
    if not lbl then return end
    if warnLevel == 2 then
        local now = tick()
        if now - _kwBlinkTimer >= 0.3 then
            _kwBlinkTimer = now
            _kwBlinkState = not _kwBlinkState
        end
        lbl.Text       = "!!"
        lbl.TextColor3 = Color3.fromRGB(255, 30, 30)
        lbl.Visible    = _kwBlinkState
    else
        lbl.Text       = "!"
        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        lbl.Visible    = true
        _kwBlinkState  = true
    end
end
local function SetupParryRing()
    if ParryRing and ParryRing.Parent then
        pcall(function() ParryRing:Destroy() end)
        ParryRing = nil
    end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    ParryRing              = Instance.new("CylinderHandleAdornment")
    ParryRing.Name         = "VONIXE_ParryRing"
    ParryRing.Color3       = getgenv().ParryRingColor or Color3.fromRGB(255, 255, 255)
    ParryRing.Transparency = 1
    ParryRing.AlwaysOnTop  = true
    ParryRing.ZIndex       = 10
    ParryRing.Height       = 0.08
    ParryRing.Radius       = tonumber(ParryDistance) or 10
    ParryRing.InnerRadius  = (tonumber(ParryDistance) or 10) - 0.15
    ParryRing.CFrame       = CFrame.new(0, -3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
    ParryRing.Adornee      = root
    ParryRing.Parent       = PlayerGui
end
local AimIndicatorGui = Instance.new("ScreenGui")
AimIndicatorGui.Name = "Vonixe_AimIndicator"
AimIndicatorGui.IgnoreGuiInset = true
AimIndicatorGui.ResetOnSpawn = false
local _cg = game:GetService("CoreGui")
if gethui then
    AimIndicatorGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(AimIndicatorGui)
    AimIndicatorGui.Parent = _cg
else
    AimIndicatorGui.Parent = _cg
end
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, AimRadius * 2, 0, AimRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = AimIndicatorGui
local _fovCorner = Instance.new("UICorner", FOVCircle)
_fovCorner.CornerRadius = UDim.new(1, 0)
local _fovStroke = Instance.new("UIStroke", FOVCircle)
_fovStroke.Color = Color3.new(1, 1, 1)
_fovStroke.Transparency = 0.5
_fovStroke.Thickness = 1.5
local CH_Container = Instance.new("Frame")
CH_Container.Name = "CrosshairContainer"
CH_Container.Size = UDim2.new(0, 50, 0, 50)
CH_Container.AnchorPoint = Vector2.new(0.5, 0.5)
CH_Container.Position = UDim2.new(0.5, 0, 0.5, 0)
CH_Container.BackgroundTransparency = 1
CH_Container.Visible = false
CH_Container.Parent = AimIndicatorGui
local CH_Dot = Instance.new("Frame", CH_Container)
CH_Dot.AnchorPoint = Vector2.new(0.5, 0.5)
CH_Dot.Position = UDim2.new(0.5, 0, 0.5, 0)
CH_Dot.Size = UDim2.new(0, 4, 0, 4)
CH_Dot.BackgroundColor3 = Color3.new(0, 1, 0)
local CH_DotCorner = Instance.new("UICorner", CH_Dot)
local CH_Stroke = Instance.new("UIStroke", CH_Dot)
CH_Stroke.Color = Color3.new(0,0,0)
CH_Stroke.Thickness = 1
CH_Stroke.Enabled = false
local CH_Top = Instance.new("Frame", CH_Container)
local CH_Bottom = Instance.new("Frame", CH_Container)
local CH_Left = Instance.new("Frame", CH_Container)
local CH_Right = Instance.new("Frame", CH_Container)
for _, line in ipairs({CH_Top, CH_Bottom, CH_Left, CH_Right}) do
    line.BackgroundColor3 = Color3.new(0, 1, 0)
    line.BorderSizePixel = 0
    local stk = Instance.new("UIStroke", line)
    stk.Color = Color3.new(0,0,0)
    stk.Thickness = 1
end
CH_Top.AnchorPoint = Vector2.new(0.5, 1)
CH_Bottom.AnchorPoint = Vector2.new(0.5, 0)
CH_Left.AnchorPoint = Vector2.new(1, 0.5)
CH_Right.AnchorPoint = Vector2.new(0, 0.5)
local function UpdateCrosshair()
    if not CH_Container then return end
    local style = getgenv().CrosshairStyle or "Cross"
    local size = getgenv().CrosshairSize or 4
    local color = getgenv().CrosshairColor or Color3.fromRGB(0, 255, 0)
    local ox = getgenv().CrosshairOffsetX or 0
    local oy = getgenv().CrosshairOffsetY or 0
    CH_Container.Visible = getgenv().ShowCrosshair or false
    CH_Container.Position = UDim2.new(0.5, ox, 0.5, oy)
    CH_Dot.BackgroundColor3 = color
    for _, line in ipairs({CH_Top, CH_Bottom, CH_Left, CH_Right}) do
        line.BackgroundColor3 = color
    end
    if style == "Cross" then
        CH_Dot.Visible = false
        CH_Stroke.Enabled = false
        for _, line in ipairs({CH_Top, CH_Bottom, CH_Left, CH_Right}) do
            line.Visible = true
        end
        local length = size * 3
        local thickness = math.max(1, math.floor(size / 3))
        local gap = size
        CH_Top.Size = UDim2.new(0, thickness, 0, length)
        CH_Top.Position = UDim2.new(0.5, 0, 0.5, -gap)
        CH_Bottom.Size = UDim2.new(0, thickness, 0, length)
        CH_Bottom.Position = UDim2.new(0.5, 0, 0.5, gap)
        CH_Left.Size = UDim2.new(0, length, 0, thickness)
        CH_Left.Position = UDim2.new(0.5, -gap, 0.5, 0)
        CH_Right.Size = UDim2.new(0, length, 0, thickness)
        CH_Right.Position = UDim2.new(0.5, gap, 0.5, 0)
    elseif style == "Dot" then
        CH_Dot.Visible = true
        CH_DotCorner.CornerRadius = UDim.new(1, 0)
        CH_Dot.Size = UDim2.new(0, size, 0, size)
        CH_Dot.BackgroundTransparency = 0
        CH_Stroke.Enabled = false
        for _, line in ipairs({CH_Top, CH_Bottom, CH_Left, CH_Right}) do line.Visible = false end
    elseif style == "Circle" then
        CH_Dot.Visible = true
        CH_DotCorner.CornerRadius = UDim.new(1, 0)
        CH_Dot.Size = UDim2.new(0, size * 2, 0, size * 2)
        CH_Dot.BackgroundTransparency = 1
        CH_Stroke.Enabled = true
        CH_Stroke.Color = color
        CH_Stroke.Thickness = math.max(1, math.floor(size / 4))
        for _, line in ipairs({CH_Top, CH_Bottom, CH_Left, CH_Right}) do line.Visible = false end
    end
end
local Lighting       = game:GetService("Lighting")
local _FPSBoostOn    = false
local _PotatoOn      = false
local _HasScanned    = false
local _OrigShadows   = Lighting.GlobalShadows
local _OrigFogEnd    = Lighting.FogEnd
local _OrigFogStart  = Lighting.FogStart
local _StoredEffects   = {}
local _StoredParticles = {}
local _StoredTextures  = {}
local _StoredShadows   = {}
local function ScanWorld()
    table.clear(_StoredEffects)
    table.clear(_StoredParticles)
    table.clear(_StoredShadows)
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            table.insert(_StoredEffects, { obj = v, was = v.Enabled })
        end
    end
    local desc = workspace:GetDescendants()
    for i, v in ipairs(desc) do
        if v:IsA("BasePart") then
            table.insert(_StoredShadows, { obj = v, cast = v.CastShadow })
        end
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            if v.Enabled then table.insert(_StoredParticles, v) end
        end
        if i % 1000 == 0 then task.wait() end
    end
    _HasScanned = true
end
local function ApplyPerformanceState()
    if _FPSBoostOn then
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.FogStart      = 9e9
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        for _, d in ipairs(_StoredEffects) do
            pcall(function() if d.obj.Parent then d.obj.Enabled = false end end)
        end
        for _, v in ipairs(_StoredParticles) do
            pcall(function() if v.Parent then v.Enabled = false end end)
        end
        for _, d in ipairs(_StoredShadows) do
            pcall(function() if d.obj.Parent then d.obj.CastShadow = false end end)
        end
    else
        Lighting.GlobalShadows = _OrigShadows
        Lighting.FogEnd        = _OrigFogEnd
        Lighting.FogStart      = _OrigFogStart
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        for _, d in ipairs(_StoredEffects) do
            pcall(function() if d.obj.Parent then d.obj.Enabled = d.was end end)
        end
        for _, v in ipairs(_StoredParticles) do
            pcall(function() if v.Parent then v.Enabled = true end end)
        end
        for _, d in ipairs(_StoredShadows) do
            pcall(function() if d.obj.Parent then d.obj.CastShadow = d.cast end end)
        end
        _HasScanned = false
    end
end
local function SetFPSBoost(state)
    _FPSBoostOn = state
    if state and not _HasScanned then
        task.spawn(function()
            ScanWorld()
            ApplyPerformanceState()
        end)
    else
        ApplyPerformanceState()
    end
end
local ParryRemoteCache = nil
local ATTACK_ANIM_IDS = {
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://121571390309073"] = true,
    ["rbxassetid://78935059863801"]  = true, 
    ["rbxassetid://80411309607666"]  = true, 
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://95934119190708"]  = true,
    ["rbxassetid://117042998468241"] = true, 
    ["rbxassetid://129918027564423"] = true, 
    ["rbxassetid://132817836308238"] = true, 
    ["rbxassetid://82666958311998"]  = true, 
    ["rbxassetid://129784271201071"] = true, 
    ["rbxassetid://121216847022485"] = true, 
    ["rbxassetid://135002183282873"] = true, 
    ["rbxassetid://78432063483146"] = true, 
    ["rbxassetid://77081789642514"] = true, 
    ["rbxassetid://118907603246885"] = true, 
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://138720291317243"] = true,
    ["rbxassetid://115244153053858"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://117070354890871"] = true,
    ["rbxassetid://106871536134254"] = true,
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://74968262036854"] = true,
}
local LastParryTick = 0
local CFG_ParryCooldown = 0.4
local CFG_BurstAmount = 8
local CFG_FaceSensitivity = 3.5  -- dari hasil testing
local function GetParryRemote()
    if ParryRemoteCache and ParryRemoteCache.Parent then
        return ParryRemoteCache
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end
    local item   = remotes:FindFirstChild("Items")
    local dagger = item and item:FindFirstChild("Parrying Dagger")
    if dagger and dagger:FindFirstChild("parry") then
        ParryRemoteCache = dagger.parry
    end
    return ParryRemoteCache
end
local _ServerCooldownEnd   = 0
local _ParryResultConn     = nil
local _isFakingParryResult = false
local _parryGUITween       = nil
local _parryGUICompConn    = nil
local function IsParryServerCooldown()
    return tick() < _ServerCooldownEnd
end
local function DoParryGUIUpdate(cd)
    pcall(function()
        local TS    = game:GetService("TweenService")
        local dark  = Color3.fromRGB(77, 77, 77)
        local light = Color3.fromRGB(255, 255, 255)
        local sg = PlayerGui:FindFirstChild("Survivor") or PlayerGui:FindFirstChild("Survivor-con")
        if not sg then return end
        local gen  = sg:FindFirstChild("Gen");       if not gen  then return end
        local itf  = gen:FindFirstChild("ItemFrame"); if not itf  then return end
        local gf   = itf:FindFirstChild("Gui");       if not gf   then return end
        local bar  = gf:FindFirstChild("Bar");        if not bar  then return end
        local grad = bar:FindFirstChild("UIGradient"); if not grad then return end

        if _parryGUITween then
            pcall(function() _parryGUITween:Cancel() end)
            _parryGUITween = nil
        end
        if _parryGUICompConn then
            pcall(function() _parryGUICompConn:Disconnect() end)
            _parryGUICompConn = nil
        end

        local icon = gf:FindFirstChild("icon")
        if icon then icon.ImageColor3 = dark end
        if gf:IsA("ImageLabel") or gf:IsA("ImageButton") then
            gf.ImageColor3 = dark
        end
        grad.Offset = Vector2.new(0, 0.75)
        local tw = TS:Create(grad, TweenInfo.new(cd, Enum.EasingStyle.Linear), {
            Offset = Vector2.new(0, 0.25)
        })
        _parryGUITween = tw
        tw:Play()
        _parryGUICompConn = tw.Completed:Connect(function()
            _parryGUITween    = nil
            _parryGUICompConn = nil
            if icon then icon.ImageColor3 = light end
            if gf:IsA("ImageLabel") or gf:IsA("ImageButton") then
                gf.ImageColor3 = light
            end
        end)
    end)
end
local function StartParryRingCooldown(totalCd)
    task.spawn(function()
        local endTime = _ServerCooldownEnd
        if ParryRing and ParryRing.Parent then
            ParryRing.Color3 = Color3.fromRGB(255, 50, 50)
        end
        task.wait(totalCd)
        if ParryRing and ParryRing.Parent then
            ParryRing.Color3 = getgenv().ParryRingColor or Color3.fromRGB(255, 255, 255)
        end
    end)
end
local function InitParryResultWatcher()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes"); if not remotes then return end
    local dagger  = remotes:FindFirstChild("Items"); dagger = dagger and dagger:FindFirstChild("Parrying Dagger")
    local pResult = dagger and dagger:FindFirstChild("parryResult"); if not pResult then return end
    if _ParryResultConn then _ParryResultConn:Disconnect() end
    _ParryResultConn = pResult.OnClientEvent:Connect(function(_, cooldown)
        local cd = tonumber(cooldown) or 0
        if cd > 0 then
            _ServerCooldownEnd = tick() + cd
            if not _isFakingParryResult then
                DoParryGUIUpdate(cd)
                StartParryRingCooldown(cd)
            end
        end
    end)
end
local function HookParryBlock()
    pcall(function()
        local PARRY_ANIM_IDS = {
            ["rbxassetid://109133187196613"] = true, -- Default
            ["rbxassetid://127096285501517"] = true, -- Enten Skin
            ["rbxassetid://81793464499285"]  = true, -- Time Skin
        }
        local function FakeParryResult()
            pcall(function()
                if not firesignal then return end
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                local dagger  = remotes and remotes:FindFirstChild("Items")
                               and remotes.Items:FindFirstChild("Parrying Dagger")
                local pResult = dagger and dagger:FindFirstChild("parryResult")
                if pResult then
                    local remaining = math.max(0.1, _ServerCooldownEnd - tick())
                    _isFakingParryResult = true
                    firesignal(pResult.OnClientEvent, false, remaining)
                    task.defer(function() _isFakingParryResult = false end)
                end
            end)
        end
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local isGodMode = getgenv().GodModeEnabled
            local isOnCD    = tick() < _ServerCooldownEnd
            if not isGodMode and not isOnCD then
                return oldNamecall(self, ...)
            end
            if method == "FireServer" then
                if isGodMode then
                    local rn = tostring(self)
                    if rn == "Damage" or rn == "Damagedone" or rn == "Damageviz" or rn == "gotknocked" then
                        return
                    end
                end
                if isOnCD then
                    local parryRemote = GetParryRemote()
                    if parryRemote and rawequal(self, parryRemote) then
                        task.spawn(FakeParryResult)
                        return
                    end
                end
            elseif method == "Play" and isOnCD then
                local isParryAnim = false
                pcall(function()
                    if self.Animation and PARRY_ANIM_IDS[self.Animation.AnimationId] then
                        isParryAnim = true
                    end
                end)
                if isParryAnim then
                    local result = oldNamecall(self, ...)
                    task.spawn(function() pcall(function() self:Stop(0) end) end)
                    return result
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end
local function HookParryModule()
    pcall(function()
        local mod = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Items"):WaitForChild("ParryClient"))
        if type(mod) == "table" and type(mod.new) == "function" then
            local oldNew = mod.new
            mod.new = function(data)
                if type(data) == "table" and data.animationId then
                    getgenv().DetectedParryAnim = "rbxassetid://" .. tostring(data.animationId)
                end
                return oldNew(data)
            end
        end
    end)
end

task.spawn(function()
    task.wait(2)
    HookParryModule()
    InitParryResultWatcher()
    HookParryBlock()
end)
local _cachedParryAnim = nil

local function GetAutoSkinAnimation()
    if getgenv().DetectedParryAnim then 
        return getgenv().DetectedParryAnim 
    end
    
    pcall(function()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Parrying Dagger") or LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Parrying Dagger")
        if tool then
            local scriptObj = tool:FindFirstChildOfClass("LocalScript")
            if scriptObj and getscriptclosure and getconstants then
                local consts = getconstants(getscriptclosure(scriptObj))
                for _, const in ipairs(consts) do
                    local str = tostring(const)
                    if str == "109133187196613" or str == "127096285501517" or str == "81793464499285" then
                        getgenv().DetectedParryAnim = "rbxassetid://" .. str
                        break
                    end
                end
            end
        end
    end)
    
    return getgenv().DetectedParryAnim or "rbxassetid://109133187196613"
end

local function TriggerManualVisuals(root, animator)
    pcall(function()
        if animator then
            local animId = GetAutoSkinAnimation()
            if not _cachedParryAnim or _cachedParryAnim.AnimationId ~= animId then
                if _cachedParryAnim then _cachedParryAnim:Destroy() end
                _cachedParryAnim = Instance.new("Animation")
                _cachedParryAnim.AnimationId = animId
            end
            local track = animator:LoadAnimation(_cachedParryAnim)
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
        end
    end)
    pcall(function()
        local CollectionService = game:GetService("CollectionService")
        CollectionService:AddTag(root, "doing action")
        task.delay(0.8, function()
            if root and root.Parent then
                CollectionService:RemoveTag(root, "doing action")
            end
        end)
    end)
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local slow = remotes and remotes:FindFirstChild("Mechanics") and remotes.Mechanics:FindFirstChild("Slow")
        if slow then slow:Fire(0, 1, 0) end
    end)
end
local function FireParry(killerChar)
    if IsParryServerCooldown() then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not (root and hum) or hum.Health <= 0 then return end
    local tool = char:FindFirstChild("Parrying Dagger")
    if not tool then return end
    local now = tick()
    if now - LastParryTick < CFG_ParryCooldown then return end
    LastParryTick = now
    task.spawn(function()
        local delay = getgenv().ParryDelayOffset or 0
        if delay > 0 then task.wait(delay) end
        if not AutoParry then return end
        local kRoot = killerChar and killerChar:FindFirstChild("HumanoidRootPart")
        if kRoot then
            pcall(function()
                if hum then hum.AutoRotate = false end
                root.CFrame = CFrame.new(root.Position, Vector3.new(kRoot.Position.X, root.Position.Y, kRoot.Position.Z))
            end)
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        TriggerManualVisuals(root, animator)
        local remote = GetParryRemote()
        for i = 1, CFG_BurstAmount do
            if not AutoParry then break end
            if IsParryServerCooldown() then break end
            if not remote or not remote.Parent then break end
            pcall(function() remote:FireServer() end)
            task.wait(0.008)
        end
        if kRoot then
            task.delay(0.35, function()
                if hum and hum.Parent then hum.AutoRotate = true end
            end)
        end
    end)
end
local function IsKillerFacingMe(killerChar)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local kRoot  = killerChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and kRoot) then return false end
    local killerPos  = kRoot.Position
    local killerLook = kRoot.CFrame.LookVector
    local myPos      = myRoot.Position
    local toPlayer  = myPos - killerPos
    local projected = toPlayer:Dot(killerLook)
    if projected <= 0 then return false end
    local closestPoint = killerPos + killerLook * projected
    local lateralDist  = (myPos - closestPoint).Magnitude
    return lateralDist <= CFG_FaceSensitivity
end
local cachedRayFilter = {}
local function IsAimVisible(targetPart)
    if not WallCheck then return true end
    local cam = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local direction = targetPart.Position - origin
    local myChar = LocalPlayer.Character
    table.clear(cachedRayFilter)
    if cam then table.insert(cachedRayFilter, cam) end
    if myChar then table.insert(cachedRayFilter, myChar) end
    aimRayParams.FilterDescendantsInstances = cachedRayFilter
    local result = workspace:Raycast(origin, direction, aimRayParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end
local function GetClosestAimTarget(currentTarget)
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local center   = camera.ViewportSize * 0.5
    local camPos   = camera.CFrame.Position
    local shortest = AimRadius
    local bestTarget = nil
    local myTeam   = (LocalPlayer.Team and LocalPlayer.Team.Name:lower()) or ""
    local isKiller = myTeam:find("killer") ~= nil

    -- Pertahankan target lama kalau masih valid (skip full scan)
    if currentTarget and currentTarget.Parent then
        local hum = currentTarget.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local pos, vis = camera:WorldToViewportPoint(currentTarget.Position)
            if vis and (Vector2.new(pos.X, pos.Y) - center).Magnitude <= AimRadius then
                if not WallCheck or IsAimVisible(currentTarget) then
                    return currentTarget
                end
            end
        end
    end

    for _, p in ipairs(_CachedPlayers) do   -- ✅ cached, tidak alokasi table baru
        if p == LocalPlayer or not p.Character then continue end
        local char = p.Character
        local hum  = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local enemyTeam     = (p.Team and p.Team.Name:lower()) or ""
        local isEnemyKiller = enemyTeam:find("killer") ~= nil
        local targetMode    = getgenv().AimbotTeamTarget or "Killer"
        if targetMode == "Killer" and not isEnemyKiller then continue end
        if targetMode == "Team"   and isEnemyKiller     then continue end
        if isKiller then
            if GetGameValue(char, "Knocked") or GetGameValue(char, "IsHooked") then continue end
        end

        local targetPart = TargetPartCache[char]
        if not targetPart or not targetPart.Parent then
            targetPart =
                (getgenv().AimbotPart == "Head"             and char:FindFirstChild("Head"))
                or (getgenv().AimbotPart == "Body (RootPart)" and char:FindFirstChild("HumanoidRootPart"))
                or char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso")
                or char:FindFirstChild("HumanoidRootPart")
                or char.PrimaryPart
            TargetPartCache[char] = targetPart
        end
        if not targetPart then continue end

        -- ✅ Early cull: cek jarak 3D dulu, JAUH lebih murah dari WorldToViewportPoint
        if (targetPart.Position - camPos).Magnitude > AimDistance then continue end

        local pos, visible = camera:WorldToViewportPoint(targetPart.Position)
        if not visible then continue end

        local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if screenDist < shortest then
            if not WallCheck or IsAimVisible(targetPart) then
                shortest  = screenDist
                bestTarget = targetPart
            end
        end
    end

    CachedAimTarget = bestTarget
    return CachedAimTarget
end
local function WatchKillerParry(char)
    local hum  = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 10)
    if not animator then return end

    if not getgenv().VonixeParryConns then getgenv().VonixeParryConns = {} end
    if getgenv().VonixeParryConns[char] then
        getgenv().VonixeParryConns[char]:Disconnect()
    end

    getgenv().VonixeParryConns[char] = animator.AnimationPlayed:Connect(function(track)
        if not track.Animation then return end
        local animId = track.Animation.AnimationId
        local animName = string.lower(track.Animation.Name or "")

        local isAttack = false
        if ATTACK_ANIM_IDS and ATTACK_ANIM_IDS[animId] then
            isAttack = true
        elseif animName:find("attack") or animName:find("slash") or animName:find("swing")
            or animName:find("hit") or animName:find("lunge") then
            isAttack = true
        end

        if not isAttack then return end
        if not AutoParry then return end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local eRoot  = char:FindFirstChild("HumanoidRootPart")
        if not (myRoot and eRoot) then return end

        local profile       = GetKillerProfile(char)
        local effectiveRange = getgenv().EffectiveRangeOverride or profile.EffectiveRange or 7.8
        local maxDist       = tonumber(ParryDistance) or 10

        task.spawn(function()
            local startTime = tick()
            local fired     = false

            -- Poll selama 0.6 detik (durasi max swing killer)
            while not fired and (tick() - startTime <= 0.6) do
                if not AutoParry or not myRoot or not eRoot then break end

                local currentDist = (eRoot.Position - myRoot.Position).Magnitude

                -- Dalam detection range + effective range + facing check
                if currentDist <= maxDist and currentDist <= effectiveRange and IsKillerFacingMe(char) then
                    fired = true

                    local ping       = GetPing()
                    local reactDelay = math.max(0, (profile.Delay or 0) - ping)

                    if reactDelay > 0.01 then
                        task.wait(reactDelay)
                    end

                    -- Fire parry tanpa cek IsKillerFacingMe lagi
                    -- (sudah dicek di atas, double check terlalu strict)
                    FireParry(char)
                    break
                end

                task.wait(0.05)
            end
        end)
    end)
end
local function SetupPlayerParryWatch(plr)
    if plr == LocalPlayer then return end
    if plr.Character then
        task.spawn(WatchKillerParry, plr.Character)
    end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        task.spawn(WatchKillerParry, char)
    end)
end
task.spawn(function()
    task.wait(2)
    for _, plr in ipairs(Players:GetPlayers()) do
        SetupPlayerParryWatch(plr)
    end
end)
Players.PlayerAdded:Connect(SetupPlayerParryWatch)
local GEN_COLOR_MID = Color3.fromRGB(255, 140, 0)
local GEN_COLOR_END = Color3.fromRGB(0, 255, 120)
local function updateGeneratorProgress(generatorPart)
    if not generatorPart or not generatorPart.Parent then return true end
    local generatorModel = generatorPart.Parent
    local percent = GetGameValue(generatorModel, "RepairProgress") or GetGameValue(generatorModel, "Progress") or 0
    if percent >= 100 then
        RemoveHighlight(generatorModel)
        local b = generatorPart:FindFirstChild("GenTag")
        if b then b:Destroy() end
        return true
    end
    if not ESP_Generator then
        RemoveHighlight(generatorModel)
        local b = generatorPart:FindFirstChild("GenTag")
        if b then b:Destroy() end
        return false
    end
    local rounded    = math.floor(percent * 10) / 10
    local cp         = math.clamp(percent, 0, 100)
    local finalColor = cp < 50
        and ESP_COLORS.Generator:Lerp(GEN_COLOR_MID, cp / 50)
        or  GEN_COLOR_MID:Lerp(GEN_COLOR_END, (cp - 50) / 50)
    ApplyHighlight(generatorModel, finalColor)
    local percentStr = s_format("%.1f%%", rounded)
    local bb = generatorPart:FindFirstChild("GenTag")
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = "GenTag"; bb.Parent = generatorPart; bb.Adornee = generatorPart
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.MaxDistance = 300
        bb.Size = UDim2.new(0, 100, 0, 30); bb.StudsOffset = Vector3.new(0, 3.2, 0)
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"; lbl.Parent = bb; lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 15); lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
        lbl.Text = percentStr; lbl.TextColor3 = finalColor
        local stk = Instance.new("UIStroke"); stk.Parent = lbl
        stk.Thickness = 1.2; stk.Transparency = 0.2; stk.Color = Color3.new(0, 0, 0)
        local barBg = Instance.new("Frame")
        barBg.Name = "BarBg"; barBg.Parent = bb
        barBg.Size = UDim2.new(1, 0, 0, 5); barBg.Position = UDim2.new(0, 0, 0, 20)
        barBg.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); barBg.BackgroundTransparency = 0.3
        local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(1, 0); bgCorner.Parent = barBg
        local bgStroke = Instance.new("UIStroke"); bgStroke.Parent = barBg; bgStroke.Color = Color3.new(0,0,0); bgStroke.Thickness = 1.2
        local barFill = Instance.new("Frame")
        barFill.Name = "BarFill"; barFill.Parent = barBg
        barFill.Size = UDim2.new(cp / 100, 0, 1, 0)
        barFill.BackgroundColor3 = finalColor; barFill.BorderSizePixel = 0
        local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(1, 0); fillCorner.Parent = barFill
    else
        local lbl = bb:FindFirstChild("Label")
        if lbl then lbl.Text = percentStr; lbl.TextColor3 = finalColor end
        local barBg = bb:FindFirstChild("BarBg")
        if barBg then
            local barFill = barBg:FindFirstChild("BarFill")
            if barFill then
                barFill.Size = UDim2.new(cp / 100, 0, 1, 0)
                barFill.BackgroundColor3 = finalColor
            end
        end
    end
    return false
end
local function RefreshESP()
    local myChar = Players.LocalPlayer.Character
    local myPos  = myChar and myChar.PrimaryPart and myChar.PrimaryPart.Position
    if not workspace.CurrentCamera then return end
    if ESP_Enabled then
        for _, p in ipairs(_CachedPlayers) do
            if p ~= LocalPlayer then
                local team     = p.Team
                local teamName = team and string.lower(team.Name) or ""
                local isKiller   = string.find(teamName, "killer") ~= nil
                local isSurvivor = string.find(teamName, "survivors") ~= nil
                local shouldESP = false
                if isKiller   and ESP_Killer then shouldESP = true
                elseif isSurvivor and ESP_Player then shouldESP = true end
                if shouldESP then
                    CreatePlayerESP(p, isKiller)
                else
                    RemovePlayerESP(p)
                end
            end
        end
    end
    if ESP_Enabled and ESP_Generator then
        if not PrevESPState.Generator then PrevESPState.Generator = true end
        local gens    = CachedMapObjects.Generators
        local newGens = {}
        for i = 1, #gens do
            local obj = gens[i]
            if obj and obj.Parent then
                local finished = updateGeneratorProgress(obj)
                if not finished then t_insert(newGens, obj) end
            end
        end
        CachedMapObjects.Generators = newGens
        ActiveGenerators = newGens
    elseif PrevESPState.Generator then
        for _, obj in ipairs(CachedMapObjects.Generators) do
            if obj and obj.Parent then
                RemoveHighlight(obj.Parent)
                local b = obj:FindFirstChild("GenTag"); if b then b:Destroy() end
            end
        end
        PrevESPState.Generator = false
    end
    if ESP_Enabled and ESP_Pallet then
        if not PrevESPState.Pallet then PrevESPState.Pallet = true end
        local validPallets = {}
        for i = #CachedMapObjects.Pallets, 1, -1 do
            local pallet = CachedMapObjects.Pallets[i]
            if pallet and pallet.Parent then
                local dist = math.huge
                if myPos and pallet:IsA("BasePart") then
                    dist = (pallet.Position - myPos).Magnitude
                end
                table.insert(validPallets, {obj = pallet, dist = dist, idx = i})
            else
                t_remove(CachedMapObjects.Pallets, i)
            end
        end
        table.sort(validPallets, function(a, b) return a.dist < b.dist end)
        for i, data in ipairs(validPallets) do
            if i <= 10 then
                ApplyHighlight(data.obj.Parent, ESP_COLORS.Pallet)
                RemoveMapTag(data.obj)
            else
                RemoveHighlight(data.obj.Parent)
                RemoveMapTag(data.obj)
            end
        end
    elseif PrevESPState.Pallet then
        for _, p in ipairs(CachedMapObjects.Pallets) do
            if p and p.Parent then
                RemoveHighlight(p.Parent)
                RemoveMapTag(p)
            end
        end
        PrevESPState.Pallet = false
    end
    if ESP_Enabled and ESP_Window then
        if not PrevESPState.Window then PrevESPState.Window = true end
        for i = #CachedMapObjects.Windows, 1, -1 do
            local w = CachedMapObjects.Windows[i]
            if w and w.Parent then
                ApplyVaultESP(w, ESP_COLORS.Window)
                local box = w:FindFirstChild("VESP_Vault")
                if box then box.Transparency = ESP_ModeOutline and 0.8 or 0.5 end
                RemoveMapTag(w)
            else
                t_remove(CachedMapObjects.Windows, i)
            end
        end
    elseif PrevESPState.Window then
        for _, w in ipairs(CachedMapObjects.Windows) do
            if w and w.Parent then RemoveVaultESP(w); RemoveMapTag(w) end
        end
        PrevESPState.Window = false
    end
    if ESP_Enabled and ESP_Gate then
        if not PrevESPState.Gate then PrevESPState.Gate = true end
        for i = #CachedMapObjects.Gates, 1, -1 do
            local gate = CachedMapObjects.Gates[i]
            if gate and gate.Parent then
                ApplyHighlight(gate.Parent, ESP_COLORS.Gate)
                RemoveMapTag(gate)
            else
                t_remove(CachedMapObjects.Gates, i)
            end
        end
    elseif PrevESPState.Gate then
        for _, g in ipairs(CachedMapObjects.Gates) do
            if g and g.Parent then RemoveHighlight(g.Parent); RemoveMapTag(g) end
        end
        PrevESPState.Gate = false
    end
    if ESP_Enabled and ESP_Hook then
        if not PrevESPState.Hook then PrevESPState.Hook = true end
        local validHooks = {}
        for i = #CachedMapObjects.Hooks, 1, -1 do
            local hook = CachedMapObjects.Hooks[i]
            if hook and hook.Parent then
                local dist = math.huge
                local part = hook:FindFirstChildWhichIsA("BasePart", true)
                if myPos and part then
                    dist = (part.Position - myPos).Magnitude
                end
                table.insert(validHooks, {obj = hook, dist = dist, idx = i, part = part})
            else
                t_remove(CachedMapObjects.Hooks, i)
            end
        end
        table.sort(validHooks, function(a, b) return a.dist < b.dist end)
        for i, data in ipairs(validHooks) do
            if i <= 6 then
                ApplyHighlight(data.obj.Parent, ESP_COLORS.Hook)
                if data.part then RemoveMapTag(data.part) end
            else
                RemoveHighlight(data.obj.Parent)
                if data.part then RemoveMapTag(data.part) end
            end
        end
    elseif PrevESPState.Hook then
        for _, h in ipairs(CachedMapObjects.Hooks) do
            if h and h.Parent then
                RemoveHighlight(h.Parent)
                local part = h:FindFirstChildWhichIsA("BasePart", true)
                if part then RemoveMapTag(part) end
            end
        end
        PrevESPState.Hook = false
    end
    if ESP_Enabled and ESP_SCP then
        if not PrevESPState.SCP then PrevESPState.SCP = true end
        for i = #CachedMapObjects.SCPs, 1, -1 do
            local scp = CachedMapObjects.SCPs[i]
            if scp and scp.Parent then
                ApplyHighlight(scp, ESP_COLORS.SCP)
                local root = scp:FindFirstChild("HumanoidRootPart") or scp:FindFirstChild("Torso") or scp.PrimaryPart
                if root then
                    RemoveMapTag(root)
                end
            else
                t_remove(CachedMapObjects.SCPs, i)
            end
        end
    elseif PrevESPState.SCP then
        for _, scp in ipairs(CachedMapObjects.SCPs) do
            if scp and scp.Parent then 
                RemoveHighlight(scp)
                local root = scp:FindFirstChild("HumanoidRootPart") or scp:FindFirstChild("Torso") or scp.PrimaryPart
                if root then RemoveMapTag(root) end
            end
        end
        PrevESPState.SCP = false
    end
end
task.spawn(function()
    while task.wait(0.8) do
        if not getgenv().VONIXE_VD_RUNNING then break end
        pcall(RefreshESP)
    end
end)
task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().VONIXE_VD_RUNNING then break end
        pcall(UpdateKillerWarn)
    end
end)
task.spawn(function()
    task.wait(1)
    SetupParryRing()
end)
local VonixeLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SCombat282/vonixehub/main/vonixe-library"))()
local Window = VonixeLib:CreateWindow({
    Title        = "Vonixe Hub",
    Subtitle     = "Violence District",
    Width        = 560,
    Height       = 420,
    ConfigFolder = "VonixeHub"
})
local SurvivorTab = Window:AddTab({ Title = "Survivor",      Icon = "heart" })
local KillerTab   = Window:AddTab({ Title = "Killer",        Icon = "sword" })
local ESPTab      = Window:AddTab({ Title = "ESP",           Icon = "eye" })
local AimbotTab   = Window:AddTab({ Title = "Aimbot",        Icon = "crosshair" })
local MiscTab     = Window:AddTab({ Title = "Miscellaneous", Icon = "box" })
local ESPMainGroup = ESPTab:AddGroupbox({ Title = "Main ESP" })
local ESPMasterToggle = ESPMainGroup:AddToggle({
    Title = "Enable ESP",
    Value = false,
    Callback = function(state)
        ESP_Enabled = state
        if not state then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then RemovePlayerESP(p) end
            end
        end
    end
})
ESPMainGroup:AddCheckbox({
    Title = "ESP Name",
    Value = true,
    DependsOn = ESPMasterToggle,
    Callback = function(state) ESP_Name = state end
})
ESPMainGroup:AddCheckbox({
    Title = "Item Icon ESP",
    Value = false,
    DependsOn = ESPMasterToggle,
    Callback = function(state) ESP_ItemIcon = state end
})
ESPMainGroup:AddCheckbox({
    Title = "Mode Outline",
    Value = false,
    DependsOn = ESPMasterToggle,
    Callback = function(state) ESP_ModeOutline = state end
})
ESPMainGroup:AddCheckbox({
    Title = "Skeleton ESP",
    Value = false,
    DependsOn = ESPMasterToggle,
    Callback = function(state) ESP_Skeleton = state end
})
ESPMainGroup:AddCheckbox({
    Title = "Killer Warn",
    Value = false,
    DependsOn = ESPMasterToggle,
    Callback = function(state) ESP_KillerWarn = state end
})
ESPMainGroup:AddColorPicker({
    Title = "SCP / Zombie",
    Default = ESP_COLORS.SCP,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_SCP = state end,
    Callback = function(color) ESP_COLORS.SCP = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Player",
    Default = ESP_COLORS.Player,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Player = state end,
    Callback = function(color) ESP_COLORS.Player = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Killer",
    Default = ESP_COLORS.Killer,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Killer = state end,
    Callback = function(color) ESP_COLORS.Killer = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Generator",
    Default = ESP_COLORS.Generator,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Generator = state end,
    Callback = function(color) ESP_COLORS.Generator = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Pallet",
    Default = ESP_COLORS.Pallet,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Pallet = state end,
    Callback = function(color) ESP_COLORS.Pallet = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Window / Vault",
    Default = ESP_COLORS.Window,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Window = state end,
    Callback = function(color) ESP_COLORS.Window = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Hook",
    Default = ESP_COLORS.Hook,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Hook = state end,
    Callback = function(color) ESP_COLORS.Hook = color end
})
ESPMainGroup:AddColorPicker({
    Title = "Exit Gate",
    Default = ESP_COLORS.Gate,
    HasCheckbox = true, ToggleValue = true,
    ToggleCallback = function(state) ESP_Gate = state end,
    Callback = function(color) ESP_COLORS.Gate = color end
})
SurvivorTab:AddSection({ Title = "Automation Settings" })
_G.Vonixe_VD_WebhookURL = _G.Vonixe_VD_WebhookURL or ""
_G.Vonixe_VD_StatsWebhookEnabled = _G.Vonixe_VD_StatsWebhookEnabled or false

local function sendStatsWebhook()
    if not _G.Vonixe_VD_StatsWebhookEnabled or _G.Vonixe_VD_WebhookURL == "" then return end
    
    local Player = game:GetService("Players").LocalPlayer
    local gears = "0"
    local screws = "0"
    local level = "0"
    local exp = "0"
    
    pcall(function()
        local info = Player.PlayerGui:FindFirstChild("Spectator")
        if info then
            local infoCont = info:FindFirstChild("Info")
            if infoCont then
                local your = infoCont:FindFirstChild("Your")
                if your then
                    if your:FindFirstChild("Gears") then gears = your.Gears.Text or "0" end
                    if your:FindFirstChild("Screws") then screws = your.Screws.Text or "0" end
                    if your:FindFirstChild("Border") and your.Border:FindFirstChild("Level") then
                        level = your.Border.Level.Text or "0"
                    end
                    
                    for _, v in pairs(your:GetDescendants()) do
                        if v.Name:lower() == "exp" or v.Name:lower():find("exp") then
                            if v:IsA("BoolValue") or v:IsA("StringValue") or v:IsA("NumberValue") or v:IsA("IntValue") then
                                exp = tostring(v.Value or v.Name)
                            elseif v:IsA("TextLabel") then
                                exp = v.Text
                            end
                        end
                    end
                end
            end
        end
        local expAttr = Player:GetAttribute("EXP")
        if expAttr then 
            exp = tostring(expAttr)
        else
            local expChild = Player:FindFirstChild("EXP")
            if expChild then
                exp = tostring(expChild.Value or expChild.Name)
            end
        end
    end)
    
    local HttpService = game:GetService("HttpService")
    local trackerFile = "Vonixe_VD_Stats.json"
    local tracker = { lastLevel = level, lastGears = gears, lastScrews = screws, lastExp = exp }
    
    if isfile and readfile and isfile(trackerFile) then
        pcall(function() 
            local saved = HttpService:JSONDecode(readfile(trackerFile)) 
            if saved and type(saved) == "table" and saved.lastLevel then
                tracker = saved
            end
        end)
    end
    
    local function formatDiff(old, new)
        if tostring(old) ~= tostring(new) then
            return tostring(old) .. " -> " .. tostring(new)
        end
        return tostring(new)
    end
    
    local diffLevel = formatDiff(tracker.lastLevel, level)
    local diffGears = formatDiff(tracker.lastGears, gears)
    local diffScrews = formatDiff(tracker.lastScrews, screws)
    
    tracker.lastLevel = level
    tracker.lastGears = gears
    tracker.lastScrews = screws
    tracker.lastExp = exp
    
    if writefile then pcall(function() writefile(trackerFile, HttpService:JSONEncode(tracker)) end) end
    
    local function maskName(name)
        if #name <= 2 then return name end
        return name:sub(1, 1) .. string.rep("*", #name - 2) .. name:sub(#name, #name)
    end
    
    local embed = {
        ["title"] = "Violence District | Vonixe Hub Auto Farm",
        ["color"] = 0xFF5500,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        ["fields"] = {
            { ["name"] = "Player", ["value"] = "```" .. maskName(Player.DisplayName) .. "```", ["inline"] = true },
            { ["name"] = "Level", ["value"] = "```" .. diffLevel .. "```", ["inline"] = true },
            { ["name"] = "EXP", ["value"] = "```" .. exp .. "```", ["inline"] = true },
            { ["name"] = "Gears", ["value"] = "```" .. diffGears .. "```", ["inline"] = true },
            { ["name"] = "Screws", ["value"] = "```" .. diffScrews .. "```", ["inline"] = true }
        },
        ["footer"] = { ["text"] = "Vonixe Hub" }
    }
    
    pcall(function()
        local req = (syn and syn.request) or http_request or request or (http and http.request)
        if req then
            req({
                Url = _G.Vonixe_VD_WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode({
                    ["username"] = "Vonixe Hub Auto Farm",
                    ["avatar_url"] = "https://i.imgur.com/IjU1vKY.gif",
                    ["embeds"] = { embed }
                })
            })
        end
    end)
end

local AutoFarmGroup = SurvivorTab:AddGroupbox({ Title = "Auto Farm (Insta-Win)" })
AutoFarmGroup:AddToggle({
    Title = "Auto Farm",
    Desc = "Otomatis escape saat jadi survivor, server hop kalo match udah mulai.",
    Default = false,
    Locked = not getgenv().Vonixe_IsPremium,
    Flag = "VonixeVD_AutoFarmEnabled",
    Callback = function(state)
        getgenv().AutoFarmEnabled = state
    end
})

AutoFarmGroup:AddToggle({ 
    Title = "Send Webhook", 
    Value = _G.Vonixe_VD_StatsWebhookEnabled, 
    Locked = not getgenv().Vonixe_IsPremium,
    Flag = "VonixeVD_StatsWebhookEnabled",
    Callback = function(s) 
        _G.Vonixe_VD_StatsWebhookEnabled = s
    end 
})

AutoFarmGroup:AddInput({
    Title = "Webhook URL", 
    Placeholder = "https://discord.com/api/webhooks/...", 
    Value = _G.Vonixe_VD_WebhookURL,
    Locked = not getgenv().Vonixe_IsPremium,
    Flag = "VonixeVD_WebhookURL",
    Callback = function(val) 
        _G.Vonixe_VD_WebhookURL = val 
    end
})

AutoFarmGroup:AddButton({
    Title = "Test Webhook",
    Locked = not getgenv().Vonixe_IsPremium,
    Callback = function()
        Window:Notify({Title="Webhook", Content="Mengirim tes...", Type="Info", Duration=3})
        task.spawn(function()
            local req = (syn and syn.request) or http_request or request or (http and http.request)
            if req and _G.Vonixe_VD_WebhookURL ~= "" then
                req({
                    Url = _G.Vonixe_VD_WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = game:GetService("HttpService"):JSONEncode({
                        ["username"] = "Vonixe Hub Auto Farm",
                        ["avatar_url"] = "https://i.imgur.com/IjU1vKY.gif",
                        ["embeds"] = {
                            {
                                ["title"] = "Vonixe Hub | Test Webhook",
                                ["color"] = 0x00FF88,
                                ["fields"] = {
                                    { ["name"]="Player",  ["value"]="```"..game:GetService("Players").LocalPlayer.DisplayName.."```", ["inline"]=true },
                                    { ["name"]="Status",  ["value"]="```Webhook aktif!```", ["inline"]=true },
                                }
                            }
                        }
                    })
                })
            end
        end)
    end
})

SurvivorTab:AddSection({ Title = "Survivor Exploits" })
local GodModeGroup = SurvivorTab:AddGroupbox({ Title = "God Mode (Invincibility)", Icon = "shield" })
GodModeGroup:AddToggle({
    Title = "Enable God Mode",
    Desc  = "Bikin kebal dari serangan (fitur eksperimental).",
    Value = false,
    Callback = function(state)
        getgenv().GodModeEnabled = state
    end
})

local SkillGroup = SurvivorTab:AddGroupbox({ Title = "Skill Check Settings" })
SkillGroup:AddToggle({
    Title = "Auto Perfect Skill",
    Default = false,
    Callback = function(state)
        ESP_AutoSkillCheck = state
        AutoGenerator      = state
        AutoGeneratorMode  = "Perfect"
    end
})
SkillGroup:AddSlider({
    Title = "Skill Check Speed",
    Desc  = "Slows down needle. Higher = slower. (default: 1)",
    Min = 0.1, Max = 10, Default = 1, Step = 0.1,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char then char:SetAttribute("skillcheckspeed", value) end
        getgenv().SkillCheckSpeedOverride = value
    end
})
SkillGroup:AddSlider({
    Title = "Skill Check Frequency",
    Desc  = "Frequency of skill checks appearing. (default: 1)",
    Min = 0.1, Max = 10, Default = 1, Step = 0.1,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char then char:SetAttribute("skillcheckfrequency", value) end
        getgenv().SkillCheckFreqOverride = value
    end
})
local MovementGroup = SurvivorTab:AddGroupbox({ Title = "Movement Manipulation" })
local SpeedBoostToggle = MovementGroup:AddToggle({
    Title = "Enable Speed Boost",
    Desc  = "Enable speed boost manipulation.",
    Value = false,
    HasKeybind = true,
    Callback = function(state)
        getgenv().SpeedBoostEnabled = state
    end
})
MovementGroup:AddSlider({
    Title = "Speed Boost Multiplier",
    Desc  = "Run speed (default: 1)",
    Min = 1, Max = 10, Default = 1, Step = 0.1,
    DependsOn = SpeedBoostToggle,
    Callback = function(value)
        getgenv().SpeedBoostOverride = value
    end
})
local VaultSpeedToggle = MovementGroup:AddToggle({
    Title = "Enable Vault Speed",
    Desc  = "Enable vault speed manipulation.",
    Value = false,
    HasKeybind = true,
    Callback = function(state)
        getgenv().VaultSpeedEnabled = state
    end
})
MovementGroup:AddSlider({
    Title = "Vault Speed Multiplier",
    Desc  = "Vault speed (default: 1)",
    Min = 1, Max = 10, Default = 1, Step = 0.1,
    DependsOn = VaultSpeedToggle,
    Callback = function(value)
        getgenv().VaultSpeedOverride = value
    end
})
local ParryGroup = SurvivorTab:AddGroupbox({ Title = "Auto Parry" })
local ParryMasterToggle = ParryGroup:AddToggle({
    Title = "Auto Parry",
    Desc  = "Automatically parry when the killer approaches.",
    Value = false,
    Callback = function(state)
        AutoParry = state
    end
})

ParryGroup:AddColorPicker({
    Title        = "Show Parry Ring",
    Desc         = "Show parry range ring around character.",
    Default      = Color3.fromRGB(255, 255, 255),
    HasCheckbox  = true,
    ToggleValue  = false,
    Flag         = "ParryRingSettings",
    Save         = true,
    DependsOn    = ParryMasterToggle,
    ToggleCallback = function(state)
        ShowParryRing = state
        if ParryRing and ParryRing.Parent then
            ParryRing.Transparency = state and 0.3 or 1
        end
    end,
    Callback = function(color)
        getgenv().ParryRingColor = color
        if ParryRing and ParryRing.Parent then
            ParryRing.Color3 = color
        end
    end
})
ParryGroup:AddSlider({
    Title = "Parry Distance",
    Desc  = "Auto Parry detection distance (studs).",
    Min = 3, Max = 25, Default = 10, Step = 1,
    Callback = function(value)
        ParryDistance = tonumber(value) or 10
        if ParryRing and ParryRing.Parent then
            ParryRing.Radius      = ParryDistance
            ParryRing.InnerRadius = ParryDistance - 0.15
        end
    end
})
ParryGroup:AddSlider({
    Title = "Parry Delay (ms)",
    Desc  = "Delay before parry is executed. 0 = instant.",
    Min = 0, Max = 500, Default = 0, Step = 10,
    Callback = function(value)
        getgenv().ParryDelayOffset = (tonumber(value) or 0) / 1000
    end
})
ParryGroup:AddSlider({
    Title = "Face Sensitivity",
    Desc  = "Higher = more lenient. Lower = stricter. 0 = disabled.",
    Min = 1, Max = 10, Default = 3.5, Step = 0.1,
    Callback = function(value)
        CFG_FaceSensitivity = value == 0 and math.huge or value
    end
})
KillerTab:AddSection({ Title = "Killer Features" })
KillerTab:AddLabel({ Title = "Coming soon..." })
local MobileAimbotGUI = nil
getgenv().MobileAimbotPressed = false
local function ToggleMobileAimbot(state)
    if not state then
        if MobileAimbotGUI then
            MobileAimbotGUI:Destroy()
            MobileAimbotGUI = nil
        end
        getgenv().MobileAimbotPressed = false
        return
    end
    if MobileAimbotGUI then return end
    local coreGui = game:GetService("CoreGui")
    local mainGui = coreGui:FindFirstChild("VonixeLib_Vonixe Hub") or (gethui and gethui():FindFirstChild("VonixeLib_Vonixe Hub"))
    local gui = Instance.new("ScreenGui")
    gui.Name = "Vonixe_MobileAimbot"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = coreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = coreGui
    end
    local frame = Instance.new("Frame")
    frame.Name = "MobileFrame"
    frame.BackgroundColor3 = Color3.fromRGB(12, 10, 10)
    frame.BackgroundTransparency = 0.1
    frame.Position = UDim2.new(1, -170, 0.5, -90)
    frame.AnchorPoint = Vector2.new(1, 0.5)
    frame.Size = UDim2.new(0, 150, 0, 70)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 0)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 100, 0)
    title.Text = "Vonixe Aimbot"
    title.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "Start Aimlock"
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        local newState = not getgenv().MobileAimbotPressed
        getgenv().MobileAimbotPressed = newState
        if newState then
            btn.Text = "Stop Aimlock"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        else
            btn.Text = "Start Aimlock"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
        end
    end)
    task.spawn(function()
        while MobileAimbotGUI == gui and mainGui and mainGui.Parent do
            task.wait(1)
        end
        if MobileAimbotGUI == gui and (not mainGui or not mainGui.Parent) then
            MobileAimbotGUI:Destroy()
            MobileAimbotGUI = nil
        end
    end)
    MobileAimbotGUI = gui
end
AimbotTab:AddSection({ Title = "Core Settings" })
local AimbotGroup = AimbotTab:AddGroupbox({ Title = "Targeting System", Icon = "target" })
AimbotGroup:AddToggle({
    Title = "Aimbot",
    Desc  = "Auto aim ke target terdekat.",
    Value = false,
    Callback = function(v)
        Aimbot = v
        if not v then CachedAimTarget = nil end
    end
})
AimbotGroup:AddToggle({
    Title = "Show Mobile Aim Button",
    Desc  = "Tombol on-screen untuk Hold to Lock (khusus mobile).",
    Value = false,
    Callback = function(v)
        ToggleMobileAimbot(v)
    end
})
AimbotGroup:AddDropdown({
    Title   = "Target Team",
    Desc    = "Pilih tim yang ingin di-lock oleh Aimbot.",
    Options = { "Killer", "Team", "Both" },
    Default = "Killer",
    Callback = function(v)
        getgenv().AimbotTeamTarget = v
    end
})
AimbotGroup:AddDropdown({
    Title   = "Aimbot Target",
    Desc    = "Bagian tubuh yang ditarget.",
    Options = { "Head", "Torso", "Body (RootPart)" },
    Default = "Torso",
    Callback = function(v) getgenv().AimbotPart = v end
})
AimbotGroup:AddDropdown({
    Title   = "Aimbot Trigger",
    Desc    = "Cara aktivasi aimbot.",
    Options = { "Hold to Lock", "Auto Lock (Always)" },
    Default = "Hold to Lock",
    Callback = function(v) getgenv().AimbotTrigger = v end
})
AimbotGroup:AddSlider({
    Title = "Aim Radius",
    Desc  = "Radius FOV circle (pixels).",
    Min = 30, Max = 300, Default = 60, Step = 5,
    Callback = function(v)
        AimRadius = tonumber(v) or 60
        if FOVCircle then
            FOVCircle.Size = UDim2.new(0, AimRadius * 2, 0, AimRadius * 2)
        end
    end
})
AimbotGroup:AddSlider({
    Title = "Aim Distance",
    Desc  = "Jarak maksimal target (studs).",
    Min = 20, Max = 300, Default = 80, Step = 10,
    Callback = function(v) AimDistance = tonumber(v) or 80 end
})
AimbotGroup:AddSlider({
    Title = "Aim Smoothness",
    Desc  = "Semakin tinggi = semakin smooth.",
    Min = 1, Max = 20, Default = 8, Step = 1,
    Callback = function(v) getgenv().AimbotSmoothness = tonumber(v) or 8 end
})
AimbotGroup:AddCheckbox({
    Title = "Wall Check",
    Value = true,
    Callback = function(v) WallCheck = v end
})
AimbotGroup:AddColorPicker({
    Title = "FOV Circle",
    Default = Color3.fromRGB(255, 255, 255),
    HasCheckbox = true,
    ToggleValue = false,
    Flag = "FOVCircleConfig",
    Save = true,
    ToggleCallback = function(state)
        ShowFOVCircle = state
        if FOVCircle then FOVCircle.Visible = state end
    end,
    Callback = function(color)
        if FOVCircle then
            local stroke = FOVCircle:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = color end
        end
    end
})
AimbotTab:AddSection({ Title = "Overlay Visuals" })
local CrosshairGroup = AimbotTab:AddGroupbox({ Title = "Custom Crosshair", Icon = "crosshair" })
CrosshairGroup:AddColorPicker({
    Title        = "Crosshair",
    Default      = Color3.fromRGB(0, 255, 0),
    HasCheckbox  = true,
    ToggleValue  = false,
    Flag         = "CrosshairConfig",
    Save         = true,
    ToggleCallback = function(state)
        getgenv().ShowCrosshair = state
        UpdateCrosshair()
    end,
    Callback = function(color)
        getgenv().CrosshairColor = color
        UpdateCrosshair()
    end
})
CrosshairGroup:AddDropdown({
    Title   = "Crosshair Style",
    Options = { "Cross", "Dot", "Circle" },
    Default = "Cross",
    Flag    = "CrosshairStyle",
    Save    = true,
    Callback = function(v)
        getgenv().CrosshairStyle = v
        UpdateCrosshair()
    end
})
CrosshairGroup:AddSlider({
    Title = "Crosshair Size",
    Min = 1, Max = 30, Default = 4, Step = 1,
    Flag = "CrosshairSize",
    Save = true,
    Callback = function(v)
        getgenv().CrosshairSize = tonumber(v) or 4
        UpdateCrosshair()
    end
})
local CrosshairPosGroup = AimbotTab:AddGroupbox({ Title = "Crosshair Position", Icon = "move" })
CrosshairPosGroup:AddInput({
    Title = "Posisi X",
    Default = "",
    Placeholder = "misal: 50",
    Flag = "CrosshairPosX",
    Save = true,
    Callback = function(v)
        getgenv().CrosshairOffsetX = tonumber(v) or 0
        UpdateCrosshair()
    end
})
CrosshairPosGroup:AddInput({
    Title = "Posisi Y",
    Default = "",
    Placeholder = "misal: 50",
    Flag = "CrosshairPosY",
    Save = true,
    Callback = function(v)
        getgenv().CrosshairOffsetY = tonumber(v) or 0
        UpdateCrosshair()
    end
})
MiscTab:AddSection({ Title = "Movement Enhancements" })
local MoonwalkGroup = MiscTab:AddGroupbox({ Title = "Moonwalk" })
local MobileMoonwalkGUI = nil
local function ToggleMobileMoonwalk(state)
    if not state then
        if MobileMoonwalkGUI then
            MobileMoonwalkGUI:Destroy()
            MobileMoonwalkGUI = nil
        end
        return
    end
    if MobileMoonwalkGUI then return end
    local coreGui = game:GetService("CoreGui")
    local mainGui = coreGui:FindFirstChild("VonixeLib_Vonixe Hub") or (gethui and gethui():FindFirstChild("VonixeLib_Vonixe Hub"))
    local gui = Instance.new("ScreenGui")
    gui.Name = "Vonixe_MobileMoonwalk"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = coreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = coreGui
    end
    local frame = Instance.new("Frame")
    frame.Name = "MobileFrame"
    frame.BackgroundColor3 = Color3.fromRGB(12, 10, 10)
    frame.BackgroundTransparency = 0.1
    frame.Position = UDim2.new(1, -170, 0.5, 0)
    frame.AnchorPoint = Vector2.new(1, 0.5)
    frame.Size = UDim2.new(0, 150, 0, 70)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 0)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 100, 0)
    title.Text = "Vonixe Moonwalk"
    title.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "Start Moonwalk"
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    local function syncState()
        if getgenv().MoonwalkEnabled then
            btn.Text = "Stop Moonwalk"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        else
            btn.Text = "Start Moonwalk"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
        end
    end
    btn.MouseButton1Click:Connect(function()
        local currentState = not getgenv().MoonwalkEnabled
        getgenv().MoonwalkEnabled = currentState
        if Window.Flags and Window.Flags["MoonwalkToggle"] and type(Window.Flags["MoonwalkToggle"].SetValue) == "function" then
            pcall(function() Window.Flags["MoonwalkToggle"]:SetValue(currentState) end)
        else
            if not currentState then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.AutoRotate = true
                end
            end
        end
        syncState()
    end)
    syncState()
    MobileMoonwalkGUI = gui
    task.spawn(function()
        while MobileMoonwalkGUI == gui and mainGui and mainGui.Parent do
            task.wait(1)
            if MobileMoonwalkGUI == gui then
                syncState()
            end
        end
        if MobileMoonwalkGUI == gui and (not mainGui or not mainGui.Parent) then
            gui:Destroy()
            MobileMoonwalkGUI = nil
        end
    end)
end
MoonwalkGroup:AddToggle({
    Title = "Enable Moonwalk",
    Value = false,
    HasKeybind = true,
    Keybind = Enum.KeyCode.Q,
    Flag = "MoonwalkToggle",
    Callback = function(state)
        getgenv().MoonwalkEnabled = state
        local char = game.Players.LocalPlayer.Character
        if state then
            if char and char:FindFirstChild("HumanoidRootPart") then
                local lv = char.HumanoidRootPart.CFrame.LookVector
                getgenv().CurrentMoonwalkYaw = math.deg(math.atan2(lv.X, lv.Z))
            end
        else
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.AutoRotate = true
            end
        end
    end
})
MoonwalkGroup:AddToggle({
    Title = "Enable Moonwalk for Mobile",
    Value = false,
    Callback = function(state)
        ToggleMobileMoonwalk(state)
    end
})
MoonwalkGroup:AddSlider({
    Title = "Zigzag Intensity",
    Min = 5,
    Max = 50,
    Default = 11,
    Rounding = 0,
    Callback = function(value)
        getgenv().MoonwalkZigzagSpeed = value
    end
})
MoonwalkGroup:AddSlider({
    Title = "Moonwalk Smoothness",
    Min = 1,
    Max = 100,
    Default = 5,
    Rounding = 0,
    Callback = function(value)
        getgenv().MoonwalkSmoothness = value / 100
    end
})
local PerformanceGroup = MiscTab:AddGroupbox({ Title = "Performance" })
PerformanceGroup:AddToggle({
    Title = "FPS Boost",
    Desc  = "Disable shadows, fog, post effects & particles.",
    Value = false,
    Callback = function(state)
        SetFPSBoost(state)
    end
})
PerformanceGroup:AddButton({
    Title = "Execute Potato Mode",
    Desc  = "Hapus semua tekstur dan efek",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/1Ar7LSp9/raw"))()
        end)
    end
})
MiscTab:AddSection({ Title = "Visuals" })
local VisualGroup = MiscTab:AddGroupbox({ Title = "Camera" })
VisualGroup:AddToggle({
    Title = "Custom FOV",
    Value = false,
    Callback = function(state)
        getgenv().CustomFOVEnabled = state
    end
})
VisualGroup:AddSlider({
    Title = "Field of View",
    Min = 10,
    Max = 120,
    Default = 70,
    Rounding = 0,
    Callback = function(value)
        getgenv().CustomFOV = value
    end
})
VisualGroup:AddToggle({
    Title = "Unlock Camera Zoom",
    Value = false,
    Callback = function(state)
        getgenv().UnlockZoomEnabled = state
        if not state then
            local p = game.Players.LocalPlayer
            if p then
                p.CameraMaxZoomDistance = 14
                p.CameraMinZoomDistance = 0.5
            end
        end
    end
})
local CurrentMoonwalkSway = 0
local LastAutoRevive = 0
-- GodMode → Heartbeat (bukan tiap frame)
local _godTimer = 0
RunService.Heartbeat:Connect(function()
    if not getgenv().VONIXE_VD_RUNNING or not getgenv().GodModeEnabled then return end
    local now = tick()
    if now - _godTimer < 0.15 then return end
    _godTimer = now
    local hum  = _LocalHum
    local char = _LocalChar
    if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
        hum.Health = hum.MaxHealth
    end
    if char and not char:GetAttribute("Parry") then
        char:SetAttribute("Parry", true)
    end
end)

-- Zoom Unlock → Heartbeat tiap 1 detik (bukan tiap frame)
local _zoomTimer = 0
RunService.Heartbeat:Connect(function()
    if not getgenv().UnlockZoomEnabled then return end
    local now = tick()
    if now - _zoomTimer < 1 then return end
    _zoomTimer = now
    LocalPlayer.CameraMaxZoomDistance = 120
    LocalPlayer.CameraMinZoomDistance = 0.5
end)

-- RenderStepped: HANYA Moonwalk + Aimbot camera lerp
if getgenv().VONIXE_VD_RENDER_CONN then
    getgenv().VONIXE_VD_RENDER_CONN:Disconnect()
end
getgenv().VONIXE_VD_RENDER_CONN = RunService.RenderStepped:Connect(function(deltaTime)
    if not getgenv().VONIXE_VD_RUNNING then return end

    -- Moonwalk (pakai cached refs, bukan FindFirstChild tiap frame)
    if getgenv().MoonwalkEnabled then
        local myHum  = _LocalHum
        local myRoot = _LocalRoot
        if myHum and myRoot and myHum.Health > 0 then
            if myHum.AutoRotate then myHum.AutoRotate = false end
            local moving = myHum.MoveDirection.Magnitude > 0.01
            if moving then
                local look = workspace.CurrentCamera.CFrame.LookVector
                local targetYaw = math.deg(math.atan2(look.X, look.Z)) + 180
                local diff = (targetYaw - (getgenv().CurrentMoonwalkYaw or 0) + 180) % 360 - 180
                local maxTurn = ((getgenv().MoonwalkSmoothness or 0.05) * 100)
                              * math.clamp(deltaTime * 60, 0, 3)
                getgenv().CurrentMoonwalkYaw = (getgenv().CurrentMoonwalkYaw or 0)
                                             + math.clamp(diff, -maxTurn, maxTurn)
            end
            local sway = moving
                and math.sin(tick() * (getgenv().MoonwalkZigzagSpeed or 11)) * 48
                or  0
            CurrentMoonwalkSway = (CurrentMoonwalkSway or 0)
                                + (sway - (CurrentMoonwalkSway or 0)) * 0.38
            myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.Angles(0, math.rad(
                (getgenv().CurrentMoonwalkYaw or 0) + CurrentMoonwalkSway
            ), 0)
        end
    end

    -- Aimbot camera lerp
    if Aimbot then
        local now = time()
        if now - lastRenderCheck > 0.5 then          -- was 0.25
            cachedIsCarrying = GetGameValue(_LocalChar, "Carrying")
                            or GetGameValue(_LocalChar, "IsCarried")
                            or false
            lastRenderCheck = now
        end
        if not cachedIsCarrying then
            if now - LastTargetCheck > 0.2 then      -- was 0.12
                CachedAimTarget = GetClosestAimTarget(CachedAimTarget)
                LastTargetCheck = now
            end
            if CachedAimTarget and (not CachedAimTarget.Parent
               or not CachedAimTarget:IsDescendantOf(workspace)) then
                CachedAimTarget = nil
            end
            local target = CachedAimTarget
            if target and target.Parent then
                local trigger = getgenv().AimbotTrigger or "Hold to Lock"
                local firing  = trigger == "Auto Lock (Always)"
                             or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                             or getgenv().MobileAimbotPressed
                if firing then
                    local smooth = math.clamp(
                        deltaTime * (tonumber(getgenv().AimbotSmoothness) or 8), 0.08, 0.28
                    )
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
                        CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Position),
                        smooth
                    )
                end
            end
        else
            CachedAimTarget = nil
        end
    end

    -- Custom FOV: hanya set kalau nilainya memang berbeda
    if getgenv().CustomFOVEnabled then
        local cam = workspace.CurrentCamera
        local fov = getgenv().CustomFOV or 70
        if cam and cam.FieldOfView ~= fov then cam.FieldOfView = fov end
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().VONIXE_VD_RUNNING then break end
        local char = _LocalChar
        if char then
            local speedOverride = getgenv().SkillCheckSpeedOverride
            if speedOverride then
                local current = char:GetAttribute("skillcheckspeed")
                if current ~= speedOverride then
                    char:SetAttribute("skillcheckspeed", speedOverride)
                end
            end
            local freqOverride = getgenv().SkillCheckFreqOverride
            if freqOverride then
                local current = char:GetAttribute("skillcheckfrequency")
                if current ~= freqOverride then
                    char:SetAttribute("skillcheckfrequency", freqOverride)
                end
            end
            local speedBoostEnabled = getgenv().SpeedBoostEnabled
            local speedBoostVal = getgenv().SpeedBoostOverride
            local currentBoost = char:GetAttribute("speedboost")
            if speedBoostEnabled and speedBoostVal then
                if currentBoost ~= speedBoostVal then
                    char:SetAttribute("speedboost", speedBoostVal)
                end
            else
                if currentBoost and currentBoost ~= 1 then
                    char:SetAttribute("speedboost", 1)
                end
            end
            local vaultSpeedEnabled = getgenv().VaultSpeedEnabled
            local vaultSpeedVal = getgenv().VaultSpeedOverride
            local currentVault = char:GetAttribute("vaultspeed")
            if vaultSpeedEnabled and vaultSpeedVal then
                if currentVault ~= vaultSpeedVal then
                    char:SetAttribute("vaultspeed", vaultSpeedVal)
                end
            else
                if currentVault and currentVault ~= 1 then
                    char:SetAttribute("vaultspeed", 1)
                end
            end
        end
    end
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    _CacheChar(char)
    task.wait(0.5)
    SetupParryRing()
    if ParryRing then
        ParryRing.Transparency = ShowParryRing and 0.3 or 1
    end
end)
Window:BuildSettingsTab()
local function InitWatermark()
    local coreGui = game:GetService("CoreGui")
    local runService = game:GetService("RunService")
    local stats = game:GetService("Stats")
    local frame = Instance.new("Frame")
    frame.Name = "WatermarkFrame"
    frame.BackgroundColor3 = Color3.fromRGB(12, 10, 10)
    frame.BackgroundTransparency = 0.1
    frame.Position = UDim2.new(0.5, 0, 0, 55)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Size = UDim2.new(0, 200, 0, 26)
    frame.Active = true
    frame.Draggable = true
    local mainGui = coreGui:FindFirstChild("VonixeLib_Vonixe Hub") or (gethui and gethui():FindFirstChild("VonixeLib_Vonixe Hub"))
    if mainGui then
        frame.Parent = mainGui
    else
        local gui = Instance.new("ScreenGui")
        gui.Name = "Vonixe_Watermark"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = coreGui
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = coreGui
        end
        frame.Parent = gui
    end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    local strokeGradient = Instance.new("UIGradient")
    strokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 160, 0))
    })
    strokeGradient.Parent = stroke
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextSize = 13
    textLabel.RichText = true
    textLabel.TextColor3 = Color3.fromRGB(255, 245, 235)
    textLabel.Text = '<b><font color="#FF6400">Vonixe</font></b> | 0 FPS | 0ms'
    textLabel.Parent = frame
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame
    textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        frame.Size = UDim2.new(0, textLabel.TextBounds.X + 24, 0, 26)
    end)
    local lastUpdate = tick()
    local frames = 0
    local conn
    conn = runService.RenderStepped:Connect(function()
        if not frame.Parent or (mainGui and not mainGui.Parent) then
            conn:Disconnect()
            if frame.Parent and frame.Parent.Name == "Vonixe_Watermark" then
                frame.Parent:Destroy()
            end
            return
        end
        frames = frames + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            local fps = math.floor(frames / (now - lastUpdate))
            frames = 0
            lastUpdate = now
            local ping = 0
            pcall(function()
                ping = math.round(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local fpsColor = fps >= 55 and "#55FF7F" or (fps >= 30 and "#FFFF55" or "#FF5555")
            local pingColor = ping <= 100 and "#55FF7F" or (ping <= 200 and "#FFFF55" or "#FF5555")
            textLabel.Text = string.format('<b><font color="#FF6400">Vonixe</font></b> | <font color="%s">%d FPS</font> | <font color="%s">%dms</font>', fpsColor, fps, pingColor, ping)
        end
    end)
end

task.spawn(InitWatermark)

local isHopping = false

local function ServerHop()
    if isHopping then return end
    isHopping = true
    
    task.spawn(function()
        task.wait(15)
        isHopping = false
    end)
    
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    local cursor = ""
    local foundServer = nil

    for i = 1, 5 do
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local success, result = pcall(function()
            if req then
                local response = req({Url = url, Method = "GET"})
                if response and response.Body then return HttpService:JSONDecode(response.Body) end
            else
                return HttpService:JSONDecode(game:HttpGet(url))
            end
        end)

        if success and type(result) == "table" and result.data then
            local available = {}
            for _, v in ipairs(result.data) do
                if type(v) == "table" and v.playing and v.maxPlayers and v.playing < v.maxPlayers - 2 and v.playing >= 5 and v.id ~= game.JobId then
                    table.insert(available, v.id)
                end
            end
            
            if #available > 0 then
                foundServer = available[math.random(1, #available)]
                break
            end
            
            if result.nextPageCursor then
                cursor = result.nextPageCursor
            else
                break
            end
        else
            break
        end
    end

    if foundServer then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, foundServer, LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

local function EscapeNow()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return end

    local finishlines = {}
    for _, desc in ipairs(mapFolder:GetDescendants()) do
        if desc.Name == "Fininshline" then
            table.insert(finishlines, desc)
        end
    end

    if #finishlines == 0 then return end

    local hrp = char.HumanoidRootPart
    for _, target in ipairs(finishlines) do
        local targetPart
        if target:IsA("BasePart") then
            targetPart = target
        elseif target:IsA("Model") then
            targetPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
        end

        if targetPart then
            if firetouchinterest then
                pcall(function()
                    firetouchinterest(hrp, targetPart, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, targetPart, 1)
                end)
            end
            pcall(function()
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
            end)
        end
        task.wait(0.1)
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().AutoFarmEnabled then
            local isSurvivor = (LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors")
            
            if isSurvivor then
                local mapFolder = workspace:FindFirstChild("Map")
                local hasLine = false
                if mapFolder then
                    for _, desc in ipairs(mapFolder:GetDescendants()) do
                        if desc.Name == "Fininshline" then
                            hasLine = true
                            break
                        end
                    end
                end
                
                if hasLine then
                      task.wait(15)
                      EscapeNow()
                      task.wait(2)
                      pcall(sendStatsWebhook)
                      task.wait(3)
                      ServerHop()
                      task.wait(5)
                end
            else
                local matchOngoing = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Team then
                        local tName = plr.Team.Name
                        if tName == "Survivors" or tName == "Killers" then
                            matchOngoing = true
                            break
                        end
                    end
                end
                
                if matchOngoing then
                    task.wait(5)
                    ServerHop()
                    task.wait(5)
                else
                    if #Players:GetPlayers() < 3 then
                        task.wait(5)
                        ServerHop()
                        task.wait(5)
                    end
                end
            end
        end
    end
end)