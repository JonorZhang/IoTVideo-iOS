# 快速开始

## 第一步：集成

**平台支持**：

| 平台 | SDK 及兼容性          | SDK 及 Demo                                                  |
| :--- | :-------------------- | :----------------------------------------------------------- |
| iOS  | Xcode 10.2+, iOS 9.0+ | 填写 [申请表](https://cloud.tencent.com/apply/p/ozpml9a5po) 进行申请，完成申请后，相关工作人员将联系您进行需求沟通，并提供对应 SDK 及 Demo |

将IoTVideoSDK集成到您的项目中并配置工程依赖，就可以完成SDK的集成工作。

> 详情请参见 [【集成指南】](#集成指南)

## 第二步：接入准备

开始使用 SDK 前，我们还需要获取`accessId`和`accessToken`，获取方式如下：

- **accessId：** 外部访问 IoT Video 云平台的唯一性身份标识 
- **accessToken：** 登录成功后 IoT Video 云服务器返回的`accessToken`。

**1. 获取 accessId**

用户自有账号体系可以采用云对接的方式实现账户体系相关业务，详情请参见 [终端用户注册](https://cloud.tencent.com/document/product/1131/42370)。

**2. 获取accessToken**

用户自有账号体系可以采用云对接的方式实现账户体系相关业务，详情请参见 [终端用户接入授权](https://cloud.tencent.com/document/product/1131/42365)。

## 第三步：SDK初始化

### 1、初始化

在 `AppDelegate` 中的`application:didFinishLaunchingWithOptions:`调用如下初始化方法：

```swift
import IoTVideo

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
    // 初始化
    IoTVideo.sharedInstance.setup(launchOptions: launchOptions)
    // 设置代理
    IoTVideo.sharedInstance.delegate = self
    // 设置日志等级
    IoTVideo.sharedInstance.logLevel = .DEBUG
    
    ...
}

/// IoTVideoDelegate协议
extension AppDelegate: IoTVideoDelegate {
    func didUpdate(_ linkStatus: IVLinkStatus) {
        print("sdkLinkStatus: \(linkStatus.rawValue)")
    }
    
    func didOutputLogMessage(_ message: String, level: IVLogLevel, file: String, func: String, line: Int32) {
        print("\(Date()) <\(file):\(line)> \(`func`): \(message)")
    }
}

```


### 2、注册

账号注册成功后可获取到 `accessId`，登录成功后可获取到 `accessToken `，调用sdk注册接口:

```swift
import IoTVideo

IoTVideo.sharedInstance.register(withAccessId: "********", accessToken: "********")
```

⚠️注意：对设备的操作都依赖于`accessId`和`accessToken`的加密校验，非法参数将无法操作设备。

## 第四步：配网

通过[SDK初始化](#第三步：SDK初始化) 我们已经可以正常使用SDK，现在我们为设备配置上网环境。   

### 1.设备联网

设备配网模块用来为设备配置上网环境，目前支持以下配网方式:

- 有线配网
- 扫码配网
- AP配网 

⚠️注意：并非任意设备都支持以上所有配网方式，具体支持的配网方式由硬件和固件版本决定。

> 详见[【设备配网】](#设备配网) 

### 2.设备绑定

设备绑定具体操作请参见 [终端用户绑定设备接口](https://cloud.tencent.com/document/product/1131/42367) 进行设备绑定。

### 3.设备订阅

绑定成功后，获取到订阅token,需调用命令使IoTVideo SDK订阅该设备：

```swift
import IoTVideo.IVNetConfig

IVNetConfig.subscribeDevice(withToken: "********", deviceId: deviceId)
```

## 第五步：监控

使用内置的多媒体模块可以轻松实现设备监控。

```swift
import IoTVideo

// 1.创建监控播放器
let monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID)
// 如果是多源设备(NVR)，创建监控播放器时应指定源ID，例如"2"
// let monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID, sourceId: 2)

// 2.设置播放器代理（回调）
monitorPlayer.delegate = self
// 3.添加播放器渲染图层
videoView.insertSubview(monitorPlayer.videoView!, at: 0)
monitorPlayer.videoView?.frame = videoView.bounds
// 4.预连接，获取流媒体头信息
monitorPlayer.prepare()
// 5.开始播放，启动推拉流、渲染模块
monitorPlayer.play()
// 6.开启/关闭语音对讲（只支持MonitorPlayer/LivePlayer）
monitorPlayer.startTalk()
monitorPlayer.stopTalk()
// 7.停止播放，断开连接
monitorPlayer.stop()
```

> 详见[【多媒体】](#多媒体)

## 第六步：消息管理

```swift
import IoTVideo.IVMessageMgr

// 设备ID的字符串
let deviceId = dev.deviceId
// 模型路径的字符串
let path = "ProWritable._logLevel"
// 模型参数的字符串
let json = "{\"setVal\":0}"

// 1.读取属性
IVMessageMgr.sharedInstance.readProperty(ofDeviceId: deviceId, path: path) { (json, error) in
    // do something here    
}

// 2.设置属性
IVMessageMgr.sharedInstance.writeProperty(ofDevice:deviceId, path: path, json: json) { (json, error) in
    // do something here    
}

// 3.执行动作
// 模型路径的字符串
let actionPath = "Action.cameraOn"
// 模型参数的字符串
let actionJson = "{\"ctlVal\":1}"

IVMessageMgr.sharedInstance.takeAction(ofDevice: deviceId, path: actionPath, json: actionJson) { (json, error) in
    // do something here    
}
```


> 详见[【消息管理】](#消息管理)


# 集成指南

本节主要介绍如何快速地将IoTVideoSDK集成到您的项目中，按照如下步骤进行配置，就可以完成 SDK 的集成工 作。

### 开发环境要求

- Xcode 10.2+
- iOS 9.0+

### 集成 SDK

**1. 登录 [物联网智能视频服务控制台](https://console.cloud.tencent.com/iot-video) 进行申请，申请完成后，相关工作人员将联系您进行需求沟通，并提供对应 SDK 及 Demo**。



**2. 将下载并解压得到的IoTVideo相关Framework添加到工程中, 并添加相应依赖库**


> ⚠️重要说明：SDK中的IoTVideo.framework和Demo中的IJKMediaFramework.framework皆依赖于FFmpeg库，为方便开发者能自定义FFmpeg库同时避免多个FFmpeg库代码冲突，自`v1.1(ebb)`版本起IoTVideo.framework将FFmpeg库分离出来，由开发者在APP工程中导入。此外，我们提供了一份基于`ff3.4`的FFmpeg库(非GPL)，位于`Demo/IotVideoDemo/IotVideoDemo/Frameworks/ffmpeg/lib`，仅供开发者参考使用，也可另行编译（注：自行编译的FFmpeg版本应考虑接口兼容问题）。

必选库：

- IoTVideo.framework (静态库)   // 核心库     
  - 依赖FFmpeg库 (必须)
- IVVAS.framework (静态库)      // 增值服务库
- IVNetwork.framework (静态库)  // 网络库

可选库：

- IJKMediaFramework.framework（静态库）// 用于播放云回放的m3u8文件，
  - 依赖FFmpeg库 (必须)
  - 依赖SSL库（可选）

依赖库：

  - AudioToolbox.framework   
  - VideoToolbox.framework   
  - CoreMedia.framework 
  - FFmpeg库 (必须)
    - libavutil.a     
    - libavfilter.a     
    - libavcodec.a     
    - libavformat.a     
    - libswresample.a     
    - libswscale.a
  - SSL库（可选）
    - libcrypto.a
    - libssl.a
  - libc++.tbd
  - libz.tbd
  - libbz2.tbd
  - libiconv.tbd

![](https://note.youdao.com/yws/api/group/108650997/file/900729043?method=download&inline=true&version=1&shareToken=8EEC2178C08E464184C1A09B6363FEE3)



**3. ⚠️注意： v1.0(da7)及之前版本需要设置TATGETS -> Build Phases -> Embed Frameworks为 Embed & sign，或者Xcode11后可在General -> Frameworks,Libraries,and Embedded Content 设置 Embed&Sign**

 ![image](https://note.youdao.com/yws/api/group/108650997/file/898850154?method=download&inline=true&version=2&shareToken=13D2636806184BB1931F4809D2A4C8F0)



**4. 其他设置**

  - 关闭bitcode： TARGETS -> Build Settings -> Build Options -> Enable Bitcode -> NO
    ![image](https://note.youdao.com/yws/api/group/108650997/file/891138351?method=download&inline=true&version=3&shareToken=0C0D6A6794DE4F8BBEC81BD8497CDC41)
  - 设置APP权限,在info.plist中加入下方代码

  ```xml
  <key>NSCameraUsageDescription</key>
  <string>访问相机</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>访问麦克风</string>
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>访问相册</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>访问相册</string>
  ```


# 设备配网

设备配网模块用来为设备配置上网环境，目前支持以下配网方式:

- 有线配网
- 扫码配网
- AP配网

⚠️注意：并非任意设备都支持以上所有配网方式，具体支持的配网方式由硬件和固件版本决定。

##### 通用配网流程

![image](https://note.youdao.com/yws/api/group/108650997/file/891176742?method=download&inline=true&version=1&shareToken=129824A776F441A7B4D86CDB2959E074)

##### 有线配网（添加已在线局域网设备，需设备硬件支持）

部分设备可通过自带网口使用有线上网，省去了配网环节，APP可通过局域网搜索到目标设备，使用设备ID向服务器发起绑定请求。  
流程大致如下：

> 1. APP连接到与设备同一网络下的Wi-Fi
> 2. APP搜索到目标设备，取得目标设备ID
> 3. APP向服务器发起绑定目标设备的请求
> 4. 账户绑定设备成功
> 5. 订阅该设备
> 6. 配网结束

##### AP配网（需设备硬件支持）

AP配网原理是APP连接设备发射的热点，使设备与APP处于同一局域网，并在局域网下实现信息传递。  
流程大致如下：

> 1. 设备复位进入配网模式并发射Wi-Fi热点
> 2. APP连接设备的热点（进入局域网）
> 3. APP向设备发送配网信息（Wi-Fi信息）
> 4. 设备收到配网信息并连接指定网络
> 5. 设备上线并向服务器注册
> 6. APP收到设备已上线通知
> 7. APP向服务器发起绑定目标设备的请求
> 8. 账户绑定设备成功
> 9. 订阅该设备
> 10. 配网结束

##### 二维码配网

二维码配网原理是APP使用配网信息生成二维码，设备通过摄像头扫描二维码获取配网信息。  
流程大致如下：

> 1. 设备复位进入配网模式，摄像头开始扫描二维码
> 2. APP使用配网信息生成二维码
> 3. 用户使用设备扫描二维码
> 4. 设备获取配网信息并连接指定网络
> 5. 设备上线并向服务器注册
> 6. APP收到设备已上线通知
> 7. APP向服务器发起绑定目标设备的请求
> 8. 账户绑定设备成功
> 9. 订阅该设备
> 10. 配网结束

## 使用示例

##### 1.有线配网

```swift
import IoTVideo.IVNetConfig

// 1.获取局域网设备列表
let deviceList: [IVLANDevice] = IVNetConfig.lan.getDeviceList()

// 2.取得目标设备
let dev = deviceList[0]

// 3.绑定设备

// 4.订阅设备 token 来自绑定设备结果的  AccessToken 字段
IVNetConfig.subscribeDevice(withToken: "********", deviceId: deviceId)
```

设备绑定具体操作请参见 [终端用户绑定设备接口](https://cloud.tencent.com/document/product/1131/42367) 进行设备绑定。

##### 2.AP配网

```swift
import IoTVideo.IVNetConfig

// 1.连接设备热点,获取设备信息
let dev = IVNetConfig.lan.getDeviceList().first()


// 2.向服务器请求配网Token
IVNetConfig.getToken { (token, error) in
            
}

// 3.发送配网信息
IVNetConfig.lan.sendWifiName("***", wifiPassword: "***", token: token, toDevice: dev.deviceID) { (success, error) in
    if success {
       //发送成功，开始监听事件通知
    } else {
       //发送失败
    }
}
    
// 4.等待设备配网成功通知,拿到结果后可调用 IVNetConfig.unregisterDeviceOnline(),销毁监听
IVNetConfig.registerDeviceOnlineCallback { (devId, error) in {
    
}

// 5.绑定设备

// 6.订阅设备 token 来自绑定设备结果的  AccessToken 字段
IVNetConfig.subscribeDevice(withToken: "********", deviceId: deviceId)
```

设备绑定具体操作请参见 [终端用户绑定设备接口](https://cloud.tencent.com/document/product/1131/42367) 进行设备绑定。


##### 3.二维码配网

接入方自定义传递给设备的数据格式，可使用内置工具类生成二维码，也可自行生成二维码

```swift
import IoTVideo.IVNetConfig


// 1. 获取配网token
IVNetConfig.getToken { (token, error) in
            
}

// 2. 生成二维码 使用得到的配网token加上wifi信息
let image = IVNetConfig.qrCode.createQRCode(withWifiName: ssid,
                                            wifiPassword: password,
                                                   token: token)


// 3.用户使用设备扫描二维码....

// 4.等待设备配网成功通知, 拿到结果后可调用 IVNetConfig.unregisterDeviceOnline(),销毁监听
IVNetConfig.registerDeviceOnlineCallback { (devId, error) in {
    
}

// 5.绑定设备

// 6.订阅设备 token 来自绑定设备结果的  AccessToken 字段
IVNetConfig.subscribeDevice(withToken: "********", deviceId: deviceId)

```

设备绑定具体操作请参见 [终端用户绑定设备接口](https://cloud.tencent.com/document/product/1131/42367) 进行设备绑定。


# 多媒体

多媒体模块为SDK提供音视频能力，包含实时监控、实时音视频通话、远程回放、录像、截图等功能。
![播放器架构](https://note.youdao.com/yws/api/group/108650997/file/897776632?method=download&inline=true&version=1&shareToken=7A82CB2CA90046279C4EF907ADC575E7)

##### 播放器核心(IVPlayer)

IVPlayer是整个多媒体模块的核心，主要负责以下流程控制：

- 音视频通道建立
- 音视频流的推拉
- 协议解析
- 封装和解封装
- 音视频编解码
- 音视频同步
- 音视频渲染
- 音视频录制
- 播放状态控制

其中，*音视频编解码* 和 *音视频渲染* 流程允许开发者自定义实现（*⚠️播放器已内置实现，不推荐自定义实现*）  

##### 监控播放器(MonitorPlayer)

MonitorPlayer是基于IVPlayer派生的监控播放器，主要增加以下功能：

- 语音对讲

##### 音视频通话播放器(LivePlayer)

LivePlayer是基于IVPlayer派生的音视频通话播放器，主要增加以下功能：

- 语音对讲
- 双向视频

##### 回放播放器(PlaybackPlayer)

PlaybackPlayer是基于IVPlayer派生的回放播放器，主要增加以下功能：

- 暂停/恢复
- 跳至指定位置播放

##### 播放器功能对比

|        功能        | 监控播放器 | 回放播放器 | 音视频通话 |
| :----------------: | :--------: | :--------: | :--------: |
|      视频播放      |     ✓      |     ✓      |     ✓      |
|      音频播放      |     ✓      |     ✓      |     ✓      |
|     暂停/恢复      |     x      |     ✓      |     x      |
|  跳至指定位置播放  |     x      |     ✓      |     x      |
|       总时长       |     x      |     ✓      |     x      |
|    当前播放进度    |     x      |     ✓      |     x      |
| 播放器状态变更通知 |     ✓      |     ✓      |     ✓      |
|        静音        |     ✓      |     ✓      |     ✓      |
|  画面缩放模式设置  |     ✓      |     ✓      |     ✓      |
|     播放器截图     |     ✓      |     ✓      |     ✓      |
|      边播边录      |     ✓      |     ✓      |     ✓      |
|        对讲        |     ✓      |     ✓      |     ✓      |
|     分辨率切换     |     ✓      |     x      |     x      |
|      双向视频      |     x      |     x      |     ✓      |

## 使用示例

##### 1.创建播放器实例
*⚠️ 注意：如果是多源设备(NVR)，创建播放器时应指定源ID，例如"2"*

```swift
import IoTVideo

// 监控播放器
let monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID)
// let monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID, sourceId: 2) //For NVR

// 音视频通话播放器
let livePlayer = IVLivePlayer(deviceId: device.deviceID)
//let livePlayer = IVLivePlayer(deviceId: device.deviceID, sourceId: 2) //For NVR

// 回放播放器
let playbackPlayer = IVPlaybackPlayer(deviceId: device.deviceID, playbackItem: item, seekToTime: time)
//let playbackPlayer = IVPlaybackPlayer(deviceId: device.deviceID, playbackItem: item, seekToTime: time, sourceId: 2) //For NVR

```

*⚠️注意：以下使用`xxxxPlayer`泛指支持该功能的播放器*

##### 2.设置播放器代理（回调）

```swift
xxxxPlayer.delegate = self
```

##### 3.添加摄像头预览图层(只支持LivePlayer)

```swift
previewView.layer.addSublayer(livePlayer.previewLayer)
livePlayer.previewLayer.frame = previewView.bounds
```

##### 4.添加播放器渲染图层

```swift
videoView.insertSubview(xxxxPlayer.videoView!, at: 0)
xxxxPlayer.videoView?.frame   = videoView.bounds
```

##### 5.预连接（可选），获取流媒体头信息

```swift
xxxxPlayer.prepare() //【可选】
```

##### 6.开始播放，启动推拉流、渲染模块

```swift
xxxxPlayer.play()
```

##### 7.开启/关闭语音对讲（只支持MonitorPlayer/LivePlayer）

```swift
xxxxPlayer.startTalking()
xxxxPlayer.stopTalking()
```

##### 8.开启/切换/关闭摄像头（只支持LivePlayer）

```swift
//打开摄像头
livePlayer.openCamera()
//切换摄像头
livePlayer.switchCamera()
//关闭摄像头
livePlayer.closeCamera()
```

##### 9.指定时间播放(只支持PlaybackPlayer)

```swift
playbackPlayer.seek(toTime: time, playbackItem: item)
```

##### 10.暂停/恢复播放(只支持PlaybackPlayer)

```swift
//暂停
playbackPlayer.pause()
//恢复
playbackPlayer.resume()
```

##### 11.停止播放，断开连接

```swift
xxxxPlayer.stop()
```

## 高级功能

##### 自定义音视频编码、解码、渲染、采集等功能模块

> ⚠️注意：音视频编解码及渲染等已默认由核心播放器实现。如无必要，无需另行实现。

播放器默认使用内置采集器、编解码器、渲染器等功能模块，但允许开发者在开始播放前对内置功能模块进行某些参数修改，也可根据对应模块的协议自定义实现并赋值给播放器以覆盖内置功能模块。

```swift
// 基础播放器可自定义模块
class IVPlayer {
	/// 音频解码器, 默认实现为 `IVAudioDecoder`
    open var audioDecoder: (Any & IVAudioDecodable)?
	/// 视频解码器, 默认实现为 `IVVideoDecoder`
     open var videoDecoder: (Any & IVVideoDecodable)?
	/// 音频渲染器, 默认实现为 `IVAudioRender`
    open var audioRender: (Any & IVAudioRenderable)?
	/// 视频渲染器, 默认实现为`IVVideoRender`
    open var videoRender: (Any & IVVideoRenderable)?
	/// 音视频录制器, 默认实现为`IVAVRecorder`
    open var avRecorder: (Any & IVAVRecordable)?
}

// 可对讲播放器可自定义模块
public protocol IVPlayerTalkable {    
	/// 音频采集器, 默认实现为 `IVAudioCapture`
    open var audioCapture: (Any & IVAudioCapturable)
	/// 音频编码器, 默认实现为 `IVAudioEncoder`
    open var audioEncoder: (Any & IVAudioEncodable)
}

// 可视频播放器可自定义模块
protocol IVPlayerVideoable {
    /// 视频采集器, 默认实现为 `IVVideoCapture`
    open var videoCapture: (Any & IVVideoCapturable)?
    /// 视频编码器, 默认实现为 `IVVideoEncoder`
    open var videoEncoder: (Any & IVVideoEncodable)?
}
```

- swift示例如下:

```swift
class MyAudioEncoder: IVAudioEncodable { ... }
class MyAudioDecoder: IVAudioDecodable { ... }
class MyVideoRender: IVVideoRenderable { ... }

// 自定义功能模块
if let player = xxxxPlayer as? IVPlayerTalkable {
    // player.audioEncoder.audioType = .AMR // 默认AAC
    // player.audioEncoder = MyAudioEncoder() // 自定义audioEncoder
    player.audioCapture.sampleRate = 16000 // 默认8000
}
if let player = xxxxPlayer as? IVPlayerVideoable {
    // player.videoEncoder.videoType = .H264 // 默认H264
    player.videoCapture.definition = .mid // 默认low
}
// player.videoRender = MyVideoRender() // 自定义videoRender
// player.audioDecoder = MyAudioDecoder() // 自定义audioDecoder
// ....

// 开始播放
xxxxPlayer.play()
```

更多信息见SDK中的如下路径的内置实现及其协议：

- 内置实现
	- <IoTVideo/IVAudioDecoder.h> // AudioDecode
	- <IoTVideo/IVAudioEncoder.h> // AudioEncode
	- <IoTVideo/IVVideoDecoder.h> // VideoDecode
	- <IoTVideo/IVVideoEncoder.h> // VideoEncode
	- <IoTVideo/IVVideoCapture.h> // VideoCapture
	- <IoTVideo/IVAVRecorder.h>   // AudioRecorder + VideoRecorder
	- <IoTVideo/IVVideoRender.h>  // VideoRender
	- <IoTVideo/IVAudioUnit.h>    // AudioRender + AudioCapture

- 相关协议
	- <IoTVideo/IVAVRecordable.h  >
	- <IoTVideo/IVAudioEncodable.h>
	- <IoTVideo/IVVideoDecodable.h>
	- <IoTVideo/IVAudioCapturable.h>
	- <IoTVideo/IVAudioRenderable.h>
	- <IoTVideo/IVVideoEncodable.h>
	- <IoTVideo/IVAudioDecodable.h >
	- <IoTVideo/IVVideoCapturable.h>
	- <IoTVideo/IVVideoRenderable.h>


##### 自定义数据传输

此功能允许用户在建立通道连接之后传输自定义数据，例如硬件模块开关、交互指令、额外的多媒体信息等。

- 发送数据

> 说明：`#define MAX_DATA_SIZE 64000`

```swift
/// 通道连接（抽象类，不要直接实例化，请使用其派生类: IVLivePlayer / IVPlaybackPlayer / IVMonitorPlayer / IVTransmission）
open class IVConnection : NSObject {
    
    /// 开始连接
    open func connect() -> Bool

    /// 断开连接
    open func disconnect() -> Bool
    
    /// 发送自定义数据
    ///
    /// 需要与设备建立专门的连接通道，适用于较大数据传输、实时性要求较高的场景，如多媒体数据传输。
    /// @param data 要发送的数据，data.length不能超过`MAX_PKG_BYTES`
    /// @return 发送是否成功
    open func send(_ data: Data) -> Bool
}
```

- 接收数据

```swift
/// 连接代理
public protocol IVConnectionDelegate : NSObjectProtocol {
    /// 收到数据
    /// @param connection 连接实例
    /// @param data 数据
    func connection(_ connection: IVConnection, didReceive data: Data)
}
```


# 消息管理

消息管理模块负责APP与设备、服务器之间的消息传递，主要包含以下功能：


- 在线消息回调
  - 接收到事件消息（Event）:  告警、分享、系统通知
  - 接收到状态消息（ProReadonly）
- 控制/操作设备（Action）
- 设置设备参数（ProWritable）
- 获取设备状态（ProReadonly）
- 获取设备参数（ProWritable）
- 自定义消息透传 (Data)

## 使用示例

##### 1.状态和事件消息通知

```swift
import IoTVideo.IVMessageMgr

class MyViewController: UIViewController, IVMessageDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置消息代理
        IVMessageMgr.sharedInstance.delegate = self
    }
    
    // MARK: - IVMessageDelegate
    
    // 接收到事件消息（Event）:  告警、分享、系统通知
    func didReceiveEvent(_ event: String, topic: String) {
        // do something here
    }
    
    // 接收到状态消息（ProReadonly）
    func didUpdateProperty(_ json: String, path: String, deviceId: String) {
        // do something here
    }
}
```

##### 3.读取属性

```swift
import IoTVideo.IVMessageMgr

// 设备ID的字符串
let deviceId = dev.deviceId
// 模型路径的字符串
let path = "ProWritable._logLevel"

IVMessageMgr.sharedInstance.readProperty(ofDevice: deviceId, path: path) { (json, error) in
    // do something here    
}
```

##### 4.设置属性

```swift
import IoTVideo.IVMessageMgr

// 设备ID的字符串
let deviceId = dev.deviceId
// 模型路径的字符串
let path = "ProWritable._logLevel"
// 模型参数的字符串
let json = "{\"setVal\":0}"

IVMessageMgr.sharedInstance.writeProperty(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here    
}
```

##### 5.执行动作

```swift
import IoTVideo.IVMessageMgr

// 设备ID的字符串
let deviceId = dev.deviceId
// 模型路径的字符串
let path = "Action.cameraOn"
// 模型参数的字符串
let json = "{\"ctlVal\":1}"

IVMessageMgr.sharedInstance.takeAction(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here    
}
```

## 高级功能

# 1.透传数据给设备

- 说明：`#define MAX_DATA_SIZE 30000`

```swift
/// 透传数据给设备（无数据回传）
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性不高、数据小于`MAX_DATA_SIZE`、不需要回传的场景，如控制指令。
/// @note 完成回调条件：收到ACK 或 消息超时
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param completionHandler 完成回调
open func sendData(toDevice deviceId: String, data: Data, withoutResponse completionHandler: IVMsgDataCallback? = nil)


/// 透传数据给设备（有数据回传）
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性不高、数据小于`MAX_DATA_SIZE`、需要回传的场景，如获取信息。
/// @note 完成回调条件：收到ACK错误、消息超时 或 有数据回传
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param completionHandler 完成回调
open func sendData(toDevice deviceId: String, data: Data, withResponse completionHandler: IVMsgDataCallback? = nil)


/// 透传数据给设备
///
/// 不需要建立通道连接，数据经由服务器转发，适用于实时性要求不高，数据小于`MAX_DATA_SIZE`的场景，如控制指令、获取信息。
/// @note 相关接口 @c `sendDataToDevice:data:withoutResponse:`、`sendDataToDevice:data:withResponse:`。
/// @param deviceId 设备ID
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param timeout 自定义超时时间，默认超时时间可使用@c `IVMsgTimeoutAuto`
/// @param expectResponse 【YES】预期有数据回传 ；【NO】忽略数据回传
/// @param completionHandler 完成回调
open func sendData(toDevice deviceId: String, data: Data, timeout: TimeInterval, expectResponse: Bool, completionHandler: IVMsgDataCallback? = nil)

```

##### 2.透传数据给服务器

```swift
/// 透传数据给服务器
/// @param url 服务器路径
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param completionHandler 完成回调
open func sendData(toServer url: String, data: Data?, completionHandler: IVMsgDataCallback? = nil)


/// 透传数据给服务器
/// @param url 服务器路径
/// @param data 数据内容，data.length不能超过`MAX_DATA_SIZE`
/// @param timeout 超时时间
/// @param completionHandler 完成回调
open func sendData(toServer url: String, data: Data?, timeout: TimeInterval, completionHandler: IVMsgDataCallback? = nil)

```

# 增值服务
使用前提，设备已开通云存
- 查询存在云存的日期信息
- 获取云存回放m3u8列表


##### 1.查询存在云存的日期信息
```swift
/// 获取云存视频信息
/// - 用于终端用户在云存页面中对云存服务时间内的日期进行标注，区分出是否有云存视频文件。
/// @param deviceId 设备id
/// @param timezone 相对于0时区的秒数，例如东八区28800
/// @param responseHandler 回调
- (void)getVideoListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```

##### 2.获取云存回放m3u8列表
```swift
/// 获取云存回放m3u8列表
///- 终端用户获取云存储的m3u8列表进行回放，同时根据返回的列表对时间轴进行渲染。
/// @param deviceId 设备id
/// @param timezone  相对于0时区的秒数，例如东八区28800
/// @param startTime  时间戳，回放开始时间
/// @param endTime 时间戳，回放结束时间
/// @param responseHandler 回调
- (void)getVideoPlaybackListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
示例请参考：demo 内`IJKMediaViewController.swift`

# 错误码

- 播放器错误码

```swift
public enum IVPlayerError : UInt {

    /// 方法选择器无响应、未实现协议方法
    case noRespondsToSelector = 21030

    /// 参数错误
    case invalidParameter = 21031

    /// 录像列表为空
    case playbackListEmpty = 21032

    /// 录像列表数据异常
    case playbackDataErr = 21033

    /// 正在录制
    case recorderIsRunning = 21034

    /// 视频分辨率已改变
    case videoResolutionChanged = 21035

    /// 编码器暂不可用
    case encoderNotAvailableNow = 21036
}
```

-  消息管理错误码

```swift
public enum IVMessageError : UInt {

    /// 消息重复、消息正在发送
    case duplicate = 21000

    /// 消息发送失败
    case sendFailed = 21001

    /// 消息响应超时
    case timeout = 21002

    /// 获取物模型失败
    case getGdmDataErr = 21003

    /// 接收物模型失败
    case rcvGdmDataErr = 21004

    /// 透传数据给服务器失败
    case sendPassSrvErr = 21005

    /// 透传数据给设备失败
    case sendPassDevErr = 21006

    /// 没有找到回调
    case notFoundCallback = 21007

    /// 数据超过上限
    case exceedsMaxLength = 21008
}
```

- 公共错误码

```swift
public enum IVError : UInt {

    
    //!< 成功
    case error_none = 0

    
    //!< 接入服务器返回的错误码
    //!< 目标离线
    case aSrv_dst_offline = 8000

    //!< 没有找到目标所在的接入服务器
    case aSrv_dst_notfound_asrv = 8001

    //!< 目标不存在
    case aSrv_dst_notexsit = 8002

    //!< 非法关系链
    case aSrv_dst_error_relation = 8003

    //!< 校验帧失败
    case aSrv_data_chkfrm_fail = 8004

    //!< 终端上传的json,加载到物模型失败
    case aSrv_data_loadjson_fail = 8005

    //!< 终端上传的json,修改物模型相关的时间戳失败
    case aSrv_data_modifytick_fail = 8006

    //!< 接入服务器与中心服务器通信超时
    case aSrv_tocsrv_timeout = 8007

    //!< url地址解析失败
    case aSrv_url_parse_fail = 8008

    //!<  中心服务器响应错误的数据
    case aSrv_csrv_reply_err = 8009

    //!< 接入服务器转发消息到其他接入服务器超时
    case aSrv_forward_toASrv_timeout = 8010

    //!< 接入服务器转发消息到其他接入服务器失败
    case aSrv_forward_toASrv_fail = 8011

    //!< 接入服务器转发消息到设备超时
    case aSrv_forward_toTerm_timeout = 8012

    //!< 接入服务器转发消息到设备失败
    case aSrv_forward_toTerm_fail = 8013

    //!< 接入服务器处理收到的数据帧失败
    case aSrv_handle_fail = 8014

    //!< 接入服务器没有从数据帧中解析出目标ID
    case aSrv_dstid_parse_faild = 8015

    //!< 接入服务器发现目标ID是个用户
    case aSrv_dstid_isuser = 8016

    //!< 接入服务器计算leaf失败
    case aSrv_calc_leaf_fail = 8017

    //!< 接入服务器设置物模型的timeval值失败
    case aSrv_set_timeval_leafval_fail = 8018

    //!< 接入服务器计算转发json失败
    case aSrv_calc_forward_json_fail = 8019

    //!< 临时订阅帧没有解析出设备ID
    case aSrv_tmpsubs_parse_fail = 8020

    //!< 中心服务器发来的ctl帧，trgtype不对
    case aSrv_csrvctrl_trgtype_error = 8021

    //!< 这对设备和用户已经绑定
    case aSrv_binderror_dev_usr_has_bind = 8022

    //!< 设备已经绑定其他用户
    case aSrv_binderror_dev_has_bind_other = 8023

    //!< 配网失败,设备的客户ID与用户的客户ID不一致
    case aSrv_binderror_customer_diffrent = 8024

    //!< json字符串处理失败
    case aSrv_unformat_jsstr_fail = 8025

    //!< 配网时生成token失败
    case aSrv_netcfg_maketoken_fail = 8026

    //!< 配网时校验token失败
    case aSrv_netcfg_verifytoken_fail = 8027

    case aSrv_parse_json_fail = 8028

    //!< 接入服务器没有读取到物模型信息
    case aSrv_read_gdm_fail = 8029

    //!< 禁止APP设置
    case aSrv_gdm_ctrl_forbidden = 8030

    //!< 生成腾讯签名失败
    case aSrv_generate_tx_sign_fail = 8031

    //!< 消息SRC终端被禁用(RDB标识禁用)
    case aSrv_src_term_disable = 8032

    //!< 消息DST终端被禁用(RDB标识禁用)
    case aSrv_dst_term_disable = 8033

    //!< 接入服务器设置物模型的origin值失败
    case aSrv_set_origin_leafval_fail = 8034

    //!< 终端类型信息校验失败
    case aSrv_termtype_error = 8035

    //!< 数据与物模型匹配失败
    case aSrv_gdm_match_fail = 8036

    //!< 上传的leaf_path路径无效
    case aSrv_gdmpath_error = 8037

    //!< 重组action消息失败
    case aSrv_rebuild_actioncmd_fail = 8038

    
    //!< 中心服务器返回的错误码
    //!< 帧类型错误
    case ac_frm_type_err = 8501

    //!< 帧长度错误
    case ac_frm_len_err = 8502

    //!< bson数据与bson哈希值不匹配
    case ac_frm_bson_hashval_err = 8503

    //!< 无效的GdmType
    case ac_GdmType_err = 8504

    //!< GACFRM_Bson_UploadReq帧上传的不是一个设备id
    case ac_UploadReq_termid_is_not_dev_err = 8505

    //!< MsgBody_GdmBsonDat结构体中leaf字符串的结束符错误
    case ac_MsgBody_GdmBsonDat_Leaf_length_err = 8506

    //!< MsgBody_GdmJsonDat结构体中leaf字符串的结束符错误
    case ac_MsgBody_GdmJsonDat_Leaf_length_err = 8507

    //!< 获取GdmDefBson错误
    case ac_MsgBody_GetGdmDefBson_err = 8508

    //!< MsgBody_GdmJsonDat结构体中json字符串的结束符错误
    case ac_MsgBody_GdmJsonDat_length_err = 8509

    //!< MsgBody_GdmDat结构体中leaf_path无效
    case ac_MsgBody_GdmDat_Leaf_path_err = 8510

    //!< MsgBody_GdmDat结构体中数据无效
    case ac_MsgBody_GdmDat_content_err = 8511

    //!< 中心服务器中不存在该终端的物模型
    case ac_csrv_no_term_GdmDat_err = 8512

    //!< 中心服务器中找不到该终端
    case ac_csrv_no_term_err = 8513

    //!< 中心服务器中没有与该终端对应的productID
    case ac_csrv_no_term_productID_err = 8514

    //!< 中心服务器获取json格式物模型错误
    case ac_MsgBody_GetGdmDefJson_err = 8515

    
    //!< 初始化请求帧，olinf 参数不正确
    case ac_TermOnlineReq_olinf_parm_err = 8520

    //!< 初始化请求帧,置上了opt_with_data_fp，但是没有置上opt_with_termid
    case ac_TermOnlineReq_opt_with_fp_but_no_with_termid = 8521

    
    //!< GACFRM_Dat_UploadReq reqfrm->dat_type是0，但是没有置上opt_with_termid
    case ac_Dat_UploadReq_dat_type_json_but_no_opt_with_termid_err = 8531

    //!< GACFRM_Dat_UploadReq reqfrm->dat_type是0，但是没有置上opt_with_termid
    case ac_Dat_UploadReq_dat_type_err = 8532

    
    //!< 其它类型错误
    case ac_other_err = 8600

    
    //!< 中心服务器load_bson失败
    case ac_centerInner_load_bson_err = 8601

    //!< 中心服务器load_json失败
    case ac_centerInner_load_json_err = 8602

    //!< 中心服务器get_bson_raw失败
    case ac_centerInner_get_bson_raw_err = 8603

    
    //!< 中心服务器user哈希表插入失败
    case ac_centerInner_insert_user_fail = 8610

    //!< 中心服务器dev哈希表插入失败
    case ac_centerInner_insert_dev_fail = 8611

    case ac_centerInner_find_login_user_err = 8612

    case ac_centerInner_login_user_utcinitchgd_lower_err = 8613

    case ac_centerInner_login_dev_utcinitchgd_lower_err = 8614

    
    case ac_centerInner_processDevLastWord_err = 8620

    case ac_MsgBody_LastWords_topic_is_not_valide_err = 8621

    case ac_MsgBody_LastWords_json_is_not_valide_err = 8622

    case ac_MsgBody_LastWords_not_with_livetime_err = 8623

    case ac_MsgBody_LastWords_not_with_topic_err = 8624

    case ac_MsgBody_LastWords_not_with_json_err = 8625

    case ac_MsgBody_LastWords_action_is_err = 8626

    //!< 中心服务器未查到遗言
    case ac_MsgBody_LastWords_query_is_none = 8627

    
    case aSrv_centerInner_other_err = 8700

    //!< GACFRM_TempSubscription帧上传的不是一个用户id
    case aSrv_TempSubscription_termid_is_not_usr_err = 8800

    //!< GACFRM_RdbTermListReq帧既不获取在线信息也不获取离线信息，从业务上来说这是无意义的
    case aSrv_RdbTermListReq_neither_get_online_nor_get_offline_err = 8900

    case aSrv_AllTermInitReq_other_err = 9000

    
    //!< 终端使用
    //!< 消息发送给对方超时
    case term_msg_send_peer_timeout = 20001

    //calling相关
    //!< 普通挂断消息
    case term_msg_calling_hangup = 20002

    //!< calling消息发送超时
    case term_msg_calling_send_timeout = 20003

    //!< 服务器未分配转发地址
    case term_msg_calling_no_srv_addr = 20004

    //!< 握手超时
    case term_msg_calling_handshake_timeout = 20005

    //!< 设备端token校验失败
    case term_msg_calling_token_error = 20006

    //!< 监控通道数满
    case term_msg_calling_all_chn_busy = 20007

    //!< 超时断开
    case term_msg_calling_timeout_disconnect = 20008

    //!< 未找到目的id
    case term_msg_calling_no_find_dst_id = 20009

    //!< token校验出错
    case term_msg_calling_check_token_error = 20010

    //!< 设备已经禁用
    case term_msg_calling_dev_is_disable = 20011

    
    //物模型
    //!< 设备正在处理中
    case term_msg_gdm_handle_processing = 20100

    //!< 设备端校验叶子路径非法
    case term_msg_gdm_handle_leaf_path_error = 20101

    //!< 设备端解析JSON出错
    case term_msg_gdm_handle_parse_json_fail = 20102

    //!< 设备处理ACtion失败
    case term_msg_gdm_handle_fail = 20103

    //!< 设备未注册相应的ACtion回调函数
    case term_msg_gdm_handle_no_cb_registered = 20104

    //!< 设备不允许通过局域网修改内置可写对象
    case term_msg_gdm_handle_buildin_prowritable_error = 20105

    
    //
    case term_alloc_fail = 20200

    case term_param_invalid = 20201

    case term_term_unit_no_init = 20202

    
    //!< 在线消息handle错误，有可能是过期丢弃了
    case term_msg_onlinemsg_handle_invalid = 20213

    //!< 已回应handle值，不需重复发送
    case term_msg_onlinemsg_handle_repeat = 20214
}
```