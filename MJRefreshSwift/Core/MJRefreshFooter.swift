//
//  MJRefreshFooter.swift
//  MJRefreshSwift
//
//  Created by apple on 2019/3/1.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

class MJRefreshFooter: MJRefreshComponent {

	/** 创建header */
	class func footer(with refreshingBlock: @escaping MJRefreshCallBack) -> Self {
		let cmp = self.init()
		cmp.refreshingBlock = refreshingBlock
		return cmp
	}
	
	override func prepare() {
		super.prepare()
		// 设置自己的高度
		self.mj_h = MJRefreshFooterHeight
	}
	
//MARK: - 公共方法
	
	func noticeNoMoreData() {
		self.endRefreshingWithNoMoreData()
	}
	
	func endRefreshingWithNoMoreData() {
		DispatchQueue.main.async { [weak self] in
			guard let this = self else { return }
			this.state = .noMoreData
		}
	}
	
	func resetNoMoreData() {
		DispatchQueue.main.async { [weak self] in
			guard let this = self else { return }
			this.state = .idle
		}
	}
}
