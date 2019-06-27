
local class = require 'middleclass'
local lume = require 'lume'

-- 基底クラス
local Entity = require 'Entity'

-- ボイド クラス
local Boid = class('Boid', Entity)
Boid:include(require 'Transform')
Boid:include(require 'Collider')

local function isNaN(n)
    return type(n) == 'number' and (n ~= n)
end

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
    local neighborhoods = self:getNeighborhoods()

    -- 周囲の壁を取得
    local walls = self:getWalls()

    -- 壁かボイドがいれば、向きを変える
    if (#neighborhoods + #walls) > 0 then
        local x, y = lume.vector(self.rotation, 1)
        do
            local s = 1--self.rule.separation
            local lx, ly = self:calcSeparation(walls)
            if isNaN(lx) or isNaN(ly) then
                -- TODO: NaN の原因を探す
                --print('calcSeparation walls', lx, ly)
            else
                x, y = x + lx * s, y + ly * s
            end
        end
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
        if isNaN(x) or isNaN(y) then
            -- 数値が NaN になったらスキップ
        elseif x ~= 0 or y ~= 0 then

            self.rotation = lume.angle(self.x, self.y, self.x + x, self.y + y)
        end
    end
end

-- 近くのボイドを探す
function Boid:getNeighborhoods()
    local neighborhoods = {}
    local colliders = self.world:queryCircleArea(self.x, self.y, self.view, { 'Boid' })
    for _, collider in ipairs(colliders) do
        if collider == self.collider then
            -- 自分は除く
        else
            table.insert(neighborhoods, collider:getObject())
        end
    end
    return neighborhoods
end

-- 近くの壁を探す
function Boid:getWalls()
    local walls = {}

    -- コールバック
    local callback = function (fixture, x, y, xn, yn, fraction)
        if not fixture:isSensor() then
            local collider = fixture:getUserData()
            if collider and collider.collision_class == 'Wall' then
                table.insert(walls, { x = x, y = y, collider = fixture:getUserData() })
            end
        end
        return 1
    end

    -- 近傍
    local neighborhoods = {
        {  1,  0 },
        {  0,  1 },
        {  1,  1 },
        {  1, -1 },
        { -1,  0 },
        {  0, -1 },
        {  1, -1 },
        { -1, -1 },
    }

    -- レイキャスト
    for _, n in ipairs(neighborhoods) do
        self.world:rayCast(self.x, self.y, self.x + self.view * n[1], self.y + self.view * n[2], callback)
    end

    return walls
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
