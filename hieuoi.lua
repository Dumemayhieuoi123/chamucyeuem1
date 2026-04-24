local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "HieuOi Hub",
   LoadingTitle = "HieuOi Hub",
   LoadingSubtitle = "Get the job done",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)
local Combat = Window:CreateTab("Combat(Beta)", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-------------------------------------------------
-- WALK SPEED
-------------------------------------------------
Tab:CreateSlider({
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
Tab:CreateSlider({
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
Tab:CreateToggle({
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

Tab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v)
      flying = v
   end,
})

Tab:CreateSlider({
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

-------------------------------------------------
-- AIMLOCK
-------------------------------------------------
local aimlock = false

Tab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = false,
    Callback = function(v)
        aimlock = v
    end
})

RunService.RenderStepped:Connect(function()
    if not aimlock then return end

    local closest = nil
    local shortest = math.huge

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
        and plr.Character
        and plr.Character:FindFirstChild("Head")
        and plr.Character:FindFirstChild("Humanoid")
        and plr.Character.Humanoid.Health > 0 then

            local pos, visible = Camera:WorldToViewportPoint(
                plr.Character.Head.Position
            )

            if visible then
                local center = Vector2.new(
                    Camera.ViewportSize.X/2,
                    Camera.ViewportSize.Y/2
                )

                local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude

                if dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end

    if closest and closest.Character then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position),
            0.2
        )
    end
end)

-------------------------------------------------
-- CHẢ MỰC FLING (BASED ON K1LAS1K)
-------------------------------------------------
local selectedPlayers = {}
local playerMap = {}
local flingLoop = false
local lastPos = nil

local function CharMucFling(targetPlayer)
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end

    local TCharacter = targetPlayer.Character
    if not TCharacter then return end

    local TRootPart = TCharacter:FindFirstChild("HumanoidRootPart")
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    if not TRootPart or not THumanoid then return end

    if not lastPos then
        lastPos = RootPart.CFrame
    end

    Humanoid.PlatformStand = true

    local BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)
    BV.Velocity = Vector3.new(0,0,0)
    BV.Parent = RootPart

    local start = tick()
    local angle = 0

    repeat
        angle += 100

        RootPart.CFrame =
            TRootPart.CFrame *
            CFrame.new(0,1.5,0) *
            CFrame.Angles(math.rad(angle),0,0)

        RootPart.Velocity = Vector3.new(9e7,9e7,9e7)
        RootPart.RotVelocity = Vector3.new(9e8,9e8,9e8)

        RunService.Heartbeat:Wait()

    until tick() - start > 2.5 or not flingLoop

    BV:Destroy()
    Humanoid.PlatformStand = false
end

-------------------------------------------------
-- SELECT PLAYER
-------------------------------------------------
local dropdown = Combat:CreateDropdown({
   Name = "Select Players To Fling",
   Options = {},
   MultipleOptions = true,
   Callback = function(opt)
        selectedPlayers = {}
        for _,name in pairs(opt) do
            local plr = Players:FindFirstChild(name)
            if plr then
                table.insert(selectedPlayers, plr)
            end
        end
   end,
})

local function refreshPlayers()
    local list = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end

    dropdown:Refresh(list)
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-------------------------------------------------
-- FLING LOOP
-------------------------------------------------
local function startFling()
    flingLoop = true

    task.spawn(function()
        while flingLoop do
            for _,plr in pairs(selectedPlayers) do
                if not flingLoop then break end
                CharMucFling(plr)
            end

            for i=1,10 do
                if not flingLoop then break end
                task.wait(0.1)
            end
        end
    end)
end

local function stopFling()
    flingLoop = false

    if lastPos and LocalPlayer.Character then
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = lastPos
    end

    lastPos = nil
end

Combat:CreateToggle({
    Name = "Safe Fling Loop",
    CurrentValue = false,
    Callback = function(v)
        if v then
            startFling()
        else
            stopFling()
        end
    end
})
