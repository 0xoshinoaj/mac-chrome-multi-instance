#!/bin/bash

# 載入配置文件
source ./config.sh

# 檢查是否為全新安裝
if [ ! -d "$BASE_DIR/data" ] || [ -z "$(ls -A "$BASE_DIR/data" 2>/dev/null)" ]; then
    # 如果是全新安裝，從 000 開始
    START_NUM=0
else
    # 如果已有實例，找到最後一個編號
    LAST_INSTANCE=0
    for i in $(seq -f "%03g" 0 999)
    do
        if [ -d "$BASE_DIR/data/$i" ]; then
            LAST_INSTANCE=$i
        fi
    done
    START_NUM=$((10#$LAST_INSTANCE + 1))
fi

# 確保輸入了數量，如果沒有則使用預設值
INSTANCES=${1:-$DEFAULT_INSTANCES}

# 顯示設定信息
echo "使用以下設定："
echo "Chrome 路徑: $CHROME_PATH"
echo "基礎目錄: $BASE_DIR"
echo "創建數量: $INSTANCES"
echo "起始編號: $(printf "%03d" $START_NUM)"
echo ""

# 確認是否繼續
read -p "是否繼續？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# 創建基礎資料夾結構
mkdir -p "$BASE_DIR/apps"
mkdir -p "$BASE_DIR/data"

# 為每個實例創建資料夾和應用程式
for ((i=START_NUM; i<START_NUM+INSTANCES; i++))
do
    NUM=$(printf "%03d" $i)
    # 創建數據資料夾
    mkdir -p "$BASE_DIR/data/$NUM"
    mkdir -p "$BASE_DIR/apps/Chrome-$NUM.app/Contents/MacOS"
    
    # 創建啟動腳本
    cat > "$BASE_DIR/apps/Chrome-$NUM.app/Contents/MacOS/chrome-launcher" << EOF
#!/bin/bash
open -n -a "$CHROME_PATH" --args --user-data-dir="$BASE_DIR/data/$NUM" --no-first-run --no-default-browser-check
EOF
    
    # 設定執行權限
    chmod +x "$BASE_DIR/apps/Chrome-$NUM.app/Contents/MacOS/chrome-launcher"
    
    # 創建 Info.plist
    cat > "$BASE_DIR/apps/Chrome-$NUM.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>chrome-launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.chrome.instance.$NUM</string>
    <key>CFBundleName</key>
    <string>Chrome-$NUM</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
</dict>
</plist>
EOF
    
    echo "已創建 Chrome-$NUM"
done

echo "完成！已創建 $INSTANCES 個Chrome實例"
echo "應用程式位置：$BASE_DIR/apps"
echo "數據位置：$BASE_DIR/data"
echo "您現在可以在 $BASE_DIR/apps 中找到並執行這些Chrome實例"