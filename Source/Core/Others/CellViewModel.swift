

import UIKit
import RxCocoa
import RxSwift

open class CellViewModel: NSObject {
    
    public lazy var title = BehaviorRelay<String?>(value: nil)
    public lazy var detail = BehaviorRelay<String?>(value: nil)
    public lazy var secondDetail = BehaviorRelay<String?>(value: nil)
    public lazy var attributedDetail = BehaviorRelay<NSAttributedString?>(value: nil)
    public lazy var image = BehaviorRelay<UIImage?>(value: nil)
    public lazy var imageUrl = BehaviorRelay<String?>(value: nil)
    public lazy var cellSelected = BehaviorRelay<Bool>(value: false)
    public lazy var cellSelectedTrigger = PublishSubject<Void>()
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")

    }
}
