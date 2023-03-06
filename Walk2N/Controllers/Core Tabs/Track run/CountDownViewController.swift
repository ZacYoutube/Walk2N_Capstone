//
//  CountDownViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/5/23.
//

import UIKit

class CountDownViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    
    var t: Timer = Timer()
    var countDown = 3
    var onDone : ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGreen
        
        t = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
        skipBtn.setOnClickListener {
            self.t.invalidate()
            self.dismiss(animated: true)
            self.onDone?(true)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func timerCounter() {
        countDown -= 1
        timerLabel.text = "\(countDown)"
        if countDown == 0 {
            t.invalidate()
            self.dismiss(animated: true)
            onDone?(true)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        t.invalidate()
        self.dismiss(animated: true)
        onDone?(true)
    }
}
