-- ¥ を入力する。日本語入力（ひらがな・カタカナ）中は「円」を入力する
-- roBa の数字レイヤーのキーが ⌃⌥⇧⌘Y を送る。キーボードは今の入力モードを知らないので、Mac 側で切り替える。

local HYPER = { "ctrl", "alt", "shift", "cmd" }
local CHECK = os.getenv("HOME") .. "/Documents/roba/keymap-overlay/yen-check.txt"

-- macOS 標準の日本語入力は、英数モードのときだけ ID が ".Roman" で終わる
local function japaneseInput()
  local id = hs.keycodes.currentSourceID() or ""
  return id:find("inputmethod") ~= nil and id:find("%.Roman$") == nil, id
end

local function textToType()
  if japaneseInput() then return "円" end
  return "¥"
end

-- キーボードから届いた ⌃⌥⇧⌘ が離れてから入力する（押したままだと修飾キー付きで届いてしまう）
local function afterModifiersReleased(fn)
  local started = hs.timer.secondsSinceEpoch()
  hs.timer.waitUntil(function()
    return next(hs.eventtap.checkKeyboardModifiers()) == nil or hs.timer.secondsSinceEpoch() - started > 0.5
  end, fn, 0.01)
end

hs.hotkey.bind(HYPER, "y", function()
  afterModifiersReleased(function() hs.eventtap.keyStrokes(textToType()) end)
end)

-- キーボードなしで判定だけ確かめる入口: open -g "hammerspoon://roba-yen-check"
hs.urlevent.bind("roba-yen-check", function()
  local _, id = japaneseInput()
  local f = io.open(CHECK, "w")
  if f then
    f:write(id, " -> ", textToType(), "\n")
    f:close()
  end
end)
