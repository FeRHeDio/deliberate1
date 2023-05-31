//
//  Deliberate_1Tests.swift
//  Deliberate-1Tests
//
//  Created by Fernando Putallaz on 25/05/2023.
//

import XCTest
import UIKit

public struct Article {
    let title: String
    let description: String
    let URL: URL?
    let imageURL: URL
    let publishedAt: Date?
    let content: String?
    
    init(title: String, description: String, URL: URL?, imageURL: URL, publishedAt: Date?, content: String?) {
        self.title = title
        self.description = description
        self.URL = URL
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        self.content = content
    }
}

public protocol NewsLoader {
    typealias NewsLoaderResult = Result<[Article], Error>
    
    func load(completion: @escaping (NewsLoaderResult) -> Void)
}

final class TopHeadlinesViewController: UITableViewController {
    private var articleModel = [Article]()
    private var loader: NewsLoader?
    
    convenience init(loader: NewsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            
            switch result {
            case .success(let articles):
                self?.articleModel = articles
                
            case .failure(let error):
                print("error: \(error) ")
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articleModel.count
    }
}

class Deliberate_1Tests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut , loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
    
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected loading requests once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected loading requests when manually reload the view")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected loading requests when the user requested another loading")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingTopHeadlines() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator when the view present itself")

        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator when the load completes")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator when the user reloads the feed manually")
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator when the manual loading finishes")
    }
    
    func test_loadFeedCompletion_renderFeed() {
        let item0 = makeItem(title: "A new title", description: "Some description of the news to know.")
        
        let item1 = makeItem(title: "Another title", description: "Some new description of the news to know.")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [item0, item1], at: 0)
        XCTAssertEqual(sut.numberOfRenderedNewsArticles(), 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TopHeadlinesViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = TopHeadlinesViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeItem(title: String, description: String, URL: URL? = nil, imageURL: URL = URL(string: "http://www.a-url.com")!, publishedAt: Date? = nil, content: String? = nil ) -> Article {
            
        return Article(title: title, description: description, URL: URL, imageURL: imageURL, publishedAt: publishedAt, content: content)
    }
    
    class LoaderSpy: NewsLoader {
        private(set) var completions = [(NewsLoaderResult) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (NewsLoaderResult) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with model: [Article] = [], at index: Int) {
            completions[index](.success(model))
        }
    }
}

private extension TopHeadlinesViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedNewsArticles() -> Int {
        tableView.numberOfRows(inSection: newsArticles)
    }
    
    private var newsArticles: Int { 0 }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
