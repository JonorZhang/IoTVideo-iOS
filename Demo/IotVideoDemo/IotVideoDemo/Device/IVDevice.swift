//
//  IVDevice.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/18.
//  Copyright © 2019 gwell. All rights reserved.
//

import Foundation

// 来自设备
struct IVDevice {
    var deviceID: String = ""
    var productID: String = ""
    var deviceName: String = ""
    var serialNumber: String = ""
    var version: String = ""
    var macAddr: String = ""
}

// 来自服务器
struct IVDeviceModel: Codable {
    var deviceMode: String?
    var shareType: IVDeviceShareType
    var did: String
    var url: String?
    var deviceName: String?
    var deviceType: String?
}

enum IVDeviceShareType: String, Codable {
    case owner
    case guest
}
