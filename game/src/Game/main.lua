
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
end

-- 読み込み
function Game:load(...)
    -- スクリーンサイズ
    self.width, self.height = love.graphics.getDimensions()

    -- エンティティマネージャ
    self.entityManager = EntityManager()

    -- ワールド
    self.world = wf.newWorld()

    -- 壁の配置
    self.walls = {}
    table.insert(self.walls, self.world:newRectangleCollider(-8, -8, self.width + 16, 8))
    table.insert(self.walls, self.world:newRectangleCollider(-8, self.height, self.width + 16, 8))
    table.insert(self.walls, self.world:newRectangleCollider(-8, -8, 8, self.height + 16))
    table.insert(self.walls, self.world:newRectangleCollider(self.width, -8, 8, self.height + 16))
    for _, wall in ipairs(self.walls) do
        wall:setType('static')
    end

    -- テスト
    for i = 1, 100 do
        self.entityManager:add(
            Boid {
                x = 8 + love.math.random(self.width - 16),
                y = 8 + love.math.random(self.height - 16),
                rotation = love.math.random() * math.pi * 2,
                radius = 8,
                world = self.world
            }
        )
    end
end

-- 更新
function Game:update(dt, ...)
    -- ワールド更新
    self.world:update(dt)

    -- エンティティ更新
    self.entityManager:update(dt)
end

-- 描画
function Game:draw(...)
    -- エンティティ描画
    self.entityManager:draw()

    -- ワールド描画
    if self.debugMode then
        self.world:draw()
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
end
