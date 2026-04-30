print("HieuOi Checking...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "HieuOi Hub (Beta)",
   LoadingTitle = "HieuOi Hub (Beta)",
   LoadingSubtitle = "Get the job done",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local Main = Window:CreateTab("Main", 4483362458)
local Aimbot = Window:CreateTab("Aimlock", 4483362458)
local Combat = Window:CreateTab("Combat", 4483362458)

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
   Range = {16,500},
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
-- FLY SYSTEM (2 BUTTON - NO CONFLICT)
-------------------------------------------------

local adminFly = false
local velocityFly = false
local flySpeed = 80

local BV, BG

local function isTyping()
    return UIS:GetFocusedTextBox() ~= nil
end

local function stopAllFly()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum then
        hum.PlatformStand = false
    end

    if BV then BV:Destroy() BV = nil end
    if BG then BG:Destroy() BG = nil end

    if root then
        root.Velocity = Vector3.new()
    end

    adminFly = false
    velocityFly = false
end

-------------------------------------------------
-- SPEED
-------------------------------------------------

Main:CreateSlider({
   Name = "Fly Speed",
   Range = {10,300},
   Increment = 5,
   CurrentValue = 80,
   Callback = function(v)
      flySpeed = v
   end
})

-------------------------------------------------
-- ADMIN FLY
-------------------------------------------------

Main:CreateToggle({
   Name = "Normal Fly",
   CurrentValue = false,
   Callback = function(v)

      stopAllFly()

      adminFly = v
      if not v then return end

      local char = LocalPlayer.Character
      if not char then return end

      local hum = char:FindFirstChildOfClass("Humanoid")
      local root = char:FindFirstChild("HumanoidRootPart")
      if not hum or not root then return end

      hum.PlatformStand = true

      BV = Instance.new("BodyVelocity")
      BV.MaxForce = Vector3.new(9e9,9e9,9e9)
      BV.Velocity = Vector3.new()
      BV.Parent = root

      BG = Instance.new("BodyGyro")
      BG.MaxTorque = Vector3.new(9e9,9e9,9e9)
      BG.P = 9e4
      BG.CFrame = root.CFrame
      BG.Parent = root

   end
})

-------------------------------------------------
-- VELOCITY FLY
-------------------------------------------------

Main:CreateToggle({
   Name = "Velocity Fly",
   CurrentValue = false,
   Callback = function(v)

      stopAllFly()

      velocityFly = v
      if not v then return end

   end
})

-------------------------------------------------
-- LOOP
-------------------------------------------------

RunService.RenderStepped:Connect(function()

    if isTyping() then return end

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local move = Vector3.new()

    if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

    ---------------------------------
    --normal FLY
    ---------------------------------
    if adminFly and BV and BG then
        BV.Velocity = move * flySpeed
        BG.CFrame = Camera.CFrame
    end

    ---------------------------------
    -- VELOCITY FLY
    ---------------------------------
    if velocityFly then
        root.Velocity = move * flySpeed
    end

end)

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
-- FLING (COMBAT)
-------------------------------------------------
Combat:CreateButton({
    Name = "ChaMuc Fling GUI (Click)",
    Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Dumemayhieuoi123/chamucyeuem/refs/heads/main/fling"))()
    end
})

-------------------------------------------------
-- AIMLOCK
-------------------------------------------------
local aimEnabled = false
local aimFov = 200
local targetPlayers = {}

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Thickness = 2
circle.Color = Color3.fromRGB(0,255,120)
circle.Filled = false

RunService.RenderStepped:Connect(function()
    circle.Position = UIS:GetMouseLocation()
    circle.Radius = aimFov
    circle.Visible = aimEnabled
end)

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

Aimbot:CreateToggle({
    Name = "Aimlock",
    CurrentValue = false,
    Callback = function(v)
        aimEnabled = v
    end
})

Aimbot:CreateSlider({
    Name = "FOV",
    Range = {50,500},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(v)
        aimFov = v
    end
})

local function getClosest()

    local closest = nil
    local shortest = aimFov

    for _,plr in pairs(targetPlayers) do
        if plr.Character and plr.Character:FindFirstChild("Head") then

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

RunService.RenderStepped:Connect(function()

    if not aimEnabled then return end

    local target = getClosest()

    if target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position,target.Character.Head.Position)
    end

end)

local function refreshAim()

    local list = {}

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end

    aimDropdown:Refresh(list)

end

refreshAim()
Players.PlayerAdded:Connect(refreshAim)
Players.PlayerRemoving:Connect(refreshAim)

-------------------------------------------------
-- ESP
-------------------------------------------------

local espEnabled = false
local ESP = {}

local function removeESP(player)
    if ESP[player] then
        if ESP[player].Highlight then
            ESP[player].Highlight:Destroy()
        end
        if ESP[player].Billboard then
            ESP[player].Billboard:Destroy()
        end
        ESP[player] = nil
    end
end

local function createESP(player)

    if not espEnabled then return end
    if player == LocalPlayer then return end

    local char = player.Character
    if not char then return end

    removeESP(player)

    local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(0,255,120)
    hl.OutlineColor = Color3.fromRGB(0,200,100)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = game.CoreGui

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
        Billboard = bill
    }

end

local function setupPlayer(player)

    if player == LocalPlayer then return end

    -- khi respawn
    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        if espEnabled then
            createESP(player)
        end
    end)

    -- nếu đã spawn sẵn
    if player.Character then
        task.wait(0.3)
        createESP(player)
    end

end

-- player hiện tại
for _,plr in pairs(Players:GetPlayers()) do
    setupPlayer(plr)
end

-- player mới
Players.PlayerAdded:Connect(setupPlayer)

-- player rời
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-------------------------------------------------
-- TOGGLE
-------------------------------------------------

Main:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Callback = function(v)

        espEnabled = v

        if v then
            for _,plr in pairs(Players:GetPlayers()) do
                createESP(plr)
            end
        else
            for _,plr in pairs(Players:GetPlayers()) do
                removeESP(plr)
            end
        end

    end
})

-------------------------------------------------
-- BRIGHT MODE
-------------------------------------------------
local Lighting = game:GetService("Lighting")
local backup = {}

local function enableBright()
    backup = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        Ambient = Lighting.Ambient
    }

    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.Ambient = Color3.new(1,1,1)
end

local function disableBright()
    for k,v in pairs(backup) do
        Lighting[k] = v
    end
end

Main:CreateToggle({
    Name = "Bright Mode",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enableBright()
        else
            disableBright()
        end
    end
})
