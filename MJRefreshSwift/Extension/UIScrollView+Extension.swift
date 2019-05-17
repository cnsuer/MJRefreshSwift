//
//  UIScrollView+Extension.swift
//  MJRefreshSwift
//
//  Created by apple on 2018/10/19.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

public extension UIScrollView {
	
	private struct MJRefreshHeaderKeys {
		static var MJRefreshHeaderKey: CGFloat = 1.0
	}
		
	public var mj_header: MJRefreshHeader? {
		get{
			if let header = objc_getAssociatedObject(self, &MJRefreshHeaderKeys.MJRefreshHeaderKey) as? MJRefreshHeader {
				return header
			}
			return nil
		}
		set{
			if let newHeader = newValue, newValue != self.mj_header {
				// 删除旧的，添加新的
				self.mj_header?.removeFromSuperview()
				self.insertSubview(newHeader, at: 0)
				// 存储新的
				objc_setAssociatedObject(self, &MJRefreshHeaderKeys.MJRefreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
		}
	}
}

public extension UIScrollView {
	
	var mj_inset: UIEdgeInsets {
		get {
			if #available(iOS 11.0, *) {
				return self.adjustedContentInset
			} else {
				return self.contentInset
			}
		}
	}
	
	var mj_insetT: CGFloat {
		get {
			return self.mj_inset.top
		}
		set {
			var inset = self.contentInset
			inset.top = newValue
			if #available(iOS 11.0, *) {
				inset.top -= (self.adjustedContentInset.top - self.contentInset.top)
			}
			self.contentInset = inset
		}
	}
	var mj_insetB: CGFloat {
		get {
			return self.mj_inset.bottom
		}
		set {
			self.contentInset.bottom = newValue
			if #available(iOS 11.0, *) {
				self.contentInset.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom)
			}
		}
	}
	
	var mj_insetL: CGFloat {
		get {
			return self.mj_inset.left
		}
		set {
			self.contentInset.left = newValue
			if #available(iOS 11.0, *) {
				self.contentInset.left -= (self.adjustedContentInset.left - self.contentInset.left)
			}
		}
	}
	
	var mj_insetR: CGFloat {
		get {
			return self.mj_inset.right
		}
		set {
			self.contentInset.right = newValue
			if #available(iOS 11.0, *) {
				self.contentInset.right -= (self.adjustedContentInset.right - self.contentInset.right)
			}
		}
	}
	
	var mj_offsetX: CGFloat {
		get {
			return self.contentOffset.x
		}
		set {
			self.contentOffset.x = newValue
		}
	}
	
	var mj_offsetY: CGFloat {
		get {
			return self.contentOffset.y
		}
		set {
			self.contentOffset.y = newValue
		}
	}
	
	var mj_contentW: CGFloat {
		get {
			return self.contentSize.width
		}
		set {
			self.contentSize.width = newValue
		}
	}
	
	var mj_contentH: CGFloat {
		get {
			return self.contentSize.height
		}
		set {
			self.contentSize.height = newValue
		}
	}
}

