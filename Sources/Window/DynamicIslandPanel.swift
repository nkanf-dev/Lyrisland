import AppKit
import SwiftUI

/// A borderless, always-on-top floating panel that mimics the iOS Dynamic Island.
final class DynamicIslandPanel: NSPanel {
    init<Content: View>(contentView: Content) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 38),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = .statusBar + 1
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
        animationBehavior = .utilityWindow

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = self.frame
        self.contentView = hostingView

        positionAtTopCenter()
    }

    /// Center the panel horizontally at the top of the main screen.
    private func positionAtTopCenter() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.maxY - frame.height - 12
        setFrameOrigin(NSPoint(x: x, y: y))
    }

    // Allow the panel to become key for hover/click interactions
    // but never steal focus from other apps.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
