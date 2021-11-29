//
//  ImageBrowseView.swift
//  SSUtils
//
//  Created by yangsq on 2021/10/13.
//

import UIKit
import SSAlertSwift
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class SaveActivity: UIActivity {
    
}

//class CustomPanGestureRecognizer: UIGestureRecognizer {
//
//    private var beginPoint: CGPoint = .zero
//    private var movePoint: CGPoint = .zero
//    private var newTouch: UITouch!
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesBegan(touches, with: event)
//        let touch = touches.first!
//        let point = touch.location(in: self.view)
//        beginPoint = point
//
//    }
//
//
//
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesMoved(touches, with: event)
//        let touch = touches.first!
//        newTouch = touch
//        let point = touch.location(in: self.view)
//        movePoint = point
//        if point.y > beginPoint.y && abs(point.x - beginPoint.x) < 40 {
//            self.state = .began
//            self.state = .changed
//        } else {
//            self.state = .failed
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesEnded(touches, with: event)
//        self.state = .ended
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
//        super.touchesCancelled(touches, with: event)
//        self.state = .cancelled
//    }
//    open func translation(in view: UIView?) -> CGPoint {
//        let previousPoint = view!.convert(beginPoint, to: view)
//        let point = view!.convert(movePoint, to: view)
//        return CGPoint(x: point.x - previousPoint.x, y: point.y - previousPoint.y)
//    }
//
//
//    override func reset() {
//        super.reset()
//        beginPoint = .zero
//    }
//
//}

class CustomCollectionView: UICollectionView {
    
}


class  ImageBrowseAnimation: NSObject, SSAlertAnimation {
    private var animationView: SSAlertView? = nil

    func animationDuration() -> TimeInterval {
        0.35
    }
    
    func showAnimationOfAnimationView(animationView: SSAlertView, viewSize: CGSize, animated: Bool, completion: (((Bool) -> Void))?) {
        guard let animationSuperView = animationView.superview else {
            return
        }
        self.animationView = animationView
        animationView.alpha = 0
        animationView.ss_size = viewSize
        let browseView = animationView.customView as? ImageBrowseView
        browseView?.startAnimation()
        UIView.animate(withDuration: animationDuration(), delay: 0, options: [.layoutSubviews], animations: {
            animationView.alpha = 1
            animationView.backgroundMask?.alpha = 1
            browseView?.showAnimation()
        }, completion: completion)
      
      
    }
    
    func hideAnimationOfAnimationView(animationView: SSAlertView, viewSize: CGSize, animated: Bool, completion: (((Bool) -> Bool))?) {
        self.animationView = animationView
        let browseView = animationView.customView as? ImageBrowseView
        UIView.animate(withDuration: animationDuration(), delay: 0, options: [.layoutSubviews], animations: {
            browseView?.hideAnimation()
        }, completion: {
            finished in
            var isCancel = false
            if let completion = completion {
               isCancel = completion(finished)
            }
            if finished && !isCancel {
                animationView.removeFromSuperview()
                animationView.backgroundMask?.removeFromSuperview()
            }
        })
    }
    
    func refreshAnimationOfAnimationView(animationView: SSAlertView, viewSize: CGSize, animated: Bool, completion: (((Bool) -> Void))?) {
        
    }
    
    func panToDimissTransilatePoint(point: CGPoint, panViewFrame: CGRect) -> CGFloat {
       return 0
    }
    
    
}

public struct ImageBrowse {
    public var thumbImage: UIImage?
    public var thumbImageUrl: String?
    public var largeImage: UIImage?
    public var largeImageUrl: String?
    public var fromImageV: UIImageView?
    public init() {
        
    }
  
}

public class ImageBrowseCellVM: NSObject {
    let progress = BehaviorRelay<CGFloat>(value: 1)
    let image = ReplaySubject<(size: CGSize, image: UIImage)>.create(bufferSize: 1)
    let startDownload = ReplaySubject<Void>.create(bufferSize: 1)
    var zoomScale: CGFloat = 1
    var isDoubleTap: Bool = false
    var browse: ImageBrowse
    let downloadCompletion = PublishSubject<(String, UIImage?)>()
    public init(browse: ImageBrowse) {
        self.browse = browse
        super.init()
        if let largeImage = browse.largeImage {
            self.progress.accept(1)
            image.onNext((size: calculateImageViewSize(size: largeImage.size), image: largeImage))
        } else if let thumbImage = browse.thumbImage {
            image.onNext((size: calculateImageViewSize(size: thumbImage.size), image: thumbImage))
        } else if let thumbUrl = browse.thumbImageUrl, let Url = URL(string: thumbUrl) {
            startDownload.subscribe(onNext: {
                KF.url(Url).onSuccess({
                    [weak self] result in
                    guard let self = self else { return }
                    let size = self.calculateImageViewSize(size: result.image.size)
                    self.image.onNext((size, result.image))
                }).set(to: UIImageView())
            }).disposed(by: rx.disposeBag)
            
        }
        
        if browse.largeImage == nil, let Url = URL(string: browse.largeImageUrl ?? "") {
            self.progress.accept(0)
            startDownload.subscribe(onNext: {
                KF.url(Url)
                    .onProgress({
                        [weak self] size, totalSize  in  guard let self = self else { return }
                        if totalSize > 0 {
                            self.progress.accept(CGFloat(size) / CGFloat(totalSize))
                        }
                    }).onSuccess({
                        [weak self] result in
                        guard let self = self else { return }
                        let size = self.calculateImageViewSize(size: result.image.size)
                        self.image.onNext((size, result.image))
                        self.progress.accept(1)
                        self.downloadCompletion.onNext((browse.largeImageUrl ?? "", result.image))

                    }).set(to: UIImageView())
                
            }).disposed(by: rx.disposeBag)
            
        }
        
    }
    
    
    func calculateImageViewSize(size: CGSize) -> CGSize {

        var width = min(App.width, size.width)
        var height = width * (size.height / (size.width == 0 ? 1 : size.width))
        return CGSize(width: width, height: height)
    }
}

class ImageBrowseLayout: UICollectionViewFlowLayout, UIGestureRecognizerDelegate {
    var fromFrame: CGRect = .zero
    var canUpdate: Bool = false
    var isDraging: Bool = false
    var beginDate: Date?

    var beginPoint: CGPoint = .zero
    var orignalFrame: CGRect = .zero
    private var currentIndexPath: IndexPath?
    var activityVC: UIActivityViewController?
    weak var currentCell: ImageBrowseCell?
 
    lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(pan:)))
        longPress.minimumPressDuration = 0.1
        longPress.allowableMovement = 60
        longPress.numberOfTouchesRequired = 1
        return longPress
    }()
    
    lazy var shareLongPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(shareLongPress(pan:)))
        longPress.minimumPressDuration = 1
        return longPress
    }()
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 15.wScale
        itemSize = CGSize(width: App.width, height: App.height)
//        self.collectionView?.addGestureRecognizer(pan)
        self.collectionView?.addGestureRecognizer(longPress)
        self.collectionView?.addGestureRecognizer(shareLongPress)
        longPress.delegate = self
//        self.collectionView?.panGestureRecognizer.require(toFail: pan)
    }
    
    @objc func shareLongPress(pan: UILongPressGestureRecognizer) {
        guard let collectionView = collectionView else {
            return
        }
        let point = pan.location(in: pan.view)
        switch pan.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: point) {
                let cell = collectionView.cellForItem(at: indexPath) as? ImageBrowseCell
                let image = cell?.cellVM?.browse.largeImage ?? cell?.cellVM?.browse.thumbImage
//                let url = cell?.cellVM?.browse.largeImageUrl ?? cell?.cellVM?.browse.thumbImageUrl
                
                if let image = image {
                    activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    activityVC?.popoverPresentationController
                    UIViewController.getCurrentViewController()?.present(activityVC!, animated: true, completion: nil)
                    activityVC!.completionWithItemsHandler = {
                        type, completed, _, error in
                        if completed  {
                            UIApplication.shared.keyWindow?.showTextHUD("Success")
                        }
                    }
                }
                
            }
        default:
            break
        }
        
    }
    
    @objc func longPress(pan: UILongPressGestureRecognizer) {
        guard let collectionView = collectionView else {
            return
        }
        let point = pan.location(in: pan.view)
        let translationPoint = CGPoint(x: point.x - beginPoint.x, y: point.y - beginPoint.y)
        switch pan.state {
        case .began:
            beginPoint = point
            beginDate = Date()
            if let indexPath = collectionView.indexPathForItem(at: point) {
                let cell = collectionView.cellForItem(at: indexPath)
                currentIndexPath = indexPath
                currentCell = cell as? ImageBrowseCell
                orignalFrame = cell?.frame ?? .zero
                let duration = Date().timeIntervalSince(beginDate ?? Date())
//                if translationPoint.y > 0 && abs(translationPoint.x) < 40 {
                    currentCell?.beginDrag()
                    collectionView.beginInteractiveMovementForItem(at: indexPath)
                    canUpdate = true
//                } else {
//                    pan.state = .failed
//                }
            }
            
        case .changed:
            if canUpdate {
                isDraging = true
                collectionView.updateInteractiveMovementTargetPosition(point)
            }
        case .ended:
            isDraging = false
            let progress = translationPoint.y / (orignalFrame.height / 2.5)
            currentCell?.endDragAnimation(progress: progress)
            if canUpdate && progress < 0.6  {
                canUpdate = false
                collectionView.endInteractiveMovement()

            }
        case .cancelled:
            isDraging = false
            let progress = translationPoint.y / (orignalFrame.height / 2.5)
            currentCell?.endDragAnimation(progress: progress)
            if canUpdate {
                canUpdate = false
                collectionView.cancelInteractiveMovement()
            }
        default:
            break
        }
    }
 
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attr = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        if isDraging {
            if position.y > beginPoint.y {
                var progree = (position.y - beginPoint.y) / (orignalFrame.height / 2.5)
                if progree > 1 {
                    progree = 1
                }
                var autoSizeFromFrame = fromFrame
                var size = autoSizeFromFrame.size
                size.height = size.width * (orignalFrame.height / orignalFrame.width)
                autoSizeFromFrame.size = size
                let width = orignalFrame.width - (orignalFrame.width - autoSizeFromFrame.width) * progree
                let height = orignalFrame.height - (orignalFrame.height - autoSizeFromFrame.height) * progree
                attr.transform = CGAffineTransform.init(scaleX: width / orignalFrame.width, y: height / orignalFrame.height)
                let orginCenter = CGPoint(x: orignalFrame.minX + orignalFrame.width / 2, y:  orignalFrame.minY + orignalFrame.height / 2)
                let movePoint = CGPoint(x: position.x - beginPoint.x, y: position.y - beginPoint.y)
                attr.center = CGPoint(x: orginCenter.x + movePoint.x, y: orginCenter.y + movePoint.y)
                currentCell?.dragAnimation(progress: progree)
            } else {
                attr.frame = orignalFrame
                let orginCenter = CGPoint(x: orignalFrame.minX + orignalFrame.width / 2, y:  orignalFrame.minY + orignalFrame.height / 2)
                attr.center = orginCenter
            }
        }
        
        return attr
    }
    
    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        return previousIndexPath
    }
//    override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
//        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
//        context.invalidateItems(at: targetIndexPaths)
//        return context
//    }
//    override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
//        let context = super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
//        return context
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == shareLongPress {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
    
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        var point = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//        guard let collectionView = collectionView else {
//            return point
//        }
//        let pageIndex = proposedContentOffset.x / collectionView.frame.width
//        print(pageIndex * (collectionView.frame.width + minimumLineSpacing), point)
//        point.x = pageIndex * (collectionView.frame.width + minimumLineSpacing)
//        return point
//    }
}

class ImageBrowseCell: UICollectionViewCell, UIScrollViewDelegate, EventTrigger {
    enum Event {
        case dragingProgress(progress: CGFloat)
        case endDrag(progress: CGFloat)
        case beginDrag
    }
    var disposeBag = DisposeBag()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        return scrollView
    }()
    
    lazy var imageV: UIImageView = {
        let imageV = UIImageView()
        imageV.backgroundColor = .lightGray
        imageV.contentMode = .scaleAspectFill
        return imageV
    }()
    
    lazy var loadingHud: SSProgressHUD = {
        let hud = SSProgressHUD(mode: .progressValue, style: .clear)
        hud.maskBackgroundView.isHidden = true
        return hud
    }()
    var doubleTap: UITapGestureRecognizer!
    
    weak var cellVM: ImageBrowseCellVM?
    private var isDragAnimation = false
    private var isEndDragAnimation = false
//    var orignalImageScaleToCell: CGPoint = .zero
    var orignalCellSize: CGSize = .zero
    private var beginDragImageFrame: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        contentView.backgroundColor = .red
        layer.masksToBounds = true
//        scrollView.backgroundColor = .yellow
//        imageV.backgroundColor = .cyan
        contentView.addSubview(scrollView)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
//        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        imageV.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageV)
        loadingHud.showHUD(onView: contentView, animation: false)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        scrollView.delegate = self
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doubleTapAction() {
        guard let cellVM = cellVM else {
            return
        }
        if cellVM.isDoubleTap {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(2, animated: true)
        }
        cellVM.isDoubleTap = !cellVM.isDoubleTap
        
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        if !isEndDragAnimation {
            imageV.ss_center = CGPoint(x: scrollView.contentSize.width / 2, y: scrollView.contentSize.height / 2)
            
        } else {
            
        }
    }
    
    func dragAnimation(progress: CGFloat) {
        isDragAnimation = true
        if let trigger = self.triggerEvent {
            trigger(.dragingProgress(progress: progress))
        }
    }
    
    func beginDrag()  {
        self.beginDragImageFrame = imageV.frame
        self.orignalCellSize = ss_size
        isEndDragAnimation = false
        if let trigger = self.triggerEvent {
            trigger(.beginDrag)
        }
    }
    
    func endDragAnimation(progress: CGFloat) {
        isDragAnimation = false
        isEndDragAnimation = true
        setNeedsLayout()
        if let trigger = self.triggerEvent {
            trigger(.endDrag(progress: progress))
        }
    }
    
    
    func bind(_ cellViewModel: ImageBrowseCellVM) {
        disposeBag = DisposeBag()
        cellVM = cellViewModel
        cellViewModel.progress.subscribe(onNext: { [weak self] progress in guard let self = self else { return }
            if progress < 1 {
                self.loadingHud.isHidden = false
                self.loadingHud.customView.progress = progress
            } else {
                self.loadingHud.isHidden = true
            }
        }).disposed(by: disposeBag)
        cellViewModel.image.subscribe(onNext: {
            [weak self]
            size, imag in
            guard let self = self else { return }
           
            if size.height > App.height {
                self.scrollView.contentSize = size
            } else {
                self.scrollView.contentSize = CGSize(width: App.width, height: App.height)
            }
            self.imageV.ss_size = size
            self.imageV.image = imag
            self.setNeedsLayout()
        }).disposed(by: disposeBag)
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageV
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height < scrollView.frame.height  {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
        }
        imageV.ss_center = CGPoint(x: scrollView.contentSize.width / 2, y: scrollView.contentSize.height / 2)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        cellVM?.zoomScale = scale
    }
}


open class ImageBrowseView: UIView, EventTrigger, UICollectionViewDelegate, UICollectionViewDataSource {
   

    public enum Event {
        case close
    }
    
    lazy var bgMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let collectionLayout = ImageBrowseLayout()
    
    lazy var collectionView: CustomCollectionView = {
        let collectionView = CustomCollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = false
//        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    
    public private(set) var browses: [ImageBrowse]
    public private(set) var currentIndex: Int {
        didSet {
            pageControl.currentPage = currentIndex
        }
    }
    public private(set) var browseCellVMs: [ImageBrowseCellVM]
    private var singleTap: UITapGestureRecognizer!
    private var orginalImageFrame: CGRect?
    private var showBeightImageFrame: CGRect?
    private var orginalCellFrame: CGRect?
    private var isDragEndToOrginal: Bool = false
    private var downloadCompletion: ((String, UIImage?) -> Void)? = nil
    
    public init(browses: [ImageBrowse], currentIndex: Int, downloadCompletion: ((String, UIImage?) -> Void)? = nil ) {
        self.browses = browses
        self.currentIndex = currentIndex
        self.downloadCompletion = downloadCompletion
        self.browseCellVMs = browses.map({ b in
            let cellVM = ImageBrowseCellVM(browse: b)
            return cellVM
        })
        super.init(frame: .zero)
        self.browseCellVMs.forEach { cellVM in
            cellVM.downloadCompletion.subscribe(onNext: {
                 [weak self]
                string, image in guard let self = self else { return }
                if let downloadCompletion = self.downloadCompletion {
                    downloadCompletion(string, image)
                }
            }).disposed(by: cellVM.rx.disposeBag)
        }
        
        ss_w = App.width
        ss_h = App.height
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(singleTap)
        addSubview(bgMaskView)
        addSubview(collectionView)
        addSubview(pageControl)
    
        bgMaskView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(-(App.safeAreaInsets.bottom + 30.wScale))
            make.height.equalTo(0)
            make.centerX.equalToSuperview()
        }
        
        collectionView.register(ImageBrowseCell.self, forCellWithReuseIdentifier: ImageBrowseCell.cellName)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        DispatchQueue.main.async {
            [weak self] in guard let self = self else { return }
            self.collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        pageControl.numberOfPages = browses.count
        pageControl.currentPage = currentIndex
        pageControl.isHidden = browses.count <= 1
    }
    
    
    @objc func tapAction() {
        if let trigger = self.triggerEvent {
            trigger(.close)
        }
    }
    
  
    
    public func showAnimation() {
        let imgeV = (collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as! ImageBrowseCell).imageV
        if let orginalImageFrame = orginalImageFrame {
            imgeV.frame = orginalImageFrame
        }
        
    }
    
    public func startAnimation() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as! ImageBrowseCell
        let imgeV = cell.imageV
        orginalImageFrame = imgeV.frame
        orginalCellFrame = cell.frame
        let browse = self.browses[currentIndex]
        if let fromImageV = browse.fromImageV  {
            if let covertFrame = fromImageV.superview?.convert(fromImageV.frame, to: self) {
                let translationX = covertFrame.origin.x
                let translationY = covertFrame.origin.y - imgeV.frame.origin.y
                let scaleX = covertFrame.size.width / imgeV.frame.size.width
                let scaleY = covertFrame.size.height / imgeV.frame.size.height
                imgeV.frame = covertFrame
                showBeightImageFrame = covertFrame
                collectionLayout.fromFrame = covertFrame
            }
          
        }
      
    }
    
    public func hideAnimation() {
        let imgeV = (collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as! ImageBrowseCell).imageV
        if let orginalImageFrame = orginalImageFrame, let showBeightImageFrame = showBeightImageFrame,  let orginalCellFrame = orginalCellFrame {
            if isDragEndToOrginal  {
              var cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as! ImageBrowseCell
                setNeedsLayout()
                setNeedsDisplay()
                let scaleX = showBeightImageFrame.width / orginalImageFrame.width
                let scaleY = showBeightImageFrame.height / orginalImageFrame.height
                cell.ss_size = CGSize(width: orginalCellFrame.width * scaleX, height: orginalCellFrame.height * scaleY)
                cell.ss_center = CGPoint(x: showBeightImageFrame.minX + CGFloat(currentIndex) * (App.width + 15.wScale) + showBeightImageFrame.width / 2, y: showBeightImageFrame.minY + showBeightImageFrame.height / 2)
                imgeV.ss_origin = CGPoint(x: (cell.bounds.width - imgeV.ss_w) / 2, y: (cell.bounds.height - imgeV.ss_h) / 2)
                

            } else {
                imgeV.frame = showBeightImageFrame
            }
        }
        bgMaskView.alpha = 0

    }
    
//    public func dragAnimation(point: CGPoint) -> CGFloat {
////        if  point.y < 0 {
////            return 0
////        }
//        let imgeV = (collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as! ImageBrowseCell).imageV
//        imgeV.transform = CGAffineTransform.init(translationX: point.x, y: point.y)
//        print(point)
////        imgeV.ta = point
//        return 0
//    }
    
   
    //MARK: UICollectionViewDelegate, UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageBrowseCell.cellName, for: indexPath) as! ImageBrowseCell
        let cellVM = browseCellVMs[indexPath.row]
        singleTap.require(toFail: cell.doubleTap)
        cell.bind(cellVM)
        cellVM.startDownload.onNext(())
        cell.trigger { [weak self] event in guard let self = self else {  return }
            switch event {
            case .dragingProgress(let progress):
                self.bgMaskView.alpha = 1 - progress
            case .endDrag(let progress):
                if progress > 0.6 {
                    self.isDragEndToOrginal = true
                    
                    if let trigger = self.triggerEvent {
                        trigger(.close)
                    }
                } else {
                    self.bgMaskView.alpha = 1
                    self.pageControl.isHidden = self.browses.count <= 1
                }
              
            case .beginDrag:
                self.pageControl.isHidden = true
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return browseCellVMs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
   
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
//    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        var point = scrollView.contentOffset
//        let pageIndex = Int((point.x / scrollView.frame.width).rounded())
//        print(point.x / scrollView.frame.width, pageIndex)
//        point.x = CGFloat(pageIndex) * (scrollView.frame.width + 15.wScale)
//        scrollView.setContentOffset(point, animated: true)
//    }\
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        var point = scrollView.contentOffset
        point.x = CGFloat(currentIndex) * (scrollView.frame.width + 15.wScale)
        scrollView.setContentOffset(point, animated: true)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var point = scrollView.contentOffset
        point.x = CGFloat(currentIndex) * (scrollView.frame.width + 15.wScale)
        scrollView.setContentOffset(point, animated: true)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var point = targetContentOffset.pointee
        if point.x >= scrollView.contentOffset.x {
            let currentPointX = CGFloat(currentIndex + 1) * (scrollView.frame.width + 15.wScale)
            point.x = min(currentPointX, point.x)
        }
        
        if point.x <= scrollView.contentOffset.x, currentIndex > 0 {
            let currentPointX = CGFloat(currentIndex - 1) * (scrollView.frame.width + 15.wScale)
            point.x = max(currentPointX, point.x)
        }
        let pageIndex = Int((point.x / scrollView.frame.width).rounded())
        currentIndex = pageIndex
    }
    
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
public extension ImageBrowseView {
    
    static func browse(_ browes: [ImageBrowse], currentIndex: Int, downloadCompletion:  ((String, UIImage?) -> Void)? = nil) {
        if let currentVC = UIApplication.shared.keyWindow?.rootViewController {
            let browseView = ImageBrowseView(browses: browes, currentIndex: currentIndex, downloadCompletion: downloadCompletion)
            let alertView = SSAlertView(customView: browseView, fromViewController: currentVC, animation: ImageBrowseAnimation(), maskType: .none, canPanDimiss: false)
            alertView.isHideStatusBar = true
            alertView.show()
            browseView.trigger { [weak alertView] event in guard let alertView = alertView else { return }
                switch event {
                case .close:
                    alertView.hide()
                }
            }
        }
       
    }
}
