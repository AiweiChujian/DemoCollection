//
//  LottieDetailViewController.swift
//  LottieDemo
//
//  Created by Aiwei on 2023/2/21.
//

import UIKit
import Lottie
import SnapKit
import EasyObserve

struct LottieConfig {
    var playState = PlayState.play
    var contentMode = ContentMode.fit
    var loopMode = LoopModel.loop
}

extension LottieConfig {
    enum PlayState: Int {
        case play, pause, stop
    }
    
    enum ContentMode: Int {
        case fit, fill, scale
        var lottieReference: UIView.ContentMode {
            switch self {
            case .fit:
                return .scaleAspectFit
            case .fill:
                return .scaleAspectFill
            case .scale:
                return .scaleToFill
            }
        }
    }
    
    enum LoopModel: Int {
        case loop, once, reverse
        
        var lottieReference: LottieLoopMode {
            switch self {
            case .loop:
                return .loop
            case .once:
                return .playOnce
            case .reverse:
                return .autoReverse
            }
        }
    }
}

class LottieDetailViewController: UIViewController, EasyObserve {
    var lottieFileName: String = "test"
    
    @Observable private var config = LottieConfig()
    
    private lazy var animationView: LottieAnimationView = {
        let temp = LottieAnimationView()
        temp.backgroundColor = .gray
        temp.animation = LottieAnimation.named(lottieFileName)
        temp.backgroundBehavior = .pauseAndRestore
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = lottieFileName
        setupSubviews()
        bindSubviews()
    }
    
    @IBOutlet weak var playStateSegment: UISegmentedControl!
    @IBOutlet weak var contentModeSegment: UISegmentedControl!
    @IBOutlet weak var loopModeSegment: UISegmentedControl!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    
    private func setupSubviews() {
        view.backgroundColor = .white
        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(120)
            make.width.height.equalTo(350)
        }
    }
    
    private lazy var dlHolder: CADisplayLinkHolder = .init {[unowned self] _ in
        progressSlider.value = Float(animationView.realtimeAnimationProgress)
    }
    
    private func bindSubviews() {
        dlHolder.displayLink.add(to: .main, forMode: .common)
        ez.observingTable += $config.observe(subscriber: {[unowned self] value, change, option in
            animationView.loopMode = value.loopMode.lottieReference
            animationView.contentMode = value.contentMode.lottieReference
            playStateSegment.selectedSegmentIndex = value.playState.rawValue
            contentModeSegment.selectedSegmentIndex = value.contentMode.rawValue
            loopModeSegment.selectedSegmentIndex = value.loopMode.rawValue
            switch value.playState {
            case .play:
                animationView.play()
            case .pause:
                animationView.pause()
            case .stop:
                animationView.stop()
            }
            let isPlaying = value.playState == .play
            progressSlider.isUserInteractionEnabled = !isPlaying
            if isPlaying {
                dlHolder.displayLink.isPaused = false
            } else {
                dlHolder.displayLink.isPaused = true
            }
        })
    }

    @IBAction func playStateChanged(_ sender: UISegmentedControl) {
        guard let state = LottieConfig.PlayState(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        config.playState = state
    }
    
    @IBAction func contentModeChanged(_ sender: UISegmentedControl) {
        guard let mode = LottieConfig.ContentMode(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        config.contentMode = mode
    }
    
    @IBAction func loopModeChanged(_ sender: UISegmentedControl) {
        guard let mode = LottieConfig.LoopModel(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        config.loopMode = mode
    }
    
    @IBAction func progressChanged(_ sender: UISlider) {
        animationView.currentProgress = CGFloat(sender.value)
    }
}
