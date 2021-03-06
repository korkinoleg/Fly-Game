//
//  GameViewController.swift
//  Fly Game
//
//  Created by Oleg on 11.03.2021.
//

//import UIKit
//import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    //MARK: - Outlets
    let buttun = UIButton()
    
    ///MARK: Properties
    var duration:TimeInterval = 5
    var ship = SCNNode()
    
    //MARK: - Methods
    
    func addShip(to scene:SCNScene )  {
        // retrieve the ship node
        ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        //Correct ship rotatoin
        ship.rotation = SCNVector4(0, 0, 0, 1)
        
        //Unhide the ship
        ship.isHidden = false
        
        // position the ship
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -100
        ship.position = SCNVector3(x, y, z)
        
        //set ship orientation
        ship.look(at: SCNVector3(2 * x,2 * x,2 * z))
        
        // animate the 3d object
        
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            self.ship.isHidden = true
            DispatchQueue.main.async {
                self.buttun.isHidden = false
            }
            print(#line, #function, "GAME OVER")
        }
    }
    
    /// Configure user interface
    func configureUI() {
        //Configure buttin position
        let height = CGFloat(100)
        let width = CGFloat(200)
        let x = view.frame.midX - width / 2
        let y = view.frame.midY - height / 2
        buttun.frame = CGRect(x: x, y: y, width: width, height: height)
        
        //Configure button properties
        buttun.backgroundColor = .red
        buttun.layer.cornerRadius = 15
        buttun.setTitle("New Game", for: .normal)
        buttun.setTitleColor(.yellow, for: .normal)
        buttun.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        
        //Hide button
        buttun.isHidden = true
        
        buttun.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        //Add button to the view
        view.addSubview(buttun)
    }

    @objc func buttonTapped() {
        print(#line, #function)
        buttun.isHidden = true
        
        //Restore duration
        duration = 5
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        //Add ship to the scene view
        addShip(to: scnView.scene!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        //Add ship to the scene
        addShip(to: scene)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // Configure user interface
        configureUI()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        
        print(#line, #function, p)
        
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            //Remove animation from the ship
            ship.removeAllActions()
            
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                material.emission.contents = UIColor.black
                self.addShip(to: scnView.scene!)
                self.duration *= 0.9
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    //MARK: - Computed Properties
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
