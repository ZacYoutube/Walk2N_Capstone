//
//  shortCut.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase
import Charts

extension UIView {
    
    // make it easier to just query view.width instead of view.frame.size.width
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var btm: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat? = 0,
                paddingLeft: CGFloat? = 0, paddingBottom: CGFloat? = 0, paddingRight: CGFloat? = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft!).isActive = true
        }
        
        if let bottom = bottom {
            if let paddingBottom = paddingBottom {
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            }
        }
        
        if let right = right {
            if let paddingRight = paddingRight {
                rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            }
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}

extension UIViewController {
    // hide keyboard
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // push to navigation stack [ for convenience purposes ]
    func navigateToController(destController: Any) {
        self.navigationController!.pushViewController(destController as! UIViewController, animated: true)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // shared navbar across different view controllers [ under development ]
    func setUpNavbar(text: String) {
        
        //        var alert = UIButton(type: .custom)
        var balance = UIButton(type: .custom)
        var alert = ButtonWithBadge()
        alert.isRead = true
        
        let alertButtonItem = UIBarButtonItem(customView: alert)
        let balanceItem = UIBarButtonItem(customView: balance)
        
        
        alert.setOnClickListener {
            let alertView = AlertViewController()
            alertView.title = "Notification History"
            self.present(UINavigationController(rootViewController: alertView), animated: true)
            alert.isRead = true
        }
        
        var alertIcon = UIImage(named: "notify.png")!
        alertIcon = resizeImage(image: alertIcon, newWidth: 30)
        alert.setImage(alertIcon, for: .normal)
        
        var balanceIcon = UIImage(named: "coin.png")!
        balanceIcon = resizeImage(image: balanceIcon, newWidth: 30)
        balance.setImage(balanceIcon, for: .normal)
        
        let containView = UIView(frame: CGRectMake(0, 0, 120, 40))
        let balanaceLabel = UILabel(frame: CGRectMake(0, 0, 80, 40))
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                let balanceNow =  (doc["balance"] as! Double).truncate(places: 2)
                //                balanaceLabel.text = String(balanceNow)
                
                let bl = UIAction(title: "Balance: \(String(balanceNow))", image: nil ) { (action) in
                    print("Balance was tapped")
                }
                let menu = UIMenu(title: "Current Balance", options: .displayInline, children: [bl])
                
                balance.setOnClickListener {
                    balance.menu = menu
                    balance.showsMenuAsPrimaryAction = true
                }
                
                if doc["alertHist"] != nil && (doc["alertHist"] as? [Any]) != nil {
                    if (doc["alertHist"] as! [Any]).count > 0 {
                        alert.isRead = false
                    }
                }
                
                //                if doc["profileImgUrl"] != nil && (doc["profileImgUrl"] as? String) != nil {
                //                    if let url = URL(string: doc["profileImgUrl"] as! String) {
                //                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                //                            guard let imageData = data else { return }
                //                            DispatchQueue.main.async { [self] in
                //                                var profileImage = UIImage(data: imageData)
                //                                profileImage = resizeImage(image: profileImage!, newWidth: 45).circleMasked
                //
                //                                profile.setImage(profileImage, for: .normal)
                //                                profile.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
                //                                profile.addTarget(self, action: #selector(navigateToProfile), for: .touchUpInside)
                //                            }
                //                        }.resume()
                //                    }
                //                }
            }
        }
        
        DatabaseManager.shared.checkUserUpdates { data, update, added, deleted in
            if update == true {
                let balance = (data["balance"] as! Double).truncate(places: 2)
                balanaceLabel.text = String(balance)
            }
        }
        
        let navigationLabel = UILabel()
        navigationLabel.textColor = UIColor.lessDark
        navigationLabel.text = text
        navigationLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        balanaceLabel.textAlignment = NSTextAlignment.center
        balanaceLabel.layer.borderWidth = 0.2
        balanaceLabel.layer.borderColor = UIColor.lightGray.cgColor
        balanaceLabel.layer.cornerRadius = 10
        //        label.center = containView.center
        
        containView.addSubview(balanaceLabel)
        
        let imageview = UIImageView(frame: CGRectMake(90, 10, 20, 20))
        imageview.image = UIImage(named: "zec.svg")
        imageview.contentMode = UIView.ContentMode.scaleAspectFill
        
        
        containView.addSubview(imageview)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 20
        
        self.navigationItem.rightBarButtonItems = [alertButtonItem, space, balanceItem]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationLabel)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @objc func navigateToProfile(){
        self.tabBarController?.selectedIndex = 4
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
//        guard let window = self.window else {
//            return
//        }
        
        // change the root view controller to your specific view controller
        UIApplication.shared.keyWindow?.rootViewController = vc
        UIView.transition(with:  UIApplication.shared.keyWindow!, duration: 1, options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }
}



// truncate double decimals
extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

// convert date to day of the week and get its timestamp
extension Date {
    typealias UnixTimestamp = Int
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let str = dateFormatter.string(from: self)
        let start = String.Index(utf16Offset: 0, in: str)
        let end = String.Index(utf16Offset: 3, in: str)
        let substring = String(str[start..<end])
        return substring.capitalized
    }
    var unixTimestamp: UnixTimestamp {
        return UnixTimestamp(self.timeIntervalSince1970 * 1_000)
    }
}

extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect  { .init(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        guard let cgImage = cgImage?
            .cropping(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                              y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = false
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: format.scale, orientation: imageOrientation)
                .draw(in: .init(origin: .zero, size: breadthSize))
            UIBezierPath(ovalIn: breadthRect).lineWidth = 100
            UIColor.black.setStroke()
            UIBezierPath(ovalIn: breadthRect).stroke()
        }
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let grayish = UIColor.rgb(red: 237, green: 237, blue: 237)
    
    static let lightGreen = UIColor.rgb(red: 139, green: 203, blue: 187)
    static let lessDark = UIColor.rgb(red: 73, green: 81, blue: 88)
    static let background1 = UIColor(red: 245/250, green: 245/250, blue: 245/250, alpha: 1)
//    static let lightRed = UIColor.rgb(red: 241, green: 160, blue: 159)
//    static let background1 = UIColor(red: 247, green: 249, blue: 255, alpha: 255)
    
    
    static let background = UIColor.rgb(red: 246, green: 246, blue: 246)
//    static let background = UIColor.rgb(red: 242, green: 242, blue: 246)
    static let lightRed = UIColor.rgb(red: 241, green: 160, blue: 159)
    static let darkRed = UIColor.rgb(red: 139, green: 0, blue: 0)
    static let darkGreen = UIColor.rgb(red: 40, green: 104, blue: 71)
//    static let background1 = UIColor(red: 247, green: 249, blue: 255, alpha: 255)
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 16 }
    var boldFont:UIFont { return UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

// from online source in order to make barchart view work

extension BarChartView {
    
    private class BarChartFormatter: NSObject,AxisValueFormatter {
        
        var values : [String]
        required init (values : [String]) {
            self.values = values
            super.init()
        }
        
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return values[Int(value)]
        }
    }
    
    func setChartValues (xAxisValues : [String], values : [Double], color: [NSUIColor], label : String) {
        
        var barChartDataEntries = [BarChartDataEntry]()
        
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            barChartDataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: barChartDataEntries, label: label)
        chartDataSet.colors = color
        let chartData = BarChartData(dataSet: chartDataSet)
        
        let formatter = BarChartFormatter(values: xAxisValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = formatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.labelPosition = .bottom
        
        self.data = chartData
        self.data?.notifyDataChanged()
        self.notifyDataSetChanged()
        //        self.xAxis.drawLimitLinesBehindDataEnabled = true
        
        self.pinchZoomEnabled = false
        self.drawBarShadowEnabled = false
        self.drawBordersEnabled = false
        self.doubleTapToZoomEnabled = false
        //        self.drawGridBackgroundEnabled = true
        
        
        
        self.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        
    }
    
}


extension LineChartView {
    
    private class LineChartFormatter: NSObject,AxisValueFormatter {
        
        var values : [String]
        required init (values : [String]) {
            self.values = values
            super.init()
        }
        
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return values[Int(value)]
        }
    }
    
    func setChartValues (xAxisValues : [String], values : [Double], label : String) {
        
        var lineChartDataEntries = [ChartDataEntry]()
        
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            lineChartDataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(entries: lineChartDataEntries, label: label)
        chartDataSet.mode = .cubicBezier
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 2
        chartDataSet.setColor(NSUIColor(cgColor: UIColor.lessDark.cgColor))
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fill = ColorFill(color: .lightGreen)
        
        let chartData = LineChartData(dataSet: chartDataSet)
        
        let formatter = LineChartFormatter(values: xAxisValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = formatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.labelPosition = .bottom
        
        self.data = chartData
        self.data?.notifyDataChanged()
        self.notifyDataSetChanged()
        //        self.xAxis.drawLimitLinesBehindDataEnabled = true
        
        self.pinchZoomEnabled = false
        self.drawBordersEnabled = false
        self.doubleTapToZoomEnabled = false
        self.drawGridBackgroundEnabled = false
        
        
        
        self.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        
    }
    
}

class ClosureSleeve {
    let closure: () -> ()
    
    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func setOnClickListener(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}

class ButtonWithBadge: UIButton {
    let badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .red
        return view
    }()
    var isRead: Bool = false {
        didSet {
            setBadge()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBadge()
        addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.rightAnchor.constraint(equalTo: rightAnchor, constant: 3),
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            badgeView.heightAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2),
            badgeView.widthAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2)
        ])
    }
    
    func setBadge() {
        badgeView.isHidden = isRead
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




