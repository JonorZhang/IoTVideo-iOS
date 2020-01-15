//
//  IVLiveViewController.swift
//  IoTVideoDemo
//
//  Created by ZhaoYong on 2019/11/29.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo
import Photos

class IVLiveViewController: IVDevicePlayerViewController {
        
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var screenshotBtn: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var livePlayer: IVLivePlayer {
        get { return player as! IVLivePlayer }
        set { player = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(device)
        livePlayer = IVLivePlayer(deviceId: device.deviceID)
        livePlayer.delegate = self
        
        previewView.layer.addSublayer(livePlayer.previewLayer)
        
        livePlayer.videoView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePlayer.videoView!.frame = videoView.bounds
        videoView.autoresizesSubviews = true
        videoView.insertSubview(livePlayer.videoView!, at: 0)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        livePlayer.play()
        livePlayer.openCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        livePlayer.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        livePlayer.previewLayer.frame = previewView.bounds
        livePlayer.videoView?.frame   = videoView.bounds
    }
    
    deinit {
        print(self.classForCoder, #function)
    }

    // MARK: - 点击事件

    @IBAction func playClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            livePlayer.play()
        } else {
            livePlayer.stop()
        }
    }

    @IBAction func cameraClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            livePlayer.closeCamera()
        } else {
            livePlayer.openCamera()
        }
    }
    
    @IBAction func switchClicked(_ sender: UIButton) {
        livePlayer.switchCamera()
    }
    
    @IBAction func micClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            livePlayer.stopTalk()
        } else {
            livePlayer.startTalk()
        }
    }
    
    @IBAction func speakerClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        livePlayer.mute = sender.isSelected
    }
    
    @IBAction func recordClicked(_ sender: UIButton) {
        if sender.isSelected {
            livePlayer.stopRecord()
        } else {
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let mp4Path = docPath + "/hahaha.mp4"
            livePlayer.startRecord(mp4Path) { (savePath, error) in
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
        livePlayer.takeScreenshot({ (image) in
            guard let image = image else { return }
            DispatchQueue.main.sync {
                let imgW: CGFloat = 150
                let imgH = imgW / image.size.width * image.size.height
                let imgVrect = CGRect(x: 8, y: self.videoView.bounds.size.height - imgH - 8, width: imgW, height: imgH)
                let imgView = UIImageView(frame: imgVrect)
                imgView.image = image
                self.view.addSubview(imgView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    imgView.removeFromSuperview()
                }
            }
        })
    }
}

extension IVLiveViewController: IVPlayerDelegate {
    func player(_ player: IVPlayer, didUpdate status: IVPlayerStatus) {
        status == .loading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        playBtn.isSelected = (status == .playing)
        speakerBtn.isSelected = livePlayer.mute
        micBtn.isSelected = !livePlayer.isTalking
        cameraBtn.isSelected = !livePlayer.isCameraOpening
    }
    
    func player(_ player: IVPlayer, didUpdatePTS PTS: TimeInterval) {
        logVerbose(PTS)
    }
    
    func player(_ player: IVPlayer, didReceiveError error: Error) {
        logError(error)
    }
    
    func player(_ player: IVPlayer, didReceive avHeader: IVAVHeader) {
//        logInfo(avHeader)
    }
    
    func player(_ player: IVPlayer, didReceiveUserData userData: Data) {
        logInfo(userData)
    }
    
    
}
