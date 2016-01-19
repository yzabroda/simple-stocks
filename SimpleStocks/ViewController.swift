//
//  ViewController.swift
//  SimpleStocks
//
//  Created by Yuriy Zabroda on 1/15/16.
//
//

import UIKit



class ViewController: UIViewController, SimpleStockViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        simpleStockView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func graphViewDailyTradeInfoCount(graphView: SimpleStockView) -> NSInteger {
        return DailyTradeInfoSource.tradeInfoArray.count
    }



    func graphView(graphView: SimpleStockView, tradeCountForMonth components: NSDateComponents) -> NSInteger {
        let calendar = NSCalendar.currentCalendar()
        let closingDates = DailyTradeInfoSource.tradeInfoArray.map { $0.tradingDate }

        let months = NSCountedSet()

        for closingDate in closingDates {
            months.addObject(calendar.components(.Month, fromDate: closingDate))
        }

        return months.countForObject(components)
    }



    /**
     * @return The month to be drawn
     */
    func graphViewSortedMonths(graphView: SimpleStockView) -> [NSDateComponents] {
        let calendar = NSCalendar.currentCalendar()
        let closingDates = DailyTradeInfoSource.tradeInfoArray.map { $0.tradingDate }

        let months = NSCountedSet()

        for closingDate in closingDates {
            months.addObject(calendar.components(.Month, fromDate: closingDate))
        }

        let sortDescriptor = NSSortDescriptor(key: "month", ascending: true)

        return months.sortedArrayUsingDescriptors([sortDescriptor]) as! [NSDateComponents]
    }


    func graphViewDailyTradeInfos(graphView: SimpleStockView) -> [DailyTradeInfo] {
        return DailyTradeInfoSource.tradeInfoArray
    }


    func graphViewMaxClosingPrice(graphView: SimpleStockView) -> CGFloat {
        return DailyTradeInfoSource.tradeInfoArray.reduce(CGFloat.min) {
            max($0, CGFloat($1.closingPrice.doubleValue))
        }
    }


    func graphViewMinClosingPrice(graphView: SimpleStockView) -> CGFloat {
        return DailyTradeInfoSource.tradeInfoArray.reduce(CGFloat.max) {
            min($0, CGFloat($1.closingPrice.doubleValue))
        }
    }


    func graphViewMaxTradingVolume(graphView: SimpleStockView) -> CGFloat {
        return DailyTradeInfoSource.tradeInfoArray.reduce(CGFloat.min) {
            max($0, CGFloat($1.tradingVolume.doubleValue))
        }
    }



    func graphViewMinTradingVolume(graphView: SimpleStockView) -> CGFloat {
        return DailyTradeInfoSource.tradeInfoArray.reduce(CGFloat.max) {
            min($0, CGFloat($1.tradingVolume.doubleValue))
        }
    }



    @IBOutlet weak var simpleStockView: SimpleStockView!
}

