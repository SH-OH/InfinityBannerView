//
//  InfinityBannerView.swift
//  InfinityBannerView
//
//  Created by Oh Sangho on 2020/04/08.
//  Copyright © 2020 Oh Sangho. All rights reserved.
//

import UIKit

final class InfinityBannerView: UIView {
    
    // MARK: - Public
    
    /// AutoScroll starting index. never set 0 or last. default 1
    public var autoScrollIndex: Int = 1
    
    /// Auto Scroll Time(Seconds). default 5.0.
    public var scrollingTime: Double = 5.0
    
    // MARK: - Private
    
    private var timer: Timer?
    private var currentIndex: Int = 0
    private var banners: [String]? {
        didSet {
            self.reload()
        }
    }
    private var bannerCount: Int {
        guard let banners = self.banners, !banners.isEmpty else { return 0 }
        return banners.count
    }
    
    // MARK: - UI Components
    
    private weak var pageControl: UIPageControl!
    private weak var collectionView: UICollectionView!
    
    // MARK: - Con(De)structor
    
    init(images: [String]) {
        super.init(frame: .zero)
        self.banners = self.configDatas(images)
        setupView()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.invalidateTimer()
    }
    
    private func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.layoutIfNeeded()
        }
    }
    
    private func setupView() {
        collectionView = {
            let layout: UICollectionViewFlowLayout = .init()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            let cv: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.backgroundColor = self.backgroundColor
            cv.showsHorizontalScrollIndicator = false
            cv.isScrollEnabled = true
            cv.isPagingEnabled = true
            self.addSubview(cv)
            cv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            cv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            cv.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            cv.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            cv.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: "BannerCollectionViewCell")
            return cv
        }()
        pageControl = {
            let pc: UIPageControl = .init()
            pc.translatesAutoresizingMaskIntoConstraints = false
            pc.currentPageIndicatorTintColor = .white
            pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
            pc.currentPage = 0
            pc.contentVerticalAlignment = .bottom
            pc.isHidden = true
            self.collectionView.addSubview(pc)
            pc.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor).isActive = true
            pc.trailingAnchor.constraint(equalTo: self.collectionView.trailingAnchor, constant: -16).isActive = true
            return pc
        }()
    }
    
    private func setDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    // MARK: - Configure For Infinity
    
    private func configDatas(_ images: [String]) -> [String] {
        switch images.count {
        case 0:
            self.isHidden = true
            return images
        case 1:
            return images
        case 1...:
            var banners: [String] = images
            guard let first: String = images.first,
                let last: String = images.last else { return images }
            banners.append(first)
            banners.insert(last, at: 0)
            let ip: IndexPath = .init(row: autoScrollIndex, section: 0)
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
            }
            return banners
        case _:
            return images
        }
    }
    
    // MARK: - Timer Acion
    
    @objc private func startAutoScrolling() {
        let lastOffsetX = scrollViewOffsetX(lastIndex: 2)
        let currentOffsetX = collectionView.contentOffset.x
        self.autoScrollIndex = getAutoScrollIndex(item: self.autoScrollIndex)
        let endIndex = self.bannerCount - 1
        if currentOffsetX == lastOffsetX, self.autoScrollIndex == endIndex {
            let x: CGFloat = lastOffsetX + self.collectionView.frame.size.width
            let offset: CGPoint = CGPoint(x: x, y: 0)
            DispatchQueue.main.async {
                self.collectionView.setContentOffset(offset, animated: true)
                self.scrollViewDidScroll(self.collectionView)
                self.autoScrollIndex = 1
            }
        } else {
            let x: CGFloat = collectionView.frame.width * CGFloat(self.autoScrollIndex)
            let offset: CGPoint = CGPoint(x: x, y: 0)
            DispatchQueue.main.async {
                self.collectionView.setContentOffset(offset, animated: true)
            }
        }
        self.pageControl.currentPage = self.autoScrollIndex - 1
    }
    
    // MARK: - Scrolling
    
    private func scrollViewOffsetX(lastIndex: Int) -> CGFloat {
        return self.collectionView.frame.size.width * CGFloat(self.bannerCount-lastIndex)
    }
    
    private func getAutoScrollIndex(item: Int) -> Int {
        switch item {
        case let count where count == self.bannerCount - 1:
            return 1
        default:
            return item + 1
        }
    }
}

// MARK: - Timer

extension InfinityBannerView {
    private func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    private func refreshTimer() {
        guard timer == nil, bannerCount > 1 else {return}
        let interval: TimeInterval = .init(self.scrollingTime)
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(self.startAutoScrolling),
                                     userInfo: nil,
                                     repeats: true)
    }
}

// MARK: - UICollectionViewDataSource

extension InfinityBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.bannerCount >= 0 else { return 0 }
        return self.bannerCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell else {
            return .init()
        }
        if let banners = self.banners, !banners.isEmpty {
            let item = banners[indexPath.row]
            cell.configure(String(format: "%@ / row : %d", item, indexPath.row))
            switch indexPath.row {
            case 0:
                cell.contentView.backgroundColor = .red
            case 1:
                cell.contentView.backgroundColor = .blue
            case 2:
                cell.contentView.backgroundColor = .green
            case 3:
                cell.contentView.backgroundColor = .red
            case 4:
                cell.contentView.backgroundColor = .blue
            default:
                break
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

var count: Int = 0

extension InfinityBannerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard self.bannerCount > 1 else { return }
//        let lastIndex: Int = self.bannerCount - 1
//
//        //        print("willDisplay======================")
//        //        print("currentIndex : \(self.currentIndex)")
//        //        print("indexPath.row : \(indexPath.row)")
//
//        switch indexPath.row {
//        case 0:
//            /// if true, move to left(real last item). if false, move to right(real first item)
//            switch self.currentIndex {
//            case indexPath.row + 1:
//                self.scrollToItem(collectionView, at: IndexPath(row: lastIndex, section: 0), animated: false)
//            default:
//                self.scrollToItem(collectionView, at: IndexPath(row: 0, section: 0), animated: false)
//            }
//        case lastIndex:
//            switch self.currentIndex {
//            case indexPath.row - 1:
//                self.scrollToItem(collectionView, at: IndexPath(row: 0, section: 0), animated: false)
//            default:
//                self.scrollToItem(collectionView, at: IndexPath(row: lastIndex, section: 0), animated: false)
//            }
//        default:
//            self.currentIndex = indexPath.row
//            return
//        }
    }
    
    private func scrollToItem(_ collectionView: UICollectionView,
                              at indexPath: IndexPath,
                              animated: Bool) {
        DispatchQueue.main.async {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            self.currentIndex = indexPath.row
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard self.bannerCount > 1 else { return }
        let maxOffsetX = scrollViewOffsetX(lastIndex: 1)
        let targetOffsetX = targetContentOffset.pointee.x
        
//        print("maxOffsetX : \(maxOffsetX)")
//        print("currentOffsetX : \(targetOffsetX)")
//        print("velocity : \(velocity)")
        
        if targetOffsetX >= maxOffsetX {
            print("scrollViewWillEndDragging==================1")
//            pageControl.currentPage = 0
            let width: CGFloat = scrollView.bounds.width
            let currentOffsetX: CGFloat = maxOffsetX - scrollView.contentOffset.x
//            print("maxOffsetX : \(maxOffsetX)")
//            print("scrollView.contentOffset.x : \(scrollView.contentOffset.x)")
//            print("currentOffsetX : \(currentOffsetX)")
            
            
            let multiplierX: CGFloat = width - (maxOffsetX - scrollView.contentOffset.x)
            guard multiplierX / width >= 0.5 else {
                
                return
            }
            print("multiplierX / width >= 0.5 : \(multiplierX / width >= 0.5)")
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: .init(row: 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        } else if targetOffsetX < 10 {
            print("scrollViewWillEndDragging==================2")
//            pageControl.currentPage = bannerCount - 2
            let lastIndex: Int = self.bannerCount - 1
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: .init(row: lastIndex - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        } else {
            print("scrollViewWillEndDragging==================3")
            if abs(velocity.x) > abs(velocity.y) {
                var value: Int = 1
                if velocity.x < 0 {
                    value = -1
                }
                pageControl.currentPage += value
            }
        }
    }
    
}

// MARK: - UICollectionViewFlowLayout

extension InfinityBannerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize = self.bounds.size
        return size
    }
}

// MARK: - UIScrollViewDelegate

extension InfinityBannerView {
    @nonobjc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let banners = self.banners, !banners.isEmpty else { return }
        guard scrollView.contentOffset.x < 10 ||
            scrollView.contentOffset.x > scrollViewOffsetX(lastIndex: 1)-10 else {return}
        
        let maxOffsetX = scrollViewOffsetX(lastIndex: 1)
        let currentOffsetX = scrollView.contentOffset.x
        
        if currentOffsetX >= maxOffsetX {
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
        } else if currentOffsetX == 0 {
            scrollView.contentOffset = CGPoint(x: scrollViewOffsetX(lastIndex: 2), y: 0)
        }
    }
}
