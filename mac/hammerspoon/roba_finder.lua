-- Finder を前に出す。開いているウィンドウがなければ、ホームフォルダの新しいウィンドウを開く
-- roBa のマウスレイヤーのキーが ⌃⌥⇧⌘F を送る。

local HYPER = { "ctrl", "alt", "shift", "cmd" }

local function openFinder()
  local finder = hs.application.get("com.apple.finder")
  local hasWindow = false
  if finder then
    for _, w in ipairs(finder:allWindows()) do
      if w:isStandard() then hasWindow = true break end
    end
  end
  if hasWindow then
    finder:activate(true)
  else
    hs.execute('open "$HOME"')
  end
end

hs.hotkey.bind(HYPER, "f", openFinder)

-- キーボードなしで確かめるための入口: open -g "hammerspoon://roba-finder"
hs.urlevent.bind("roba-finder", openFinder)
