//
//  BannerView.swift
//  SSUtils
//
//  Created by yangsq on 2022/2/14.
//

import UIKit


class BannerCell: UICollectionViewCell {
    public lazy var imageV: UIImageView = {
        let imageV = UIImageView()
        imageV.backgroundColor = UIColor.lightGray
        imageV.contentMode = .scaleAspectFill
        return imageV
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class BannerView: UIView, EventTrigger {

    public enum Event {
        case selected(index: Int)
    }
    
    lazy var pageControl: CustomPageControl = {
        let view = CustomPageControl()
        view.pageIndicatorNormalColor = UIColor.hex(0xffffff).withAlphaComponent(0.5)
        view.pageIndicatorSelectedColor = UIColor.hex(0xffffff)
        view.pageIndicatorSize = CGSize(width: 4, height: 4)
        view.currentPageIndicatorSize = CGSize(width: 8, height: 4)
        view.hidesForSinglePage = true
        return view
    }()
    
    public var playDuration: TimeInterval = 2
    public var collectionView: UICollectionView!
    public var isCanAutoPlay: Bool = false
    public var imageUrls: [String?] = [] {
        didSet {
            pageControl.numOfPages = imageUrls.count
            collectionView.reloadData()
            if imageUrls.count > 1 {
                collectionView.layoutIfNeeded()
                DispatchQueue.main.async {
                    [weak self] in guard let self = self else { return }
                    let section = self.collectionView.numberOfSections
                    let point = CGPoint(x: self.itemSize.width * CGFloat(self.imageUrls.count) * CGFloat(section / 100), y: 0)
                    self.collectionView.setContentOffset(point, animated: false)
                    self.endPlay()
                    self.startPlay()
                }
            }

           
        }
    }
    
    private var itemSize: CGSize
    private var timer: Timer?
    public init(itemSize: CGSize) {
        self.itemSize = itemSize
        super.init(frame: .zero)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.cellName)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(-8)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
        }
    }
    
    
    func startPlay() {
        timer = Timer.scheduledTimer(withTimeInterval: playDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let indexPath = self.collectionView.indexPathForItem(at: CGPoint(x: self.collectionView.contentOffset.x + 1, y: 1)) {
                var section = indexPath.section
                var row = indexPath.row + 1
                if indexPath.row == self.collectionView.numberOfItems(inSection: indexPath.section) {
                    section += 1
                    row = 0
                }
                let point = CGPoint(x: self.itemSize.width * CGFloat(self.imageUrls.count) * CGFloat(section) + self.itemSize.width * CGFloat(row), y: 0)
                self.collectionView.setContentOffset(point, animated: true)
            }
            
        }
        RunLoop.main.add(timer!, forMode: .default)
    }
    
    func endPlay() {
        timer?.invalidate()
        timer = nil
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    

}

extension BannerView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.cellName, for: indexPath) as! BannerCell
        cell.imageV.kf.setImage(with: URL(string: self.imageUrls[indexPath.row] ?? ""))
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard imageUrls.count > 1 else {
            return 1
        }
        return 200
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.imageUrls.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let trigger = self.triggerEvent {
            trigger(.selected(index: indexPath.row))
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = collectionView.indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x + 1, y: 1))?.row ?? 0
        self.pageControl.currentPageNum = page
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard imageUrls.count > 1 else {
            return
        }
        let indexPath = collectionView.indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x + 1, y: 1))
        let section = collectionView.numberOfSections
        if indexPath?.section == 0 || indexPath?.section == section - 1 {
            collectionView.scrollToItem(at: IndexPath(item: indexPath?.row ?? 0, section: section / 2), at: UICollectionView.ScrollPosition.left, animated: false)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard imageUrls.count > 1 else {
            return
        }
        let indexPath = collectionView.indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x + 1, y: 1))
        let section = collectionView.numberOfSections
        if indexPath?.section == 0 || indexPath?.section == section - 1 {
            collectionView.scrollToItem(at: IndexPath(item: indexPath?.row ?? 0, section: section / 2), at: UICollectionView.ScrollPosition.left, animated: false)
        }
    }
  
}
