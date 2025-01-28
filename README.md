# Mac Chrome 多開工具

這是一個用於 macOS 的 Chrome 多開工具，可以創建和管理多個 Chrome 實例，每個實例都有獨立的配置和插件設定。

## 功能
- 創建多個獨立的 Chrome 實例
- 自動複製指定插件到所有實例
- 支持批量初始化和設定

## 使用步驟

### 1. 下載並設定
```shell
# 下載專案
git clone https://github.com/oshinoaj/mac-chrome-multi-instance.git
cd mac-chrome-multi-instance

# 添加執行權限
chmod +x create_chrome_innstannces.sh copy_extensions.sh
```

### 2. 修改配置
編輯 `config.sh`，設定：
- Chrome 安裝位置（預設: `/Applications/Google Chrome.app`）
- 多開Chrome的存放位置（預設: `$HOME/Desktop/多開Chrome`）
- 實例數量（預設: 11個，000為模板，001~010為實例）

### 3. 創建實例
```shell
./create_chrome_innstannces.sh
```
- 會創建 Chrome-000 到 Chrome-010
- 每個實例都是獨立的
- 如果已有部分實例，會從最後一個編號繼續創建

### 4. 自行安裝模板插件
1. 打開 Chrome-000
2. 前往Chrome擴充功能頁面，安裝需要的插件（如：OKX Wallet）

### 5. 設定要複製的插件資訊
編輯 `copy_extensions.sh`，設定要複製的插件資訊
# 指定要複製的插件本體
COPY_EXTENSIONS=(
    "Extensions/mcohilncbfahbmgdjkbpemcciiolgcge"  # OKX web3錢包
)

後面那串是插件的ID，取得方法有3
1. 前往Chrome擴充功能頁面，點擊插件，複製ID
2. 前往Chrome擴充功能安裝URL，複製URL結尾的ID
3. 前往Data/Chrome-000/Default/Extensions，找到插件資料夾，複製ID

### 6. 執行 複製插件
```shell
./copy_extensions.sh
```
- 將 Chrome-000 的插件複製到其他實例
- 會自動初始化未開啟過的實例
- 支持批量處理，提高效率

## 注意事項
1. 執行前請關閉所有 Chrome
2. Chrome-000 作為模板，請先完成設定
3. 建議定期備份重要數據
4. 首次使用時需要手動打開一次 Chrome-000

## 系統要求
- macOS 系統
- 已安裝 Google Chrome
- 足夠的硬碟空間

## 常見問題

### Q: 為什麼需要 Chrome-000？
A: Chrome-000 作為模板實例，用於設定要複製到其他實例的插件和配置。

### Q: 如何修改實例數量？
A: 可以在 config.sh 中修改 DEFAULT_INSTANCES 的值，或在執行 create_chrome_innstannces.sh 時指定數量。

### Q: 複製插件失敗怎麼辦？
A: 請確保：
1. 已關閉所有 Chrome 實例
2. Chrome-000 已正確設定
3. 有足夠的硬碟空間
