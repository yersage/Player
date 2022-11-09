//
//  ViewController.swift
//  Player
//
//  Created by user on 01.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var center: UIView = {
        let centerView = UIView()
        centerView.backgroundColor = .red
        centerView.translatesAutoresizingMaskIntoConstraints = false
        return centerView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var timeframeView: TimeframeView = {
        let ruler = TimeframeView()
        ruler.backgroundColor = .white
        ruler.isUserInteractionEnabled = true
        ruler.translatesAutoresizingMaskIntoConstraints = false
        return ruler
    }()
    
    private var currentMinutes: CGFloat = 0.0
    
    private var rulerWidthConstraint: NSLayoutConstraint!
    
    private var recordRanges = [
        RecordRangeModel(startTime: "1665367201", endTime: "1665395040217604"),
        RecordRangeModel(startTime: "1665395117059224", endTime: "1665395574022637"),
        RecordRangeModel(startTime: "1665396477244332", endTime: "1665397002596221"),
        RecordRangeModel(startTime: "1665397111438812", endTime: "1665399601")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for recordRange in recordRanges {
//            let date = Date(timeIntervalSince1970: Double(recordRange.startTime.prefix(10))!)
//            let date2 = Date(timeIntervalSince1970: Double(recordRange.endTime.prefix(10))!)
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.timeStyle = DateFormatter.Style.medium
//            dateFormatter.dateStyle = DateFormatter.Style.short
//            dateFormatter.timeZone = .current
//
//            print(dateFormatter.string(from: date))
//            print(dateFormatter.string(from: date2))
//        }
        
        view.addSubview(currentValueLabel)
        view.addSubview(center)
        
        view.addSubview(scrollView)
        scrollView.addSubview(timeframeView)
        
        timeframeView.recordRanges = recordRanges
        
        scrollView.addGestureRecognizer(UIPinchGestureRecognizer(target: self,
                                                            action: #selector(didPinch(_:))))
        
        view.bringSubviewToFront(center)
                
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            currentValueLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            currentValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            center.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            center.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -20),
            center.heightAnchor.constraint(equalToConstant: 30),
            center.widthAnchor.constraint(equalToConstant: 1),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 100),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            timeframeView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            timeframeView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            timeframeView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            timeframeView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
        ])

        rulerWidthConstraint = timeframeView.widthAnchor.constraint(equalToConstant: timeframeView.currentScaleLength + UIScreen.main.bounds.width)

        NSLayoutConstraint.activate([
            timeframeView.heightAnchor.constraint(equalToConstant: 100),
            rulerWidthConstraint
        ])
    }
}

extension ViewController {
    
    @objc func didPinch(_ gestureRecognizer : UIPinchGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .changed {
            
            timeframeView.currentScaleLength *= gestureRecognizer.scale
            
            rulerWidthConstraint.constant = timeframeView.currentScaleLength + UIScreen.main.bounds.width
            gestureRecognizer.scale = 1.0
            timeframeView.setNeedsDisplay()
            
            let pointToScroll = CGPoint(x: (currentMinutes * timeframeView.distanceBetweenScales),
                                        y: 0)
            scrollView.setContentOffset(pointToScroll, animated: false)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentMinutes = scrollView.contentOffset.x / timeframeView.distanceBetweenScales
        let currentMinutes = Int(Float(currentMinutes) * 60)
        currentValueLabel.text = String(format: "%02d:%02d:%02d", currentMinutes / 3600, (currentMinutes / 60) % 60, currentMinutes % 60)
    }
}

