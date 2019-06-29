
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Slab = require 'Slab'

-- スペーサー
local function spacer(w, h)
    local x, y = Slab.GetCursorPos()
    Slab.Button('', { Invisible = true, W = w, H = h })
    Slab.SetCursorPos(x, y)
end

-- 入力欄
local function input(t, name, label)
    local changed = false

    Slab.BeginColumn(1)
    Slab.Text(label or name or '')
    Slab.EndColumn()

    Slab.BeginColumn(2)
	local ww, wh = Slab.GetWindowActiveSize()
    local h = Slab.GetStyle().Font:getHeight()
    if Slab.Input(name, { Text = tostring(t[name]), ReturnOnText = false, W = ww, H = h }) then
        t[name] = Slab.GetInputText()
        changed = true
    end
    Slab.EndColumn()

    return changed
end

-- 初期化
function Game:initializeDebug(...)
    love.keyboard.setKeyRepeat(true)
    Slab.Initialize()
end

-- 読み込み
function Game:loadDebug(...)
end

-- 更新
function Game:updateDebug(dt, ...)
    -- Slab 更新
    Slab.Update(dt)

    -- ルールウィンドウ
    self:ruleWindow()

    self.focus = Slab.IsVoidHovered()
end

-- 描画
function Game:drawDebug(...)
    Slab.Draw()
end

-- ルールウィンドウ
function Game:ruleWindow()

    Slab.BeginWindow(
        'Rule',
        {
            Title = 'Rule',
            Columns = 2,
        }
    )
    spacer(300)

    if input(self.rule, 'separation', 'Separation') then
        self.rule.separation = math.max(0, math.min(self.rule.separation, 1))
    end
    if input(self.rule, 'alignment', 'Alignment') then
        self.rule.alignment = math.max(0, math.min(self.rule.alignment, 1))
    end
    if input(self.rule, 'cohesion', 'Cohesion') then
        self.rule.cohesion = math.max(0, math.min(self.rule.cohesion, 1))
    end

    Slab.EndWindow()
end
