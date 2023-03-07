//
//  TrackRunViewController.swift
//  Walk2N
//
//  Learned and borrowed from https://medium.com/macoclock/logic-for-building-a-simple-jogging-and-running-app-in-ios-13-swift-5-116a49af226
//

import UIKit
import MapKit
import CoreLocation
import MessageUI
import Firebase
import CoreMotion

class TrackRunViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var errorView: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var sv: UIStackView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var stopRunButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var viewWalkHist: UIButton!
        
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var locationAccess = false
        
    var locationsPassed = [CLLocation]()
    var isRunning = false
    var route: MKPolyline?
    
    static var distanceTraveled: Double = 0.0
    static var numOfSteps: Double = 0.0
    static var bonusAccu: Double = 0.0
    static var locationArr = [CLLocation]()
    
    var startRunTime: Date?
    var endRunTime: Date?
    
    let stepCounter = StepCounter()
    var currentShoe: Shoe? = nil
    
    var currency: Double? = 0.0
    var timer: Timer = Timer()
    var count: Int = 0
    var counting: Bool = false
    
    static var duration: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavbar(text: "Map")
        mapView.delegate = self
        viewWalkHist.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let walkHistViewController = storyboard.instantiateViewController(identifier: "WalkHistViewController")
            walkHistViewController.modalPresentationStyle = .fullScreen
            self.present(walkHistViewController, animated: true)
        }
        reset()
        setup()
    }
    
    func setup() {
        runButton.setTitleColor(.white, for: .normal)
        runButton.setTitle("START MOVE", for: .normal)
        runButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        distanceLabel.isHidden = true
        stepsLabel.isHidden = true
        statusView.isHidden = true
        
        statusView.backgroundColor = UIColor.background
        timeLabel.textColor = UIColor.lessDark
        timeLabel.text = formatTimerStr(hour: 0, min: 0, sec: 0)
        stepLabel.text = "Steps: 0"
        stepLabel.textColor = UIColor.lessDark
        
        stopRunButton.setTitleColor(.white, for: .normal)
        stopRunButton.tintColor = .white
        distanceLabel.textColor = .systemRed
        stepsLabel.textColor = .systemRed
        
        stopRunButton.setTitle("End", for: .normal)
        stopRunButton.backgroundColor = .lightGreen
        stopRunButton.layer.cornerRadius = 8
        
        stopRunButton.setOnClickListener {
            self.stopRun()
        }
        
        checkLocationServices()
    }
    
    func addLocationsToArray(_ locations: [CLLocation]) {
        for location in locations {
            if !locationsPassed.contains(location) {
                locationsPassed.append(location)
            }
        }
    }
    
    func calculateAndDisplayDistance() {
        var totalDistance = 0.0
        if locationsPassed.count > 0 {
            for i in 1..<locationsPassed.count {
                let previousLocation = locationsPassed[i-1]
                let currentLocation = locationsPassed[i]
                totalDistance += currentLocation.distance(from: previousLocation)
            }
        }
        
        TrackRunViewController.distanceTraveled = totalDistance
        let displayDistance: String
        displayDistance = String(format: "Distance Travelled: %.2f kilometers", TrackRunViewController.distanceTraveled * 0.001)
        distanceLabel.text = displayDistance
    }
    
    func getAppleMapsURL() -> String? {
        guard let startLocation = locationsPassed.first?.coordinate, let endLocation = locationsPassed.last?.coordinate, locationsPassed.count > 1 else {
            return nil
        }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: startLocation))
        source.name = "Start"
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: endLocation))
        destination.name = "End"
        
        let appleMapsURL = "http://maps.apple.com/maps?saddr=\(startLocation.latitude),\(startLocation.longitude)&daddr=\(endLocation.latitude),\(endLocation.longitude)"
        return appleMapsURL
    }
    
    func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> Double {
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

        return Double(newDateMinutes - oldDateMinutes).truncate(places: 1)
    }
    
    func startRun() {
        reset()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let countDownVC = storyboard!.instantiateViewController(withIdentifier: "countdown") as! CountDownViewController
        countDownVC.modalPresentationStyle = .fullScreen
        countDownVC.modalTransitionStyle = .coverVertical
        present(countDownVC, animated: true)
        
        countDownVC.onDone = {
            result in
            
            if result == true {
                self.isRunning = true
                self.distanceLabel.isHidden = true
                self.stepsLabel.isHidden = true
                self.sv.isHidden = true
                self.runButton.isHidden = true
                self.statusView.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCounter), userInfo: nil, repeats: true)
                
                self.distanceLabel.text = ""
                self.stepsLabel.text = ""
                
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.startUpdatingLocation()
                
                self.startRunTime = Date()
                
                if CMPedometer.isStepCountingAvailable() {
                    self.stepCounter.pedometer.startUpdates(from: self.startRunTime!) { data, err in
                        if err == nil {
                            if let res = data {
                                DispatchQueue.main.sync {
                                    self.stepLabel.text = "Steps: \(res.numberOfSteps)"
                                    TrackRunViewController.numOfSteps = Double(truncating: res.numberOfSteps)
                                }
                            }
                        }
                    }
                }
                
                if  let arrayOfTabBarItems = self.tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[0] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
                if  let arrayOfTabBarItems = self.tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[1] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
                if  let arrayOfTabBarItems = self.tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[3] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
                if  let arrayOfTabBarItems = self.tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[4] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
    }
    
    
    func stopRun() {
        isRunning = false
        
        count = 0
        timeLabel.text = formatTimerStr(hour: 0, min: 0, sec: 0)
        timer.invalidate()

        stepCounter.endTracking()
        
        statusView.isHidden = true
        runButton.isHidden = false
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        displayRoute()
        
        endRunTime = Date()
        
        calculateBonus { bonus in
            
            TrackRunViewController.bonusAccu = bonus
            TrackRunViewController.duration = self.minutesBetweenDates(self.startRunTime!, self.endRunTime!)
            TrackRunViewController.locationArr = self.locationsPassed
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let saveWalkVC = storyboard.instantiateViewController(identifier: "SaveWalkVC")
                saveWalkVC.modalPresentationStyle = .fullScreen
                self.present(saveWalkVC, animated: true)
            }
        }
       
        
        if  let arrayOfTabBarItems = tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[0] as? UITabBarItem {
            tabBarItem.isEnabled = true
        }
        if  let arrayOfTabBarItems = tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[1] as? UITabBarItem {
            tabBarItem.isEnabled = true
        }
        if  let arrayOfTabBarItems = tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[3] as? UITabBarItem {
            tabBarItem.isEnabled = true
        }
        if  let arrayOfTabBarItems = tabBarController!.tabBar.items! as AnyObject as? NSArray,let tabBarItem = arrayOfTabBarItems[4] as? UITabBarItem {
            tabBarItem.isEnabled = true
        }
    }
    
    @objc func timerCounter() -> Void {
        count += 1
        let time = secondsToHoursAndMinutes(seconds: count)
        let timeStr = formatTimerStr(hour: time.0, min: time.1, sec: time.2)
        timeLabel.text = timeStr
    }
    
    func secondsToHoursAndMinutes(seconds: Int) -> (Int, Int, Int) {
        return ((seconds/3600), ((seconds%3600)/60), ((seconds%3600)%60))
    }
    
    func formatTimerStr(hour: Int, min: Int, sec: Int) -> String {
        var timeStr = "Time: "
        timeStr += String(format: "%02d", hour)
        timeStr += " : "
        timeStr += String(format: "%02d", min)
        timeStr += " : "
        timeStr += String(format: "%02d", sec)
        return timeStr
    }
    
    func calculateBonus(completion:@escaping ((Double) -> Void)) {
        self.stepCounter.getSteps(from: self.startRunTime!) { stepsTaken in
            DispatchQueue.main.async {
                if self.currentShoe != nil {
                    let steps = Double(stepsTaken!)
                    let currentShoe = self.currentShoe!
                    let balance = self.currency
                    let stepGoalToday = 1000.0
                    var stepsString: String = ""
                    var bonus: Double = 0.0
                    
                    let db = DatabaseManager.shared
                    
                    self.stepsLabel.text = "Steps Taken: \(steps), bonus earned: 0"
                    
                    completion(Double(steps * currentShoe.awardPerStep!).truncate(places: 2))
                    
                    // here we can calculate the bonus - formula for now
                    db.getUserInfo { docSnapshot in
                        for doc in docSnapshot {
                            if (doc["currentShoe"] as? [String: Any]) != nil {
                                if TrackRunViewController.distanceTraveled * 0.001 > 0.0 {
                                    let bonusSoFar = doc["bonusEarnedToday"] as! Double
                                    bonus = bonusSoFar + steps * currentShoe.awardPerStep!
                                    db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday", "balance", "bonusEarnedDuringRealTimeRun"], fieldValues: [bonus, balance! + bonus - bonusSoFar, bonus - bonusSoFar]) { bool in }
                                    stepsString = "Steps Taken: \(Int(steps)), bonus earned: \(Double(bonus - bonusSoFar).truncate(places: 2))"
                                    self.stepsLabel.text = stepsString
                                }
                            }
                        }
                    }
                } else {
                    completion(0)
                }
            }
        }
    }
    
    func enableButtons() {
        runButton.isEnabled = true
        runButton.isHidden = false
        runButton.layer.backgroundColor = UIColor.lightGreen.cgColor
        runButton.layer.cornerRadius = 16
    }
    
    func disableAllButtons() {
        runButton.isEnabled = false
        runButton.isHidden = true
    }
}

extension TrackRunViewController{
    //    @IBAction func locationButtonTapped(_ sender: Any) {
    //        centerViewOnUserLocation()
    //    }
    
    @IBAction func runButtonTapped(_ sender: Any) {
        DatabaseManager.shared.checkUserUpdates { data, update, added, deleted in
            if let user = data as? [String: Any] {
                if added == true || deleted == true {
                    if user["currentShoe"] != nil &&  (user["currentShoe"] as? [String: Any]) != nil {
                        let user = user["currentShoe"] as! [String: Any]
                        self.currentShoe = Shoe(id: user["id"] as? String, name: user["name"] as? String, awardPerStep: user["awardPerStep"] as? Double, imgUrl: user["imgUrl"] as? String, price: user["price"] as? Double, expirationDate: (user["expirationDate"] as! Timestamp).dateValue())
                        self.toggleRun()
                    } else {
                        if self.runButton.title(for: .normal) == "START MOVE" {
                            let alert = UIAlertController(title: "Confirmation", message: "You will not receive any bonus if you don't wear a shoe. Are you sure?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                self.startRun()
                            }))
                            self.present(alert, animated: true)
                        } else {
                            self.toggleRun()
                        }
                    }
                    if (user["balance"] != nil) {
                        self.currency = (user["balance"] as! Double)
                    }
                }
            }
            
        }
    }
    
    private func toggleRun() {
        if self.runButton.isHidden == true {
            self.runButton.isHidden = false
            self.stopRun()
            self.statusView.isHidden = true
        } else {
            self.runButton.isHidden = true
            self.startRun()
            self.statusView.isHidden = false
        }
    }
}

extension TrackRunViewController: MFMessageComposeViewControllerDelegate {
    
    func getComposeMessageViewController(message: String) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = message
        controller.messageComposeDelegate = self
        return controller
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TrackRunViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Annotation {
            let id = "pin"
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            pin.canShowCallout = true
            pin.animatesDrop = true
            pin.pinTintColor = annotation.coordinateType == .start ? .lightGreen : .lightRed
            pin.calloutOffset = CGPoint(x: -8, y: -3)
            return pin
        }
        return nil
    }
    
    func displayRoute() {
        var routeCoordinates = [CLLocationCoordinate2D]()
        for location in locationsPassed {
            routeCoordinates.append(location.coordinate)
        }
        route = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        guard let route = route else { return }
        mapView.addOverlay(route)
        mapView.setVisibleMapRect(route.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
        
        calculateAndDisplayDistance()
        setupAnnotations()
    }
    
    func setupAnnotations() {
        guard let startLocation = locationsPassed.first?.coordinate, let endLocation = locationsPassed.last?.coordinate, locationsPassed.count > 1 else {
            return
        }
        let startAnnotation = Annotation(coordinateType: .start, coordinate: startLocation)
        let endAnnotation = Annotation(coordinateType: .end, coordinate: endLocation)
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
    }
    
    func removeOverlays() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    func reset() {
        removeOverlays()
        TrackRunViewController.distanceTraveled = 0
        locationsPassed.removeAll()
        route = nil
    }
}

extension TrackRunViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        if isRunning {
            addLocationsToArray(locations)
        }
        
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("MSH: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization(manager)
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            enableButtons()
            errorView.isHidden = true
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        } else {
            disableAllButtons()
            
            locationManager.stopUpdatingLocation()
            errorView.isHidden = false
            errorView.text = "Location not found"
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            self.errorView.isHidden = true
            self.setupLocationManager()
            self.locationManagerDidChangeAuthorization(self.locationManager)
        } else {
            self.disableAllButtons()
            
            self.errorView.isHidden = false
            self.errorView.text = "Please enable Location Services"
        }
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            errorView.isHidden = true
            locationManager.requestLocation()
            centerViewOnUserLocation()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            disableAllButtons()
            
            //Alert error
            locationManager.stopUpdatingLocation()
            errorView.isHidden = false
            errorView.text = "For this app to work\n" +
            "Please go to Setttings\n" +
            "Then Privacy\n" +
            "Then Location Services\n" +
            "Then Running App\n" +
            "Then Select Always"
            break
        }
    }
}
