//
//  SSImagesView.swift
//  LoolaCommon
//
//  Created by yangsq on 2021/9/8.
//

import UIKit
import RxSwift
import Kingfisher
import SnapKit

public class SSImagesView: SSView {
    private var imageViews = [UIImageView]()
    private var stackViews = [UIStackView]()
    let imageBackgroundColor = UIColor.lightGray
    let space: CGFloat = 3.5.wScale
    let cornerRadious: CGFloat = 8.wScale
    var rowNum: Int
    private lazy var containerView: SSVerticalStackView = {
        let view = SSVerticalStackView()
        view.spacing = space
        view.alignment = .leading
        return view
    }()
    public private(set) var count: Int
    public private(set) var viewWidth: CGFloat
    var imageWidth: CGFloat!
    var firstImageHeightConstraint: Constraint?
    var firstImageWidthConstraint: Constraint?
    public var imageTouchTrigger = PublishSubject<(images:[(fromImageView: UIImageView, thumbImage: UIImage?)], index: Int)>()
    var imageTouchDisposeBag = DisposeBag()
    public init(count: Int = 9, viewWidth: CGFloat, rowNum: Int = 3) {
        self.rowNum = rowNum
        self.count = count
        self.viewWidth = viewWidth
        imageWidth = ceil(((viewWidth - CGFloat(rowNum - 1) * space) / CGFloat(rowNum)).rounded(.down))
        super.init(frame: .zero)
    }
    public override func make() {
        super.make()
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        var row = Int(count / rowNum)
        let blance = count % rowNum
        if blance > 0 {
            row += 1
        }
        for _ in 0..<row {
            let stackView = SSHorizontalStackView()
            stackView.spacing = space
//            stackView.distribution = .fillEqually
            containerView.addArrangedSubview(stackView)
            stackViews.append(stackView)
            stackView.isHidden = true
        }
        
        for num in 0..<count {
            let imagV = UIImageView()
            imagV.backgroundColor = imageBackgroundColor
            imagV.contentMode = .scaleAspectFill
            imagV.isUserInteractionEnabled = true
            addSubview(imagV)
            imageViews.append(imagV)
            let row = num / rowNum
            let stackView = stackViews[row]
            stackView.addArrangedSubview(imagV)
            imagV.snp.makeConstraints { make in
                if num % rowNum == 0 {
                    make.top.bottom.equalTo(0)
                }
                if num == 0 {
                    firstImageHeightConstraint = make.height.equalTo(imageWidth).priority(.high).constraint
                    firstImageWidthConstraint = make.width.equalTo(imageWidth).priority(.high).constraint
                } else {
                    make.height.equalTo(imageWidth)
                    make.width.equalTo(imageWidth)
                }
            }
        }
    }
    
    public func setImages(count: Int, images:(([UIImageView]) -> Void)? = nil) {
        
        stackViews.forEach ({ stackView in
            stackView.isHidden = true
        })
        
        var totalRow = Int(count / rowNum)
        let blance = count % rowNum
        if blance > 0 {
            totalRow += 1
        }
        
        for num in 0..<count {
            
            if num < imageViews.count {
                let row = num / rowNum
                let stackView = stackViews[row]
                if stackView.isHidden {
                    stackView.isHidden = false
                }
                if count == 4 && self.count == 9 {
                    imageViews[0].isHidden = false
                    imageViews[0].addCorner(size: CGSize(width: imageWidth, height: imageWidth), roundingCorners: [.topLeft], cornerSize: CGSize(width: cornerRadious, height: cornerRadious))
                    imageViews[1].isHidden = false
                    imageViews[1].addCorner(size: CGSize(width: imageWidth, height: imageWidth), roundingCorners: [.topRight], cornerSize: CGSize(width: cornerRadious, height: cornerRadious))
                    imageViews[3].isHidden = false
                    imageViews[3].addCorner(size: CGSize(width: imageWidth, height: imageWidth), roundingCorners: [.bottomLeft], cornerSize: CGSize(width: cornerRadious, height: cornerRadious))
                    imageViews[4].isHidden = false
                    imageViews[4].addCorner(size: CGSize(width: imageWidth, height: imageWidth), roundingCorners: [.bottomRight], cornerSize: CGSize(width: cornerRadious, height: cornerRadious))
                } else {
                    let imageV = imageViews[num]
                    imageV.isHidden = false
                    imageV.addCorner(size: CGSize(width: imageWidth, height: imageWidth), roundingCorners: cornerRadious(num: num, count: count), cornerSize: CGSize(width: cornerRadious, height: cornerRadious))
                }
                
                
                
            }
        }
        if let imagesCompletion = images, count > 0 {
            if count == 4 && self.count == 9 {
                imagesCompletion([imageViews[0], imageViews[1], imageViews[3], imageViews[4]])
            } else {
                imagesCompletion(Array(imageViews[0..<count]))
            }
        }
        if count == 4 && self.count == 9 {
            imageViews[2].isHidden = true
            imageViews[5].isHidden = true
            imageViews[8].isHidden = true
        } else {
            imageViews[count..<imageViews.count].forEach { imageV in
                imageV.isHidden = true
            }
        }
        
    }
    
    public func setImage(image: UIImage, index: Int) {
        if imageViews.count > index {
            imageViews[index].image = image
        }
    }
    
    
    func cornerRadious(num: Int, count: Int) -> UIRectCorner {
        var cornerRadious: UIRectCorner = []
        let balance = num % rowNum
        if num - 1 < 0  {
            cornerRadious.insert(.topLeft)
        }
        
        if balance == count - 1 && num - rowNum < 0 || balance == rowNum - 1 && num - rowNum < 0 {
            cornerRadious.insert(.topRight)
        }
        
        if balance == 0 && num + rowNum >= count  {
            cornerRadious.insert(.bottomLeft)
        }
        
        if num == count - 1 || (num + rowNum >= count && balance == rowNum - 1)   {
            cornerRadious.insert(.bottomRight)
        }
        return cornerRadious
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

extension SSImagesView {
    static let singlePicMaxWidth: CGFloat = 227.wScale
}

public extension Reactive where Base: SSImagesView {
    var imageUrls: Binder<[(String?, CGSize)]> {
        return Binder(self.base, binding: { (view, results) in
            view.imageTouchDisposeBag = DisposeBag()
            view.setImages(count: results.count) { imageViews in
                imageViews.forEach({
                    imageV in
                    let index = imageViews.firstIndex(of: imageV)!
                    let result = results[index]
                    let url = result.0
                    if results.count == 1 {
//                        let width = min(result.1.width, ImagesView.singlePicMaxWidth)
//                        let height = width * (result.1.height / result.1.width)
                        let width = SSImagesView.singlePicMaxWidth
                        let height = SSImagesView.singlePicMaxWidth
                        view.firstImageHeightConstraint?.update(offset: height).update(priority: .high)
                        view.firstImageWidthConstraint?.update(offset: width).update(priority: .high)
                        imageV.addCorner(size: CGSize(width: width, height: height), roundingCorners: view.cornerRadious(num: index, count: results.count), cornerSize: CGSize(width: view.cornerRadious, height: view.cornerRadious))
                    } else {
                        view.firstImageHeightConstraint?.update(offset: view.imageWidth).update(priority: .high)
                        view.firstImageWidthConstraint?.update(offset: view.imageWidth).update(priority: .high)
                        if results.count == 4 && view.count == 9 {
                            var corners: UIRectCorner = .allCorners
                            if index == 0 {
                                corners = .topLeft
                            }
                            if index == 1 {
                                corners = .topRight
                            }
                            if index == 2 {
                                corners = .bottomLeft
                            }
                            if index == 3 {
                                corners = .bottomRight
                            }
                            imageV.addCorner(size: CGSize(width: view.imageWidth, height: view.imageWidth), roundingCorners: corners, cornerSize: CGSize(width: view.cornerRadious, height: view.cornerRadious))
                        } else {
                            imageV.addCorner(size: CGSize(width: view.imageWidth, height: view.imageWidth), roundingCorners: view.cornerRadious(num: index, count: results.count), cornerSize: CGSize(width: view.cornerRadious, height: view.cornerRadious))
                        }
                        
                    }
                    imageV.rx.tap().subscribe(onNext: {
                        [weak view]
                        _ in guard let view = view else { return }
                        let triggerImages = imageViews.filter({$0.isHidden == false}).map({
                            (fromImageView: $0, thumbImage: $0.image)
                        })
                        view.imageTouchTrigger.onNext((images:triggerImages, index: imageViews.firstIndex(of: imageV)!))
                    }).disposed(by: view.imageTouchDisposeBag)
                    if let Url = URL(string: url ?? "") {
                        imageV.kf.setImage(with: Url)
                    }
                    
                })
            }
        })
    }
    

}
