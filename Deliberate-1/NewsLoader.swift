//
//  NewsLoader.swift
//  Deliberate-1
//
//  Created by Fernando Putallaz on 07/06/2023.
//

import Foundation

public protocol NewsLoader {
    typealias NewsLoaderResult = Result<[Article], Error>
    
    func load(completion: @escaping (NewsLoaderResult) -> Void)
}
