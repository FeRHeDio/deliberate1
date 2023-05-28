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
    let URL: URL
    let imageURL: URL
    let publishedAt: Date
    let content: String
}

public protocol NewsLoader {
    typealias NewsLoaderResult = Result<[Article], Error>
    
    func load(completion: @escaping (NewsLoaderResult) -> Void)
}

final class TopHeadlinesViewController: UIViewController {
    private var loader: NewsLoader?
    
    convenience init(loader: NewsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        loader?.load { _ in }
    }
}

class Deliberate_1Tests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_ , loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsNews() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TopHeadlinesViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = TopHeadlinesViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: NewsLoader {
        func load(completion: @escaping (NewsLoaderResult) -> Void) {
            loadCallCount += 1
        }
        
        private(set) var loadCallCount = 0
    }
}


