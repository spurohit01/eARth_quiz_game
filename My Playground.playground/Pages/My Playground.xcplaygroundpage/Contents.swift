import UIKit
import SceneKit
import AudioToolbox
import ARKit
import PlaygroundSupport

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, AVAudioPlayerDelegate {
    var audioPlayer : AVAudioPlayer?
    var earthSize: CGFloat = 0.15
    let questions = ["Which continent number represents South America?", "Which continent has the largest population?", "Which continent houses the smallest country?", "What is the 2nd largest continent?", "Which continent's name is also a country?"]
    let answers = [["2", "6", "1", "5", "3"], ["5", "3", "2", "1", "4"], ["4", "6", "1", "3", "6"], ["3", "1", "4", "6", "5"], ["6", "2", "1", "4", "3"]]
    var currentQuestion = 0
    var correctAnswerPlacement:UInt32 = 0
    var startPressed = false
    var points = 0
    let session = ARSession()
    var sceneView: ARSCNView!
    var quizView: UIView!
    var resultsView: UIView!
    var welcomeView: UIView!
    var earthNode: SCNNode?
    //var label: UILabel!
    var buttonNum = 1
    let startQuizButton = UIButton(type: .system)
    let viewInstructions = UIButton(type: .system)
    var questionLabel = UILabel(frame: CGRect(x: 0, y: 510, width: 440, height: 35))
    func createQuestion(){
        questionLabel.textAlignment = .center
        //questionLabel.text = "Question"
        self.sceneView.addSubview(questionLabel)
    }
    func newQuestion(){
        questionLabel.text = questions[currentQuestion]
        correctAnswerPlacement = arc4random_uniform(5)+1
        var button: UIButton = UIButton()
        var x = 1
        for i in 1...5{
            button = sceneView.viewWithTag(i) as! UIButton
            if(i == Int(correctAnswerPlacement)){
                button.setTitle(answers[currentQuestion][0], for: .normal)
            }
            else{
                button.setTitle(answers[currentQuestion][x], for: .normal)
                x = x+1
            }
        }
        currentQuestion = currentQuestion + 1
    }
    func createButton(x: Int, y: Int, width: Int, height: Int){
        let answerChoiceButton = UIButton(type: .system)
        answerChoiceButton.tag = buttonNum
        answerChoiceButton .tintColor = UIColor.blue
        answerChoiceButton.backgroundColor = UIColor.white
        answerChoiceButton.layer.cornerRadius = 5
        answerChoiceButton.frame=CGRect(x: x, y: y, width: width, height: height)
        answerChoiceButton.addTarget(self, action: #selector(answerChosen), for: .touchUpInside)
        self.sceneView?.addSubview(answerChoiceButton)
        buttonNum = buttonNum + 1
    }
    @objc func answerChosen(sender: UIButton){
        if(sender.tag == Int(correctAnswerPlacement)){
            points+=1
        }
        if(currentQuestion != questions.count){
            newQuestion()
        }
        else{
            resultsView = UIView(frame: CGRect(x: 0.0, y: 0, width: 440, height: 650))
            resultsView.backgroundColor = UIColor(red: 153.0/255, green: 192.0/255, blue: 255.0/255, alpha: 1.0)
            self.view.addSubview(resultsView)
            
            let quizCompleteLabel = UILabel(frame: CGRect(x: 0, y: 60, width: 450, height: 40))
            quizCompleteLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            quizCompleteLabel.textAlignment = .center
            quizCompleteLabel.text = "Quiz Complete!"
            self.resultsView.addSubview(quizCompleteLabel)
            
            let scoreLabel = UILabel(frame: CGRect(x: 0, y: 110, width: 450, height: 40))
            scoreLabel.font = UIFont.preferredFont(forTextStyle: .title1)
            scoreLabel.textAlignment = .center
            scoreLabel.text = "You scored " + String(points) + " out of 5 points!"
            scoreLabel.textColor = UIColor.red
            self.resultsView.addSubview(scoreLabel)
            
            var imageView = UIImageView()
            imageView = UIImageView(frame: CGRect(x: 30, y: 170, width: 375, height: 295))
            imageView.image = UIImage(named: "eARth fun facts")
            
            imageView.alpha = 0.0
            self.resultsView.addSubview(imageView)
            
            UIImageView.animate(withDuration: 1.3, animations: {imageView.alpha = 1.0})
        }
    }
    func createQuizLayout(){
        createButton(x: 50, y: 560, width: 50, height: 50)
        createButton(x: 120, y: 560, width: 50, height: 50)
        createButton(x: 190, y: 560, width: 50, height: 50)
        createButton(x: 260, y: 560, width: 50, height: 50)
        createButton(x: 330, y: 560, width: 50, height: 50)
        createQuestion()
    }
    override func loadView() {
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 500.0, height: 300.0))
        quizView = UIView(frame: CGRect(x: 0.0, y: 500, width: 500.0, height: 150.0))
        //welcomeView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 500.0, height: 500.0))
        var label = UILabel(frame: CGRect(x: 67, y: 100, width: 300, height: 100))
        label.text = "Welcome to eARth!"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.backgroundColor = UIColor.cyan
        sceneView.addSubview(label)
        var label2 = UILabel(frame: CGRect(x: 42, y: 250, width: 350, height: 80))
        label2.text = "An Augmented Reality Geography Quiz"
        label2.textAlignment = .center
        label2.font = UIFont.preferredFont(forTextStyle: .headline)
        label2.backgroundColor = UIColor.green
        sceneView.addSubview(label2)
        quizView.backgroundColor = UIColor.darkGray
        //welcomeView.backgroundColor = UIColor.lightGray
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, -0.3)
        scene.rootNode.addChildNode(cameraNode)
        self.view = sceneView
        //let configuration = ARWorldTrackingConfiguration()
        //sceneView.session.run(configuration)
        self.view.addSubview(quizView)
        //self.view.addSubview(welcomeView)
        startQuizButton.tintColor = UIColor.blue
        startQuizButton.backgroundColor = UIColor.white
        startQuizButton.layer.cornerRadius = 5
        startQuizButton.setTitle("Start Quiz!", for: .normal)
        startQuizButton.frame=CGRect(x: 165, y: 560, width: 100, height: 50)
        startQuizButton.addTarget(self, action: #selector(startQuizPressed), for: .touchUpInside)
        self.sceneView?.addSubview(startQuizButton)
        
        viewInstructions.tintColor = UIColor.red
        viewInstructions.backgroundColor = UIColor.lightGray
        viewInstructions.layer.cornerRadius = 5
        viewInstructions.setTitle("Instructions and App Info", for: .normal)
        viewInstructions.frame=CGRect(x: 92, y: 510, width: 250, height: 40)
        viewInstructions.addTarget(self, action: #selector(instructionsPressed), for: .touchUpInside)
        self.sceneView?.addSubview(viewInstructions)
    }
    @objc func instructionsPressed(sender: UIButton){
        let ac = UIViewController() as UIViewController
        ac.modalPresentationStyle = .popover
        ac.preferredContentSize = CGSize(width: 300, height: 400)
        let popover = ac.popoverPresentationController
        popover?.delegate = self
        popover?.permittedArrowDirections = .down
        popover?.sourceView = self.view
        popover?.sourceRect = CGRect(x: 90, y: 510, width: 250, height: 40)
        var imageView: UIImageView
        imageView = UIImageView(frame: CGRect(x: 20, y: 35, width: 260, height: 330))
        imageView.image = UIImage(named: "gameInstructions")
        ac.view.addSubview(imageView)
        
        present(ac, animated: true, completion: nil)
    }
    @objc func startQuizPressed(sender: UIButton){
        for view in self.sceneView.subviews{
            if view is UILabel{
                view.removeFromSuperview()
            }
        }
        startQuizButton.isHidden = true
        startQuizButton.isEnabled = false
        viewInstructions.isHidden = true
        viewInstructions.isEnabled = false
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressRecognizer.minimumPressDuration = 0.03
        longPressRecognizer.delegate = self
        sceneView.addGestureRecognizer(longPressRecognizer)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        startPressed = true
        createQuizLayout()
        newQuestion()
    }
    override func viewDidLoad() {
        audioPlayer = AVAudioPlayer()
        if let pathResource = Bundle.main.path(forResource: "bensound-littleidea", ofType: "mp3"){
            let backgroundMusic = NSURL(fileURLWithPath: pathResource)
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
                audioPlayer!.prepareToPlay()
                audioPlayer!.delegate = self
                audioPlayer!.play()
            }
            catch{
                
            }
        }
    }
    @objc func addAnnotation(press:UILongPressGestureRecognizer){
        let location = press.location(in:sceneView)
        if location.y > 500{
            return
        }
        else{
            let hitResults = sceneView.hitTest(location, types: .featurePoint)
            if let hitTestResult = hitResults.first {
                let transform = hitTestResult.worldTransform
                let position = SCNVector3(x: transform.columns.3.x, y: transform.columns.3.y, z: transform.columns.3.z)
                earthNode = SCNNode()
                earthNode?.position = position
                earthNode?.geometry = SCNSphere(radius: earthSize)
                earthNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "DiffuseNumbered")
                earthNode?.geometry?.firstMaterial?.specular.contents = UIImage(named: "Specular")
                earthNode?.geometry?.firstMaterial?.emission.contents = UIImage(named: "Emission")
                earthNode?.geometry?.firstMaterial?.normal.contents = UIImage(named: "Normal")
                earthNode?.geometry?.firstMaterial?.isDoubleSided = true
                
                earthNode?.geometry?.firstMaterial?.transparency = 1
                earthNode?.geometry?.firstMaterial?.shininess = 50
                sceneView.scene.rootNode.addChildNode(earthNode!)
                let action = SCNAction.rotate(by: 360*CGFloat((Double.pi)/180), around: SCNVector3(x:0,y:1,z:0), duration: 15)
                let repeatAction = SCNAction.repeatForever(action)
                earthNode?.runAction(repeatAction)
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}

let controller = ViewController()
//controller.preferredContentSize = CGSize(width: 500, height: 600)
controller.preferredContentSize = CGSize(width: 432, height: 620)
PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true
