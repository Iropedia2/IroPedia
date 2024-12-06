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
    @State private var registerText_i: String = ""
    @State private var registerText_p: String = ""
    @State private var items: [Item] = []
    @State private var selectedItem: Item? = nil
    @State private var functions: [Functions] = [.browse, .history, .register, .credit, .synchronize]
    @State private var browsebool: Bool = true
    @State private var historybool: Bool = true
    @State private var registerbool: Bool = true
    @State private var creditbool: Bool = true
    @State private var synchronizebool: Bool = true
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
                    VStack {
                        Text("登録画面").font(.headline).padding(.top, 20)
                        VStack(spacing: 15) {
                            TextField("皮肉", text: $registerText_i).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                            TextField("場面", text: $registerText_p).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                            Button("登録") {
                                var sourceData = "100,\(registerText_i),\(registerText_p)"
                                writeCSVData(sources: sourceData)
                            }
                            .padding().foregroundColor(.white).cornerRadius(10)
                        }
                        .padding().background(Color.white).cornerRadius(10).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5).padding(.horizontal)
                    }
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
                VStack(spacing: 10) {
                    ForEach(functions, id: \.self) { function in
                        ZStack {
                            getColor(for: function).frame(height: 60).frame(width: 350).cornerRadius(8)
                            Text(getTitle(for: function))
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .onTapGesture {
                            handleFunctionTap(function)
                        }
                    }
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
            copyCSVToDocuments()
            loadCSVData()
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
                if columns.count == 3,
                   let index = Int(columns[0]) {
                    let item = Item(name: columns[1], index: index, type: columns[2])
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
        let fileURL = documentsDirectory.appendingPathComponent("data.csv")

        do {
            let components = sources.split(separator: ",").map { String($0) }
            let csvString = components.joined(separator: ",") + "\n"

            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = csvString.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            }

            print("書込: \(csvString)")
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
    private func handleFunctionTap(_ function: Functions) {
        print("\(function.rawValue)中")
        switch function {
        case .browse:
            browsebool = true
            historybool = false
            registerbool = false
            creditbool = false
            synchronizebool = false
        case .history:
            browsebool = false
            historybool = true
            registerbool = false
            creditbool = false
            synchronizebool = false
        case .register:
            browsebool = false
            historybool = false
            registerbool = true
            creditbool = false
            synchronizebool = false
        case .credit:
            browsebool = false
            historybool = false
            registerbool = false
            creditbool = true
            synchronizebool = false
        case .synchronize:
            browsebool = false
            historybool = false
            registerbool = false
            creditbool = false
            synchronizebool = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1200, height: 800)
    }
}
