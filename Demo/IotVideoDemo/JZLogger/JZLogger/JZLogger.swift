//
//  GWLogger.swift
//  Yoosee
//
//  Created by JonorZhang on 2019/4/10.
//  Copyright © 2019 Gwell. All rights reserved.
//

import Foundation

// 日志级别
@objc public enum Level: Int, CustomStringConvertible {
    case off     = 0
    case fatal   = 1
    case error   = 2
    case warning = 3
    case info    = 4
    case debug   = 5
    case verbose = 6
    
    public var description: String {
        switch self {
        case .off:      return ""
        case .fatal:    return " [F]📵"
        case .error:    return " [E]💔"
        case .warning:  return " [W]⚠️"
        case .info:     return " [I]💙"
        case .debug:    return " [D]"
        case .verbose:  return " [V]"
        }
    }
}

fileprivate class Log: NSObject {
    var date: Date
    var level: Level
    var message: String
    var file: String
    var function: String
    var line: Int
    
    var dateDesc: String {
        return Log.dateFormatter.string(from: date)
    }
    
    var lineDesc: String {
        return "\(line)"
    }
    
    convenience override init() {
        self.init(date: Date(), level: .verbose, message: "", file: "", function: "", line: 0)
    }
    
    init(date: Date, level: Level, message: String, file: String, function: String, line: Int) {
        self.date   = date
        self.level  = level
        self.message   = message
        self.file   = file
        self.function = function
        self.line   = line
        super.init()
    }
    
    // 2019-05-17 08:30:53.004 [D] <BaseViewController.m:22> -[BaseViewController dealloc] 控制器销毁 MineController
    override var description: String {
        return briefDescription
    }
    
    var briefDescription: String {
    #if DEBUG
        let location = ":\(line) "
        return dateDesc + level.description + location + message
    #else
        let location = " <\(file):\(line)> "
        return dateDesc + location + message
    #endif
    }

    var detailDescription: String {
    #if DEBUG
        let location = " <\(file):\(line)> \(function) "
        return dateDesc + level.description + location + message
    #else
        let location = " <\(file):\(line)> "
        return dateDesc + location + message
    #endif
    }

    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func < (lhs: Log, rhs: Log) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func > (lhs: Log, rhs: Log) -> Bool {
        return lhs.date > rhs.date
    }
    
    private static let dateFormatter: DateFormatter = {
        let defaultDateFormatter = DateFormatter()
        defaultDateFormatter.locale = NSLocale.current
        defaultDateFormatter.dateFormat = "HH:mm:ss.SSS" //"yyyy-MM-dd HH:mm:ss.SSS"
        return defaultDateFormatter
    }()
}

@objc public class JZLogger: NSObject {
    
    private static let serialQueue = DispatchQueue(label: "gw.logger.serialQueue")

    /// 日志的最高级别, 默认Debug:.debug / Release:.info。 log.level > maxLevel 的将会忽略
    internal static var maxLevel: Level = {
        return JZLogSettingViewController.logLevel
    }()
    
    @objc public static func log(_ level: Level = .debug, path: String = #file, function: String = #function, line: Int = #line, message: String = "") {
        // 级别限制
        if level.rawValue > maxLevel.rawValue { return }
        
        // 模型转换
        let fileName = (path as NSString).lastPathComponent
        let log = Log(date: Date(), level: level, message: message, file: fileName, function: function, line: line)
        
        logMessage(log.description)
    }
    
    @objc public static func logMessage(_ message: String?) {
        guard let message = message else { return }
    #if DEBUG
        print(message)
    #endif
        serialQueue.async {
            JZFileLogger.shared.insertText(message)
        }
    }
    
    @objc public static var isXcodeRunning: Bool = {
        var info = kinfo_proc()
        info.kp_proc.p_flag = 0
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        
        var size = MemoryLayout.size(ofValue: info)
        let _ = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        
        let isxcode = ( (info.kp_proc.p_flag & P_TRACED) != 0 )
        log(.info, message: "isXcodeRunning:\(isxcode)")

        return isxcode
    }()

}


