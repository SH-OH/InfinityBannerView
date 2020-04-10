//
//  ViewController.swift
//  InfinityBannerView
//
//  Created by Oh Sangho on 2020/04/08.
//  Copyright © 2020 Oh Sangho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let datas: [BannerModel] = [
        .init(title: "첫번째", image: "1i1i1i1i1i"),
        .init(title: "두번째", image: "2i2i2i2i2i"),
        .init(title: "마지막", image: "3i3i3i3i3i3i")
    ]
    private lazy var titles: [String] = self.datas.map { $0.title }
    private lazy var images: [String] = self.datas.map { $0.image }
    
    private weak var bannerView: InfinityBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .cyan
        bannerView = {
            let bv: InfinityBannerView = .init(images: titles)
            bv.translatesAutoresizingMaskIntoConstraints = false
            bv.scrollingTime = 2.0
            self.view.addSubview(bv)
            bv.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            bv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            bv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            bv.heightAnchor.constraint(equalToConstant: 150).isActive = true
            return bv
        }()
    }

}

struct BannerModel {
    let title: String
    let image: String
}
