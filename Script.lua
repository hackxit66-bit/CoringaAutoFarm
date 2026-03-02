local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
local tpBoxVisivel = false
local tamanhoOriginal = UDim2.new(0, 380, 0, 260)
local tamanhoMinimizado = UDim2.new(0, 120, 0, 30)

local coresTimes = {
    {Nome = " Preto", Cor = Color3.fromRGB(40, 40, 40), TeamName = "Preto"},
    {Nome = " Azul", Cor = Color3.fromRGB(0, 100, 255), TeamName = "Azul"},
    {Nome = " Verde", Cor = Color3.fromRGB(0, 150, 0), TeamName = "Verde"},
    {Nome = " Roxo", Cor = Color3.fromRGB(150, 0, 150), TeamName = "Roxo"},
    {Nome = " Vermelho", Cor = Color3.fromRGB(200, 0, 0), TeamName = "Vermelho"},
    {Nome = " Branco", Cor = Color3.fromRGB(255, 255, 255), TeamName = "Branco"},
    {Nome = " Amarelo", Cor = Color3.fromRGB(255, 200, 0), TeamName = "Amarelo"}
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
    if not BoatStages then wait(2) return end
    
    local NormalStages = BoatStages:FindFirstChild("NormalStages")
    if not NormalStages then wait(2) return end

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
                        Character.HumanoidRootPart.CFrame = Trigger.CFrame
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
        Connection = player.CharacterAdded:Connect(function()
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
            pcall(function() autoFarm(runAtual) end)
            runAtual = runAtual + 1
            atualizarUI()
        end
        wait(1)
    end
end

function teleportarParaCor(teamInfo)
    local root = getRoot()
    if not root then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
                root.CFrame = otherChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                break
            end
        end
    end
    
    submenuTimes.Visible = false
    submenuTimesVisivel = false
    btnTimes.Text = " TIMES"
    btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
end

function teleportarParaJogador(nick)
    if not nick or nick == "" then return end
    
    local alvo = Players:FindFirstChild(nick)
    if not alvo then return end
    
    local root = getRoot()
    if not root then return end
    
    local alvoChar = alvo.Character
    if not alvoChar then return end
    
    local alvoRoot = alvoChar:FindFirstChild("HumanoidRootPart")
    if not alvoRoot then return end
    
    root.CFrame = alvoRoot.CFrame * CFrame.new(0, 3, 2)
    
    if tpBoxVisivel then
        tpBox.Visible = false
        tpBoxVisivel = false
        btnTP.Text = " TP"
        btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaAutoFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Size = UDim2.new(0, 35, 0, 35)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -17)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = ""
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 18
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui
Instance.new("UICorner", botaoFlutuante).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -190, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
title.Text = " CORINGA AUTO FARM "
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 22, 0, 22)
btnMinimizar.Position = UDim2.new(1, -50, 0, 4)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
btnMinimizar.Text = ""
btnMinimizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimizar.TextSize = 14
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame
Instance.new("UICorner", btnMinimizar).CornerRadius = UDim.new(0, 4)

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 22, 0, 22)
btnFechar.Position = UDim2.new(1, -24, 0, 4)
btnFechar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
btnFechar.Text = ""
btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFechar.TextSize = 14
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 4)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -35)
container.Position = UDim2.new(0, 5, 0, 30)
container.BackgroundTransparency = 1
container.Parent = frame

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 25)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 45, 0, 25)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusFrame
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 4)

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0, 65, 0, 25)
ouroLabel.Position = UDim2.new(0, 50, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = " 0"
ouroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ouroLabel.TextSize = 12
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = statusFrame
Instance.new("UICorner", ouroLabel).CornerRadius = UDim.new(0, 4)

local faseLabel = Instance.new("TextLabel")
faseLabel.Size = UDim2.new(0, 60, 0, 25)
faseLabel.Position = UDim2.new(0, 120, 0, 0)
faseLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
faseLabel.Text = " 1/10"
faseLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
faseLabel.TextSize = 10
faseLabel.Font = Enum.Font.GothamBold
faseLabel.Parent = statusFrame
Instance.new("UICorner", faseLabel).CornerRadius = UDim.new(0, 4)

local runLabel = Instance.new("TextLabel")
runLabel.Size = UDim2.new(0, 45, 0, 25)
runLabel.Position = UDim2.new(0, 185, 0, 0)
runLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
runLabel.Text = " 1"
runLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
runLabel.TextSize = 10
runLabel.Font = Enum.Font.GothamBold
runLabel.Parent = statusFrame
Instance.new("UICorner", runLabel).CornerRadius = UDim.new(0, 4)

local botoesFrame = Instance.new("Frame")
botoesFrame.Size = UDim2.new(1, 0, 0, 35)
botoesFrame.Position = UDim2.new(0, 0, 0, 30)
botoesFrame.BackgroundTransparency = 1
botoesFrame.Parent = container

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(0, 80, 0, 35)
btnIniciar.Position = UDim2.new(0, 0, 0, 0)
btnIniciar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIniciar.Text = " INICIAR"
btnIniciar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIniciar.TextSize = 10
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = botoesFrame
Instance.new("UICorner", btnIniciar).CornerRadius = UDim.new(0, 4)

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(0, 80, 0, 35)
btnVelocidade.Position = UDim2.new(0, 90, 0, 0)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
btnVelocidade.Text = " NORMAL"
btnVelocidade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVelocidade.TextSize = 10
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = botoesFrame
Instance.new("UICorner", btnVelocidade).CornerRadius = UDim.new(0, 4)

local btnTimes = Instance.new("TextButton")
btnTimes.Size = UDim2.new(0, 80, 0, 35)
btnTimes.Position = UDim2.new(0, 180, 0, 0)
btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
btnTimes.Text = " TIMES"
btnTimes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTimes.TextSize = 10
btnTimes.Font = Enum.Font.GothamBold
btnTimes.Parent = botoesFrame
Instance.new("UICorner", btnTimes).CornerRadius = UDim.new(0, 4)

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0, 80, 0, 35)
btnTP.Position = UDim2.new(0, 270, 0, 0)
btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnTP.Text = " TP"
btnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTP.TextSize = 10
btnTP.Font = Enum.Font.GothamBold
btnTP.Parent = botoesFrame
Instance.new("UICorner", btnTP).CornerRadius = UDim.new(0, 4)

local submenuTimes = Instance.new("Frame")
submenuTimes.Size = UDim2.new(1, 0, 0, 80)
submenuTimes.Position = UDim2.new(0, 0, 0, 70)
submenuTimes.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
submenuTimes.BackgroundTransparency = 0.1
submenuTimes.Visible = false
submenuTimes.Parent = container
Instance.new("UICorner", submenuTimes).CornerRadius = UDim.new(0, 6)

local posX = 8
local posY = 8
local colunas = 0

for i, corInfo in pairs(coresTimes) do
    local btnCor = Instance.new("TextButton")
    btnCor.Size = UDim2.new(0, 80, 0, 25)
    btnCor.Position = UDim2.new(0, posX, 0, posY)
    btnCor.BackgroundColor3 = corInfo.Cor
    btnCor.Text = corInfo.Nome
    btnCor.TextColor3 = corInfo.Cor.r + corInfo.Cor.g + corInfo.Cor.b > 1.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btnCor.TextSize = 10
    btnCor.Font = Enum.Font.GothamBold
    btnCor.Parent = submenuTimes
    Instance.new("UICorner", btnCor).CornerRadius = UDim.new(0, 4)
    
    btnCor.MouseButton1Click:Connect(function() teleportarParaCor(corInfo) end)
    
    posX = posX + 88
    colunas = colunas + 1
    if colunas == 4 then
        colunas = 0
        posX = 8
        posY = 42
    end
end

local tpBox = Instance.new("Frame")
tpBox.Size = UDim2.new(1, 0, 0, 70)
tpBox.Position = UDim2.new(0, 0, 0, 70)
tpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tpBox.BackgroundTransparency = 0.1
tpBox.Visible = false
tpBox.Parent = container
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 6)

local tpInput = Instance.new("TextBox")
tpInput.Size = UDim2.new(0.7, 0, 0, 25)
tpInput.Position = UDim2.new(0.15, 0, 0.1, 0)
tpInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tpInput.PlaceholderText = "Digite o nick..."
tpInput.Text = ""
tpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
tpInput.TextSize = 11
tpInput.Font = Enum.Font.Gotham
tpInput.ClearTextOnFocus = false
tpInput.Parent = tpBox
Instance.new("UICorner", tpInput).CornerRadius = UDim.new(0, 4)

local btnConfirmar = Instance.new("TextButton")
btnConfirmar.Size = UDim2.new(0.4, 0, 0, 25)
btnConfirmar.Position = UDim2.new(0.3, 0, 0.55, 0)
btnConfirmar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnConfirmar.Text = " CONFIRMAR"
btnConfirmar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnConfirmar.TextSize = 10
btnConfirmar.Font = Enum.Font.GothamBold
btnConfirmar.Parent = tpBox
Instance.new("UICorner", btnConfirmar).CornerRadius = UDim.new(0, 4)

btnConfirmar.MouseButton1Click:Connect(function() teleportarParaJogador(tpInput.Text) end)
tpInput.FocusLost:Connect(function(enter) if enter then teleportarParaJogador(tpInput.Text) end end)

function atualizarUI()
    statusLabel.Text = farmAtivo and "" or ""
    statusLabel.TextColor3 = farmAtivo and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    ouroLabel.Text = " " .. ouroTotal
    faseLabel.Text = " " .. faseAtual .. "/10"
    runLabel.Text = " " .. runAtual
end

function minimizarMenu()
    menuMinimizado = not menuMinimizado
    local alvoSize = menuMinimizado and tamanhoMinimizado or tamanhoOriginal
    TweenService:Create(frame, TweenInfo.new(0.2), {Size = alvoSize}):Play()
    
    if menuMinimizado then
        botaoFlutuante.Visible = true
        btnMinimizar.Text = ""
    else
        botaoFlutuante.Visible = false
        btnMinimizar.Text = ""
    end
end

botaoFlutuante.MouseButton1Click:Connect(minimizarMenu)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().TreasureAutoFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and " PAUSAR" or " INICIAR"
    atualizarUI()
    
    if farmAtivo then
        spawn(iniciarFarmOriginal)
        spawn(function() while farmAtivo do wait(60) VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end end)
    end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().TreasureAutoFarm.Teleport == 2 then
        getgenv().TreasureAutoFarm.Teleport = 0.5
        btnVelocidade.Text = " RÁPIDO"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    elseif getgenv().TreasureAutoFarm.Teleport == 0.5 then
        getgenv().TreasureAutoFarm.Teleport = 3
        btnVelocidade.Text = " LENTO"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        getgenv().TreasureAutoFarm.Teleport = 2
        btnVelocidade.Text = " NORMAL"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

btnTimes.MouseButton1Click:Connect(function()
    if tpBoxVisivel then
        tpBox.Visible = false
        tpBoxVisivel = false
        btnTP.Text = " TP"
        btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end
    submenuTimesVisivel = not submenuTimesVisivel
    submenuTimes.Visible = submenuTimesVisivel
    btnTimes.Text = submenuTimesVisivel and " FECHAR" or " TIMES"
    btnTimes.BackgroundColor3 = submenuTimesVisivel and Color3.fromRGB(150, 0, 150) or Color3.fromRGB(128, 0, 128)
end)

btnTP.MouseButton1Click:Connect(function()
    if submenuTimesVisivel then
        submenuTimes.Visible = false
        submenuTimesVisivel = false
        btnTimes.Text = " TIMES"
        btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
    end
    tpBoxVisivel = not tpBoxVisivel
    tpBox.Visible = tpBoxVisivel
    btnTP.Text = tpBoxVisivel and " FECHAR" or " TP"
    btnTP.BackgroundColor3 = tpBoxVisivel and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 100, 200)
    if tpBoxVisivel then
        tpInput.Text = ""
        tpInput:CaptureFocus()
    end
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)
btnFechar.MouseButton1Click:Connect(function() farmAtivo = false getgenv().TreasureAutoFarm.Enabled = false screenGui:Destroy() end)

atualizarUI()

frame.BackgroundTransparency = 1
for i = 1, 10 do wait(0.02) frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1 end