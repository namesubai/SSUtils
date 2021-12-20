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

public protocol MapResult {
    associatedtype Object
    var object:Object { get }
    var result: RootResult? {get}
}

public struct ObjectResult<T: Mappable>: MapResult {
    public var result: RootResult?
    public var object: T
}

public struct ObjectArrayResult<T: Mappable>: MapResult {
    public var result: RootResult?
    public var object: [T]
}

//struct NetWorkResult: CustomDebugStringConvertible {
//    var debugDescription: String {
//        return "\(String(describing: try? response.mapString()))"
//    }
//
//    var result: RootResult?
//    var response: Moya.Response
//    init(result: RootResult?, response: Moya.Response) {
//        self.result = result
//        self.response = response
//        if let origalJson = try? response.mapJSON() {
//            var json = JSON(origalJson)
////            json["data"] = JSON(parseJSON: result?.data ?? "")
////            let newJsonString = json.rawString()
////            if let data = newJsonString?.data(using: .utf8, allowLossyConversion: false) {
////                let newResponse = Moya.Response(statusCode: response.statusCode, data: data, request: response.request, response: response.response)
////                self.response = newResponse
////            }
//            #if DEBUG
//            print(json)
//            #endif
//
//
//        }
//    }
//}

///
public enum CachDataType<T> {
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
public protocol CacheResult {
    associatedtype T
    var dataType: CachDataType<T> {get}
}

public struct CacheObject<T: Mappable>: CacheResult {
    public var dataType: CachDataType<T>
}

public struct CacheObjectArray<T: Mappable>: CacheResult{
    public var dataType: CachDataType<[T]>
}




extension ObservableType where Element: RootResult {
    func mapObject<T: BaseMappable>(_ type: T.Type) -> Observable<ObjectResult<T>> {

        return flatMap { result -> Observable<ObjectResult<T>> in
            var objectResult: ObjectResult<T>? = nil
            
            
            if let jsonString = result.needMapJsonString, let object = try?  Mapper<T>().map(JSONString:jsonString) {
                objectResult = ObjectResult(result: result, object: object)
            }
            return  Observable<ObjectResult<T>>.create {
                (observer) -> Disposable in
                if objectResult == nil {
                    let error = ServiceError.parseResultError
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
    
    func mapArray<T: BaseMappable>(_ type: T.Type) -> Observable<ObjectArrayResult<T>> {
        return flatMap { result -> Observable<ObjectArrayResult<T>> in
            
            var objectResult: ObjectArrayResult<T>? = nil
            if let jsonString = result.needMapJsonString, let object = try? Mapper<T>().mapArray(JSONString: jsonString) {
                objectResult = ObjectArrayResult(result: result, object: object)
            }
            
            return  Observable<ObjectArrayResult<T>>.create {
                (observer) -> Disposable in
                if objectResult == nil {
                    let error = ServiceError.parseResultError
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


public extension ObservableType where Element: MapResult {
    func onlyObject() -> Observable<Element.Object> {
        return map({$0.object})
    }
}

public extension ObservableType where Element: CacheResult {
    
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

 class __NetWorkingProvider<Target>: NSObject where Target: NetworkTargetType {
    let provider = MoyaProvider<Target>()
    let online = connectedToInternet()
    func request<Result>(_ target: Target, resultType: Result.Type) -> Observable<Result> where Result: RootResult {
        
        var request =
            provider.rx.request(target).observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
        var lastRequest = request
        if target.needGetAccessToken {
            lastRequest = target.getAccessToken(error: nil).flatMapLatest({ _ -> Observable<Response> in
                return request.asObservable()
            }).asSingle()
        }
        
        return Single<Result>.create { (single) -> Disposable in
            let dispose = lastRequest
                .subscribe { (response) in
                    #if DEBUG
                    print("接口 \(target.method)：\(response.request?.url?.absoluteString ?? "")")
                    print("头部信息:",target.headers ?? [String: String]())
                    switch target.task {
                    case .requestParameters(let params, _):
                        print("参数:",params)
                    case .uploadCompositeMultipart(let number, let params):
                        print("\(number)个文件", "参数:",params)
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
                    if let data = try? response.mapObject(resultType) {
                        if data.isSuccess {
                            single(.success(data))
                            
                        }else {
                            let error = ServiceError.serverError(response: data)
                            single(.failure(error))
                            target.handleError(error)
                        }
                        
                    } else {
                        let error = ServiceError.parseResultError
                        single(.failure(error))
                    }
                } onFailure: { (error) in
                single(.failure(error))
            }
            return Disposables.create {
                dispose.dispose()
            }
        }.retry(when: {
            error in
            
           return error.flatMapLatest({
                error -> Observable<Void>  in
                if error == nil {
                    return Observable.just(())
                } else {
                  return  target.getAccessToken(error: error)
                }
            })
        }).asObservable().share()  ///加share，为了避免多个订阅，调用多次请求

    }
    
    
}

public protocol NetworkTargetType: Moya.TargetType {
    var cachePath: String? { get }
    var cacheIdentifier: String? { get }
    var parameters: [String: Any] { get }
    var apiVerstion: String? { get }
    func getAccessToken(error: Error?) -> Observable<Void>
    func handleError(_ error: Error)
    var needGetAccessToken: Bool { get }
    var debugLog: Bool {get}
}

public extension NetworkTargetType {
    var cachePath: String? {
        var path = self.path
        
        if !self.parameters.keys.isEmpty {
            let sort = self.parameters.sorted(by: {$0.0 < $1.0})
            path  += "?" + sort.map({"\($0)=\($1)"}).joined(separator: "&")
        }
        path = path.ss_md5() + (self.cacheIdentifier ?? "")
        return path
    }
    
    var task: Task {
        return .requestParameters(parameters: self.parameters, encoding:  URLEncoding.default)
    }
    
    var debugLog: Bool {
        return true
    }

//    var cacheIdentifier: String? {
//        return nil
//    }
}

public protocol NetworkAPI {
    
}

extension NetworkingProvider: NetworkAPI {
    
}

protocol NetworkType {
    associatedtype T: NetworkTargetType
    var provider: __NetWorkingProvider<T> { get }
    func request<Result>(_ target: T, result: Result.Type) -> Observable<Result> where Result: RootResult
}

open class NetworkingProvider<NetworkTarget>: NetworkType where NetworkTarget: NetworkTargetType {
    
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
    typealias T = NetworkTarget
    internal let provider = __NetWorkingProvider<NetworkTarget>()
    
    func request<Result>(_ target: NetworkTarget, result: Result.Type) -> Observable<Result> where Result: RootResult {
        return provider.request(target, resultType: result)
    }
    
    
    public init() {
        
    }
}
 
public extension NetworkingProvider {

//    func requestDataObject<T: Mappable, Result: RootResult>(_ target: Target, type: T.Type, result: Result.Type) -> Single<ObjectResult<T>>
//    {
//        return request(target, result: result)
//            .mapObject(T.self)
//            .observe(on: MainScheduler.instance)
//            .asSingle()
//    }
    
    func requestObject<T: Mappable, Result: RootResult>(_ target: NetworkTargetType, type: T.Type, result: Result.Type) ->
    Single<ObjectResult<T>>
    {
        
        return request(target as! NetworkTarget, result: result)
            .mapObject(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
    func requestArray<T: Mappable, Result: RootResult>(_ target: NetworkTargetType, type: T.Type, result: Result.Type) -> Single<ObjectArrayResult<T>>
    {
        return request(target as! NetworkTarget, result: result)
            .mapArray(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
    
//    func requestDataArray<T: Mappable, Result: RootResult>(_ target: Target, type: T.Type, result: Result.Type) -> Single<ObjectArrayResult<T>>
//    {
//        return request(target, result: result)
//            .mapArray(T.self)
//            .observe(on: MainScheduler.instance)
//            .asSingle()
//    }
//
    
    
    func cacheRequestObject<T: Mappable, Result: RootResult>(_ target: NetworkTargetType, type: T.Type, result: Result.Type) -> Observable<CacheObject<T>> {
        
        Observable<CacheObject<T>>.create { network in
            
            func networkRequest() {
                var request: Observable<T>
                request = self.requestObject(target, type: type, result: result).asObservable().onlyObject()
                var dispose: Disposable?
                dispose = request.observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())).subscribe(onNext: {
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
            }
            
            if let cache = self.cache, let path = target.cachePath {
                cache.containsObject(forKey: path) { (key, isContain) in
                    if isContain {
                        cache.object(forKey: path) { (key, jsonString) in
                            if let map = T(JSONString: jsonString as! NSString as String) {
                                let cacheObject = CacheObject<T>(dataType: CachDataType.cache(result: map))
                                network.onNext(cacheObject)
                                networkRequest()
                            } else {
                                networkRequest()
                            }
                        }
                    } else {
                        networkRequest()
                    }
                }
                
            } else {
                networkRequest()
            }
          
            return Disposables.create {
            }
        }.observe(on: MainScheduler.instance).share()
        
    }
    
    func cacheRequestArray<T: Mappable, Result: RootResult>(_ target: NetworkTargetType, type: T.Type, result: Result.Type) -> Observable<CacheObjectArray<T>> {
        
        Observable<CacheObjectArray<T>>.create { network in
            func networkRequest() {
                var request: Observable<[T]>
                request = self.requestArray(target, type: type, result: result).asObservable().onlyObject()
                var dispose: Disposable?
                dispose = request.observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())).subscribe(onNext: {
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
            }
            
            if let cache = self.cache, let path = target.cachePath {
                cache.containsObject(forKey: path) { (key, isContain) in
                    if isContain {
                        cache.object(forKey: path) { (key, jsonString) in
                            if let mapArray = Array<T>(JSONString: jsonString as! NSString as String)  {
                                let object = CacheObjectArray<T>(dataType: CachDataType.cache(result: mapArray))
                                network.onNext(object)
                                networkRequest()
                            } else {
                                networkRequest()
                            }
                        }
                    } else {
                        networkRequest()
                    }
                }
                
            } else {
                networkRequest()
            }
         
            return Disposables.create {

            }
        }.observe(on: MainScheduler.instance).share()
        
    }
}


