//
//  WalkHistViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/6/23.
//

import UIKit
import Firebase

class WalkHistViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource : [WalkHist] = []
    
    var activityView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.backgroundColor = .white
        collectionView.backgroundColor = .background
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 360, height: 490)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(WalkHistCollectionViewCell.nib(),forCellWithReuseIdentifier: WalkHistCollectionViewCell.identifier)
        collectionView.backgroundColor = .background
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        collectionView.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: view.frame.height - 150)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        
        self.view.isUserInteractionEnabled = true
        
        self.view.addGestureRecognizer(rightSwipe)
        
        getWalkDist()
    }
    
    func getWalkDist() {
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser?.uid
            let db = Firestore.firestore()
            let ref = db.collection("walkHistory")
            
            let query = ref.whereField("uid", isEqualTo: uid! as String)
            
            query.getDocuments { querySnapshot, error in
                for document in querySnapshot!.documents {
                    let elem = document.data() as [String: Any]
                    let walkHist = WalkHist(id: document.documentID, uid: uid, distance: (elem["distance"] as! Double), duration: (elem["duration"] as! Double), steps: (elem["steps"] as! Double), bonus: (elem["bonus"] as! Double), longitudeArr: (elem["longitudeArr"] as! [Double]), latitudeArr: (elem["latitudeArr"] as! [Double]), title: (elem["title"] as! String), description: (elem["description"] as! String), date: (elem["date"] as! Timestamp).dateValue())
                    self.dataSource.append(walkHist)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .right {
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromLeft
            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: false, completion: nil)
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
    
}

extension WalkHistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension WalkHistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalkHistCollectionViewCell.identifier, for: indexPath) as! WalkHistCollectionViewCell
        
        cell.configure(with: self.dataSource[indexPath.row])
        cell.deleteWalkHist.setOnClickListener {
            self.showLoading()
            let alert = UIAlertController(title: "Delete this record?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                let docId = self.dataSource[indexPath.row].id!
                let docRef = Firestore.firestore().collection("walkHistory").document(docId)
                
                docRef.delete() { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                        self.hideLoading()
                    } else {
                        print("Document successfully deleted")
                        self.hideLoading()
                    }
                    self.dataSource.remove(at: indexPath.row)
                    print(indexPath.row)
                    for i in 0..<self.dataSource.count {
                        print(self.dataSource[i].firestoreData)
                    }
                    self.collectionView.reloadData()
                }
            }))
            self.getTopMostViewController()?.present(alert, animated: true, completion: nil)
            
        }
        return cell
    }
}

extension WalkHistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ PopCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: 490)
    }
}

