//
//  ChartViewController.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 24.08.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
//import Charts

/*
class MotoChart: UIView, ChartViewDelegate {


    @IBOutlet weak var lineChartView: LineChartView!
    
    // 1 - creating an array of data entries
    var yVals1 : [ChartDataEntry] = [ChartDataEntry]()

    
    //MARK: overrides
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    override func awakeFromNib() {
    }
    
    
    func setupChart(_ routeMaster: RouteMaster, type: String?){
        
      self.lineChartView.delegate = self


      self.lineChartView.descriptionTextColor = UIColor.whiteColor()
      //self.lineChartView.gridBackgroundColor = UIColor.darkGrayColor()
      self.lineChartView.noDataText = "No data provided"
      self.lineChartView.rightAxis.enabled = false
      self.lineChartView.drawGridBackgroundEnabled = false
      self.lineChartView.doubleTapToZoomEnabled = false
      self.lineChartView.xAxis.drawGridLinesEnabled = false
      self.lineChartView.xAxis.drawAxisLineEnabled = false
      self.lineChartView.rightAxis.drawGridLinesEnabled = false
      self.lineChartView.rightAxis.drawAxisLineEnabled = false
      self.lineChartView.leftAxis.drawGridLinesEnabled = false
      self.lineChartView.leftAxis.labelTextColor = UIColor.whiteColor()
      self.lineChartView.leftAxis.drawAxisLineEnabled = false
      self.lineChartView.animate(yAxisDuration: 1.0)

      let xValsArr = routeMaster.routeListTimestamps
      
      //self.lineChartView.descriptionText = "Speed"
      var yValsArr = routeMaster.routeListSpeeds
      var label = "Spped"
      
        if(type=="alt"){
            yValsArr = routeMaster.routeListAltitudes
            label = "Alt"
        }
        
        
      setChartData(xValsArr as [Date], yValsArr: yValsArr, label: label)
    }
    
   
    func setChartData(_ xValsArr: [Date], yValsArr: [Double], label: String) {
    
        for (index, item) in xValsArr.enumerated() {
            yVals1.append(ChartDataEntry(value: yValsArr[index], xIndex: index))
        }
        
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: label)
        set1.axisDependency = .Left // Line will correlate with left axis values
        set1.setColor(UIColor.whiteColor().colorWithAlphaComponent(1)) // our line's opacity is 50%
       
        set1.drawCirclesEnabled = false
        //set1.setCircleColor(UIColor.redColor()) // our circle will be dark red
        set1.lineWidth = 0.5
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 100 / 255.0
        set1.fillColor = UIColor.whiteColor()
        set1.drawFilledEnabled = true
        set1.highlightColor = UIColor.whiteColor()
        set1.valueTextColor = UIColor.whiteColor()
        set1.drawCircleHoleEnabled = true
        set1.fill = ChartFill(linearGradient: colorUtils.getGradient(), angle: 90)
        
        
        //3 - create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        
        dataSets.append(set1)
        
        //4 - pass our data in for our x-axis label value along with our dataSets        
        let data: LineChartData = LineChartData(xVals: xValsArr, dataSets: dataSets)
        data.setValueTextColor(UIColor.whiteColor())
        

        self.lineChartView.data = data
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print(" Chart Value \(entry.value)  \(entry.xIndex)")
        let key = [entry.xIndex]
        NotificationCenter.defaultCenter().postNotificationName(chartSetNotificationKey, object: key)
    }
    
}*/
