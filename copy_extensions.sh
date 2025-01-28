#!/bin/bash

# 載入配置文件
source ./config.sh

# 檢查模板實例是否存在
if [ ! -d "$BASE_DIR/data/$TEMPLATE_INSTANCE" ]; then
    echo "錯誤：模板實例 (Chrome-$TEMPLATE_INSTANCE) 不存在！"
    exit 1
fi

# 檢查模板實例是否已初始化
if [ ! -d "$BASE_DIR/data/$TEMPLATE_INSTANCE/Default" ] || [ ! -d "$BASE_DIR/data/$TEMPLATE_INSTANCE/Default/Extensions" ]; then
    echo "錯誤：模板實例尚未初始化或未安裝任何插件！"
    echo "請先打開 Chrome-$TEMPLATE_INSTANCE 並安裝所需插件。"
    exit 1
fi

# 檢查是否有其他實例存在
FOUND_INSTANCES=0
for i in $(seq -f "%03g" 1 999)
do
    if [ -d "$BASE_DIR/data/$i" ]; then
        FOUND_INSTANCES=$((FOUND_INSTANCES + 1))
    fi
done

if [ $FOUND_INSTANCES -eq 0 ]; then
    echo "錯誤：未找到任何其他 Chrome 實例！"
    echo "請先使用 create_chrome_innstannces.sh 創建實例。"
    exit 1
fi

echo "找到 $FOUND_INSTANCES 個需要處理的實例"

# 確保模板實例已經安裝好所需插件
echo "請確保 Chrome-000 已安裝好所需的插件"
read -p "是否繼續複製插件到其他實例？(y/n) " REPLY
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# 指定要複製的插件本體
COPY_EXTENSIONS=(
    "Extensions/mcohilncbfahbmgdjkbpemcciiolgcge"  # OKX web3錢包
)

# 指定要複製的必要文件
COPY_FILES=(
    "Preferences"
    "Secure Preferences"
)

# 第一階段：初始化所有實例
echo "第一階段：初始化所有 Chrome 實例..."
# 記錄需要初始化的實例
INIT_NEEDED=()
for i in $(seq -f "%03g" 0 999)
do
    # 跳過模板實例
    if [ "$i" = "000" ]; then
        continue
    fi
    
    # 檢查實例是否存在
    if [ -d "$BASE_DIR/data/$i" ]; then
        # 檢查是否需要初始化
        if [ ! -d "$BASE_DIR/data/$i/Default" ] || [ -z "$(ls -A "$BASE_DIR/data/$i/Default" 2>/dev/null)" ]; then
            INIT_NEEDED+=($i)
        fi
    fi
done

# 如果有需要初始化的實例
if [ ${#INIT_NEEDED[@]} -gt 0 ]; then
    echo "需要初始化 ${#INIT_NEEDED[@]} 個實例..."
    
    # 同時開啟所有需要初始化的實例
    for i in "${INIT_NEEDED[@]}"
    do
        echo "啟動 Chrome-$i..."
        open -n -a "$CHROME_PATH" --args --user-data-dir="$BASE_DIR/data/$i" --no-first-run --no-default-browser-check
    done
    
    # 等待足夠時間讓所有實例初始化
    echo "等待初始化完成..."
    sleep 10
    
    # 一次性關閉所有 Chrome
    echo "關閉所有 Chrome 實例..."
    killall "Google Chrome"
    sleep 5
else
    echo "所有實例都已初始化"
fi

# 確保所有 Chrome 進程都已關閉
killall "Google Chrome" 2>/dev/null
sleep 5

# 第二階段：複製插件
echo -e "\n第二階段：複製插件到所有實例..."
for i in $(seq -f "%03g" 0 999)
do
    if [ "$i" = "000" ]; then
        continue
    fi
    
    if [ -d "$BASE_DIR/data/$i" ]; then
        echo "複製插件到 Chrome-$i..."
        echo "  - 檢查目錄結構..."
        mkdir -p "$BASE_DIR/data/$i/Default/Extensions"

        echo "  - 複製插件..."
        for extension in "${COPY_EXTENSIONS[@]}"
        do
            extension_dir=$(dirname "$BASE_DIR/data/$i/Default/$extension")
            mkdir -p "$extension_dir"
            echo "    * 複製 $extension"
            cp -R "$BASE_DIR/data/$TEMPLATE_INSTANCE/Default/$extension" "$BASE_DIR/data/$i/Default/$extension"
        done

        echo "  - 複製配置文件..."
        for file in "${COPY_FILES[@]}"
        do
            if [ -e "$BASE_DIR/data/$TEMPLATE_INSTANCE/Default/$file" ]; then
                echo "    * 複製 $file"
                cp -R "$BASE_DIR/data/$TEMPLATE_INSTANCE/Default/$file" "$BASE_DIR/data/$i/Default/$file"
            fi
        done

        echo "已完成 Chrome-$i"
        echo "----------------------------------------"
    fi
done

echo -e "\n所有操作完成！" 