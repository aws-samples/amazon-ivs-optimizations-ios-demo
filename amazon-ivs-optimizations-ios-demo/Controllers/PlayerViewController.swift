//
//  PlayerViewController.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 05/05/2021.
//

import UIKit
import AmazonIVSPlayer

class PlayerViewController: UIViewController, InfoPillsDelegate {

    // MARK: IBOutlet

    @IBOutlet weak var playerView: IVSPlayerView!
    @IBOutlet weak var infoViewsStackView: InfoPillsStackView!
    @IBOutlet weak var infoViewsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bufferIndicator: UIActivityIndicatorView!

    var playbackURL: URL?
    var technique: OptimizationTechnique = .RebufferToLive
    var ttv: Float? {
        didSet {
            infoViewsStackView.updateTTVLabel(to: ttv ?? 0.0)
        }
    }

    private var didSeekForward: Bool = false
    private var startTime: DispatchTime?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startTime = DispatchTime.now()

        switch technique {
        case .RebufferToLive, .CatchUpToLive:
            if let url = playbackURL {
                loadStream(from: url)
            }
            playerView?.player = player

        case .PreCaching:
            player?.delegate = self
            playerView?.player = player
            startPlayback()

        default: break
        }

        infoViewsStackViewHeightConstraint.constant = 250
        infoViewsStackView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if technique == .PreCaching {
            infoViewsStackView.setup()
        }

        infoViewsStackView.startStatsUpdate()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pausePlayback()
        player?.delegate = nil
        player = nil
    }

    // MARK: Application Lifecycle

    private var didPauseOnBackground = false

    @objc private func applicationDidEnterBackground(notification: Notification) {
        if player?.state == .playing || player?.state == .buffering {
            didPauseOnBackground = true
            pausePlayback()
        } else {
            didPauseOnBackground = false
        }
    }

    @objc private func applicationDidBecomeActive(notification: Notification) {
        if didPauseOnBackground && player?.error == nil {
            startPlayback()
            didPauseOnBackground = false
        }
    }

    private func addApplicationLifecycleObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func removeApplicationLifecycleObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // MARK: - IVSPlayer

    var player: IVSPlayer? {
        didSet {
            if oldValue != nil {
                removeApplicationLifecycleObservers()
            }
            playerView?.player = player

            if player != nil {
                addApplicationLifecycleObservers()
            }
        }
    }

    private func loadStream(from url: URL) {
        let player: IVSPlayer
        if let existingPlayer = self.player {
            player = existingPlayer
        } else {
            player = IVSPlayer()
            player.delegate = self
            self.player = player
        }
        player.load(url)
    }

    // MARK: Playback Control

    private func startPlayback() {
        player?.play()
        player?.muted = false
    }

    private func pausePlayback() {
        player?.pause()
        player?.muted = true
    }

    private func setTTV() {
        if ttv == nil {
            let endTime = DispatchTime.now()
            if let startTime = startTime {
                ttv = Float((endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000)
            }
        }
    }

    // MARK: IBAction

    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension PlayerViewController: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {

        switch state {
        case .ready:
            bufferIndicator.stopAnimating()
            infoViewsStackView.setup()
            player.play()

        case .playing:
            bufferIndicator.stopAnimating()
            setTTV()

        case .buffering:
            bufferIndicator.startAnimating()

        default:
            bufferIndicator.stopAnimating()
        }
    }
}
