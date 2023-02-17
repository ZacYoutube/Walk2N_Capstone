//
//  ShoeListCollectionViewCell.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/6/23.
//

import UIKit

class ShoeListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shoeName: UILabel!
    @IBOutlet weak var shoeAction: UIButton!
    @IBOutlet weak var shoeImage: UIImageView!
    @IBOutlet weak var shoePrice: UILabel!
    @IBOutlet weak var shoeExpirationDate: UILabel!
    @IBOutlet weak var shoeDurability: UILabel!
    
    static let identifier = "ShoeListCollectionViewCell"
    
    var shoe: Shoe? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with shoe: Shoe) {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/YY"
        let expDate = df.string(from: shoe.expirationDate ?? Date())
        shoePrice.text = String(shoe.price!)
        shoeExpirationDate.text = expDate
        shoeDurability.text = String(shoe.durability!)
        shoeName.text = String(shoe.name!)
        retrieveImage(url: shoe.imgUrl!)
        shoeAction.addTarget(self, action: #selector(buyShoes), for: .touchUpInside)
        self.shoe = shoe
        showBtn()
        
        let cell = self
        
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        
        cell.layer.cornerRadius = 10
    }
    
    private func showBtn() {
        let db = DatabaseManager.shared

        db.checkUserUpdates { data, update, added, deleted in
            if added == true || deleted == true || update == true {
                
                self.shoeAction.setTitle("Buy", for: .normal)
                self.shoeAction.isEnabled = true
                
                if data["boughtShoes"] != nil {
                    let boughtShoes = data["boughtShoes"] as? [Any]
                    if boughtShoes != nil {
                        for i in 0..<boughtShoes!.count {
                            if (boughtShoes![i] as! [String:Any])["id"] as! String == self.shoe!.id! {
                                self.shoeAction.isEnabled = false
                                self.shoeAction.setTitle("Already Bought", for: .normal)
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
    
    @objc private func buyShoes() {
        let price = Double(shoePrice.text!)
        let db = DatabaseManager.shared
        let alert = UIAlertController(title: "Confirmation", message: "Buy this shoe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Buy", style: .default, handler: { action in
            db.getUserInfo { docSnapshot in
                var newBalanace: Double = 0.0
                for doc in docSnapshot {
                    if doc["balance"] as! Double >= price! {
                        newBalanace = doc["balance"] as! Double - price!
                        db.updateUserInfo(fieldToUpdate: ["balance"], fieldValues: [newBalanace]) { success in
                            if success {
                                db.updateArrayData(fieldName: "boughtShoes", fieldVal: self.shoe!.firestoreData, pop: false) { bought in
                                    if bought {
                                        print("unsuccessfully updated balance and bought shoes")
                                    } else {
                                        print("unsuccessfully updated balance but did not bought shoes")
                                    }
                                }
                            } else {
                                print("unsuccessfully updated balance")
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Not enough tokens", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { handler in
                            alert.dismiss(animated: true)
                        }))
                        self.window?.rootViewController?.present(alert, animated: true)
                    }
                }
            }
        }))
        self.window?.rootViewController?.present(alert, animated: true)
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
        return UINib(nibName: "ShoeListCollectionViewCell", bundle: nil)
    }
}
