-- 全角の括弧をペアで入力して、カーソルを括弧の中に置く（… は1文字だけ）
-- roBa の記号レイヤーのキーが ⌃⌥⇧⌘ + 文字 を送る。
-- 日本語入力の状態に左右されないよう、クリップボード経由で貼り付けて、元のクリップボードに戻す。

local HYPER = { "ctrl", "alt", "shift", "cmd" }
local CHECK = os.getenv("HOME") .. "/Documents/roba/keymap-overlay/brackets-check.txt"

-- キー = { 入力する文字, 入力後にカーソルを左へ戻す文字数 }
local KEYS = {
  b = { "「」", 1 },
  j = { "（）", 1 },
  k = { "『』", 1 },
  l = { "［］", 1 },
  m = { "【】", 1 },
  o = { "…", 0 },
}

-- キーボードから届いた ⌃⌥⇧⌘ が離れてから入力する（押したままだと貼り付けが別のショートカットになる）
local function afterModifiersReleased(fn)
  local started = hs.timer.secondsSinceEpoch()
  hs.timer.waitUntil(function()
    return next(hs.eventtap.checkKeyboardModifiers()) == nil or hs.timer.secondsSinceEpoch() - started > 0.5
  end, fn, 0.01)
end

local function paste(text, back)
  local saved = hs.pasteboard.readAllData()
  hs.pasteboard.setContents(text)
  hs.eventtap.keyStroke({ "cmd" }, "v", 0)
  hs.timer.doAfter(0.05, function()
    for _ = 1, back do hs.eventtap.keyStroke({}, "left", 0) end
    hs.timer.doAfter(0.3, function()
      if saved then hs.pasteboard.writeAllData(saved) end
    end)
  end)
end

for key, item in pairs(KEYS) do
  hs.hotkey.bind(HYPER, key, function()
    afterModifiersReleased(function() paste(item[1], item[2]) end)
  end)
end

-- キーボードなしで読み込めているか確かめる入口: open -g "hammerspoon://roba-brackets-check"
hs.urlevent.bind("roba-brackets-check", function()
  local f = io.open(CHECK, "w")
  if f then
    for key, item in pairs(KEYS) do f:write(key, " ", item[1], " ", item[2], "\n") end
    f:close()
  end
end)
