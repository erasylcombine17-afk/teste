local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0.5, -110, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true

local box = Instance.new("TextBox")
box.Parent = frame
box.Size = UDim2.new(0, 200, 0, 30)
box.Position = UDim2.new(0,10,0,10)
box.PlaceholderText = "Введите скорость..."
box.Text = ""

local button = Instance.new("TextButton")
button.Parent = frame
button.Size = UDim2.new(0,200,0,30)
button.Position = UDim2.new(0,10,0,50)
button.Text = "Set Speed"

button.MouseButton1Click:Connect(function()
    local speed = tonumber(box.Text)
    if speed then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end)
