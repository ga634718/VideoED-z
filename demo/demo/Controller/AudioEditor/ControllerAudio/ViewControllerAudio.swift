//
//  ViewController.swift
//  AudioControllerFFMPEG
//
//  Created by Viet Hoang on 7/13/20.
//  Copyright © 2020 Viet Hoang. All rights reserved.
//

import UIKit
import AVFoundation
import ICGVideoTrimmer
import ZKProgressHUD
import Photos
import MediaPlayer
import FDWaveformView

class ViewControllerAudio: UIViewController, AVAudioRecorderDelegate, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wave1: FDWaveformView!
    @IBOutlet weak var wave2: FDWaveformView!
    @IBOutlet weak var wave3: FDWaveformView!
    @IBOutlet weak var wave4: FDWaveformView!
    @IBOutlet weak var wave1Width: NSLayoutConstraint!
    @IBOutlet weak var wave2Width: NSLayoutConstraint!
    @IBOutlet weak var wave3Width: NSLayoutConstraint!
    @IBOutlet weak var wave4Width: NSLayoutConstraint!
    
    fileprivate var startRendering = Date()
    fileprivate var endRendering = Date()
    fileprivate var startLoading = Date()
    fileprivate var endLoading = Date()
    fileprivate var profileResult = ""
    
    var audioURLDelegate: AudioURLDelegate!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var arr = [ModelItem1]()
    var Audios = [ArrAudio]()
    var volume: Float?
    var volumeRate: Float = 0.01
    var rate: Float?
    var steps: Float = 0.25
    var fileManage = HandleOutputFile()
    var asset: AVAsset!
    var quality: String = "1280:720"
    var startTime: CGFloat?
    var endTime: CGFloat?
    var delegate: TransformDataDelegate!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var urlVideo: URL!
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    var audioPlayer: AVAudioPlayer?
    var videoPlayer: AVPlayer!
    var isPlay = false
    var isRecord = false
    var recordNum = 0
    var arrURL = [URL]()
    var recordURL:URL?
    var position = -1
    var hasChooseMusic = false
    var hasChangeMedia: Bool = false
    var isVideo: Bool!
    var delayTime: CGFloat!
    var isReload: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isReload = false
        
        delegateWaveform()
        
        let wave1gesture = UITapGestureRecognizer(target: self, action:  #selector(self.wave1Action))
        let wave2gesture = UITapGestureRecognizer(target: self, action:  #selector(self.wave2Action))
        let wave3gesture = UITapGestureRecognizer(target: self, action:  #selector(self.wave3Action))
        let wave4gesture = UITapGestureRecognizer(target: self, action:  #selector(self.wave4Action))
        self.wave1.addGestureRecognizer(wave1gesture)
        self.wave2.addGestureRecognizer(wave2gesture)
        self.wave3.addGestureRecognizer(wave3gesture)
        self.wave4.addGestureRecognizer(wave4gesture)
        
        asset = AVAsset(url: urlVideo)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        

        
        createAudioSession()
        initCollectionView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        trimmerView.addGestureRecognizer(tap)
    }
    
    @objc func doubleTapped() {
        pauseMedia()
        isVideo = true
        gotoEditVolume()
    }
    
    func delegateWaveform(){
            wave1.isUserInteractionEnabled = false
            wave1.isHidden = true
            wave2.isUserInteractionEnabled = false
            wave2.isHidden = true
            wave3.isUserInteractionEnabled = false
            wave3.isHidden = true
            wave4.isUserInteractionEnabled = false
            wave4.isHidden = true
            
            wave1.delegate = self
            wave2.delegate = self
            wave3.delegate = self
            wave4.delegate = self
            
        }
        
        func initWaveform(){
            // Animate the waveform view when it is rendered
            if arrURL.count > 0 {
                let mainWidth = Double(view.frame.width - 42)
                print(mainWidth)
                let videoDuration = videoPlayer.currentItem?.asset.duration.seconds
                print(videoDuration!)
                addAudioPlayer()
                if arrURL.count == 1 {
                    //wave1
    //                wave1.delegate = self
                    wave1.alpha = 0.0
                    wave1Width.constant = CGFloat(Audios[0].player.duration * mainWidth / videoDuration!)
                    wave1.audioURL = arrURL[0]
                    wave1.zoomSamples = 0 ..< wave1.totalSamples / 3
                    wave1.doesAllowScrubbing = true
                    wave1.doesAllowStretch = true
                    wave1.doesAllowScroll = true
                    wave1.backgroundColor = UIColor.clear
                    wave1.wavesColor = UIColor.white
                    wave1.isHidden = false
                    wave1.isUserInteractionEnabled = true
                    //wave 2, 3 , 4
                    wave2.isHidden = true
                    wave2.isUserInteractionEnabled = false
                    wave3.isHidden = true
                    wave3.isUserInteractionEnabled = false
                    wave4.isHidden = true
                    wave4.isUserInteractionEnabled = false
                } else if arrURL.count == 2 {
                    //wave1
    //                wave1.delegate = self
                    wave1.alpha = 0.0
                    wave1Width.constant = CGFloat(Audios[0].player.duration * mainWidth / videoDuration!)
                    wave1.audioURL = arrURL[0]
                    wave1.zoomSamples = 0 ..< wave1.totalSamples / 3
                    wave1.doesAllowScrubbing = true
                    wave1.doesAllowStretch = true
                    wave1.doesAllowScroll = true
                    wave1.isHidden = false
                    wave1.isUserInteractionEnabled = true
                    wave1.backgroundColor = UIColor.clear
                    wave1.wavesColor = UIColor.white
                    //wave2
    //                wave2.delegate = self
                    wave2.alpha = 0.0
                    wave2Width.constant = CGFloat(Audios[1].player.duration * mainWidth / videoDuration!)
                    wave2.audioURL = arrURL[1]
                    wave2.zoomSamples = 0 ..< wave2.totalSamples / 3
                    wave2.doesAllowScrubbing = true
                    wave2.doesAllowStretch = true
                    wave2.doesAllowScroll = true
                    wave2.isHidden = false
                    wave2.isUserInteractionEnabled = true
                    wave2.backgroundColor = UIColor.clear
                    wave2.wavesColor = UIColor.white
                    //wave 3, 4
                    wave3.isHidden = true
                    wave3.isUserInteractionEnabled = false
                    wave4.isHidden = true
                    wave4.isUserInteractionEnabled = false
                } else if arrURL.count == 3 {
                    //wave1
    //                wave1.delegate = self
                    wave1.alpha = 0.0
                    wave1Width.constant = CGFloat(Audios[0].player.duration * mainWidth / videoDuration!)
                    wave1.audioURL = arrURL[0]
                    wave1.zoomSamples = 0 ..< wave1.totalSamples / 3
                    wave1.doesAllowScrubbing = true
                    wave1.doesAllowStretch = true
                    wave1.doesAllowScroll = true
                    wave1.isHidden = false
                    wave1.isUserInteractionEnabled = true
                    wave1.backgroundColor = UIColor.clear
                    wave1.wavesColor = UIColor.white
                    //wave2
    //                wave2.delegate = self
                    wave2.alpha = 0.0
                    wave2Width.constant = CGFloat(Audios[1].player.duration * mainWidth / videoDuration!)
                    wave2.audioURL = arrURL[1]
                    wave2.zoomSamples = 0 ..< wave2.totalSamples / 3
                    wave2.doesAllowScrubbing = true
                    wave2.doesAllowStretch = true
                    wave2.doesAllowScroll = true
                    wave2.isHidden = false
                    wave2.isUserInteractionEnabled = true
                    wave2.backgroundColor = UIColor.clear
                    wave2.wavesColor = UIColor.white
                    //wave3
    //                wave3.delegate = self
                    wave3.alpha = 0.0
                    wave3Width.constant = CGFloat(Audios[2].player.duration * mainWidth / videoDuration!)
                    wave3.audioURL = arrURL[2]
                    wave3.zoomSamples = 0 ..< wave3.totalSamples / 3
                    wave3.doesAllowScrubbing = true
                    wave3.doesAllowStretch = true
                    wave3.doesAllowScroll = true
                    wave3.isHidden = false
                    wave3.isUserInteractionEnabled = true
                    wave3.backgroundColor = UIColor.clear
                    wave3.wavesColor = UIColor.white
                    //wave4
                    wave4.isHidden = true
                    wave4.isUserInteractionEnabled = false
                } else if arrURL.count == 4 {
                    //wave1
    //                wave1.delegate = self
                    wave1.alpha = 0.0
                    wave1Width.constant = CGFloat(Audios[0].player.duration * mainWidth / videoDuration!)
                    wave1.audioURL = arrURL[0]
                    wave1.zoomSamples = 0 ..< wave1.totalSamples / 3
                    wave1.doesAllowScrubbing = true
                    wave1.doesAllowStretch = true
                    wave1.doesAllowScroll = true
                    wave1.isHidden = false
                    wave1.isUserInteractionEnabled = true
                    wave1.backgroundColor = UIColor.clear
                    wave1.wavesColor = UIColor.white
                    //wave2
    //                wave2.delegate = self
                    wave2.alpha = 0.0
                    wave2Width.constant = CGFloat(Audios[1].player.duration * mainWidth / videoDuration!)
                    wave2.audioURL = arrURL[1]
                    wave2.zoomSamples = 0 ..< wave2.totalSamples / 3
                    wave2.doesAllowScrubbing = true
                    wave2.doesAllowStretch = true
                    wave2.doesAllowScroll = true
                    wave2.isHidden = false
                    wave2.isUserInteractionEnabled = true
                    wave2.backgroundColor = UIColor.clear
                    wave2.wavesColor = UIColor.white
                    //wave3
    //                wave3.delegate = self
                    wave3.alpha = 0.0
                    wave3Width.constant = CGFloat(Audios[2].player.duration * mainWidth / videoDuration!)
                    wave3.audioURL = arrURL[2]
                    wave3.zoomSamples = 0 ..< wave3.totalSamples / 3
                    wave3.doesAllowScrubbing = true
                    wave3.doesAllowStretch = true
                    wave3.doesAllowScroll = true
                    wave3.isHidden = false
                    wave3.isUserInteractionEnabled = true
                    wave3.backgroundColor = UIColor.clear
                    wave3.wavesColor = UIColor.white
                    //wave4
    //                wave4.delegate = self
                    wave4.alpha = 0.0
                    wave4Width.constant = CGFloat(Audios[3].player.duration * mainWidth / videoDuration!)
                    wave4.audioURL = arrURL[3]
                    wave4.zoomSamples = 0 ..< wave4.totalSamples / 3
                    wave4.doesAllowScrubbing = true
                    wave4.doesAllowStretch = true
                    wave4.doesAllowScroll = true
                    wave4.isHidden = false
                    wave4.isUserInteractionEnabled = true
                    wave4.backgroundColor = UIColor.clear
                    wave4.wavesColor = UIColor.white
                }
            } else {
                wave1.isHidden = true
                wave1.isUserInteractionEnabled = false
            }
//            scrollView.contentSize.width = 5000
        }
    
    //MARK: Tap sound wave action
    //wave1
    @objc func wave1Action(sender : UITapGestureRecognizer) {
        // Do ....
        if arrURL.count > 0 {
            
            // Pause all Audio and video
            for audio in Audios {
                audio.player.pause()
            }
            videoPlayer.pause()
            
            if position == 0 {
                wave1.wavesColor = UIColor.white
                position = -1
                hasChooseMusic = false
            } else {
                wave1.wavesColor = UIColor.yellow
                if position != -1 {
                    switch (position + 1) {
                    case 2:
                        wave2.wavesColor = UIColor.white
                    case 3:
                        wave3.wavesColor = UIColor.white
                    case 4:
                        wave4.wavesColor = UIColor.white
                    default: break
                    }
                }
                position = 0
                hasChooseMusic = true
            }
            print(Audios[0].player.duration)
            collectionView.reloadData()
            changeIconBtnPlay()
        }
    }
    
    //wave2
    @objc func wave2Action(sender : UITapGestureRecognizer) {
        // Do ....
        if arrURL.count > 0 {
            
            // Pause all Audio and video
            for audio in Audios {
                audio.player.pause()
            }
            videoPlayer.pause()
            
            if position == 1 {
                wave2.wavesColor = UIColor.white
                position = -1
                hasChooseMusic = false
            } else {
                wave2.wavesColor = UIColor.yellow
                if position != -1 {
                    switch (position + 1) {
                    case 1:
                        wave1.wavesColor = UIColor.white
                    case 3:
                        wave3.wavesColor = UIColor.white
                    case 4:
                        wave4.wavesColor = UIColor.white
                    default: break
                    }
                }
                position = 1
                hasChooseMusic = true
            }
            collectionView.reloadData()
            changeIconBtnPlay()
        }
    }
    
    //wave3
    @objc func wave3Action(sender : UITapGestureRecognizer) {
        // Do ....
        if arrURL.count > 0 {
            
            // Pause all Audio and video
            for audio in Audios {
                audio.player.pause()
            }
            videoPlayer.pause()
            
            if position == 2 {
                wave3.wavesColor = UIColor.white
                position = -1
                hasChooseMusic = false
            } else {
                wave3.wavesColor = UIColor.yellow
                if position != -1 {
                    switch (position + 1) {
                    case 2:
                        wave2.wavesColor = UIColor.white
                    case 1:
                        wave1.wavesColor = UIColor.white
                    case 4:
                        wave4.wavesColor = UIColor.white
                    default: break
                    }
                }
                position = 2
                hasChooseMusic = true
            }
            collectionView.reloadData()
            changeIconBtnPlay()
        }
    }
    
    //wave4
    @objc func wave4Action(sender : UITapGestureRecognizer) {
        // Do ....
        if arrURL.count > 0 {
            
            // Pause all Audio and video
            for audio in Audios {
                audio.player.pause()
            }
            videoPlayer.pause()
            if position == 3 {
                wave4.wavesColor = UIColor.white
                position = -1
                hasChooseMusic = false
            } else {
                wave4.wavesColor = UIColor.yellow
                if position != -1 {
                    switch (position + 1) {
                    case 2:
                        wave2.wavesColor = UIColor.white
                    case 3:
                        wave3.wavesColor = UIColor.white
                    case 1:
                        wave1.wavesColor = UIColor.white
                    default: break
                    }
                }
                position = 3
                hasChooseMusic = true
            }

            collectionView.reloadData()
            changeIconBtnPlay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addVieoPlayer(asset: asset, playerView: playerView)
        initTrimmerView(asset: asset)
        initVariable()
        
    }
    
    func initVariable() {
        if arrURL.count > 0 {
            initWaveform()
            collectionView.reloadData()
        }
        position = -1
        hasChooseMusic = false
        isVideo = false
    }
    
    // create session
    func createAudioSession(){
        do {
            /// this codes for making this app ready to takeover the device nlPlayer
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,mode:.moviePlayback ,options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Add AudioPlayer
    
    private func getAudios() {
        let numURL = arrURL.count
        let numAudio = Audios.count
        if numURL > 0 {
            for i in 0..<numURL {
                do {
                    let audio = try AVAudioPlayer(contentsOf: arrURL[i])
                    audio.enableRate = true
                    if i <= (numAudio - 1) {
                        audio.rate = Audios[i].player.rate
                        audio.volume = Audios[i].player.volume
                        Audios[i].player = audio
                    } else {
                        audio.rate = self.rate! * steps
                        audio.volume = self.volume! * volumeRate
                        Audios.append(ArrAudio(player: audio, delayTime: delayTime))
                    }
                } catch {
                    
                }
            }
        }
    }
    
    private func addVieoPlayer(asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewControllerAudio.itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: videoPlayer)
        layer.backgroundColor = UIColor.black.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        //        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.addSublayer(layer)
        endTime = CGFloat(CMTimeGetSeconds((videoPlayer.currentItem?.asset.duration)!))
        startTime = 0
        delayTime = startTime
        videoPlayer.volume = 0.6
        initMedia()
    }
    
    private func addAudioPlayer() {
        getAudios()
        initMedia() 
    }
    
    // Nếu điểm bắt đầu của trimmer view chưa tới thời gian delay mà music được thêm vào
    // -> trình phát nhạc quản lí music của nó vẫn như cũ
    
    func isOverTimeDelay(startTime: CGFloat, delayTime: CGFloat) -> Bool {
        return startTime > delayTime
    }
    
    func setTimeMusic(audio: ArrAudio, startTime: CGFloat, play: Bool) {
        var time: CGFloat = 0
        if isOverTimeDelay(startTime: startTime, delayTime: audio.delayTime) {
            time = startTime - audio.delayTime
        }
        audio.player.currentTime = Double(time)
        if !play {
            audio.player.pause()
        }
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let start = self.startTime {
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(start), preferredTimescale: 600))
            videoPlayer.pause()
            if hasChooseMusic {
                setTimeMusic(audio: Audios[position], startTime: start, play: false)
            } else {
                for audio in Audios {
                    setTimeMusic(audio: audio, startTime: start, play: false)
                }
            }
        }
        changeIconBtnPlay()
    }
    
    // MARK: Playback time checker
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
        
    }
    
    func stopPlaybackTimeChecker(){
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let start = startTime, let endTime = endTime, let videoPlayer = videoPlayer else {
            return
        }
        
        let playBackTime = CGFloat(CMTimeGetSeconds(videoPlayer.currentTime()))
        trimmerView.seek(toTime: playBackTime)
        
        
        if playBackTime >= endTime {
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(start), preferredTimescale: 600), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            videoPlayer.pause()
                      
            if hasChooseMusic {
                setTimeMusic(audio: Audios[position], startTime: start, play: false)
            } else {
                for audio in Audios {
                    setTimeMusic(audio: audio, startTime: start, play: false)
                }
            }
            
            trimmerView.seek(toTime: start)
            changeIconBtnPlay()
        } else {
            delayTime = playBackTime
            var audioDelayTime: Double!
            var audioDuration: Double!
            if hasChooseMusic {
                audioDelayTime = Double(Audios[position].delayTime)
                audioDuration = Audios[position].player.duration
                if !Audios[position].player.isPlaying && ((Double(playBackTime) - audioDelayTime - audioDuration) < 0){
                    setTimeMusic(audio: Audios[position], startTime: playBackTime, play: true)
                    if isOverTimeDelay(startTime: playBackTime, delayTime: Audios[position].delayTime){
                        if videoPlayer.isPlaying {
                            Audios[position].player.play()
                        }
                    }
                }
            } else {
                for audio in Audios {
                    audioDelayTime = Double(audio.delayTime)
                    audioDuration = audio.player.duration
                    if !audio.player.isPlaying && ((Double(playBackTime) - audioDelayTime - audioDuration) < 0) {
                        setTimeMusic(audio: audio, startTime: playBackTime, play: true)
                        if isOverTimeDelay(startTime: playBackTime, delayTime: audio.delayTime){
                            if videoPlayer.isPlaying {
                                audio.player.play()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setLabelTime() {
        lblStartTime.text = CMTimeMakeWithSeconds(Float64(startTime!), preferredTimescale: 600).positionalTime
        lblEndTime.text = CMTimeMakeWithSeconds(Float64(endTime!), preferredTimescale: 600).positionalTime
        lblDuration.text = CMTimeMakeWithSeconds(Float64(endTime! - startTime!), preferredTimescale: 600).positionalTime
    }
    
    func initMedia() {
        if volume == nil {
            volume = 60.0
        }
        if rate == nil {
            rate = 4.0
        }
        
        if hasChangeMedia {
            setMedia()
        } else {
            for audio in Audios {
                audio.player.rate = 4 * steps
                audio.player.volume = 60 * volumeRate
            }
        }
        changeIconBtnPlay()
    }
    
    func setMedia() {
        if position >= 0 {
            Audios[position].player.volume = volume! * volumeRate
            Audios[position].player.rate = rate! * steps
        }
    }
    
    //MARK: Init View, Player...
    func initCollectionView() {
        collectionView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellWithReuseIdentifier: "ButtonCell")
        arr.append(ModelItem1(title: "MUSIC", image: "Music-1"))
        arr.append(ModelItem1(title: "ITUNES", image: "Itunes"))
        arr.append(ModelItem1(title: "RECORD", image: "Record"))
        arr.append(ModelItem1(title: "VOLUME", image: "icon_sound"))
        arr.append(ModelItem1(title: "SPEED", image: "icon_speed"))
        arr.append(ModelItem1(title: "DELETE", image: "icon_trash"))
        arr.append(ModelItem1(title: "SPLIT", image: "icon_split"))
        arr.append(ModelItem1(title: "DUPLICATE", image: "icon_duplicate"))
    }
    
    //MARK: Init TrimmerView
    
    private func initTrimmerView(asset: AVAsset) {
        self.trimmerView.asset = asset
        self.trimmerView.delegate = self
        self.trimmerView.themeColor = .white
        self.trimmerView.showsRulerView = false
        self.trimmerView.maxLength = CGFloat(CMTimeGetSeconds((videoPlayer.currentItem?.asset.duration)!))
        self.trimmerView.trackerColor = .white
        self.trimmerView.thumbWidth = 12
        trimmerView.backgroundColor = .gray
        self.trimmerView.resetSubviews()
        setLabelTime()
    }
    
    // MARK: Display media picker
    
    func displayMediaPickerAndPlayItem(){
        mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        
        if let picker = mediaPicker{
            //            print("Successfully instantiated a media picker")
            picker.delegate = self
            view.addSubview(picker.view)
            present(picker, animated: true, completion: nil)
            //            playItunesItem()
        } else {
            print("Could not instantiate a media picker")
        }
    }
    
    func ItunesMusic(){
        if arrURL.count < 4 {
            displayMediaPickerAndPlayItem()
        }
    }
    
    // MARK: Navigate to another view
    
    func MusicInApp(){
//        self.delayTime = CGFloat(videoPlayer.currentTime().seconds)
        if arrURL.count < 4 {
            let MusicView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppMusic") as! AppMusicViewController
            MusicView.delegate = self
            MusicView.delayTime = self.delayTime
            MusicView.modalPresentationStyle = .overCurrentContext
            self.present(MusicView, animated: true)
        }
    }
    
    func gotoEditVolume() {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VolumeView") as! VolumeViewController
        view.delegate = self
        view.volumeRate = volumeRate
        view.steps = steps
        view.isVideo = isVideo
        if isVideo {
            view.url = urlVideo
            view.volume = videoPlayer.volume / volumeRate
        } else {
            view.url = arrURL[position]
            view.volume = Audios[position].player.volume / volumeRate
            view.rate = Audios[position].player.rate / steps
        }
        view.modalPresentationStyle = .overCurrentContext
        self.present(view, animated: true)
    }
    
    func gotoEditRate() {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpeedView") as! SpeedViewController
        view.delegate = self
        view.volume = Audios[position].player.volume / volumeRate
        view.rate = Audios[position].player.rate / steps
        view.volumeRate = volumeRate
        view.steps = steps
        view.url = arrURL[position]
        view.modalPresentationStyle = .overCurrentContext
        self.present(view, animated: true)
    }
    
    func gotoDeleteAudioFile() {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeleteView") as! DeleteViewController
        view.volume = Audios[position].player.volume / volumeRate
        view.rate = Audios[position].player.rate / steps
        view.volumeRate = volumeRate
        view.steps = steps
        view.url = self.arrURL[position]
        view.delegate = self
        view.modalPresentationStyle = .overCurrentContext
        self.present(view, animated: true)
    }
    
    func gotoSplitView() {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplitView") as! SplitViewController
        view.volume = Audios[position].player.volume / volumeRate
        view.rate = Audios[position].player.rate / steps
        view.volumeRate = volumeRate
        view.steps = steps
        view.url = self.arrURL[position]
        view.delegate = self
        view.modalPresentationStyle = .overCurrentContext
        self.present(view, animated: true)
    }
    
    //MARK: Itunes
        
    func gotoItunesView(){
        
        if arrURL.count < 4 {
            let picker = MPMediaPickerController(mediaTypes: .anyAudio)
            picker.delegate = self
            picker.allowsPickingMultipleItems = false
            present(picker, animated: true, completion: nil)
        }
    }
        
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let mediaItem = mediaItemCollection.items.first else {
            print("No song selected")
            return
        }
        if mediaItem.hasProtectedAsset {
            print("Must be played only via MPMusicPlayer")
        } else {
            print("Can be played both via AVPlayer & MPMusicPlayer")
        }
        let audioUrl = mediaItem.assetURL
        print("Audio URL:::")
        print(audioUrl ?? "No file detected")
        arrURL.append(audioUrl!)
        initWaveform()
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Duplicate
    func dupicateAudioFile() {
        
        let outputTemp = fileManage.createUrlInApp(name: "temp.mp3")
        let name = Date().toString(dateFormat: "HH:mm:ss")
        let type = ".mp3"
        let outputDuplicate = fileManage.createUrlInApp(name: "\(name)\(type)")
        let cmd = "-i \(arrURL[position]) -vn -ac 2 -ar 44100 -ab 320k -f mp3 \(outputTemp)"
        let cmd2 = "-i \"concat:\(outputTemp)|\(outputTemp)\" -c copy \(outputDuplicate)"
        
        let serialQueue = DispatchQueue(label: "serialQueue")
        
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        
        serialQueue.async {
            MobileFFmpeg.execute(cmd)
            MobileFFmpeg.execute(cmd2)
            self.arrURL[self.position] = outputDuplicate
            let audio = try! AVAudioPlayer(contentsOf: outputDuplicate)
            let audioPosition = self.Audios[self.position]
            audio.enableRate = true
            audio.volume = audioPosition.player.volume
            audio.rate = audioPosition.player.rate
            self.Audios[self.position].player = audio
            DispatchQueue.main.async {
                self.initWaveform()
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showSuccess()
            }
        }
    }
    
    func changeIconBtnPlay() {
        if videoPlayer.isPlaying {
            btnPlay.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            btnPlay.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    //MARK: Handle IBAction
    @IBAction func playAudio(_ sender: Any) {
        
        if videoPlayer.isPlaying {
            pauseMedia()
            stopPlaybackTimeChecker()
        } else {
            playMedia()
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
    }
    
    func pauseMedia() {
        if hasChooseMusic {
            if Audios[position].player.isPlaying && videoPlayer.isPlaying {
                Audios[position].player.pause()
            }
        } else {
            for audio in Audios {
                if audio.player.isPlaying && videoPlayer.isPlaying {
                    audio.player.pause()
                }
            }
        }
        videoPlayer.pause()
    }
    
    func playMedia() {
        let playbackTime = videoPlayer.currentTime().seconds
        var audioDelayTime: Double!
        if hasChooseMusic {
            audioDelayTime = Double(Audios[position].delayTime)
            if (!videoPlayer.isPlaying) && (playbackTime >= audioDelayTime) && ((playbackTime - audioDelayTime - Audios[position].player.duration) < 0) {
                Audios[position].player.play()
            }
        } else {
            for audio in Audios {
                audioDelayTime = Double(audio.delayTime)
                if (!videoPlayer.isPlaying) && (playbackTime >= audioDelayTime) && ((playbackTime - audioDelayTime - audio.player.duration) < 0){
                    audio.player.play()
                }
            }
        }
        videoPlayer.play()
    }
    
    @IBAction func saveChange(_ sender: Any) {
        pauseMedia()
        ZKProgressHUD.show()
        let queue = DispatchQueue(label: "saveQueue")
        queue.async {
            let a = self.mergeAudioWithVideo()
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showSuccess()
                self.audioURLDelegate.getAudioURL(url: a)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        pauseMedia()
        videoPlayer = nil
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Record audio file
    // Get permission
    func recordPermission(){
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { granted in
                if granted {
                    print("Permission success")
                } else {
                    print("Permission denied")
                }
            }
        } catch {
            // failed to record!
            print("Permission fail")
        }
    }
    
    func RecordAudio() {
        if arrURL.count < 4 {
            recordPermission()
            if audioRecorder == nil {
                startRecord()
            } else{
                finishRecord(success: true)
                isRecord = false
            }
        }
    }
    
    func startRecord(){
        let fileName = "recordFile\(recordNum + 1).m4a"
        recordNum += 1
        recordURL = fileManage.getDocumentsDirectory().appendingPathComponent(fileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do{
            audioRecorder = try AVAudioRecorder(url: recordURL!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            isRecord = true
            collectionView.reloadData()
        } catch{
            finishRecord(success: false)
        }
    }
    
    func finishRecord(success: Bool){
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            let tempURL = fileManage.createUrlInApp(name: "tempRecord.mp3")
            let str = "-i \(recordURL!) -c:a libmp3lame -q:a 8 \(tempURL)"
            MobileFFmpeg.execute(str)
            arrURL.append(tempURL)
            initWaveform()
            collectionView.reloadData()
        } else{
            print("Record failed")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecord(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    // MARK: Merge audio with video
    func mergeAudioWithVideo() -> URL {
        let output = fileManage.createUrlInApp(name: "output.mp4")
        let outputVideo = fileManage.createUrlInApp(name: "outputVideo.mp3")
        let outputMerge = fileManage.createUrlInApp(name: "outputMerge.mp3")
        let path = urlVideo.path
        
        // Get audio from mp4 file
        let extract = "-i \(path) -af \"volume=\(videoPlayer.volume)\" \(outputVideo)"
        MobileFFmpeg.execute(extract)
        
        var outputAudio: URL
        
        // Merge audio file
        
        if arrURL.count == 0 {
            fileManage.clearTempDirectory()
            return urlVideo
        } else {
            var final = ""
            outputAudio = mergeAllOfAudioURL()
            if arrURL.count == 1 {
                let delay = Audios[0].delayTime * 1000

                final = "-i \(outputVideo) -i \(outputAudio) -filter_complex \"[0]adelay=0000|0000[b];[1]adelay=\(delay)|\(delay)[c];[b][c]amerge[a]\" -map \"[a]\" -c:a libmp3lame -q:a 4 \(outputMerge)"
            } else {

                final = "-i \(outputVideo) -i \(outputAudio) -filter_complex amerge -c:a libmp3lame -q:a 4 \(outputMerge)"
            }
            MobileFFmpeg.execute(final)

            // Merge audio file with video

            let str2 = "-i \(path) -i \(outputMerge) -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 \(output)"
            MobileFFmpeg.execute(str2)

            // Move to directory
            let urlDir = fileManage.saveToDocumentDirectory(url: output)
            fileManage.clearTempDirectory()
            return urlDir
        }
    }
    
    func mergeAllOfAudioURL() -> (URL) {
        var url = [URL]()
        let urlNum = arrURL.count
        var outputAudio = fileManage.createUrlInApp(name: "OutputAudio.mp3")
        if arrURL.count > 0 {
            for i in 0 ..< urlNum {
                let output = fileManage.createUrlInApp(name: "\(i).mp3")
                let audio = "-i \(arrURL[i]) -af \"volume=\(Audios[i].player.volume), atempo=\(Audios[i].player.rate)\" \(output)"
                MobileFFmpeg.execute(audio)
                url.append(output)
            }
        }
        
        let urlConvert = url.count
        if urlConvert >= 1 {
            var str = ""
            switch urlConvert {
            case 1:
                outputAudio = url[0]
            case 2:
                let delay0 = Audios[0].delayTime * 1000
                let delay1 = Audios[1].delayTime * 1000
                str = "-i \(url[0]) -i \(url[1]) -filter_complex \"[0]adelay=\(delay0)|\(delay0)[b];[1]adelay=\(delay1)|\(delay1)[c];[b][c]amerge[a]\" -map \"[a]\" -c:a libmp3lame -q:a 4 \(outputAudio)"
            case 3:
                let delay0 = Audios[0].delayTime * 1000
                let delay1 = Audios[1].delayTime * 1000
                let delay2 = Audios[2].delayTime * 1000
                str = "-i \(url[0]) -i \(url[1]) -i \(url[2]) -filter_complex \"[0]adelay=\(delay0)|\(delay0)[b];[1]adelay=\(delay1)|\(delay1)[c];[2]adelay=\(delay2)|\(delay2)[d];[b][c][d]amix=3[a]\" -map \"[a]\" -c:a libmp3lame -q:a 4 \(outputAudio)"
            case 4:
                let delay0 = Audios[0].delayTime * 1000
                let delay1 = Audios[1].delayTime * 1000
                let delay2 = Audios[2].delayTime * 1000
                let delay3 = Audios[3].delayTime * 1000
                str = "-i \(url[0]) -i \(url[1]) -i \(url[2]) -i \(url[3]) -filter_complex \"[0]adelay=\(delay0)|\(delay0)[b];[1]adelay=\(delay1)|\(delay1)[c];[2]adelay=\(delay2)|\(delay2)[d];[3]adelay=\(delay3)|\(delay3)[e];[b][c][d][e]amix=4[a]\" -map \"[a]\" -c:a libmp3lame -q:a 4 \(outputAudio)"
            default:
                print("Default")
            }
            MobileFFmpeg.execute(str)
        }
        return outputAudio
    }
    
}

extension ViewControllerAudio: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ICGVideoTrimmerDelegate, TransformDataDelegate {
    
    // MARK: Rewrite func for CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            let data = arr[indexPath.row]
            let hasAudio = arrURL.count != 0 && position != -1
            
            if isRecord {
                cell.isUserInteractionEnabled = false
                if indexPath.row == 2 {
                    cell.isUserInteractionEnabled = true
                    cell.initView(title: data.title, img: "Stop")
                    cell.updateView(hasAudio: true)
                } else {
                    cell.initView(title: data.title, img: data.image)
                    cell.isUserInteractionEnabled = false
                    cell.updateView(hasAudio: false)
                }
            } else {
                cell.initView(title: data.title, img: data.image)
                if indexPath.row >= 3 {
                    if hasAudio {
                        cell.isUserInteractionEnabled = true
                    } else {
                        cell.isUserInteractionEnabled = false
                    }
                } else {
                    cell.isUserInteractionEnabled = true
                }
                cell.updateView(hasAudio: indexPath.row < 3 || hasAudio)
            }
            
//            cell.updateView(hasAudio: indexPath.row < 3 || hasAudio)
//
//            if isRecord && indexPath.row == 2 {
//                cell.initView(title: data.title, img: "Stop")
//            } else{
//                cell.initView(title: data.title, img: data.image)
//            }
//            if indexPath.row >= 3 {
//                if hasAudio {
//                    cell.isUserInteractionEnabled = true
//                } else {
//                    cell.isUserInteractionEnabled = false
//                }
//            } else {
//                cell.isUserInteractionEnabled = true
//            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let xWidth = collectionView.frame.width
        let xHeight = collectionView.frame.height
        return CGSize(width: xWidth / 7, height: xHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        hasChangeMedia = true
        
        for audio in Audios {
            audio.player.currentTime = 0
            audio.player.pause()
        }
        
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.pause()
        changeIconBtnPlay()
        
        switch indexPath.row {
        case 0:
            MusicInApp()
        case 1:
            gotoItunesView()
        case 2:
            RecordAudio()
//            collectionView.reloadItems(at: [indexPath])
        case 3:
            gotoEditVolume()
        case 4:
            gotoEditRate()
        case 5:
            gotoDeleteAudioFile()
        case 6:
            gotoSplitView()
        case 7:
            dupicateAudioFile()
        default:
            print(indexPath.row)
        }
    }
    
    // MARK: Extension TrimmerView
    func trimmerView(_ trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        
        for audio in Audios {
            // Nếu trimmer chưa kéo tới thời gian add audio vào thì sẽ không thay đổi thời gian bắt đầu của audio đó
            if startTime <= audio.delayTime {
                audio.player.currentTime = 0
            } else {
                audio.player.currentTime = Double(startTime)
            }
            audio.player.pause()
        }
        
        videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: 600), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        videoPlayer.pause()
        changeIconBtnPlay()
        
        trimmerView.seek(toTime: startTime)
//        delayTime = startTime
        
        self.startTime = startTime
        self.endTime = endTime
        setLabelTime()
    }
    
    //MARK: Rewirite function for userdefine Protocol
    
    func transform(url: URL, volume: Float, rate: Float) {
        if isVideo {
            videoPlayer.volume = volume
        } else {
            self.arrURL[position] = url
            self.Audios[position].player.volume = volume
            self.Audios[position].player.rate = rate
            self.volume = volume / self.volumeRate
            self.rate = rate / self.steps
        }
        isReload = true
        initVariable()
    }
    
    func transformQuality(quality: String) {
        self.quality = quality
    }
    
    func transformSplitMusic(url: URL) {
        self.arrURL[position] = url
        isReload = true
        initVariable()
    }
    
    func isRemove(isRemove: Bool) {
        let count = arrURL.count - 1
        if count >= 0 {
            if isRemove {
                if position < count {
                    for i in position ..< count {
                        Audios[i].player = Audios[i+1].player
                        Audios[i].delayTime = Audios[i+1].delayTime
                    }
                }
                arrURL.remove(at: position)
                Audios.remove(at: position)
            }
            collectionView.reloadData()
        }
        position = -1
        initWaveform()
        hasChooseMusic = false
    }
    
    func isGetMusic(state: Bool) {
        if state {
            addAudioPlayer()
            initWaveform()
        }
    }
    
    func transformMusicPath(path: String) {
        if(arrURL.count < 4) {
            self.arrURL.append(URL(fileURLWithPath: path))
        } else {
            print("Number of audio file more than 4")
        }
    }
    
    func delayTime(delayTime: CGFloat) {
        self.delayTime = delayTime
    }
}


//MARK: Extension TableView
//extension ViewControllerAudio: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrURL.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        if arrURL.count != 0 {
//            if indexPath.row < arrURL.count {
//                cell.textLabel?.text = arrURL[indexPath.row].lastPathComponent
//                addAudioPlayer()
//            }
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        isVideo = false
//
//        if arrURL.count > 0 {
//
//            // Pause all Audio and video
//            for audio in Audios {
//                audio.player.pause()
//            }
//            videoPlayer.pause()
//
//            if indexPath.row != position {
//                position = indexPath.row
//                hasChooseMusic = true
//            } else {
//                tableView.deselectRow(at: indexPath, animated: true)
//                position = -1
//                hasChooseMusic = false
//            }
//            collectionView.reloadData()
//            changeIconBtnPlay()
//        }
//    }
//}

//MARK: Waveform Delegate

extension ViewControllerAudio: FDWaveformViewDelegate {
    func waveformViewWillRender(_ waveformView: FDWaveformView) {
        startRendering = Date()
    }
    
    func waveformViewDidRender(_ waveformView: FDWaveformView) {
        endRendering = Date()
        NSLog("FDWaveformView rendering done, took %0.3f seconds", endRendering.timeIntervalSince(startRendering))
        profileResult.append(String(format: " render %0.3f ", endRendering.timeIntervalSince(startRendering)))
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            waveformView.alpha = 1.0
        })
    }
    
    func waveformViewWillLoad(_ waveformView: FDWaveformView) {
        startLoading = Date()
    }
    
    func waveformViewDidLoad(_ waveformView: FDWaveformView) {
        endLoading = Date()
        NSLog("FDWaveformView loading done, took %0.3f seconds", endLoading.timeIntervalSince(startLoading))
        profileResult.append(String(format: " load %0.3f ", endLoading.timeIntervalSince(startLoading)))
    }
}
