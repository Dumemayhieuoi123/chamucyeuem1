local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "HieuOi Hub",
   LoadingTitle = "HieuOi Hub",
   LoadingSubtitle = "Get the job done",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local Main = Window:CreateTab("Main", 4483362458)
local Aimbot = Window:CreateTab("Aimbot", 4483362458)
local Combat = Window:CreateTab("Combat (beta)", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-------------------------------------------------
-- WALK SPEED
-------------------------------------------------
Main:CreateSlider({
   Name = "WalkSpeed",
   Range = {16,200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.WalkSpeed = v end
   end
})

-------------------------------------------------
-- JUMP POWER 
-------------------------------------------------
Main:CreateSlider({
   Name = "JumpPower",
   Range = {50,500},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v)
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.UseJumpPower = true
         hum.JumpPower = v
      end
   end
})

-------------------------------------------------
-- NOCLIP
-------------------------------------------------
local noclip = false

Main:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v)
      noclip = v
   end,
})

RunService.Stepped:Connect(function()
   if noclip and LocalPlayer.Character then
      for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
         if v:IsA("BasePart") then
            v.CanCollide = false
         end
      end
   end
end)

-------------------------------------------------
-- FLY SYSTEM (2 MODE)
-------------------------------------------------

local flying = false
local flySpeed = 60
local flyMode = "Velocity"

Main:CreateDropdown({
    Name = "Fly Mode",
    Options = {"Velocity","TP Walking"},
    CurrentOption = "Velocity",
    Callback = function(v)
        flyMode = v
    end
})

Main:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v)
      flying = v
   end,
})

Main:CreateSlider({
   Name = "Fly Speed",
   Range = {1,500},
   Increment = 5,
   CurrentValue = 60,
   Callback = function(v)
      flySpeed = v
   end
})

-------------------------------------------------
-- VELOCITY FLY
-------------------------------------------------

RunService.RenderStepped:Connect(function()

    if not flying then return end
    if flyMode ~= "Velocity" then return end
    if not LocalPlayer.Character then return end

    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local move = Vector3.new()

    if UIS:IsKeyDown(Enum.KeyCode.W) then
        move += Camera.CFrame.LookVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.S) then
        move -= Camera.CFrame.LookVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.A) then
        move -= Camera.CFrame.RightVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.D) then
        move += Camera.CFrame.RightVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.Space) then
        move += Vector3.new(0,1,0)
    end

    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        move -= Vector3.new(0,1,0)
    end

    hrp.Velocity = move * flySpeed

end)

-------------------------------------------------
-- TP WALKING FLY (FIXED)
-------------------------------------------------

local tpFly = false

RunService.Heartbeat:Connect(function()

    if not flying then 
        tpFly = false
        return 
    end

    if flyMode ~= "TP Walking" then 
        tpFly = false
        return 
    end

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return end

    -- bật fly
    if not tpFly then
        tpFly = true
        hum.PlatformStand = true
    end

    local move = Vector3.new()

    if UIS:IsKeyDown(Enum.KeyCode.W) then
        move += Camera.CFrame.LookVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.S) then
        move -= Camera.CFrame.LookVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.A) then
        move -= Camera.CFrame.RightVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.D) then
        move += Camera.CFrame.RightVector
    end

    if UIS:IsKeyDown(Enum.KeyCode.Space) then
        move += Vector3.new(0,1,0)
    end

    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        move -= Vector3.new(0,1,0)
    end

    root.CFrame = root.CFrame + (move * (flySpeed/25))

end)

-- tắt fly trả lại bình thường
RunService.RenderStepped:Connect(function()
    if not flying and tpFly then
        tpFly = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end
end)

---------------------------------------------------
-- FLING SYSTEM
---------------------------------------------------

local selectedTargets = {}
local flingActive = false
local FPDH = workspace.FallenPartsDestroyHeight

local function CharMucFling(TargetPlayer)

    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not RootPart then return end

    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local TRoot = TCharacter:FindFirstChild("HumanoidRootPart")
    if not TRoot then return end

    local oldPos = RootPart.CFrame

    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)

    for i = 1,20 do
        if not flingActive then break end

        RootPart.CFrame = TRoot.CFrame * CFrame.new(0,1,0)

        RootPart.Velocity = Vector3.new(
            math.random(-999999,999999),
            math.random(999999,9999999),
            math.random(-999999,999999)
        )

        RootPart.RotVelocity = Vector3.new(999999,999999,999999)

        task.wait()
    end

    BV:Destroy()

    RootPart.CFrame = oldPos
    workspace.FallenPartsDestroyHeight = FPDH

end

---------------------------------------------------
-- START FLING
---------------------------------------------------

local function StartFling()

    flingActive = true

    task.spawn(function()
        while flingActive do

            for _,plr in pairs(selectedTargets) do
                if flingActive and plr then
                    CharMucFling(plr)
                    task.wait(0.2)
                end
            end

            task.wait(0.1)
        end
    end)

end

---------------------------------------------------
-- STOP FLING
---------------------------------------------------

local function StopFling()
    flingActive = false
end

---------------------------------------------------
-- PLAYER DROPDOWN
---------------------------------------------------

local dropdown = Combat:CreateDropdown({
    Name = "Select Players To Fling",
    Options = {},
    MultipleOptions = true,
    CurrentOption = {},
    Callback = function(options)

        selectedTargets = {}

        for _,name in pairs(options) do
            local plr = Players:FindFirstChild(name)
            if plr then
                table.insert(selectedTargets, plr)
            end
        end

    end,
})

---------------------------------------------------
-- FLING TOGGLE
---------------------------------------------------

Combat:CreateToggle({
    Name = "Safe Fling Loop",
    CurrentValue = false,
    Callback = function(v)

        if v then
            StartFling()
        else
            StopFling()
        end

    end,
})

---------------------------------------------------
-- REFRESH PLAYER LIST
---------------------------------------------------

local function RefreshPlayers()

    local list = {}

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end

    dropdown:Refresh(list)

end

RefreshPlayers()

Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)
-------------------------------------------------
-- AIMBOT SYSTEM
-------------------------------------------------

local aimbotEnabled = false
local silentAim = false
local multiTarget = false
local aimFov = 200
local targetPlayers = {}

-- FOV CIRCLE
local circle = Drawing.new("Circle")
circle.Visible = false
circle.Radius = aimFov
circle.Thickness = 2
circle.Color = Color3.fromRGB(255,255,255)
circle.Filled = false
circle.NumSides = 100

RunService.RenderStepped:Connect(function()
    circle.Position = UIS:GetMouseLocation()
    circle.Radius = aimFov
    circle.Visible = aimbotEnabled
end)

-------------------------------------------------
-- PLAYER DROPDOWN
-------------------------------------------------

local aimDropdown = Aimbot:CreateDropdown({
    Name = "Select Target",
    Options = {},
    MultipleOptions = true,
    CurrentOption = {},
    Callback = function(options)

        targetPlayers = {}

        for _,name in pairs(options) do
            local plr = Players:FindFirstChild(name)
            if plr then
                table.insert(targetPlayers, plr)
            end
        end

    end,
})

-------------------------------------------------
-- ENABLE AIMBOT
-------------------------------------------------

Aimbot:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(v)
        aimbotEnabled = v
    end
})

-------------------------------------------------
-- MULTI TARGET
-------------------------------------------------

Aimbot:CreateToggle({
    Name = "Multi Target",
    CurrentValue = false,
    Callback = function(v)
        multiTarget = v
    end
})

-------------------------------------------------
-- SILENT AIM
-------------------------------------------------

Aimbot:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(v)
        silentAim = v
    end
})

-------------------------------------------------
-- FOV SIZE
-------------------------------------------------

Aimbot:CreateSlider({
    Name = "FOV Size",
    Range = {50,500},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(v)
        aimFov = v
    end
})

-------------------------------------------------
-- GET CLOSEST TARGET
-------------------------------------------------

local function getClosest()

    local closest = nil
    local shortest = aimFov

    for _,plr in pairs(targetPlayers) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then

            local pos, visible = Camera:WorldToViewportPoint(plr.Character.Head.Position)

            if visible then
                local dist = (Vector2.new(pos.X,pos.Y) - UIS:GetMouseLocation()).Magnitude

                if dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end

    return closest
end

-------------------------------------------------
-- AIMBOT LOOP
-------------------------------------------------

RunService.RenderStepped:Connect(function()

    if not aimbotEnabled then return end

    local target = getClosest()

    if target and target.Character and target.Character:FindFirstChild("Head") then

        local pos = target.Character.Head.Position

        Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)

    end

end)

-------------------------------------------------
-- REFRESH PLAYER LIST
-------------------------------------------------

local function refreshAimPlayers()

    local list = {}

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end

    aimDropdown:Refresh(list)

end

refreshAimPlayers()
Players.PlayerAdded:Connect(refreshAimPlayers)
Players.PlayerRemoving:Connect(refreshAimPlayers)
-------------------------------------------------
-- FIXED ESP SYSTEM (ON/OFF CLEAN)
-------------------------------------------------

local espEnabled = false
local ESP = {}

local function removeESP(player)
    if ESP[player] then
        if ESP[player].Highlight then ESP[player].Highlight:Destroy() end
        if ESP[player].Name then ESP[player].Name:Destroy() end
        ESP[player] = nil
    end
end

local function applyESP(player, character)
    if not espEnabled then return end
    if player == LocalPlayer then return end
    if not character then return end

    removeESP(player)

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(0,255,120)
    hl.OutlineColor = Color3.fromRGB(0,200,100)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = character
    hl.Parent = game.CoreGui

    local head = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0,200,0,40)
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0,3,0)
    bill.Adornee = head
    bill.Parent = game.CoreGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = player.DisplayName.." ("..player.Name..")"
    text.TextColor3 = Color3.fromRGB(0,255,120)
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Parent = bill

    ESP[player] = {
        Highlight = hl,
        Name = bill
    }
end

local function setupPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        applyESP(player, char)
    end)

    if player.Character then
        applyESP(player, player.Character)
    end
end

for _,plr in pairs(Players:GetPlayers()) do
    setupPlayer(plr)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-------------------------------------------------
-- ADVANCED ESP (ANTI INVISIBLE + MORPH + FAR)
-------------------------------------------------

local espEnabled = false
local ESP = {}

local function createESP(player)

    if player == LocalPlayer then return end

    local function apply(character)

        if ESP[player] then
            ESP[player].Highlight:Destroy()
            ESP[player].Name:Destroy()
        end

        -------------------------
        -- HIGHLIGHT
        -------------------------

        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(0,255,120)
        hl.OutlineColor = Color3.fromRGB(0,200,100)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = character
        hl.Enabled = espEnabled
        hl.Parent = game.CoreGui

        -------------------------
        -- NAME TAG
        -------------------------

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0,200,0,40)
        bill.AlwaysOnTop = true
        bill.StudsOffset = Vector3.new(0,3,0)
        bill.Adornee = character:FindFirstChild("Head") 
                    or character:FindFirstChildWhichIsA("BasePart")
        bill.Parent = game.CoreGui

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = player.DisplayName.." ("..player.Name..")"
        text.TextColor3 = Color3.fromRGB(0,255,120)
        text.TextStrokeTransparency = 0
        text.TextScaled = true
        text.Font = Enum.Font.SourceSansBold
        text.Parent = bill

        ESP[player] = {
            Highlight = hl,
            Name = bill
        }

    end

    if player.Character then
        apply(player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        apply(char)
    end)

end

for _,plr in pairs(Players:GetPlayers()) do
    createESP(plr)
end

Players.PlayerAdded:Connect(createESP)

Players.PlayerRemoving:Connect(function(plr)
    if ESP[plr] then
        ESP[plr].Highlight:Destroy()
        ESP[plr].Name:Destroy()
        ESP[plr] = nil
    end
end)

-------------------------------------------------
-- TOGGLE
-------------------------------------------------

Main:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Callback = function(v)

        espEnabled = v

        if not v then
            -- TẮT: xoá toàn bộ ESP
            for _,plr in pairs(Players:GetPlayers()) do
                removeESP(plr)
            end
        else
            -- BẬT: tạo lại ESP
            for _,plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    applyESP(plr, plr.Character)
                end
            end
        end

    end
})

-------------------------------------------------
-- Night to Light
-------------------------------------------------
local Lighting = game:GetService("Lighting")

local lightingBackup = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ExposureCompensation = Lighting.ExposureCompensation
}
local function EnableBright()
	Lighting.Brightness = 3
	Lighting.ClockTime = 14 -- ban ngày
	Lighting.FogStart = 0
	Lighting.FogEnd = 100000
	Lighting.Ambient = Color3.fromRGB(255,255,255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	Lighting.ExposureCompensation = 0.3
end
local function DisableBright()
	for k, v in pairs(lightingBackup) do
		Lighting[k] = v
	end
end
local brightEnabled = false

Main:CreateToggle({
	Name = "Bright Mode (nhin trong bong toi)",
	CurrentValue = false,
	Callback = function(v)
		brightEnabled = v

		if v then
			EnableBright()
		else
			DisableBright()
		end
	end
})
