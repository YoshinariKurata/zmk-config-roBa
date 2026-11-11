-- 右上に出ている macOS の通知を閉じる
-- roBa のマウスレイヤーの , の位置のキーが ⌃⌥⇧⌘N を送る。
-- 通知センターの画面要素をたどり、通知についている「閉じる」操作を実行する。
-- macOS の内部構造に頼っているので、見つからないときは構造を DUMP に書き出す。

local HYPER = { "ctrl", "alt", "shift", "cmd" }
local BUNDLE_ID = "com.apple.notificationcenterui"
local DUMP = os.getenv("HOME") .. "/Documents/roba/keymap-overlay/notifications-dump.txt"
local MAX_DEPTH = 15

local function closeAction(el)
  local names = el:actionNames() or {}
  for _, name in ipairs(names) do
    if name:find("Close") or name:find("閉じる") or name:find("Clear") or name:find("消去") then
      return name
    end
  end
  local subrole = el:attributeValue("AXSubrole") or ""
  if subrole:find("AXNotificationCenter") then
    for _, name in ipairs(names) do
      if name == "AXCancel" then return name end
    end
  end
  return nil
end

local function walk(el, depth, visit)
  visit(el, depth)
  if depth >= MAX_DEPTH then return end
  for _, child in ipairs(el:attributeValue("AXChildren") or {}) do
    walk(child, depth + 1, visit)
  end
end

local function rootElement()
  local app = hs.application.get(BUNDLE_ID)
  return app and hs.axuielement.applicationElement(app)
end

local function closeAll()
  local root = rootElement()
  if not root then return 0 end
  local targets = {}
  walk(root, 0, function(el)
    local action = closeAction(el)
    if action then table.insert(targets, { el = el, action = action }) end
  end)
  -- 消すと後ろの要素が動くので、後ろから順に閉じる
  for i = #targets, 1, -1 do
    targets[i].el:performAction(targets[i].action)
  end
  return #targets
end

local function dump()
  local root = rootElement()
  local f = io.open(DUMP, "w")
  if not f then return end
  if root then
    walk(root, 0, function(el, depth)
      f:write(string.rep("  ", depth),
        tostring(el:attributeValue("AXRole")), " ",
        tostring(el:attributeValue("AXSubrole")), " actions=",
        table.concat(el:actionNames() or {}, " | "):gsub("\n", " "), "\n")
    end)
  else
    f:write("notification center process not found\n")
  end
  f:close()
end

local function clearNotifications()
  if closeAll() == 0 then
    dump()
    hs.alert.show("閉じる通知が見つかりません")
    return
  end
  -- 重なっていた通知が順に出てくるので、少し待ってもう一度閉じる
  hs.timer.doAfter(0.4, closeAll)
end

hs.hotkey.bind(HYPER, "n", clearNotifications)
hs.urlevent.bind("roba-clear-notifications", clearNotifications)
hs.urlevent.bind("roba-dump-notifications", dump)
