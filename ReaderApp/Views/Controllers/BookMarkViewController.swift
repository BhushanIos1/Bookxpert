//
//  BookMarkViewController.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import UIKit
import SafariServices

class BookMarkViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var viewModel: BookmarkViewModel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
        self.bindViewModel()
        
        self.viewModel.loadBookmarks()
    }
    
    private func setup() {
        self.title = "Bookmarks"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        self.mainTableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.onBookmarksUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.mainTableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}

extension BookMarkViewController: UITableViewDelegate, UITableViewDataSource, ArticleTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewModel.numberOfBookmarks() == 0 {
            tableView.setEmptyMessage("No Bookmarks available.")
        } else {
            tableView.restore()
        }
        return self.viewModel.numberOfBookmarks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseIdentifier, for: indexPath) as? ArticleTableViewCell else {
            fatalError("Unable to dequeue ArticleTableViewCell")
        }
        let article = viewModel.bookmark(at: indexPath.row)
        cell.configure(with: article)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.bookmark(at: indexPath.row)
        if let urlString = article.url, let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            safariVC.preferredControlTintColor = .systemBlue
            safariVC.dismissButtonStyle = .done
            
            present(safariVC, animated: true)
        }
    }
    
    func articleCellDidToggleBookmark(_ cell: ArticleTableViewCell, article: Article) {
        self.viewModel.toggleBookmark(for: article)
    }
}


extension BookMarkViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("SafariViewController was dismissed.")
    }
}
