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
        imageV.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        imageV.contentMode = .scaleAspectFill
        imageV.layer.masksToBounds = true
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
public enum BannerDisplayType {
    case `default`
    case card
}
fileprivate class  BannerCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var displayType: BannerDisplayType
    var size: CGSize
    init(displayType: BannerDisplayType = .default, size: CGSize) {
        self.displayType = displayType
        self.size = size
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepare() {
        super.prepare()
        itemSize = self.size
        scrollDirection = .horizontal
        estimatedItemSize = .zero
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        sectionInset = .zero
        headerReferenceSize = .zero
        footerReferenceSize = .zero
    }
    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let collectionView = collectionView else {  return super.layoutAttributesForElements(in: rect) }
//        let arr = super.layoutAttributesForElements(in: rect)
//        let currentPageIndex = Int(round(currentScrollOffset))
////        let sections = collectionView.numberOfSections
////        let indexPaths = [Int](0..<sections).reduce([IndexPath](), {
////            result, section  in
////            let rows = collectionView.numberOfItems(inSection: section)
////            let indexPs = [Int](0..<rows).reduce([IndexPath](), {
////                res, row in
////                return res + [IndexPath(item: row, section: section)]
////            })
////            return result + indexPs
////        })
////        if let nextIndexPath = indexPaths.filter({
////            $0.section * collectionView.numberOfItems(inSection: $0.section) + $0.item == currentPageIndex
////        }).first {
////            let progress = CGFloat(currentPageIndex + 1) - currentScrollOffset
////            print(progress)
////        }
//        (arr ?? []).forEach({ attr in
//            attr.frame = self.visibleRect
//            let indexPath = attr.indexPath
//            let totalIndex = indexPath.section * collectionView.numberOfItems(inSection: indexPath.section) + indexPath.item
//            let progress = CGFloat(totalIndex) - currentScrollOffset
//            var zIndex = Int(-abs(round(progress)))
//            attr.zIndex = zIndex
//            
//            var transform = CGAffineTransform.identity
//            var xAdjustment: CGFloat = 0
//            var yAdjustment: CGFloat = 0
//            var scale = 1 - progress
//            scale = max(scale, 0.6)
//            scale = min(scale, 0.9)
//            
//        })
//        
//        return arr
//    }
//    
//    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
    
    private var currentScrollOffset: CGFloat {
        let visibleRect = self.visibleRect
        return scrollDirection == .horizontal ? (visibleRect.minX / max(visibleRect.width, 1)) : (visibleRect.minY / max(visibleRect.height, 1))
    }
    
    private var visibleRect: CGRect {
        collectionView.map { CGRect(origin: $0.contentOffset, size: $0.bounds.size) } ?? .zero
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
    
    public var playDuration: TimeInterval = 4
    public var collectionView: UICollectionView!
    public var isCanAutoPlay: Bool = true
    public var isShowPageControl: Bool = false {
        didSet {
            pageControl.isHidden = !isShowPageControl
        }
    }
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
        let layout = BannerCollectionViewFlowLayout(size: itemSize)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = UIColor.clear
        addSubview(collectionView)
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.cellName)
        
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(-8)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.ss_origin = .zero
        collectionView.ss_size = itemSize
    }
    
    func startPlay() {
        guard imageUrls.count > 1, isCanAutoPlay else {
            return
        }
        
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
                DispatchQueue.main.async {
                    CATransaction.begin()
                    self.collectionView.setContentOffset(point, animated: true)
                    CATransaction.commit()
                    
//                    UIView.animate(withDuration: 0.25, delay: 0, animations: {
//                        self.collectionView.contentOffset = point
//                    })
                }
               
            }
            
        }
        RunLoop.main.add(timer!, forMode: .common)
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
        cell.imageV.imageUrl(url: self.imageUrls[indexPath.row], isAnimated: false)
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
        startPlay()
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
  
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endPlay()
    }
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        endPlay()
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startPlay()
        }
    }
}
