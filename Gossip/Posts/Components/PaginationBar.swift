//
//  PaginationBar.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 09.07.2025.
//

import SwiftUI

struct PaginationBar: View {
    let currentPage: Int
    let totalPages: Int
    let onPageSelect: (Int) -> Void

    var body: some View {
        if totalPages <= 1 {
            EmptyView()
        } else {
            let range = max(2, currentPage - 1)...min(totalPages, currentPage + 1)

            HStack(spacing: 8) {
                PaginationButton(label: "1", isSelected: currentPage == 1) {
                    onPageSelect(1)
                }

                if currentPage > 3 {
                    Text("…")
                        .padding(.horizontal, 4)
                }

                ForEach(range, id: \.self) { page in
                    PaginationButton(label: "\(page)", isSelected: currentPage == page) {
                        onPageSelect(page)
                    }
                }

                Button(action: {
                    onPageSelect(currentPage + 1)
                }) {
                    Image(systemName: "chevron.right")
                        .padding(6)
                }
                .disabled(currentPage >= totalPages)
            }
            .padding(.vertical, 12)
        }
    }
}


#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
