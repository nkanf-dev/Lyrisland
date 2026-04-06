@testable import Lyrisland
import Testing

struct PlayingIndicatorTests {
    @Test("bar scale stays within expected visual range")
    func barScaleRange() {
        for index in 0 ..< 3 {
            let scale = PlayingIndicator.barScale(at: 1.25, index: index)
            #expect(scale >= 0.3)
            #expect(scale <= 1.0)
        }
    }

    @Test("different bars have staggered scales at the same time")
    func barScaleIsStaggered() {
        let first = PlayingIndicator.barScale(at: 0.5, index: 0)
        let second = PlayingIndicator.barScale(at: 0.5, index: 1)

        #expect(first != second)
    }

    @Test("compact notch layout metrics reserve top-row slots and lyric row")
    func compactNotchLayoutMetrics() {
        #expect(CompactIslandView.LayoutMetrics.topRowArtworkSize > 0)
        #expect(CompactIslandView.LayoutMetrics.topRowIndicatorWidth > 0)
        #expect(CompactIslandView.LayoutMetrics.lyricRowMinHeight > 0)
        #expect(CompactIslandView.prefersDualLineLyricsInCompact == false)
    }

    @Test("attached compact collapsed mode keeps the same width as normal attached compact mode")
    func attachedCompactCollapsedWidth() {
        let normal = IslandContentView.size(for: .compact, attached: true, dualLine: false, artwork: true)
        let collapsed = IslandContentView.size(
            for: .compact,
            attached: true,
            dualLine: false,
            artwork: true,
            compactPresentation: .collapsed
        )

        #expect(collapsed.width == normal.width)
        #expect(collapsed.height < normal.height)
    }

    @Test("detached compact ignores collapsed presentation sizing")
    func detachedCompactIgnoresCollapsedPresentation() {
        let normal = IslandContentView.size(for: .compact, attached: false, dualLine: false, artwork: true)
        let collapsed = IslandContentView.size(
            for: .compact,
            attached: false,
            dualLine: false,
            artwork: true,
            compactPresentation: .collapsed
        )

        #expect(collapsed.width == normal.width)
        #expect(collapsed.height == normal.height)
    }

    @Test("attached compact is narrower than detached compact")
    func attachedCompactIsNarrowerThanDetachedCompact() {
        let attached = IslandContentView.size(for: .compact, attached: true, dualLine: false, artwork: true)
        let detached = IslandContentView.size(for: .compact, attached: false, dualLine: false, artwork: true)

        #expect(attached.width < detached.width)
    }

    @Test("right click collapses compact island before prompting to quit")
    func rightClickCollapsesCompactIsland() {
        let action = IslandContentView.rightClickAction(
            for: .compact,
            compactPresentation: .normal
        )

        #expect(action == .collapse)
    }

    @Test("right click on compact collapsed island prompts quit confirmation")
    func rightClickPromptOnCollapsedCompactIsland() {
        let action = IslandContentView.rightClickAction(
            for: .compact,
            compactPresentation: .collapsed
        )

        #expect(action == .confirmQuit)
        #expect(IslandContentView.quitConfirmationMessage(appName: "Lyrisland") == "是否要退出Lyrisland？")
    }
}
