//
//  TopHeadlinesCell.swift
//  Deliberate-1
//
//  Created by Fernando Putallaz on 07/06/2023.
//

import UIKit

class TopHeadlinesCell: UITableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let contentlabel = UILabel()
    let contentContainer = UIView()
    let imageContainer = UIView()
    let feedImageView = UIImageView()
    var onRetry: (() -> Void)?
        
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    @objc func retryButtonTapped() {
        onRetry?()
    }
    
}

