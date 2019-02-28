//
//  MJRefreshStateHeader.swift
//  MJRefreshSwift
//
//  Created by apple on 2019/2/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

class MJRefreshStateHeader: MJRefreshHeader {

	private typealias lastUpdatedTimeCallBack = (_ lastUpdatedTime: Date) -> (String)
	
//MARK: 刷新时间相关
	/** 利用这个block来决定显示的更新时间文字 */
	private var lastUpdatedTimeText: lastUpdatedTimeCallBack?
	
	/** 显示上一次刷新时间的label */
	lazy var lastUpdatedTimeLabel: UILabel = {
		let label = UILabel.mj_label()
		addSubview(label)
		return label
	}()
	
	/** 文字距离圈圈、箭头的距离 */
	var labelLeftInset: CGFloat = 0.0

	/** 显示刷新状态的label */
	lazy var stateLabel: UILabel = {
		let label = UILabel.mj_label()
		addSubview(label)
		return label
	}()
	
	//状态相关
	private var stateTitles = Dictionary<MJRefreshState, String>()
	
	override func prepare() {
		
		super.prepare()
		
		// 初始化间距
		self.labelLeftInset = MJRefreshLabelLeftInset
		
		// 初始化文字
		self.setTitle(Bundle.mj_localizedStringForKey(MJRefreshHeaderIdleText), for: .idle)
		self.setTitle(Bundle.mj_localizedStringForKey(MJRefreshHeaderPullingText), for: .pulling)
		self.setTitle(Bundle.mj_localizedStringForKey(MJRefreshHeaderRefreshingText), for: .refreshing)
	}
	
	override func placeSubviews() {
		super.placeSubviews()
		
		if self.stateLabel.isHidden { return }
		
		let noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0
		
		if self.lastUpdatedTimeLabel.isHidden {
			// 状态
			if noConstrainsOnStatusLabel {
				self.stateLabel.frame = self.bounds
			}
		}else {
			let stateLabelH = self.mj_h * 0.5;
			// 状态
			if noConstrainsOnStatusLabel {
				self.stateLabel.mj_x = 0
				self.stateLabel.mj_y = 0
				self.stateLabel.mj_w = self.mj_w
				self.stateLabel.mj_h = stateLabelH
			}
			// 更新时间
			if self.lastUpdatedTimeLabel.constraints.count == 0 {
				self.lastUpdatedTimeLabel.mj_x = 0
				self.lastUpdatedTimeLabel.mj_y = stateLabelH
				self.lastUpdatedTimeLabel.mj_w = self.mj_w
				self.lastUpdatedTimeLabel.mj_h = self.mj_h - self.lastUpdatedTimeLabel.mj_y
			}
		}
	}
	
	override func mj_setState(_ oldState: MJRefreshState) {
		//状态未改变的话直接返回
		if state == oldState { return }
		
		super.mj_setState(oldState)
		// 设置状态文字
		self.stateLabel.text = self.stateTitles[state];
		
		// 重新设置key（重新显示时间）
		self.lastUpdatedTimeKey = self.lastUpdatedTimeKey
	}
	
	/** 设置state状态下的文字 */
	func setTitle(_ title: String?, for state: MJRefreshState) {
		if title == nil { return }
		self.stateTitles[state] = title
		self.stateLabel.text = self.stateTitles[self.state]
	}
	
	//日历获取在9.x之后的系统使用currentCalendar会出异常。在8.0之后使用系统新API。
	private func currentCalendar() -> Calendar {
		return Calendar.init(identifier: .gregorian)
	}
	
	override func setLastUpdatedTimeKey() {
		super.setLastUpdatedTimeKey()
		// 如果label隐藏了，就不用再处理
		if self.lastUpdatedTimeLabel.isHidden { return }
		
		let lastUpdatedTime = UserDefaults.standard.object(forKey: self.lastUpdatedTimeKey)
		// 如果有block
		if let lastUpdatedTimeText = self.lastUpdatedTimeText ,let lastUpdatedTime = lastUpdatedTime as? Date {
			self.lastUpdatedTimeLabel.text = lastUpdatedTimeText(lastUpdatedTime)
			return
		}
		
		if let lastUpdatedTime = lastUpdatedTime as? Date {
			// 1.获得年月日
			let calendar = self.currentCalendar()
			let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
			let cmp1 = calendar.dateComponents(unitFlags, from: lastUpdatedTime)
			let cmp2 = calendar.dateComponents(unitFlags, from: Date())
			
			// 2.格式化日期
			let formatter = DateFormatter()
			var isToday = false
			if cmp1.day == cmp2.day { // 今天
				formatter.dateFormat = " HH:mm"
				isToday = true
			} else if cmp1.year == cmp2.year { // 今年
				formatter.dateFormat = "MM-dd HH:mm"
			} else {
				formatter.dateFormat = "yyyy-MM-dd HH:mm"
			}
			let time = formatter.string(from: lastUpdatedTime)
			
			// 3.显示日期
			let lastimeText = Bundle.mj_localizedStringForKey(MJRefreshHeaderLastTimeText)
			let dateTodayText = isToday ? Bundle.mj_localizedStringForKey(MJRefreshHeaderDateTodayText) : ""
			self.lastUpdatedTimeLabel.text = lastimeText + dateTodayText + time
		} else {
			let lastimeText = Bundle.mj_localizedStringForKey(MJRefreshHeaderLastTimeText)
			let dateTodayText = Bundle.mj_localizedStringForKey(MJRefreshHeaderNoneLastDateText)
			self.lastUpdatedTimeLabel.text = lastimeText + dateTodayText
		}
	}
}
