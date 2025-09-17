# Bookxpert

An iOS Reader app that fetches and displays news articles using NewsAPI.org. The app supports offline viewing, dynamic UI, bookmarking, and search functionality. Built with clean architecture and MVVM.


## Features

##*Fetch Articles

* Fetch top headlines via REST API (URLSession).
* Display article title, author, and thumbnail image.
* Offline Caching

##*Articles stored locally using Core Data.

*Shows cached data when offline.
*Pull-to-Refresh
*Refresh article list with UIRefreshControl.
*Search Articles
*Search bar filters articles by title.
*Bookmark/unbookmark articles.
*Bookmarks appear in a separate "Bookmarks" tab.

##Architecture
*MVVM + Clean Architecture
*Networking: NewsAPIClient + URLSessionHTTPClient
*Timeout and network connectivity checks included
*Persistence: CoreDataArticlePersistence
*ViewModels: ArticleListViewModel, BookmarkViewModel
*Views: ArticleViewController, BookmarkViewController (UITableView with dynamic layout)
*For Image downloading using ImageLoader (a custom Cache and Downloading Class)

##UI
*Built with UIKit and Auto Layout
*Fully adaptive for all iPhone devices
*Supports Light/Dark Mode


##Build and run on simulator or device.

##Testing
Basic unit tests included for models, view models, and bookmarks.
Run tests in Xcode with Cmd+U.
