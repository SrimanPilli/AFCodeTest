//
//  ExploreContentCell.swift
//  ANF Code Test
//
//  Created by SaiSriman on 10/27/25.
//


import UIKit

protocol ExploreContentCellDelegate: AnyObject {
    func exploreContentCell(_ cell: ExploreContentCell, didTapLink url: String)
}

class ExploreContentCell: UITableViewCell {
    
    //UI Components
    
    var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let topDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let promoMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let bottomDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Properties
    
    weak var delegate: ExploreContentCellDelegate?
    private var imageHeightConstraint: NSLayoutConstraint?
    
    // Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Layout
    
    private func setupViews() {
        contentView.addSubview(backgroundImageView)
        
        let verticalStack = UIStackView(arrangedSubviews: [
            topDescriptionLabel,
            titleLabel,
            promoMessageLabel,
            bottomDescriptionLabel,
            contentStackView
        ])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verticalStack)
        
        let _: CGFloat = 16
        
        // Background image constraints
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        let imageHeightConstraint = backgroundImageView.heightAnchor.constraint(
            equalTo: backgroundImageView.widthAnchor,
            multiplier: 0.912647
        )
        imageHeightConstraint.priority = .defaultHigh
        imageHeightConstraint.isActive = true

        // Stack view constraints
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 16),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // Configure
    
    func configure(with card: ProductCard) {
        topDescriptionLabel.text = card.topDescription?.uppercased() ?? ""
        topDescriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        titleLabel.text = card.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        
//        if let data = card.imageData {
//                backgroundImageView.image = UIImage(data: data)
//            } else {
//                backgroundImageView.image = nil // placeholder if needed
//            }
//            
        if let data = card.imageData, let image = UIImage(data: data) {
            backgroundImageView.image = image
            
            // Adjust imageView height dynamically based on image aspect ratio
            let aspectRatio = image.size.height / image.size.width
            imageHeightConstraint?.isActive = false
            imageHeightConstraint = backgroundImageView.heightAnchor.constraint(equalTo: backgroundImageView.widthAnchor, multiplier: aspectRatio)
            imageHeightConstraint?.isActive = true
            
            // Notify table to recalc height
            if let tableView = self.superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
        } else {
            backgroundImageView.image = nil
        }
        
        promoMessageLabel.text = card.promoMessage ?? ""
        promoMessageLabel.isHidden = card.promoMessage == nil
        
        if let bottomHTML = card.bottomDescription {
            setBottomDescriptionWithLink(bottomHTML)
        } else {
            bottomDescriptionLabel.text = nil
        }
        
        buildContentButtons(content: card.content)
    }
    
    private func buildContentButtons(content: [ContentButton]?) {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        content?.forEach { item in
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.accessibilityHint = item.target
            button.addTarget(self, action: #selector(contentButtonTapped), for: .touchUpInside)

            button.setContentHuggingPriority(.required, for: .vertical)
            button.setContentCompressionResistancePriority(.required, for: .vertical)
            
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            
            contentStackView.addArrangedSubview(button)
        }
    }
    
    //Image Loading
    
    private func loadBackgroundImage(from urlString: String) {
        backgroundImageView.image = UIImage(named: "placeholder")
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.backgroundImageView.image = image
                
                // Update height dynamically
                let aspectRatio = image.size.height / image.size.width
                self.imageHeightConstraint?.isActive = false
                self.imageHeightConstraint = self.backgroundImageView.heightAnchor.constraint(
                    equalTo: self.backgroundImageView.widthAnchor,
                    multiplier: aspectRatio
                )
                self.imageHeightConstraint?.priority = .required
                self.imageHeightConstraint?.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.contentView.layoutIfNeeded()
                    self.backgroundImageView.alpha = 1.0
                }
                
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()

                
                UIView.transition(with: self.backgroundImageView,
                                  duration: 0.10,
                                  options: .transitionCrossDissolve,
                                  animations: nil,
                                  completion: nil)
            }
        }.resume()
    }
    
    // Bottom Label Link
    
    private func setBottomDescriptionWithLink(_ htmlText: String) {
        guard let data = htmlText.data(using: .utf8) else {
            bottomDescriptionLabel.text = htmlText
            return
        }
        
        if let attributed = try? NSMutableAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            let fullRange = NSRange(location: 0, length: attributed.length)
            attributed.enumerateAttribute(.link, in: fullRange, options: []) { value, range, _ in
                if value != nil {
                    attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
                    attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                }
            }
            
            bottomDescriptionLabel.attributedText = attributed
            bottomDescriptionLabel.textAlignment = .center
            bottomDescriptionLabel.isUserInteractionEnabled = true
            
                    
            bottomDescriptionLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomLinkTapped(_:)))
            bottomDescriptionLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func bottomLinkTapped(_ recognizer: UITapGestureRecognizer) {
        guard let attributedText = bottomDescriptionLabel.attributedText else { return }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bottomDescriptionLabel.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = bottomDescriptionLabel.lineBreakMode
        textContainer.maximumNumberOfLines = bottomDescriptionLabel.numberOfLines

        let location = recognizer.location(in: bottomDescriptionLabel)
        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        let attributes = attributedText.attributes(at: index, effectiveRange: nil)
        if let url = attributes[.link] as? URL {
            delegate?.exploreContentCell(self, didTapLink: url.absoluteString)

            if let cleanedURL = extractEmbeddedURL(from: url) {
                UIApplication.shared.open(cleanedURL)
            } else {
                UIApplication.shared.open(url)
            }
        }
    }
    private func extractEmbeddedURL(from url: URL) -> URL? {
        guard let rawString = url.absoluteString.removingPercentEncoding else { return nil }

        if let range = rawString.range(of: #"https?://[^\s"]+"#, options: .regularExpression) {
            let extracted = String(rawString[range]).replacingOccurrences(of: "\"", with: "")
            return URL(string: extracted)
        }

        return nil
    }
    
    // Button Action
    @objc private func contentButtonTapped(sender: UIButton) {
        if let urlString = sender.accessibilityHint {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }

}
