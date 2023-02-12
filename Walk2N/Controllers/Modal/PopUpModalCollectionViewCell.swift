//
//  PopUpModalCollectionViewCell.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/9/23.
//

import UIKit

class PopUpModalCollectionViewCell: UICollectionViewCell {

    @IBOutlet var shoeImage: UIImageView!
    @IBOutlet var shoeName: UILabel!
    @IBOutlet var shoeDurability: UILabel!
    @IBOutlet var shoeExpirationDate: UILabel!
    @IBOutlet var wearBtn: UIButton!
    @IBOutlet var removeBtn: UIButton!
    
    static let identifier = "PopUpModalCollectionViewCell"
    
    var shoe: Shoe? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with shoe: Shoe) {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/YYYY"
        let expDate = df.string(from: shoe.expirationDate ?? Date())
        shoeExpirationDate.text = expDate
        shoeDurability.text = String(shoe.durability!)
        shoeName.text = String(shoe.name!)
        retrieveImage(url: shoe.imgUrl!)
        wearBtn.addTarget(self, action: #selector(wear), for: .touchUpInside)
        removeBtn.addTarget(self, action: #selector(remove), for: .touchUpInside)
        checkWear()
        self.shoe = shoe
    }
    
    @objc private func remove() {
        let alert = UIAlertController(title: "Confirmation", message: "Remove this shoe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { action in
        let db = DatabaseManager.shared
            db.getUserInfo { docSnapshot in
                for doc in docSnapshot {
                    if (doc["boughtShoes"] as? [Any]) != nil && (doc["currentShoe"] as? [String: Any]) != nil {
                        let boughtShoes = doc["boughtShoes"] as! [Any]
                        let currentShoe = doc["currentShoe"] as! [String: Any]
                        for i in 0..<boughtShoes.count {
                            let elem = (boughtShoes[i] as! [String: Any])
                            if elem["id"] as! String == self.shoe!.id! {
                                db.updateArrayData(fieldName: "boughtShoes", fieldVal: elem, pop: true) { bool in }
                                if currentShoe["id"] as! String == self.shoe!.id! {
                                    db.updateUserInfo(fieldToUpdate: ["currentShoe"], fieldValues: [nil]) { bool in }
                                }
                            }
                        }
                    }
                    
                }
            }
        }))
        getTopMostViewController()?.present(alert, animated: true, completion: nil)
        
    }
    
    // stupid way of handling, maybe improve in the future :((
    @objc private func checkWear() {
        let db = DatabaseManager.shared
        db.checkUserUpdates { data, update, added, deleted in
            if update == true || added == true || deleted == true {
                
                self.wearBtn.setTitle("Wear", for: .normal)
                self.wearBtn.removeTarget(self, action: #selector(self.unwear), for: .touchUpInside)
                self.wearBtn.addTarget(self, action: #selector(self.wear), for: .touchUpInside)
                
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as! [String: Any]
                    if self.shoe?.id! == (currentShoe["id"] as! String) {
                        self.wearBtn.setTitle("Unwore", for: .normal)
                        self.wearBtn.removeTarget(self, action: #selector(self.wear), for: .touchUpInside)
                        self.wearBtn.addTarget(self, action: #selector(self.unwear), for: .touchUpInside)
                    } 
                }
            }
        }
    }
    
    @objc private func wear() {
        let db = DatabaseManager.shared
        let alert = UIAlertController(title: "Confirmation", message: "Wear this shoe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Wear", style: .default, handler: { action in
            db.updateUserInfo(fieldToUpdate: ["currentShoe"], fieldValues: [self.shoe?.firestoreData as Any]) { success in
                if success {
                    print("successfully worn the shoe")
                } else {
                    print("unsuccessful wear")
                }
            }
        }))
        
        
        getTopMostViewController()?.present(alert, animated: true, completion: nil)

    }
    
    @objc private func unwear() {
        let db = DatabaseManager.shared
        let alert = UIAlertController(title: "Confirmation", message: "Unwore this shoe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Unwore", style: .default, handler: { action in
            db.updateUserInfo(fieldToUpdate: ["currentShoe"], fieldValues: [nil]) { success in
                if success {
                    print("successfully Unworn the shoe")
                } else {
                    print("unsuccessful unworn")
                }
            }
        }))
        
        
        getTopMostViewController()?.present(alert, animated: true, completion: nil)

    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }

    private func retrieveImage(url: String){
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              guard let imageData = data else { return }
                DispatchQueue.main.async { [self] in
                shoeImage.image = UIImage(data: imageData)
              }
            }.resume()
          }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "PopUpModalCollectionViewCell", bundle: nil)
    }

}
