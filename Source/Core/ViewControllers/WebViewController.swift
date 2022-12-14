//
//  WebViewController.swift
//  
//
//  Created by yangsq on 2020/12/15.
//

import Foundation
import WebKit

public struct WebData {
    public var title: String?
    public var url: String?
    public var icon: String?
}

open class WebViewController: ViewController {
    
    private lazy var webViewContainerV: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    private lazy var progressView: GradientView = {
        let view = GradientView()
        return view
    }()
    
    private lazy var closeButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeAction))
        button.tintColor = Colors.headline
        return button
    }()
    
    private var progressObserver: ((CGFloat) -> Void)? = nil
    private var loadWebDataDidChange: ((WebData) -> Void)? = nil
    private var firstLoadDidFinish: (() -> Void)? = nil
    private var loadDidFinish: (() -> Void)? = nil

    private var currentTitle: String?
    public var url: String?
    
    open var isAutoSetTitle: Bool = true
    public private(set) var currentWebData: WebData?
    public private(set) var isFirstLoadFinish = false
    open override var bottomToolView: UIView? {
        didSet {
            if let bottomToolView = bottomToolView {
                webViewContainerV.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.ss_w, height: view.ss_h - bottomToolView.ss_h)
            } else {
                webViewContainerV.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.ss_w, height: view.ss_h - view.safeAreaInsets.top)
            }
        }
    }

    @objc open override func backAction() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            super.backAction()
        }
    }
    
    @objc func closeAction() {
        closeVC()
    }
    
    open override func viewDidLoad() {
        isAutoShowAndHideNavBackButton = false
        super.viewDidLoad()
    }
    
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let bottomToolView = bottomToolView {
            webViewContainerV.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.ss_w, height: view.ss_h - bottomToolView.ss_h - view.safeAreaInsets.top)
        } else {
            webViewContainerV.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.ss_w, height: view.ss_h - view.safeAreaInsets.top)
        }
        progressView.ss_y = view.safeAreaInsets.top
    }
    
    open override func make() {
        super.make()
        view.addSubview(webViewContainerV)
        webViewContainerV.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        view.addSubview(progressView)
        progressView.ss_x = 0
        progressView.ss_h = 2
        webView.rx.observe(String.self, "title").subscribe(onNext: {
            [weak self] title in guard let self = self else { return }
            self.currentTitle = title
            if self.isAutoSetTitle {
                self.navigationItem.title = title
            }
            if var currentWedData = self.currentWebData {
                currentWedData.title = self.currentWebData?.title ?? title
                self.currentWebData = currentWedData
                if let loadWebDataDidChange = self.loadWebDataDidChange {
                    loadWebDataDidChange(currentWedData)
                }
            }
           
        })
        
        webView.rx.observe(Double.self, "estimatedProgress").subscribe(onNext: {
            [weak self]
            progress
            in
            guard let self = self else { return }
            if let progress = progress {
                if progress >= 1 {
                    self.progressView.isHidden = true
                }else {
                    self.progressView.isHidden = false
                    self.progressView.ss_w = self.view.bounds.width * CGFloat(progress)
                }
                self.progressObserver?(CGFloat(progress))

            }else {
                self.progressView.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
    
    open func loadWebView(url: String) {
        self.url = url
        logDebug(url)
        if let Url = URL(string: url) {
            webView.load(URLRequest(url: Url))
        }
    }
    
    public func observeDidLoadFinish(finish:(() -> Void)? = nil) {
        self.firstLoadDidFinish = finish
    }
    public func observeFirstDidLoadFinish(finish:(() -> Void)? = nil) {
        self.loadDidFinish = finish
    }
    public func observeProgress(progress:((CGFloat) -> Void)? = nil) {
        self.progressObserver = progress
    }
    
    public func observeLoadWebDataDidChange(webData:((WebData) -> Void)? = nil) {
        self.loadWebDataDidChange = webData
    }
    
    private func updateCloseButton() {
        if webView.canGoBack {
            self.otherleftBarButtonItems = [closeButtonItem]
        } else {
            self.otherleftBarButtonItems = []
        }
    }
}


 extension WebViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        let title = webView.backForwardList.currentItem?.title
        let url = webView.backForwardList.currentItem?.url.absoluteString
        let icon = (webView.backForwardList.currentItem?.url.scheme ?? "") + "://" + (webView.backForwardList.currentItem?.url.host ?? "") + "/favicon.ico"
        let webData = WebData(title: title, url: url, icon: icon)
        self.currentWebData = webData
        if let loadWebDataDidChange = self.loadWebDataDidChange {
            loadWebDataDidChange(webData)
        }
        self.webView.isHidden = false
        self.view.hideNetworkErrorEmptyView()
        self.view.hideEmptyView()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.isHidden = false
        self.view.hideNetworkErrorEmptyView()
        self.view.hideEmptyView()
        if !isFirstLoadFinish {
            firstLoadDidFinish?()
            isFirstLoadFinish = true
        }
        loadDidFinish?()
        updateCloseButton()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        self.webView.isHidden = false
//        self.view.hideNetworkErrorEmptyView()
//        self.view.hideEmptyView()
        updateCloseButton()
        if isFirstLoadFinish {
           return
        }
        if let error = error as? NSError {
            if error.code == NSURLErrorNetworkConnectionLost ||
                error.code == NSURLErrorCannotConnectToHost {
                self.webView.isHidden = true
                let emptyView = self.view.showNetworkErrorEmptyView {
                    [weak self] in guard let self = self else { return }
                    if let url = URL(string: self.url ?? "") {
                        self.webView.load(URLRequest(url: url))
                        self.webView.isHidden = false
                    }
                }
                emptyView?.centerOffset = emptyCenterOffset ?? App.emptyCenterOffset
                
            } else {
                self.webView.isHidden = true
                self.view.hideEmptyView()
                let emptyView = self.view.showEmptyView(image: App.emptyErrorImage,
                                                        title: localized(name: "web_load_failed"),
                                                        buttonCustomView: App.emptyNotNetworkButtonCustomView?()) {
                    [weak self] in guard let self = self else { return }
                    if let url = URL(string: self.url ?? "") {
                        self.webView.load(URLRequest(url: url))
                        self.webView.isHidden = false
                    }
                }
                emptyView?.centerOffset = emptyCenterOffset ?? App.emptyCenterOffset
            }
        }
    }
    
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateCloseButton()
//        if let error = error as? NSError {
//            if error.code == NSURLErrorNetworkConnectionLost ||
//                error.code == NSURLErrorCannotConnectToHost {
//                self.webView.isHidden = true
//                let emptyView = self.view.showNetworkErrorEmptyView {
//                    [weak self] in guard let self = self else { return }
//                    if let url = URL(string: self.url ?? "") {
//                        self.webView.load(URLRequest(url: url))
//                        self.webView.isHidden = false
//                    }
//                }
//                emptyView?.centerOffset = App.emptyCenterOffset
//
//            } else {
//                self.webView.isHidden = true
//                self.view.hideEmptyView()
//                let emptyView = self.view.showEmptyView(image: App.emptyErrorImage,
//                                                           title: localized(name: "web_load_failed"),
//                                                           buttonCustomView: App.emptyNotNetworkButtonCustomView?()) {
//                    [weak self] in guard let self = self else { return }
//                    if let url = URL(string: self.url ?? "") {
//                        self.webView.load(URLRequest(url: url))
//                        self.webView.isHidden = false
//                    }
//                }
//                emptyView?.centerOffset = App.emptyCenterOffset
//            }
//        }
    }
     
     public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         
         if navigationAction.targetFrame == nil {
             if let url = navigationAction.request.url  {
                 UIApplication.shared.open(url)
             }
         }
         decisionHandler(.allow)
     }
}

extension WebViewController: WKUIDelegate {

}
