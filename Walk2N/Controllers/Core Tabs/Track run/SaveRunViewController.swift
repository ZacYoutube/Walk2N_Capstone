//
//  SaveRunViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/5/23.
//

import UIKit
import MapKit
import Firebase

class SaveRunViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var durationText: UILabel!
    @IBOutlet weak var stepText: UILabel!
    @IBOutlet weak var bonusText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var placeholderLabel : UILabel!
    
    var activityView:UIActivityIndicatorView!
    
    var longitudeArr = [Double]()
    var latitudeArr = [Double]()
    
    var route: MKPolyline?
    
    let trackVC = TrackRunViewController.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        
        continueBtn(enabled: false)
                
        containerView.backgroundColor = .background
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = UIColor.lightGreen
        
        distanceText.text = String(format: "%.2f km", trackVC.distanceTraveled * 0.001)
        durationText.text = "\(trackVC.duration) min"
        stepText.text = "\(trackVC.numOfSteps)"
        bonusText.text = "\(trackVC.bonusAccu)"
        
        titleText.borderStyle = .none
        titleText.font = .italicSystemFont(ofSize: (titleText.font?.pointSize)!)
        
        titleText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        descriptionText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some description..."
        placeholderLabel.font = .italicSystemFont(ofSize: (descriptionText.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        descriptionText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionText.font?.pointSize)! / 2)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !descriptionText.text.isEmpty
        
        displayRoute()
        
        titleText.delegate = self
        descriptionText.delegate = self
        mapView.delegate = self

        saveBtn.setOnClickListener {
            self.saveRun()
            self.dismiss(animated: true)
        }
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        
        self.view.isUserInteractionEnabled = true

        self.view.addGestureRecognizer(rightSwipe)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func saveRun() {
        
        continueBtn(enabled: false)
        
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser?.uid
            let title = titleText.text
            let description = descriptionText.text
            let duration = trackVC.duration
            let distance = trackVC.distanceTraveled * 0.001
            let steps = trackVC.numOfSteps
            let bonus = trackVC.bonusAccu
            
            let date = Date()
            
            let walkObj = WalkHist(uid: uid, distance: distance, duration: duration, steps: steps, bonus: bonus, longitudeArr: longitudeArr, latitudeArr: latitudeArr, title: title, description: description, date: date)
            
            let db = Firestore.firestore()
            
            var ref: DocumentReference? = nil
            
            showLoading()
            
            ref = db.collection("walkHistory").addDocument(data: walkObj.firestoreData) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    self.hideLoading()
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.hideLoading()
                }
            }
        }
    }
    
    
    
    
    // show loading gif when in process
    func showLoading() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    // dismiss loading gif
    func hideLoading(){
        activityView?.stopAnimating()
    }
    
    @objc func textFieldChanged() {
        let title = titleText.text
        let description = descriptionText.text
        let formFilled = title != nil && title != "" && description != nil && description != ""
        continueBtn(enabled: formFilled)
    }
    
    func continueBtn(enabled: Bool) {
        if enabled {
            saveBtn.isEnabled = true
            saveBtn.alpha = 1
        } else {
            saveBtn.isEnabled = false
            saveBtn.alpha = 0.8
        }
    }
    
    func getAppleMapsURL() -> String? {
        guard let startLocation = trackVC.locationArr.first?.coordinate, let endLocation = trackVC.locationArr.last?.coordinate, trackVC.locationArr.count > 1 else {
            return nil
        }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: startLocation))
        source.name = "Start"
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: endLocation))
        destination.name = "End"
        
        let appleMapsURL = "http://maps.apple.com/maps?saddr=\(startLocation.latitude),\(startLocation.longitude)&daddr=\(endLocation.latitude),\(endLocation.longitude)"
        return appleMapsURL
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .right {
            self.dismiss(animated: true)
        }
    }
    
}

extension SaveRunViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Annotation {
            let id = "pin1"
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
        for location in trackVC.locationArr {
            routeCoordinates.append(location.coordinate)
            longitudeArr.append(location.coordinate.longitude)
            latitudeArr.append(location.coordinate.latitude)
        }
        
        route = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        guard let route = route else { return }
        mapView.addOverlay(route)
        mapView.setVisibleMapRect(route.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
        
        setupAnnotations()
    }
    
    func setupAnnotations() {
        guard let startLocation = trackVC.locationArr.first?.coordinate, let endLocation = trackVC.locationArr.last?.coordinate, trackVC.locationArr.count > 1 else {
            return
        }
        let startAnnotation = Annotation(coordinateType: .start, coordinate: startLocation)
        let endAnnotation = Annotation(coordinateType: .end, coordinate: endLocation)
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
    }
}

extension SaveRunViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
        let title = titleText.text
        let description = descriptionText.text
        let formFilled = title != nil && title != "" && description != nil && description != ""
        continueBtn(enabled: formFilled)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
        moveTextView(textView, moveDistance: -250, up: false)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("text view begin")
        moveTextView(textView, moveDistance: -250, up: true)
        placeholderLabel?.isHidden = true
    }
    func moveTextView(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

extension SaveRunViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("text field begin")
        moveTextField(textField, moveDistance: -100, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -100, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

extension SaveRunViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
