//
//  FloatingCreatePostButton.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 09.07.2025.
//

import SwiftUI

struct FloatingCreatePostButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.pink)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
                .accessibilityLabel("Loo postitus")
            }
        }
    }
}

#Preview {
    FloatingCreatePostButton(action: {})
}
