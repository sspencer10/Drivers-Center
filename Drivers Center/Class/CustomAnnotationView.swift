import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {
    let titleLabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Allow callouts if desired.
        canShowCallout = true
        
        // Configure the label.
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        titleLabel.textColor = .black
        titleLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = 4
        titleLabel.clipsToBounds = true
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update the label's text.
        titleLabel.text = annotation?.title ?? ""
        titleLabel.sizeToFit()
        
        // Add some padding around the label text.
        let padding: CGFloat = 4
        
        // Position the label below the pin image.
        // The x position is calculated to center the label relative to the annotation view.
        let labelWidth = titleLabel.frame.size.width + padding * 2
        let labelHeight = titleLabel.frame.size.height + padding
        titleLabel.frame = CGRect(
            x: -(labelWidth - self.frame.size.width) / 2,
            y: self.frame.size.height,
            width: labelWidth,
            height: labelHeight
        )
    }
}