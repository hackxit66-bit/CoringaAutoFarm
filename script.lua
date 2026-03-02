local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")

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
local submenuTimesVisivel = false
local tamanhoOriginal = UDim2.new(0, 500, 0, 320)
local tamanhoMinimizado = UDim2.new(0, 200, 0, 40)

-- Cores dos times disponíveis
local coresTimes = {
    {Nome = "⚫ Preto", Cor = Color3.fromRGB(0, 0, 0), TeamName = "Preto", TeamColor = BrickColor.new("Black")},
    {Nome = "🔵 Azul", Cor = Color3.fromRGB(0, 0, 255), TeamName = "Azul", TeamColor = BrickColor.new("Bright blue")},
    {Nome = "🟢 Verde", Cor = Color3.fromRGB(0, 255, 0), TeamName = "Verde", TeamColor = BrickColor.new("Bright green")},
    {Nome = "🟣 Roxo", Cor = Color3.fromRGB(128, 0, 128), TeamName = "Roxo", TeamColor = BrickColor.new("Bright violet")},
    {Nome = "🔴 Vermelho", Cor = Color3.fromRGB(255, 0, 0), TeamName = "Vermelho", TeamColor = BrickColor.new("Bright red")},
    {Nome = "⚪ Branco", Cor = Color3.fromRGB(255, 255, 255), TeamName = "Branco", TeamColor = BrickColor.new("White")},
    {Nome = "🟡 Amarelo", Cor = Color3.fromRGB(255, 255, 0), TeamName = "Amarelo", TeamColor = BrickColor.new("Bright yellow")}
}

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

    for i = 1, 10 do
        if not farmAtivo then break end
        
        local Stage = NormalStages:FindFirstChild("CaveStage" .. i)
        if Stage then
            local DarknessPart = Stage:FindFirstChild("DarknessPart")
            
            if DarknessPart then
                Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
                
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

    if farmAtivo then
        local TheEnd = NormalStages:FindFirstChild("TheEnd")
        if TheEnd then
            local GoldenChest = TheEnd:FindFirstChild("GoldenChest")
            if GoldenChest then
                local Trigger = GoldenChest:FindFirstChild("Trigger")
                if Trigger then
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

    if farmAtivo then
        local Respawned = false
        local Connection
        Connection = player.CharacterAdded:Connect(function(newChar)
            Respawned = true
            Connection:Disconnect()
            wait(2)
            faseAtual = 1
            atualizarUI()
        end)

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

-- Função para teleportar para um time específico
function teleportarParaCor(teamInfo)
    local root = getRoot()
    if not root then return end
    
    -- Procura por uma base ou área do time correspondente
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("Model") then
            -- Verifica se o objeto está relacionado ao time
            if obj.Name:find(teamInfo.TeamName) or obj.Name:find("Team") or obj.Name:find("Base") then
                if obj:IsA("Model") and obj.PrimaryPart then
                    root.CFrame = obj.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                elseif obj:IsA("Part") then
                    root.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                end
                
                -- Feedback visual
                print("🚀 Teleportado para time " .. teamInfo.Nome)
                return
            end
        end
    end
    
    -- Se não encontrar área específica, tenta mudar a cor do personagem
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("Part") or part:IsA("MeshPart") then
                part.BrickColor = teamInfo.TeamColor
                part.Material = Enum.Material.Neon
            end
        end
        print("🎨 Cor alterada para " .. teamInfo.Nome)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaAutoFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

-- Botão flutuante
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

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -250, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Título
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

-- Botão minimizar
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

-- Botão fechar
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

-- Container principal
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.Parent = frame

-- Labels de status
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

-- Botões de ação
local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(0, 150, 0, 45)
btnIniciar.Position = UDim2.new(0, 0, 0, 55)
btnIniciar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIniciar.Text = "▶️ INICIAR"
btnIniciar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIniciar.TextSize = 14
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = container

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = btnIniciar

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(0, 150, 0, 45)
btnVelocidade.Position = UDim2.new(0, 160, 0, 55)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
btnVelocidade.Text = "⚡ VELOCIDADE"
btnVelocidade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVelocidade.TextSize = 14
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = container

local btnVelocidadeCorner = Instance.new("UICorner")
btnVelocidadeCorner.CornerRadius = UDim.new(0, 5)
btnVelocidadeCorner.Parent = btnVelocidade

-- NOVO BOTÃO: TIMES
local btnTimes = Instance.new("TextButton")
btnTimes.Size = UDim2.new(0, 150, 0, 45)
btnTimes.Position = UDim2.new(0, 320, 0, 55)
btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
btnTimes.Text = "👥 TIMES"
btnTimes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTimes.TextSize = 14
btnTimes.Font = Enum.Font.GothamBold
btnTimes.Parent = container

local btnTimesCorner = Instance.new("UICorner")
btnTimesCorner.CornerRadius = UDim.new(0, 5)
btnTimesCorner.Parent = btnTimes

-- SUBMENU DE CORES (inicialmente invisível)
local submenuTimes = Instance.new("Frame")
submenuTimes.Size = UDim2.new(0, 470, 0, 140)
submenuTimes.Position = UDim2.new(0, 0, 0, 110)
submenuTimes.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
submenuTimes.BackgroundTransparency = 0.1
submenuTimes.Visible = false
submenuTimes.Parent = container

local submenuCorner = Instance.new("UICorner")
submenuCorner.CornerRadius = UDim.new(0, 8)
submenuCorner.Parent = submenuTimes

local submenuTitle = Instance.new("TextLabel")
submenuTitle.Size = UDim2.new(1, 0, 0, 25)
submenuTitle.BackgroundTransparency = 1
submenuTitle.Text = "📌 SELECIONE UMA COR"
submenuTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
submenuTitle.TextSize = 12
submenuTitle.Font = Enum.Font.GothamBold
submenuTitle.Parent = submenuTimes

-- Criar botões de cores (2 linhas de 4 cores)
local posX = 10
local posY = 30
local colunas = 0

for i, corInfo in pairs(coresTimes) do
    local btnCor = Instance.new("TextButton")
    btnCor.Size = UDim2.new(0, 100, 0, 40)
    btnCor.Position = UDim2.new(0, posX, 0, posY)
    btnCor.BackgroundColor3 = corInfo.Cor
    btnCor.Text = corInfo.Nome
    btnCor.TextColor3 = corInfo.Cor.r + corInfo.Cor.g + corInfo.Cor.b > 1.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btnCor.TextSize = 12
    btnCor.Font = Enum.Font.GothamBold
    btnCor.Parent = submenuTimes
    
    local btnCorCorner = Instance.new("UICorner")
    btnCorCorner.CornerRadius = UDim.new(0, 5)
    btnCorCorner.Parent = btnCor
    
    btnCor.MouseButton1Click:Connect(function()
        teleportarParaCor(corInfo)
        submenuTimes.Visible = false
        btnTimes.Text = "👥 " .. corInfo.Nome
    end)
    
    posX = posX + 115
    colunas = colunas + 1
    
    if colunas == 4 then
        colunas = 0
        posX = 10
        posY = 80
    end
end

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

-- Conexões dos botões
botaoFlutuante.MouseButton1Click:Connect(function()
    if menuMinimizado then
        minimizarMenu()
    end
end)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().TreasureAutoFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and "⏸️ PAUSAR" or "▶️ INICIAR"
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
        btnVelocidade.Text = "⚡ RÁPIDO"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    elseif getgenv().TreasureAutoFarm.Teleport == 0.5 then
        getgenv().TreasureAutoFarm.Teleport = 3
        btnVelocidade.Text = "⚡ LENTO"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        getgenv().TreasureAutoFarm.Teleport = 2
        btnVelocidade.Text = "⚡ NORMAL"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

-- Botão Times: abre/fecha submenu
btnTimes.MouseButton1Click:Connect(function()
    submenuTimes.Visible = not submenuTimes.Visible
    if submenuTimes.Visible then
        btnTimes.Text = "👥 FECHAR"
        btnTimes.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    else
        btnTimes.Text = "👥 TIMES"
        btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
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
