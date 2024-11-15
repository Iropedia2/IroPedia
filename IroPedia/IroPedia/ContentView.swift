import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var items: [Item] = [] // CSVから読み込んだデータを格納
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items // searchTextが空の場合は、全てのアイテムを表示
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左側の検索結果エリア
            VStack {
                Spacer()
                
                // 検索結果の表示
                List(filteredItems) { item in
                    Text(item.name)
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            
            // 中央の仕切り線
            Rectangle()
                .frame(width: 1)
                .foregroundColor(.black)
            
            // 右側のサイドバー
            VStack(spacing: 20) {
                // 検索欄
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("検索...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // 付箋風の選択バーたち（略）
                VStack(spacing: 10) {
                    Color.blue.opacity(0.9)
                        .frame(height: 60)
                        .frame(width: 450)
                        .cornerRadius(8)
                    Color.cyan.opacity(0.9)
                        .frame(height: 60)
                        .cornerRadius(8)
                    Color.pink.opacity(0.9)
                        .frame(height: 60)
                        .cornerRadius(8)
                    Color.orange.opacity(0.9)
                        .frame(height: 60)
                        .cornerRadius(8)
                    Color.green.opacity(0.9)
                        .frame(height: 60)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                )
                .padding(.top, 20)
            
            }
            .frame(width: 600)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
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
            // エンコーディングを指定してファイル内容を取得
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.components(separatedBy: "\n").dropFirst() // ヘッダー行をスキップ
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1200, height: 800)
    }
}
