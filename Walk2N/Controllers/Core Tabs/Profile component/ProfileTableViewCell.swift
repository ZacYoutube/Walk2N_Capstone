//
//  ProfileTableViewCell.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/16/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"
    
    private let container: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iv: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabels: UILabel = {
        let titleLabel = UILabel()
        return titleLabel
    }()
    
    private let textLabels: UILabel = {
        let textLabel = UILabel()
        return textLabel
    }()
    
    public func configure(with setting: setting) {
        titleLabels.text = setting.title
        textLabels.text = setting.text
        titleLabels.font = UIFont.boldSystemFont(ofSize: 14.0)
        textLabels.font = UIFont.systemFont(ofSize: 14)
        titleLabels.textColor = .lessDark
        textLabels.textColor = .lessDark
        container.backgroundColor = setting.background
        
        let img = setting.image?.withRenderingMode(.alwaysTemplate)
        iv.image = img
        iv.tintColor = UIColor.white
        
        if setting.arrow == true {
            accessoryType = .disclosureIndicator
        } else {
            accessoryType = .none
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabels)
        container.addSubview(iv)
        contentView.addSubview(container)
        contentView.addSubview(textLabels)
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let s: CGFloat = contentView.frame.size.height - 15
        container.frame = CGRect(x: 15, y: 6, width: s, height: s)
        let imgSize: CGFloat = s / 2
        iv.frame = CGRect(x: (s - imgSize)/2, y: (s - imgSize)/2, width: imgSize, height: imgSize)
        titleLabels.frame = CGRect(x: 25 + container.frame.size.width,
                                   y: 0,
                                   width: contentView.frame.size.width - 100 - container.frame.size.width,
                                   height: contentView.frame.size.height)
        textLabels.frame = CGRect(x: contentView.frame.size.width - 60 - container.frame.size.width, y: 0, width: 80, height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iv.image = nil
        titleLabels.text = nil
        textLabels.text = nil
        container.backgroundColor = nil
    }
    
}
