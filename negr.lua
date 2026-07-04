local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local DropkickEvent = ReplicatedStorage:FindFirstChild("DropkickEvent")
local isDropkickMode = false
local buttonGui = nil

-- СОЗДАЁМ КНОПКУ
local function createToggleButton()
    -- Главный ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DropkickButton"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Сама квадратная кнопка
    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, 70, 0, 70) -- Квадратная
    button.Position = UDim2.new(0.9, -35, 0.1, 0) -- В правом верхнем углу
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 3
    button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    button.Parent = screenGui
    
    -- Иконка (для красоты)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🦵"
    icon.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    icon.TextScaled = true
    icon.Font = Enum.Font.Bold
    icon.Parent = button
    
    -- Текст состояния
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 1, 5)
    statusText.BackgroundTransparency = 1
    statusText.Text = "ВЫКЛ"
    statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.Bold
    statusText.Parent = button
    
    -- Обработка нажатия (переключение)
    button.MouseButton1Click:Connect(function()
        isDropkickMode = not isDropkickMode
        
        if isDropkickMode then
            -- ВКЛЮЧЕНО
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            button.BorderColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "ВКЛ"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            icon.Text = "✅"
            
            -- Подсветка игроков (включаем)
            highlightPlayers(true)
            
            -- Уведомление
            showNotification("🔴 РЕЖИМ DROPKICK ВКЛЮЧЁН! Кликай на игроков.")
        else
            -- ВЫКЛЮЧЕНО
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            button.BorderColor3 = Color3.fromRGB(100, 100, 100)
            statusText.Text = "ВЫКЛ"
            statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            icon.Text = "🦵"
            
            -- Убираем подсветку
            highlightPlayers(false)
            
            showNotification("🟢 Режим выключен")
        end
    end)
    
    buttonGui = screenGui
    return button
end

-- ПОДСВЕТКА ИГРОКОВ (чтобы видеть по кому кликать)
local function highlightPlayers(enabled)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local highlight = char:FindFirstChild("DropkickHighlight")
                if enabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "DropkickHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
                        highlight.OutlineTransparency = 0.3
                        highlight.Parent = char
                    end
                else
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end

-- УВЕДОМЛЕНИЯ
local function showNotification(text)
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 400, 0, 50)
    label.Position = UDim2.new(0.5, -200, 0.8, 0)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.BackgroundTransparency = 0.6
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Bold
    label.Parent = gui
    
    task.wait(2)
    gui:Destroy()
end

-- КЛИК ПО ИГРОКАМ (когда режим включён)
local function onClickPlayer()
    local mouse = player:GetMouse()
    
    mouse.Button1Down:Connect(function()
        if not isDropkickMode then return end
        
        local target = mouse.Target
        if not target then return end
        
        local character = target.Parent
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local targetPlayer = Players:GetPlayerFromCharacter(character)
        if not targetPlayer or targetPlayer == player then return end
        
        -- Отправляем запрос на дропкик
        DropkickEvent:FireServer(targetPlayer.Name)
        showNotification("🦵 Вышвыриваем " .. targetPlayer.Name .. "!")
    end)
end

-- ЗАПУСК
createToggleButton()
onClickPlayer()

-- ОБНОВЛЕНИЕ ПОДСВЕТКИ ПРИ ПОЯВЛЕНИИ ИГРОКОВ
Players.PlayerAdded:Connect(function(newPlayer)
    if isDropkickMode then
        task.wait(0.5)
        highlightPlayers(true)
    end
end)
