-- roBa のキーマップ図を画面に重ねて表示する (見ながら打てるように、前面のアプリのフォーカスは奪わない)
-- roBa の ' + : 同時押しが ⌃⌥⇧⌘ + レイヤー番号 (0〜6) を送る。どのレイヤーで押しても同じ動き。
--   押すたびに 右側に全部 → 上部に F キー・基本・数字 (基本が真ん中) → 消す を繰り返す。
-- roBa の V + : 同時押しが ⌃⌥⇧⌘D を送る。全レイヤーの詳しい図を画面いっぱいに出す (もう一度押すと消える)。
--   二つの表示は重ねず、表示中にもう一方を押すとそちらに切り替わる。

local HYPER = { "ctrl", "alt", "shift", "cmd" }
local PAGE = "file://" .. os.getenv("HOME") .. "/Documents/roba/keymap-overlay/keymap.html"
local RIGHT_CARDS = 8 -- 図の #overlay に並ぶカードの数 (レイヤーが増減したら合わせる)
local TOP_CARDS = 3
local MARGIN = 8
local GAP = 6
local CARD_PADDING = 6
local RIGHT_MAX_WIDTH = 520
local TOP_MAX_WIDTH = 460
local BOARD_RATIO = 5.05 / 13.6

local view = nil
local state = "hidden"

local function cardHeight(w)
  return (w - CARD_PADDING * 2) * BOARD_RATIO + CARD_PADDING * 2
end

-- 全カードが画面の高さに収まる幅にして、右端に寄せる
local function rightFrame(f)
  local maxH = (f.h - MARGIN * 2 - GAP * (RIGHT_CARDS - 1)) / RIGHT_CARDS
  local w = math.min((maxH - CARD_PADDING * 2) / BOARD_RATIO + CARD_PADDING * 2, RIGHT_MAX_WIDTH)
  local h = cardHeight(w) * RIGHT_CARDS + GAP * (RIGHT_CARDS - 1)
  return hs.geometry.rect(f.x + f.w - w - MARGIN, f.y + MARGIN, w, h)
end

-- カードを横に並べて、上部の中央に置く
local function topFrame(f)
  local cardW = math.min((f.w - MARGIN * 2 - GAP * (TOP_CARDS - 1)) / TOP_CARDS, TOP_MAX_WIDTH)
  local w = cardW * TOP_CARDS + GAP * (TOP_CARDS - 1)
  return hs.geometry.rect(f.x + (f.w - w) / 2, f.y + MARGIN, w, cardHeight(cardW))
end

local FRAMES = { right = rightFrame, top = topFrame, full = function(f) return f end }
local HASHES = { right = "#overlay", top = "#overlay=top", full = "#overlay=full" }

local function hide()
  if view then view:hide() end
  state = "hidden"
end

local function show(newState)
  local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
  local frame = FRAMES[newState](screen:frame())
  if not view then
    view = hs.webview.new(frame)
      :windowStyle({ "borderless" })
      :level(hs.drawing.windowLevels.overlay)
      :behavior(hs.drawing.windowBehaviors.canJoinAllSpaces + hs.drawing.windowBehaviors.fullScreenAuxiliary)
      :transparent(true)
      :shadow(false)
      :allowTextEntry(false)
  else
    view:frame(frame)
  end
  view:url(PAGE .. HASHES[newState])
  view:show()
  state = newState
end

-- ' + : の切り替え。詳しい図を出しているときは、右側の表示から始める
local function cycle()
  if state == "right" then
    show("top")
  elseif state == "top" then
    hide()
  else
    show("right")
  end
end

-- V + : の詳しい図
local function toggleFull()
  if state == "full" then hide() else show("full") end
end

for layer = 0, 6 do
  hs.hotkey.bind(HYPER, tostring(layer), cycle)
end
hs.hotkey.bind(HYPER, "d", toggleFull)

-- キーボードなしで確かめるための入口: open -g "hammerspoon://roba-keymap" / "hammerspoon://roba-keymap-full"
hs.urlevent.bind("roba-keymap", cycle)
hs.urlevent.bind("roba-keymap-full", toggleFull)
