//
//  SimpleStockView.swift
//  SimpleStocks
//
//  Created by Yuriy Zabroda on 1/15/16.
//
//

import UIKit


protocol SimpleStockViewDataSource: NSObjectProtocol {
    func graphViewDailyTradeInfoCount(graphView: SimpleStockView) -> NSInteger
    func graphView(graphView: SimpleStockView, tradeCountForMonth components: NSDateComponents) -> NSInteger
    func graphViewSortedMonths(graphView: SimpleStockView) -> [NSDateComponents]
    func graphViewDailyTradeInfos(graphView: SimpleStockView)
    func graphViewMaxClosingPrice(graphView: SimpleStockView)
    func graphViewMinClosingPrice(graphView: SimpleStockView)
    func graphViewMaxTradingVolume(graphView: SimpleStockView)
    func graphViewMinTradingVolume(graphView: SimpleStockView)
}




class SimpleStockView: UIView {

    weak var dataSource: SimpleStockViewDataSource?




    override func drawRect(rect: CGRect) {
        let dataRect = closingDataRect()
        let volumeRect = volumeDataRect()

        // Step 1: draw the backgroud gradient.
        drawBackgroundGradient()

        // Step 2: draw the first part of the grid to give the data context.
        drawVerticalGridInRect(dataRect, volumeGraphHeight: CGRectGetHeight(volumeRect), priceLabelWidth: priceLabelWidth())
    }



    // MARK: - Drawing Methods

    private func pathFromDataInRect(rect: CGRect) -> UIBezierPath {
        return UIBezierPath()
    }


    private func bottomClipPathFromDataInRect(rect: CGRect) -> UIBezierPath {
        return UIBezierPath()
    }


    // MARK: - Miscellaneous Private Methods

    private func closingDataRect() -> CGRect {
        let top: CGFloat = 57.0
        let textHeight: CGFloat = 25.0
        let bottom = bounds.size.height - (textHeight + volumeGraphHeight())

        let left: CGFloat = 0.0
        let right = CGRectGetWidth(bounds) - priceLabelWidth()

        return CGRect(x: left, y: top, width: right, height: bottom - top)
    }



    private func priceLabelWidth() -> CGFloat {
        // NYI
        return CGFloat(128)
    }



    private func volumeGraphHeight() -> CGFloat {
        // Tweaked...
        return 37.0
    }


    private func volumeDataRect() -> CGRect {
        let textHeight: CGFloat = 25.0
        let bottom = bounds.size.height - (textHeight + volumeGraphHeight())

        let left: CGFloat = 0.0
        let right = CGRectGetWidth(bounds) - priceLabelWidth()

        return CGRect(x: left, y: bottom, width: right, height: volumeGraphHeight())
    }


    private func drawBackgroundGradient() {
        let context = UIGraphicsGetCurrentContext()
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 0.0, y: bounds.size.height)

        CGContextDrawLinearGradient(context, backgroundGradient, startPoint, endPoint, [])
    }



    private func drawVerticalGridInRect(dataRect: CGRect, volumeGraphHeight: CGFloat, priceLabelWidth: CGFloat) {
        let gridColor = UIColor(red: 74.0 / 255.0, green: 86.0 / 255.0, blue: 126 / 255.0, alpha: 1.0)
        gridColor.setStroke()

        let dataCount = dataSource!.graphViewDailyTradeInfoCount(self)
        let sortedMonths = dataSource!.graphViewSortedMonths(self)

        let gridLinePath = UIBezierPath()
        gridLinePath.moveToPoint(CGPoint(x: rint(CGRectGetMinX(dataRect)), y: CGRectGetMinY(dataRect)))
        gridLinePath.addLineToPoint(CGPoint(x: rint(CGRectGetMinX(dataRect)), y: CGRectGetMaxY(dataRect) + volumeGraphHeight))
        gridLinePath.lineWidth = 2.0

        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)

        // Round to an integer point.
        let tradingDayLineSpacing = rint(CGRectGetWidth(dataRect) / CGFloat(dataCount))

        for month in sortedMonths {
            let linePosition = tradingDayLineSpacing * CGFloat(dataSource!.graphView(self, tradeCountForMonth: month))
            CGContextTranslateCTM(context, rint(linePosition), 0.0)
            gridLinePath.stroke()
        }
    }


    // MARK: - Private Properties

    lazy var backgroundGradient: CGGradientRef = {
        let colors: [CGFloat] = [
            48.0 / 255.0, 61.0 / 255.0, 114.0 / 255.0, 1.0,
            33.0 / 255.0, 47.0 / 255.0, 113.0 / 255.0, 1.0
        ]

        let colorStops: [CGFloat] = [0.0, 0.5, 0.5, 1.0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bg = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4)

        return bg!
    }()


    // MARK: - Private Filds

    var blueBlendGradient: CGGradientRef!
    var initialDataPoint = CGPointZero
}
