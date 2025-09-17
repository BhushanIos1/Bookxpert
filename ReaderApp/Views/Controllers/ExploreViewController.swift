//
//  ExploreViewController.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import UIKit
import SafariServices

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var mainTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private let loader = UIActivityIndicatorView(style: .large)
    
    // MARK: - ViewModel
    var viewModel: ArticleListViewModel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.mySearchBar.delegate = self
        self.setupLoader()
        self.bindViewModel()
        
        Task {
            await self.viewModel.loadArticles()
        }
    }
    
    private func setup() {
        self.title = "Top Headlines"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        self.hideKeyboardWhenTappedAround()
        
        self.mainTableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
        self.mainTableView.refreshControl = refreshControl
        
        self.refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
    }
    
    private func setupLoader() {
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self else { return }
            DispatchQueue.main.async {
                if isLoading {
                    if !self.refreshControl.isRefreshing {
                        self.loader.startAnimating()
                    }
                } else {
                    self.loader.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        
        viewModel.onArticlesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.mainTableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func refreshPulled() {
        self.mySearchBar.text = ""
        view.endEditing(true)
        Task {
            await viewModel.refreshArticles()
        }
    }
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSource, ArticleTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfArticles()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = ArticleTableViewCell()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseIdentifier, for: indexPath) as? ArticleTableViewCell else {
            fatalError("Unable to dequeue ArticleTableViewCell")
        }
        let article = self.viewModel.article(at: indexPath.row)
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
        let article = viewModel.article(at: indexPath.row)
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

extension ExploreViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.search(query: searchText)
    }
}

extension ExploreViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("SafariViewController was dismissed.")
    }
}
