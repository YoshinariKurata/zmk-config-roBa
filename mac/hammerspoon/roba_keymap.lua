-- roBa のキーマップ図を画面に重ねて表示する (見ながら打てるように、前面のアプリのフォーカスは奪わない)
-- roBa の ' + : 同時押しが ⌃⌥⇧⌘ + レイヤー番号 (0〜6) を送る。どのレイヤーで押しても同じ動き。
--   押すたびに 上部 → 下部 → 消す を繰り返す。どちらも 記号・基本・数字 の3枚を横に並べて中央に置く (基本が真ん中)。
-- roBa の V + : 同時押しが ⌃⌥⇧⌘D を送る。全レイヤーの詳しい図を画面いっぱいに出す (もう一度押すと消える)。
--   二つの表示は重ねず、表示中にもう一方を押すとそちらに切り替わる。
--
-- すぐ出るように、小さい図と全画面の図の2つの窓を起動時に読み込んで隠しておき、キーでは見せる・隠すだけにする。
-- 図はリポジトリの diagram/roba-keymap.html から作る。リポジトリは2分ごとに pull し (変更していないときだけ)、
-- 図が変わったら隠れている窓を読み直す。mac/hammerspoon の lua が変わったら Hammerspoon ごと読み直す。

local HOME = os.getenv("HOME")
local REPO = HOME .. "/Documents/roba/zmk-config-roBa"
local SRC = REPO .. "/diagram/roba-keymap.html"
local OUT_DIR = HOME .. "/Documents/roba/keymap-overlay"
local COPY = OUT_DIR .. "/keymap.html"
local SYNC_LOG = OUT_DIR .. "/sync-log.txt"
local PAGE = "file://" .. COPY
-- Hammerspoon は file:// で開くので、文字化けしないよう先頭に doctype / charset / viewport を足す
local PREFIX = '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">\n'
local PULL_EVERY = 120 -- 秒

local HYPER = { "ctrl", "alt", "shift", "cmd" }
local STRIP_CARDS = 3
local MARGIN = 8
local GAP = 6
local CARD_PADDING = 6
local CARD_MAX_WIDTH = 460
local BOARD_RATIO = 5.05 / 13.6

-- 窓や監視をグローバルに置く (ローカルだけだと捨てられて、監視が止まる)。読み直したときは前のものを片付ける
roba_overlay = roba_overlay or {}
local R = roba_overlay
for _, w in ipairs({ "diagramWatcher", "luaWatcher", "pullTimer" }) do
  if R[w] then R[w]:stop() end
end
for _, v in pairs(R.views or {}) do v:delete() end
R.views = {}
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
-- 状態ごとに使う窓 (上と下は同じ窓を動かす)
local VIEW_OF = { top = "strip", bottom = "strip", full = "full" }
local HASHES = { strip = "#overlay=top", full = "#overlay=full" }

local function currentScreenFrame()
  return (hs.mouse.getCurrentScreen() or hs.screen.mainScreen()):frame()
end

-- リポジトリの図に先頭の行を足して、Hammerspoon が開くコピーを書き出す
local function writeCopy()
  local f = io.open(SRC, "r")
  if not f then return false end
  local body = f:read("a")
  f:close()
  hs.fs.mkdir(OUT_DIR)
  local out = io.open(COPY, "w")
  if not out then return false end
  out:write(PREFIX .. body)
  out:close()
  return true
end

local function makeView(name, frame)
  local v = hs.webview.new(frame)
    :windowStyle({ "borderless" })
    :level(hs.drawing.windowLevels.overlay)
    :behavior(hs.drawing.windowBehaviors.canJoinAllSpaces + hs.drawing.windowBehaviors.fullScreenAuxiliary)
    :transparent(true)
    :shadow(false)
    :allowTextEntry(false)
  v:url(PAGE .. HASHES[name])
  return v
end

-- 隠したまま2つの窓を読み込んでおく
local function preload()
  writeCopy()
  local f = currentScreenFrame()
  R.views.strip = makeView("strip", FRAMES.top(f))
  R.views.full = makeView("full", FRAMES.full(f))
end

-- 図が変わったら、窓を作ったまま中身だけ読み直す
local function reloadViews()
  if not writeCopy() then return end
  for _, v in pairs(R.views) do v:reload(true) end
end

local function hide()
  for _, v in pairs(R.views) do v:hide() end
  state = "hidden"
end

local function show(newState)
  local name = VIEW_OF[newState]
  local v = R.views[name]
  for other, ov in pairs(R.views) do
    if other ~= name then ov:hide() end
  end
  local frame = FRAMES[newState](currentScreenFrame())
  local now = v:frame()
  if now.x ~= frame.x or now.y ~= frame.y or now.w ~= frame.w or now.h ~= frame.h then
    v:frame(frame) -- 全画面の図は、画面の大きさが変わると図の側で並べ直す
  end
  v:show()
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

-- 変更していないときだけ pull する (未コミットの変更があると飛ばす。分かれていたら --ff-only が止める)
local function log(msg)
  local f = io.open(SYNC_LOG, "w")
  if f then
    f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg .. "\n")
    f:close()
  end
end

local function pull()
  hs.task.new("/usr/bin/git", function(code, out)
    if code ~= 0 then return log("status failed") end
    if out ~= "" then return log("skipped: local changes") end
    hs.task.new("/usr/bin/git", function(c, o, e)
      log(c == 0 and ("pulled: " .. (o:match("[^\n]*") or "")) or ("pull failed: " .. (e or "")))
    end, { "-C", REPO, "pull", "--ff-only" }):start()
  end, { "-C", REPO, "status", "--porcelain", "--untracked-files=no" }):start()
end

preload()

R.diagramWatcher = hs.pathwatcher.new(REPO .. "/diagram/", function(paths)
  for _, p in ipairs(paths) do
    if p:match("roba%-keymap%.html$") then return reloadViews() end
  end
end):start()

R.luaWatcher = hs.pathwatcher.new(REPO .. "/mac/hammerspoon/", function(paths)
  for _, p in ipairs(paths) do
    if p:match("%.lua$") then return hs.timer.doAfter(0.5, hs.reload) end
  end
end):start()

R.pullTimer = hs.timer.doEvery(PULL_EVERY, pull)
hs.timer.doAfter(5, pull)

for layer = 0, 6 do
  hs.hotkey.bind(HYPER, tostring(layer), cycle)
end
hs.hotkey.bind(HYPER, "d", toggleFull)

-- キーボードなしで確かめるための入口: open -g "hammerspoon://roba-keymap" / "hammerspoon://roba-keymap-full" / "hammerspoon://roba-sync"
hs.urlevent.bind("roba-keymap", cycle)
hs.urlevent.bind("roba-keymap-full", toggleFull)
hs.urlevent.bind("roba-sync", pull)
