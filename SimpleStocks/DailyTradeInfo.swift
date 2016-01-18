//
//  DailyTradeInfo.swift
//  SimpleStocks
//
//  Created by Yuriy Zabroda on 1/18/16.
//
//

import UIKit



struct DailyTradeInfo {
    var tradingDate: NSDate
    var openingPrice: NSNumber
    var highPrice: NSNumber
    var lowPrice: NSNumber
    var closingPrice: NSNumber
    var tradingVolume: NSNumber
}



//
//
//
extension DailyTradeInfo: Equatable { }


func ==(lhs: DailyTradeInfo, rhs: DailyTradeInfo) -> Bool {
    return .OrderedSame == lhs.tradingDate.compare(rhs.tradingDate)
}



//
//
//
extension DailyTradeInfo: Comparable {  }

func <(lhs: DailyTradeInfo, rhs: DailyTradeInfo) -> Bool {
    return NSComparisonResult.OrderedAscending == lhs.tradingDate.compare(rhs.tradingDate)
}
