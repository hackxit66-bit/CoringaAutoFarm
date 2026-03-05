local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ChatService = game:GetService("Chat")

local player = Players.LocalPlayer

getgenv().CoringaFarm = {
    Enabled = false,
    Teleport = 2,
    TimeBetweenRuns = 5,
    Escudo = false,
    Velocidade = false,
    Invisivel = false,
    SuperPulo = false,
    VisaoNoturna = false,
    Noclip = false,
    VidaInfinita = false,
    ModoAmigo = false,
    AntiQueda = false,
    AntiAfk = false,
    Voo = false,
    Efeitos = false,
    Esp = false,
    Espiando = nil
}

local farmAtivo = false
local ouroTotal = 0
local faseAtual = 1
local runAtual = 1
local menuMinimizado = false
local mostrandoJogadores = true
local mostrandoPlayers = false
local mostrandoConfig = false
local mostrandoIdioma = false
local mostrandoTemas = false
local mostrandoOpcoesJogador = false
local jogadorSelecionado = nil
local temporizador = 0
local jogadoresProximos = {}
local farmCancelado = false
local idiomaAtual = "portugues"
local tamanhoOriginal = UDim2.new(0, 400, 0, 300)
local tamanhoMinimizado = UDim2.new(0, 80, 0, 25)
local amigos = {}
local efeitosObjetos = {}
local blocoAgua = nil
local antiAfkAtivo = false
local espObjetos = {}

-- =============================================
-- CORES DOS TEMAS
-- =============================================
local coresTemas = {
    ["🔵 Azul"] = {
        titulo = Color3.fromRGB(0, 150, 255),
        fundo = Color3.fromRGB(20, 30, 45),
        botao = Color3.fromRGB(0, 100, 200),
        texto = Color3.fromRGB(255, 255, 255),
        destaque = Color3.fromRGB(255, 215, 0)
    },
    ["🟢 Verde"] = {
        titulo = Color3.fromRGB(0, 255, 0),
        fundo = Color3.fromRGB(20, 45, 20),
        botao = Color3.fromRGB(0, 150, 0),
        texto = Color3.fromRGB(255, 255, 255),
        destaque = Color3.fromRGB(255, 215, 0)
    },
    ["🔴 Vermelho"] = {
        titulo = Color3.fromRGB(255, 0, 0),
        fundo = Color3.fromRGB(45, 20, 20),
        botao = Color3.fromRGB(200, 0, 0),
        texto = Color3.fromRGB(255, 255, 255),
        destaque = Color3.fromRGB(255, 215, 0)
    },
    ["🟡 Amarelo"] = {
        titulo = Color3.fromRGB(255, 255, 0),
        fundo = Color3.fromRGB(45, 45, 20),
        botao = Color3.fromRGB(200, 200, 0),
        texto = Color3.fromRGB(0, 0, 0),
        destaque = Color3.fromRGB(255, 215, 0)
    },
    ["💗 Rosa"] = {
        titulo = Color3.fromRGB(255, 100, 150),
        fundo = Color3.fromRGB(45, 20, 30),
        botao = Color3.fromRGB(200, 50, 100),
        texto = Color3.fromRGB(255, 255, 255),
        destaque = Color3.fromRGB(255, 215, 0)
    },
    ["🟣 Roxo"] = {
        titulo = Color3.fromRGB(150, 0, 255),
        fundo = Color3.fromRGB(30, 20, 45),
        botao = Color3.fromRGB(100, 0, 200),
        texto = Color3.fromRGB(255, 255, 255),
        destaque = Color3.fromRGB(255, 215, 0)
    }
}

local temaAtual = "🔵 Azul"

-- =============================================
-- TEXTOS DOS IDIOMAS
-- =============================================
local textos = {
    portugues = {
        titulo = "⚡ CORINGA AUTO FARM ⚡",
        iniciar = "▶️ INICIAR",
        pausar = "⏸️ PAUSAR",
        velocidade = "⚡ VEL NORMAL",
        velRapida = "⚡ VEL RAPIDA",
        velLenta = "🐢 VEL LENTA",
        player = "👤 PLAYER",
        fecharPlayer = "❌ FECHAR PLAYER",
        config = "⚙️ CONFIG",
        fecharConfig = "❌ FECHAR CONFIG",
        idioma = "🌎 IDIOMA",
        temas = "🎨 TEMAS",
        voltar = "🔙 VOLTAR",
        jogadores = "👥 JOGADORES",
        playerTitulo = "⚙️ PLAYER",
        configTitulo = "⚙️ CONFIGURAÇÕES",
        idiomaTitulo = "🌎 IDIOMA",
        temasTitulo = "🎨 TEMAS",
        portuguesOpcao = "🇧🇷 Português",
        inglesOpcao = "🇺🇸 English",
        espanholOpcao = "🇪🇸 Español",
        velocidadeNome = "⚡ Velocidade",
        invisivelNome = "👻 Invisível",
        superPuloNome = "⬆️ Super Pulo",
        escudoNome = "🛡️ Escudo",
        visaoNoturnaNome = "👁️ Visão Noturna",
        efeitosNome = "✨ Efeitos",
        vooNome = "✈️ Voo",
        noclipNome = "🧱 NoClip",
        vidaInfinitaNome = "❤️ Vida Infinita",
        modoAmigoNome = "🤝 Modo Amigo",
        antiQuedaNome = "⚡ Anti Queda",
        antiAfkNome = "🔄 Anti-AFK",
        espNome = "👁️ ESP",
        espiar = "👁️ ESPIAR",
        teleportar = "📍 TP",
        subir = "⬆️ SUBIR",
        descer = "⬇️ DESCER"
    },
    english = {
        titulo = "⚡ CORINGA AUTO FARM ⚡",
        iniciar = "▶️ START",
        pausar = "⏸️ PAUSE",
        velocidade = "⚡ SPEED NORMAL",
        velRapida = "⚡ FAST SPEED",
        velLenta = "🐢 SLOW SPEED",
        player = "👤 PLAYER",
        fecharPlayer = "❌ CLOSE PLAYER",
        config = "⚙️ SETTINGS",
        fecharConfig = "❌ CLOSE SETTINGS",
        idioma = "🌎 LANGUAGE",
        temas = "🎨 THEMES",
        voltar = "🔙 BACK",
        jogadores = "👥 PLAYERS",
        playerTitulo = "⚙️ PLAYER",
        configTitulo = "⚙️ SETTINGS",
        idiomaTitulo = "🌎 LANGUAGE",
        temasTitulo = "🎨 THEMES",
        portuguesOpcao = "🇧🇷 Portuguese",
        inglesOpcao = "🇺🇸 English",
        espanholOpcao = "🇪🇸 Spanish",
        velocidadeNome = "⚡ Speed",
        invisivelNome = "👻 Invisible",
        superPuloNome = "⬆️ Super Jump",
        escudoNome = "🛡️ Shield",
        visaoNoturnaNome = "👁️ Night Vision",
        efeitosNome = "✨ Effects",
        vooNome = "✈️ Fly",
        noclipNome = "🧱 NoClip",
        vidaInfinitaNome = "❤️ Infinite Life",
        modoAmigoNome = "🤝 Friend Mode",
        antiQuedaNome = "⚡ Anti Fall",
        antiAfkNome = "🔄 Anti-AFK",
        espNome = "👁️ ESP",
        espiar = "👁️ WATCH",
        teleportar = "📍 TP",
        subir = "⬆️ UP",
        descer = "⬇️ DOWN"
    },
    espanol = {
        titulo = "⚡ CORINGA AUTO FARM ⚡",
        iniciar = "▶️ INICIAR",
        pausar = "⏸️ PAUSAR",
        velocidade = "⚡ VEL NORMAL",
        velRapida = "⚡ VEL RÁPIDA",
        velLenta = "🐢 VEL LENTA",
        player = "👤 JUGADOR",
        fecharPlayer = "❌ CERRAR JUGADOR",
        config = "⚙️ CONFIG",
        fecharConfig = "❌ CERRAR CONFIG",
        idioma = "🌎 IDIOMA",
        temas = "🎨 TEMAS",
        voltar = "🔙 VOLVER",
        jogadores = "👥 JUGADORES",
        playerTitulo = "⚙️ JUGADOR",
        configTitulo = "⚙️ CONFIGURACIÓN",
        idiomaTitulo = "🌎 IDIOMA",
        temasTitulo = "🎨 TEMAS",
        portuguesOpcao = "🇧🇷 Portugués",
        inglesOpcao = "🇺🇸 Inglés",
        espanholOpcao = "🇪🇸 Español",
        velocidadeNome = "⚡ Velocidad",
        invisivelNome = "👻 Invisible",
        superPuloNome = "⬆️ Super Salto",
        escudoNome = "🛡️ Escudo",
        visaoNoturnaNome = "👁️ Visión Nocturna",
        efeitosNome = "✨ Efectos",
        vooNome = "✈️ Vuelo",
        noclipNome = "🧱 NoClip",
        vidaInfinitaNome = "❤️ Vida Infinita",
        modoAmigoNome = "🤝 Modo Amigo",
        antiQuedaNome = "⚡ Anti Caída",
        antiAfkNome = "🔄 Anti-AFK",
        espNome = "👁️ ESP",
        espiar = "👁️ VIGILAR",
        teleportar = "📍 TP",
        subir = "⬆️ SUBIR",
        descer = "⬇️ BAJAR"
    }
}

function getRoot()
    local character = player.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function getHumanoid()
    local character = player.Character
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

-- =============================================
-- FUNÇÕES DE UTILIDADES
-- =============================================

-- LIMPAR EFEITOS
function limparEfeitos()
    for _, obj in pairs(efeitosObjetos) do
        pcall(function() obj:Destroy() end)
    end
    efeitosObjetos = {}
end

-- EFEITO DE BOLINHAS
function efeitoUnicoLoop()
    spawn(function()
        while getgenv().CoringaFarm.Efeitos do
            local root = getRoot()
            if root then
                limparEfeitos()
                local particle = Instance.new("ParticleEmitter")
                particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                particle.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
                particle.Lifetime = NumberRange.new(1, 2)
                particle.Rate = 100
                particle.Speed = NumberRange.new(2, 4)
                particle.SpreadAngle = Vector2.new(360, 360)
                particle.VelocityInheritance = 0
                particle.Parent = root
                table.insert(efeitosObjetos, particle)
            end
            wait(1)
        end
        limparEfeitos()
    end)
end

-- ESP MELHORADO (COM HIGHLIGHT)
function criarESPJogador(alvo)
    if not alvo.Character then return end
    
    -- HIGHLIGHT (contorno através das paredes)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. alvo.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = alvo.Character
    table.insert(espObjetos, highlight)
    
    -- BILLBOARD (nome e distância)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Nome_" .. alvo.Name
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = alvo.Character:FindFirstChild("Head") or alvo.Character:FindFirstChild("HumanoidRootPart")
    
    local distancia = alvo.Character.HumanoidRootPart and math.floor((alvo.Character.HumanoidRootPart.Position - getRoot().Position).Magnitude) or 0
    
    local texto = Instance.new("TextLabel")
    texto.Size = UDim2.new(1, 0, 1, 0)
    texto.BackgroundTransparency = 1
    texto.Text = alvo.Name .. " | " .. distancia .. "m"
    texto.TextColor3 = Color3.fromRGB(255, 255, 255)
    texto.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    texto.TextStrokeTransparency = 0
    texto.TextScaled = true
    texto.Font = Enum.Font.GothamBold
    texto.Parent = billboard
    
    table.insert(espObjetos, billboard)
end

function removerESP()
    for _, obj in pairs(espObjetos) do
        pcall(function() obj:Destroy() end)
    end
    espObjetos = {}
end

function espLoop()
    spawn(function()
        while getgenv().CoringaFarm.Esp do
            removerESP()
            for _, outroJogador in pairs(Players:GetPlayers()) do
                if outroJogador ~= player and outroJogador.Character then
                    criarESPJogador(outroJogador)
                end
            end
            wait(0.5)
        end
        removerESP()
    end)
end

-- ESCUDO
function escudoLoop()
    spawn(function()
        while getgenv().CoringaFarm.Escudo do
            local character = player.Character
            if character then
                local shieldAntigo = character:FindFirstChild("Shield")
                if shieldAntigo then
                    shieldAntigo:Destroy()
                end
                local shield = Instance.new("ForceField")
                shield.Name = "Shield"
                shield.Visible = true
                shield.Parent = character
            end
            wait(0.1)
        end
        local character = player.Character
        if character then
            local shield = character:FindFirstChild("Shield")
            if shield then
                shield:Destroy()
            end
        end
    end)
end

-- DEMAIS FUNÇÕES
function antiAfkLoop()
    spawn(function()
        while getgenv().CoringaFarm.AntiAfk do
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
            VirtualUser:ClickButton2(Vector2.new())
            wait(60)
        end
    end)
end

function velocidadeLoop()
    spawn(function()
        while getgenv().CoringaFarm.Velocidade do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = 100
            end
            wait()
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end)
end

function superPuloLoop()
    spawn(function()
        while getgenv().CoringaFarm.SuperPulo do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = 200
            end
            wait()
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.JumpPower = 50
        end
    end)
end

function visaoNoturnaLoop()
    spawn(function()
        while getgenv().CoringaFarm.VisaoNoturna do
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            wait()
        end
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
    end)
end

function noclipLoop()
    spawn(function()
        while getgenv().CoringaFarm.Noclip do
            local character = player.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            wait(0.1)
        end
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
end

function vidaInfinitaLoop()
    spawn(function()
        while getgenv().CoringaFarm.VidaInfinita do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
            wait(0.5)
        end
    end)
end

function modoAmigoLoop()
    spawn(function()
        while getgenv().CoringaFarm.ModoAmigo do
            wait(2)
        end
    end)
end

function antiQuedaLoop()
    spawn(function()
        while getgenv().CoringaFarm.AntiQueda do
            local root = getRoot()
            if root and root.Position.Y < -50 then
                root.CFrame = CFrame.new(0, 100, 0)
            end
            wait(0.5)
        end
    end)
end

function invisivelLoop()
    spawn(function()
        while getgenv().CoringaFarm.Invisivel do
            local character = player.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    end
                end
            end
            wait()
        end
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end)
end

-- =============================================
-- FUNÇÕES DE VOO
-- =============================================

local botoesVoo = {}
local vooGui = nil
local bodyVelocityVoo = nil
local vooAtivo = false

function destruirBotoesVoo()
    if bodyVelocityVoo then
        bodyVelocityVoo:Destroy()
        bodyVelocityVoo = nil
    end
    if vooGui then
        vooGui:Destroy()
        vooGui = nil
    end
    botoesVoo = {}
    vooAtivo = false
end

function criarBotoesVoo()
    destruirBotoesVoo()
    
    bodyVelocityVoo = Instance.new("BodyVelocity")
    bodyVelocityVoo.MaxForce = Vector3.new(0, 4000, 0)
    bodyVelocityVoo.Velocity = Vector3.new(0, 0, 0)
    
    local root = getRoot()
    if root then
        bodyVelocityVoo.Parent = root
    end
    
    vooAtivo = true
    
    vooGui = Instance.new("ScreenGui")
    vooGui.Name = "VooBotoes"
    vooGui.ResetOnSpawn = false
    vooGui.Parent = player:WaitForChild("PlayerGui")
    vooGui.DisplayOrder = 1000
    
    local btnSubir = Instance.new("TextButton")
    btnSubir.Size = UDim2.new(0, 80, 0, 70)
    btnSubir.Position = UDim2.new(0.85, -40, 0.4, -35)
    btnSubir.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    btnSubir.Text = textos[idiomaAtual].subir
    btnSubir.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSubir.TextSize = 14
    btnSubir.Font = Enum.Font.GothamBold
    btnSubir.Parent = vooGui
    Instance.new("UICorner", btnSubir).CornerRadius = UDim.new(0, 10)
    
    btnSubir.MouseButton1Click:Connect(function()
        local root = getRoot()
        if root and vooAtivo then
            root.CFrame = root.CFrame + Vector3.new(0, 10, 0)
            if bodyVelocityVoo then
                bodyVelocityVoo.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    local btnDescer = Instance.new("TextButton")
    btnDescer.Size = UDim2.new(0, 80, 0, 70)
    btnDescer.Position = UDim2.new(0.85, -40, 0.6, -35)
    btnDescer.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    btnDescer.Text = textos[idiomaAtual].descer
    btnDescer.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnDescer.TextSize = 14
    btnDescer.Font = Enum.Font.GothamBold
    btnDescer.Parent = vooGui
    Instance.new("UICorner", btnDescer).CornerRadius = UDim.new(0, 10)
    
    btnDescer.MouseButton1Click:Connect(function()
        local root = getRoot()
        if root and vooAtivo then
            root.CFrame = root.CFrame + Vector3.new(0, -10, 0)
            if bodyVelocityVoo then
                bodyVelocityVoo.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

function vooLoop()
    spawn(function()
        while getgenv().CoringaFarm.Voo do
            local root = getRoot()
            if root and bodyVelocityVoo and bodyVelocityVoo.Parent ~= root then
                bodyVelocityVoo.Parent = root
            end
            wait(1)
        end
        destruirBotoesVoo()
    end)
end

-- =============================================
-- FUNÇÕES DE JOGADORES
-- =============================================

function espiarJogador(alvo)
    spawn(function()
        local camera = Workspace.CurrentCamera
        local cameraType = camera.CameraType
        local cameraCFrame = camera.CFrame
        
        camera.CameraType = Enum.CameraType.Scriptable
        
        local tempo = 0
        while tempo < 10 do
            local alvoChar = alvo.Character
            if alvoChar and alvoChar:FindFirstChild("HumanoidRootPart") and alvoChar:FindFirstChild("Head") then
                local head = alvoChar.Head
                camera.CFrame = CFrame.new(head.Position + Vector3.new(0, 2, 5), head.Position)
            end
            wait(0.1)
            tempo = tempo + 0.1
        end
        
        camera.CameraType = cameraType
        camera.CFrame = cameraCFrame
    end)
end

function verJogadoresProximos()
    jogadoresProximos = {}
    local root = getRoot()
    if root then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherChar = otherPlayer.Character
                if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (otherChar.HumanoidRootPart.Position - root.Position).Magnitude
                    table.insert(jogadoresProximos, {player = otherPlayer, dist = dist})
                end
            end
        end
        table.sort(jogadoresProximos, function(a, b) return a.dist < b.dist end)
    end
    atualizarListaJogadores()
end

function teleportarParaJogador(alvo)
    local root = getRoot()
    if not root then return end
    
    local alvoChar = alvo.Character
    if not alvoChar then return end
    
    local alvoRoot = alvoChar:FindFirstChild("HumanoidRootPart")
    if not alvoRoot then return end
    
    root.CFrame = alvoRoot.CFrame * CFrame.new(0, 5, 2)
end

-- =============================================
-- FUNÇÃO DE FARM
-- =============================================

function autoFarm(currentRun)
    farmCancelado = false
    local Character = player.Character
    if not Character then 
        player.CharacterAdded:Wait()
        Character = player.Character
    end
    
    local BoatStages = Workspace:FindFirstChild("BoatStages")
    if not BoatStages then return end
    
    local NormalStages = BoatStages:FindFirstChild("NormalStages")
    if not NormalStages then return end

    for i = 1, 10 do
        if not farmAtivo or farmCancelado then break end
        
        local Stage = NormalStages:FindFirstChild("CaveStage" .. i)
        if Stage then
            local DarknessPart = Stage:FindFirstChild("DarknessPart")
            if DarknessPart then
                Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
                
                local Part = Instance.new("Part", Character)
                Part.Anchored = true
                Part.Position = Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)
                
                wait(getgenv().CoringaFarm.Teleport)
                Part:Destroy()
                
                faseAtual = i
                atualizarUI()
            end
        end
    end

    if farmAtivo and not farmCancelado then
        local TheEnd = NormalStages:FindFirstChild("TheEnd")
        if TheEnd then
            local GoldenChest = TheEnd:FindFirstChild("GoldenChest")
            if GoldenChest then
                local Trigger = GoldenChest:FindFirstChild("Trigger")
                if Trigger then
                    Character.HumanoidRootPart.CFrame = Trigger.CFrame
                    
                    local luzMudou = false
                    local tempo = 0
                    
                    while not luzMudou and farmAtivo and tempo < 10 do
                        wait(0.5)
                        tempo = tempo + 0.5
                        
                        if Lighting.ClockTime ~= 14 then
                            luzMudou = true
                        end
                    end
                    
                    if luzMudou then
                        ouroTotal = ouroTotal + 100
                    end
                    atualizarUI()
                end
            end
        end
    end

    if farmAtivo and not farmCancelado then
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
        
        wait(getgenv().CoringaFarm.TimeBetweenRuns)
    end
end

function iniciarFarmOriginal()
    runAtual = 1
    while farmAtivo and not farmCancelado do
        if farmAtivo and not farmCancelado then
            local success = pcall(function() 
                autoFarm(runAtual) 
            end)
            
            runAtual = runAtual + 1
            atualizarUI()
        end
        wait(1)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Size = UDim2.new(0, 25, 0, 25)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -12)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = "⚡"
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 14
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui
Instance.new("UICorner", botaoFlutuante).CornerRadius = UDim.new(1, 0)

-- FUNÇÃO PARA APLICAR TEMA
function aplicarTema(tema)
    local cores = coresTemas[tema]
    if not cores then return end
    
    frame.BackgroundColor3 = cores.fundo
    title.BackgroundColor3 = cores.titulo
    title.TextColor3 = cores.texto
    
    btnIniciar.BackgroundColor3 = cores.botao
    btnVelocidade.BackgroundColor3 = cores.botao
    btnPlayer.BackgroundColor3 = cores.botao
    btnConfig.BackgroundColor3 = cores.botao
    
    statusLabel.TextColor3 = farmAtivo and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    ouroLabel.TextColor3 = cores.destaque
    timerLabel.TextColor3 = cores.texto
    
    for _, btn in pairs(idiomaBotoes or {}) do
        btn.BackgroundColor3 = btn.Text == (idiomaAtual == "portugues" and textos[idiomaAtual].portuguesOpcao or 
                                           (idiomaAtual == "english" and textos[idiomaAtual].inglesOpcao or 
                                           textos[idiomaAtual].espanholOpcao)) and Color3.fromRGB(0, 150, 0) or cores.botao
    end
    
    for _, btn in pairs(temaBotoes or {}) do
        if btn then
            btn.BackgroundColor3 = btn.Text:find(tema) and Color3.fromRGB(0, 150, 0) or cores.botao
        end
    end
end

-- FRAME PRINCIPAL
local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = coresTemas[temaAtual].fundo
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 25)
title.BackgroundColor3 = coresTemas[temaAtual].titulo
title.Text = textos[idiomaAtual].titulo
title.TextColor3 = coresTemas[temaAtual].texto
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 18, 0, 18)
btnMinimizar.Position = UDim2.new(1, -38, 0, 3)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnMinimizar.Text = "➖"
btnMinimizar.TextColor3 = Color3.fromRGB(0, 0, 0)
btnMinimizar.TextSize = 12
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame
Instance.new("UICorner", btnMinimizar).CornerRadius = UDim.new(0, 3)

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 18, 0, 18)
btnFechar.Position = UDim2.new(1, -18, 0, 3)
btnFechar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnFechar.Text = "✖"
btnFechar.TextColor3 = Color3.fromRGB(0, 0, 0)
btnFechar.TextSize = 12
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 3)

-- =============================================
-- CONTAINER PRINCIPAL
-- =============================================
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -30)
container.Position = UDim2.new(0, 5, 0, 25)
container.BackgroundTransparency = 1
container.Parent = frame

-- =============================================
-- PAINEL ESQUERDO
-- =============================================
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.5, -3, 1, 0)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = container

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 45)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusFrame.BackgroundTransparency = 0.1
statusFrame.Parent = leftPanel
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 5)

local statusGrid = Instance.new("Frame")
statusGrid.Size = UDim2.new(1, -10, 1, -10)
statusGrid.Position = UDim2.new(0, 5, 0, 5)
statusGrid.BackgroundTransparency = 1
statusGrid.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.33, -2, 1, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = "⚪"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusGrid
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 4)

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0.33, -2, 1, 0)
ouroLabel.Position = UDim2.new(0.33, 2, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = "💰0"
ouroLabel.TextColor3 = coresTemas[temaAtual].destaque
ouroLabel.TextSize = 11
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = statusGrid
Instance.new("UICorner", ouroLabel).CornerRadius = UDim.new(0, 4)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.33, -2, 1, 0)
timerLabel.Position = UDim2.new(0.66, 4, 0, 0)
timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
timerLabel.Text = "⏱️0s"
timerLabel.TextColor3 = coresTemas[temaAtual].texto
timerLabel.TextSize = 10
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = statusGrid
Instance.new("UICorner", timerLabel).CornerRadius = UDim.new(0, 4)

-- BOTÕES DO MENU PRINCIPAL
local botoesFrame = Instance.new("Frame")
botoesFrame.Size = UDim2.new(1, 0, 0, 140)
botoesFrame.Position = UDim2.new(0, 0, 0, 50)
botoesFrame.BackgroundTransparency = 1
botoesFrame.Parent = leftPanel

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(1, 0, 0, 30)
btnIniciar.BackgroundColor3 = coresTemas[temaAtual].botao
btnIniciar.Text = textos[idiomaAtual].iniciar
btnIniciar.TextColor3 = coresTemas[temaAtual].texto
btnIniciar.TextSize = 10
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = botoesFrame
Instance.new("UICorner", btnIniciar).CornerRadius = UDim.new(0, 4)

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(1, 0, 0, 30)
btnVelocidade.Position = UDim2.new(0, 0, 0, 35)
btnVelocidade.BackgroundColor3 = coresTemas[temaAtual].botao
btnVelocidade.Text = textos[idiomaAtual].velocidade
btnVelocidade.TextColor3 = coresTemas[temaAtual].texto
btnVelocidade.TextSize = 9
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = botoesFrame
Instance.new("UICorner", btnVelocidade).CornerRadius = UDim.new(0, 4)

local btnPlayer = Instance.new("TextButton")
btnPlayer.Size = UDim2.new(1, 0, 0, 30)
btnPlayer.Position = UDim2.new(0, 0, 0, 70)
btnPlayer.BackgroundColor3 = coresTemas[temaAtual].botao
btnPlayer.Text = textos[idiomaAtual].player
btnPlayer.TextColor3 = coresTemas[temaAtual].texto
btnPlayer.TextSize = 10
btnPlayer.Font = Enum.Font.GothamBold
btnPlayer.Parent = botoesFrame
Instance.new("UICorner", btnPlayer).CornerRadius = UDim.new(0, 4)

local btnConfig = Instance.new("TextButton")
btnConfig.Size = UDim2.new(1, 0, 0, 30)
btnConfig.Position = UDim2.new(0, 0, 0, 105)
btnConfig.BackgroundColor3 = coresTemas[temaAtual].botao
btnConfig.Text = textos[idiomaAtual].config
btnConfig.TextColor3 = coresTemas[temaAtual].texto
btnConfig.TextSize = 10
btnConfig.Font = Enum.Font.GothamBold
btnConfig.Parent = botoesFrame
Instance.new("UICorner", btnConfig).CornerRadius = UDim.new(0, 4)

-- =============================================
-- PAINEL DIREITO
-- =============================================
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.5, -3, 1, 0)
rightPanel.Position = UDim2.new(0.5, 3, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
rightPanel.BackgroundTransparency = 0.1
rightPanel.Parent = container
Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 5)

local rightTitle = Instance.new("TextLabel")
rightTitle.Size = UDim2.new(1, -10, 0, 20)
rightTitle.Position = UDim2.new(0, 5, 0, 5)
rightTitle.BackgroundTransparency = 1
rightTitle.Text = textos[idiomaAtual].jogadores
rightTitle.TextColor3 = coresTemas[temaAtual].destaque
rightTitle.TextSize = 11
rightTitle.Font = Enum.Font.GothamBold
rightTitle.Parent = rightPanel

-- LISTA DE JOGADORES
local jogadoresLista = Instance.new("ScrollingFrame")
jogadoresLista.Size = UDim2.new(1, -10, 1, -30)
jogadoresLista.Position = UDim2.new(0, 5, 0, 25)
jogadoresLista.BackgroundTransparency = 1
jogadoresLista.ScrollBarThickness = 4
jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, 0)
jogadoresLista.Parent = rightPanel
jogadoresLista.Visible = true

-- LISTA DE OPÇÕES DO JOGADOR
local opcoesLista = Instance.new("Frame")
opcoesLista.Size = UDim2.new(1, -10, 0, 80)
opcoesLista.Position = UDim2.new(0, 5, 0, 25)
opcoesLista.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
opcoesLista.BackgroundTransparency = 0.1
opcoesLista.Visible = false
opcoesLista.Parent = rightPanel
Instance.new("UICorner", opcoesLista).CornerRadius = UDim.new(0, 6)

local opcoesTitle = Instance.new("TextLabel")
opcoesTitle.Size = UDim2.new(1, -10, 0, 20)
opcoesTitle.Position = UDim2.new(0, 5, 0, 5)
opcoesTitle.BackgroundTransparency = 1
opcoesTitle.Text = "Selecione uma opção"
opcoesTitle.TextColor3 = coresTemas[temaAtual].destaque
opcoesTitle.TextSize = 11
opcoesTitle.Font = Enum.Font.GothamBold
opcoesTitle.Parent = opcoesLista

local btnEspiar = Instance.new("TextButton")
btnEspiar.Size = UDim2.new(0.8, 0, 0, 25)
btnEspiar.Position = UDim2.new(0.1, 0, 0.3, 0)
btnEspiar.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
btnEspiar.Text = textos[idiomaAtual].espiar
btnEspiar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEspiar.TextSize = 11
btnEspiar.Font = Enum.Font.GothamBold
btnEspiar.Parent = opcoesLista
Instance.new("UICorner", btnEspiar).CornerRadius = UDim.new(0, 4)

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0.8, 0, 0, 25)
btnTP.Position = UDim2.new(0.1, 0, 0.6, 0)
btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnTP.Text = textos[idiomaAtual].teleportar
btnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTP.TextSize = 11
btnTP.Font = Enum.Font.GothamBold
btnTP.Parent = opcoesLista
Instance.new("UICorner", btnTP).CornerRadius = UDim.new(0, 4)

btnEspiar.MouseButton1Click:Connect(function()
    if jogadorSelecionado then
        espiarJogador(jogadorSelecionado)
        opcoesLista.Visible = false
        jogadoresLista.Visible = true
        mostrandoJogadores = true
        mostrandoOpcoesJogador = false
        rightTitle.Text = textos[idiomaAtual].jogadores
    end
end)

btnTP.MouseButton1Click:Connect(function()
    if jogadorSelecionado then
        teleportarParaJogador(jogadorSelecionado)
        opcoesLista.Visible = false
        jogadoresLista.Visible = true
        mostrandoJogadores = true
        mostrandoOpcoesJogador = false
        rightTitle.Text = textos[idiomaAtual].jogadores
    end
end)

-- LISTA DE PLAYER
local playerLista = Instance.new("ScrollingFrame")
playerLista.Size = UDim2.new(1, -10, 1, -30)
playerLista.Position = UDim2.new(0, 5, 0, 25)
playerLista.BackgroundTransparency = 1
playerLista.ScrollBarThickness = 4
playerLista.CanvasSize = UDim2.new(0, 0, 0, 0)
playerLista.Parent = rightPanel
playerLista.Visible = false

-- LISTA DE CONFIGURAÇÃO (SUBMENU)
local configLista = Instance.new("ScrollingFrame")
configLista.Size = UDim2.new(1, -10, 1, -30)
configLista.Position = UDim2.new(0, 5, 0, 25)
configLista.BackgroundTransparency = 1
configLista.ScrollBarThickness = 4
configLista.CanvasSize = UDim2.new(0, 0, 0, 0)
configLista.Parent = rightPanel
configLista.Visible = false

-- BOTÃO IDIOMA (dentro de CONFIG)
local btnIdioma = Instance.new("TextButton")
btnIdioma.Size = UDim2.new(0.9, 0, 0, 30)
btnIdioma.Position = UDim2.new(0.05, 0, 0.05, 0)
btnIdioma.BackgroundColor3 = coresTemas[temaAtual].botao
btnIdioma.Text = textos[idiomaAtual].idioma
btnIdioma.TextColor3 = coresTemas[temaAtual].texto
btnIdioma.TextSize = 12
btnIdioma.Font = Enum.Font.GothamBold
btnIdioma.Parent = configLista
Instance.new("UICorner", btnIdioma).CornerRadius = UDim.new(0, 4)

-- BOTÃO TEMAS (dentro de CONFIG)
local btnTemas = Instance.new("TextButton")
btnTemas.Size = UDim2.new(0.9, 0, 0, 30)
btnTemas.Position = UDim2.new(0.05, 0, 0.15, 0)
btnTemas.BackgroundColor3 = coresTemas[temaAtual].botao
btnTemas.Text = textos[idiomaAtual].temas
btnTemas.TextColor3 = coresTemas[temaAtual].texto
btnTemas.TextSize = 12
btnTemas.Font = Enum.Font.GothamBold
btnTemas.Parent = configLista
Instance.new("UICorner", btnTemas).CornerRadius = UDim.new(0, 4)

-- LISTA DE IDIOMA
local idiomaLista = Instance.new("Frame")
idiomaLista.Size = UDim2.new(1, -10, 0, 100)
idiomaLista.Position = UDim2.new(0, 5, 0, 25)
idiomaLista.BackgroundTransparency = 1
idiomaLista.Parent = rightPanel
idiomaLista.Visible = false

local idiomaBotoes = {}
local idiomasOpcoes = {
    {nome = textos[idiomaAtual].portuguesOpcao, id = "portugues"},
    {nome = textos[idiomaAtual].inglesOpcao, id = "english"},
    {nome = textos[idiomaAtual].espanholOpcao, id = "espanol"}
}

for i, idioma in ipairs(idiomasOpcoes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0.05 + (i-1)*0.1, 0)
    btn.BackgroundColor3 = idioma.id == idiomaAtual and Color3.fromRGB(0, 150, 0) or coresTemas[temaAtual].botao
    btn.Text = idioma.nome
    btn.TextColor3 = coresTemas[temaAtual].texto
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = idiomaLista
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        idiomaAtual = idioma.id
        for _, b in pairs(idiomaBotoes) do
            b.BackgroundColor3 = coresTemas[temaAtual].botao
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        atualizarIdioma()
    end)
    
    table.insert(idiomaBotoes, btn)
end

local btnVoltarIdioma = Instance.new("TextButton")
btnVoltarIdioma.Size = UDim2.new(0.9, 0, 0, 25)
btnVoltarIdioma.Position = UDim2.new(0.05, 0, 0.35, 0)
btnVoltarIdioma.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnVoltarIdioma.Text = textos[idiomaAtual].voltar
btnVoltarIdioma.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVoltarIdioma.TextSize = 11
btnVoltarIdioma.Font = Enum.Font.GothamBold
btnVoltarIdioma.Parent = idiomaLista
Instance.new("UICorner", btnVoltarIdioma).CornerRadius = UDim.new(0, 4)

btnVoltarIdioma.MouseButton1Click:Connect(function()
    idiomaLista.Visible = false
    configLista.Visible = true
    mostrandoIdioma = false
    rightTitle.Text = textos[idiomaAtual].configTitulo
end)

-- LISTA DE TEMAS
local temasLista = Instance.new("Frame")
temasLista.Size = UDim2.new(1, -10, 0, 200)
temasLista.Position = UDim2.new(0, 5, 0, 25)
temasLista.BackgroundTransparency = 1
temasLista.Parent = rightPanel
temasLista.Visible = false

local temaBotoes = {}
local temasOpcoes = {"🔵 Azul", "🟢 Verde", "🔴 Vermelho", "🟡 Amarelo", "💗 Rosa", "🟣 Roxo"}

for i, tema in ipairs(temasOpcoes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0.05 + (i-1)*0.08, 0)
    btn.BackgroundColor3 = tema == temaAtual and Color3.fromRGB(0, 150, 0) or coresTemas[tema].botao
    btn.Text = tema
    btn.TextColor3 = coresTemas[tema].texto
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = temasLista
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        temaAtual = tema
        for _, b in pairs(temaBotoes) do
            b.BackgroundColor3 = coresTemas[b.Text].botao
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        aplicarTema(tema)
    end)
    
    table.insert(temaBotoes, btn)
end

local btnVoltarTemas = Instance.new("TextButton")
btnVoltarTemas.Size = UDim2.new(0.9, 0, 0, 25)
btnVoltarTemas.Position = UDim2.new(0.05, 0, 0.55, 0)
btnVoltarTemas.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnVoltarTemas.Text = textos[idiomaAtual].voltar
btnVoltarTemas.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVoltarTemas.TextSize = 11
btnVoltarTemas.Font = Enum.Font.GothamBold
btnVoltarTemas.Parent = temasLista
Instance.new("UICorner", btnVoltarTemas).CornerRadius = UDim.new(0, 4)

btnVoltarTemas.MouseButton1Click:Connect(function()
    temasLista.Visible = false
    configLista.Visible = true
    mostrandoTemas = false
    rightTitle.Text = textos[idiomaAtual].configTitulo
end)

-- FUNÇÃO PARA CRIAR BOTÕES DO PLAYER
function criarBotoesPlayer()
    for _, child in pairs(playerLista:GetChildren()) do child:Destroy() end
    
    local functions = {
        {nome = textos[idiomaAtual].velocidadeNome, var = "Velocidade"},
        {nome = textos[idiomaAtual].invisivelNome, var = "Invisivel"},
        {nome = textos[idiomaAtual].superPuloNome, var = "SuperPulo"},
        {nome = textos[idiomaAtual].escudoNome, var = "Escudo"},
        {nome = textos[idiomaAtual].visaoNoturnaNome, var = "VisaoNoturna"},
        {nome = textos[idiomaAtual].efeitosNome, var = "Efeitos"},
        {nome = textos[idiomaAtual].vooNome, var = "Voo"},
        {nome = textos[idiomaAtual].espNome, var = "Esp"},
        {nome = textos[idiomaAtual].antiAfkNome, var = "AntiAfk"},
        {nome = textos[idiomaAtual].noclipNome, var = "Noclip"},
        {nome = textos[idiomaAtual].vidaInfinitaNome, var = "VidaInfinita"},
        {nome = textos[idiomaAtual].modoAmigoNome, var = "ModoAmigo"},
        {nome = textos[idiomaAtual].antiQuedaNome, var = "AntiQueda"}
    }
    
    local yPos = 0
    for i, func in pairs(functions) do
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -10, 0, 35)
        bg.Position = UDim2.new(0, 5, 0, yPos)
        bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        bg.Parent = playerLista
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
        
        local nomeLabel = Instance.new("TextLabel")
        nomeLabel.Size = UDim2.new(0.6, -5, 1, 0)
        nomeLabel.Position = UDim2.new(0, 5, 0, 0)
        nomeLabel.BackgroundTransparency = 1
        nomeLabel.Text = func.nome
        nomeLabel.TextColor3 = coresTemas[temaAtual].texto
        nomeLabel.TextSize = 10
        nomeLabel.Font = Enum.Font.GothamBold
        nomeLabel.Parent = bg
        
        local btnToggle = Instance.new("TextButton")
        btnToggle.Size = UDim2.new(0.3, 0, 0, 25)
        btnToggle.Position = UDim2.new(0.7, 0, 0.5, -12)
        btnToggle.BackgroundColor3 = getgenv().CoringaFarm[func.var] and Color3.fromRGB(0, 150, 0) or coresTemas[temaAtual].botao
        btnToggle.Text = getgenv().CoringaFarm[func.var] and "ON" or "OFF"
        btnToggle.TextColor3 = coresTemas[temaAtual].texto
        btnToggle.TextSize = 9
        btnToggle.Font = Enum.Font.GothamBold
        btnToggle.Parent = bg
        Instance.new("UICorner", btnToggle).CornerRadius = UDim.new(0, 4)
        
        btnToggle.MouseButton1Click:Connect(function()
            getgenv().CoringaFarm[func.var] = not getgenv().CoringaFarm[func.var]
            btnToggle.BackgroundColor3 = getgenv().CoringaFarm[func.var] and Color3.fromRGB(0, 150, 0) or coresTemas[temaAtual].botao
            btnToggle.Text = getgenv().CoringaFarm[func.var] and "ON" or "OFF"
            
            if func.var == "Velocidade" then velocidadeLoop()
            elseif func.var == "Invisivel" then invisivelLoop()
            elseif func.var == "SuperPulo" then superPuloLoop()
            elseif func.var == "Escudo" then escudoLoop()
            elseif func.var == "VisaoNoturna" then visaoNoturnaLoop()
            elseif func.var == "Efeitos" then efeitoUnicoLoop()
            elseif func.var == "Voo" then 
                if getgenv().CoringaFarm.Voo then criarBotoesVoo(); vooLoop() else destruirBotoesVoo() end
            elseif func.var == "Esp" then espLoop()
            elseif func.var == "AntiAfk" then antiAfkLoop()
            elseif func.var == "Noclip" then noclipLoop()
            elseif func.var == "VidaInfinita" then vidaInfinitaLoop()
            elseif func.var == "ModoAmigo" then modoAmigoLoop()
            elseif func.var == "AntiQueda" then antiQuedaLoop()
            end
        end)
        
        yPos = yPos + 40
    end
    playerLista.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- FUNÇÕES DE ATUALIZAÇÃO
function atualizarListaJogadores()
    for _, child in pairs(jogadoresLista:GetChildren()) do child:Destroy() end
    
    local yPos = 0
    for _, info in pairs(jogadoresProximos) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = coresTemas[temaAtual].botao
        btn.Text = info.player.Name .. " | " .. math.floor(info.dist) .. "m"
        btn.TextColor3 = coresTemas[temaAtual].texto
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.Parent = jogadoresLista
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            jogadorSelecionado = info.player
            jogadoresLista.Visible = false
            opcoesLista.Visible = true
            mostrandoJogadores = false
            mostrandoOpcoesJogador = true
            rightTitle.Text = info.player.Name
        end)
        yPos = yPos + 30
    end
    jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

function atualizarUI()
    statusLabel.Text = farmAtivo and "🟢" or "⚪"
    statusLabel.TextColor3 = farmAtivo and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    ouroLabel.Text = "💰" .. ouroTotal
    timerLabel.Text = "⏱️" .. temporizador .. "s"
end

function atualizarIdioma()
    title.Text = textos[idiomaAtual].titulo
    btnIniciar.Text = farmAtivo and textos[idiomaAtual].pausar or textos[idiomaAtual].iniciar
    btnVelocidade.Text = textos[idiomaAtual].velocidade
    btnPlayer.Text = mostrandoPlayers and textos[idiomaAtual].fecharPlayer or textos[idiomaAtual].player
    btnConfig.Text = mostrandoConfig and textos[idiomaAtual].fecharConfig or textos[idiomaAtual].config
    btnIdioma.Text = textos[idiomaAtual].idioma
    btnTemas.Text = textos[idiomaAtual].temas
    
    if mostrandoOpcoesJogador and jogadorSelecionado then
        rightTitle.Text = jogadorSelecionado.Name
    elseif mostrandoPlayers then
        rightTitle.Text = textos[idiomaAtual].playerTitulo
    elseif mostrandoConfig then
        rightTitle.Text = textos[idiomaAtual].configTitulo
    elseif mostrandoIdioma then
        rightTitle.Text = textos[idiomaAtual].idiomaTitulo
    elseif mostrandoTemas then
        rightTitle.Text = textos[idiomaAtual].temasTitulo
    else
        rightTitle.Text = textos[idiomaAtual].jogadores
    end
    
    btnEspiar.Text = textos[idiomaAtual].espiar
    btnTP.Text = textos[idiomaAtual].teleportar
    btnVoltarIdioma.Text = textos[idiomaAtual].voltar
    btnVoltarTemas.Text = textos[idiomaAtual].voltar
    
    criarBotoesPlayer()
end

function minimizarMenu()
    menuMinimizado = not menuMinimizado
    TweenService:Create(frame, TweenInfo.new(0.2), {Size = menuMinimizado and tamanhoMinimizado or tamanhoOriginal}):Play()
    if menuMinimizado then
        botaoFlutuante.Visible = true
        btnMinimizar.Text = "⬜"
    else
        botaoFlutuante.Visible = false
        btnMinimizar.Text = "➖"
    end
end

-- CONEXÕES DOS BOTÕES
botaoFlutuante.MouseButton1Click:Connect(minimizarMenu)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().CoringaFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and textos[idiomaAtual].pausar or textos[idiomaAtual].iniciar
    runAtual = 1
    atualizarUI()
    if farmAtivo then spawn(iniciarFarmOriginal) end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().CoringaFarm.Teleport == 2 then
        getgenv().CoringaFarm.Teleport = 0.5
        btnVelocidade.Text = textos[idiomaAtual].velRapida
    elseif getgenv().CoringaFarm.Teleport == 0.5 then
        getgenv().CoringaFarm.Teleport = 3
        btnVelocidade.Text = textos[idiomaAtual].velLenta
    else
        getgenv().CoringaFarm.Teleport = 2
        btnVelocidade.Text = textos[idiomaAtual].velocidade
    end
end)

btnPlayer.MouseButton1Click:Connect(function()
    if mostrandoOpcoesJogador then opcoesLista.Visible = false; mostrandoOpcoesJogador = false end
    if mostrandoPlayers then
        mostrandoPlayers = false
        mostrandoConfig = false
        mostrandoIdioma = false
        mostrandoTemas = false
        mostrandoJogadores = true
        jogadoresLista.Visible = true
        playerLista.Visible = false
        configLista.Visible = false
        idiomaLista.Visible = false
        temasLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].jogadores
        btnPlayer.Text = textos[idiomaAtual].player
        btnConfig.Text = textos[idiomaAtual].config
        verJogadoresProximos()
    else
        mostrandoPlayers = true
        mostrandoConfig = false
        mostrandoIdioma = false
        mostrandoTemas = false
        mostrandoJogadores = false
        jogadoresLista.Visible = false
        playerLista.Visible = true
        configLista.Visible = false
        idiomaLista.Visible = false
        temasLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].playerTitulo
        btnPlayer.Text = textos[idiomaAtual].fecharPlayer
        btnConfig.Text = textos[idiomaAtual].config
    end
end)

btnConfig.MouseButton1Click:Connect(function()
    if mostrandoOpcoesJogador then opcoesLista.Visible = false; mostrandoOpcoesJogador = false end
    if mostrandoConfig then
        mostrandoConfig = false
        mostrandoIdioma = false
        mostrandoTemas = false
        mostrandoPlayers = false
        mostrandoJogadores = true
        jogadoresLista.Visible = true
        configLista.Visible = false
        idiomaLista.Visible = false
        temasLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].jogadores
        btnConfig.Text = textos[idiomaAtual].config
        btnPlayer.Text = textos[idiomaAtual].player
        verJogadoresProximos()
    else
        mostrandoConfig = true
        mostrandoIdioma = false
        mostrandoTemas = false
        mostrandoPlayers = false
        mostrandoJogadores = false
        jogadoresLista.Visible = false
        configLista.Visible = true
        idiomaLista.Visible = false
        temasLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].configTitulo
        btnConfig.Text = textos[idiomaAtual].fecharConfig
        btnPlayer.Text = textos[idiomaAtual].player
    end
end)

btnIdioma.MouseButton1Click:Connect(function()
    configLista.Visible = false
    idiomaLista.Visible = true
    mostrandoIdioma = true
    mostrandoTemas = false
    rightTitle.Text = textos[idiomaAtual].idiomaTitulo
end)

btnTemas.MouseButton1Click:Connect(function()
    configLista.Visible = false
    temasLista.Visible = true
    mostrandoTemas = true
    mostrandoIdioma = false
    rightTitle.Text = textos[idiomaAtual].temasTitulo
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)
btnFechar.MouseButton1Click:Connect(function() 
    farmAtivo = false
    farmCancelado = true
    getgenv().CoringaFarm.Enabled = false 
    limparEfeitos()
    removerESP()
    destruirBotoesVoo()
    screenGui:Destroy() 
end)

spawn(function()
    while true do
        wait(1)
        if farmAtivo then temporizador = temporizador + 1 end
        atualizarUI()
    end
end)

spawn(function()
    while true do
        wait(3)
        if mostrandoJogadores then verJogadoresProximos() end
    end
end)

criarBotoesPlayer()
atualizarUI()
verJogadoresProximos()

frame.BackgroundTransparency = 1
for i = 1, 10 do
    wait(0.02)
    frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1
end