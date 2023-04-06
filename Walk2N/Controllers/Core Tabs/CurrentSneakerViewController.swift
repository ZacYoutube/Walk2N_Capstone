//
//  CurrentSneakerViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/28/23.
//

import UIKit
import Firebase

class CurrentSneakerViewController: UIViewController {

    @IBOutlet weak var currentShoeContainerView: UIView!
    @IBOutlet weak var currentShoeImg: UIImageView!
    @IBOutlet weak var currentShoeName: UILabel!
    @IBOutlet weak var currentShoeAwardPerStep: UILabel!
    @IBOutlet weak var currentShoeExpdate: UILabel!
    @IBOutlet weak var chooseChoe: UIButton!
    @IBOutlet weak var shoeNameContainer: UIView!
    @IBOutlet weak var shoeAwardContainer: UIView!
    @IBOutlet weak var shoeExpContainer: UIView!
    @IBOutlet weak var toStore: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    let curShoeTitle = UILabel()
    let addShoe = UIButton()
    
    let db = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseChoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        chooseChoe.titleLabel?.font = .systemFont(ofSize: 15)
        toStore.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let shoeStoreViewController = storyboard.instantiateViewController(identifier: "ShoeStoreViewController")
            shoeStoreViewController.title = "Sneaker Store"
            let nav = UINavigationController(rootViewController: shoeStoreViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        contentView.backgroundColor = .background1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpNavbar(text: "Sneakers")
        addShoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        loadCurrentShoe()
    }
    
    
    private func loadCurrentShoe() {
        
        currentShoeContainerView.backgroundColor = UIColor.background1
        
        shoeNameContainer.backgroundColor = UIColor.background1
        shoeAwardContainer.backgroundColor = UIColor.background1
        shoeExpContainer.backgroundColor = UIColor.background1
        
        shoeNameContainer.layer.cornerRadius = 8
        shoeAwardContainer.layer.cornerRadius = 8
        shoeExpContainer.layer.cornerRadius = 8
        
        currentShoeImg.layer.cornerRadius = 8
        currentShoeImg.layer.shadowColor = UIColor.black.cgColor
        currentShoeImg.layer.shadowOpacity = 0.5
        currentShoeImg.layer.shadowOffset = CGSize(width: 0, height: 2)
        currentShoeImg.layer.shadowRadius = 4
        
        currentShoeName.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        currentShoeAwardPerStep.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        currentShoeExpdate.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        
        currentShoeName.font = UIFont.boldSystemFont(ofSize: 13.0)
        currentShoeAwardPerStep.font = UIFont.boldSystemFont(ofSize: 13.0)
        currentShoeExpdate.font = UIFont.boldSystemFont(ofSize: 13.0)
        
        db.checkUserUpdates { data, update, added, deleted in
            if added == true || deleted == true || update == true {
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as? [String: Any]
                    self.curShoeTitle.attributedText = NSMutableAttributedString().normal("Current Shoe: ").bold("\(currentShoe!["name"] as! String)")
                    if let url = URL(string: currentShoe!["imgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.currentShoeImg.image = UIImage(data: imageData)
                                self.currentShoeImg.layer.borderColor = nil
                                self.currentShoeImg.layer.borderWidth = 0
                                self.currentShoeImg.heightAnchor.constraint(equalToConstant: 150).isActive = true
                                self.currentShoeImg.widthAnchor.constraint(equalToConstant: 250).isActive = true
                                
                                let df = DateFormatter()
                                df.dateFormat = "MM/dd/YYYY"
                                let expDate = df.string(from: (currentShoe!["expirationDate"] as! Timestamp).dateValue())
                                
                                self.currentShoeName.text = "\(currentShoe!["name"] as! String)"
                                
                                self.currentShoeAwardPerStep.text = "\(currentShoe!["awardPerStep"] as! Double)"
                                self.currentShoeExpdate.text = "\(expDate)"
                                self.chooseChoe.setTitle("Change Sneaker", for: .normal)
                                
                            }
                        }.resume()
                    }
                } else {
                    self.currentShoeImg.image = nil
                    
                    self.currentShoeName.text = "NA"
                    self.currentShoeAwardPerStep.text = "NA"
                    self.currentShoeExpdate.text = "NA"
                    self.chooseChoe.setTitle("Choose Sneaker", for: .normal)
                    
                }
            }
        }
    }
    
    @objc private func openModal() {
        let popup = PopUpModalViewController()
        popup.title = "Choose a sneaker to earn!"
        present(UINavigationController(rootViewController: popup), animated: true)
    }

}
