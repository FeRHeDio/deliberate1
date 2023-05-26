//
//  Deliberate_1Tests.swift
//  Deliberate-1Tests
//
//  Created by Fernando Putallaz on 25/05/2023.
//

import XCTest
@testable import Deliberate_1

struct Articles {
    
}

class TopHeadlinesViewController: UITableViewController {
    convenience init(topHeadlines: [Articles]) {
        self.init()
    }
}

class Deliberate_1Tests: XCTestCase {
    
    func test_emptyTableView() {
        let topHeadlines = [Articles]()
        let sut = TopHeadlinesViewController(topHeadlines: topHeadlines)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
    }
}
