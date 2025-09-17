//
//  ArticleTableViewCell.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 16/09/25.
//

import UIKit

protocol ArticleTableViewCellDelegate: AnyObject {
    func articleCellDidToggleBookmark(_ cell: ArticleTableViewCell, article: Article)
}

class ArticleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ArticleCell"
    
    weak var delegate: ArticleTableViewCellDelegate?
    private var currentArticle: Article?
    
    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clockImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "clock")
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timestampStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [clockImageView, timestampLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "bookmark")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var metadataStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sourceLabel, timestampStack, bookmarkButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headlineLabel, metadataStack])
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 96),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 96),
            
            textStack.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            clockImageView.widthAnchor.constraint(equalToConstant: 12),
            clockImageView.heightAnchor.constraint(equalToConstant: 12),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 24),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        currentArticle = nil
    }
    
    func configure(with article: Article) {
        currentArticle = article
        headlineLabel.text = article.title ?? "No Title"
        sourceLabel.text = article.source?.name ?? "—"
        if let publishedAt = article.publishedAt {
            timestampLabel.text = publishedAt.timeAgo()
        } else {
            timestampLabel.text = "No Date"
        }
        
        let iconName = article.isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        if let urlString = article.urlToImage, let url = URL(string: urlString) {
            ImageLoader.shared.load(url: url) { [weak self] img in
                DispatchQueue.main.async {
                    self?.thumbnailImageView.image = img ?? UIImage(systemName: "photo")
                }
            }
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }
    }
    
    @objc private func bookmarkTapped() {
        guard let article = currentArticle else { return }
        
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.impactOccurred()
        UIView.animate(withDuration: 0.12, animations: {
            self.bookmarkButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.bookmarkButton.transform = .identity
            }
        }
        delegate?.articleCellDidToggleBookmark(self, article: article)
    }
}
