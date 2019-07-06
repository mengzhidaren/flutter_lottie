//
//  FlutterEvent.swift
//  flutter_lottie
//
//  Created by Eric Martineau on 7/5/19.
//

import Foundation

// A stream handler implementation that expects only a single subscriber, and that supports replaying events.
public class LottieStreamHandler : FlutterStreamHandler {
    private var playback: [Any] = []
    var sink : FlutterEventSink!
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        playback.forEach { self.sink($0) }
        playback.removeAll()
        return nil;
    }
    
    public func append(_ any: Any) {
        if let sink = self.sink {
            sink(any)
        } else {
            // If there isn't any subscriber yet, then cache any incoming events
            // that can be played back once we do have a subscriber
            playback.append(any)
        }
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil;
    }
}
