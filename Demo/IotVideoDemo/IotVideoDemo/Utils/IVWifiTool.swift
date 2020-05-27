//
//  IVWifiTool.swift
//  IotVideoDemoDev
//
//  Created by zhaoyong on 2020/5/15.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

struct IVWifiTool {
    private static let kDemoWifiList = "iot_demo_wifi_list"
    
    static var currentSSID: String? {
        guard let wifiInterfaces = CNCopySupportedInterfaces() else { return nil }
        let interfaceArr = CFBridgingRetain(wifiInterfaces) as! Array<String>
        if interfaceArr.count > 0 {
            let interfaceName = interfaceArr[0] as CFString
            let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
            if (ussafeInterfaceData != nil) {
                let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                return interfaceData["SSID"] as? String
            }
        }
        return nil 
    };
    
    /// 本地缓存wifi信息
    /// - Parameters:
    ///   - ssid: ssid
    ///   - password: 密码
    static func save(wifi ssid: String, _ password: String) {
        var wifiList = UserDefaults.standard.dictionary(forKey: kDemoWifiList) as?  [String: String]
        if wifiList == nil {
            wifiList = [String: String]()
        }
        wifiList![ssid] = password
        UserDefaults.standard.setValue(wifiList, forKey: kDemoWifiList)
    }
    
    /// 读取本地缓存的wifi密码
    /// - Parameter ssid: ssid
    /// - Returns: 密码
    static func read(wifi ssid: String) -> String {
        if let wifiList = UserDefaults.standard.dictionary(forKey: kDemoWifiList) as? [String: String] {
            if let pwd = wifiList[ssid] {
              return pwd
            }
        }
        return ""
    }
}
