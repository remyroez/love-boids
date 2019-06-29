
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ライブラリ
local wf = require 'windfield'

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Application = require 'Application'
local EntityManager = require 'EntityManager'
local Boid = require 'Boid'

-- 初期化
function Game:initialize(...)
    Application.initialize(self, ...)
    self:initializeDebug(...)
end

-- 読み込み
function Game:load(...)
    -- スクリーンサイズ
    self.width, self.height = love.graphics.getDimensions()

    -- エンティティマネージャ
    self.entityManager = EntityManager()

    -- ワールド
    self.world = wf.newWorld()
    self.world:addCollisionClass('Wall')
    self.world:addCollisionClass('Boid')

    -- 壁の配置
    self.walls = {}
    self.fieldWidth, self.fieldHeight = 0, 0
    self:resetWall()

    -- ルール
    self.rule = {
        separation = 0.28,
        alignment = 0.25,
        cohesion = 0.25,
    }

    -- ボイド配置
    self.numBoids = 0
    self:resetBoids(100)

    -- 移動モード
    self.move = false
    self.moveOrigin = { x = 0, y = 0 }
    self.offsetOrigin = { x = 0, y = 0 }
    self.offset = { x = 0, y = 0 }
    self:setOffset()

    -- フォーカス
    self.focus = false

    -- ポーズ
    self.pause = false

    -- デバッグロード
    self:loadDebug(...)
end

-- 更新
function Game:update(dt, ...)
    if self.pause then
        -- ポーズ中
    else
        -- ワールド更新
        self.world:update(dt)

        -- エンティティ更新
        self.entityManager:update(dt)

        -- マウス操作
        self:mouseControl()
    end

    -- デバッグ更新
    if self.debugMode then
        self:updateDebug(dt)
    end
end

-- 描画
function Game:draw(...)
    love.graphics.push()
    do
        love.graphics.translate(self.offset.x, self.offset.y)

        -- エンティティ描画
        self.entityManager:draw()

        -- ワールド描画
        --self.world:draw()
        love.graphics.rectangle('line', 0, 0, self.fieldWidth, self.fieldHeight)
    end
    love.graphics.pop()

    -- デバッグ描画
    if self.debugMode then
        self:drawDebug()
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- キー離した
function Game:keyreleased(key, scancode)
end

-- テキスト入力
function Game:textinput(text)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end

-- マウス離した
function Game:mousereleased(x, y, button, istouch, presses)
end

-- マウス移動
function Game:mousemoved(x, y, dx, dy, istouch)
end

-- マウスホイール
function Game:wheelmoved(x, y)
end

-- リサイズ
function Game:resize(width, height)
    self.width, self.height = width, height
    self:setOffset()
end

-- ボイドの配置
function Game:resetBoids(num)
    num = num or 100

    -- エンティティクリア
    self.entityManager:clear()

    -- ボイド生成
    for i = 1, num do
        local entity = self.entityManager:add(
            Boid {
                x = 8 + love.math.random(self.fieldWidth - 16),
                y = 8 + love.math.random(self.fieldHeight - 16),
                rotation = love.math.random() * math.pi * 2,
                radius = 8,
                world = self.world,
                rule = self.rule,
                isCull = function (boid, x, y)
                    return not self:isView(x - boid.radius, y - boid.radius, x + boid.radius, y + boid.radius)
                end
            }
        )
        entity.collider:setCollisionClass('Boid')
    end

    self.numBoids = num
end

-- 壁のリセット
function Game:resetWall(width, height)
    width, height = width or self.width, height or self.height

    -- 既存の壁の破棄
    for _, wall in ipairs(self.walls) do
        wall:destroy()
    end

    -- 壁の作成
    self.walls = {}
    table.insert(self.walls, self.world:newRectangleCollider(-8, -8, width + 16, 8))
    table.insert(self.walls, self.world:newRectangleCollider(-8, height, width + 16, 8))
    table.insert(self.walls, self.world:newRectangleCollider(-8, -8, 8, height + 16))
    table.insert(self.walls, self.world:newRectangleCollider(width, -8, 8, height + 16))
    for _, wall in ipairs(self.walls) do
        wall:setType('static')
        wall:setCollisionClass('Wall')
    end

    self.fieldWidth, self.fieldHeight = width, height
end

-- マウス操作
function Game:mouseControl()
    if not self.focus then
        -- マウスカーソルがＧＵＩに乗っている
    elseif love.mouse.isDown(1) then
        -- クリック
        if not self.move then
            -- 移動モード開始
            self.move = true
            self.moveOrigin.x, self.moveOrigin.y = love.mouse.getPosition()
            self.offsetOrigin.x, self.offsetOrigin.y = self.offset.x, self.offset.y
        else
            -- 移動中
            local x, y = love.mouse.getPosition()
            self:setOffset(self.offsetOrigin.x + x - self.moveOrigin.x, self.offsetOrigin.y + y - self.moveOrigin.y)
        end
    else
        if self.move then
            -- 移動モード終了
            self.move = false
        end
    end
end

-- オフセットの設定
function Game:setOffset(x, y)
    self.offset.x = x or self.offset.x
    self.offset.y = y or self.offset.y
    self:setViewport(-self.offset.x, -self.offset.y, self.width, self.height)
end

-- 表示領域
function Game:setViewport(x, y, w, h)
    local sw, sh = love.graphics.getDimensions()

    self.viewport = self.viewport or {}
    self.viewport.left = x or 0
    self.viewport.top = y or 0
    self.viewport.right = self.viewport.left + (w or sw)
    self.viewport.bottom = self.viewport.top + (h or sh)
end

-- 指定した矩形が表示できるかどうか
function Game:isView(left, top, right, bottom)
    local left = left or 0
    local top = top or 0
    local right = right or left
    local bottom = bottom or top

    return (right > self.viewport.left)
        and (bottom > self.viewport.top)
        and (left < self.viewport.right)
        and (top < self.viewport.bottom)
end
