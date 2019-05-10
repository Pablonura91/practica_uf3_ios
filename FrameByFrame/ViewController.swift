import UIKit

class ViewController: UIViewController {
    //Music  Background
    let singletonMusicBackground = SingletonMusicOnBackground.sharedInstance
    
    //Viper
    var viperImageView = UIImageView()
    var viper = Viper(speed: 3.5, center: CGPoint(x: 200, y: 600), size: CGSize(width: 100, height: 100))
    
    //Asteroids
    let ASTEROIDS_IMAGES_NAMES = ["Asteroid_A", "Asteroid_B", "Asteroid_C"]
    var asteroids = [Asteroid]()
    var asteroidsViews = [UIImageView]()
    var asteroidsToBeRemoved = [Asteroid]()
    
    
    //Game Logic
    var gameRunning = false //to control game state
    var stepNumber = 0 //Used in asteroids generation: every 5s an asteroid will be created
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Music Background
        singletonMusicBackground.create()
        
        // Do any additional setup after loading the view, typically from a nib.
        
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
                self.gameRunning = false
//                self.gameOver()
                
            }
            
            //check asteroids collision between viper and screen
            /*INSERT CODE HERE*/
            checkColisionBetweenviperAndScreen()
            
            //remove from scene asteroids
            /*INSERT CODE HERE*/
            checkAsteroidsSceneToRemove()
            
            stepNumber+=1
        }
    }
    private func createAsteroid(){
        let asteroid = Asteroid(speed: 3, center: CGPoint(x: randomPositionY(), y: 140), size: CGSize(width: 75, height: 75))
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
            }
        }
    }
    
    private func checkColisionBetweenviperAndScreen(){
        let withViper = self.viper.size.width
        let heightViper = self.viper.size.height
        var isDestroy = false
        
        if viper.center.x >= self.view.frame.maxX - withViper || viper.center.x <= self.view.frame.minX + withViper{
            isDestroy = true
        } else if viper.center.y >= self.view.frame.maxY - heightViper || viper.center.y <= self.view.frame.minY + heightViper {
            isDestroy = true
        }
        
        if isDestroy { self.viperImageView.removeFromSuperview() }
    }
}

