
import UIKit
import AVKit
import AVFoundation
import ZKProgressHUD


class TFVideoViewController: AssetSelectionVideoViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var LblStartTime: UILabel!
    @IBOutlet weak var LblEndTime: UILabel!
    
    var player = AVPlayer()
    var playerController = AVPlayerViewController()
    var currentAnimation = 0
    var currentAnimation2 = 0
    var str = ""
    var path:URL!
    var tfURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var ratio1: CGFloat!
    var ratio2: CGFloat!
    var ratio3: CGFloat!
    var videoCR: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player = AVPlayer(url: path as URL)
        playerController.player = player
        playerController.showsPlaybackControls = false
        let asset = AVAsset(url: path as URL)
        trimmerView.asset = asset
        trimmerView.delegate = self
        let playerItem = AVPlayerItem(asset: asset)
        playerController.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height:  videoView.frame.height)
        self.videoView.addSubview(playerController.view)
        playerController.view.backgroundColor = nil
        setlabel()
    }
    
    @IBAction func back(_ sender: Any) {
        playerController.player?.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        
        playerController.player?.pause()
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        
        let startTime = CGFloat(CMTimeGetSeconds(trimmerView.startTime!))
        let endTime = CGFloat(CMTimeGetSeconds(trimmerView.endTime!))
        let tftime = CGFloat(CMTimeGetSeconds(trimmerView.endTime! - trimmerView.startTime!))
        let lateTime = CGFloat(CMTimeGetSeconds((playerController.player?.currentItem?.asset.duration)! - trimmerView.endTime!))
        let durationTime = CGFloat(CMTimeGetSeconds((playerController.player?.currentItem?.asset.duration)!))
        
        let url1 = createUrlInApp(name: "VideoCut1.mp4")
        removeFileIfExists(fileURL: url1)
        let url2 = createUrlInApp(name: "VideoCut2.mp4")
        removeFileIfExists(fileURL: url2)
        let urltf = createUrlInApp(name: "VideoTF.mp4")
        removeFileIfExists(fileURL: url1)
        let furl1 = createUrlInApp(name: "111.ts")
        removeFileIfExists(fileURL: furl1)
        let furl2 = createUrlInApp(name: "112.ts")
        removeFileIfExists(fileURL: furl2)
        let furl3 = createUrlInApp(name: "11.ts")
        removeFileIfExists(fileURL: furl3)
        let url3 = createUrlInApp(name: "VideoCut3.mp4")
        removeFileIfExists(fileURL: url3)
        let furl4 = createUrlInApp(name: "113.ts")
        removeFileIfExists(fileURL: furl4)
        
        let urlCrop1 = createUrlInApp(name: "VideoCrop1.mp4")
        removeFileIfExists(fileURL: urlCrop1)
        let urlCrop2 = createUrlInApp(name: "VideoCrop2.mp4")
        removeFileIfExists(fileURL: urlCrop2)
        let final = createUrlInApp(name: "\(currentDate()).mp4")
        removeFileIfExists(fileURL: final)
        if str == "" {
            print("hmm")
        }else {
            if (startTime == 0 && endTime == durationTime) {
                if str == "" {
                    print("No Edit")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    DispatchQueue.main.async {
                        ZKProgressHUD.show()
                    }
                    let transform = "-i \(filePath) -vf \(str) -codec:a copy \(final)"
                    let serialQueue = DispatchQueue(label: "serialQueue")
                    serialQueue.async {
                        MobileFFmpeg.execute(transform)
                        self.tfURL = final
                        self.isSave = true
                        self.delegate.transformReal(url: self.tfURL!)
                        DispatchQueue.main.async {
                            ZKProgressHUD.dismiss()
                            ZKProgressHUD.showSuccess()
                            ZKProgressHUD.dismiss(0.5)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else if startTime == 0 {
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    let cmdVideoTF = "-ss 0 -i \(filePath) -to \(tftime) -c copy \(url2)"
                    MobileFFmpeg.execute(cmdVideoTF)
                    let transform = "-i \(url2) -vf \(self.str) -codec:a copy \(urltf)"
                    MobileFFmpeg.execute(transform)
                    self.ratio1 = self.getVideoRatio(url: urltf)
                    let urlFinal1 = self.squareVideo(url: urltf, ratio: self.ratio1)
                    
                    
                    let cmdCutVideo1 = "-ss \(endTime) -i \(filePath) -to \(lateTime) -c copy \(url1)"
                    MobileFFmpeg.execute(cmdCutVideo1)
                    self.ratio2 = self.getVideoRatio(url: url1)
                    let urlFinal2 = self.squareVideo(url: url1, ratio: self.ratio2)
                    
                    let s1 = "-i \(urlFinal1) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl1)"
                    let s2 = "-i \(urlFinal2) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl2)"
                    let str = "-i \"concat:\(furl1)|\(furl2)\" -c copy \(furl3)"
                    let cmdFinal = "-i \(furl3) \(final)"
                    
                    MobileFFmpeg.execute(s1)
                    MobileFFmpeg.execute(s2)
                    MobileFFmpeg.execute(str)
                    MobileFFmpeg.execute(cmdFinal)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.removeFileIfExists(fileURL: furl1)
                    self.removeFileIfExists(fileURL: furl2)
                    self.removeFileIfExists(fileURL: furl3)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: urltf)
                    self.tfURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.tfURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                        ZKProgressHUD.dismiss(0.5)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else if endTime == durationTime {
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    let cmdVideoTF = "-ss \(startTime) -i \(filePath) -to \(tftime) -c copy \(url2)"
                    MobileFFmpeg.execute(cmdVideoTF)
                    let transform = "-i \(url2) -vf \(self.str) -codec:a copy \(urltf)"
                    MobileFFmpeg.execute(transform)
                    self.ratio1 = self.getVideoRatio(url: urltf)
                    let urlFinal1 = self.squareVideo(url: urltf, ratio: self.ratio1)
                    
                    
                    let cmdCutVideo1 = "-ss 0 -i \(filePath) -to \(startTime) -c copy \(url1)"
                    MobileFFmpeg.execute(cmdCutVideo1)
                    self.ratio2 = self.getVideoRatio(url: url1)
                    let urlFinal2 = self.squareVideo(url: url1, ratio: self.ratio2)
                    
                    let s1 = "-i \(urlFinal1) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl1)"
                    let s2 = "-i \(urlFinal2) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl2)"
                    let str = "-i \"concat:\(furl2)|\(furl1)\" -c copy \(furl3)"
                    let cmdFinal = "-i \(furl3) \(final)"
                    
                    MobileFFmpeg.execute(s1)
                    MobileFFmpeg.execute(s2)
                    MobileFFmpeg.execute(str)
                    MobileFFmpeg.execute(cmdFinal)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.removeFileIfExists(fileURL: furl1)
                    self.removeFileIfExists(fileURL: furl2)
                    self.removeFileIfExists(fileURL: furl3)
                    self.removeFileIfExists(fileURL: urltf)
                    self.removeFileIfExists(fileURL: url1)
                    self.tfURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.tfURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                        ZKProgressHUD.dismiss(0.5)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    let cmdVideoTF = "-ss \(startTime) -i \(filePath) -to \(tftime) -c copy \(url2)"
                    MobileFFmpeg.execute(cmdVideoTF)
                    let transform = "-i \(url2) -vf \(self.str) -codec:a copy \(urltf)"
                    MobileFFmpeg.execute(transform)
                    self.ratio1 = self.getVideoRatio(url: urltf)
                    let urlFinal1 = self.squareVideo(url: urltf, ratio: self.ratio1)
                    
                    let cmdCutVideo1 = "-ss 0 -i \(filePath) -to \(startTime) -c copy \(url1)"
                    MobileFFmpeg.execute(cmdCutVideo1)
                    self.ratio2 = self.getVideoRatio(url: url1)
                    let urlFinal2 = self.squareVideo(url: url1, ratio: self.ratio2)
                    
                    let cmdCutVideo2 = "-ss \(endTime) -i \(filePath) -to \(lateTime) -c copy \(url3)"
                    MobileFFmpeg.execute(cmdCutVideo2)
                    self.ratio3 = self.getVideoRatio(url: url3)
                    let urlFinal3 = self.squareVideo(url: url3, ratio: self.ratio3)
                    
                    let s1 = "-i \(urlFinal1) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl1)"
                    let s2 = "-i \(urlFinal2) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl2)"
                    let s3 = "-i \(urlFinal3) -c:v mpeg2video -qscale:v 2 -c:a mp2 -b:a 192k \(furl4)"
                    let str = "-i \"concat:\(furl2)|\(furl1)|\(furl4)\" -c copy \(furl3)"
                    
                    let cmdFinal = "-i \(furl3) \(final)"
                    MobileFFmpeg.execute(s1)
                    MobileFFmpeg.execute(s2)
                    MobileFFmpeg.execute(s3)
                    MobileFFmpeg.execute(str)
                    MobileFFmpeg.execute(cmdFinal)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.removeFileIfExists(fileURL: furl1)
                    self.removeFileIfExists(fileURL: furl2)
                    self.removeFileIfExists(fileURL: furl3)
                    self.removeFileIfExists(fileURL: furl4)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: urltf)
                    self.tfURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.tfURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                        ZKProgressHUD.dismiss(0.5)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func flip(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            switch self.currentAnimation{
            case 0:
                self.playerController.view.transform = .identity
                
                self.playerController.view.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.str = "\"hflip\""
            case 1:
                self.playerController.view.transform = .identity
                
            default:
                break
            }
        })
        currentAnimation += 1
        if currentAnimation > 1 {
            currentAnimation = 0
        }
    }
    
    @IBAction func turn(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            switch self.currentAnimation2{
            case 0:
                self.playerController.view.transform = .identity
                self.playerController.view.transform = CGAffineTransform(rotationAngle: .pi / 2)
                self.str = "\"transpose=1\""
            case 1:
                self.playerController.view.transform = .identity
                self.playerController.view.transform = CGAffineTransform(rotationAngle: .pi )
                self.str = "\"transpose=2,transpose=2\""
            case 2:
                self.playerController.view.transform = .identity
                self.playerController.view.transform = CGAffineTransform(rotationAngle: .pi / -2)
                self.str = "\"transpose=2\""
            case 3:
                self.playerController.view.transform = .identity
            default:
                break
            }
        })
        currentAnimation2 += 1
        if currentAnimation2 > 3 {
            currentAnimation2 = 0
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if playerController.player!.isPlaying {
            playerController.player?.pause()
            stopPlaybackTimeChecker()
        } else {
            playerController.player?.play()
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
    }
    
    func changeIconBtnPlay() {
        if playerController.player!.isPlaying {
            playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.black.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        //        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TFVideoViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            playerController.player?.seek(to: startTime)
        }
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let start = trimmerView.startTime, let end = trimmerView.endTime else {
            return
        }
        
        let playbackTime = playerController.player?.currentTime()
        trimmerView.seek(to: playbackTime!)
        
        if playbackTime! >= end {
            playerController.player?.seek(to: start, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: start)
        }
    }
    
    func setlabel() {
        LblStartTime.text = trimmerView.startTime?.positionalTime
        LblEndTime.text = trimmerView.endTime?.positionalTime
    }
    
    func createUrlInApp(name: String ) -> URL {
        return URL(fileURLWithPath: "\(NSTemporaryDirectory())\(name)")
    }
    
    func removeFileIfExists(fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func squareVideo(url : URL, ratio : CGFloat) -> URL{
        let furl1 = createUrlInApp(name: "video1.MOV")
        removeFileIfExists(fileURL: furl1)
        let furl2 = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: furl2)
        let s1 = "-i \(url) \(furl1)"
        MobileFFmpeg.execute(s1)
        if ratio == 1 {
            return url
        }
        else if ratio > 1 {
            let s = "-i \(furl1)  -aspect 1:1 -vf \"pad=iw:ih*\(ratio):(ow-iw)/2:(oh-ih)/2:black\" \(furl2)"
            print(s)
            MobileFFmpeg.execute(s)
        }
        else {
            let s = "-i \(furl1)  -aspect 1:1 -vf \"pad=iw/\(ratio):ih:(ow-iw)/2:(oh-ih)/2:black\" \(furl2)"
            print(s)
            MobileFFmpeg.execute(s)
        }
        removeFileIfExists(fileURL: furl1)
        return furl2
    }
    
    func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func getVideoRatio(url:URL) -> CGFloat{
        let size = resolutionSizeForLocalVideo(url: url)
        return size!.width/size!.height
    }
}
extension TFVideoViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        playerController.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        playerController.player?.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        startPlaybackTimeChecker()
        setlabel()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        playerController.player?.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        playerController.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        setlabel()
    }
}

