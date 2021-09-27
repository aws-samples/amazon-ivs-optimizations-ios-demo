//
//  HomeViewController.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 05/05/2021.
//

import UIKit
import AmazonIVSPlayer

class HomeViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: IBOutlet

    @IBOutlet weak var buttonsStackView: UIStackView!

    private var presentTechnique: OptimizationTechnique = .RebufferToLive
    private var preCachedPlayer: IVSPlayer?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        for button in buttonsStackView.subviews {
            button.layer.cornerRadius = 20
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPrecachedStream(from: Settings.shared.playbackURL)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayerView",
           let playerVC = segue.destination as? PlayerViewController {
            playerVC.technique = presentTechnique
            playerVC.playbackURL = Settings.shared.playbackURL

            // MARK: - Optimization demo: Pre-caching
            if presentTechnique == .PreCaching {
                playerVC.player = preCachedPlayer
            }
        }
        preCachedPlayer = nil
    }

    private func loadPrecachedStream(from url: URL) {
        if self.preCachedPlayer == nil {
            self.preCachedPlayer = IVSPlayer()
            self.preCachedPlayer?.muted = true
        }
        self.preCachedPlayer?.load(url)
    }

    private func showcase(technique: OptimizationTechnique) {
        presentTechnique = technique
        performSegue(withIdentifier: "toPlayerView", sender: self)
    }

    // MARK: IBAction

    @IBAction func didTapRebufferToLive(_ sender: Any) {
        showcase(technique: .RebufferToLive)
    }

    @IBAction func didTapCatchUpToLive(_ sender: Any) {
        showcase(technique: .CatchUpToLive)
    }

    @IBAction func didTapPreCaching(_ sender: Any) {
        showcase(technique: .PreCaching)
    }
}
