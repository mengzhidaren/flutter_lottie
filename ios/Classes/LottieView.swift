import UIKit
import Flutter
import Lottie

public class LottieView : NSObject, FlutterPlatformView {
    let frame : CGRect
    let viewId : Int64
    
    var animationView: AnimationView!
    var testStream : TestStreamHandler?
    var providers : [AnyValueProvider]
    var registrarInstance : FlutterPluginRegistrar
    
    var loopMode: LottieLoopMode!
    var onCompletion: LottieCompletionBlock!
    
    init(_ frame: CGRect, viewId: Int64, args: Any?, registrarInstance : FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.registrarInstance = registrarInstance
        self.providers = []
        
        super.init()
        
        self.create(args: args)
    }
    
    func create(args: Any?) {
    
        let channel : FlutterMethodChannel = FlutterMethodChannel.init(
            name: "convictiontech/flutter_lottie_" + String(viewId),
            binaryMessenger: self.registrarInstance.messenger())
        let handler = methodCall;
        channel.setMethodCallHandler(handler)
        
        let testChannel = FlutterEventChannel(name: "convictiontech/flutter_lottie_stream_playfinish_"  + String(viewId), binaryMessenger: self.registrarInstance.messenger())
        self.testStream  = TestStreamHandler()
        testChannel.setStreamHandler(testStream as? FlutterStreamHandler & NSObjectProtocol)
        
        if let argsDict = args as? Dictionary<String, Any> {
            let url = argsDict["url"] as? String ?? nil;
            let filePath = argsDict["filePath"] as? String ?? nil;
            let loop = argsDict["loop"] as? Bool ?? false
            let reverse = argsDict["reverse"] as? Bool ?? false
            let autoPlay = argsDict["autoPlay"] as? Bool ?? false
            
            if loop {
                self.loopMode = .loop
            } else if reverse {
                self.loopMode = .autoReverse
            } else {
                self.loopMode = .playOnce
            }
            
            self.onCompletion = completionBlock
            
            if url != nil {
                //TODO: figure out imageProvider
                let jsonURL = URL(string: url!)!
                self.animationView = AnimationView(
                    url: jsonURL,
                    imageProvider: DownloadImageProvider(baseUrl:   jsonURL.deletingLastPathComponent()),
                    closure: {bool in
                        if autoPlay {
                            self.animationView.play(completion: self.completionBlock)
                        }
                })
            }
            
            if filePath != nil {
                print("THIS IS THE ID " + String(viewId) + " " + filePath!)
                let key = self.registrarInstance.lookupKey(forAsset: filePath!)
                let path = Bundle.main.path(forResource: key, ofType: nil)
                self.animationView = AnimationView(filePath: path!)
                // URL loaded animations need to autoplay after they're loaded.
                if autoPlay {
                    self.animationView.play(completion: completionBlock)
                }
            }
            self.animationView.loopMode = self.loopMode
        }
        
    }
    
    public func view() -> UIView {
        return animationView!
    }
    
    public func completionBlock(animationFinished : Bool) -> Void {
        if let ev : FlutterEventSink = self.testStream!.event {
            ev(animationFinished)
        }
    }
    
    
    func methodCall( call : FlutterMethodCall, result: FlutterResult ) {
        var props : Dictionary<String, Any>  = [String: Any]()
        
        if let args = call.arguments as? Dictionary<String, Any> {
            props = args
        }
        
        if call.method == "play" {
            self.animationView.currentProgress = 0
            self.animationView.play(completion: completionBlock);
        }
        
        if call.method == "resume" {
            self.animationView.play(completion: completionBlock);
        }
        
        if call.method == "playWithProgress" {
            let toProgress = props["toProgress"] as! CGFloat;
            if let fromProgress = props["fromProgress"] as? CGFloat {
                self.animationView.play(fromProgress: fromProgress,
                                        toProgress: toProgress,
                                        loopMode: self.loopMode,
                                        completion: self.completionBlock)
                    
            } else {
                self.animationView?.play(fromProgress: 0, toProgress: toProgress, completion: completionBlock);
            }
        }
        
        
        if call.method == "playWithFrames" {
            let toFrame = props["toFrame"] as! CGFloat;
            if let fromFrame = props["fromFrame"] as? CGFloat {
                self.animationView.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: self.loopMode, completion: self.completionBlock)
            } else {
                self.animationView.play(fromFrame: 0, toFrame: toFrame, loopMode: self.loopMode, completion: completionBlock)
            }
        }
        
        if call.method == "stop" {
            self.animationView.stop();
        }
        
        if call.method == "pause" {
            self.animationView.pause();
        }
        
        if call.method == "setAnimationSpeed" {
            self.animationView.animationSpeed = props["speed"] as! CGFloat
        }
        
        if call.method == "setLoopAnimation" {
            let isLoop = props["loop"] as! Bool
            if isLoop {
                self.animationView.loopMode = .loop
            } else {
                self.animationView.loopMode = .playOnce
            }
        }
        
        if call.method == "setAutoReverseAnimation" {
            let isReverse = props["reverse"] as! Bool
            if isReverse {
                self.animationView.loopMode = .autoReverse
            } else {
                self.animationView.loopMode = .playOnce
            }
        }
        
        if call.method == "setAnimationProgress" {
            self.animationView.currentProgress = props["progress"] as! CGFloat
        }
        
        if call.method == "setProgressWithFrame" {
            let frame = props["frame"] as! CGFloat
            self.animationView.currentFrame = frame
        }
        
        if call.method == "isAnimationPlaying" {
            let isAnimationPlaying = self.animationView.isAnimationPlaying
            result(isAnimationPlaying)
        }
        
        if call.method == "getAnimationDuration" {
            let animationDuration = self.animationView.animation?.duration
            result(animationDuration)
        }
        
        if call.method == "getAnimationProgress" {
            let animationProgress = self.animationView.currentProgress
            result(animationProgress)
        }
        
        if call.method == "getAnimationSpeed" {
            let animationSpeed = self.animationView.animationSpeed
            result(animationSpeed)
        }
        
        if call.method == "getLoopAnimation" {
            switch self.animationView.loopMode {
            case .loop: result(true)
            default: result(false)
            }
        }
        
        if call.method == "getAutoReverseAnimation" {
            switch self.animationView.loopMode {
            case .autoReverse: result(true)
            default: result(false)
            }
        }
        
        if call.method == "setValue" {
            let value = props["value"] as! String;
            let keyPath = props["keyPath"] as! String;
            if let type = props["type"] as? String {
                setValue(type: type, value: value, keyPath: keyPath)
            }
        }
    }
    
    func setValue(type: String, value: String, keyPath: String) -> Void {
        switch type {
        case "ColorValue":
            let i = UInt32(value.dropFirst(2), radix: 16)
            let color: CGColor = hexToColor(hex8: i!);
            self.providers.append(ColorDelegate(color: color))
            self.animationView.setValueProvider(self.providers.last!,
                                                keypath: AnimationKeypath(keypath: keyPath + ".Color"))
            break;
        case "OpacityValue":
            if let n = NumberFormatter().number(from: value) {
                let f = CGFloat(truncating: n)
                self.providers.append(NumberDelegate(number: f))
                self.animationView.setValueProvider(self.providers.last!,
                                                    keypath: AnimationKeypath(keypath: keyPath + ".Opacity"))
            }
            break;
        default:
            break;
        }
    }
    
}

class DownloadImageProvider: AnimationImageProvider {
    let baseUrl:URL
    init(baseUrl:URL) {
        self.baseUrl = baseUrl
    }
    
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        let imageURL = baseUrl
            .appendingPathComponent(asset.directory)
            .appendingPathComponent(asset.name)
        guard let data = try? Data(contentsOf: imageURL) else {
            print("Problem downloading \(imageURL)")
            return nil
        }
        return UIImage(data: data)?.cgImage
    }
    
}
