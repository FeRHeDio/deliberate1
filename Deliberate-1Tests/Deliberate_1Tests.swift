//
//  Deliberate_1Tests.swift
//  Deliberate-1Tests
//
//  Created by Fernando Putallaz on 25/05/2023.
//

import XCTest
import UIKit

class TopHeadlinesCell: UITableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let contentlabel = UILabel()
    let contentContainer = UIView()
    
}

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

public protocol FeedImageLoader {
    func loadImage(from url: URL)
    func cancelLoading(from url: URL)
}

final class TopHeadlinesViewController: UITableViewController {
    private var articleModel = [Article]()
    private var newsFeedLoader: NewsLoader?
    private var imageLoader: FeedImageLoader?
    
    convenience init(loader: NewsLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.newsFeedLoader = loader
        self.imageLoader = imageLoader
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        newsFeedLoader?.load { [weak self] result in
            if let headlines = try? result.get() {
                self?.articleModel = headlines
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articleModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = articleModel[indexPath.row]
        let cell = TopHeadlinesCell()
        cell.titleLabel.text = cellModel.title
        cell.descriptionLabel.text = cellModel.description
        cell.contentlabel.text = cellModel.content
        cell.contentContainer.isHidden = (cellModel.content == nil)
        
        imageLoader?.loadImage(from: cellModel.imageURL)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = articleModel[indexPath.row]
        imageLoader?.cancelLoading(from: cellModel.imageURL)
    }
}

class Deliberate_1Tests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut , loader) = makeSUT()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 0, "Expected no loading requests before view is loaded")
    
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 1, "Expected loading requests once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 2, "Expected loading requests when manually reload the view")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 3, "Expected loading requests when the user requested another loading")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingTopHeadlines() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator when the view present itself")

        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator when the load completes succesfully")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator when the user reloads the feed manually")
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator when the manual loading finishes with an error")
    }
    
    func test_loadFeedCompletion_renderNumberOfItemsOnFeed() {
        let item0 = makeItem(title: "A new title", description: "Some description of the news to know.", content: "a Long long content.. but not so long, a few more lines, nothing more that this long, at least I guess.")
        let item1 = makeItem(title: "Another title", description: "Some new description of the news to know.", content: nil)
        let item2 = makeItem(title: "Some exiting news", description: "The kind of sexy description")
        let item3 = makeItem(title: "The Pope was killed", description: "Not really, just a heads up for you to pay attention", content: "Some stupidity to try to convey a message here.")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedNewsArticles(), 0)
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [item0], at: 0)
        assertThat(sut, isRendering: [item0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [item0, item1, item2, item3], at: 1)
        assertThat(sut, isRendering: [item0, item1, item2, item3])
    }
    
    func test_loadCompletion_notAlterTheCurrentFeedOnError() {
        let item = makeItem(title: "some", description: "some")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item], at: 0)
        assertThat(sut, isRendering: [item])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [item])
    }
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let itemWithImage0 = makeItem(title: "some title a", description: "a description", imageURL: URL(string: "http://www.a-url.com")!)
        let itemWithImage1 = makeItem(title: "some title b", description: "b description", imageURL: URL(string: "http://www.b-url.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [itemWithImage0, itemWithImage1], at: 0)
        
        XCTAssertEqual(loader.loadedImagesURLs, [], "Expected no image URL requests until view becomes visible")
        
        sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImagesURLs, [itemWithImage0.imageURL])
        
        sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImagesURLs, [itemWithImage0.imageURL, itemWithImage1.imageURL])
    }
    
    func test_feedImageView_cancelImageLoadingWhenViewIsNotVisible() {
        let itemWithImage0 = makeItem(title: "some title a", description: "a description", imageURL: URL(string: "http://www.a-url.com")!)
        let itemWithImage1 = makeItem(title: "some title b", description: "b description", imageURL: URL(string: "http://www.b-url.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [itemWithImage0, itemWithImage1], at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [])
        
        sut.simulateImageNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [itemWithImage0.imageURL])
        
        sut.simulateImageNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [itemWithImage0.imageURL, itemWithImage1.imageURL])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TopHeadlinesViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = TopHeadlinesViewController(loader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: TopHeadlinesViewController, isRendering newsFeed: [Article], file: StaticString = #file, line: UInt = #line) {
        guard newsFeed.count == sut.numberOfRenderedNewsArticles() else {
            return XCTFail("Expected \(newsFeed.count) articles, but got \(sut.numberOfRenderedNewsArticles())", file: file, line: line)
        }
        
        newsFeed.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index)
        }
    }
    
    private func assertThat(_ sut: TopHeadlinesViewController, hasViewConfiguredFor item: Article, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.topHeadLinesView(at: index)
        
        guard let cell = view as? TopHeadlinesCell else {
            return XCTFail("Expected \(TopHeadlinesCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldContentBeVisible = (item.content != nil)

        
        XCTAssertEqual(cell.titleText, item.title, "Expected content to be \(String(describing: item.title)) for item at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, item.description, "Expected content to be \(String(describing: item.description)) for item at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.contentText, item.content, "Expected content to be \(String(describing: item.content)) for item at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.isShowingContent, shouldContentBeVisible, "Expected `isShowingContent` to be \(shouldContentBeVisible) for content view at index (\(index))", file: file, line: line)
        
    }
    
    private func makeItem(title: String, description: String, URL: URL? = nil, imageURL: URL = URL(string: "http://www.a-url.com")!, publishedAt: Date? = nil, content: String? = nil ) -> Article {
            
        return Article(title: title, description: description, URL: URL, imageURL: imageURL, publishedAt: publishedAt, content: content)
    }
    
    class LoaderSpy: NewsLoader, FeedImageLoader {
        
        //MARK: NewsLoader
        
        private(set) var completions = [(NewsLoaderResult) -> Void]()
        
        var loadNewsFeedCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (NewsLoaderResult) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with model: [Article] = [], at index: Int) {
            completions[index](.success(model))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = anyNSError()
            completions[index](.failure(error))
        }
        
        //MARK: FeedImageLoader
        
        private(set) var loadedImagesURLs = [URL]()
        private(set) var canceledImageURLs = [URL]()
        
        func loadImage(from url: URL) {
            loadedImagesURLs.append(url)
        }
        
        func cancelLoading(from url: URL) {
            canceledImageURLs.append(url)
        }
    }
}

public func anyNSError() -> NSError {
    return NSError(domain: "error", code: 0)
}

private extension TopHeadlinesCell {
    var isShowingContent: Bool {
        return !contentContainer.isHidden
    }
    
    var titleText: String? {
        return titleLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var contentText: String? {
        return contentlabel.text
    }
}

private extension TopHeadlinesViewController {
    func simulateImageNotVisible(at row: Int) {
        let view = simulateImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: topHeadLinesSection)
        
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: index)
    }
    
    @discardableResult
    func simulateImageViewVisible(at index: Int) -> TopHeadlinesCell {
        topHeadLinesView(at: index) as! TopHeadlinesCell
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func topHeadLinesView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: topHeadLinesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var topHeadLinesSection: Int {
        return 0
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
