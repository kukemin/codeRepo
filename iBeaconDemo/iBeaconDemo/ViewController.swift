//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by mac on 2020/9/22.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

     let Beacon_Device_UUID = "B0702880-A295-A8AB-F734-031A98A512DE"
    lazy var locationManager: CLLocationManager = {
        let loca = CLLocationManager()
        loca.delegate = self
        return loca
    }()
    
    lazy var beaconRegion: CLBeaconRegion = {
            // 监听所有UUID为Beacon_Device_UUID的Beacon设备
            let beacon = CLBeaconRegion(proximityUUID: UUID(uuidString: Beacon_Device_UUID)!, identifier: "BCTest")
            // 监听UUID为Beacon_Device_UUID，major为666的所有Beacon设备
    //        let beacon1 = CLBeaconRegion(proximityUUID: UUID(uuidString: Beacon_Device_UUID)!, major: CLBeaconMajorValue(exactly: 666)!, identifier: "BCTest")
            // 监听UUID为Beacon_Device_UUID，major为666，minor为999的唯一一个Beacon设备
    //       let beacon2 = CLBeaconRegion(proximityUUID: UUID(uuidString: Beacon_Device_UUID)!, major:  CLBeaconMajorValue(exactly: 666)!, minor: CLBeaconMinorValue(exactly: 999), identifier: "BCTest")
            beacon.notifyEntryStateOnDisplay = true
            return beacon
        }()
    lazy var tableview: UITableView = {
 
        let tablewview = UITableView.init(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.addSubview(tablewview)
        tablewview.dataSource = self;
        tablewview.delegate = self;
        
//        tablewview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")

        return tablewview
        
    }()
    
    lazy var dataArr:[Dictionary<String, String>] = {
        return Array()
    }()
    
    lazy var textfild:UITextField = {
        
        let textfild = UITextField.init(frame: CGRect(x: 50, y: 50, width: UIScreen.main.bounds.width - 100, height: 50))
        
        textfild.placeholder = "请输入要检测的proximityUUID"
        
        textfild.borderStyle = .line

        return textfild
        
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        
//        view.addSubview(textfild)
        
        
        // 在开始监控之前，我们需要判断改设备是否支持，和区域权限请求
            let availableMonitor = CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
            if availableMonitor {
                let authorizationStatus = CLLocationManager.authorizationStatus()
                switch authorizationStatus {
                case .notDetermined:
                    locationManager.requestAlwaysAuthorization()
                case .denied:
                    print("权限受限制")
                case .authorizedWhenInUse, .authorizedAlways:
                    locationManager.startMonitoring(for: beaconRegion)
                    locationManager.startRangingBeacons(in: beaconRegion)
                default:
                    break
                }
            } else {
                print("该设备不支持 CLBeaconRegion 区域检测")
            }

            
        }
    
    

    
}
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
        }
    }
// pragma mark -- Monitoring
    /** 进入区域 */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
             print("你已经进入监控区域")
        var dic:[String:String] = [String:String]()
        dic["proximityUUID"] = "你已经进入监控区域"
        dataArr.insert(dic, at: 0)
        tableview.reloadData()
        tableview.scrollsToTop = true
        
        
        let notification = UILocalNotification()
        
        notification.alertBody = "你已经进入监控区域"
//        UIApplication.shared.presentLocalNotificationNow(notification)
//        UIApplication.shared.scheduleLocalNotification(notification)
        
        
       
        
    }
    /** 离开区域 */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
              print("你已经离开监控区域")
         var dic:[String:String] = [String:String]()
        dic["proximityUUID"] = "你已经离开监控区域"
        dataArr.insert(dic, at: 0)
        tableview.reloadData()
        tableview.scrollsToTop = true
    }
    /** Monitoring有错误产生时的回调 */
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
    }
    /** Monitoring 成功回调 */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
// pragma mark -- Ranging
    /** 1秒钟执行1次 */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            print("rssis is:\(beacon.rssi)")
            print("beacon proximity :\(beacon.proximity)")
            print(" accuracy : \(beacon.accuracy)")
            print("proximityUUID : \(beacon.proximityUUID)")
            print("major : \(beacon.major.intValue)")
            print("minor : \(beacon.minor.intValue)")
            
            let location = String(format: "%.3f", beacon.accuracy)
            print( "距离beacon\(location)m")
            
            var dic:[String:String] = [String:String]()
            dic["proximityUUID"] = "\(beacon.proximityUUID)"
            dic["major"] = "\(beacon.major)"
            dic["minor"] = "\(beacon.minor)"
            dic["distance"] = "\(location)m"
            
            dataArr.insert(dic, at: 0)
            tableview.reloadData()
            tableview.scrollsToTop = true
            
            
        }
    }
    /** ranging有错误产生时的回调  */
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        
    }
//    pragma mark -- Kill callBack
    
    /** 杀掉进程之后的回调，直接锁屏解锁，会触发 */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
      // 发送本地通知
        
        let localNotification = UILocalNotification.init()
        let msgText: String = state == .unknown ? "未知" : state == .inside ? "区域外":"区域内"
        let msg = "你监听的Beacon区域状态：\(msgText),锁屏点亮屏幕会收到此推送"
        if region.isKind(of: CLBeaconRegion.self) {
            let bregion = region as? CLBeaconRegion
            let body = "status = \(msg),uuid = \(String(describing: bregion?.proximityUUID.uuidString)),major = \(String(describing: bregion?.major?.intValue)),minor = \(String(describing: bregion?.minor?.intValue))"
            localNotification.alertBody = body
            
//            localNotification.delayTimeInterval = 0.0
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        
    }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("dataArr:\(dataArr.count)")
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil{
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        }
            
        let dic = dataArr[indexPath.row]
        
        cell?.textLabel?.text = "beacon设备：\(dic["proximityUUID"]!)"
        
        if let major = dic["major"]{
            
            cell?.detailTextLabel?.text = "major:\(major) minor:\(dic["minor"]!) distance:\(dic["distance"]!)"
        }

        
        return cell!
        
    }
    
    
}

