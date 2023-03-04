//
//  ProfileViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

struct section {
    let title: String?
    var setting: [setting]?
}

struct setting {
    let title: String?
    let image: UIImage?
    let text: String?
    let arrow: Bool?
    let background: UIColor?
    let handler: (() -> Void)
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = DatabaseManager.shared
    
    var userInfoHeader: ProfileUserInfo!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var settingModels = [section](repeating: section(title: "", setting: nil), count: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        containerView.backgroundColor = .background
                    
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        settingModels[0] = section(title: "Personal Information", setting: [setting](repeating: setting(title: nil, image: nil, text: nil, arrow: nil, background: nil, handler: {}), count: 3))
        settingModels[1] = section(title: "Activity level", setting: [setting](repeating: setting(title: nil, image: nil, text: nil, arrow: nil, background: nil, handler: {}), count: 2))
        settingModels[2] = section(title: "Others", setting: [setting](repeating: setting(title: nil, image: nil, text: nil, arrow: nil, background: nil, handler: {}), count: 3))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpNavbar(text: "Profile")

        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 90)
        userInfoHeader = ProfileUserInfo(frame: frame)
        
        tableView.tableHeaderView = userInfoHeader
        tableView.tableHeaderView?.backgroundColor = UIColor.white
        tableView.tableHeaderView?.layer.cornerRadius = 8
        
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["firstName"] != nil && doc["lastName"] != nil {
                    self.userInfoHeader.nameLabel.text = "\(doc["firstName"] as? String ?? "") \(doc["lastName"] as? String ?? "")"
                }
                if doc["email"] != nil {
                    self.userInfoHeader.emailLabel.text = doc["email"] as? String
                }
                if doc["profileImgUrl"] != nil && (doc["profileImgUrl"] as? String) != nil {
                    if let url = URL(string: doc["profileImgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.userInfoHeader.profileImageView.image = UIImage(data: imageData)
                            }
                        }.resume()
                    }
                }
            }
        }
        
        containerView.center = view.center
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor = UIColor.background
        containerView.addSubview(tableView)
        
        view.addSubview(containerView)
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func configure() {
        
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["balance"] != nil && (doc["balance"] as? Double) != nil {
                    let balance = String(describing: (doc["balance"] as! Double).truncate(places: 2))
                    self.settingModels[2].setting![0] = (setting(title: "Balance", image: UIImage(named: "balance.png")!, text: balance, arrow: false, background: UIColor.rgb(red: 146, green: 139, blue: 203), handler: {}))
                }
                if doc["age"] != nil && (doc["age"] as? Double) != nil {
                    let age = String(describing: Int(doc["age"] as! Double))
                    self.settingModels[0].setting![0] = (setting(title: "Age", image: UIImage(named: "age.png")!, text: "\(age)", arrow: false, background: .lessDark, handler: {}))
                }
                if doc["height"] != nil && (doc["height"] as? Double) != nil{
                    let height = String(describing: (doc["height"] as! Double))
                    self.settingModels[0].setting![1] = (setting(title: "Height", image: UIImage(named: "height.png")!, text: "\(height) cm", arrow: false, background: .lessDark, handler: {}))
                }
                if doc["weight"] != nil && (doc["weight"] as? Double) != nil{
                    let weight = String(describing: (doc["weight"] as! Double))
                    self.settingModels[0].setting![2] = (setting(title: "Weight", image: UIImage(named: "weight.png")!, text: "\(weight) kg", arrow: false, background: .lessDark, handler: {}))
                }
                if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil{
                    let historicalSteps = doc["historicalSteps"] as! [Any]
                    var count = 0
                    if historicalSteps.count > 7 {
                        for i in historicalSteps.count - 8...historicalSteps.count - 1 {
                            let stepData = historicalSteps[i] as! [String: Any]
                            count += stepData["stepCount"] as! Int
                        }
                    } else {
                        for i in 0..<historicalSteps.count {
                            let stepData = historicalSteps[i] as! [String: Any]
                            count += stepData["stepCount"] as! Int
                        }
                    }
                    
                    self.settingModels[1].setting![0] = (setting(title: "Steps (past week)", image: UIImage(named: "steps.png")!, text: "\(count)", arrow: false, background: .lightGreen, handler: {}))
                }
                self.tableView.reloadData()
            }
        }
        
        
        let hk = HealthKitManager()
        
        hk.gettingDistance(7) { dist in
            DispatchQueue.main.async {
                let distance = String(describing: (dist).truncate(places: 2))
                self.settingModels[1].setting![1] = (setting(title: "Distance (past week)", image: UIImage(named: "dist.png")!, text: "\(distance) km", arrow: false, background: .lightGreen, handler: {}))
                self.settingModels[2].setting![1] = (setting(title: "Privacy", image: UIImage(named: "privacy.png")!, text: "", arrow: true, background:  UIColor.rgb(red: 146, green: 139, blue: 203), handler: {}))
                self.settingModels[2].setting![2] = (setting(title: "Log out", image: UIImage(named: "logout.png")!, text: "", arrow: false, background:  UIColor.rgb(red: 146, green: 139, blue: 203)) {
                    self.logout()
                })
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    private func logout() {
        let alert = UIAlertController(title: "Confirmation", message: "Log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            AuthManager().logout()
            
            // after logout, redirect to login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainMenuViewController = storyboard.instantiateViewController(identifier: "MainMenuViewController")
            self.changeRootViewController(mainMenuViewController)
        }))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingModels[section].setting!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingModels[indexPath.section].setting![indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath
        ) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: setting)
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = settingModels[indexPath.section].setting![indexPath.row]
        setting.handler()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius : CGFloat = 10.0
        cell.backgroundColor = UIColor.clear
        let layer: CAShapeLayer = CAShapeLayer()
        let pathRef:CGMutablePath = CGMutablePath()
        let bounds: CGRect = cell.bounds.insetBy(dx:0,dy:0)
        var addLine: Bool = false
        
        if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            pathRef.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
            // CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius)
        } else if (indexPath.row == 0) {
            
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.midY), radius: cornerRadius)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
            pathRef.addLine(to:CGPoint(x: bounds.maxX, y: bounds.maxY) )
            
            addLine = true
        } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            
            
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY), transform: CGAffineTransform())
            //                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
            pathRef.addLine(to:CGPoint(x: bounds.maxX, y: bounds.minY) )
            
            
        } else {
            pathRef.addRect(bounds)
            
            addLine = true
        }
        
        layer.path = pathRef
        layer.fillColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8).cgColor
        
        if (addLine == true) {
            let lineLayer: CALayer = CALayer()
            let lineHeight: CGFloat = (1.0 / UIScreen.main.scale)
            lineLayer.frame = CGRect(x:bounds.minX + 10 , y:bounds.size.height-lineHeight, width:bounds.size.width-10, height:lineHeight)
            lineLayer.backgroundColor = tableView.separatorColor?.cgColor
            layer.addSublayer(lineLayer)
        }
        let testView: UIView = UIView(frame: bounds)
        testView.layer.insertSublayer(layer, at: 0)
        testView.backgroundColor = UIColor.clear
        cell.backgroundView = testView
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .lightGray
            headerView.textLabel?.text = headerView.textLabel?.text?.uppercased()
            headerView.textLabel?.font = .systemFont(ofSize: 12)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingModels.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = settingModels[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    
}
