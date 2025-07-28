//
//  ContentView.swift
//  MVIDemo
//
//  Created by Kylie on 2025/7/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("MVI Demo App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("專案結構已建立完成")
                .font(.title2)
                .padding()
            
            Text("請在 Xcode 中手動加入其他檔案到專案中")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
