//
//  InfoPillsStackView.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 06/05/2021.
//

import UIKit
import AmazonIVSPlayer

protocol InfoPillsDelegate {
    var player: IVSPlayer? { get }
    var technique: OptimizationTechnique { get }
    var ttv: Float? { get }
}

class InfoPillsStackView: UIStackView {

    var delegate: InfoPillsDelegate? {
        didSet {
            createInfoPills()
        }
    }

    func startStatsUpdate() {
        updateStats()
    }

    private func createInfoPills() {
        var infoViews: [InfoView] = []
        for _ in 1...5 {
            infoViews.append(InfoView.fromNib())
        }

        DispatchQueue.main.async { [weak self] in
            for infoView in infoViews {
                self?.addArrangedSubview(infoView)
                self?.setNeedsLayout()
            }
        }
    }

    func setup() {
        guard let playerInfo = subviews[0] as? InfoView else { return }
        playerInfo.fill(
            with: "Player",
            value: "Amazon IVS \(delegate?.player?.version ?? "-")",
            prefferedTitleWidth: 55
        )

        updateTTVLabel(to: nil)

        switch delegate?.technique {
        case .RebufferToLive:
            let info = subviews[2] as! InfoView
            info.fill(
                with: "Rebuffer to Live",
                value: "true",
                prefferedTitleWidth: 130
            )
        case .CatchUpToLive:
            updateSpeedLabel(to: nil)
        case .PreCaching:
            let info = subviews[2] as! InfoView
            info.fill(
                with: "Pre-cached",
                value: "true",
                prefferedTitleWidth: 100
            )
        case .none:
            break
        }

        updateBufferSizeLabel(to: nil)
        updateLatencyLabel(to: nil)

        layoutIfNeeded()
    }

    private func updateStats() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let player = self?.delegate?.player {
                let bufferSize: TimeInterval = (player.buffered - player.position).seconds

                // MARK: - Optimization demo: Catch up to Live
                if self?.delegate?.technique == .CatchUpToLive {
                    // Resume normal playback when reaching this buffer size:
                    let targetBufferDuration: TimeInterval = 2
                    // This is the value that will trigger the catch-up logic:
                    let maxAllowedBuffer: TimeInterval = 5

                    switch bufferSize {
                    case 0 ..< targetBufferDuration:
                        // Resume normal playback
                        player.playbackRate = 1.0

                    case targetBufferDuration ..< maxAllowedBuffer:
                        // If catching up, make sure to back off to a lower rate
                        if player.playbackRate > 1.01 {
                            player.playbackRate = 1.01
                        }

                    case maxAllowedBuffer ..< TimeInterval.infinity:
                        // For every 3s of additional buffer, increase rate by 0.01x, with a max rate of 1.05x
                        let maxRate = 1.05
                        let speedUpRatio = 0.01
                        let bufferInterval: TimeInterval = 3

                        let baseRate = 1.01
                        let extraBuffer = bufferSize - maxAllowedBuffer
                        let extraRate = extraBuffer / bufferInterval * speedUpRatio

                        player.playbackRate = Float(min(baseRate + extraRate, maxRate))

                    default:
                        player.playbackRate = 1.0
                    }

                    self?.updateSpeedLabel(to: player.playbackRate)
                }

                self?.updateBufferSizeLabel(to: bufferSize)
                self?.updateLatencyLabel(to: player.liveLatency.seconds)
            }

            self?.updateStats()
        }
    }

    func updateTTVLabel(to value: Float?) {
        let TTVInfo = subviews[1] as! InfoView
        TTVInfo.fill(
            with: "Time to video",
            value: value != nil ? "\(String(format: "%0.0f", value!))ms" : "-",
            prefferedTitleWidth: 110
        )
    }

    private func updateSpeedLabel(to value: Float?) {
        let info = subviews[2] as! InfoView
        info.fill(
            with: "Player speed",
            value: value != nil ? "\(String(format: "%0.4f", value!))x" : "-",
            prefferedTitleWidth: 105
        )
    }

    private func updateBufferSizeLabel(to value: Double?) {
        let bufferInfo = subviews[3] as! InfoView
        bufferInfo.fill(
            with: "Buffer size",
            value: value != nil ? "\(String(format: "%0.2f", value!))s" : "-",
            prefferedTitleWidth: 90
        )
    }

    private func updateLatencyLabel(to value: Double?) {
        let latencyInfo = subviews[4] as! InfoView
        latencyInfo.fill(
            with: "Latency",
            value: value != nil ? "\(String(format: "%0.2f", value!))s" : "-",
            backgroundColor: value != nil ? UIColor.color(for: value!) : UIColor(hex: "#5AAD43"),
            isLatencyPill: true,
            prefferedTitleWidth: 70
        )
    }
}
