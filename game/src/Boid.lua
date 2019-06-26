
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
    self.speed = t.speed or 100
    self.radius = t.radius or 1
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
    -- コライダーの位置を取得して適用
    self:applyPositionFromCollider()

    -- 前進
    local x, y = lume.vector(self.rotation, 1)
    self:setColliderVelocity(x, y, self.speed)
end

-- 描画
function Boid:draw()
end

return Boid