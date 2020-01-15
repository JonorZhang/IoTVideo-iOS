//
//  IVMonitorViewController.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/11.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo
import Photos


class IVMonitorViewController: IVDevicePlayerViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var screenshotBtn: UIButton!
    
    var monitorPlayer: IVMonitorPlayer {
        get { return player as! IVMonitorPlayer }
        set { player = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID)
        monitorPlayer.delegate = self
        
        monitorPlayer.videoView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        monitorPlayer.videoView!.frame = videoView.bounds
        videoView.autoresizesSubviews = true
        videoView.insertSubview(monitorPlayer.videoView!, at: 0)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared.allowRotation = true
        monitorPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.shared.allowRotation = false
        UIDevice.setOrientation(.portrait)
        monitorPlayer.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        monitorPlayer.videoView?.frame = videoView.bounds
    }
    
    deinit {
        print(self.classForCoder, #function)
    }

    // MARK: - 点击事件
    
    @IBAction func playClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            monitorPlayer.play()
        } else {
            monitorPlayer.stop()
        }
    }

    @IBAction func micClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            monitorPlayer.stopTalk()
        } else {
            monitorPlayer.startTalk()
        }
    }
    
    @IBAction func speakerClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        monitorPlayer.mute = sender.isSelected
    }
    
    @IBAction func recordClicked(_ sender: UIButton) {
        if sender.isSelected {
            monitorPlayer.stopRecord()
        } else {
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let mp4Path = docPath + "/hahaha.mp4"
            monitorPlayer.startRecord(mp4Path) { (savePath, error) in
                guard let savePath = savePath else {
                    print("录像失败", error as Any)
                    return
                }
                print("录像成功", savePath)
                let url = URL(fileURLWithPath: savePath)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { (success, error) in
                    guard success == true else {
                        print("视频保存到相册失败", error as Any)
                        return
                    }
                    print("视频保存到相册成功", url)
                }
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func screenshotClicked(_ sender: UIButton) {
        monitorPlayer.takeScreenshot({ (image) in
            guard let image = image else { return }
            DispatchQueue.main.sync {
                let imgW: CGFloat = 150
                let imgH = imgW / image.size.width * image.size.height
                let imgVrect = CGRect(x: 8, y: self.videoView.bounds.size.height - imgH - 8, width: imgW, height: imgH)
                let imgView = UIImageView(frame: imgVrect)
                imgView.image = image
                self.videoView.addSubview(imgView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    imgView.removeFromSuperview()
                }
            }
        })
    }
}

extension IVMonitorViewController: IVPlayerDelegate {
    func player(_ player: IVPlayer, didUpdate status: IVPlayerStatus) {
        status == .loading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        playBtn.isSelected = (status == .playing)
        speakerBtn.isSelected = monitorPlayer.mute
        micBtn.isSelected = !monitorPlayer.isTalking
    }
    
    func player(_ player: IVPlayer, didUpdatePTS PTS: TimeInterval) {
        logVerbose(PTS)
    }
    
    func player(_ player: IVPlayer, didReceiveError error: Error) {
        logError(error)
    }
    
    func player(_ player: IVPlayer, didReceive avHeader: IVAVHeader) {
        //logInfo(avHeader)
    }
    
    func player(_ player: IVPlayer, didReceiveUserData userData: Data) {
        logInfo(userData)
    }
    
}
