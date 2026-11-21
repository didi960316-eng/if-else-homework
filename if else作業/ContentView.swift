import SwiftUI

// MARK: - 卡片資料模型
struct GachaItem: Identifiable {
    let id = UUID()
    let name: String
    let star: Int
    let isFeatured: Bool

    var color: Color {
        if star == 5 {
            return .yellow
        } else if star == 4 {
            return .purple
        } else {
            return .blue
        }
    }
}

struct ContentView: View {
    // MARK: - 保底狀態
    @State private var pullsSinceLast5Star: Int = 0  // 五星累積抽數 (0~90)
    @State private var pullsSinceLast4Star: Int = 0  // 四星累積抽數 (0~10)
    @State private var isGuaranteedFeatured: Bool = false  // 是否為大保底（下次五星必中限定）

    // 抽卡結果與歷史紀錄
    @State private var latestResults: [GachaItem] = []
    @State private var historyLogs: [String] = []

    // 卡池設定
    let featured5StarName = "限定五星"
    let standard5StarName = "常駐五星"
    let fourStarName = "四星"
    let threeStarName = "三星"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - 頂部狀態列
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("抽卡模擬器")
                            .font(.title2)
                            .bold()
                        Text("當期限定：\(featured5StarName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                // MARK: - 保底進度看板
                VStack(spacing: 8) {
                    HStack {
                        Text("五星累積：\(pullsSinceLast5Star) / 90 抽")
                            .font(.subheadline)
                            .bold()

                        // 判斷是否進入 74 抽軟保底
                        if pullsSinceLast5Star >= 74 {
                            Text("(保底增率中)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Spacer()

                        // 判斷大小保底狀態
                        if isGuaranteedFeatured {
                            Text("大保底 (必出限定)")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(Color.orange.opacity(0.2))
                                )
                                .foregroundStyle(.orange)
                        } else {
                            Text("小保底 (50%會歪)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(Color.gray.opacity(0.2))
                                )
                                .foregroundStyle(.secondary)
                        }
                    }

                    ProgressView(value: Double(pullsSinceLast5Star), total: 90)
                        .tint(pullsSinceLast5Star >= 74 ? .orange : .blue)

                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6))
                )
                .padding(.horizontal)

                // MARK: - 抽卡成果展示區
                VStack(alignment: .leading, spacing: 10) {
                    Text("本輪祈願成果：")
                        .font(.headline)
                        .padding(.horizontal)

                    if latestResults.isEmpty {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                            .overlay(
                                Text("點擊下方按鈕開始祈願！")
                                    .foregroundStyle(.secondary)
                            )
                            .padding(.horizontal)
                    } else {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: 10),
                                count: 5
                            ),
                            spacing: 10
                        ) {
                            ForEach(latestResults) { item in
                                VStack(spacing: 4) {
                                    Text(item.name)
                                        .font(.caption)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .lineLimit(1)

                                    HStack(spacing: 1) {
                                        ForEach(0..<item.star, id: \.self) {
                                            _ in
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 8))
                                                .foregroundStyle(item.color)
                                        }
                                    }
                                }
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(item.color.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    item.color,
                                                    lineWidth: item.star == 5
                                                        ? 2 : 1
                                                )
                                        )
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // MARK: - 祈願按鈕區
                HStack(spacing: 15) {
                    // 單抽
                    Button {
                        performPulls(count: 1)
                    } label: {
                        Text("祈願 1 次")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)

                    // 十連抽
                    Button {
                        performPulls(count: 10)
                    } label: {
                        Text("祈願 10 次")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                Divider()

                // MARK: - 祈願歷史紀錄
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("抽卡紀錄")
                            .font(.headline)
                        Spacer()
                        if !historyLogs.isEmpty {
                            Button("清空") {
                                historyLogs.removeAll()
                            }
                            .font(.caption)
                        }
                    }

                    if historyLogs.isEmpty {
                        Text("暫無抽卡紀錄")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(historyLogs.suffix(8).reversed(), id: \.self) {
                            log in
                            Text(log)
                                .font(.caption)
                                .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    // MARK: - 核心抽卡邏輯（大量運算與 if-else）
    func performPulls(count: Int) {
        var currentPulls: [GachaItem] = []

        for _ in 0..<count {
            pullsSinceLast5Star += 1
            pullsSinceLast4Star += 1

            // 【if-else 應用 1】：五星機率動態計算（74 抽軟保底與 90 抽硬保底）
            let fiveStarRate: Double
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

            let roll = Double.random(in: 0.0...1.0)

            // 【if-else 應用 2】：判斷抽出的卡片星級（五星、四星、三星）
            if roll < fiveStarRate {
                // === 出五星金光 ===
                let pulledItem: GachaItem

                // 【if-else 應用 3】：大小保底與 50/50 歪卡機制
                if isGuaranteedFeatured {
                    // 大保底：必定為限定角色
                    pulledItem = GachaItem(
                        name: featured5StarName,
                        star: 5,
                        isFeatured: true
                    )
                    isGuaranteedFeatured = false
                    historyLogs.append(
                        "【大保底】第 \(pullsSinceLast5Star) 抽迎來限定：\(featured5StarName)！"
                    )
                } else {
                    // 小保底：50% 機率不歪，50% 機率歪常駐
                    let win5050 = Bool.random()
                    if win5050 {
                        pulledItem = GachaItem(
                            name: featured5StarName,
                            star: 5,
                            isFeatured: true
                        )
                        historyLogs.append(
                            "【小保底不歪】第 \(pullsSinceLast5Star) 抽抽出限定：\(featured5StarName)！"
                        )
                    } else {
                        pulledItem = GachaItem(
                            name: standard5StarName,
                            star: 5,
                            isFeatured: false
                        )
                        isGuaranteedFeatured = true
                        historyLogs.append(
                            "【小保底歪了】第 \(pullsSinceLast5Star) 抽歪出常駐：\(standard5StarName)（啟動大保底）"
                        )
                    }
                }

                currentPulls.append(pulledItem)
                pullsSinceLast5Star = 0  // 重置五星累積抽數
                pullsSinceLast4Star = 0  // 出五星同時重置四星

            } else if roll < (fiveStarRate + 0.051) || pullsSinceLast4Star >= 10
            {
                // === 出四星紫光（基礎機率 5.1% 或 10 抽必定保底）===
                currentPulls.append(
                    GachaItem(name: fourStarName, star: 4, isFeatured: false)
                )
                pullsSinceLast4Star = 0  // 重置四星累積抽數

            } else {
                // === 出三星藍光 ===
                currentPulls.append(
                    GachaItem(name: threeStarName, star: 3, isFeatured: false)
                )
            }
        }

        latestResults = currentPulls
    }
}

#Preview {
    ContentView()
}
