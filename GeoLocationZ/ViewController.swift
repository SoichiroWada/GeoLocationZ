//
//  ViewController.swift
//  GeoLocationZ
//
//  Created by SoichiroWada on 2019/08/30.
//  Copyright © 2019 SoichiroWada. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var locManager:CLLocationManager!
    
    var geocodingStatus: Int = 0
    
    var latitude:String = ""
    var longitude:String = ""
    var wrappedLat:String? = nil
    var wrappedLon:String? = nil
    var uuid:String = ""
    var time1:String = ""
    var time2:String = ""
    var time3:String = ""
    var absoluteTime1:Double = 0.0
    var absoluteTime2:Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locManager = CLLocationManager()
        locManager.delegate = self
        
        // 位置情報の使用の許可を得る
        locManager.requestWhenInUseAuthorization()
//        locManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedWhenInUse:
    //            case .authorizedAlways:
                    // 座標の表示
                    locManager.startUpdatingLocation()
                    break
                default:
                    break
            }
        }
        // 地図の初期化
        initMap()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        
        print("########## Geocodeing by location Manager ##########")
        
        wrappedLat = locations.last?.coordinate.latitude.description
        wrappedLon = locations.last?.coordinate.longitude.description
        
        if wrappedLat == nil || wrappedLon == nil {
            geocodingStatus = 99
        } else if wrappedLat! == "" || wrappedLon! == "" {
            geocodingStatus = 0
        } else {
            geocodingStatus = 1
            longitude = wrappedLat!
            latitude = wrappedLon!
        }
        print("geocodingStatus: ", geocodingStatus)
        
//        longitude = (locations.last?.coordinate.longitude.description)!
//        latitude = (locations.last?.coordinate.latitude.description)!
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time1 = format.string(from: date)
        format.dateFormat = "yyyy年MM月dd日 HH時mm分"
        time2 = format.string(from: date)
        
        absoluteTime1 = CFAbsoluteTimeGetCurrent()
        
        print("time1: ", time1)
        print("time2: ", time2)
        print("absoluteTime1: ", absoluteTime1)
        
        if let uuidx = UIDevice.current.identifierForVendor?.uuidString {
            uuid = uuidx
            print("uuid : " + uuid)
        }
        
        print("経度 : " + longitude)
        print("緯度 : " + latitude)
        print("日時 : " + time2)
        print("uuid : " + uuid)
        
        //update position to geo center
        updateCurrentPos((locations.last?.coordinate)!)
    }
    
    func initMap() {
        // 縮尺を設定
        var region:MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        mapView.setRegion(region,animated:true)
        
        // 現在位置表示の有効化
        mapView.showsUserLocation = true
        // 現在位置設定（デバイスの動きとしてこの時の一回だけ中心位置が現在位置で更新される）
        mapView.userTrackingMode = .follow
    }
    
    func updateCurrentPos(_ coordinate:CLLocationCoordinate2D) {
        var region:MKCoordinateRegion = mapView.region
        region.center = coordinate
        mapView.setRegion(region,animated:true)
    }
    
    @IBAction func showAlert(_ sender: UIButton) {
        
        var labelText:String = ""
        if let buttonTitle = sender.title(for: .normal) {
            labelText = buttonTitle
            print(buttonTitle)
        }
        
        absoluteTime2 = CFAbsoluteTimeGetCurrent()
        print("absoluteTime2: ", absoluteTime2)
        
        let difference = absoluteTime2 - absoluteTime1
        print("difference: ",difference)
        
        if difference < 180 && geocodingStatus == 1 {
            let title: String = labelText + "報告を行います"
            let message = """
                作成日時：\(time2)
                緯度：\(latitude)
                経度：\(longitude)
                """
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            let title: String = "GPSデータ取得エラー"
            let message = "現在位置情報が取得できません"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
}

