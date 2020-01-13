//
//  IVConfigMgr.swift
//  IVLogger
//
//  Created by Zhang on 2019/9/8.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

public struct Config: Codable {
    public var name: String
    public var key: String
    public var value: String
    public var enable: Bool
}

public class IVConfigMgr: NSObject {
    
    static let kAllConfigKeys = "IVConfigKeys"
    
    public static var allConfigs: [Config] = {
        if let data = UserDefaults.standard.data(forKey: kAllConfigKeys),
            let cfgs = try? JSONDecoder().decode([Config].self, from: data) {
            return cfgs
        }
        return []
    }() {
        didSet {
            let data = try? JSONEncoder().encode(allConfigs)
            UserDefaults.standard.set(data, forKey: kAllConfigKeys)
        }
    }

    static func addCfg(_ cfg: Config) {
        if let idx = allConfigs.firstIndex(where: { $0.name == cfg.name }) {
            allConfigs[idx] = cfg
        } else {
            allConfigs.append(cfg)
        }
    }

    static func deleteCfg(_ cfg: Config) {
        if let idx = allConfigs.firstIndex(where: { $0.name == cfg.name }) {
            allConfigs.remove(at: idx)
        }
    }

    static func updateCfg(_ name: String, _ newCfg: Config) {
        if let idx = allConfigs.firstIndex(where: { $0.name == name }) {
            allConfigs[idx] = newCfg
        }
    }

    static func enableCfg(_ name: String, _ enable: Bool) {
        if let idx = allConfigs.firstIndex(where: { $0.name == name }) {
            allConfigs[idx].enable = enable
        }
    }
    
    static func existsCfg(_ name: String) -> Bool {
        if let _ = allConfigs.firstIndex(where: { $0.name == name }) {
            return true
        }
        return false
    }
    


}