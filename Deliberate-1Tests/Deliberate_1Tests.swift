//
//  Deliberate_1Tests.swift
//  Deliberate-1Tests
//
//  Created by Fernando Putallaz on 25/05/2023.
//

import XCTest
@testable import Deliberate_1

struct Article {
    let name: String
}

class TopHeadlinesViewController: UITableViewController {
    var articles: [Article] = []
    
    convenience init(articles: [Article]) {
        self.init()
        self.articles = articles
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
}

class Deliberate_1Tests: XCTestCase {
    
    func test_emptyTableView() {
        let sut = makeSUT(articles: [Article]())
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
    }
    
    func test_oneArticle() {
        let sut = makeSUT(articles: [Article(name: "A name")])
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
    }
    
    // MARK: - Helpers
    
    func makeSUT(articles: [Article]) -> TopHeadlinesViewController {
        let sut = TopHeadlinesViewController(articles: articles)
        
        return sut
    }
}
