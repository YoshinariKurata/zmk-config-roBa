-- roBa のキーマップ図を画面に重ねて表示する (見ながら打てるように、前面のアプリのフォーカスは奪わない)
-- roBa の ' + : 同時押しが ⌃⌥⇧⌘ + レイヤー番号 (0〜6) を送る。どのレイヤーで押しても同じ動き。
--   押すたびに 上部 → 下部 → 消す を繰り返す。どちらも 記号・基本・数字 の3枚を横に並べて中央に置く (基本が真ん中)。
-- roBa の V + : 同時押しが ⌃⌥⇧⌘D を送る。全レイヤーの詳しい図を画面いっぱいに出す (もう一度押すと消える)。
--   二つの表示は重ねず、表示中にもう一方を押すとそちらに切り替わる。

local HYPER = { "ctrl", "alt", "shift", "cmd" }
local PAGE = "file://" .. os.getenv("HOME") .. "/Documents/roba/keymap-overlay/keymap.html"
local STRIP_CARDS = 3
local MARGIN = 8
local GAP = 6
local CARD_PADDING = 6
local CARD_MAX_WIDTH = 460
local BOARD_RATIO = 5.05 / 13.6

local view = nil
local state = "hidden"

local function cardHeight(w)
  return (w - CARD_PADDING * 2) * BOARD_RATIO + CARD_PADDING * 2
end

-- カードを横に並べて、画面の中央に置く。atBottom なら下端、そうでなければ上端に寄せる
local function stripFrame(f, atBottom)
  local cardW = math.min((f.w - MARGIN * 2 - GAP * (STRIP_CARDS - 1)) / STRIP_CARDS, CARD_MAX_WIDTH)
  local w = cardW * STRIP_CARDS + GAP * (STRIP_CARDS - 1)
  local h = cardHeight(cardW)
  local y = atBottom and (f.y + f.h - h - MARGIN) or (f.y + MARGIN)
  return hs.geometry.rect(f.x + (f.w - w) / 2, y, w, h)
end

local FRAMES = {
  top = function(f) return stripFrame(f, false) end,
  bottom = function(f) return stripFrame(f, true) end,
  full = function(f) return f end,
}
local HASHES = { top = "#overlay=top", bottom = "#overlay=top", full = "#overlay=full" }

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

-- ' + : の切り替え。詳しい図を出しているときは、上部の表示から始める
local function cycle()
  if state == "top" then
    show("bottom")
  elseif state == "bottom" then
    hide()
  else
    show("top")
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
