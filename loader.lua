-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hackxit66-bit/CoringaAutoFarm/main/loader.lua"))()

local repo = "hackxit66-bit"
local nomeScript = "CoringaAutoFarm"
local versaoAtual = "2.0"

function verificarVersao()
    local sucesso, versaoSite = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/version.txt")
    end)
    
    if sucesso and versaoSite then
        return versaoSite:gsub("%s+", "")
    end
    return nil
end

function baixarScript()
    local sucesso, script = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/script.lua")
    end)
    
    if sucesso and type(script) == "string" and script:match("%S") then
        return script
    end
    return nil, sucesso and "resposta vazia ou inválida" or tostring(script)
end

function limparCache()
    if getgenv().TreasureAutoFarm then
        getgenv().TreasureAutoFarm = nil
    end
end

limparCache()
wait(0.5)

local versaoSite = verificarVersao()
if versaoSite and versaoSite ~= versaoAtual then
    
end

wait(0.5)

local scriptConteudo, erroDownload = baixarScript()

if scriptConteudo then
    wait(0.5)
    
    local sucesso, erro = pcall(function()
        local executar, erroCompilacao = loadstring(scriptConteudo)
        if not executar then
            error("erro ao compilar: " .. tostring(erroCompilacao))
        end
        executar()
    end)
    
    if not sucesso then
        warn("[CoringaAutoFarm] Falha ao executar o script: " .. tostring(erro))
    end
else
    warn("[CoringaAutoFarm] Falha ao baixar o script: " .. tostring(erroDownload))
end
