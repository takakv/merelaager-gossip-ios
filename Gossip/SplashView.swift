//
//  SplashView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 16.07.2025.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Spacer()

            Image("GossipSplashIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.pink)
                .frame(width: 250, height: 250)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SplashView()
}
