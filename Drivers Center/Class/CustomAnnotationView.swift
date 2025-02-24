import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {
    let titleLabel = UILabel()
    
    var pinColor: UIColor = .black {
        didSet {
            titleLabel.textColor = pinColor
            titleLabel.backgroundColor = .clear
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        canShowCallout = true
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        titleLabel.textColor = pinColor
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = 4
        titleLabel.clipsToBounds = true
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var txt: String = ""
        // Update the label's text using the current annotation's title.
        titleLabel.text = annotation?.title ?? ""
        txt = titleLabel.text ?? ""
        txt = txt.truncated(to: 12)
        titleLabel.text = txt
        
        titleLabel.sizeToFit()
        
        let padding: CGFloat = 4
        let labelWidth = titleLabel.frame.size.width + padding * 2
        let labelHeight = titleLabel.frame.size.height + padding
        titleLabel.frame = CGRect(
            x: -(labelWidth - self.frame.size.width) / 2,
            y: self.frame.size.height,
            width: labelWidth,
            height: labelHeight
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear the label text so stale text is not shown.
        titleLabel.text = nil
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var category: MKPointOfInterestCategory?
    var placeID: String?
}

extension String {
    func truncated(to maxLength: Int) -> String {
        guard self.count > maxLength else { return self }
        
        let index = self.index(self.startIndex, offsetBy: maxLength)
        
        // Find the last space before or at maxLength
        if let lastSpaceIndex = self[..<index].lastIndex(of: " ") {
            return String(self[..<lastSpaceIndex]) + "..."
        } else {
            return String(self.prefix(maxLength)) + "..."
        }
    }
}
