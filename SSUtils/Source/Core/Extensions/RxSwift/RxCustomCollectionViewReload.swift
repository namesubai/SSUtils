//
//  RxSwiftCollectionViewReload.swift
//  HiWidget
//
//  Created by yangsq on 2022/8/1.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
class _CustomRxCollectionViewReactiveArrayDataSource
: NSObject
, UICollectionViewDataSource {
    
    @objc(numberOfSectionsInCollectionView:)
    func numberOfSections(in: UICollectionView) -> Int {
        1
    }
    
    func _collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    fileprivate func _collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        rxAbstractMethod()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        _collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func rxAbstractMethod(file: StaticString = #file, line: UInt = #line) -> Swift.Never {
        rxFatalError("Abstract method", file: file, line: line)
    }
    
    func rxFatalError(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Swift.Never  {
        fatalError(lastMessage(), file: file, line: line)
    }
}


class CustomRxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence: Swift.Sequence>
: CustomRxCollectionViewReactiveArrayDataSource<Sequence.Element>
, RxCollectionViewDataSourceType {
    typealias Element = Sequence
    
    override init(reloadAnimated: Bool = true, cellFactory: @escaping CellFactory) {
        super.init(reloadAnimated: reloadAnimated, cellFactory: cellFactory)
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Sequence>) {
        Binder(self) { collectionViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            collectionViewDataSource.collectionView(collectionView, observedElements: sections)
        }.on(observedEvent)
    }
}



// Please take a look at `DelegateProxyType.swift`
class CustomRxCollectionViewReactiveArrayDataSource<Element>
: _CustomRxCollectionViewReactiveArrayDataSource
, SectionedViewDataSourceType {
    
    typealias CellFactory = (UICollectionView, Int, Element) -> UICollectionViewCell
    
    var itemModels: [Element]?
    
    
    func modelAtIndex(_ index: Int) -> Element? {
        itemModels?[index]
    }
    
    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }
    
    var cellFactory: CellFactory
    var reloadAnimated: Bool

    init(reloadAnimated: Bool = true, cellFactory: @escaping CellFactory) {
        self.cellFactory = cellFactory
        self.reloadAnimated = reloadAnimated
    }
    
    // data source
    
    override func _collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemModels?.count ?? 0
    }
    
    override func _collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cellFactory(collectionView, indexPath.item, itemModels![indexPath.item])
    }
    
    // reactive
    
    func collectionView(_ collectionView: UICollectionView, observedElements: [Element]) {
        self.itemModels = observedElements
        if reloadAnimated {
            collectionView.reloadData()
            
            // workaround for http://stackoverflow.com/questions/39867325/ios-10-bug-uicollectionview-received-layout-attributes-for-a-cell-with-an-index
            collectionView.collectionViewLayout.invalidateLayout()
        } else {
            UIView.performWithoutAnimation {
                collectionView.reloadData()
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.setNeedsLayout()
            }
        }
        
    }
}
extension Reactive where Base: UICollectionView {
    public  func customItems<Sequence: Swift.Sequence, Cell: UICollectionViewCell, Source: ObservableType>
    (cellIdentifier: String, cellType: Cell.Type = Cell.self, reloadAnimated: Bool = true)
    -> (_ source: Source)
    -> (_ configureCell: @escaping (Int, Sequence.Element, Cell) -> Void)
    -> Disposable where Source.Element == Sequence {
        return { source in
            return { configureCell in
                let dataSource = CustomRxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence>(reloadAnimated: reloadAnimated) { cv, i, item in
                    let indexPath = IndexPath(item: i, section: 0)
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! Cell
                    configureCell(i, item, cell)
                    return cell
                }
                
                return self.items(dataSource: dataSource)(source)
            }
        }
    }
    
    public func noReloadAnimationItems<Sequence: Swift.Sequence, Source: ObservableType>
    (_ source: Source)
    -> (_ cellFactory: @escaping (UICollectionView, Int, Sequence.Element) -> UICollectionViewCell)
    -> Disposable where Source.Element == Sequence {
        return { cellFactory in
            let dataSource = CustomRxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence>(reloadAnimated: false, cellFactory: cellFactory)
            return self.items(dataSource: dataSource)(source)
        }
        
    }
}


#endif
