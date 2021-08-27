//
//  Kingfisher+RX.swift
//  
//
//  Created by yangsq on 2020/11/10.
//

import Foundation
import RxCocoa
import RxSwift
import Kingfisher

extension Reactive where Base: UIButton {
    public func imageUrl(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<String?> {
        return Binder(self.base, binding: { (button, url) in
            guard let url = url else {  return }
            button.kf.setImage(with: URL(string: url), for: .normal, placeholder: placeholderImage, progressBlock: nil, completionHandler: nil)
        })
    }
}

extension Reactive where Base: UIImageView {

    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }
    
    public var imageUrl: Binder<String?> {
        return self.imageUrl(withPlaceholder: nil)
    }
    
    public var imageUrlWithAnimation: Binder<String?> {
        return self.imageUrl(withPlaceholder: nil,options: [.forceTransition,.transition(.fade(0.5))])
    }
    
    public func imageUrlWithAnimation(withPlaceholder placeholderImage: UIImage? = nil, imageSize: CGSize? = nil, conerRadious: CGFloat? = nil) -> Binder<String?> {
        var processor: ImageProcessor? = nil
        
        var options = KingfisherOptionsInfo()
        
        if let imageSize = imageSize, let conerRadious = conerRadious {
            processor = DownsamplingImageProcessor(size: imageSize)
                         |> RoundCornerImageProcessor(cornerRadius: conerRadious)
            options.append(KingfisherOptionsInfoItem.processor(processor!))
        }
        options.append(.transition(.fade(0.5)))
        options.append(.forceTransition)

        return Binder(self.base, binding: { (imageView, url) in
//            imageView.kf.indicatorType = .activity
            guard let url = url else {  return }
            imageView.kf.setImage(with: URL(string: url),
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
 
        })
    }
    
    public var headerImageUrl: Binder<String?> {
        return self.imageUrl(withPlaceholder: UIImage(color: UIColor.random, size: CGSize(width: 200, height: 200)))
    }
    
    public func imageUrl(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<String?> {
        return Binder(self.base, binding: { (imageView, url) in
            guard let url = url else {  return }
            imageView.kf.setImage(with: URL(string: url),
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
 
        })
    }

    public func imageURL(withPlaceholder placeholderImage: UIImage?, options: KingfisherOptionsInfo? = []) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView, url) in
            imageView.kf.setImage(with: url,
                                  placeholder: placeholderImage,
                                  options: options,
                                  progressBlock: nil,
                                  completionHandler: { (result) in })
        })
    }
}

extension ImageCache: ReactiveCompatible {}

extension Reactive where Base: ImageCache {

    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single in
            self.base.calculateDiskStorageSize { (result) in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }

    public func clearCache() -> Observable<Void> {
        return Single.create { single in
            self.base.clearMemoryCache()
            self.base.clearDiskCache(completion: {
                single(.success(()))
            })
            return Disposables.create { }
        }.asObservable()
    }
}
