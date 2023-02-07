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
