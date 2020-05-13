//
//  IVDevicePlayerViewController.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/25.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

import UIKit
import IoTVideo
import Photos


class IVDevicePlayerViewController: UIViewController, IVDeviceAccessable {
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var screenshotBtn: UIButton!
    @IBOutlet weak var userdataFiled: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var deviceIdLabel: UILabel?
    
    // IVPlayerTalkable
    @IBOutlet weak var speakerBtn: UIButton?
    @IBOutlet weak var micBtn: UIButton?
    
    // IVLivePlayer
    @IBOutlet weak var cameraBtn: UIButton?


    var device: IVDevice!
    var player: IVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceIdLabel?.text = device.deviceID
        
        for ctrl in [recordBtn, screenshotBtn, speakerBtn, micBtn, cameraBtn, userdataFiled] {
            ctrl?.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayerIfNeed), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayerIfNeed), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayerIfNeed), name: UIApplication.willTerminateNotification, object: nil)
    
        player.delegate = self
        player.videoView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.videoView!.frame = videoView.bounds
        videoView.autoresizesSubviews = true
        videoView.insertSubview(player.videoView!, at: 0)
        UIApplication.shared.isIdleTimerDisabled = true //禁止锁屏
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
        UIApplication.shared.isIdleTimerDisabled = false //允许锁屏
    }

    deinit {
        logInfo(self.classForCoder, #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func stopPlayerIfNeed() {
        if player.status != .stoped {
            player.stop()
        }
    }
    
    func requestAuthorization(_ work: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                IVPopupView.showAlert(message: "未授权访问相册", in: self.videoView)
                return
            }
            DispatchQueue.main.async(execute: work)
        }
    }

    static func creationRequestForAsset(_ asset: Any, target: IVDevicePlayerViewController?) {
        PHPhotoLibrary.shared().performChanges({
            if let image = asset as? UIImage {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } else if let url = asset as? URL {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }
        }) { (_, error) in
            
            let msg = (asset is UIImage ? "图片" : "录像") + (error != nil ? "保存失败 \(asset), \(error!)" : "已保存到相册")
            
            error != nil ? logError(msg, asset) : logInfo(msg, asset)
            
            if let target = target {
                IVPopupView.showAlert(message: msg, in: target.videoView)
            } else {
                IVPopupView.showAlert(message: msg)
            }
        }
    }
}

// MARK: - 点击事件
extension IVDevicePlayerViewController {
            
    @IBAction func playClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if let player = player as? IVPlaybackPlayer,
                player.status == .paused {
                player.resume()
            } else {
                player.play()
            }
        } else {
            if let player = player as? IVPlaybackPlayer {
                player.pause()
            } else {
                player.stop()
            }
        }
    }
    
    @IBAction func recordClicked(_ sender: UIButton) {
        if player.isRecording {
            player.stopRecord()
            sender.isSelected = false
        } else {
            requestAuthorization { [weak self] in
                let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let mp4Path = docPath + "/" + Date().string() + ".mp4"
                self?.player.startRecord(mp4Path) { (savePath, error) in
                    sender.isSelected = false
                    guard let savePath = savePath else {
                        IVPopupView.showAlert(message: error?.localizedDescription ?? "录像失败", in: self?.videoView)
                        return
                    }
                    let url = URL(fileURLWithPath: savePath)
                    IVDevicePlayerViewController.creationRequestForAsset(url, target: self)
                }
                sender.isSelected = true
            }
        }
    }
    
    @IBAction func screenshotClicked(_ sender: UIButton) {
        requestAuthorization {  [weak self] in
            self?.player.takeScreenshot({ (image) in
                guard let image = image else {
                    IVPopupView.showAlert(message: "截图失败", in: self?.videoView)
                    return
                }
                DispatchQueue.main.sync {
                    guard let `self` = self else { return }
                    let imgW: CGFloat = 150
                    let imgH = imgW / image.size.width * image.size.height
                    let imgVrect = CGRect(x: 8, y: self.videoView.bounds.size.height - imgH - 8, width: imgW, height: imgH)
                    let imgView = UIImageView(frame: imgVrect)
                    imgView.image = image
                    self.videoView.addSubview(imgView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        imgView.removeFromSuperview()
                    }
                    IVDevicePlayerViewController.creationRequestForAsset(image, target: self)
                }
            })
        }
    }
    
    @IBAction func micClicked(_ sender: UIButton) {
        
        let status = AVAudioSession.sharedInstance().recordPermission
        if status == AVAudioSession.RecordPermission.denied {
            let errStr = "没有麦克风权限，请在设置中开启"
            logWarning(errStr)
            IVPopupView.showAlert(message: errStr, in: self.videoView)
            return
        }
        
        if let player = player as? IVPlayerTalkable {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                player.stopTalk()
            } else {
                player.startTalk()
            }
        }
    }
    
    @IBAction func speakerClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        player.mute = sender.isSelected
    }
}

extension IVDevicePlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let cmd = textField.text, !cmd.isEmpty,
            let cmdData = cmd.data(using: .utf8) {
            player.sendUserData(cmdData)
            IVPopupView.showAlert(title: "已发送", message: "\(cmdData)", in: self.videoView)
        }
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        userdataFiled.resignFirstResponder()
    }

}

extension IVDevicePlayerViewController: IVPlayerDelegate {
    func player(_ player: IVPlayer, didUpdate status: IVPlayerStatus) {
        let animating = (status == .preparing || status == .loading)
        animating ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        playBtn.isSelected = (status == .playing)
        speakerBtn?.isSelected = player.mute
        
        if let player = player as? IVPlayerTalkable {
            micBtn?.isSelected = !player.isTalking
        }
        
        if let player = player as? IVLivePlayer {
            cameraBtn?.isSelected = !player.isCameraOpening
        }

        for ctrl in [recordBtn, screenshotBtn, speakerBtn, micBtn, cameraBtn, userdataFiled] {
            ctrl?.isEnabled = (status == .playing)
        }
    }
    
    func player(_ player: IVPlayer, didUpdatePTS PTS: TimeInterval) {
        logVerbose("PTS: ", PTS)
    }
    
    func player(_ player: IVPlayer, didReceiveError error: Error) {
        IVPopupView.showConfirm(title: "播放器错误", message: error.localizedDescription, in: self.videoView)
    }
    
    func player(_ player: IVPlayer, didReceive avHeader: IVAVHeader) {
//        logInfo(avHeader)
    }
    
    func player(_ player: IVPlayer, didReceiveUserData userData: Data) {
        logInfo(userData)
    }
}
