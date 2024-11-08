import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // 左側の検索結果エリア
            VStack {
                Spacer()
                Text("検索結果の表示など\n(追加機能も考えてる)")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
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
                .padding(.top, 20) // 上に余白を追加して配置
                
                // 付箋風の選択バーたち
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
                .padding(.bottom, 40) // ウィンドウ下部との距離感を設定
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                )
                .padding(.top, 20) // 上に少し余白を追加
            }
            .frame(width: 600) // サイドバーの幅を調整
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1200, height: 800)
    }
}
