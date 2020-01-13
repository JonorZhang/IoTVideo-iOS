//
//  IVSuspendViewController.swift
//  IVLogger
//
//  Created by JonorZhang on 2019/12/25.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class IVSuspendViewController: UIViewController {
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 7)
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        textView.layoutManager.allowsNonContiguousLayout = false
        return textView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        view.bringSubviewToFront(textView)
        
        view.isUserInteractionEnabled = false
        
        scheduleRefreshText()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame = view.bounds
    }
    
    func scheduleRefreshText() {
        DispatchQueue.global().async { [weak self] in
            let maxlen = 1600
            var datalen = maxlen
            guard let databuf = malloc(maxlen) else {
                return
            }
            
            let filename = IVFileLogger.shared.currLogFileURL.path.cString(using: .ascii)
            let mode = "rb".cString(using: .ascii)
            guard let fp = fopen(filename, mode) else {
                free(databuf)
                return
            }
            
            if fseek(fp, -maxlen, SEEK_END) != 0 {
                fseek(fp, 0, SEEK_SET)
            }
            
            while let `self` = self {
                datalen = fread(databuf, 1, maxlen, fp);
                fseek(fp, 0, SEEK_END)
                
                if datalen > 0 {
                    if let text = self.stringFromData(Data(bytes: databuf, count: datalen)) {
                        self.insertText(text)
                    }
                }
                usleep(useconds_t(1000000 * 0.1))
            }
            
            free(databuf)
            fclose(fp)
        }
    }
    
    func insertText(_ text: String) {
        DispatchQueue.main.async {
            self.textView.insertText(text)
            let maxTextCount = 2000, delta = 2000 // 给个阈值，防止频繁删除导致画面抖动
            if (self.textView.text.count > maxTextCount + delta) {
                let offset = self.textView.text.count - delta
                let endRemoveIndex = self.textView.text.index(self.textView.text.startIndex, offsetBy: offset)
                self.textView.text.removeSubrange(self.textView.text.startIndex ..< endRemoveIndex)
            }
            let visiRect = self.textView.caretRect(for: self.textView.endOfDocument)
            self.textView.scrollRectToVisible(visiRect, animated: false)
        }
    }
    
    func stringFromData(_ data: Data) -> String? {
        if let utf8Str = String(data: data, encoding: .utf8) {
            return utf8Str
        }
        
        return String(data: data, encoding: .ascii)
    }
}

