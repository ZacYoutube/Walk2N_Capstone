//
//  WalkHistCollectionViewCell.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/6/23.
//

import UIKit
import MapKit
import Firebase

class WalkHistCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var bonus: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var deleteWalkHist: UIButton!
    
    static let identifier = "WalkHistCollectionViewCell"
    var routeCoordinates = [CLLocationCoordinate2D]()
    var locationArr = [CLLocation]()
    var route: MKPolyline?
    
    var walkHistObj: WalkHist?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(with walkHist: WalkHist) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        walkHistObj = walkHist
        
        routeCoordinates.removeAll()
        
        if (walkHist.longitudeArr) != nil && (walkHist.latitudeArr) != nil {
            for i in 0..<walkHist.longitudeArr!.count {
                let longitude = walkHist.longitudeArr![i]
                let latitude = walkHist.latitudeArr![i]
                
                routeCoordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                
                if i == 0 || i == walkHist.longitudeArr!.count - 1 {
                    locationArr.append(CLLocation(latitude: latitude, longitude: longitude))
                }
            }
        }
        
        title.text = (walkHist.title!).uppercased()
        steps.text = "\(String(describing: (walkHist.steps!)))"
        date.text = "\(dateFormatter.string(from: walkHist.date!))"
        distance.text = "\(String(describing: (walkHist.distance!).truncate(places: 2))) km"
        duration.text = "\(String(describing: (walkHist.duration!).truncate(places: 2))) min"
        bonus.text = "\(String(describing: (walkHist.bonus!).truncate(places: 2)))"
        descriptionText.text = walkHist.description!
        
        descriptionText.isEditable = false
//        descriptionText.layer.borderColor = UIColor.lightGray.cgColor
//        descriptionText.layer.borderWidth = 1
//        descriptionText.layer.cornerRadius = 8
        
        profileImg.clipsToBounds = true
        profileImg.translatesAutoresizingMaskIntoConstraints = false
        
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["firstName"] != nil && doc["firstName"] as? String != nil {
                    self.name.text = (doc["firstName"] as! String)
                }
                if doc["profileImgUrl"] != nil && (doc["profileImgUrl"] as? String) != nil {
                    if let url = URL(string: doc["profileImgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.profileImg.image = UIImage(data: imageData)?.circleMasked
                            }
                        }.resume()
                    }
                }
            }
        }
        
        
        let cell = self
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        
        displayRoute()
        mapView.delegate = self
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "WalkHistCollectionViewCell", bundle: nil)
    }
}

extension WalkHistCollectionViewCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Annotation {
            let id = "pin2"
            let pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            pin.canShowCallout = true
            pin.calloutOffset = CGPoint(x: -8, y: -3)
            return pin
        }
        return nil
    }
    
    func displayRoute() {
        route = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        guard let route = route else { return }
        mapView.addOverlay(route)
        mapView.setVisibleMapRect(route.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
        
        setupAnnotations()
    }
    
    func setupAnnotations() {
        guard let startLocation = locationArr.first?.coordinate, let endLocation = locationArr.last?.coordinate, locationArr.count > 1 else {
            return
        }
        let startAnnotation = Annotation(coordinateType: .start, coordinate: startLocation)
        let endAnnotation = Annotation(coordinateType: .end, coordinate: endLocation)
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
    }
}
