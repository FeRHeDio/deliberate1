//
//  TopHeadlinesViewController.swift
//  Deliberate-1
//
//  Created by Fernando Putallaz on 07/06/2023.
//

import UIKit

final public class TopHeadlinesViewController: UITableViewController {
    private var articleModel = [Article]()
    private var newsFeedLoader: NewsLoader?
    private var imageLoader: FeedImageLoader?
    private var tasks = [IndexPath: FeedImageLoaderTask]()
    
    public convenience init(loader: NewsLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.newsFeedLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
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
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articleModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = articleModel[indexPath.row]
        let cell = TopHeadlinesCell()
        cell.titleLabel.text = cellModel.title
        cell.descriptionLabel.text = cellModel.description
        cell.contentlabel.text = cellModel.content
        cell.contentContainer.isHidden = (cellModel.content == nil)
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.imageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImage(from: cellModel.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.imageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
