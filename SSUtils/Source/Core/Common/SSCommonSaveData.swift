//
//  CommonSaveData.swift
//  HeyWorld
//
//  Created by yangsq on 2022/10/31.
//

import Foundation
import RxSwift
import RxCocoa

public protocol SSCommonSaveDatas: NSObject {
    associatedtype SaveData: Codable, Identifiable
    var name: String { get }
    var saveDataDidChange: Observable<[SaveData]> { get }
    var currentSaveDatas: [SaveData]? { get }
    var hasRequestData: Bool { set get }
    @discardableResult func saveDatas(datas: [SaveData]) -> Bool
    @discardableResult func saveOrReplaceData(data: SaveData) -> Bool
    func getDatas() -> [SaveData]
    func refreshDatas(needShowLoading: Bool, completion: @escaping([SaveData]) -> Void)
    func request(needSave: Bool, needShowLoading: Bool)
    func requestIfNeed(needSave: Bool, needShowLoading: Bool)
    @discardableResult func updateSaveData(saveData: SaveData) -> Bool
    @discardableResult func getSaveData(id: SaveData.ID) -> SaveData?
}

private var lockSaveDataKey: Int8 = 0
private var savgeDataDidChangeKey: Int8 = 0
private var currentSaveDatasKey: Int8 = 0
private var hasRequestDataKey: Int8 = 0

public struct CommonSaveDatasConfig {
    public static var saveName: (() -> String?)? = nil
}
extension SSCommonSaveDatas {
    
    public var name: String {
        self.className + (CommonSaveDatasConfig.saveName?() ?? "defaultname")
    }
    
    public var saveDataDidChange: Observable<[SaveData]> {
        return _savgeDataDidChange.map(\.safeArray).observe(on: MainScheduler.instance).asObservable()
    }
    
    public var currentSaveDatas: [SaveData]? {
        _savgeDataDidChange.value.safeArray
    }
    
    public var hasRequestData: Bool {
        get {
            (objc_getAssociatedObject(self, &hasRequestDataKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &hasRequestDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var _savgeDataDidChange: BehaviorRelay<SSSafeArray<SaveData>> {
        if let dc = objc_getAssociatedObject(self, &savgeDataDidChangeKey) as? BehaviorRelay<SSSafeArray<SaveData>> {
            return dc
        } else {
            let dc = BehaviorRelay<SSSafeArray<SaveData>>(value: SSSafeArray(getDatas()))
            objc_setAssociatedObject(self, &savgeDataDidChangeKey, dc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dc
        }
    }
//    private var lock: NSRecursiveLock {
//        if let lock = objc_getAssociatedObject(self, &lockSaveDataKey) as? NSRecursiveLock {
//            return lock
//        } else {
//            let lock = NSRecursiveLock()
//            objc_setAssociatedObject(self, &lockSaveDataKey, lock, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            return lock
//        }
//    }
//
    func savePath() -> URL? {
        let fm = FileManager()
        var fullPath = SSPaths.Documents + "/CommonSaveDatas"
        if !fm.fileExists(atPath: fullPath) {
            try? fm.createDirectory(at: URL(fileURLWithPath: fullPath), withIntermediateDirectories: true)
        }
        fullPath += "/\(name).json"
        return URL(fileURLWithPath: fullPath)
    }
    
    @discardableResult public func saveDatas(datas: [SaveData]) -> Bool {
//        defer {
//            lock.unlock()
//        }
        _savgeDataDidChange.accept(SSSafeArray(datas))
//        lock.lock()
        let encoder = JSONEncoder()
        if let tData = try? encoder.encode(datas), let url = savePath() {
            do {
                try tData.write(to: url, options: .atomic)
                return true
            } catch  {
                print(error)
            }
        }
        return false
    }
    
    @discardableResult public func saveOrReplaceData(data: SaveData) -> Bool {
        
        var allDatas = _savgeDataDidChange.value.count > 0 ? _savgeDataDidChange.value.safeArray : getDatas()
        if let index = allDatas.firstIndex(where: {$0.id == data.id}) {
            allDatas[index] = data
        } else {
            allDatas.append(data)

        }
        return saveDatas(datas: allDatas)

    }
    
    public func getDatas() -> [SaveData] {
//        defer {
//            lock.unlock()
//        }
//        lock.lock()
        let decoder = JSONDecoder()
        if let url = savePath(), let data = try? Data(contentsOf: url) {
            do {
                let object = try decoder.decode([SaveData].self, from: data)
                return object
            } catch  {
                print(error)
            }
        }
        return []
    }
    
    public func request(needSave: Bool = true, needShowLoading: Bool = false) {
        refreshDatas(needShowLoading: needShowLoading) { [weak self] datas in guard let self = self else { return }
            self.hasRequestData = true
            self.saveDatas(datas: datas)
        }
    }
    public func refreshDatas(needShowLoading: Bool, completion: @escaping([SaveData]) -> Void) {
        
    }
    
    public func requestIfNeed(needSave: Bool = true, needShowLoading: Bool = false) {
        if self.hasRequestData {
            return
        }
        request(needSave: needSave, needShowLoading: needShowLoading)
    }
    
    @discardableResult public func updateSaveData(saveData: SaveData) -> Bool {
        var datas = _savgeDataDidChange.value.count > 0 ? _savgeDataDidChange.value.safeArray : getDatas()
        if let index = datas.firstIndex(where: {$0.id == saveData.id}) {
            datas[index] = saveData
        }
        return saveDatas(datas: datas)
    }
    
    @discardableResult public func getSaveData(id: SaveData.ID) -> SaveData? {
        let datas = _savgeDataDidChange.value.count > 0 ? _savgeDataDidChange.value.safeArray : getDatas()
        return datas.first(where: {$0.id == id})
    }
}

public protocol ManagerShare: NSObject {
    static var shared: Self { get }
}
private var managerShareKey: Int8 = 0
extension ManagerShare {
    static private var _shared: Self {
        if let shared = objc_getAssociatedObject(self, &managerShareKey) as? Self {
            return shared
        } else {
            let shared = Self()
            objc_setAssociatedObject(self, &managerShareKey, shared, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return shared
        }
    }
    public static var shared: Self {
        _shared
    }
}
