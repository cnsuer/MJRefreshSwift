//
//  MJRefreshComponent.swift
//  MJRefresh
//
//  Created by apple on 2019/2/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

/** 刷新控件的状态 */
enum MJRefreshState: Int {
	/** 普通闲置状态 */
	case idle = 1
	/** 松开就可以进行刷新的状态 */
	case pulling
	/** 正在刷新中的状态 */
	case refreshing
	/** 即将刷新的状态 */
	case willRefresh
	/** 所有数据加载完毕，没有更多的数据了 */
	case noMoreData
	
}

class MJRefreshComponent: UIView {
	
	public typealias MJRefreshCallBack = () -> ()
	
	/** 正在刷新的回调 */
	public var refreshingBlock: MJRefreshCallBack?
	
	private var pan: UIPanGestureRecognizer?
	
	/** 父控件 */
	weak var scrollView: UIScrollView?
	
	/** 记录scrollView刚开始的inset */
	var scrollViewOriginalInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	
	/** 开始刷新后的回调(进入刷新状态后的回调) */
	var beginRefreshingCompletionBlock: MJRefreshCallBack?
	
	/** 结束刷新的回调 */
	var endRefreshingCompletionBlock: MJRefreshCallBack?
	
	/** 是否正在刷新 */
	var isRefreshing: Bool {
		return self.state == .refreshing || self.state == .willRefresh
	}
	
	/** 刷新状态 一般交给子类内部实现 默认是普通闲置状态 */
	var state: MJRefreshState = .idle {
		didSet{
			//状态改变
			mj_setState(oldValue)
		}
	}
	
	/** 根据拖拽比例自动切换透明度 */
	var isAutomaticallyChangeAlpha = true {
		didSet{
			if self.isRefreshing { return }
			if oldValue {
				self.alpha = self.pullingPercent
			} else {
				self.alpha = 1.0
			}
		}
	}
	
	/** 拉拽的百分比(交给子类重写) */
	var pullingPercent: CGFloat = 0.0 {
		didSet{
			if self.isRefreshing { return }
			if self.isAutomaticallyChangeAlpha {
				self.alpha = pullingPercent
			}
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// 准备工作
		self.prepare()
	}
	
	override public func layoutSubviews() {
		
		placeSubviews()
		
		super.layoutSubviews()
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		
		// 如果newSuperview不为空,且不是UIScrollView，不做任何事情
		guard let _scrollView = newSuperview as? UIScrollView else { return }

		// 旧的父控件移除监听
		removeObservers()
		
		scrollView = _scrollView
		// 设置宽度
		self.mj_w = _scrollView.mj_w;
		// 设置位置
		self.mj_x = -_scrollView.mj_insetL
		// 记录UIScrollView
		// 设置永远支持垂直弹簧效果
		scrollView?.alwaysBounceVertical = true
		// 记录UIScrollView最开始的contentInset
		scrollViewOriginalInset = _scrollView.mj_inset
		
		// 添加监听
		self.addObservers()
		
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		if self.state == .willRefresh {
			// 预防view还没显示出来就调用了beginRefreshing
			self.state = .refreshing
		}
	}
	
//MARK: KVO监听
	func addObservers() {
		let options: NSKeyValueObservingOptions = [.new, .old]
		self.scrollView?.addObserver(self, forKeyPath: MJRefreshKeyPathContentOffset, options: options, context: nil)
		self.scrollView?.addObserver(self, forKeyPath: MJRefreshKeyPathContentSize, options: options, context: nil)
		self.pan = self.scrollView?.panGestureRecognizer
		self.pan?.addObserver(self, forKeyPath: MJRefreshKeyPathPanState, options: options, context: nil)
	}
	
	func removeObservers() {
		self.superview?.removeObserver(self, forKeyPath: MJRefreshKeyPathContentOffset)
		self.superview?.removeObserver(self, forKeyPath: MJRefreshKeyPathContentSize)
		self.superview?.removeObserver(self, forKeyPath: MJRefreshKeyPathPanState)
		self.pan = nil
	}
	
	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		// 遇到这些情况就直接返回
		if !self.isUserInteractionEnabled { return }
		
		// 这个就算看不见也需要处理
		if keyPath == MJRefreshKeyPathContentSize {
			self.scrollViewContentSizeDidChange(change)
		}
		
		// 看不见
		if self.isHidden { return }
		
		if keyPath == MJRefreshKeyPathContentOffset {
			self.scrollViewContentOffsetDidChange(change)
		} else if keyPath == MJRefreshKeyPathPanState {
			self .scrollViewPanStateDidChange(change)
		}
	}
	
//MARK: 开始刷新和结束刷新,以及刷新状态改变的设置
	
	func mj_setState(_ oldState: MJRefreshState) {
		// 加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
		DispatchQueue.main.async  { [weak self] in
			guard let this = self else { return }
			this.setNeedsLayout()
		}
	}

	/** 进入刷新状态 */
	func beginRefreshing() {
		UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
			self.alpha = 1.0
		}
		self.pullingPercent = 1.0
		// 只要正在刷新，就完全显示
		if self.window != nil {
			self.state = .refreshing
		} else {
			// 预防正在刷新中时，调用本方法使得header inset回置失败
			if self.state != .refreshing {
				self.state = .willRefresh
				// 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
				self.setNeedsDisplay()
			}
		}
	}
	
	func beginRefreshingWithCompletionBlock(_ completionBlock: @escaping MJRefreshCallBack) {
		self.beginRefreshingCompletionBlock = completionBlock
		self.beginRefreshing()
	}
	
	/** 结束刷新状态 */
	func endRefreshing() {
		DispatchQueue.main.async  { [weak self] in
			guard let this = self else { return }
			this.state = .idle
		}
	}
	
	func endRefreshingWithCompletionBlock(_ completionBlock: @escaping MJRefreshCallBack) {
		self.endRefreshingCompletionBlock = completionBlock
		self.endRefreshing()
	}

	/** 触发回调（交给子类去调用） */
	func executeRefreshingCallback() {
		DispatchQueue.main.async  { [weak self] in
			guard let this = self else { return }
			
			if let refreshingBlock = this.refreshingBlock {
				refreshingBlock()
			}
			
			if let beginRefreshingCompletionBlock = this.beginRefreshingCompletionBlock {
				beginRefreshingCompletionBlock()
			}
		}
	}
	
//MARK: 交给子类们去实现的方法啊
	
	/** 初始化 */
	func prepare() {
		// 基本属性
		autoresizingMask = .flexibleWidth
		backgroundColor = UIColor.clear
	}
	
	/** 摆放子控件frame */
	func placeSubviews() {}
	
	/** 当scrollView的contentOffset发生改变的时候调用 */
	func scrollViewContentOffsetDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {}
	
	/** 当scrollView的contentSize发生改变的时候调用 */
	func scrollViewContentSizeDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {}
	
	/** 当scrollView的拖拽状态发生改变的时候调用 */
	func scrollViewPanStateDidChange(_ change: Dictionary<NSKeyValueChangeKey, Any>?) {}

}


extension UILabel {
	class func mj_label() -> Self {
		let label = self.init()
		label.font = MJRefreshLabelFont;
		label.textColor = MJRefreshLabelTextColor;
		label.autoresizingMask = .flexibleWidth;
		label.textAlignment = .center;
		label.backgroundColor = UIColor.clear
		return label
	}
	
	var mj_textWith: CGFloat {
		var stringWidth: CGFloat = 0
		let size = CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
		if let text = self.text as NSString?, text.length > 0 {
			stringWidth = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : self.font], context: nil).size.width
		}
		return stringWidth
	}
}
