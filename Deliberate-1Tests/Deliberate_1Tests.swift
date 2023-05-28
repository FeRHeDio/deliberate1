//
//  Deliberate_1Tests.swift
//  Deliberate-1Tests
//
//  Created by Fernando Putallaz on 25/05/2023.
//

import XCTest
import UIKit

final class TopHeadlinesViewController: UIViewController {
    private var loader: Deliberate_1Tests.LoaderSpy?
    
    convenience init(loader: Deliberate_1Tests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        loader?.load()
    }
}

class Deliberate_1Tests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = TopHeadlinesViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsNews() {
        let loader = LoaderSpy()
        let sut = TopHeadlinesViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
