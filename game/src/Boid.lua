
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- ボイド クラス
local Boid = class('Boid', Entity)
Boid:include(require 'Transform')
Boid:include(require 'Collider')

-- 初期化
function Boid:initialize(t)
    t = t or {}

    -- 基底クラス初期化
    Entity.initialize(self)

    -- プロパティ
    self.radius = t.radius or 16
    self.world = t.world or {}

    -- Transform 初期化
    self:initializeTransform(t.x, t.y, t.rotation)

    -- Collider 初期化
    self:initializeCollider(t.collider or lume.call(self.world.newCircleCollider, self.world, 0, 0, self.radius))
end

-- 破棄
function Boid:destroy()
end

-- 更新
function Boid:update(dt)
end

-- 描画
function Boid:draw()
end

return Boid
