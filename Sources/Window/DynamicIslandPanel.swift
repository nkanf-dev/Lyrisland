import AppKit
import SwiftUI

/// A borderless, always-on-top floating panel that mimics the iOS Dynamic Island.
final class DynamicIslandPanel: NSPanel {
    init(contentView: some View) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 38),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = .statusBar + 1
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
        animationBehavior = .utilityWindow

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear

        // macOS 14+: disable the automatic window background that NSHostingView adds
        if #available(macOS 14.0, *) {
            hostingView.sceneBridgingOptions = []
        }

        // Use a plain transparent container to ensure no AppKit background leaks
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: 38))
        container.wantsLayer = true
        container.layer?.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: container.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        self.contentView = container

        positionAtTopCenter()
    }

    /// Animate the panel to a new size, keeping the top-center anchor point.
    func animateResize(to newSize: NSSize, duration: TimeInterval = 0.35) {
        let currentFrame = frame

        // Keep the top-center pinned
        let newX = currentFrame.midX - newSize.width / 2
        let newY = currentFrame.maxY - newSize.height
        let newFrame = NSRect(origin: NSPoint(x: newX, y: newY), size: newSize)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(newFrame, display: true)
        }
    }

    /// Center the panel horizontally at the top of the main screen.
    private func positionAtTopCenter() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.maxY - frame.height - 12
        setFrameOrigin(NSPoint(x: x, y: y))
    }

    /// Track mouse movement to distinguish clicks from drags
    private var mouseDownOrigin: NSPoint?

    override func mouseDown(with event: NSEvent) {
        mouseDownOrigin = NSEvent.mouseLocation
        super.mouseDown(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        if let origin = mouseDownOrigin {
            let end = NSEvent.mouseLocation
            let distance = hypot(end.x - origin.x, end.y - origin.y)
            if distance < 5 {
                NotificationCenter.default.post(name: .islandTapped, object: nil)
            }
        }
        mouseDownOrigin = nil
        super.mouseUp(with: event)
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        false
    }
}

extension Notification.Name {
    static let islandTapped = Notification.Name("islandTapped")
}
