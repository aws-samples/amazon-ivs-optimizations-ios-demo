//
//  Settings.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 27/05/2021.
//

import Foundation

struct Settings {
    static var shared = Settings()

    private let defaultURLString: String = "https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.DmumNckWFTqz.m3u8"
    private var defaultURL: URL {
        return URL(string: defaultURLString)!
    }

    var customURLString: String?
    private var customURL: URL? {
        return URL(string: customURLString ?? "")
    }

    var playbackURL: URL {
        return customURL ?? defaultURL
    }
}
