LARGURA = 320
ALTURA = 480

MAX_METEORO = 12
FIM_DE_JOGO = false
METEOROS_ATINGIDOS = 0

aviao = {
    src = "imagens/14bis.png",
    largura = 55,
    altura = 64,
    x = LARGURA / 2 - 32,
    y = ALTURA - 128,
    tiros = {}
}

meteoros = {}

function daTiro()
    musica_disparo:play()
    local tiro = {
        x = aviao.x + aviao.largura / 2 - 4,
        y = aviao.y,
        largura = 16,
        altura = 16,
    }

    table.insert(aviao.tiros, tiro)
end

function moveTiros()
    for i = #aviao.tiros, 1, -1 do
        if aviao.tiros[i].y > 0 then
            aviao.tiros[i].y = aviao.tiros[i].y - 2
        else 
            table.remove(aviao.tiros, i)
        end
    end
end

function trocaMusicaDeFundo()
    musica_ambiente:stop()
    musica_game_over:play()
end

function temColisao(X1, Y1, L1, A1, X2, Y2, L2, A2)
    return  X2 < X1 + L1 and
            X1 < X2 + L2 and
            Y1 < Y2 + A2 and
            Y2 < Y1 + A1
end

function checkColisaoAviao()
    for k, meteoro in pairs(meteoros) do
        if temColisao(meteoro.x, meteoro.y, meteoro.largura, meteoro.altura, aviao.x, aviao.y, aviao.altura, aviao.largura) then
            trocaMusicaDeFundo()
           destroyAviao()
           FIM_DE_JOGO = true
        end
    end
end

function checkColisaoTiros()
    for i = #aviao.tiros, 1, -1 do
        for j = #meteoros, 1, -1 do
            if temColisao(aviao.tiros[i].x, aviao.tiros[i].y, aviao.tiros[i].largura, aviao.tiros[i].altura, meteoros[j].x, meteoros[j].y, meteoros[j].largura, meteoros[j].altura) then
                METEOROS_ATINGIDOS = METEOROS_ATINGIDOS + 1
                table.remove(aviao.tiros, i)
                table.remove(meteoros, j)
                break
            end            
        end
    end
end

function checkColisao()
    checkColisaoAviao()
    checkColisaoTiros()
end

function checkObjetivo()
    if METEOROS_ATINGIDOS >= 100 then
        musica_ambiente:stop()
        VENCEDOR = true
        musica_vencedor:play()
    end
end

function destroyAviao()

    musica_destruicao:play()
    aviao.src = "imagens/explosao_nave.png"
    aviao.imagem = love.graphics.newImage(aviao.src)
    aviao.largura = 67
    aviao.altura = 77  

end

function criaMeteoro()
    meteoro = {
        x = math.random(LARGURA),
        y = -64,
        largura = 50,
        altura = 44,
        speedX = math.random(3),
        speedY = math.random(-1, 1)
    }
    table.insert(meteoros, meteoro)
end

function moveMeteoros()
    for k,meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.speedX
        meteoro.x = meteoro.x + meteoro.speedY
    end
end

function removeMeteoros()
    for i = #meteoros, 1, -1 do
        if meteoros[i].y > ALTURA then
            table.remove(meteoros, i)
        end
    end
end

function moveAviao()
    if love.keyboard.isDown('w') then
        aviao.y = aviao.y - 1
    end

    if love.keyboard.isDown('s') then
        aviao.y = aviao.y + 1
    end

    if love.keyboard.isDown('a') then
        aviao.x = aviao.x - 1
    end

    if love.keyboard.isDown('d') then
        aviao.x = aviao.x + 1
    end
end

function love.load()
    love.window.setMode(LARGURA, ALTURA, {resizable = false})
    love.window.setTitle("14bits")

    math.randomseed(os.time())

    --images

    background = love.graphics.newImage('imagens/background.png')
    aviao.imagem = love.graphics.newImage(aviao.src)
    tiro_img = love.graphics.newImage("imagens/tiro.png")
    meteoro_img = love.graphics.newImage('imagens/meteoro.png')
    game_over_img = love.graphics.newImage('imagens/gameover.png')
    game_win_img = love.graphics.newImage('imagens/vencedor.png')

    -- audios

    musica_ambiente = love.audio.newSource("audios/ambiente.wav", 'static')
    musica_ambiente:setLooping(true)
    musica_ambiente:play()
    musica_destruicao = love.audio.newSource("audios/destruicao.wav", 'static')
    musica_game_over = love.audio.newSource("audios/game_over.wav", 'static')
    musica_disparo = love.audio.newSource("audios/disparo.wav", "static")
    musica_vencedor = love.audio.newSource("audios/winner.wav", "static")

end

function love.update(dt)
    if not FIM_DE_JOGO and not VENCEDOR then
        if love.keyboard.isDown('w', 'a', 's', 'd') then
            moveAviao()
        end

        removeMeteoros()
        if #meteoros < MAX_METEORO then
            criaMeteoro()
        end
        moveMeteoros()
        moveTiros()
        checkColisao()
        checkObjetivo()
    end
    
end

function love.draw()

    love.graphics.draw(background, 0, 0)

    love.graphics.draw(aviao.imagem, aviao.x, aviao.y)

    for k,meteoro in pairs(meteoros) do
        love.graphics.draw(meteoro_img, meteoro.x, meteoro.y)
    end

    for k,tiro in pairs(aviao.tiros) do
        love.graphics.draw(tiro_img, tiro.x, tiro.y)
    end

    if FIM_DE_JOGO then
        love.graphics.draw(game_over_img, LARGURA / 2 - game_over_img:getWidth() / 2, ALTURA / 2 - game_over_img:getHeight() / 2)
    end
    
    if VENCEDOR then
        love.graphics.draw(game_win_img, LARGURA / 2 - game_win_img:getWidth() / 2, ALTURA / 2 - game_win_img:getHeight() / 2)
    end

    love.graphics.print("Meteoros restantes "..METEOROS_ATINGIDOS, 0, 0)
end

function love.keypressed(tecla)
    if tecla == "escape" then
        love.event.quit()
    elseif tecla == "space" then
        daTiro()
    end
end