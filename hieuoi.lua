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
   Range = {50,200},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v)
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.JumpPower = v end
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
-- FLY
-------------------------------------------------
local flying = false
local flySpeed = 60

Main:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v)
      flying = v
   end,
})

Main:CreateSlider({
   Name = "Fly Speed",
   Range = {20,300},
   Increment = 5,
   CurrentValue = 60,
   Callback = function(v)
      flySpeed = v
   end
})

RunService.RenderStepped:Connect(function()
    if flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local move = Vector3.new()

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        hrp.Velocity = move * flySpeed
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
