local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local enabled = false
local cooldown = false
local kickDistance = 8
local kickPower = 150

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 100, 0, 100)
button.Position = UDim2.new(0, 20, 0.5, -50)
button.Text = "KICK OFF"
button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
button.TextScaled = true

button.MouseButton1Click:Connect(function()
    enabled = not enabled

    if enabled then
        button.Text = "KICK ON"
        button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        button.Text = "KICK OFF"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

local function kickPlayers()
    if cooldown then return end
    cooldown = true

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        cooldown = false
        return
    end

    local myRoot = myChar.HumanoidRootPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (targetRoot.Position - myRoot.Position).Magnitude

            if dist <= kickDistance then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                bv.Velocity = (targetRoot.Position - myRoot.Position).Unit * kickPower + Vector3.new(0,50,0)
                bv.Parent = targetRoot

                game.Debris:AddItem(bv, 0.2)
            end
        end
    end

    task.wait(1) -- кулдаун 1 секунда
    cooldown = false
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if enabled and input.KeyCode == Enum.KeyCode.F then
        kickPlayers()
    end
end)
