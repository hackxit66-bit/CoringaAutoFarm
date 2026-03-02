local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

getgenv().TreasureAutoFarm = {
    Enabled = false,
    Teleport = 2,
    TimeBetweenRuns = 5
}

local farmAtivo = false
local ouroTotal = 0
local faseAtual = 1
local runAtual = 1
local menuMinimizado = false
local tamanhoOriginal = UDim2.new(0, 500, 0, 250)
local tamanhoMinimizado = UDim2.new(0, 200, 0, 40)

function getRoot()
    local character = player.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function autoFarm(currentRun)
    local Character = player.Character
    if not Character then 
        player.CharacterAdded:Wait()
        Character = player.Character
    end
    
    -- Verifica se a estrutura do jogo existe
    local BoatStages = Workspace:FindFirstChild("BoatStages")
    if not BoatStages then 
        wait(2)
        return
    end
    
    local NormalStages = BoatStages:FindFirstChild("NormalStages")
    if not NormalStages then 
        wait(2)
        return
    end

    -- Passa por todas as 10 fases
    for i = 1, 10 do
        if not farmAtivo then break end
        
        local Stage = NormalStages:FindFirstChild("CaveStage" .. i)
        if Stage then
            local DarknessPart = Stage:FindFirstChild("DarknessPart")
            
            if DarknessPart then
                -- Teleport para a próxima fase
                Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
                
                -- Truque da parte temporária (original do GitHub)
                local Part = Instance.new("Part")
                Part.Anchored = true
                Part.Position = Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)
                Part.Parent = Character
                
                wait(getgenv().TreasureAutoFarm.Teleport)
                Part:Destroy()
                
                faseAtual = i
                atualizarUI()
            end
        end
    end

    -- Vai para o baú final
    if farmAtivo then
        local TheEnd = NormalStages:FindFirstChild("TheEnd")
        if TheEnd then
            local GoldenChest = TheEnd:FindFirstChild("GoldenChest")
            if GoldenChest then
                local Trigger = GoldenChest:FindFirstChild("Trigger")
                if Trigger then
                    -- Repete até a luz mudar (mecânica do jogo)
                    repeat 
                        wait()
                        if Character and Character.HumanoidRootPart then
                            Character.HumanoidRootPart.CFrame = Trigger.CFrame
                        end
                    until Lighting.ClockTime ~= 14 or not farmAtivo
                    
                    if farmAtivo then
                        ouroTotal = ouroTotal + 100
                        atualizarUI()
                    end
                end
            end
        end
    end

    -- Aguarda respawn e reinicia automaticamente
    if farmAtivo then
        -- Espera morrer e renascer
        local Respawned = false
        local Connection
        Connection = player.CharacterAdded:Connect(function(newChar)
            Respawned = true
            Connection:Disconnect()
            
            -- Pequena pausa para o jogo carregar
            wait(2)
            
            -- Reinicia a fase atual para 1 na próxima run
            faseAtual = 1
            atualizarUI()
        end)

        -- Tempo máximo de espera (30 segundos)
        local tempoEspera = 0
        while not Respawned and farmAtivo and tempoEspera < 30 do
            wait(1)
            tempoEspera = tempoEspera + 1
        end
        
        wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
    end
end

function iniciarFarmOriginal()
    runAtual = 1
    while farmAtivo do
        if farmAtivo then
            -- Tenta executar o farm
            local success, err = pcall(function()
                autoFarm(runAtual)
            end)
            
            if not success then
                wait(2)
            end
            
            runAtual = runAtual + 1
            atualizarUI()
        end
        wait(1)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaAutoFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

-- BOTÃO FLUTUANTE
local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Size = UDim2.new(0, 50, 0, 50)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -25)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = "⚡"
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 30
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui

local botaoCorner = Instance.new("UICorner")
botaoCorner.CornerRadius = UDim.new(1, 0)
botaoCorner.Parent = botaoFlutuante

-- FRAME PRINCIPAL
local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -250, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
title.Text = "⚡ CORINGA AUTO FARM ⚡"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 30, 0, 30)
btnMinimizar.Position = UDim2.new(1, -65, 0, 5)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
btnMinimizar.Text = "➖"
btnMinimizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimizar.TextSize = 20
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame

local btnMinimizarCorner = Instance.new("UICorner")
btnMinimizarCorner.CornerRadius = UDim.new(0, 5)
btnMinimizarCorner.Parent = btnMinimizar

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 30, 0, 30)
btnFechar.Position = UDim2.new(1, -30, 0, 5)
btnFechar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
btnFechar.Text = "✖"
btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFechar.TextSize = 20
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame

local btnFecharCorner = Instance.new("UICorner")
btnFecharCorner.CornerRadius = UDim.new(0, 5)
btnFecharCorner.Parent = btnFechar

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 120, 0, 40)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = "⚪ DESLIGADO"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = container

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 5)
statusCorner.Parent = statusLabel

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0, 120, 0, 40)
ouroLabel.Position = UDim2.new(0, 130, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = "💰 0"
ouroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ouroLabel.TextSize = 14
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = container

local ouroCorner = Instance.new("UICorner")
ouroCorner.CornerRadius = UDim.new(0, 5)
ouroCorner.Parent = ouroLabel

local faseLabel = Instance.new("TextLabel")
faseLabel.Size = UDim2.new(0, 120, 0, 40)
faseLabel.Position = UDim2.new(0, 260, 0, 0)
faseLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
faseLabel.Text = "🚢 1/10"
faseLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
faseLabel.TextSize = 14
faseLabel.Font = Enum.Font.GothamBold
faseLabel.Parent = container

local faseCorner = Instance.new("UICorner")
faseCorner.CornerRadius = UDim.new(0, 5)
faseCorner.Parent = faseLabel

local runLabel = Instance.new("TextLabel")
runLabel.Size = UDim2.new(0, 120, 0, 40)
runLabel.Position = UDim2.new(0, 390, 0, 0)
runLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
runLabel.Text = "🔄 ∞"
runLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
runLabel.TextSize = 14
runLabel.Font = Enum.Font.GothamBold
runLabel.Parent = container

local runCorner = Instance.new("UICorner")
runCorner.CornerRadius = UDim.new(0, 5)
runCorner.Parent = runLabel

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(0, 230, 0, 45)
btnIniciar.Position = UDim2.new(0, 0, 0, 55)
btnIniciar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIniciar.Text = "▶️ INICIAR FARM"
btnIniciar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIniciar.TextSize = 16
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = container

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = btnIniciar

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(0, 230, 0, 45)
btnVelocidade.Position = UDim2.new(0, 250, 0, 55)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
btnVelocidade.Text = "⚡ VELOCIDADE NORMAL"
btnVelocidade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVelocidade.TextSize = 14
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = container

local btnVelocidadeCorner = Instance.new("UICorner")
btnVelocidadeCorner.CornerRadius = UDim.new(0, 5)
btnVelocidadeCorner.Parent = btnVelocidade

function atualizarUI()
    if farmAtivo then
        statusLabel.Text = "🟢 ATIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        statusLabel.Text = "⚪ DESLIGADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    ouroLabel.Text = "💰 " .. ouroTotal
    faseLabel.Text = "🚢 " .. faseAtual .. "/10"
    runLabel.Text = "🔄 " .. runAtual
end

function minimizarMenu()
    menuMinimizado = not menuMinimizado
    
    local alvoSize = menuMinimizado and tamanhoMinimizado or tamanhoOriginal
    local alvoTransparencia = menuMinimizado and 1 or 0
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(frame, tweenInfo, {Size = alvoSize})
    tween:Play()
    
    for _, obj in pairs(container:GetChildren()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local fadeTween = TweenService:Create(obj, tweenInfo, {BackgroundTransparency = alvoTransparencia, TextTransparency = alvoTransparencia})
            fadeTween:Play()
        end
    end
    
    if menuMinimizado then
        botaoFlutuante.Visible = true
        btnMinimizar.Text = "⬜"
    else
        botaoFlutuante.Visible = false
        btnMinimizar.Text = "➖"
    end
end

botaoFlutuante.MouseButton1Click:Connect(function()
    if menuMinimizado then
        minimizarMenu()
    end
end)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().TreasureAutoFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and "⏸️ PAUSAR FARM" or "▶️ INICIAR FARM"
    atualizarUI()
    
    if farmAtivo then
        spawn(function()
            iniciarFarmOriginal()
        end)
        
        spawn(function()
            while farmAtivo do
                wait(60)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().TreasureAutoFarm.Teleport == 2 then
        getgenv().TreasureAutoFarm.Teleport = 0.5
        btnVelocidade.Text = "⚡ VELOCIDADE RÁPIDA"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    elseif getgenv().TreasureAutoFarm.Teleport == 0.5 then
        getgenv().TreasureAutoFarm.Teleport = 3
        btnVelocidade.Text = "⚡ VELOCIDADE LENTA"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        getgenv().TreasureAutoFarm.Teleport = 2
        btnVelocidade.Text = "⚡ VELOCIDADE NORMAL"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)

btnFechar.MouseButton1Click:Connect(function()
    farmAtivo = false
    getgenv().TreasureAutoFarm.Enabled = false
    screenGui:Destroy()
end)

atualizarUI()

frame.BackgroundTransparency = 1
for i = 1, 10 do
    wait(0.02)
    frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1
end
