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
        iv.image = setting.image
        if setting.arrow == true {
            accessoryType = .disclosureIndicator
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
        let s: CGFloat = contentView.frame.size.height - 12
        container.frame = CGRect(x: 15, y: 6, width: s, height: s)
        let imgSize: CGFloat = s / 1.5
        iv.frame = CGRect(x: (s - imgSize)/2, y: (s - imgSize)/2, width: imgSize, height: imgSize)
        titleLabels.frame = CGRect(x: 25 + container.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width - 20 - container.frame.size.width,
                             height: contentView.frame.size.height)
        textLabels.frame = CGRect(x: titleLabels.frame.size.width, y: 0, width: 100, height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iv.image = nil
        titleLabels.text = nil
        textLabels.text = nil
        container.backgroundColor = nil
    }

}
