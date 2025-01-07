import SwiftUI

enum Functions: String {
    case browse = "browse"
    case history = "history"
    case register = "register"
    case Delete = "Delete"
    case recommendation = "recommendation"
}

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var registerText_i: String = ""
    @State private var registerText_p: String = ""
    @State private var registerText_e: String = ""
    @State private var registerText_l: [Int] = Array(repeating: 0, count: 3)
    @State private var boxColor: Color = Color.gray
    @State private var boxIcon: String = ""
    @State private var items: [Item] = []
    @State private var selectedItem: Item? = nil
    @State private var HistoryItem: [History] = [History(index: -1, name: "まだ履歴はありません")]
    @State private var recommendedItem: Item? = nil
    @State private var functions: [Functions] = [.browse, .history, .register, .Delete, .recommendation]
    @State private var browsebool: Bool = true
    @State private var historybool: Bool = true
    @State private var registerbool: Bool = true
    @State private var Deletebool: Bool = true
    @State private var recommendationbool: Bool = true
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
    
    func selectRandomItem() {
        guard !items.isEmpty else { return }
        recommendedItem = items.randomElement()
    }

    var rView: some View {
        VStack {
            let numberFormatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none
                return formatter
            }()
            Text("登録画面").font(.headline).padding(.top, 20)
            VStack(spacing: 15) {
                TextField("皮肉", text: $registerText_i).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                TextField("場面", text: $registerText_p).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                TextField("対象", text: $registerText_e).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                TextField("皮肉の強烈さ", value: $registerText_l[0], formatter: numberFormatter).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                TextField("場所との親和性", value: $registerText_l[1], formatter: numberFormatter).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                TextField("対象に対するダメージ", value: $registerText_l[2], formatter: numberFormatter).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                Button("登録") {
                    var sourceData = "100,\(registerText_i),\(registerText_p)"
                    if !registerText_i.isEmpty && !registerText_p.isEmpty {
                        writeCSVData(sources: sourceData)
                        registerText_i = ""
                        registerText_p = ""
                        registerText_e = ""
                        registerText_l = [0, 0, 0]
                        withAnimation {
                            boxColor = Color.green
                            boxIcon = "checkmark"
                        }
                    } else {
                        withAnimation {
                            boxColor = Color.red
                            boxIcon = "xmark"
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            boxColor = Color.gray
                            boxIcon = ""
                        }
                    }
                }
                .padding().foregroundColor(.white).cornerRadius(10)
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(boxColor).frame(width: 60, height: 40).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    if !boxIcon.isEmpty {Image(systemName: boxIcon).foregroundColor(.white).font(.headline)}
                }
            }
            .padding().background(Color.white).cornerRadius(10).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5).padding(.horizontal)
        }
    }
    
    var recView: some View {
        VStack {
            Text("おすすめの皮肉")
                .font(.headline)
                .padding(.top, 20)
            if let recommended = recommendedItem {
                VStack {
                    Text(recommended.name)
                        .font(.title)
                        .foregroundColor(.purple)
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(8)
                    Text("登録番号: \(recommended.index)")
                        .font(.body)
                        .padding(.top, 10)
                    Text("場面: \(recommended.type)")
                        .font(.body)
                        .padding(.top, 10)
                    Button("この皮肉を見る") {
                        selectedItem = recommended
                        recommendationbool = true
                    }
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            } else {
                Text("おすすめがありません")
                    .foregroundColor(.gray)
                    .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.vertical)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左
            VStack {
                if let item = selectedItem {
                    VStack {
                        Text("内容").font(.headline).padding(.top, 20)
                        Text("登録番号: \(item.index)").font(.title2).padding(.top, 10)
                        Text("\(item.name)").font(.title3).padding(.top, 10)
                        Text("場面: \(item.type)").font(.body).padding(.top, 10)
                        Spacer()
                        
                        Button("戻る") {
                            selectedItem = nil
                        }
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    .padding()
                } else if registerbool {
                    rView
                } else if historybool {
                    VStack {
                        Text("閲覧履歴")
                            .font(.headline)
                            .padding(.top, 20)
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(HistoryItem) { history in
                                    HStack {
                                        Text("\(history.index)").bold()
                                        Text("\(history.name)")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                        )
                        .padding()
                    }
                } else if Deletebool {
                    VStack {
                        
                            Text("削除画面").font(.headline).padding(.top, 20)
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(items) { item in
                                        HStack {
                                            Text("\(item.index)").bold()
                                            Text("\(item.name)")
                                            Spacer()
                                            Button("削除") {
                                                Itemdelete(item)
                                            }
                                            .foregroundColor(.red)
                                        }
                                        .padding().background(Color.gray.opacity(0.2)).cornerRadius(8)
                                    }
                                }
                                .padding()
                            }
                        }
                } else if recommendationbool {
                    recView
                } else {
                    VStack {
                        Text("一覧")
                            .font(.headline)
                            .padding(.top, 20)
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(filteredItems) { item in
                                    HStack {
                                        Text("\(item.index)").bold()
                                        Text("\(item.name)")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        selectedItem = item
                                        historydata(item)
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                        )
                        .padding()
                    }
                }
            }
            .frame(width: 600)
            .background(Color.white)
            // 中央
            Rectangle()
                .frame(width: 1)
                .foregroundColor(.black)
            // 右
            VStack(spacing: 20) {
                if browsebool {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("検索...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                VStack(spacing: 5) {
                    ForEach(functions, id: \.self) { function in
                        ZStack {
                            getColor(for: function).frame(height: 60).frame(width: 350).cornerRadius(8)
                            Text(getTitle(for: function))
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.vertical, 10)
                        .onTapGesture {
                            handleFunctionTap(function)
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 5)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                ).padding(.top, 20)
            }
            .frame(width: 600).background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)
        .onAppear {
            copyCSVToDocuments()
            loadCSVData()
            recommendedItem = items.randomElement()
        }
    }
    private func loadCSVData() {
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent("data.csv")

        do {
            let data = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = data.components(separatedBy: "\n").dropFirst()
            items = []
            for row in rows {
                let columns = row.components(separatedBy: ",")
                if columns.count >= 3,
                   let index = Int(columns[0]) {
                    let p1 = columns.count > 3 ? Int(columns[3]) ?? 0 : 0
                    let p2 = columns.count > 4 ? Int(columns[4]) ?? 0 : 0
                    let p3 = columns.count > 5 ? Int(columns[5]) ?? 0 : 0
                    let p = [p1, p2, p3]
                    let item = Item(name: columns[1], index: index, type: columns[2], parameters: p)
                    self.items.append(item)
                }
            }
        } catch {
            print("読込エラー: \(error)")
        }
    }
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private func writeCSVData(sources: String) {
        let documentsDirectory = getDocumentsDirectory()
        let URL = documentsDirectory.appendingPathComponent("data.csv")
        print("書き込み先 URL: \(URL)")
        do {
            var data = try String(contentsOf: URL, encoding: .utf8)
            if !data.hasSuffix("\n") {
                data.append("\n")
            }
            let rows = data.components(separatedBy: "\n").filter{!$0.isEmpty}
            var lastIndex = 0
            if let lastRow = rows.last {
                let columns = lastRow.components(separatedBy: ",")
                if let index = Int(columns[0]) {
                    lastIndex = index
                }
            }
            let newIndex = lastIndex + 1
            let tostring = registerText_l.map{String($0)}.joined(separator: ",")
            let newData = "\(newIndex),\(registerText_i),\(registerText_p),\(tostring)\n"
            if let fileHandle = try? FileHandle(forWritingTo: URL) {
                fileHandle.seekToEndOfFile()
                if !data.hasSuffix("\n") {
                    data.append("\n")
                }
                if let data = newData.data(using: String.Encoding.utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try newData.write(to: URL, atomically: true, encoding: String.Encoding.utf8)
            }

            print("書込: \(newData)")
            loadCSVData()
        } catch {
            print("書込エラー: \(error)")
        }
    }

    private func copyCSVToDocuments() {
        guard let bundlePath = Bundle.main.path(forResource: "data", ofType: "csv") else {
            print("見つかりません")
            return
        }

        let documentsDirectory = getDocumentsDirectory()
        let destinationPath = documentsDirectory.appendingPathComponent("data.csv")

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: destinationPath.path) {
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: destinationPath.path)
                print("コピー")
            } catch {
                print("コピーエラー: \(error)")
            }
        }
    }
    private func historydata(_ item:Item) {
        if HistoryItem.count == 1 && HistoryItem[0].name == "まだ履歴はありません" {
                HistoryItem.removeAll()
        }
        if !HistoryItem.contains(where: {$0.index == item.index}) {
            HistoryItem.append(History(index: item.index, name: item.name))
        }
    }
    private func Itemdelete(_ item: Item) {
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent("data.csv")
        print("削除対象のCSVファイル: \(fileURL.path)")
        do {
            let data = try String(contentsOf: fileURL, encoding: .utf8)
            var rows = data.components(separatedBy: "\n").filter { !$0.isEmpty }
            rows.removeAll { row in
                let columns = row.components(separatedBy: ",")
                return columns.count == 3 && Int(columns[0]) == item.index
            }
            let updatedData = rows.joined(separator: "\n")
            try updatedData.write(to: fileURL, atomically: true, encoding: .utf8)
            items.removeAll { $0.index == item.index }
            print("削除成功: \(item)")
        } catch {
            print("削除エラー: \(error)")
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
        case .Delete:
            return Color.orange.opacity(0.9)
        case .recommendation:
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
        case .Delete:
            return "削除"
        case .recommendation:
            return "今日の皮肉"
        }
    }
    private func handleFunctionTap(_ function: Functions) {
        print("\(function.rawValue)中")
        switch function {
        case .browse:
            browsebool = true
            historybool = false
            registerbool = false
            Deletebool = false
            recommendationbool = false
        case .history:
            browsebool = false
            historybool = true
            registerbool = false
            Deletebool = false
            recommendationbool = false
        case .register:
            browsebool = false
            historybool = false
            registerbool = true
            Deletebool = false
            recommendationbool = false
        case .Delete:
            browsebool = false
            historybool = false
            registerbool = false
            Deletebool = true
            recommendationbool = false
        case .recommendation:
            browsebool = false
            historybool = false
            registerbool = false
            Deletebool = false
            recommendationbool = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1200, height: 800)
    }
}
