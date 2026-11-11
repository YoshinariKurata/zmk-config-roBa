-- roBa 用の Hammerspoon 設定をまとめて読み込む。
-- ~/.hammerspoon/init.lua から dofile でこのファイルを読む。

local DIR = os.getenv("HOME") .. "/Documents/roba/zmk-config-roBa/mac/hammerspoon/"

for _, name in ipairs({ "roba_keymap", "roba_notifications", "roba_yen", "roba_finder", "roba_brackets" }) do
  dofile(DIR .. name .. ".lua")
end
