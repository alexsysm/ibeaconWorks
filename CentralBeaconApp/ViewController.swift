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
    
    
    var beaconsToRangeConstraints: [CLBeaconIdentityConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeLocationManager()
        
        let scene = UIApplication.shared.connectedScenes.first
        // grab the scene delegate and give it a reference to this ViewController
        if let sceneDelegate : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sceneDelegate.audioViewController = self;
        }
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
//                let uuid = UUID(uuidString: "9d410000-35d6-f4dd-ba60-e7bd8dc491c0")!    // Tile Beacon

//                let major = CLBeaconMajorValue(123)
//                let minor = CLBeaconMinorValue(456)
//                let major = CLBeaconMajorValue(20523)
//                let minor = CLBeaconMinorValue(14779)

//                let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: uuid.uuidString)
                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
//                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid)
                
                beaconRegion.notifyOnExit = true
                beaconRegion.notifyOnEntry = true
//                beaconRegion.notifyEntryStateOnDisplay = true

                locationManager.startMonitoring(for: beaconRegion)
//                locationManager.startRangingBeacons(satisfying: beaconRegionConstraints)
            }
        }
    }

    func stopBeaconScanning() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//            if CLLocationManager.isRangingAvailable() {
//                let uuid = UUID(uuidString: "086704EE-9611-4ACC-91DB-F983ABAC9153")!
                let uuid = UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!    // locate manager pre-setting UUID
//                let uuid = UUID(uuidString: "CFC50F84-BEAC-473B-98A1-28DD3089788F")!    // 전팀장님이 준 UUID
//                let uuid = UUID(uuidString: "9d410000-35d6-f4dd-ba60-e7bd8dc491c0")!    // Tile Beacon

//                let major = CLBeaconMajorValue(123)
//                let minor = CLBeaconMinorValue(456)
//                let major = CLBeaconMajorValue(20523)
//                let minor = CLBeaconMinorValue(14779)

//                let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: uuid.uuidString)
                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
//                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
                let beaconRegionConstraint = CLBeaconIdentityConstraint(uuid: uuid)

                locationManager.stopMonitoring(for: beaconRegion)
                locationManager.stopRangingBeacons(satisfying: beaconRegionConstraint)
                
                locationManager.showsBackgroundLocationIndicator = false
//            }
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func getState(_ sender: Any) {
        let uuid = UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!    // locate manager pre-setting UUID
//        let uuid = UUID(uuidString: "9d410000-35d6-f4dd-ba60-e7bd8dc491c0")!    // Tile Beacon
        let major = CLBeaconMajorValue(123)
        let minor = CLBeaconMinorValue(456)
//        let major = CLBeaconMajorValue(20523)
//        let minor = CLBeaconMinorValue(14779)

        let beaconRegion = CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: uuid.uuidString)
        locationManager.requestState(for: beaconRegion)
    }

    func playSound() {
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
        if beacons.count > 0 {
            // 여기서 첫번째 비콘을 찾는게 아니고 웰나우가 등록한 비콘의 maj/min을 찾습니다.
            // 1개만 있다고 가정하고 아래에서 123/456으로 하드코딩했으므로 다음과 같이 코딩합니다. 수정하세요.
            let nearestBeacon = beacons.first!
            let major = CLBeaconMajorValue(truncating: nearestBeacon.major)
            let minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)

            switch nearestBeacon.proximity {
            // Sound 재생 거리를 조정하세요.
            case .near, .immediate:
                // 푸시 & 사운드
                NotificationHandler.shared.showNotification(title: "did range near or immediate", body: "\(major): \(minor)")
                playSound()
                
                update(distance: nearestBeacon.proximity)
                send(beacons)
                break

            default:

                beaconsToRangeConstraints.forEach { beaconRegionConstraint in
                    // 여기서 maj/min 찾아서 해당 beaconRegion만 중지 합니다.
                    // 여기서는 하나 밖에 없다고 생각하고 다 중지 시킵니다. 수정하세요.
                    // 시뮬레이터로 하면 폰에서 멀어지면 중지 될 것이고, Tag 로하면 2초뒤에 꺼지니까 중지되어야 합니다.
                    manager.stopRangingBeacons(satisfying: beaconConstraint)
                }
                
                NotificationHandler.shared.showNotification(title: "did range far or unknown", body: "\(major): \(minor)")
                stopSound()

                update(distance: nearestBeacon.proximity)
                send(beacons)
                
                break
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log("did start monitoring for region \(region.identifier)")
//        This method performs the request asynchronously and delivers the results to the location manager’s delegate.
//        You must implement the locationManager(_:didDetermineState:for:) method in the delegate to receive the results.
        manager.requestState(for: region)
        NotificationHandler.shared.showNotification(title: "did start monitoring for region", body: "\(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log("did monitoring failed \(error.localizedDescription)")
//        NotificationHandler.shared.showNotification(title: "did fail for region", body: "")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            if CLLocationManager.isRangingAvailable() {
                let beaconRegion: CLBeaconRegion = region as! CLBeaconRegion;
                log("did enter region \(beaconRegion.uuid), \(String(describing: beaconRegion.major)), \(String(describing: beaconRegion.minor))")

                let major = CLBeaconMajorValue(123)
                let minor = CLBeaconMinorValue(456)
                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: beaconRegion.uuid, major: major, minor: minor)
//                let beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid)
                
                manager.startRangingBeacons(satisfying: beaconRegionConstraints)

                // Store the beacon so that ranging can be stopped on demand.
                beaconsToRangeConstraints.append(beaconRegionConstraints)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let r: CLBeaconRegion = region as! CLBeaconRegion;
        log("did exit region \(r.uuid), \(String(describing: r.major)), \(String(describing: r.minor))")
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
            NotificationHandler.shared.showNotification(title: "did determin state", body: "inside")
        case .outside:
            log("did determin outside of region")
            NotificationHandler.shared.showNotification(title: "did determin state", body: "outside")
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
