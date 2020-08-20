//
//  VolumeViewController.swift
//  AudioControllerFFMPEG
//
//  Created by Viet Hoang on 7/14/20.
//  Copyright © 2020 Viet Hoang. All rights reserved.
//

import UIKit
import AVFoundation
import ICGVideoTrimmer


class VolumeViewController: UIViewController {
    
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    @IBOutlet weak var screen: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    var delegate: TransformDataDelegate!
    var player = AVAudioPlayer()
    var videoPlayer = AVPlayer()
    var url: URL!
    
    var volume: Float!
    var volumeRate: Float!
    var steps: Float!
    var rate: Float!
    var startTime: CGFloat?
    var endTime: CGFloat?
    
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var isVideo: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderVolume.value = volume
        
        addScreenTap(screen: self.screen)
    }
    
    func addScreenTap(screen: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        tap.numberOfTapsRequired = 1
        screen.addGestureRecognizer(tap)
    }
    
    @objc func screenTapped() {
        player.pause()
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addAudioPlayer(with: url)
        
        initTrimmerView(asset: AVAsset(url: url))
        
        player.pause()
        changeIconBtnPlay()
    }
    
    
    func changeIconBtnPlay() {
        if player.isPlaying || videoPlayer.isPlaying {
            btnPlay.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    private func addAudioPlayer(with url: URL) {
        
        do {
            if !isVideo {
                try player = AVAudioPlayer(contentsOf: url)
            } else {
                videoPlayer = AVPlayer(url: url)
            }
        } catch {
            print("Couldn't load file")
        }
        if !isVideo {
            player.numberOfLoops = -1
            player.enableRate = true
        endTime = CGFloat(player.duration)
        startTime = 0
        initMedia()
        }
    }
    
    private func initTrimmerView(asset: AVAsset) {
        self.trimmerView.asset = asset
        self.trimmerView.delegate = self
        self.trimmerView.themeColor = .white
        self.trimmerView.showsRulerView = false
        if isVideo {
            self.trimmerView.maxLength = CGFloat((videoPlayer.currentItem?.asset.duration.seconds)!)
        } else {
            self.trimmerView.maxLength = CGFloat(player.duration)
        }
        self.trimmerView.trackerColor = .white
        self.trimmerView.thumbWidth = 12
        self.trimmerView.resetSubviews()
        setLabelTime()
    }
    
    func initMedia() {
        
        if !isVideo {
            player.rate = rate! * steps
            player.volume = volumeRate * volume!
        } else {
            videoPlayer.volume = volumeRate * volume!
        }
        
    }
    
    func setLabelTime() {
        lblStartTime.text = CMTimeMakeWithSeconds(Float64(startTime!), preferredTimescale: 600).positionalTime
        lblEndTime.text = CMTimeMakeWithSeconds(Float64(endTime!), preferredTimescale: 600).positionalTime
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification){
        
        if isVideo {
            videoPlayer.seek(to: CMTime.zero)
        } else {
            player.currentTime = 0
        }
    }
    
    // MARK: Playback time checker
    func startPlaybackTimeChecker() {
        stopPlaypbackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaypbackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    
    @objc func onPlaybackTimeChecker() {
        guard let start = startTime, let end = endTime else {
            return
        }
        
        var playbackTime:CGFloat!
        if isVideo {
            playbackTime = CGFloat(videoPlayer.currentTime().seconds)
        } else {
            playbackTime = CGFloat(player.currentTime)
        }
        trimmerView.seek(toTime: playbackTime)
        
        if Float(playbackTime) >= Float(end) {
            if isVideo {
                player.currentTime = Double(start)
            } else {
                videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(start), preferredTimescale: 600))
            }

            trimmerView.seek(toTime: start)
        }
    }
    
    // MARK: Handle IBAction
    @IBAction func play(_ sender: Any) {
        if player.isPlaying || videoPlayer.isPlaying {
            if isVideo {
                videoPlayer.pause()
            } else {
                player.pause()
            }
            stopPlaypbackTimeChecker()
        } else {
            if isVideo {
                videoPlayer.play()
            } else {
                player.play()
            }
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
    }
    
    
    @IBAction func screenPressed(_ sender: Any) {
        self.dismiss(animated: true)
        if isVideo {
            videoPlayer.pause()
        } else {
            player.pause()
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
        if isVideo {
            videoPlayer.pause()
        } else {
            player.pause()
        }
    }
    
    
    @IBAction func save(_ sender: Any) {
        self.dismiss(animated: true) {
            if self.isVideo {
                self.delegate.transform(url: self.url, volume: self.videoPlayer.volume, rate: 1.0)
            } else {
                self.delegate.transform(url: self.url, volume: self.player.volume, rate: self.player.rate)
            }
        }
        if isVideo {
            videoPlayer.pause()
        } else {
            player.pause()
        }
    }
    
    @IBAction func changeVolume(_ sender: Any) {
        sliderVolume.value = roundf(sliderVolume.value)
        volume = sliderVolume.value
        if isVideo {
            videoPlayer.volume = volume * volumeRate
        } else {
            player.volume = volume * volumeRate
        }
    }
    
    
    @IBAction func volumeTapped(_ sender: Any) {
        if volume > 0 {
            volume = 0
            sliderVolume.value = volume
            if isVideo {
                videoPlayer.volume = volume
            } else {
                player.volume = volume
            }
        } else {
            volume = 100
            sliderVolume.value = volume
            if isVideo {
                videoPlayer.volume = volume
            } else {
                player.volume = volume
            }
        }
    }
}

extension VolumeViewController: ICGVideoTrimmerDelegate {
    func trimmerView(_ trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        if isVideo {
            videoPlayer.pause()
        } else {
            player.pause()
        }
        changeIconBtnPlay()
        player.currentTime = Double(startTime)
        
        self.startTime = startTime
        self.endTime = endTime
        setLabelTime()
    }
}
