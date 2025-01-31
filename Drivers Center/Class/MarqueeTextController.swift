class MarqueeTextController {
    private let longText: String
    private var currentIndex: Int = 0
    private weak var listItem: CPListItem?

    init(text: String, listItem: CPListItem) {
        self.longText = text
        self.listItem = listItem
    }

    func startScrolling() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, let listItem = self.listItem else {
                timer.invalidate()
                return
            }

            let visibleText = self.currentSubstring()
            listItem.text = visibleText
            self.currentIndex += 1
            if self.currentIndex > self.longText.count {
                self.currentIndex = 0
            }
        }
    }

    private func currentSubstring() -> String {
        let start = longText.index(longText.startIndex, offsetBy: currentIndex)
        let end = longText.index(start, offsetBy: 20, limitedBy: longText.endIndex) ?? longText.endIndex
        return String(longText[start..<end])
    }
}

// Usage
let listItem = CPListItem(text: "Placeholder", detailText: nil)
let marqueeController = MarqueeTextController(text: "This is a very long text that needs scrolling.", listItem: listItem)
marqueeController.startScrolling()