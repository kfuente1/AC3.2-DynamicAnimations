//
//  ViewController.swift
//  DynamicAnimations
//
//  Created by Louis Tur on 1/26/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var dynamicAnimator: UIDynamicAnimator? = nil
    //^animates the object your passing it on later
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        viewHiearchy()
        configureContraints()
        //give the dynamic animator a refrence but in view did appear give it the behaviors
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let bouncyBehaivor = BouncyViewBehaivor(items: [blueView,redView,snapButton,deSnapButton])
        self.dynamicAnimator?.addBehavior(bouncyBehaivor)
        
        let barrierBehaivor = UICollisionBehavior(items: [redView])
        greenView.isHidden = true
        barrierBehaivor.addBoundary(withIdentifier: "Barrier" as NSString,
                                    from: CGPoint(x: greenView.frame.minX, y: greenView.frame.minY),
                                    to: CGPoint(x:greenView.frame.maxX, y: greenView.frame.minY))
        
        self.dynamicAnimator?.addBehavior(barrierBehaivor)
        
        /* THIS WAS MOVED TO CLASS: EXPLINATION BELOW:
         
         // here we give it the objects and behaivors
         let gravityBehaivor = UIGravityBehavior(items: [blueView])
         // magnitude
         gravityBehaivor.angle = CGFloat.pi/6.0
         gravityBehaivor.magnitude = 0.2
         //then add behaivor to dynamic behaivor
         self.dynamicAnimator?.addBehavior(gravityBehaivor)
         //blue view was going off the white view so to bound it use what UICOllisonBehaivor
         let collisionBehaivor = UICollisionBehavior(items: [blueView])
         collisionBehaivor.translatesReferenceBoundsIntoBoundary = true
         self.dynamicAnimator?.addBehavior(collisionBehaivor)
         
         let elasticBehaivor = UIDynamicItemBehavior()
         elasticBehaivor.elasticity = 0.5
         self.dynamicAnimator?.addBehavior(elasticBehaivor)
         */
        
    }
    
    //Mark View Hiearchy
    
    func viewHiearchy() {
        view.addSubview(blueView)
        view.addSubview(snapButton)
        view.addSubview(deSnapButton)
        view.addSubview(redView)
        view.addSubview(greenView)
        self.snapButton.addTarget(self, action: #selector(snaptoCenter), for: .touchUpInside)
        self.deSnapButton.addTarget(self, action: #selector(deSnapFromCenter), for: .touchUpInside)
    }
    
    //MARK: - Button Functions
    
    internal  func snaptoCenter() {
        //damping slows the snap and ranges from 0..1
        
        let snapingBehaivor = UISnapBehavior(item: blueView, snapTo: self.view.center)
        snapingBehaivor.damping = 1.0
        self.dynamicAnimator?.addBehavior(snapingBehaivor)
    }
    
    internal func deSnapFromCenter() {
        //if you were to do remove all behaviors by (self.dynamicAnimator?.removeAllBehaviors()) you would be removing snap and gravity behaviors thus having a square that doesnt move at all after unsnapping to combat that do this:
        
        let _ = dynamicAnimator?.behaviors.map{
            if $0 is UISnapBehavior {
                self.dynamicAnimator?.removeBehavior($0)
            }
        }
    }
    
    //MARK:-Configuring contraints
    
    func configureContraints() {
        self.edgesForExtendedLayout = []
        
        //views
        greenView.snp.makeConstraints { (view) in
            view.leading.trailing.centerY.equalToSuperview()
            view.height.equalTo(20.0)
        }
        blueView.snp.makeConstraints { (view) in
            view.top.centerX.equalToSuperview()
            //view.center.equalToSuperview()
            view.size.equalTo(CGSize(width: 100.0, height: 100.0))
        }
        redView.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview()
            view.size.equalTo(CGSize(width: 100.0, height: 100.0))
        }
        
        //butons
        snapButton.snp.makeConstraints { (button) in
            button.centerX.equalToSuperview()
            button.bottom.equalToSuperview().inset(50)
        }
        deSnapButton.snp.makeConstraints { (button) in
            button.centerX.equalToSuperview()
            button.top.equalTo(snapButton.snp.bottom).offset(8.0)
        }
    }
    //Mark: - View Instances
    internal lazy var greenView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .green
        return view
        
    }()
    internal lazy var blueView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .blue
        return view
        
    }()
    internal lazy var redView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .red
        return view
        
    }()
    internal lazy var snapButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("SNAP!", for: .normal)
        return button
    }()
    internal lazy var deSnapButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("(de)SNAP!", for: .normal)
        return button
    }()
    
}

//We created a sub class of UIDynamicBehavior so that any view that we want to give more than one view the same behaivors (bouncing, gravity, etc) we can call this class and we pass in item (ie views) makes it more dynamic

class BouncyViewBehaivor: UIDynamicBehavior {
    override init() {
        
    }
    convenience init (items: [UIDynamicItem]) {
        self.init()
        
        // here we give it the objects and behaivors
        // magnitude
        //then add behaivor to dynamic behaivor
        
        let gravityBehaivor = UIGravityBehavior(items: items)
        //gravityBehaivor.angle = CGFloat.pi/6.0
        gravityBehaivor.magnitude = 0.2
        self.addChildBehavior(gravityBehaivor)
        
        //blue view was going off the white view so to bound it use what UICOllisonBehaivor
        
        let collisionBehaivor = UICollisionBehavior(items: items)
        collisionBehaivor.translatesReferenceBoundsIntoBoundary = true
        self.addChildBehavior(collisionBehaivor)
        
        //alows it to rotate while it fall the angle is in radian
        
        let elasticBehaivor = UIDynamicItemBehavior()
        elasticBehaivor.elasticity = 0.5
        elasticBehaivor.addAngularVelocity(CGFloat.pi, for: items.first!)
        self.addChildBehavior(elasticBehaivor)
        
    }
}
