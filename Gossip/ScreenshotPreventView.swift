//
//  ScreenshotPreventView.swift
//  Gossip
//
//

import SwiftUI

// https://stackoverflow.com/a/77841290
struct ScreenshotPreventView<Content: View>: View {
    let content: Content

    @State private var hostingController: UIHostingController<Content>?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        _ScreenshotPreventHelper(hostingController: $hostingController)
            .overlay(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            setupHostingController(with: proxy.size)
                        }
                        .onChange(of: proxy.size) {
                            updateHostingControllerSize(proxy.size)
                        }
                }
            )
    }

    private func setupHostingController(with size: CGSize) {
        guard hostingController == nil, size != .zero else { return }
        let controller = UIHostingController(rootView: content)
        controller.view.backgroundColor = .clear
        controller.view.tag = 1009
        controller.view.frame = CGRect(origin: .zero, size: size)
        hostingController = controller
    }

    private func updateHostingControllerSize(_ size: CGSize) {
        guard size != .zero else { return }
        hostingController?.view.frame = CGRect(origin: .zero, size: size)
    }
}

private struct _ScreenshotPreventHelper<Content: View>: UIViewRepresentable {
    @Binding var hostingController: UIHostingController<Content>?

    func makeUIView(context: Context) -> UIView {
        let secureField = UITextField()
        secureField.isSecureTextEntry = true

        if let textLayoutView = secureField.subviews.first {
            return textLayoutView
        }
        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let hostingController = hostingController,
            !uiView.subviews.contains(where: { $0.tag == 1009 })
        {
            uiView.addSubview(hostingController.view)
        }
    }
}
