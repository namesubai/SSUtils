//
//  ScrollViewController.swift
//  SSUtils
//
//  Created by yangsq on 2021/9/8.
//

import UIKit

open class ScrollViewController: ViewController {
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    public lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    open override func make() {
        super.make()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.width.equalTo(App.width)
        }
    }


}
