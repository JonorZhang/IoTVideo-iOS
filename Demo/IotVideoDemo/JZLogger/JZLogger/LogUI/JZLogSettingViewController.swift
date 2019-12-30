//
//  JZLogSettingViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/10/14.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZLogSettingViewController: UITableViewController {
    
    @IBOutlet weak var logLevelSlider: UISlider!
    @IBOutlet weak var maxLogFilesSlider: UISlider!

    @IBAction func logLevelChanged(_ sender: UISlider) {
        sender.value = Float(Int(sender.value + 0.5) > Int(sender.value) ? Int(sender.value + 0.5) : Int(sender.value))
        JZLogSettingViewController.logLevel = Level(rawValue: Int(sender.value))!
    }
    
    @IBAction func maxLogFilesChanged(_ sender: UISlider) {
        JZLogSettingViewController.maxLogFiles = Int(sender.value)
    }
    
    var popEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logLevelSlider.value = Float(JZLogSettingViewController.logLevel.rawValue)
        maxLogFilesSlider.value = Float(JZLogSettingViewController.maxLogFiles)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled ?? false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = popEnabled
    }
    
    private static let kLogLevelKey = "key.LogLevel.JZLogSettingViewController"
    private static let kMaxLogFilesKey = "key.maxLogFiles.JZLogSettingViewController"
    
    static var logLevel: Level {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: kLogLevelKey)
            JZLogger.maxLevel = newValue
        }
        get {
            if let lv = UserDefaults.standard.value(forKey: kLogLevelKey) as? Int {
                return Level(rawValue: lv) ?? .info
            } else {
                return .info
            }
        }
    }
    
    static var maxLogFiles: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kMaxLogFilesKey)
            JZFileLogger.shared.maxFileCount = newValue
        }
        get {
            return UserDefaults.standard.value(forKey: kMaxLogFilesKey) as? Int ?? 30
        }
    }

}
