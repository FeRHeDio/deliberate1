//
//  FeedImageLoader.swift
//  Deliberate-1
//
//  Created by Fernando Putallaz on 07/06/2023.
//

import Foundation

public protocol FeedImageLoaderTask {
    func cancel()
}

public protocol FeedImageLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageLoaderTask
}
