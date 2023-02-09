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
        df.dateFormat = "MM/dd/YYYY"
        let expDate = df.string(from: shoe.expirationDate ?? Date())
        shoePrice.text = String(shoe.price!)
        shoeExpirationDate.text = expDate
        shoeDurability.text = String(shoe.durability!)
        shoeName.text = String(shoe.name!)
        retrieveImage(url: shoe.imgUrl!)
        shoeAction.addTarget(self, action: #selector(buyShoes), for: .touchUpInside)
        self.shoe = shoe
        
        print(shoe)
    }
    
    @objc private func buyShoes() {
        let price = Double(shoePrice.text!)
        let db = DatabaseManager.shared
        db.getUserInfo { docSnapshot in
            var newBalanace: Double = 0.0
            for doc in docSnapshot {
                if doc["balance"] as! Double >= price! {
                    newBalanace = doc["balance"] as! Double - price!
                    db.updateUserInfo(fieldToUpdate: ["balance"], fieldValues: [newBalanace]) { success in
                        if success {
                            db.updateStepsData(fieldName: "boughtShoes", fieldVal: self.shoe!.firestoreData, pop: false) { bought in
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
                }
            }
        }
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
