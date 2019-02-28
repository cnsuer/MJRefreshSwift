//
//  MJRefreshNormalHeader.swift
//  MJRefreshSwift
//
//  Created by apple on 2019/2/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

class MJRefreshNormalHeader: MJRefreshStateHeader {
	
	lazy var arrowView: UIImageView? = {
		let image = Bundle.mj_arrowImage()
		let arrowView = UIImageView(image: image)
		self.addSubview(arrowView)
		return arrowView
	}()
	/** 菊花的样式 */
	var activityIndicatorViewStyle: UIActivityIndicatorView.Style = .whiteLarge {
		didSet{
			self.setNeedsLayout()
		}
	}
	
	lazy var loadingView: UIActivityIndicatorView? = {
		let view = UIActivityIndicatorView(style: self.activityIndicatorViewStyle)
		view.hidesWhenStopped = true
		self.addSubview(view)
		return view
	}()
	
//MARK:  重写父类的方法
	override func prepare() {
		super.prepare()
		self.activityIndicatorViewStyle = .gray
	}
	
	override func placeSubviews() {
		super.placeSubviews()
		// 箭头的中心点
		var arrowCenterX = self.mj_w * 0.5
		if !self.stateLabel.isHidden {
			let stateWidth = self.stateLabel.mj_textWith
			var timeWidth: CGFloat = 0.0
			if !self.lastUpdatedTimeLabel.isHidden {
				timeWidth = self.lastUpdatedTimeLabel.mj_textWith
			}
			let textWidth = max(stateWidth, timeWidth)
			arrowCenterX -= textWidth / 2 + self.labelLeftInset
		}
		let arrowCenterY = self.mj_h * 0.5;
		let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)
		// 箭头
		if self.arrowView?.constraints.count == 0, let size = self.arrowView?.image?.size {
			self.arrowView?.mj_size = size
			self.arrowView?.center = arrowCenter
		}
		
		// 圈圈
		if self.loadingView?.constraints.count == 0 {
			self.loadingView?.center = arrowCenter
		}
		
		self.arrowView?.tintColor = self.stateLabel.textColor
	}
	
	override func mj_setState(_ oldState: MJRefreshState) {
		
		//状态未改变的话直接返回
		if state == oldState { return }
		
		super.mj_setState(oldState)
		
		// 根据状态做事情
		if state == .idle {
			if oldState == .refreshing {
				self.arrowView?.transform = .identity
				UIView.animate(withDuration: MJRefreshSlowAnimationDuration, animations: {
					self.loadingView?.alpha = 0.0;
				}, completion: { (isfinished) in
					// 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
					if self.state != .idle { return }
					
					self.loadingView?.alpha = 1.0
					self.loadingView?.stopAnimating()
					self.arrowView?.isHidden = false
				})
			} else {
				self.loadingView?.stopAnimating()
				self.arrowView?.isHidden = false
				UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
					self.arrowView?.transform = .identity
				}
			}
		}else if state == .pulling {
			self.loadingView?.stopAnimating()
			self.arrowView?.isHidden = false
			UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
				self.arrowView?.transform = CGAffineTransform(rotationAngle: CGFloat(0.000001 - Double.pi))
			}
		}else if state == .refreshing {
			self.loadingView?.alpha = 1.0 // 防止refreshing -> idle的动画完毕动作没有被执行
			self.loadingView?.startAnimating()
			self.arrowView?.isHidden = true
		}
	}
}
