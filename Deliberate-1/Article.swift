//
//  Article.swift
//  Deliberate-1
//
//  Created by Fernando Putallaz on 07/06/2023.
//

import Foundation

public struct Article {
    let title: String
    let description: String
    let URL: URL?
    let imageURL: URL
    let publishedAt: Date?
    let content: String?
    
    public init(title: String, description: String, URL: URL?, imageURL: URL, publishedAt: Date?, content: String?) {
        self.title = title
        self.description = description
        self.URL = URL
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        self.content = content
    }
}
