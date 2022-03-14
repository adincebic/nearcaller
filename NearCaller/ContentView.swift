//
//  ContentView.swift
//  NearCaller
//
//  Created by Adin Ćebić on 12. 3. 2022..
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Text("Tap below to call")
            Button("Call") {
                viewModel.callButtonTapped()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
