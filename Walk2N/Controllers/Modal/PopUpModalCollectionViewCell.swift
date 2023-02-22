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
        shoeDurability.text = String(shoe.awardPerStep!)
        shoeName.text = String(shoe.name!)
        
        shoeExpirationDate.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        shoeDurability.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        shoeName.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        retrieveImage(url: shoe.imgUrl!)
        
        wearBtn.addTarget(self, action: #selector(wear), for: .touchUpInside)
        removeBtn.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        wearBtn.backgroundColor = UIColor.lightGreen
        wearBtn.setTitleColor(UIColor.lessDark, for: .normal)
        removeBtn.backgroundColor = UIColor.lightGreen
        removeBtn.tintColor = .lessDark
        
        wearBtn.layer.cornerRadius = 8
        removeBtn.layer.cornerRadius = 8
        
        checkWear()
        self.shoe = shoe
        
        let cell = self
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
    }
    
    @objc private func remove() {
        let alert = UIAlertController(title: "Confirmation", message: "Remove this shoe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { action in
        let db = DatabaseManager.shared
            db.getUserInfo { docSnapshot in
                for doc in docSnapshot {
                    if (doc["boughtShoes"] as? [Any]) != nil {
                        let boughtShoes = doc["boughtShoes"] as! [Any]
                        for i in 0..<boughtShoes.count {
                            let elem = (boughtShoes[i] as! [String: Any])
                            if elem["id"] as! String == self.shoe!.id! {
                                db.updateArrayData(fieldName: "boughtShoes", fieldVal: elem, pop: true) { bool in }
                                if (doc["currentShoe"] as? [String: Any]) != nil {
                                    let currentShoe = doc["currentShoe"] as! [String: Any]
                                    if currentShoe["id"] as! String == self.shoe!.id!{
                                        db.updateUserInfo(fieldToUpdate: ["currentShoe"], fieldValues: [nil]) { bool in }}
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
                self.wearBtn.removeTarget(self, action: #selector(self.unwear), for: .allEvents)
                self.wearBtn.addTarget(self, action: #selector(self.wear), for: .touchUpInside)
                
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as! [String: Any]
                    if self.shoe?.id! == (currentShoe["id"] as! String) {
                        self.wearBtn.setTitle("Unwore", for: .normal)
                        self.wearBtn.removeTarget(self, action: #selector(self.wear), for: .allEvents)
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
