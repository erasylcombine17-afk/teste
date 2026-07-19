local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===== СОЗДАЁМ СОБЫТИЕ =====
local SpeedEvent = Instance.new("RemoteEvent")
SpeedEvent.Name = "SpeedEvent"
SpeedEvent.Parent = ReplicatedStorage

local mouse = player:GetMouse()
local isSpeedMode = false
local speedMultiplier = 3 -- Множитель скорости (можно менять)

-- ===== КВАДРАТНАЯ КНОПКА-ПЕРЕКЛЮЧАТЕЛЬ =====
local function createToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Квадратная кнопка
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0.9, -40, 0.05, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 3
    button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    button.Text = ""
    button.Parent = screenGui
    
    -- Иконка
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0.6, 0)
    icon.Position = UDim2.new(0, 0, 0.05, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🏃"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.TextScaled = true
    icon.Font = Enum.Font.Bold
    icon.Parent = button
    
    -- Текст состояния
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0.3, 0)
    statusText.Position = UDim2.new(0, 0, 0.7, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.Bold
    statusText.Parent = button
    
    -- ПЕРЕКЛЮЧЕНИЕ
    button.MouseButton1Click:Connect(function()
        isSpeedMode = not isSpeedMode
        
        if isSpeedMode then
            -- ВКЛ
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            button.BackgroundTransparency = 0.2
            button.BorderColor3 = Color3.fromRGB(0, 200, 255)
            statusText.Text = "ON " .. speedMultiplier .. "x"
            statusText.TextColor3 = Color3.fromRGB(0, 200, 255)
            icon.Text = "⚡"
            
            -- Включаем скорость
            setSpeed(speedMultiplier)
            showNotification("🔵 СКОРОСТЬ ВКЛЮЧЕНА! x" .. speedMultiplier)
        else
            -- ВЫКЛ
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            button.BackgroundTransparency = 0.1
            button.BorderColor3 = Color3.fromRGB(100, 100, 100)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
            icon.Text = "🏃"
            
            -- Выключаем скорость
            setSpeed(1)
            showNotification("🔴 Скорость выключена")
        end
    end)
    
    return button
end

-- ===== ФУНКЦИЯ ИЗМЕНЕНИЯ СКОРОСТИ =====
local function setSpeed(multiplier)
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Базовая скорость пешком
    humanoid.WalkSpeed = 16 * multiplier
    
    -- Базовая скорость бега (если есть)
    if humanoid:FindFirstChild("RunSpeed") then
        humanoid.RunSpeed = 16 * multiplier
    end
    
    -- Увеличиваем скорость прыжка (опционально)
    if multiplier > 1 then
        humanoid.JumpPower = 60 + (multiplier * 5)
    else
        humanoid.JumpPower = 50
    end
end

-- ===== ОБНОВЛЕНИЕ ПРИ ПОЯВЛЕНИИ ПЕРСОНАЖА =====
player.CharacterAdded:Connect(function(character)
    task.wait(0.5) -- Ждём загрузки
    local humanoid = character:WaitForChild("Humanoid")
    
    if isSpeedMode then
        setSpeed(speedMultiplier)
    else
        setSpeed(1)
    end
end)

-- ===== РЕГУЛИРОВКА КНОПКАМИ (опционально) =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Кнопка [ = увеличить скорость
    if input.KeyCode == Enum.KeyCode.LeftBracket then
        if not isSpeedMode then
            showNotification("❌ Сначала включи режим скорости!")
            return
        end
        
        speedMultiplier = math.min(speedMultiplier + 0.5, 10) -- Максимум x10
        setSpeed(speedMultiplier)
        updateButtonText()
        showNotification("⚡ Скорость: x" .. speedMultiplier)
    end
    
    -- Кнопка ] = уменьшить скорость
    if input.KeyCode == Enum.KeyCode.RightBracket then
        if not isSpeedMode then
            showNotification("❌ Сначала включи режим скорости!")
            return
        end
        
        speedMultiplier = math.max(speedMultiplier - 0.5, 1) -- Минимум x1
        setSpeed(speedMultiplier)
        updateButtonText()
        showNotification("⚡ Скорость: x" .. speedMultiplier)
    end
end)

-- ===== ОБНОВЛЕНИЕ ТЕКСТА КНОПКИ =====
function updateButtonText()
    local gui = player:WaitForChild("PlayerGui"):FindFirstChild("SpeedUI")
    if not gui then return end
    
    local button = gui:FindFirstChildOfClass("TextButton")
    if not button then return end
    
    local statusText = button:FindFirstChildOfClass("TextLabel")
    if statusText and isSpeedMode then
        statusText.Text = "ON " .. speedMultiplier .. "x"
    end
end

-- ===== УВЕДОМЛЕНИЯ =====
local function showNotification(text)
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 50)
    frame.Position = UDim2.new(0.5, -225, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Bold
    label.Parent = frame
    
    task.wait(2.5)
    gui:Destroy()
end

-- ===== ЗАПУСК =====
createToggleButton()

-- Устанавливаем стандартную скорость при старте
task.wait(1)
setSpeed(1)
