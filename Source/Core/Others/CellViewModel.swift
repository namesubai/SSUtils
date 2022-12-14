

import UIKit
import RxCocoa

open class CellViewModel: NSObject {
    
    public let title = BehaviorRelay<String?>(value: nil)
    public let detail = BehaviorRelay<String?>(value: nil)
    public let secondDetail = BehaviorRelay<String?>(value: nil)
    public let attributedDetail = BehaviorRelay<NSAttributedString?>(value: nil)
    public let image = BehaviorRelay<UIImage?>(value: nil)
    public let imageUrl = BehaviorRelay<String?>(value: nil)
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")

    }
}
