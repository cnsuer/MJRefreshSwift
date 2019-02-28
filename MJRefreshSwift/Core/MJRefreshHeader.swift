//
//  MJRefreshHeader.swift
//  MJRefreshSwift
//
//  Created by apple on 2019/2/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

public class MJRefreshHeader: MJRefreshComponent {
	
	/** 这个key用来存储上一次下拉刷新成功的时间 */
	var lastUpdatedTimeKey = MJRefreshHeaderLastUpdatedTimeKey{
		didSet{
			self.setLastUpdatedTimeKey()
		}
	}
	
	/** 上一次下拉刷新成功的时间 */
	var lastUpdatedTime: Date {
		if let date = UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date {
			return date
		}
		return Date()
	}
	
	/** 忽略多少scrollView的contentInset的top */
	var ignoredScrollViewContentInsetTop: CGFloat = 0.0 {
		didSet{
			self.mj_y = -self.mj_h - ignoredScrollViewContentInsetTop
		}
	}
	
	private var insetTDelta: CGFloat = 0.0
	
	/** 创建header */
	class func header(with refreshingBlock: @escaping MJRefreshCallBack) -> Self {
		let cmp = self.init()
		cmp.refreshingBlock = refreshingBlock
		return cmp
	}
	
	override func prepare() {
		super.prepare()

		// 设置key,调用didSet方法重新显示时间
		self.lastUpdatedTimeKey = MJRefreshHeaderLastUpdatedTimeKey
		// 设置高度
		self.mj_h = MJRefreshHeaderHeight
	}
	
	override func placeSubviews() {
		super.placeSubviews()
		// 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
		self.mj_y = -self.mj_h - self.ignoredScrollViewContentInsetTop;
	}
	
	override func scrollViewContentOffsetDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {
		super.scrollViewContentOffsetDidChange(change)
		
		guard let scrollView = scrollView else { return }
		
		// 在刷新的refreshing状态
		if self.state == .refreshing {
			// 暂时保留
			if self.window == nil { return }
			
			// sectionheader停留解决
			var insetT = -scrollView.mj_offsetY > scrollViewOriginalInset.top ? -scrollView.mj_offsetY : scrollViewOriginalInset.top
			insetT = insetT > self.mj_h + scrollViewOriginalInset.top ? self.mj_h + scrollViewOriginalInset.top : insetT
			self.scrollView?.mj_insetT = insetT
			self.insetTDelta = scrollViewOriginalInset.top - insetT
			
			return
		}
		
		// 跳转到下一个控制器时，contentInset可能会变
		scrollViewOriginalInset = scrollView.mj_inset
		
		// 当前的contentOffset
		let offsetY = scrollView.mj_offsetY
		// 头部控件刚好出现的offsetY
		let happenOffsetY = -scrollViewOriginalInset.top;
		
		// 如果是向上滚动到看不见头部控件，直接返回
		// offsetY为正值,即向上滚动
		if offsetY > happenOffsetY { return }
		
		// 普通 和 即将刷新 的临界点
		let normal2pullingOffsetY = happenOffsetY - self.mj_h
		let pullingPercent = (happenOffsetY - offsetY) / self.mj_h
		
		if scrollView.isDragging { // 如果正在拖拽
			self.pullingPercent = pullingPercent
			if self.state == .idle && (offsetY < normal2pullingOffsetY) {
				//1: 向下拉,超过header的高度,即,将转为即将刷新状态
				self.state = .pulling
			} else if self.state == .pulling && (offsetY >= normal2pullingOffsetY) {
				//2-1:向上滑,又将header向上送回,即,将取消刷新操作,转为普通状态
				self.state = .idle
			}
		} else if (self.state == .pulling) {
			// 2-2即将刷新 && 手松开,开始刷新
			self.beginRefreshing()
		} else if pullingPercent < 1 {
			//3 向下拉的高度,不超过header的高度,即,取消刷新操作
			self.pullingPercent = pullingPercent
		}
	}
	
	override func mj_setState(_ oldState: MJRefreshState) {
		
		//状态未改变的话直接返回
		if state == oldState { return }
		
		super.mj_setState(oldState)
		
		// 根据状态做事情
		if state == .idle {
			if oldState != .refreshing { return }
			
			// 保存刷新时间
			UserDefaults.standard.set(Date(), forKey: self.lastUpdatedTimeKey)
			UserDefaults.standard.synchronize()
			
			// 恢复inset和offset
			UIView.animate(withDuration: MJRefreshSlowAnimationDuration, animations: {
				self.scrollView?.mj_insetT += self.insetTDelta;
				// 自动调整透明度
				if self.isAutomaticallyChangeAlpha {
					self.alpha = 0.0;
				}
			}, completion: { (isFinished) in
				self.pullingPercent = 0.0;
				if let endRefreshingCompletionBlock = self.endRefreshingCompletionBlock {
					endRefreshingCompletionBlock()
				}
			})
		} else if state == .refreshing {
			DispatchQueue.main.async {
				UIView.animate(withDuration: MJRefreshFastAnimationDuration, animations: {
					if self.scrollView?.panGestureRecognizer.state != .cancelled {
						let top = self.scrollViewOriginalInset.top + self.mj_h
						// 增加滚动区域top
						self.scrollView?.mj_insetT = top
						// 设置滚动位置
						if var offset = self.scrollView?.contentOffset {
							offset.y = -top
							self.scrollView?.setContentOffset(offset, animated: false)
						}
					}
				}, completion: { (isFinished) in
					self.executeRefreshingCallback()
				})
			}
		}
	}
	
	func setLastUpdatedTimeKey() {}

}
