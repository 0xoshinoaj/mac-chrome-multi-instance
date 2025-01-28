#!/bin/bash

# Chrome 安裝位置
CHROME_PATH="/Applications/Google Chrome.app"

# 基礎目錄設定
BASE_DIR="$HOME/Desktop/多開Chrome"    # $HOME/Desktop 是用戶桌面的標準路徑

# 預設創建數量 (可以被命令行參數覆蓋)
DEFAULT_INSTANCES=11  # 從000開始，所以增加一個

# 模板實例編號
TEMPLATE_INSTANCE="000" 