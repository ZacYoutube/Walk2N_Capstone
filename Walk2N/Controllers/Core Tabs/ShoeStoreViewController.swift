//
//  ShoeStoreViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/6/23.
//

import UIKit
import Firebase

class ShoeStoreViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource : [Shoe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Store"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 320)
        collectionView.backgroundColor = UIColor(red: 245/250, green: 245/250, blue: 245/250, alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        collectionView.collectionViewLayout = layout
        collectionView.register(ShoeListCollectionViewCell.nib(), forCellWithReuseIdentifier: ShoeListCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        getShoes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpNavbar()
    }
    
    private func getShoes() -> Void {
        DatabaseManager().getShoes { docSnapshot in
            for doc in docSnapshot {
                let shoe = Shoe(id: doc.documentID, name: doc["name"] as? String, awardPerStep: (doc["awardPerStep"] as! Double), imgUrl: doc["imgUrl"] as? String, price: doc["price"] as? Double, expirationDate: (doc["expirationDate"] as! Timestamp).dateValue())
                self.dataSource.append(shoe)
            }
            self.collectionView.reloadData()
        }
    }

}

extension ShoeStoreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
extension ShoeStoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.dataSource)
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoeListCollectionViewCell.identifier, for: indexPath) as! ShoeListCollectionViewCell
        
        cell.configure(with: self.dataSource[indexPath.row])
        return cell
    }
}

extension ShoeStoreViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 180, height: 300)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}




