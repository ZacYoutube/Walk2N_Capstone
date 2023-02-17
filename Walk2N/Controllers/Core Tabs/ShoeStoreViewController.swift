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
        self.setUpNavbar()
        navigationItem.title = "Store"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 300)
        collectionView.collectionViewLayout = layout
        collectionView.register(ShoeListCollectionViewCell.nib(), forCellWithReuseIdentifier: ShoeListCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        getShoes()
        
    }
    
    private func getShoes() -> Void {
        DatabaseManager().getShoes { docSnapshot in
            for doc in docSnapshot {
                let shoe = Shoe(id: doc.documentID, name: doc["name"] as? String, durability: doc["durability"] as? Float, imgUrl: doc["imgUrl"] as? String, price: doc["price"] as? Float, expirationDate: (doc["expirationDate"] as! Timestamp).dateValue())
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 300)
    }
}




