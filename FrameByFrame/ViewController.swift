import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    private var tempProgress: Float = 0.0
    //Music  Background
    let singletonMusicBackground = SingletonMusicOnBackground.sharedInstance
    
    //Viper
    var viperImageView = UIImageView()
    var viper = Viper(speed: 3.0, center: CGPoint(x: 200, y: 600), size: CGSize(width: 100, height: 100))
    
    //Asteroids
    let ASTEROIDS_IMAGES_NAMES = ["Asteroid_A", "Asteroid_B", "Asteroid_C"]
    var asteroids = [Asteroid]()
    var asteroidsViews = [UIImageView]()
    var asteroidsToBeRemoved = [Asteroid]()
    
    
    //Game Logic
    var gameRunning = false //to control game state
    var stepNumber = 0 //Used in asteroids generation: every 5s an asteroid will be created
    var dificulty: CGFloat = 2.0
    var speedViper: CGFloat = 3.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Music Background
        singletonMusicBackground.create()
        
        // Do any additional setup after loading the view, typically from a nib.
        viper.moveToPoint = CGPoint(x: self.view.center.x, y: self.view.center.y + (self.view.frame.height/2 - viper.size.height))
        
        //set up Viper
        viperImageView.frame.size = viper.size
        viperImageView.center = viper.center
        viperImageView.image = UIImage(named: "viper")
        self.view.addSubview(viperImageView)
        
        //allow user tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        self.view.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
        
        //set game running
        self.gameRunning = true
        
        //initialize timer
        let dislayLink = CADisplayLink(target: self, selector: #selector(self.updateScene))
        dislayLink.add(to: .current, forMode: .default)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended {
            let tapPoint = sender.location(in: self.view)
            //update the model
            self.viper.moveToPoint = tapPoint
        }
    }
    
    @objc func updateScene(){
        
        if gameRunning{
            //create an asterior every 5s
            /*INSERT CODE HERE*/
            if (stepNumber%(60*5)==0){
                createAsteroid()
            }
            
            if (stepNumber%(60*10)==0){
                checkDificulty()
            }
            
            if (asteroidsToBeRemoved.count > 0 && asteroidsToBeRemoved.count % 10 == 0){
                updateProgressBar()
            }
        
            //update location viper
            self.viper.step() //update the model
            self.viperImageView.center = self.viper.center //update the view from the model
            
            //update location asteroids
            /*INSERT CODE HERE*/
            for index in 0..<asteroids.count{
                asteroids[index].step()
                asteroidsViews[index].center = asteroids[index].center
            }
                
            //updatethemodelasteroidsViews[index].center = asteroids[index].center //updatetheviewfromthemodel}
            //check viper screen collision
            /*INSERT CODE HERE*/
            if viper.checkScreenCollision(screenViewSize: self.view.frame.size){
                self.viperImageView.removeFromSuperview()
//                self.gameRunning = false
//                self.gameOver()
                
            }
            
            //check asteroids collision between viper and screen
            /*INSERT CODE HERE*/
            
            //remove from scene asteroids
            /*INSERT CODE HERE*/
            checkAsteroidsSceneToRemove()
            
            stepNumber+=1
        }
    }
    private func createAsteroid(){
        let asteroid = Asteroid(speed: self.dificulty, center: CGPoint(x: randomPositionY(), y: 140), size: CGSize(width: 75, height: 75))
        self.asteroids.append(asteroid)
        
        let index = Int.random(in: 0 ..< ASTEROIDS_IMAGES_NAMES.count)
        let asteroidView = UIImageView(image: UIImage(named: ASTEROIDS_IMAGES_NAMES[index]))
        asteroidView.frame.size = asteroid.size
        asteroidView.center = asteroid.center
        self.view.addSubview(asteroidView)
        self.asteroidsViews.append(asteroidView)
    }

    private func randomPositionY() -> Int{
        return Int.random(in: 0 ... Int(self.view.frame.width))
    }
    
    private func checkAsteroidsSceneToRemove(){
        for index in 0..<asteroids.count{
            if asteroids[index].center.y >= self.view.frame.maxY{
                
                self.asteroidsViews[index].removeFromSuperview()
                self.asteroidsToBeRemoved.append(asteroids[index])
                self.asteroids.remove(at: index)
                self.asteroidsViews.remove(at: index)
                
                break
            }
        }
    }
    
    private func checkDificulty(){
        //Speed Asteroids
        self.dificulty *= 1.05
        
        //Speed Viper
        self.speedViper *= 1.01
        self.viper.speed = self.speedViper
    }
    
    private func updateProgressBar(){
        self.tempProgress = progressBar.progress
        print(tempProgress)
        progressBar.progress = self.tempProgress + 0.05
        
        asteroidsToBeRemoved.removeAll()
    }
}

