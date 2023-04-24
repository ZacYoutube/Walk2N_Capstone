//
//  AlertViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/24/23.
//

import UIKit
import Firebase

class AlertViewController: UIViewController {
    
    var dataSource : [Alert] = []
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAlerts()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.width - 20, height: 80)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AlertCollectionViewCell.nib(),forCellWithReuseIdentifier: AlertCollectionViewCell.identifier)
        collectionView.backgroundColor = UIColor(red: 245/250, green: 245/250, blue: 245/250, alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        collectionView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 245/250, green: 245/250, blue: 245/250, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        view.addSubview(collectionView)
    }
    
    private func getAlerts() -> Void {
        let db = DatabaseManager.shared
        db.checkUserUpdates { data, update, added, deleted in
            if update == true || added == true || deleted == true {
                if data["alertHist"] != nil {
                    let alertHist = data["alertHist"] as? [Any]
                    if alertHist != nil {
                        for i in 0..<alertHist!.count {
                            let alert = alertHist![i] as! [String: Any]
                            let alertObj = Alert(message: alert["message"] as! String, date: (alert["date"] as! Timestamp).dateValue() as? Date)
                            self.dataSource.append(alertObj)
                        }
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
    }
}

extension AlertViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension AlertViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlertCollectionViewCell.identifier, for: indexPath) as! AlertCollectionViewCell
        
        cell.configure(with: self.dataSource[indexPath.row])
        return cell
    }
}

extension AlertViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ PopCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width - 20, height: 80)
    }
}

