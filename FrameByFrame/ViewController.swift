import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    private let counter = Counter()
    
    @IBOutlet weak var progressBar: UIProgressView!
    private var tempProgress: Float = 0.0
    
    //Music  Background
    let singletonMusicBackground = SingletonMusicOnBackground.sharedInstance
    
    //Sounds
    private var soundColisionBetweenAsteroidAndViper :SystemSoundID = 0
    private var soundColisionBetweenWallAndViper :SystemSoundID = 0
    
    //Viper
    private let VIPERS_IMAGES_NAMES = ["viper", "viper2", "viper3"]
    private let LEVELS_VIPER: [Float] = [0.25, 0.50, 0.75]
    private var viperImageView = UIImageView()
    private let viper = Viper(speed: 3.0, center: CGPoint(x: 200, y: 600), size: CGSize(width: 100, height: 100))
    private let INCREMENTSPEEDVIPER: CGFloat = 1.01
    private var viperInitialPosition: CGPoint?
    
    //Asteroids
    private let ASTEROIDS_IMAGES_NAMES = ["Asteroid_A", "Asteroid_B", "Asteroid_C"]
    private var asteroids = [Asteroid]()
    private var asteroidsViews = [UIImageView]()
    private var asteroidsToBeRemoved = [Asteroid]()
    private let INCREMENTSPEEDASTEROID: CGFloat = 1.05
    
    
    //Game Logic
    private var gameRunning = false //to control game state
    private var stepNumber = 0 //Used in asteroids generation: every 5s an asteroid will be created
    private var speedAsteroid: CGFloat = 2.0
    private var speedViper: CGFloat = 3.0
    private let INCREMENTPROGRESSBAR: Float = 0.05
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Music Background
        singletonMusicBackground.create()
        
        //Set Sounds
        loadSounds()
        
        // Do any additional setup after loading the view, typically from a nib.
        viper.speed = speedViper
        viperInitialPosition = CGPoint(x: self.view.center.x, y: self.view.center.y + (self.view.frame.height/2 - viper.size.height))
        viper.moveToPoint = viperInitialPosition
        
        //set up Viper
        viperImageView.frame.size = viper.size
        viperImageView.center = viper.center
        viperImageView.image = UIImage(named: VIPERS_IMAGES_NAMES[0])
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
            //create an asterior every 5s and Dificulty
            /*INSERT CODE HERE*/
            if (stepNumber%(60*5)==0){
                createAsteroid()
                checkDificulty()
            }
            
            //Increase progress bar every time asteroids hit the floor
            if (asteroidsToBeRemoved.count > 0 && asteroidsToBeRemoved.count % 2 == 0){
                increaseProgressBar()
            }
        
            //update location viper
            self.viper.step() //update the model
            self.viperImageView.center = self.viper.center //update the view from the model
            
            //Update img viper
            evolveViper()
            
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
                AudioServicesPlaySystemSound(soundColisionBetweenWallAndViper)
                self.decreaseProgressBar(dmg: Damage.Wall.rawValue)
            }
            
            //check asteroids collision between viper and screen
            /*INSERT CODE HERE*/
            checkCollitionBetweenViperAndAsteroid()
            
            //remove from scene asteroids
            /*INSERT CODE HERE*/
            checkAsteroidsSceneToRemove()
            
            stepNumber+=1
        }
    }
    
    private func loadSounds() {
        if let soundColisionURL = Bundle.main.url(forResource: "asteroidExplosion", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundColisionURL as CFURL, &soundColisionBetweenAsteroidAndViper)
        }
        
        if let soundColisionWallURL = Bundle.main.url(forResource: "asteroidExplosion", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundColisionWallURL as CFURL, &soundColisionBetweenWallAndViper)
        }
    }
    
    private func createAsteroid(){
        //Generate random size
        let size = randomWidth(minRange: 20, maxRange: 120)
        //Create asteroid
        let asteroid = Asteroid(speed: self.speedAsteroid, center: CGPoint(x: randomPositionX(minRange: Int(0 + size.width / 2), range: Int(self.view.frame.width - (size.width / 2))), y: 140), size: size)
        self.asteroids.append(asteroid)
        
        //Load random UIImage
        let index = randomNumber(minRange: 0, maxRange: ASTEROIDS_IMAGES_NAMES.count - 1)
        let asteroidView = UIImageView(image: UIImage(named: ASTEROIDS_IMAGES_NAMES[index]))
        
        //Set size and center asteroid view
        asteroidView.frame.size = asteroid.size
        asteroidView.center = asteroid.center
        
        //Add asteroidView
        self.view.addSubview(asteroidView)
        self.asteroidsViews.append(asteroidView)
    }

    private func randomPositionX(minRange: Int, range: Int) -> Int{
        return randomNumber(minRange: minRange, maxRange: range)
    }
    
    private func randomWidth(minRange: Int, maxRange: Int) -> CGSize {
        let size = randomNumber(minRange: minRange, maxRange: maxRange)
        return CGSize(width: size, height: size)
    }
    
    private func randomNumber(minRange: Int, maxRange: Int) -> Int{
        return Int.random(in: minRange ... maxRange)
    }
    
    //Check if asteroid has to be removed if it hits the floor
    private func checkAsteroidsSceneToRemove(){
        for index in 0..<asteroids.count{
            if asteroids[index].center.y >= self.view.frame.maxY{
                self.asteroidsToBeRemoved.append(asteroids[index])
                eraseAsteroids(index: index)
                
                //Increment label Score
                counter.increment()
                scoreLabel.text = "\(counter.value)"
                break
            }
        }
    }
    
    private func checkCollitionBetweenViperAndAsteroid() {
        for index in 0..<asteroids.count{
            if self.viper.overlapsWith(actor: asteroids[index]) {
                eraseAsteroids(index: index)
                
                AudioServicesPlaySystemSound(soundColisionBetweenAsteroidAndViper)
                
                decreaseProgressBar(dmg: Damage.Asteroid.rawValue)
                break
            }
        }
    }
    
    //Remove asteroid
    private func eraseAsteroids(index:Int) {
        self.asteroidsViews[index].removeFromSuperview()
        self.asteroids.remove(at: index)
        self.asteroidsViews.remove(at: index)
    }
    
    private func checkDificulty(){
        //Speed Asteroids increment
        self.speedAsteroid *= INCREMENTSPEEDASTEROID
        
        //Speed Viper INCREMENT
        self.speedViper *= INCREMENTSPEEDVIPER
        self.viper.speed = self.speedViper
    }
    
    private func increaseProgressBar(){
        self.tempProgress = progressBar.progress
        
        progressBar.progress = self.tempProgress + INCREMENTPROGRESSBAR
        
        asteroidsToBeRemoved.removeAll()
    }
    
    private func evolveViper(){
        if progressBar.progress <= LEVELS_VIPER[0] {
            viperImageView.image = UIImage(named: VIPERS_IMAGES_NAMES[0])
            progressBar.tintColor = UIColor.blue
        } else if progressBar.progress >= LEVELS_VIPER[0] && progressBar.progress <= LEVELS_VIPER[1]{
            viperImageView.image = UIImage(named: VIPERS_IMAGES_NAMES[1])
            progressBar.tintColor = UIColor.orange
        } else if (progressBar.progress >= LEVELS_VIPER[2]){
            viperImageView.image = UIImage(named: VIPERS_IMAGES_NAMES[2])
            progressBar.tintColor = UIColor.purple
        }
    }
    
    private func decreaseProgressBar(dmg:Float){
        self.tempProgress = progressBar.progress
        if tempProgress >= 0.05 {
            decreasProgressBarAnimation()
            progressBar.progress = self.tempProgress - dmg
        } else {
            gameOver()
        }
    
    }
    
    private func decreasProgressBarAnimation(){
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.07
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.progressBar.center.x - 10, y: self.progressBar.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.progressBar.center.x + 10, y: self.progressBar.center.y))
        progressBar.layer.add(shakeAnimation, forKey: "position")
    }
    
    private func resetValues() {
        progressBar.progress = 0.10
        asteroids.removeAll()
        asteroidsViews.removeAll()
        asteroidsToBeRemoved.removeAll()
        speedViper = 3.0
        speedAsteroid = 2.0
        viper.moveToPoint = viperInitialPosition
        viperImageView.image = UIImage(named: VIPERS_IMAGES_NAMES[0])
        progressBar.tintColor = UIColor.blue
        counter.reset()
        scoreLabel.text = "\(counter.value)"
        self.gameRunning = true
    }
    
    private func gameOver() {
        //Game over setea la progress bar a 0 y cambia el estado del juego a false
        progressBar.progress = 0
        for index in 0..<asteroids.count {
            eraseAsteroids(index: index)
        }
        //comprobamos si hemos de guardar la puntuación.
        checkIfScoreHasToBeSaved()
        self.gameRunning = false
        //se crea el alert dialog del game over
        let alert = UIAlertController(title: "Game Over", message: "Do you want to quit the game?.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"Try Again\" alert occured.")
            //se resetean los valores si el usuario clica en try again
            self.resetValues()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"Cancel\" alert occured.")
            //exit nos envía a otro controller
            self.performSegue (withIdentifier: "goToScoreView", sender: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func checkIfScoreHasToBeSaved() {
        //si hay datos guardados en userdefaults comprobamos que el score sea mayor que el highscore, sino guardamos por primera vez.
        let defaults = UserDefaults.standard
        if let scoreToSave = defaults.value(forKey: "highscore") as? Int {
            if (scoreToSave < counter.value) {
                defaults.setValue(counter.value, forKeyPath: "highscore")
            }
        }
        else {
            defaults.setValue(counter.value, forKeyPath: "highscore")
        }
        
    }
    
    @IBAction func goBack(segue : UIStoryboardSegue) {
        resetValues()
    }
}



