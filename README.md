# 🎯 抽卡模擬器 (Gacha Simulator) - SwiftUI if-else 作業

一個基於 SwiftUI 開發的原神風格抽卡祈願模擬器，完整實作了手遊抽卡系統中的**機率計算**、**軟硬保底**與**50/50 大小保底**機制，展示了 Swift 中 `if-else` 條件判斷的實際應用。

---

## 📱 專案簡介

本專案為 iOS SwiftUI 的條件判斷（`if-else`）練習作業，透過模擬常見的抽卡保底機制，深入探討多重條件判斷、動態機率演算法與狀態驅動的 UI 呈現。

### 🌟 核心功能與特色

1. **五星保底系統**
   - **基礎機率**：0.6% 基礎出金率。
   - **74 抽軟保底 (Soft Pity)**：達到 74 抽後，每抽增加約 6% 機率，進度條切換提示為「保底增率中」。
   - **90 抽硬保底 (Hard Pity)**：累積至 90 抽時機率達到 100%，必定獲得五星。

2. **大小保底與 50/50 歪卡機制**
   - **小保底**：出五星時有 50% 機率獲得「當期限定五星」，50% 機率歪「常駐五星」。
   - **大保底**：若小保底抽中常駐角色，自動啟動大保底狀態，下次出五星必定為限定五星。

3. **四星保底機制**
   - 基礎四星機率 5.1%，每 10 抽必定保底出四星或以上。
   - 抽出五星時，同時重置五星與四星的累積計數。

4. **互動式 SwiftUI 介面**
   - **進度看板**：即時顯示五星累積抽數、進度條視覺化與當前大小保底狀態膠囊標籤。
   - **單抽 / 十連抽**：支援單抽（1抽）與十連祈願（10連抽），以卡片網格（`LazyVGrid`）展示星級與顏色。
   - **祈願歷史記錄**：即時紀錄重要抽卡事件（小保底命中、歪卡、大保底），並提供一鍵清空功能。

---

## 💻 `if-else` 邏輯重點解析

本專案在 [`ContentView.swift`](if%20else作業/ContentView.swift) 中應用了多處 `if-else` 條件控制：

### 1. 動態五星機率計算（軟保底 / 硬保底）
```swift
if pullsSinceLast5Star >= 90 {
    // 90 抽硬保底必定出五星
    fiveStarRate = 1.0
} else if pullsSinceLast5Star >= 74 {
    // 74 抽開始進入軟保底：每多一抽機率增加約 6%
    let extraRate = Double(pullsSinceLast5Star - 73) * 0.06
    fiveStarRate = 0.006 + extraRate
} else {
    // 基礎五星機率 0.6%
    fiveStarRate = 0.006
}
```

### 2. 星級判定邏輯
```swift
if roll < fiveStarRate {
    // 抽中五星金光
} else if roll < (fiveStarRate + 0.051) || pullsSinceLast4Star >= 10 {
    // 抽中四星紫光（機率或十抽保底）
} else {
    // 抽中三星藍光
}
```

### 3. 大小保底與歪卡判定
```swift
if isGuaranteedFeatured {
    // 大保底：必定為限定角色
    pulledItem = GachaItem(name: featured5StarName, star: 5, isFeatured: true)
    isGuaranteedFeatured = false
} else {
    // 小保底：50% 機率命中限定，50% 歪常駐並觸發大保底
    let win5050 = Bool.random()
    if win5050 {
        pulledItem = GachaItem(name: featured5StarName, star: 5, isFeatured: true)
    } else {
        pulledItem = GachaItem(name: standard5StarName, star: 5, isFeatured: false)
        isGuaranteedFeatured = true
    }
}
```

---

## 🛠 開發環境

- **平台**：iOS 17+
- **語言**：Swift 5.9+
- **UI 框架**：SwiftUI
- **開發工具**：Xcode 15+

---

## 🚀 安裝與執行

1. Clone 本專案：
   ```bash
   git clone https://github.com/didi960316-eng/if-else-homework.git
   ```
2. 使用 Xcode 打開專案：
   ```bash
   cd if-else-homework
   open "if else作業.xcodeproj"
   ```
3. 在 Xcode 中選擇模擬器（例如 iPhone 15 / 16）或真機，按下 `Cmd + R` 即可執行。
