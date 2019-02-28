//
//  MJRefreshSwift+Extension.swift
//  MJRefreshSwift
//
//  Created by apple on 2018/10/19.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

extension UIView {
	
	var mj_x: CGFloat {
		get {
			return self.frame.origin.x
		}
		set {
			self.frame.origin.x = newValue
		}
	}
	
	var mj_y: CGFloat {
		get {
			return self.frame.origin.y
		}
		set {
			self.frame.origin.y = newValue
		}
	}
	var mj_w: CGFloat {
		get {
			return self.frame.size.width
		}
		set {
			self.frame.size.width = newValue
		}
	}
	
	var mj_h: CGFloat {
		get {
			return self.frame.size.height
		}
		set {
			self.frame.size.height = newValue
		}
	}
	
	var mj_size: CGSize {
		get {
			return self.frame.size
		}
		set {
			self.frame.size = newValue
		}
	}
	
}
