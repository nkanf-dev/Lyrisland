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
}
