//
//  NetWorking.swift
//  
//
//  Created by yangsq on 2020/11/10.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Alamofire
import ObjectMapper
import Moya_ObjectMapper
import SwiftyJSON
import YYCache

protocol MapResult {
    associatedtype Object
    var object:Object { get }
    var result: BaseResult? {get}
}

struct ObjectResult<T: Mappable>: MapResult {
    var result: BaseResult?
    var object: T
}

struct ObjectArrayResult<T: Mappable>: MapResult {
    var result: BaseResult?
    var object: [T]
}

struct NetWorkResult: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(String(describing: try? response.mapString()))"
    }
    
    var result: BaseResult?
    var response: Moya.Response
    init(result: BaseResult?, response: Moya.Response) {
        self.result = result
        self.response = response
        if let origalJson = try? response.mapJSON() {
            var json = JSON(origalJson)
            json["data"] = JSON(parseJSON: result?.data ?? "")
            let newJsonString = json.rawString()
            if let data = newJsonString?.data(using: .utf8, allowLossyConversion: false) {
                let newResponse = Moya.Response(statusCode: response.statusCode, data: data, request: response.request, response: response.response)
                self.response = newResponse
            }
            #if DEBUG
            print(json)
            #endif
            
            
        }
    }
}

///
enum CachDataType<T> {
    case cache(result:T)
    case network(result:T)
    var result: T {
        switch self {
        case .cache(let reuslt):
            return reuslt
        case .network(let reuslt):
            return reuslt
        }
    }
}
protocol CacheResult {
    associatedtype T
    var dataType: CachDataType<T> {get}
}

struct CacheObject<T: Mappable>: CacheResult {
    var dataType: CachDataType<T>
}

struct CacheObjectArray<T: Mappable>: CacheResult{
    var dataType: CachDataType<[T]>
}




extension ObservableType where Element == NetWorkResult {
    func mapObject<T: BaseMappable>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<ObjectResult<T>> {

        return flatMap { result -> Observable<ObjectResult<T>> in
            var objectResult: ObjectResult<T>? = nil
            if keyPath == nil {
                if let object = try? result.response.mapObject(type) {
                   objectResult = ObjectResult(result: result.result, object: object)
                }
                
            }else {
                if let object = try? result.response.mapObject(type, atKeyPath: keyPath!) {
                    objectResult = ObjectResult(result: result.result, object: object)
                }
            }
            return  Observable<ObjectResult<T>>.create {
                (observer) -> Disposable in
                if objectResult == nil {
                    let error = ServiceError.parseResultError(response: result.response)
                    observer.onError(error)
                }else {
                    observer.onNext(objectResult!)
                    observer.onCompleted()

                }
                return Disposables.create {
                }
            }

        }
    }
    
    func mapArray<T: BaseMappable>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<ObjectArrayResult<T>> {
        return flatMap { result -> Observable<ObjectArrayResult<T>> in
            
            var objectResult: ObjectArrayResult<T>? = nil
            if keyPath == nil {
                if let object = try? result.response.mapArray(type) {
                    objectResult = ObjectArrayResult(result: result.result, object: object)
                }else {
                    objectResult = ObjectArrayResult(result: result.result, object: [])
                }
                
            }else {
                if let object = try? result.response.mapArray(type, atKeyPath: keyPath!) {
                    objectResult = ObjectArrayResult(result: result.result, object: object)
                }else {
                    objectResult = ObjectArrayResult(result: result.result, object: [])
                }
            }
            
            return  Observable<ObjectArrayResult<T>>.create {
                (observer) -> Disposable in
                if objectResult == nil {
                    let error = ServiceError.parseResultError(response: result.response)
                    observer.onError(error)
                }else {
                    observer.onNext(objectResult!)
                    observer.onCompleted()
                }
                return Disposables.create {
                }
            }

        }
    }
    
}


extension ObservableType where Element: MapResult {
    func onlyObject() -> Observable<Element.Object> {
        return map({$0.object})
    }
}

extension ObservableType where Element: CacheResult {
    
    func network() -> Observable<Element.T> {
     
     return filter { (element) -> Bool in
            switch element.dataType {
            case .cache(_):
            return false
            case .network(_):
            return true
            }
     }.map({$0.dataType.result}).observe(on: MainScheduler.instance)
    }
    
    func cache() -> Observable<Element.T> {
        
     return filter { (element) -> Bool in
            switch element.dataType {
            case .cache(_):
            return true
            case .network(_):
            return false
            }
     }.map({$0.dataType.result}).observe(on: MainScheduler.instance)
    }
}

 class __NetWorkingProvider<Target>: NSObject where Target: Moya.TargetType  {
    let provider = MoyaProvider<Target>()
    let online = connectedToInternet()
    func request(_ target: Target) -> Observable<NetWorkResult> {
        
        let actualRequest =
            provider.rx.request(target).observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        return Single<NetWorkResult>.create { (single) -> Disposable in
            let dispose = actualRequest
                .subscribe { (response) in
                    #if DEBUG
                    print("接口 \(target.method)：\(response.request?.url?.absoluteString ?? "")")
                    print("头部信息:",target.headers ?? [String: String]())
                    switch target.task {
                    case .requestParameters(let params, _):
                        print("参数:",params)
                    default:
                        break
                    }
                    if let result = try? response.mapJSON() {
                        print("网络数据：\(String(describing: result))")
                    }else
                    if let result = try? response.mapString() {
                        print("网络数据：\(String(describing: result))")
                    }
                    #endif
                    if let data = try? response.mapObject(BaseResult.self) {
                        if data.code == .success {
                            let result = NetWorkResult(result: data, response: response)
                            single(.success(result))
                            
                        }else {
                            let error = ServiceError.serverError(response: data)
                            single(.failure(error))
                            if data.code == .tokenInvalid ||
                                data.code == .anotherLogin ||
                                data.code == .loginExpired ||
                                data.code == .needLogin ||
                                data.code == .signVerifyFailed {
                                
                            }
                            
                        }
                        
                    }else {
                        let error = ServiceError.parseResultError(response: response)
                        single(.failure(error))
                    }
                } onFailure: { (error) in
                single(.failure(error))
            }
            return Disposables.create {
                dispose.dispose()
            }
        }.asObservable().share()  ///加share，为了避免多个订阅，调用多次请求

    }
    
    
}

public protocol NetworkTargetType: Moya.TargetType {
    var cachePath: String? { get }
}

public protocol NetworkAPI {
    
}

extension NetworkingProvider: NetworkAPI {
    
}

protocol NetworkType {
    associatedtype T: TargetType
    var provider: __NetWorkingProvider<T> { get }
    func request(_ target: T) -> Observable<NetWorkResult>
}

open class NetworkingProvider<Target>: NetworkType where Target: NetworkTargetType {

    let disposeBag = DisposeBag()
    private lazy var cache: YYCache? = {
        let userId =  0
        if let cache = YYCache(name: "\(App.bundleIdentifier).network.cache") {
            cache.memoryCache.costLimit = 20 * 1024 * 1024
            cache.diskCache.costLimit = 200 * 1024 * 1024
            return cache
        }
        return nil
    }()
    typealias T = Target
    let provider = __NetWorkingProvider<Target>()
    func request(_ target: Target) -> Observable<NetWorkResult> {
        return provider.request(target)
    }
}

extension NetworkingProvider {

    func requestDataObject<T: Mappable>(_ target: Target, type: T.Type) -> Single<ObjectResult<T>>
    {
        
        return provider.request(target)
            .mapObject(T.self, atKeyPath: "data")
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
    func requestObject<T: Mappable>(_ target: Target, type: T.Type) ->
    Single<ObjectResult<T>>
    {
        
        return provider.request(target)
            .mapObject(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
    func requestArray<T: Mappable>(_ target: Target, type: T.Type) -> Single<ObjectArrayResult<T>>
    {
        return provider.request(target)
            .mapArray(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
    func requestDataArray<T: Mappable>(_ target: Target, type: T.Type) -> Single<ObjectArrayResult<T>>
    {
        return provider.request(target)
            .mapArray(T.self, atKeyPath: "data")
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
    
    
    func cacheRequestObject<T: Mappable>(_ target: Target, type: T.Type, isDataKeypath: Bool = true) -> Observable<CacheObject<T>> {
        
        Observable<CacheObject<T>>.create { network in
            if let cache = self.cache, let path = target.cachePath {
                cache.containsObject(forKey: path) { (key, isContain) in
                    if isContain {
                        cache.object(forKey: path) { (key, jsonString) in
                            if let map = T(JSONString: jsonString as! NSString as String) {
                                let cacheObject = CacheObject<T>(dataType: CachDataType.cache(result: map))
                                network.onNext(cacheObject)
                            }
                        }
                    }
                }
                
            }
            
            var request: Observable<T>
            if isDataKeypath {
                request = self.requestDataObject(target, type: type).asObservable().onlyObject()
            }else {
                request = self.requestObject(target, type: type).asObservable().onlyObject()
            }
            var dispose: Disposable?
            dispose = request.subscribe(onNext: {
                (map) in
                let object = CacheObject<T>(dataType: CachDataType.network(result: map))
                network.onNext(object)
                guard let cache = self.cache, let jsonString = map.toJSONString(), let path = target.cachePath else { return }
                cache.setObject(jsonString as NSString, forKey: path) {
                    logDebug("\(path):缓存成功")
                }
                
                network.onCompleted()
                dispose?.dispose()
            }, onError: {
                (error) in
                network.onError(error)
                dispose?.dispose()
            })
            
            return Disposables.create {
            }
        }
        
    }
    
    func cacheRequestArray<T: Mappable>(_ target: Target, type: T.Type, isDataKeypath: Bool = true) -> Observable<CacheObjectArray<T>> {
        
        Observable<CacheObjectArray<T>>.create { network in
            
            
            if let cache = self.cache, let path = target.cachePath {
                cache.containsObject(forKey: path) { (key, isContain) in
                    if isContain {
                        cache.object(forKey: path) { (key, jsonString) in
                            if let mapArray = Array<T>(JSONString: jsonString as! NSString as String)  {
                                let object = CacheObjectArray<T>(dataType: CachDataType.cache(result: mapArray))
                                network.onNext(object)
                            }
                        }
                    }
                }
                
            }
            
            var request: Observable<[T]>
            if isDataKeypath {
                request = self.requestDataArray(target, type: type).asObservable().onlyObject()
            }else {
                request = self.requestArray(target, type: type).asObservable().onlyObject()
            }
            var dispose: Disposable?
            dispose = request.subscribe(onNext: {
                (mapArray) in
                let object = CacheObjectArray<T>(dataType: CachDataType.network(result: mapArray))
                network.onNext(object)
                guard let cache = self.cache, let jsonString = mapArray.toJSONString(), let path = target.cachePath else { return }
                cache.setObject(jsonString as NSString, forKey: path) {
                    logDebug("\(path):缓存成功")
                }
                network.onCompleted()
                dispose?.dispose()
            }, onError: {

                (error) in
                network.onError(error)
                dispose?.dispose()
            })
            return Disposables.create {

            }
        }
        
    }
}


