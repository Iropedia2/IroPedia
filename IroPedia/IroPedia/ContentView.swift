import SwiftUI

enum Functions: String {
    case browse = "browse"
    case history = "history"
    case register = "register"
    case credit = "credit"
    case synchronize = "synchronize"
}

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var items: [Item] = []
    @State private var selectedItem: Item? = nil
    @State private var functions: [Functions] = [.browse, .history, .register, .credit, .synchronize]
    @Environment(\.colorScheme) var colorScheme
    
    var filteredItems: [Item] {
            let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                return items
            } else {
                return items.filter { $0.name.localizedCaseInsensitiveContains(trimmedText) }
            }
        }
    var groupedItems: [Int: [Item]] {
            Dictionary(grouping: filteredItems, by: { $0.index })
        }
    var body: some View {
            HStack(spacing: 0) {
                // 左側のエリア
                VStack {
                    if let item = selectedItem {
                        // 選択されたアイテムの詳細を表示
                        VStack {
                            Text("内容").font(.headline).padding(.top, 20)
                            Text("登録番号: \(item.index)").font(.title2).padding(.top, 10)
                            Text("\(item.name)").font(.title3).padding(.top, 10)
                            Text("場面: \(item.type)").font(.body).padding(.top, 10)
                            Spacer()
                            Button("戻る") {
                                selectedItem = nil // 詳細表示から一覧に戻る
                            }
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                        }
                        .frame(maxWidth: .infinity).background(Color.white).cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5).padding()
                    } else {
                        // 一覧
                        VStack {
                            Text("一覧")
                                .font(.headline).padding(.top, 20)
                            // 検索結果
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(filteredItems) { item in
                                        HStack {
                                            Text("\(item.index)").bold()
                                            Text("\(item.name)")
                                            Spacer()
                                        }
                                        .padding().background(Color.gray.opacity(0.2)).cornerRadius(8)
                                        .onTapGesture {
                                            selectedItem = item // クリックされたアイテムを記録
                                        }
                                    }
                                }
                                .padding()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            ).padding()
                        }
                    }
                }
                .frame(width: 600) // 左側
                .background(Color.white)
                // 中央線
                Rectangle().frame(width: 1).foregroundColor(.black)
                // 右側
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("検索...", text: $searchText).textFieldStyle(PlainTextFieldStyle()).padding(8).cornerRadius(8)
                    }
                    .padding(.horizontal).padding(.top, 40)
                    VStack(spacing: 10) {
                                        ForEach(functions, id: \.self) { function in
                                            ZStack {
                                                getColor(for: function)
                                                    .frame(height: 60)
                                                    .frame(width: 350)
                                                    .cornerRadius(8)

                                                Text(getTitle(for: function))
                                                    .foregroundColor(.white)
                                                    .font(.headline)
                                            }
                                            .onTapGesture {
                                                handleFunctionTap(function) // クリックされた機能に応じた処理
                                            }
                                        }
                                    }
                    .padding(.horizontal, 20).padding(.bottom, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.8)).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    ).padding(.top, 20)
                }
                .frame(width: 400).background(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)
            .onAppear {
                loadCSVData()
            }
        }
    
    // CSVファイルからデータを読み込む関数
    private func loadCSVData() {
        guard let path = Bundle.main.path(forResource: "data", ofType: "csv") else {
            print("CSVファイルが見つかりません")
            return
        }
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.components(separatedBy: "\n").dropFirst()
            for row in rows {
                let columns = row.components(separatedBy: ",")
                if columns.count == 3,
                   let index = Int(columns[0]) {
                    let item = Item(name: columns[1], index: index, type: columns[2]) // 引数の順序を修正
                    self.items.append(item)
                }
            }
        } catch {
            print("CSV読み込みエラー: \(error)")
        }
    }
    private func getColor(for function: Functions) -> Color {
        switch function {
        case .browse:
            return Color.blue.opacity(0.9)
        case .history:
            return Color.cyan.opacity(0.9)
        case .register:
            return Color.pink.opacity(0.9)
        case .credit:
            return Color.orange.opacity(0.9)
        case .synchronize:
            return Color.green.opacity(0.9)
        }
    }
    
    private func getTitle(for function: Functions) -> String {
            switch function {
            case .browse:
                return "検索"
            case .history:
                return "履歴"
            case .register:
                return "登録"
            case .credit:
                return "クレジット"
            case .synchronize:
                return "辞書同期(実装予定)"
        }
    }

    // Functionタップ時の処理
    private func handleFunctionTap(_ function: Functions) {
        print("\(function.rawValue) がクリックされました")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1200, height: 800)
    }
}
