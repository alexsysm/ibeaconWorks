//
//  ViewController.swift
//  CentralBeaconApp
//
//  Created by 심윤수 on 2021/11/11.
//

import UIKit
import CoreLocation
import AVKit


class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
//    var player : AVAudioPlayer?

    @IBOutlet weak var logger: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeLocationManager()
        
        let scene = UIApplication.shared.connectedScenes.first
        // grab the scene delegate and give it a reference to this ViewController
        if let sceneDelegate : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sceneDelegate.audioViewController = self;
        }

//        playSound()
    }
    
    @IBAction func onClick(_ sender: Any) {
        self.logger.text = ""
    }
    
    func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager.requestAlwaysAuthorization()
//        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerNeededState() {
        log("Access to location service is needed.")
    }
    
    func locationManagerRestrictedState() {
        log("This app is restricted from using the location service.")
    }
    
    func log(_ log: String) {
        print(log)
        logger.text.append(log)
        logger.text.append("\n")
    }

    func promptForAuthorization() {
        let alert = UIAlertController(title: "Location Access is needed to get your location.", message: "Please, allow to use always.", preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "Setting", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [weak self] _ in
            self?.locationManagerNeededState()
        }

        alert.addAction(settingAction)
        alert.addAction(cancelAction)
        alert.preferredAction = settingAction

        present(alert, animated: true, completion: nil)
    }

    func startBeaconScanning() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
//                let uuid = UUID(uuidString: "086704EE-9611-4ACC-91DB-F983ABAC9153")!
                let uuid = UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!    // locate manager pre-setting UUID
//                let uuid = UUID(uuidString: "CFC50F84-BEAC-473B-98A1-28DD3089788F")!    // 전팀장님이 준 UUID
//                let uuid = UUID(uuidString: "10F86430-1346-11E4-9191-0800200C9A66")!

                let major = CLBeaconMajorValue(123)
                let minor = CLBeaconMinorValue(456)
//                let major = CLBeaconMajorValue(1)
//                let minor = CLBeaconMinorValue(1)
//                let major = CLBeaconMajorValue(0x38)
//                let minor = CLBeaconMinorValue(0xB3)

                let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: uuid.uuidString)
                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)

                locationManager.startMonitoring(for: beaconRegion)
                locationManager.startRangingBeacons(satisfying: beaconRegionConstraints)
            }
        }
    }

    func stopBeaconScanning() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
//                let uuid = UUID(uuidString: "086704EE-9611-4ACC-91DB-F983ABAC9153")!
                let uuid = UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!    // locate manager pre-setting UUID
//                let uuid = UUID(uuidString: "CFC50F84-BEAC-473B-98A1-28DD3089788F")!    // 전팀장님이 준 UUID
//                let uuid = UUID(uuidString: "10F86430-1346-11E4-9191-0800200C9A66")!

                let major = CLBeaconMajorValue(123)
                let minor = CLBeaconMinorValue(456)
//                let major = CLBeaconMajorValue(1)
//                let minor = CLBeaconMinorValue(1)
//                let major = CLBeaconMajorValue(0x38)
//                let minor = CLBeaconMinorValue(0xB3)

                let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: uuid.uuidString)
//                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)

                locationManager.stopMonitoring(for: beaconRegion)
                locationManager.stopRangingBeacons(satisfying: beaconRegionConstraints)
                
                locationManager.showsBackgroundLocationIndicator = false
            }
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func playSound() {
//        guard let soundFileURL = Bundle.main.url(forResource: "FindPhoneSound", withExtension: "mp3") else {
//            return
//        }
//
//        do {
//            // Configure and activate the AVAudioSession
//            try AVAudioSession.sharedInstance().setCategory(.playback)
//            try AVAudioSession.sharedInstance().setActive(true)
//            UIApplication.shared.beginReceivingRemoteControlEvents()
//
//            player = try AVAudioPlayer(contentsOf: soundFileURL)
//
//            let timeInterval = 60.0
//            let timeOffset = player!.deviceCurrentTime + timeInterval
//            player!.play(atTime: timeOffset)
//        }
//        catch {
//            // Handle error
//        }
        NotificationHandler.shared.playSound()
    }
    
    func stopSound() {
        NotificationHandler.shared.stopSound()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        log("locationManagerDidChangeAuthorization")
        
        switch manager.authorizationStatus {
        case .authorizedAlways:
            log("authorizedAlways")
//            self.startUpdatingLocation()
            self.stopBeaconScanning()
            self.startBeaconScanning()
        case .authorizedWhenInUse:
            log("authorizedWhenInUse")
        case .denied:
            log("denied")
            promptForAuthorization()
        case .notDetermined:
            log("notDetermined")
            locationManagerNeededState()
        case .restricted:
            log("restricted.")
            locationManagerRestrictedState()
        default:
            log("unknown")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log("locationManager(manager, didUpdateLocations)")

        guard let location = manager.location else {
            return
        }
        let cor = location.coordinate
        printAddressBasedOnGPS(lati: cor.latitude , longi: cor.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
            send(beacons)
        } else {
            update(distance: .unknown)
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log("did start monitoring for region \(region.identifier)")
//        This method performs the request asynchronously and delivers the results to the location manager’s delegate.
//        You must implement the locationManager(_:didDetermineState:for:) method in the delegate to receive the results.
        manager.requestState(for: region)
//        NotificationHandler.shared.showNotification(title: "did start monitoring for region", body: "\(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log("did monitoring failed \(error.localizedDescription)")
//        NotificationHandler.shared.showNotification(title: "did fail for region", body: "")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log("did enter region")
        NotificationHandler.shared.showNotification(title: "did enter region", body: "\(region.identifier): \(region.description)")
        playSound()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log("did exit region")
        NotificationHandler.shared.showNotification(title: "did exit region", body: "\(region.identifier)")
        stopSound()
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        playSound()
        switch state {
        case .unknown:
            log("did determin unknown region")
        case .inside:
            log("did determin inside of region")
//            NotificationHandler.shared.showNotification(title: "did determin state", body: "inside")
        case .outside:
            log("did determin outside of region")
//            NotificationHandler.shared.showNotification(title: "did determin state", body: "outside")
        default:
            log("did determin unknown region")
        }
    }
}

extension ViewController{
    func printAddressBasedOnGPS(lati:CLLocationDegrees, longi:CLLocationDegrees){
        let findLocation = CLLocation(latitude: lati, longitude: longi )
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr") //원하는 언어의 나라 코드 삽입
        
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                
                if let name: String = address.last?.name {
                    print(name , lati, address)
                    self.log("\(name) : \(address) [\(lati)]")
                }
                // refered to CLPlacemark 객체:
                // po address.last?.administrativeArea 경기도
                // po address.last?.locality 안양시
                // po address.last?.name     안양대로
                // po address.last?.country  대한민국
            }
        })
    }
    
    func send(_ beacons: [CLBeacon]) {
        for beacon in beacons {
//            NotificationHandler.shared.showNotification(title: "did range region \(beacon.proximity.rawValue)", body: "")
         log("did beacon \(beacon.uuid):\(beacon.major):\(beacon.minor) range region proximity:  \(beacon.proximity.rawValue)")
        }
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1, delay: 0.1) {
            switch distance {
            case .unknown:
                self.logger.backgroundColor = .gray
                self.log("unknown")
            case .immediate:
                self.logger.backgroundColor = .red
                self.log("immediate")
            case .near:
                self.logger.backgroundColor = .orange
                self.log("near")
            case .far:
                self.logger.backgroundColor = .blue
                self.log("far")
            default:
                self.logger.backgroundColor = .gray
                self.log("unknown")
            }
        }
    }
}
