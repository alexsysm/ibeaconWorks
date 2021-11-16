//
//  NotificationHandler.swift
//  CentralManager
//
//  Created by Nguyen Uy on 1/7/19.
//  Copyright © 2019 Uy Nguyen Long. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import AVKit

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    var player : AVAudioPlayer?
    
    private override init() {
        super.init()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in
                guard error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            })
        } else {
            self.registerForLocalNotification(on: UIApplication.shared)
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func showNotification(title: String, body: String, timeInterval: TimeInterval = 1.0) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
//            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "FindPhoneSound.mp3"))
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "TAG_FIND_PHONE_ALARM"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if let error = error {
                    // Something went wrong
                    print("Error \(error.localizedDescription)")
                }
            })
        } else {
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = body
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }
    
    /*
     For iOS < 10
     */
    func registerForLocalNotification(on application:UIApplication) {
        if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            let notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            notificationCategory.identifier = "NOTIFICATION_CATEGORY"
            application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
        }
    }

    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        if response.notification.request.content.categoryIdentifier == "TAG_FIND_PHONE_ALARM" {
            playSound()
//        }

        completionHandler()
    }
    
    func playSound() {
        guard let soundFileURL = Bundle.main.url(forResource: "FindPhoneSound", withExtension: "mp3") else {
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: soundFileURL)
//            player?.numberOfLoops = 1
            player?.prepareToPlay()
            
            // Configure and activate the AVAudioSession
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()

            let timeInterval = 1.0
            let timeOffset = player!.deviceCurrentTime + timeInterval
            player!.play(atTime: timeOffset)
        }
        catch {
            // Handle error
        }
    }
    
    func stopSound() {
        if let player = self.player {
            player.stop()
        }
    }
}
