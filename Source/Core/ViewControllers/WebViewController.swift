//
//  WebViewController.swift
//  
//
//  Created by yangsq on 2020/12/15.
//

import Foundation
import WebKit

open class WebViewController: ViewController {
    public lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    private lazy var progressView: GradientView = {
        let view = GradientView()
        return view
    }()
    
    open var isAutoSetTitle: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func make() {
        super.make()
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.addSubview(progressView)
        progressView.ss_y = navigationBarHeight + App.statusBarHeight
        progressView.ss_x = 0
        progressView.ss_h = 2
        
        if isAutoSetTitle {
            webView.rx.observe(String.self, "title").bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        }
        
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
            }else {
                self.progressView.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
    
    open func loadWebView(url: String) {
        logDebug(url)
        if let Url = URL(string: url) {
            webView.load(URLRequest(url: Url))
        }
    }
}


 extension WebViewController: WKNavigationDelegate {

//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//    }
//
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//    }
//
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//    }
}

extension WebViewController: WKUIDelegate {

}
