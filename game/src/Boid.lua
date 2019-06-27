
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
    self.view = t.view or 50
    self.speed = t.speed or 100
    self.radius = t.radius or 1
    self.world = t.world or {}

    self.rule = t.rule or {}
    self.rule.separation = self.rule.separation or 0.5
    self.rule.alignment = self.rule.alignment or 0.5
    self.rule.cohesion = self.rule.cohesion or 0.5

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
    do
        local x, y = lume.vector(self.rotation, 1)
        self:setColliderVelocity(x, y, self.speed)
    end

    -- 周囲のボイドを取得
    local neighborhoods = {}
    local colliders = self.world:queryCircleArea(self.x, self.y, self.view, { 'Boid' })
    for _, collider in ipairs(colliders) do
        if collider == self.collider then
            -- 自分は除く
        else
            table.insert(neighborhoods, collider:getObject())
        end
    end

    -- ボイドがいれば、向きを変える
    if #neighborhoods > 0 then
        local x, y = lume.vector(self.rotation, 1)
        do
            local s = self.rule.separation
            local lx, ly = self:calcSeparation(neighborhoods)
            x, y = x + lx * s, y + ly * s
        end
        do
            local s = self.rule.alignment
            local lx, ly = self:calcAlignment(neighborhoods)
            x, y = x + lx * s, y + ly * s
        end
        do
            local s = self.rule.cohesion
            local lx, ly = self:calcCohesion(neighborhoods)
            x, y = x + lx * s, y + ly * s
        end
        if self.x ~= 0 or self.y ~= 0 then
            self.rotation = lume.angle(self.x, self.y, self.x + x, self.y + y)
        end
    end
end

-- 分離
function Boid:calcSeparation(neighborhoods)
    local x, y = 0, 0

    for _, neighborhood in ipairs(neighborhoods) do
        local nx, ny = lume.vector(lume.angle(self.x, self.y, neighborhood.x, neighborhood.y), 1)
        x, y = x + nx, y + ny
    end

    local dist = lume.distance(x, y, 0, 0)

    return -x / dist, -y / dist
end

-- 整列
function Boid:calcAlignment(neighborhoods)
    local x, y = 0, 0

    for _, neighborhood in ipairs(neighborhoods) do
        local nx, ny = lume.vector(neighborhood.rotation, 1)
        x, y = x + nx, y + ny
    end

    local dist = lume.distance(x, y, 0, 0)

    return x / dist, y / dist
end

-- 結合
function Boid:calcCohesion(neighborhoods)
    local x, y = 0, 0

    for _, neighborhood in ipairs(neighborhoods) do
        x, y = x + neighborhood.x, y + neighborhood.y
    end

    x, y = x / #neighborhoods, y / #neighborhoods

    return lume.vector(lume.angle(self.x, self.y, x, y), 1)
end

-- 描画
function Boid:draw()
end

return Boid
