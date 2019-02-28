//
//  ViewController.swift
//  MJRefreshSwift
//
//  Created by apple on 2018/10/19.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var _scrollView: UIScrollView?
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let scrollView = UIScrollView(frame: view.bounds)
		scrollView.backgroundColor = UIColor.green
		scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 10)
		view.addSubview(scrollView)
		_scrollView = scrollView

		if #available(iOS 11.0, *) {
			scrollView.contentInsetAdjustmentBehavior = .never
		} else {
			automaticallyAdjustsScrollViewInsets = false
		}
		
		scrollView.mj_header = MJRefreshNormalHeader.header { [weak self] in
			let now = DispatchTime.now().uptimeNanoseconds
			let append = 3 * NSEC_PER_SEC
			let result = now + append
			let dispatchTime = DispatchTime(uptimeNanoseconds: result)
			DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
				self?.end()
			})
		}
	}
	
	func end(){
		print("ssss")
		_scrollView?.mj_header?.endRefreshing()
	}

}

