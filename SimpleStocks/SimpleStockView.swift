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
    func graphViewDailyTradeInfos(graphView: SimpleStockView) -> [DailyTradeInfo]
    func graphViewMaxClosingPrice(graphView: SimpleStockView) -> CGFloat
    func graphViewMinClosingPrice(graphView: SimpleStockView) -> CGFloat
    func graphViewMaxTradingVolume(graphView: SimpleStockView) -> CGFloat
    func graphViewMinTradingVolume(graphView: SimpleStockView) -> CGFloat
}




class SimpleStockView: UIView {

    weak var dataSource: SimpleStockViewDataSource?




    override func drawRect(rect: CGRect) {
        let dataRect = closingDataRect()
        let volumeRect = volumeDataRect()

        // Clip to the rounded rectangle.
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 16.0, height: 16.0))
        path.addClip()

        // Step 1: draw the backgroud gradient.
        drawBackgroundGradient()

        // Step 2: draw the first part of the grid to give the data context.
        drawVerticalGridInRect(dataRect, volumeGraphHeight: CGRectGetHeight(volumeRect), priceLabelWidth: priceLabelWidth())

        // Step 3: draw the second part of the grid to give the data context.
        drawHorizontalGridInRect(dataRect, clip: true)

        // Step 4: draw the lines to emphasize the data.
        drawPatternUnderClosingData(dataRect, clip: true)
        drawLinePatternUnderClosingData(dataRect, clip: true)

        // Step 5: draw the volume data.
        drawVolumeDataInRect(volumeRect)

        // Step 6: draw the closing data.
        drawClosingDataInRect(dataRect)

        // Step 7: draw the month names under the graph.
        drawMonthNamesTextUnderDataRect(dataRect, volumeGraphHeight: volumeGraphHeight())
    }



    // MARK: - Drawing Methods

    //
    //
    //
    private func pathFromDataInRect(theRect: CGRect) -> UIBezierPath {
        let tradingDays = dataSource!.graphViewDailyTradeInfoCount(self)
        let maxClose = dataSource!.graphViewMaxClosingPrice(self)
        let minClose = dataSource!.graphViewMinClosingPrice(self)
        let dailyTradeInfos = dataSource!.graphViewDailyTradeInfos(self)

        let path = UIBezierPath()

        let lineWidth: CGFloat = 5.0
        path.lineWidth = lineWidth
        path.lineJoinStyle = .Round
        path.lineCapStyle = .Round

        // Inset so the path does not ever go beyond the frame of the graph.
        let rect = theRect.insetBy(dx: lineWidth / 2.0, dy: lineWidth)
        let horizontalSpacing = CGRectGetWidth(rect) / CGFloat(tradingDays)
        let verticalScale = CGRectGetHeight(rect) / (maxClose - minClose)
        var closingPrice = CGFloat(dailyTradeInfos[0].closingPrice.doubleValue)

        initialDataPoint = CGPoint(x: lineWidth / 2.0, y: (closingPrice - minClose) * verticalScale)
        path.moveToPoint(initialDataPoint)

        for i in 1..<(tradingDays - 1) {
            closingPrice = CGFloat(dailyTradeInfos[i].closingPrice.doubleValue)

            let pt = CGPoint(
                x: CGFloat(i + 1) * horizontalSpacing,
                y: CGRectGetMinY(rect) + (closingPrice - minClose) * verticalScale
            )

            path.addLineToPoint(pt)
        }

        closingPrice = CGFloat(dailyTradeInfos.last!.closingPrice.doubleValue)
        let pt = CGPoint(
            x: CGRectGetMaxX(rect),
            y: CGRectGetMinY(rect) + (closingPrice - minClose) * verticalScale
        )
        path.addLineToPoint(pt)

        return path
    }


    /**
     * @discussion Creates and returns a path that can be used to clip drawing
     * to the bottom of the data graph.
     *
     */
    private func bottomClipPathFromDataInRect(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()

        path.appendPath(pathFromDataInRect(rect))

        path.addLineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: path.currentPoint.y))
        path.addLineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect)))
        path.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect)))
        path.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: initialDataPoint.y))
        path.addLineToPoint(initialDataPoint)

        path.closePath()

        return path
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
        let minimum: CGFloat = 32.0
        let maximum: CGFloat = 54.0

        let size = (numberFormatter.stringFromNumber(dataSource!.graphViewMaxClosingPrice(self))! as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14)])
        var width = minimum

        if (size.width < maximum) && (size.width > minimum) {
            width = size.width
        }

        return width
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

        CGContextRestoreGState(context)

        //
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, rint(CGRectGetMaxX(dataRect)), 0.0)
        gridLinePath.stroke()
        CGContextRestoreGState(context)
    }



    /**
     *
     * @discussion Draws the line pattern, slowly changing the alpha of the stroke
     * color from 0.8 to 0.2.
     *
     */
    private func drawLinePatternUnderClosingData(rect: CGRect, clip: Bool) {
        let context = UIGraphicsGetCurrentContext()

        if clip {
            CGContextSaveGState(context)
            let clipPath = bottomClipPathFromDataInRect(rect)
            clipPath.addClip()
        }

        let path = UIBezierPath()
        let lineWidth: CGFloat = 1.0
        path.lineWidth = lineWidth

        // !!!
        // Because the line with is odd, offset the horizontal lines by 0.5 points.
        path.moveToPoint(CGPoint(x: 0.0, y: rint(CGRectGetMinY(rect)) + 0.5))
        path.addLineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: rint(CGRectGetMinY(rect)) + 0.5))

        var alpha: CGFloat = 0.8
        var startColor = UIColor(white: 1.0, alpha: alpha)
        startColor.setStroke()
        let step: CGFloat = 4.0
        let stepCount = CGRectGetHeight(rect) / step

        let alphaStep = (0.8 - 0.2) / stepCount

        CGContextSaveGState(context)

        var translation = CGRectGetMinY(rect)

        while (translation < CGRectGetMaxY(rect)) {
            path.stroke()
            CGContextTranslateCTM(context, 0.0, lineWidth * step)
            translation += lineWidth * step
            alpha -= alphaStep
            startColor = startColor.colorWithAlphaComponent(alpha)
            startColor.setStroke()
        }

        CGContextRestoreGState(context)

        if clip {
            CGContextRestoreGState(context)
        }
    }



    private func drawHorizontalGridInRect(dataRect: CGRect, clip: Bool) {
        let context = UIGraphicsGetCurrentContext()

        if clip {
            CGContextSaveGState(context)
            let clipPath = topClipPathFromDataInRect(dataRect)
            clipPath.addClip()
        }

        let path = UIBezierPath()
        path.lineWidth = 1.0
        var pt = CGPoint(
            x: rint(CGRectGetMinX(dataRect)),
            y: rint(CGRectGetMinY(dataRect) + 0.5)
        )
        path.moveToPoint(pt)

        pt = CGPoint(
            x: rint(CGRectGetMaxX(dataRect)),
            y: rint(CGRectGetMinY(dataRect)) + 0.5
        )
        path.addLineToPoint(pt)

        let dashPattern: [CGFloat] = [1.0, 1.0]

        path.setLineDash(dashPattern, count: 2, phase: 0.0)
        
        let gridColor = UIColor(
            red: 74.0 / 255.0,
            green: 86.0 / 255.0,
            blue: 126.0 / 255.0,
            alpha: 1.0
        )
        gridColor.setStroke()

        CGContextSaveGState(context)
        path.stroke()

        let step = rint(CGRectGetHeight(dataRect) / 5.0)
        for _ in 0..<5 {
            CGContextTranslateCTM(context, 0.0, step)
            path.stroke()
        }

        CGContextRestoreGState(context)

        if clip {
            CGContextRestoreGState(context)
        }
    }



    private func drawVolumeDataInRect(volumeGraphRect: CGRect) {
        let maxVolume = dataSource!.graphViewMaxTradingVolume(self)
        let minVolume = dataSource!.graphViewMinTradingVolume(self)
        let verticalScale = CGRectGetHeight(volumeGraphRect) / (maxVolume - minVolume)

        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)

        let tradingDayLineSpacing = rint(CGRectGetWidth(volumeGraphRect) / CGFloat(dataSource!.graphViewDailyTradeInfoCount(self)))
        var counter: CGFloat = 0.0
        let maxY = CGRectGetMaxY(volumeGraphRect)
        UIColor.whiteColor().setStroke()

        let dailyTradeInfos = dataSource!.graphViewDailyTradeInfos(self)

        for dailyTradeInfo in dailyTradeInfos {
            let path = UIBezierPath()
            path.lineWidth = 2.0
            let tradingVolume = CGFloat(dailyTradeInfo.tradingVolume.doubleValue)

            var pt = CGPoint(x: rint(counter * tradingDayLineSpacing), y: maxY)
            path.moveToPoint(pt)

            pt = CGPoint(
                x: rint(counter * tradingDayLineSpacing),
                y: maxY - (tradingVolume - minVolume) * verticalScale
            )
            path.addLineToPoint(pt)
    
            path.stroke()
            counter += 1.0
        }

        CGContextRestoreGState(context)
    }


    private func drawClosingDataInRect(rect: CGRect) {
        UIColor.whiteColor().setStroke()
        let path = pathFromDataInRect(rect)
        path.stroke()
    }


    private func drawMonthNamesTextUnderDataRect(dataRect: CGRect, volumeGraphHeight: CGFloat) {
        let dataCount = dataSource!.graphViewDailyTradeInfoCount(self)
        let sortedMonths = dataSource!.graphViewSortedMonths(self)

        let calendar = NSCalendar.currentCalendar()

        let dateFormatter = NSDateFormatter()
        let format = NSDateFormatter.dateFormatFromTemplate("MMMM", options: 0, locale: NSLocale.currentLocale())
        dateFormatter.dateFormat = format

//        UIColor.whiteColor().setFill()
        let font = UIFont.boldSystemFontOfSize(16)

        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)
        let shadowHeight: CGFloat = 2.0
        CGContextSetShadowWithColor(context, CGSize(width: 1.0, height: -shadowHeight) , 0.0, UIColor.darkGrayColor().CGColor)

        let tradingDayLineSpacing = rint(CGRectGetWidth(dataRect) / CGFloat(dataCount))

        for i in 0..<(sortedMonths.count - 1) {
            let linePosition = tradingDayLineSpacing * CGFloat(dataSource!.graphView(self, tradeCountForMonth: sortedMonths[i]))
            CGContextTranslateCTM(context, linePosition, 0.0)
            let date = calendar.dateFromComponents(sortedMonths[i + 1])
            let monthName = dateFormatter.stringFromDate(date!) as NSString
            let monthSize = monthName.sizeWithAttributes([NSFontAttributeName: font])
            let monthRect = CGRect(
                x: 0.0,
                y: CGRectGetMaxY(dataRect) + volumeGraphHeight + shadowHeight,
                width: monthSize.width,
                height: monthSize.height
            )

            monthName.drawInRect(monthRect, withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()])
        }

        CGContextRestoreGState(context)
    }



    private func topClipPathFromDataInRect(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()

        path.appendPath(pathFromDataInRect(rect))

        path.addLineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: path.currentPoint.y))
        path.addLineToPoint(CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMinY(rect)))
        path.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect)))
        path.addLineToPoint(CGPoint(x: CGRectGetMinX(rect), y: initialDataPoint.y))
        path.addLineToPoint(initialDataPoint)

        path.closePath()

        return path
    }



    private func drawPatternUnderClosingData(rect: CGRect, clip: Bool) {
        UIColor(patternImage: patternImageOfSize(CGSize(width: 32.0, height: 32.0))).setFill()

        if clip {
            let path = bottomClipPathFromDataInRect(rect)
            path.fill()
        } else {
            UIRectFill(rect)
        }
    }



    private func patternImageOfSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)

        let center = CGPoint(
            x: floor(size.width / 2.0),
            y: floor(size.height) / 2.0
        )

        drawRadialGradientInSize(size, center: center)

        let lineColor = UIColor(
            red: 211.0 / 255.0,
            green: 218.0 / 255.0,
            blue: 182.0 / 255.0,
            alpha: 1.0
        )
        lineColor.setStroke()

        var start = CGPoint(x: 0.0, y: 0.0)
        var end = CGPoint(x: floor(size.width), y: floor(size.height))
        drawLineFromPoint(start, toPoint: end)

        start = CGPoint(x: 0.0, y: floor(size.height))
        end = CGPoint(x: floor(size.width), y: 0.0)
        drawLineFromPoint(start, toPoint: end)

        let patternImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return patternImage
    }


    private func drawRadialGradientInSize(size: CGSize, center: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        let startRadius: CGFloat = 0.0
        let endRadius = 0.85 * pow(floor(size.width / 2.0) * floor(size.width / 2.0)
            + floor(size.height / 2.0) * floor(size.height / 2.0), 0.5)

        CGContextDrawRadialGradient(context, blueBlendGradient, center, startRadius, center, endRadius, .DrawsAfterEndLocation)
    }



    private func drawLineFromPoint(start: CGPoint, toPoint end: CGPoint) {
        let path = UIBezierPath()

        path.lineWidth = 2.0
        path.moveToPoint(start)
        path.addLineToPoint(end)

        path.stroke()
    }


    // MARK: - Private Properties

    lazy var backgroundGradient: CGGradientRef = {
        let colors: [CGFloat] = [
            48.0 / 255.0, 61.0 / 255.0, 114.0 / 255.0, 1.0,
            33.0 / 255.0, 47.0 / 255.0, 113.0 / 255.0, 1.0,
            20.0 / 255.0, 33.0 / 255.0, 104.0 / 255.0, 1.0,
            20.0 / 255.0, 33.0 / 255.0, 104.0 / 255.0, 1.0
        ]

        let colorStops: [CGFloat] = [0.0, 0.5, 0.5, 1.0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bg = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4)

        return bg!
    }()


    lazy var numberFormatter: NSNumberFormatter = {
        return NSNumberFormatter()
    }()


    // MARK: - Private Filds

    private lazy var blueBlendGradient: CGGradientRef = {
        let colors: [CGFloat] = [
            0.0,
            80.0 / 255.0,
            89.0 / 255.0,
            1.0,
            0.0,
            50.0 / 255.0,
            64.0 / 255.0,
            1.0
        ]

        let locations: [CGFloat] = [0.0, 0.9]

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bbg = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2)

        return bbg!
    }()

    private var initialDataPoint = CGPointZero
}
