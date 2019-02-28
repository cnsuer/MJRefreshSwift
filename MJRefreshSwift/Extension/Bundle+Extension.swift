
//
//  File.swift
//  MJRefreshSwift
//
//  Created by apple on 2018/10/22.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

extension Bundle {
	
	class func mj_refreshBundle() -> Bundle? {
		var refreshBundle: Bundle?
		// 这里不使用mainBundle是为了适配pod 1.x和0.x
		if let path = Bundle.init(for: MJRefreshComponent.self).path(forResource: "MJRefresh", ofType: "bundle") {
			refreshBundle = Bundle(path: path)
		}
		return refreshBundle
	}
	
	class func mj_localizedStringForKey(_ key: String, value:String? = nil) -> String {
		// （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans，其他按照系统默认处理
		guard let firstLanguage = Locale.preferredLanguages.first else { return "" }
		var language: String = "en"
		if firstLanguage.hasPrefix("en") {
			language = "en"
		} else if firstLanguage.hasPrefix("zh") {
			language = "zh-Hans" // 简体中文
		}
		if let path = Bundle.mj_refreshBundle()?.path(forResource: language, ofType: "lproj"), let bundle = Bundle(path: path) {
			let	text = bundle.localizedString(forKey: key, value: value, table: nil)
			return text
		}
		return Bundle.main.localizedString(forKey: key, value: value, table: nil)
	}
	
	class func mj_arrowImage() -> UIImage? {
		if let path = Bundle.mj_refreshBundle()?.path(forResource: "arrow@2x", ofType: "png") {
			let arrowImage = UIImage.init(contentsOfFile: path)?.withRenderingMode(.alwaysTemplate)
			return arrowImage
		}
		return nil
	}
}
