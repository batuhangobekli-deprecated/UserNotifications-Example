//
//  ViewController.swift
//  TreasureHunt
//
//  Created by Batuhan Göbekli on 14.11.2020.
//

import UIKit

struct Player{
    let userName:String //Unique username to identify player
    var userHasAuthorizedNotification:Bool //User granted notification permission
    var availableTreasures:[TreasureBox] //Returns available treasures
}

struct TreasureBox{
    let id:String //Unique identifier
    let name:String //Name of the treasure box
    let duration:Int //Total seconds before box opens (10 seconds)
    let reward:String //Reward of treasure box (200 Gold)
    
    ///Schedules UserNotification for treasure.
    func scheduleTreasureLocalNotification(){
        //First create notification content
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = self.name + " is opened"
        notificationContent.subtitle = "Launch app to collect \(self.reward)"
        notificationContent.sound = UNNotificationSound.default
        
        // show this notification treasurebox duration from now (in seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.duration), repeats: false)
        
        // Use treasurebox identifier as identifier
        let request = UNNotificationRequest(identifier: self.id, content: notificationContent, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}

class ViewController: UIViewController {
    var player:Player!{
        didSet{
            //Control if player is Authorized
            if player.userHasAuthorizedNotification == true{
                //Schedule players treasures notifications available
                for treasure in player.availableTreasures{
                    //Trigger
                    treasure.scheduleTreasureLocalNotification()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Lets create our player (Pre defined fields entered static)
        //Initially user has no available treasure
        self.player = Player(userName: "TreasureHunter", userHasAuthorizedNotification: false, availableTreasures: [])
        
        //Lets ask for notification permission
        registerForRemoteNotification(completion: { (permissionGranted) in
            //Manipulate our player "userHasAuthorizedNotification variable with using @escaping result
            self.player.userHasAuthorizedNotification = permissionGranted
        })
        
        //Then create our Treasures
        let goldTreasureBox = createDummyTreasureBox(name: "Gold Treasure Box", duration: 10, reward: "20 Gold")
        let expTreasureBox = createDummyTreasureBox(name: "Exp Treasure Box",duration: 20, reward:"100 Exp")
        
        //User gathers treasures
        player.availableTreasures.append(goldTreasureBox)
        player.availableTreasures.append(expTreasureBox)
    }
    
    
    ///Creates TreasureBox by given values and returns
    func createDummyTreasureBox(name:String,duration:Int,reward:String) -> TreasureBox{
        let uuid = UUID().uuidString // Create unique UUID for id
        return TreasureBox(id: uuid, name: name, duration: duration, reward: reward)
    }
    
    ///Request notification permission & register for notification
    func registerForRemoteNotification(completion: @escaping (Bool) -> Void){
        if #available(iOS 10.0, *) { //Control for ios 10+ for requesting permission
            let center  = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    completion(true) //User granted notification permission
                }else{
                    completion(false) //User denied giving notification permission
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            completion(true) //Notification granted permission
        }
    }
}

