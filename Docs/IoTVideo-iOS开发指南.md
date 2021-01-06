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

**3. 使用临时访问设备授权获取 accessId 和 accessToken**

允许终端用户短时或一次性临时访问设备，详情参见 [终端用户临时访问设备授权](https://cloud.tencent.com/document/product/1131/42366)。

## 第三步：SDK初始化

### 1、初始化

在 `AppDelegate` 中的`application:didFinishLaunchingWithOptions:`调用如下初始化方法：

```swift
import IoTVideo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
      // 初始化
      IoTVideo.sharedInstance.setup(launchOptions: launchOptions)
      // 设置代理
      IoTVideo.sharedInstance.delegate = self
      // 设置日志等级
      IoTVideo.sharedInstance.logLevel = .DEBUG
      
    	...
  }
}

/// 实现IoTVideoDelegate协议
extension AppDelegate: IoTVideoDelegate {
    // SDK状态回调
  	func didUpdate(_ linkStatus: IVLinkStatus) {
       print("sdkLinkStatus: \(linkStatus.rawValue)")
    }
    
    // SDK日志输出
    func didOutputPrettyLogMessage(_ message: String) {
        print(message)
    }
}

```

### 2、注册

账号注册成功后可获取到 `accessId`，登录成功后可获取到 `accessToken `，调用sdk注册接口:

```swift
import IoTVideo

IoTVideo.sharedInstance.register(withAccessId: "********", accessToken: "********")
```
注册后请留意SDK状态回调：`-[IoTVideoDelegate didUpdateLinkStatus:]`,也可通过`-[IoTVideo linkStatus]`主动查询SDK状态, 当状态变为`IVLinkStatusOnline`即表示SDK成功上线。

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

绑定成功后，获取到订阅token, 需调用命令使IoTVideo SDK订阅该设备：

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
// 4.预连接，获取流媒体头信息【此步骤可跳过】
monitorPlayer.prepare() 
// 5.开始播放，启动推拉流、渲染模块
monitorPlayer.play()
// 6.开启/关闭语音对讲（只支持MonitorPlayer/LivePlayer）
monitorPlayer.startTalking()
monitorPlayer.stopTalking()
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

![](https://note.youdao.com/yws/api/group/108650997/file/905721786?method=download&inline=true&version=1&shareToken=40D9119DB53148FFAB19556DACCC79EE)



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

##### 2.读取属性

`path`为空字符串`""`则表示获取完整物模型

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

##### 3.设置属性

```swift
import IoTVideo.IVMessageMgr

// 设备ID的字符串
let deviceId = dev.deviceId
// 模型路径的字符串
let path = "ProWritable._logLevel"
// 模型参数的字符串
let json = "{\"setVal\":0}"

// 或
let path = "ProWritable._logLevel.setVal"
let json = "0" //代表整型
let json = "\"value\"" // 代表字符串

IVMessageMgr.sharedInstance.writeProperty(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here    
}
```

##### 4.执行动作

```swift
import IoTVideo.IVMessageMgr

let deviceId = dev.deviceId
let path = "Action.cameraOn"
let json = "{\"ctlVal\":1}"

IVMessageMgr.sharedInstance.takeAction(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here    
}
```

#### 5. 用户自定义属性


##### 5.1 新增用户自定义属性

 - 禁止使用"\_"开头，"_"为内置物模型使用（使用了会报错：8605）
 - 重复新增会直接覆盖已经存在的自定义用户物模型

```swift
import IoTVideo.IVMessageMgr

let deviceId = dev.deviceId
// 新增的用户属性
let subPath = "userPro1" 
let path = "ProUser." + subPath
let json = "{\"key\":\"value\"}"

IVMessageMgr.sharedInstance.addProperty(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here
}
```

##### 5.2 删除用户自定义属性

```swift
import IoTVideo.IVMessageMgr

let deviceId = dev.deviceId
let path = "ProUser.userPro1"

IVMessageMgr.sharedInstance.deleteProperty(ofDevice: deviceId, path: path) { (json, error) in
    // do something here
}
```

##### 5.3 修改用户物模型

与 3.设置属性 同一个API，注意 `path` 和 `json` 的细微差别
|        修改值        | 内容 | 可用示例 |
| :----------------: | :--------: | :--------: |
ProWritable  | 读写属性 | `path = ProWritable.xxx json = "{\"setVal\":\"value\"}"` <br> 或字符串：`path = Prowritable.xxx.setVal json = "\"value\""` <br> 
ProUser | 自定义用户属性| `path = ProWritable.xxx.val json = "{\"key\":\"value\"}"`
ProUser | 内 置 用 户 属性| `path = "ProUser._buildIn.val.xxx" json = "value" `

```swift
import IoTVideo.IVMessageMgr

let deviceId = dev.deviceId

// 1、用户自定义的ProUser属性 实例: 
// "testProUser":{"t":1600048390,"val":{"testKey":"testValue"}}

// path 必须拼接为 ProUser.xxx.val 
let path = "ProUser.testProUser.val" 
let json = "{\"testKey\":\"newTestValue\"}"

IVMessageMgr.sharedInstance.writeProperty(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here    
}

// 2、系统内置的ProUser属性 实例：
// "_buildIn":{"t":1599731880,"val":{"almEvtPushEna":0,"nickName":"testName"}

// path必须拼接为 ProUser._buildIn.val._xxx 
let path = "ProUser._buildIn.val.nickName"
let json = "\"newNickName\""

IVMessageMgr.sharedInstance.writeProperty(ofDevice: deviceId, path: path, json: json) { (json, error) in
    // do something here    
}
```

## 设备管理  IVDeviceMgr
#### 1、查询设备固件版本号
不通过物模型查询最新版本号，当设备离线时也可用
```swift
/// 查询设备新固件版本信息
/// @param deviceid 设备id
/// @param responseHandler 回调
open class func queryDeviceNewVersionWidthDevieId(_ deviceId: String, responseHandler: @escaping IVNetworkResponseHandler)

/// 查询设备新固件版本信息
/// @param deviceid 设备id
/// @param currentVersion 当前版本号 nil: 默认为当前版本号 当针对特定版本的升级时为必填
/// @param language 语言 nil：默认系统语言
/// @param responseHandler 回调
open class func queryDeviceNewVersionWidthDevieId(_ deviceid: String, currentVersion: String?, language: String?, responseHandler: @escaping
IVNetworkResponseHandler)
```

示例
```swift
import IoTVideo.IVDeviceMgr

IVDeviceMgr.queryDeviceNewVersionWidthDevieId("xxxx") { (json, error) in
    // do something here    
}


IVDeviceMgr.queryDeviceNewVersionWidthDevieId("xxxx", currentVersion:"1.0.0", language:"en") { (json, error) in
    // do something here    
}

json: 示例
{
"code": 0,
"msg": "Success",
"data": {
    "downUrl": "xxxxxxxxx", 
    "version": "xxxxxxxxx", //版本号
    "upgDescs": "xxxxxxxxx" //升级描述
    }
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
主要包含以下功能：
##### 基本信息

- 查询云存相关信息

##### 视频相关
- 查询存在云存的日期信息
- 获取回放文件列表
- 获取回放 m3u8 播放地址
#####  事件相关
- 获取事件列表
- 删除事件（可批量）

#### 接口详情
##### 1.查询设备的云存详细信息
- 1.1
```objc
/// 查询设备的云存详细信息
/// @param deviceId 设备id
/// @param responseHandler 回调
- (void)getServiceDetailInfoWithDeviceId:(NSString *)deviceId responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
- 1.2
```objc
/// 查询多通道设备的云存详细信息
/// @param deviceId 设备id
/// @param channel 视频流通道号。(对于存在多路视频流的设备，如NVR设备，与设备实际视频流通道号对应)。
/// @param responseHandler 回调
- (void)getServiceDetailInfoWithDeviceId:(NSString *)deviceId channel:(NSInteger)channel responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
- 返回结果：json 示例
```
{  
    "code":0,  
    "msg":"Success",  
    "data":{  
        "status":1,  
        "startTime":1606709335,  
        "endTime":1611979735,  
        "curOrderPkgType":1,  
        "curOrderStorageDays":3,  
        "curOrderStartTime":1606709335,  
        "curOrderEndTime":1606709335,  
        "playbackDays":3
    }  
}  
```
- 对应 data 结构

参数名称             |类型           |描述
---------------------|---------------|-----
status               |Integer        |云存服务状态。
startTime            |Integer        |云存服务开始时间。
endTime              |Integer        |云存服务失效时间。
curOrderPkgType      |Integer        |当前订单类型。
curOrderStorageDays  |Integer        |当前订单存储时长，单位天。
curOrderStartTime    |Integer        |当前订单开始时间。
curOrderEndTime      |Integer        |当前订单结束事件。
playbackStartTime    |Integer        |当前云存服务，支持检索回放文件的最早时间。<br> 这个时间点之前的云存文件不支持检索。

- 云存服务状态

值   | 描述                      
---  | -------------------       
 1   | 正常使用中。             
 2   | 待续费。设备云存服务已到期，但是历史云存数据未过期。续费后仍可查看这些历史数据。
 3   | 已过期。查询不到设备保存在云端的数据。
 
- 订单类型

值   | 描述                      
---  | -------------------       
 1   | 全时云存             
 2   | 事件云存
##### 2.查询存在云存的日期信息

```objc
/// 获取云存视频可播放日期信息
/// - 用于终端用户在云存页面中对云存服务时间内的日期进行标注，区分出是否有云存视频文件。
/// @param deviceId 设备id
/// @param timezone 相对于0时区的秒数，例如东八区28800
/// @param responseHandler 回调
- (void)getVideoDateListWithDeviceId:(NSString *)deviceId timezone:(NSInteger)timezone responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
返回结果：json 示例
```
{
    "code":0,
    "msg":"Success",
    "data":{
        "list":[
            1600653494
        ]
    }
}
```

##### 3. 获取回放文件列表
```objc
/// 获取回放文件列表
/// - 获取云存列表，用于对时间轴渲染
/// @param deviceId 设备id
/// @param startTime 开始UTC时间,单位秒
/// @param endTime 结束UTC时间,单位秒 超过一天只返回一天
/// @param responseHandler 回调
- (void)getVideoPlayListWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
返回结果：json 示例
```swift
{
    "msg":"Success",
    "code":0,
    "data":{
        "list":[
            {
                "start":1601285768,
                "end":1601285776
            },
            {
                "start":1601285780,
                "end":1601285800
            }
        ]
    },
}
```
##### 4.获取回放 m3u8 播放地址

```swift
/// 获取回放 m3u8 播放地址
/// @param deviceId 设备id
/// @param startTime 开始UTC时间,单位秒
/// @param endTime 结束UTC时间,单位秒 填 0 则默认播放到最新为止
/// @param responseHandler 回调
/// json： endflag boolean 播放结束标记， 表示此次播放是否把需要播放的文件播完，没有则需以返回的 endtime 为基准再次请求。false 表示未播放完，true 表示播放完成
- (void)getVideoPlayAddressWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTiem:(NSTimeInterval)endTime responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
返回结果：json 示例
```swift
{
    "code":0,
    "msg":"Success",
    "data":{
        "endTime":1601289368,
        "endflag":true,
        "startTime":1601285768,
        "url":"http://lcb.iotvideo.tencentcs.com/timeshift/live/00000101000e00fc000000000000000007000000b2860100/timeshift.m3u8?starttime=20200928173608&endtime=20200928183608"
    }
}
```
对应data 结构：
参数名称|类型   |描述
--------|-------|-----
url     |string |m3u8文件地址
startTime|int64 |此处播放m3u8文件播放开始时间
endTime |int64  |此次m3u8文件播放结束时间
endflag |boolean|播放结束标记， 表示此次请求结果的m3u8能否把需要播放的时间内的文件播完，<br> 不能则需以返回的 `endtime` 为基准再次请求。<br>`false` 表示未播放完，`true` 表示播放完成


##### 5.获取事件列表
```swift
/// 获取事件列表
///
/// @param deviceId 设备id
/// @param startTime 事件告警开始UTC时间, 一般为当天开始时间， 单位秒
/// @param endTime 事件告警结束UTC时间，获取更多应传入当前列表的最后一个事件的开始时间(事件列表按时间逆序排列)；
/// @param pageSize 本次最多查询多少条记录，取值范围 [1 - 50]
/// @param typeMasks 筛选指定类型的事件掩码数组：Array<UInt32>，
/// @param validCloudStorage 是否只返回有效云存期内的事件
/// @param responseHandler 回调 
/// @code
/// /// typeMask 过滤规则
/// /// bit 0-15 为 SDK内置 bit16 - 32为调用者可自定义类型 bit15 为标志有视频的事件即 0x8000
/// ///
/// /// 对于列表中每个掩码，单个掩码中每个bit按 或 规则来过滤，例如
/// /// almTypeMasks = [3]
/// /// 3 等于 bit0 | bit1， 此时获取到的事件为 包含bit0 或 bit1类型的事件
///
/// /// 对于列表中掩码之间，按 与 的规则来过滤， 例如
/// /// almTypeMasks = [1， 2]
/// /// 1 等于 bit0 ，2 等于 bit1， 此时获取到的事件为 同时包含bit0 和 bit1类型的事件
///
/// /// 加载更多
/// func getMoreEvents() {
///     let endTime = eventList.last?.startTime ?? currDate + 86400
///     IVVAS.shared.getEventList(withDeviceId: deviceID, startTime: currDate, endTime: endTime, pageSize: 50, filterTypeMask: 0) { [weak self](json, error) in
///         /* get more data here */
///     }
/// }
///
/// /// 下拉刷新
/// func refreshEvents() {
///     let endTime = currDate + 86400
///     IVVAS.shared.getEventList(withDeviceId: deviceID, startTime: currDate, endTime: endTime, pageSize: 50, filterTypeMask: 0) { [weak self](json, error) in
///         /* new data here */
///     }
/// }
/// @endcode
- (void)getEventListWithDeviceId:(NSString *)deviceId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime pageSize:(NSInteger)pageSize filterTypeMask:(NSArray<NSNumber *> * _Nullable)typeMasks validCloudStorage:(BOOL)validCloudStorage responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```
返回结果：json 示例
```
{
    "requestId":"xxxxxx",
    "code":0,
    "msg":"Success",
    "data":{
        "imgUrlPrefix":"xxxxx",
        "thumbUrlSuffix":"&xxxx",
        "list":[
            {
                "alarmId":"xxxx",
                "firstAlarmType":1,
                "alarmType":1,
                "startTime":1600653494,
                "endTime":1600653495,
                "imgUrlSuffix":"xxxxx"
            }
        ],
        "validStartTime":1111,
        "pageEnd":false
    }
}

// 图片下载地址为 imgUrl = imgUrlPrefix + imgUrlSuffix
// 缩略图下载地址为 thumbUrl = imgUrl + thumbUrlSuffix
```
对应 json 结构：

参数名称      |类型    |描述
--------------|--------|-----
alarmId       |string  |事件id
firstAlarmType|int64   |告警触发时的告警类型
alarmType     |int64   |告警有效时间内触发过的告警类型
startTime     |int64   |告警触发时间, utc时间，单位秒
endTime       |int64   |告警结束时间, utc时间，单位秒
imgUrlPrefix  |string  |告警图片下载地址前缀缀
imgUrlSuffix  |string  |告警图片下载地址后缀
thumbUrlSuffix|string  |告警图片缩略图下载地址后缀
validVideoStartTime|int64|云存未过期视频的开始时间，为0代表未查询到云存记录
pageEnd|bool| 为分页结束标志
##### 6. 事件删除
```swift
/// 事件删除
/// @param deviceId 设备id
/// @param eventIds 事件 id 数组
/// @param responseHandler 回调
- (void)deleteEventsWithDeviceId:(NSString *)deviceId eventIds:(NSArray<NSString *> *)eventIds responseHandler:(IVNetworkResponseHandler _Nullable)responseHandler;
```

具体使用示例请参考：demo 内`IJKMediaViewController.swift`

# 错误码

- 公共错误码

| 错误码区间分布 | 错误描述           |
| :------------: | ------------------ |
|  8000 - 8499   | Asrv错误           |
|  8500 - 8699   | Csrv错误(对接Asrv) |
|  8799 - 9999   | 预留错误           |
| 10000 - 10999  | 通用错误           |
| 11000 - 11999  | 产品/设备相关错误  |
| 12000 - 12999  | 用户相关错误       |
| 13000 - 13999  | 客户相关错误       |
| 14000 - 14999  | 云存相关错误       |
| 15000 - 15999  | UPG相关错误        |
| 16000 - 16999  | 帮助中心错误       |
| 17000 - 17999  | 第三方调用错误     |
| 20000 - 20999  | P2P错误            |
| 21000 - 21999  | iOS SDK错误        |
| 22000 - 22999  | Android SDK错误    |
| 23000 - 23999  | PC SDK错误         |
| 24000 - 24999  | DEV SDK错误        |


- 连接错误码

|         IVConnError          | 错误码 | 错误描述                             |
| :--------------------------: | :----: | ------------------------------------ |
| IVConnError_ExceedsMaxNumber | 21020  | 连接通道已达上限(MAX_CONNECTION_NUM) |
|    IVConnError_Duplicate     | 21021  | 连接通道已存在                       |
|  IVConnError_ConnectFailed   | 21022  | 建立连接失败                         |
|   IVConnError_Disconnected   | 21023  | 连接已断开/未连接                    |
| IVConnError_ExceedsMaxLength | 21024  | 数据长度超出上限(MAX_PKG_BYTES)      |
| IVConnError_NotAvailableNow  | 21025  | 当前连接暂不可用/SDK离线             |

- 播放器错误码

|            IVPlayerError             | 错误码 | 错误描述                         |
| :----------------------------------: | :----: | -------------------------------- |
|  IVPlayerError_NoRespondsToSelector  | 21030  | 方法选择器无响应、未实现协议方法 |
|    IVPlayerError_InvalidParameter    | 21031  | 参数错误                         |
|   IVPlayerError_PlaybackListEmpty    | 21032  | 录像列表为空                     |
|    IVPlayerError_PlaybackDataErr     | 21033  | 录像列表数据异常                 |
|   IVPlayerError_RecorderIsRunning    | 21034  | 正在录制                         |
| IVPlayerError_VideoResolutionChanged | 21035  | 视频分辨率已改变                 |
| IVPlayerError_EncoderNotAvailableNow | 21036  | 编码器暂不可用                   |
|   IVPlayerError_PlaybackListVerErr   | 21037  | 不支持的录像列表版本             |

-  消息管理错误码

|         IVMessageError          | 错误码 | 错误描述                        |
| :-----------------------------: | :----: | ------------------------------- |
|    IVMessageError_duplicate     | 21000  | 消息重复/正在发送               |
|    IVMessageError_sendFailed    | 21001  | 消息发送失败                    |
|     IVMessageError_timeout      | 21002  | 消息响应超时                    |
|  IVMessageError_GetGdmDataErr   | 21003  | 获取物模型失败                  |
|  IVMessageError_RcvGdmDataErr   | 21004  | 接收物模型失败                  |
|  IVMessageError_SendPassSrvErr  | 21005  | 透传数据给服务器失败            |
|  IVMessageError_SendPassDevErr  | 21006  | 透传数据给设备失败              |
| IVMessageError_NotFoundCallback | 21007  | 没有找到回调/已超时             |
| IVMessageError_ExceedsMaxLength | 21008  | 消息长度超出上限(MAX_DATA_SIZE) |

- P2P错误码

|                     TermErr                      | 错误码 | 错误描述                             |
| :----------------------------------------------: | :----: | ------------------------------------ |
|          TermErr_msg_send_peer_timeout           | 20001  | 消息发送给对方超时                   |
|            TermErr_msg_calling_hangup            | 20002  | 普通挂断消息                         |
|         TermErr_msg_calling_send_timeout         | 20003  | calling消息发送超时                  |
|         TermErr_msg_calling_no_srv_addr          | 20004  | 服务器未分配转发地址                 |
|      TermErr_msg_calling_handshake_timeout       | 20005  | 握手超时                             |
|         TermErr_msg_calling_token_error          | 20006  | 设备端token校验失败                  |
|         TermErr_msg_calling_all_chn_busy         | 20007  | 监控通道数满                         |
|      TermErr_msg_calling_timeout_disconnect      | 20008  | 超时断开                             |
|        TermErr_msg_calling_no_find_dst_id        | 20009  | 未找到目的id                         |
|      TermErr_msg_calling_check_token_error       | 20010  | token校验出错                        |
|        TermErr_msg_calling_dev_is_disable        | 20011  | 设备已经禁用                         |
|        TermErr_msg_calling_duplicate_call        | 20012  | 重复呼叫                             |
|        TermErr_msg_gdm_handle_processing         | 20100  | 设备正在处理中                       |
|      TermErr_msg_gdm_handle_leaf_path_error      | 20101  | 设备端校验叶子路径非法               |
|      TermErr_msg_gdm_handle_parse_json_fail      | 20102  | 设备端解析JSON出错                   |
|           TermErr_msg_gdm_handle_fail            | 20103  | 设备处理ACtion失败                   |
|     TermErr_msg_gdm_handle_no_cb_registered      | 20104  | 设备未注册相应的ACtion回调函数       |
| TermErr_msg_gdm_handle_buildin_prowritable_error | 20105  | 设备不允许通过局域网修改内置可写对象 |


- 常见服务器错误码

|              ASrvErr              | 错误码 | 错误描述                         |
| :-------------------------------: | :----: | -------------------------------- |
|         ASrv_dst_offline          |  8000  | 目标离线                         |
|         ASrv_dst_notexsit         |  8002  | 目标不存在                       |
|      ASrv_dst_error_relation      |  8003  | 非法关系链                       |
|  ASrv_binderror_dev_usr_has_bind  |  8022  | 设备已经绑定此用户               |
| ASrv_binderror_dev_has_bind_other |  8023  | 设备已经绑定其他用户             |
| ASrv_binderror_customer_diffrent  |  8024  | 设备的客户ID与用户的客户ID不一致 |


# 常见问题Q&A

*提示1：为方便定位问题，开发阶段建议启用SDK日志输出，设置方法参考 `【快速开始】->【第三步：SDK初始化】->【1、初始化】`*
*提示2：日志中形如 {…17} 表示此位置包含了17次同类型日志信息。例如：`18:17:15.274 [SDK] {...17} rcv_au_data CH1 alen:519 apts:839000000`表示最近收到了17个音频数据包，并且最后一次数据为`alen:519 apts:839000000`*


#### 一、SDK环境异常

##### 1. 如何判断APP网络是否正常？
```
日志输出: 
12:03:01.502 [SDK] [I]💙 ====当前网络状态为WiFi(IV-TEST-5G)=======

日志解读: 
当前手机连接了名为 “IV-TEST-5G”的Wi-Fi网络（该网络可正常上网）
```

##### 2. 如何判断SDK是否已注册？
```
日志输出：
12:03:01.902 [SDK] [I]💙 IoTVideoSDK registered ✅

日志解读：
已调用SDK注册接口，见接口`-[IoTVideo registerWithAccessId:accessToken:]`
```

##### 3. 如何判断SDK是否可以正常使用？
```
日志输出：
12:03:02.263 [SDK] [I]💙 IoTVideoSDK 🟩SDK在线(1)

日志解读：
收到`IoTVideo.linkStatus`更新通知
	- 在线：可正常使用
	- 离线：请检查网络，或尝试注册SDK
	- Token失败：尝试重新注册SDK
	- 账号被踢飞：尝试重新注册SDK

提示：可通过`-[IoTVideo linkStatus]`主动查询，也可通过`-[IoTVideoDelegate didUpdateLinkStatus:]`监听
```

##### 4. 如何判断设备是否在线？
```
日志输出：
16:14:42.086 [SDK] [I]💙 rcv_gdm_data_callback msgid:0 tid:031400005f1683ac63ffe31efc47573e type:2 path:ProReadonly._online json:{"stVal":0,"t":1609229681} ok

日志解读：
收到`ProReadonly._online`更新通知
	- stVal:0 离线
	- stVal:1 在线
	- stVal:2 休眠

提示：可通过`-[IVMessageMgr readPropertyOfDevice:path:completionHandler:]`主动查询（path取"ProReadonly._online"）
```

#### 二、 监控异常
*提示1: 为快速定位监控相关问题，请知悉播放器的四大阶段及对应步骤的日志信息。如下所示：*
*提示2: `*au*`为音频相关，`*vi*`为视频相关*
*提示3: pts单位为微秒，由设备端在回调函数中填入，在APP端可见步骤⑦⑧⑨中的pts字段*
*提示4: SDK提供保存关键步骤的音视频数据到沙盒的功能，便于校验数据正确性，默认关闭，详见`+[IVPlayer debugMode]`*

(1) 连接阶段：
```
①创建播放器
12:13:43.637 [SDK] IVMonitorPlayer(0x115b41560) init 031400005f1683ac63ffe31efc47573e_0:1 
...
②建立连接
12:13:44.001 [SDK] async play IVMonitorPlayer(0x115b41560) 031400005f1683ac63ffe31efc47573e_0:1 L195
12:13:44.004 [SDK] 建立连接ing...  IVMonitorPlayer(0x115b41560) type 1, action 1, seek:0 031400005f1683ac63ffe31efc47573e_0:1 
...
③连接成功
12:13:46.924 [SDK] [I]💙 建立连接成功(CH1) IVMonitorPlayer(0x115b41560) 031400005f1683ac63ffe31efc47573e_0:1 
```

(2) 初始化阶段：
```
④收到音视频信息头
12:13:47.473 [SDK] [I]💙 CH1 IVMonitorPlayer(0x115b41560) rcv AVHeader at:4 am:0 ac:2 abw:16 ar:8000 aspf:1024 vt:5 vr:15 vw:640 vh:360  
...
⑤注册编解码器
12:13:47.016 [SDK] CH1 AMR Enc register succ 
12:13:47.515 [SDK] CH1 AAC Dec register ch:1 sr:8000 
12:13:47.559 [SDK] CH1 IVH265Dec register end 
...
⑥启动渲染器
12:13:47.874 [SDK] CH1 start_au_render:e 
12:13:47.500 [SDK] CH1 start_vi_render W1920xH1080
```

(3) 解码渲染阶段：
```
⑦收到音视频数据包
12:13:50.227 [SDK] rcv_vi_data CH1 vpts:839000000 vlen:9519
12:13:50.228 [SDK] rcv_au_data CH1 apts:840338773 diff:840338773 alen:270
...
⑧解码数据包
12:13:50.231 [SDK] AAC Dec CH1 S:2048 pts:840338773
12:13:50.272 [SDK] H265 Dec CH1 header:640x360 pic:640x360 pts:839000000
...
⑨渲染音视频帧
12:13:50.240 [SDK] getAudioFrame CH1 ret:0 pts:840349523 diff:840349523 size:172
12:13:50.311 [SDK] getVideoFrame CH1 ret:0 pts:839000000 diff:839000000
```

(4) 断开阶段：
```
⑩断开连接
12:14:31.110 [SDK] CH1 async stop IVMonitorPlayer(0x115b41560) 031400005f1683ac63ffe31efc47573e_0:1
12:14:31.118 [SDK] 断开连接ing... IVMonitorPlayer(0x115b41560) 031400005f1683ac63ffe31efc47573e_0:1 
...
⑪关闭编解码器
12:14:31.193 [SDK] CH1 AMR Enc unregister 
12:14:31.193 [SDK] CH1 AMR Enc dealloc 
12:14:31.221 [SDK] CH1 AAC Dec unregister 
12:14:31.221 [SDK] CH1 AAC Dec dealloc 
12:14:31.222 [SDK] CH1 IVH265Dec unregister 
12:14:31.222 [SDK] CH1 IVH265Dec dealloc 
... 
⑫关闭渲染器
12:14:31.123 [SDK] CH1 stop_au_render:e 
12:14:31.179 [SDK] CH1 stop_vi_render 
...
⑬释放播放器
12:14:31.234 [SDK] 断开连接成功 IVMonitorPlayer(0x115b41560) 031400005f1683ac63ffe31efc47573e_0:1 
12:14:31.623 [SDK] IVMonitorPlayer(0x115b41560) dealloc 031400005f1683ac63ffe31efc47573e_0:1 
12:14:31.624 [SDK] CH1 IVAudioUnit dealloc 
12:14:31.629 [SDK] CH1 IVVideoRender dealloc 
```

**Q：监控不出图？无声音？**

请按顺序搜索步骤①～⑨中日志信息的关键字，确认APP处于流程中哪个步骤：
```
1. 若①～③过程未完成，属于连接未成功：
    1）设备网络不通，需切换设备网络；
    2）手机网络不通，需切换手机网络；
    3）设备无响应，需排查设备日志（常见任务超时、任务阻塞、死循环、设备离线）；
2. 若步骤④未完成，请检查设备是否有发送该音视频信息头；
3. 若⑤～⑥未完成，请确认步骤④中设备传给APP的音视频信息头无误，否则会导致步骤⑤解码器和步骤⑥渲染器初始化错误；
4. 若⑦～⑨过程无日志或未持续输出日志，请确认设备是否未发送数据或已停止发送数据；
5. 请确保正确设置IVPlayer.videoView的约束；
6. 其他情况请保留完整APP日志和设备日志，并联系我们；
```

**Q: 监控出图慢？**

请按以下顺序排查问题：
```
1. 若①～③过程耗时大于1秒，属于连接慢：
    1）设备网络慢，需切换设备网络；
    2）手机网络慢，需切换手机网络；
    3）设备响应慢，需排查设备日志（常见CPU负载高、任务阻塞）；
2. 若③～⑦过程耗时大于1秒，属于收到数据慢：
    1）设备网络不稳定，可尝试切换设备网络；
    2）手机网络不稳定，可尝试切换手机网络；
    3）设备响应慢，需排查设备日志（常见编码慢、回调慢、CPU负载高、任务阻塞）
3. 若⑦～⑨过程耗时大于1秒，属于解码渲染慢：
    1）请确认步骤④中设备传给APP的音视频信息头无误，否则会导致步骤⑤解码器和步骤⑥渲染器初始化错误
    2）请确认设备发送的数据是可播放的（发送前记录到本地，用vlc或ffplay等验证）
    3）请确认步骤⑦收到的音视频数据包与设备端发送的一致，否则应该是数据丢包了 
    4）请确认音视频帧pts正确，且同一时间音视频pts不能相差超过1秒，否则会导致音视频同步异常，进而导致步骤⑨渲染异常, 
    5）请确认APP解码成功，如上面步骤⑧的日志
4. 其他情况请保留完整APP日志和设备日志，并联系我们。
```

**Q: 监控延迟大？卡顿？**

请按以下思路排查问题：
```
1. 请检查网络是否流畅；
2. 请确认音视频帧pts正确，且同一时间音视频pts不能相差超过1秒，否则会导致音视频同步异常，进而导致步骤⑨渲染异常；
3. 查看步骤⑦的音视频pts是否连续，若不连续则表明有丢包，需检查设备发送情况和网络环境；
4. 日志搜索"jitter stalled"可查看网络抖动情况。其中"tolerance"越大表明网络抖动越厉害，"delay"也会越大，若频繁输出此信息，表明网络不佳, 可尝试切换手机或设备网络；
5. 从APP端日志估算⑦～⑨解码渲染阶段耗时，以上面的日志为例：
    注意：并非每个数据包都会输出日志，估算时可认为相近的pts是同一个数据包，例如839123456和839000000是相近的，因为他们仅相差0.123456秒

    12:13:50.227 收到了 pts为839000000 的视频包
    12:13:50.272 解码出 pts为839000000 的视频帧
    12:13:50.311 将渲染 pts为839000000 的视频帧

    耗时为 12:13:50.311 - 12:13:50.227 ≈ 0.084秒，记为Td

    1) 若Td一直很小，表明APP端处理基本不耗时，延时原因可能出在网络或者设备编码速度上；
    2) 若Td较大或忽大忽小：表明网络不佳，可尝试切换手机或设备网络；
```

**Q: 音视频不同步**
```
请确认音视频帧pts正确，且同一时间音视频pts不能相差超过1秒，否则会导致音视频同步异常，进而导致步骤⑨渲染异常；
```
