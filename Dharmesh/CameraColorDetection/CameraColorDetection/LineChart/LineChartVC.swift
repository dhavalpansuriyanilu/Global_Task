//
//  LineChartVC.swift
//  CameraColorDetection
//
//  Created by Mr. Dharmesh on 14/06/24.
//

import UIKit
//import QuartzCore


class LineChartVC: UIViewController, LineChartDelegate {

    @IBOutlet weak var lineChartView: UIView!
    
    var lineChart: LineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGraph()
        
    }
    
    func setGraph(){
        // Data Y axis
        let chart1: [CGFloat] = [6, 8, 3, 5, 6, 7]
        let chart2: [CGFloat] = [4, 5, 6, 3, 5, 6]
        
        // Data X axis
        let xLabels: [String] = ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.y.labels.visible = false
        lineChart.x.grid.color = UIColor.darkGray.withAlphaComponent(0.2)
        lineChart.y.grid.color = UIColor.darkGray.withAlphaComponent(0.2)
        lineChart.x.grid.count = 8
        lineChart.y.grid.count = 8
        lineChart.x.labels.values = xLabels
        lineChart.addLine(chart1)
        lineChart.addLine(chart2)
        lineChart.x.axis.color =  UIColor.darkGray.withAlphaComponent(0.2)
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        lineChartView.addSubview(lineChart)
        
        // Add constraints for the chart
        NSLayoutConstraint.activate([
            lineChart.leadingAnchor.constraint(equalTo: lineChartView.leadingAnchor),
            lineChart.trailingAnchor.constraint(equalTo: lineChartView.trailingAnchor),
            lineChart.topAnchor.constraint(equalTo: lineChartView.topAnchor),
            lineChart.bottomAnchor.constraint(equalTo: lineChartView.bottomAnchor)
        ])
    }
    
    /**
     * Line chart delegate method.
     */
    func didSelectDataPoint(_ x: CGFloat, yValues: [CGFloat]) {
        // You can add any action here if needed
    }
    
    /**
     * Redraw chart on device rotation.
     */
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//        if let chart = lineChart {
//            chart.setNeedsDisplay()
//        }
    }

}
