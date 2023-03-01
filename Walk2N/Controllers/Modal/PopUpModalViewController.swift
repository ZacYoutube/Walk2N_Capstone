//
//  PopUpModalViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/9/23.
//

import UIKit
import Firebase

class PopUpModalViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource : [Shoe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 180, height: 300)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PopUpModalCollectionViewCell.nib(),forCellWithReuseIdentifier: PopUpModalCollectionViewCell.identifier)
        collectionView.backgroundColor = .background
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        getBoughtShoes()
    }
    
    private func getBoughtShoes() -> Void {
        let db = DatabaseManager.shared
        
        db.checkUserUpdates { data, update, added, deleted in
            if update == true || added == true || deleted == true {
                if data["boughtShoes"] != nil {
                    self.dataSource = []
                    let boughtShoes = data["boughtShoes"] as? [Any]
                    if boughtShoes != nil {
                        for i in 0..<boughtShoes!.count {
                            let bs = boughtShoes![i] as! [String: Any]
                            let expiredDate = (bs["expirationDate"] as! Timestamp).dateValue()
                            let now = Date()
                            if expiredDate < now {
                                db.updateArrayData(fieldName: "boughtShoes", fieldVal: bs, pop: true) { bool in }
                            } else {
                                let shoe = Shoe(id: bs["id"] as! String, name: bs["name"] as! String, awardPerStep: bs["awardPerStep"] as! Double, imgUrl: bs["imgUrl"] as! String, price: bs["price"] as! Double, expirationDate: (bs["expirationDate"] as! Timestamp).dateValue() as Date?)
                                self.dataSource.append(shoe)
                            }
                        }
                        self.collectionView.reloadData()
                    }
                    
                }
            }
        }
    }
    
}

extension PopUpModalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension PopUpModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopUpModalCollectionViewCell.identifier, for: indexPath) as! PopUpModalCollectionViewCell
        
        cell.configure(with: self.dataSource[indexPath.row])
        return cell
    }
}

extension PopUpModalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ PopCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 300)
    }
}
