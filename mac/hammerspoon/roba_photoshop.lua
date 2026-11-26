-- roBa の Photoshop レイヤーのキーを、Photoshop の操作に置き換える
-- キーボードは左手のキーで、どのソフトも使わないキー (F13、F16〜F20、テンキーの 0〜9) を送る。
-- Photoshop が前面のときだけ、下の表の操作に置き換える。ほかのアプリでは何もしない (キーは捨てる)。
--   押す・離すをそのまま送るので、押している間だけツールが変わる Photoshop の動きも使える。
--   キーボードで押したままの修飾キー (⌃ ⌥ ⇧ ⌘) は、置き換えた操作に足される (⇧ を押したまま 取り消し → やり直し など)。
-- 表を変えたら、図 (diagram/roba-keymap.html の Photoshop のカード) も合わせて直す。
-- F14 / F15 は Mac で画面の明るさに使われることがあるので、キーボードからは送らない。

local PHOTOSHOP = "com.adobe.Photoshop"
local CHECK = os.getenv("HOME") .. "/Documents/roba/keymap-overlay/photoshop-check.txt"

-- キーボードが送るキー → Photoshop の操作 (位置は大西配列の文字で)
local ACTIONS = {
  f13  = { mods = { "cmd" }, key = "z", name = "取り消し" },               -- Q
  f16  = { mods = { "shift", "cmd" }, key = "z", name = "やり直し" },      -- L
  f17  = { mods = { "cmd" }, key = "t", name = "自由変形" },               -- U
  f18  = { mods = { "cmd" }, key = "d", name = "選択解除" },               -- ,
  f19  = { mods = { "cmd" }, key = "j", name = "レイヤーを複製" },         -- .
  f20  = { mods = {}, key = "b", name = "ブラシ" },                        -- E
  pad1 = { mods = {}, key = "e", name = "消しゴム" },                      -- I
  pad2 = { mods = {}, key = "v", name = "移動" },                          -- A
  pad3 = { mods = {}, key = "l", name = "なげなわ" },                      -- O
  pad4 = { mods = {}, key = "w", name = "クイック選択" },                  -- -
  pad5 = { mods = { "alt", "shift", "cmd" }, key = "n", name = "新規レイヤー" }, -- Tab (ダイアログなし)
  pad6 = { mods = {}, key = "x", name = "色の入れ替え" },                  -- Z
  pad7 = { mods = {}, key = "i", name = "スポイト" },                      -- X
  pad8 = { mods = {}, key = "g", name = "塗りつぶし" },                    -- C
  pad9 = { mods = {}, key = "c", name = "切り抜き" },                      -- V
  pad0 = { mods = { "cmd" }, key = "0", name = "画面に合わせる" },         -- '
}

local MODS = { "ctrl", "alt", "shift", "cmd" }

roba_photoshop = roba_photoshop or {}
local P = roba_photoshop
if P.tap then P.tap:stop() end
P.down = {} -- 押している間のキー → 送った操作 (離したときに同じものを離す)

local types = hs.eventtap.event.types
local AUTOREPEAT = hs.eventtap.event.properties.keyboardEventAutorepeat

local function photoshopFront()
  local app = hs.application.frontmostApplication()
  return app ~= nil and app:bundleID() == PHOTOSHOP
end

-- 表の修飾キーに、キーボードで押したままの修飾キーを足す
local function withHeld(action, flags)
  local set = {}
  for _, m in ipairs(action.mods) do set[m] = true end
  for _, m in ipairs(MODS) do
    if flags[m] then set[m] = true end
  end
  local mods = {}
  for _, m in ipairs(MODS) do
    if set[m] then table.insert(mods, m) end
  end
  return mods
end

P.tap = hs.eventtap.new({ types.keyDown, types.keyUp }, function(e)
  local code = e:getKeyCode()
  local action = ACTIONS[hs.keycodes.map[code]]
  if not action then return false end

  if e:getType() == types.keyDown then
    if e:getProperty(AUTOREPEAT) ~= 0 then return true end -- 押しっぱなしの繰り返しは捨てる
    if not photoshopFront() then return true end
    local sent = { key = action.key, mods = withHeld(action, e:getFlags()) }
    P.down[code] = sent
    return true, { hs.eventtap.event.newKeyEvent(sent.mods, sent.key, true) }
  end

  local sent = P.down[code]
  P.down[code] = nil
  if not sent then return true end
  return true, { hs.eventtap.event.newKeyEvent(sent.mods, sent.key, false) }
end):start()

-- キーボードなしで読み込めているか確かめる入口: open -g "hammerspoon://roba-photoshop-check"
hs.urlevent.bind("roba-photoshop-check", function()
  local f = io.open(CHECK, "w")
  if f then
    local app = hs.application.frontmostApplication()
    f:write("tap enabled: ", tostring(P.tap:isEnabled()), "\n")
    f:write("front: ", app and (app:bundleID() or "?") or "none", "\n")
    for name in pairs(ACTIONS) do
      f:write(name, " -> keycode ", tostring(hs.keycodes.map[name]), "\n")
    end
    f:close()
  end
end)
