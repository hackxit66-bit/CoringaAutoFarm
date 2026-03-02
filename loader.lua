-- =============================================
-- CORINGA AUTO FARM - LOADER INTELIGENTE
-- =============================================
-- Criado por: hackxit66-bit
-- Use apenas esta linha para carregar o script
-- =============================================

-- CONFIGURAÇÕES
local repo = "hackxit66-bit"
local nomeScript = "CoringaAutoFarm"
local versaoAtual = "2.0"

-- FUNÇÃO PARA VERIFICAR VERSÃO
function verificarVersao()
    local sucesso, versaoSite = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/version.txt")
    end)
    
    if sucesso and versaoSite then
        return versaoSite:gsub("%s+", "")
    end
    return nil
end

-- FUNÇÃO PARA BAIXAR O SCRIPT
function baixarScript()
    local sucesso, script = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/script.lua")
    end)
    
    if sucesso and script then
        return script
    end
    return nil
end

-- FUNÇÃO PARA LIMPAR CACHE
function limparCache()
    if getgenv().TreasureAutoFarm then
        getgenv().TreasureAutoFarm = nil
    end
end

-- =============================================
-- SISTEMA PRINCIPAL
-- =============================================

print("⚡ CORINGA AUTO FARM - LOADER")
print("================================")

-- PASSO 1: Limpar cache
print("🧹 Limpando cache...")
limparCache()
wait(0.5)

-- PASSO 2: Verificar versão
print("🔍 Verificando versão...")
wait(0.5)

local versaoSite = verificarVersao()
if versaoSite then
    print("📊 Versão local: " .. versaoAtual .. " | GitHub: " .. versaoSite)
    
    if versaoSite ~= versaoAtual then
        print("⬇️ Nova versão disponível! Atualizando...")
    else
        print("✅ Versão atualizada!")
    end
else
    print("⚠️ Não foi possível verificar versão")
end

-- PASSO 3: Baixar e executar
print("📥 Baixando script...")
wait(0.5)

local scriptConteudo = baixarScript()

if scriptConteudo then
    print("🚀 Executando script principal...")
    wait(0.5)
    
    local sucesso, erro = pcall(function()
        loadstring(scriptConteudo)()
    end)
    
    if sucesso then
        print("✅ CORINGA AUTO FARM CARREGADO!")
        print("================================")
        print("📌 Versão: " .. (versaoSite or versaoAtual))
        print("💡 Use o menu na tela para controlar")
    else
        print("❌ ERRO AO CARREGAR:")
        print(tostring(erro))
        print("================================")
        print("🔧 Soluções:")
        print("1. Verifique sua conexão")
        print("2. Tente novamente em alguns segundos")
        print("3. Se o erro persistir, contate o suporte")
    end
else
    print("❌ FALHA AO BAIXAR O SCRIPT")
    print("================================")
    print("🔧 Verifique:")
    print("• Sua conexão com a internet")
    print("• Se o GitHub está acessível")
    print("• Se o link do script está correto")
end

print("================================")
