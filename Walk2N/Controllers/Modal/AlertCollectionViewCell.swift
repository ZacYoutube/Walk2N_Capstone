//
//  AlertCollectionViewCell.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/24/23.
//

import UIKit

class AlertCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var alertDate: UILabel!
    @IBOutlet var alertMessage: UILabel!
    
    static let identifier = "AlertCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with alert: Alert) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        alertDate.attributedText = NSMutableAttributedString().bold(String("\(dateFormatter.string(from:alert.date!))"))
        //        alertDate.text = "\(dateFormatter.string(from:alert.date!))"
        alertMessage.attributedText = NSMutableAttributedString().normal(String(alert.message!))
        alertMessage.font = UIFont.systemFont(ofSize: 14)
        //        alertMessage.text = alert.message
        
        let cell = self
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "AlertCollectionViewCell", bundle: nil)
    }
}
