//
//  WaveView.swift
//  Walk2N
//
//  Learned from Murad9288/Water_wave_progress
//

import UIKit


class WaveView: UIView{
    
    
    // MARK: Properties
    // MARK: Initialize
    
    private let firstlayer = CAShapeLayer()
    private let secondLayer = CAShapeLayer()
    
    private var percentLbl = UILabel()
    
    private var firstColor: UIColor = .clear
    private var secondColor: UIColor = .clear
    
    private let twon: CGFloat = .pi*2
    private var offset: CGFloat = 0.0
    
    internal let we = 240.0
    
    var showSingleWave = false
    private var start = false
    
    var progress: CGFloat = 0.0
    var waveHeight: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


// MARK: Setup Views
extension WaveView{
    private func setupViews() {
        
        bounds = CGRect(x: 0.0, y: 0.0, width: min(we,width), height: min(we,width))
    
        clipsToBounds = true
        backgroundColor = .clear
        layer.cornerRadius = we/2
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.grayish.cgColor
        
        
        waveHeight = 8.0
        
        firstColor = .lightGreen
        secondColor = .lightGreen.withAlphaComponent(0.4)
        
        createFirstLayer()
        
        if !showSingleWave {
            createSecondLayer()
        }
        
        createPercentLbl()
        
        
    }
    
    // MARK: Create First Layer
    
    private func createFirstLayer() {
        
        firstlayer.frame = bounds
        firstlayer.anchorPoint = .zero
        firstlayer.fillColor = firstColor.cgColor
        layer.addSublayer(firstlayer)
    }
    
    private func createSecondLayer() {
        
        secondLayer.frame = bounds
        secondLayer.anchorPoint = .zero
        secondLayer.fillColor = secondColor.cgColor
        layer.addSublayer(secondLayer)
        
    }
    
    private func createPercentLbl(){
//        percentLbl.font = UIFont.boldSystemFont(ofSize: 35.0)
        percentLbl.textAlignment = .center
        percentLbl.text = ""
        percentLbl.textColor = .lessDark
        percentLbl.font = UIFont(name: "Futura", size: 40)
        addSubview(percentLbl)
        percentLbl.translatesAutoresizingMaskIntoConstraints = false
        percentLbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        percentLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func percentAnim(){
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.duration = 1.5
        anim.fromValue = 0.0
        anim.toValue = 1.5
        anim.isRemovedOnCompletion = false
        
        percentLbl.layer.add(anim, forKey: nil)

    }
    
    func setupProgress(_ pr: Double){
        progress = pr
        print("pr is", pr)
        self.percentAnim()

        if pr >= 1.0 {
            progress = 1.0
            percentLbl.text = "100%"
        } else {
            percentLbl.text = "\((pr*100.0).truncate(places: 2))%"
        }
        
        var top: CGFloat
        
        if pr * bounds.size.height <= 240.0 {
            top = pr * bounds.size.height
        } else {
            top = 240.0
        }
        
        print(top)
        firstlayer.setValue(width-top, forKeyPath: "position.y")
        secondLayer.setValue(width-top, forKeyPath: "position.y")
        
        if !start {
            DispatchQueue.main.async {
                self.startAnim()
            }
        }
    }
    
    private func startAnim() {
        start = true
        waterWaveAnim()
    }
    
    private func waterWaveAnim(){
        let w = bounds.size.width
        let h = bounds.size.height
        
        let bezier = UIBezierPath()
        let path = CGMutablePath()
        
        let startoffsetY = waveHeight * CGFloat(sinf(Float(offset*twon/w)))
        var origiOffsetY: CGFloat = 0.0
        
        path.move(to: CGPoint(x: 0.0, y: startoffsetY),transform: .identity)
        bezier.move(to: CGPoint(x: 0.0, y: startoffsetY))
        
        for i in stride(from: 0.0, to: w*100, by: 1){
            
            origiOffsetY = waveHeight * CGFloat(sinf(Float(twon / w*i + offset * twon/w)))
            bezier.addLine(to: CGPoint(x: i, y: origiOffsetY))
           
        }
        
        bezier.addLine(to: CGPoint(x: w*100, y: origiOffsetY))
        bezier.addLine(to: CGPoint(x: w*100, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: startoffsetY))
        bezier.close()
        
        let anim = CABasicAnimation(keyPath: "transform.translation.x")
        anim.duration = 2.0
        anim.fromValue = -w * 0.5
        anim.toValue = -w - w*0.5
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        
        
        firstlayer.fillColor = firstColor.cgColor
        firstlayer.path = bezier.cgPath
        firstlayer.add(anim, forKey: nil)
        
        
        if !showSingleWave{
        
            let bezier = UIBezierPath()
         
            let startoffsetY = waveHeight * CGFloat(sinf(Float(offset*twon/w)))
            var origiOffsetY: CGFloat = 0.0
            
            bezier.move(to: CGPoint(x: 0.0, y: startoffsetY))
            
            for i in stride(from: 0.0, to: w*100, by: 1){
                origiOffsetY = waveHeight*CGFloat(cosf(Float(twon/w*i + offset*twon/w)))
                bezier.addLine(to: CGPoint(x: i, y: origiOffsetY))
               
            }
            bezier.addLine(to: CGPoint(x: w*100, y: origiOffsetY))
            bezier.addLine(to: CGPoint(x: w*100, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: startoffsetY))
            bezier.close()
            
            
            secondLayer.fillColor = secondColor.cgColor
            secondLayer.path = bezier.cgPath
            secondLayer.add(anim, forKey: nil)
        }
    }

    
}
