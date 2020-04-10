//
//  BannerCollectionViewCell.swift
//  InfinityBannerView
//
//  Created by Oh Sangho on 2020/04/09.
//  Copyright © 2020 Oh Sangho. All rights reserved.
//

import UIKit.UICollectionViewCell

final class BannerCollectionViewCell: UICollectionViewCell {
    
    private weak var bannerLabel: UILabel!
    private weak var bannerImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bannerLabel.text = nil
        bannerImageView.image = nil
    }
    
    func configure(_ text: String) {
        bannerLabel.text = text
    }
    
    func configure(_ image: UIImage) {
        bannerImageView.image = image
    }
    
    private func setupView() {
        contentView.backgroundColor = .red
        bannerLabel = {
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = ""
            contentView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            return label
        }()
        bannerImageView = {
            let imageView: UIImageView = .init()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(imageView)
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            return imageView
        }()
    }
}
