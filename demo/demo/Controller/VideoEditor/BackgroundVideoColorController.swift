
import UIKit
import AVKit
import AVFoundation
import ZKProgressHUD
import AssetsLibrary
import Photos
import PryntTrimmerView

class BackgroundVideoColorController: UIViewController {
    @IBOutlet weak var collBgColor: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var LblStartTime: UILabel!
    @IBOutlet weak var LblEndTime: UILabel!
    
    var player = AVPlayer()
    var arr2 = [ModelBackgroundColor]()
    var playerController = AVPlayerViewController()
    var str = ""
    var path:URL!
    var BgURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var ratio:CGFloat!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var ratio1: CGFloat!
    var ratio2: CGFloat!
    var ratio3: CGFloat!
    var s = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collBgColor.register(UINib(nibName: "BackgroundColorViewCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundColorViewCell")
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 187/255, green: 187/255, blue: 187/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 250/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 221/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 204/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 187/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 170/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 153/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 136/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 119/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 85/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 68/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 51/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 34/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 17/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 153/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 51/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 204/255, green: 240/255, blue: 195/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 188/255, green: 163/255, blue: 202/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 124/255, green: 71/255, blue: 137/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 74/255, green: 14/255, blue: 92/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 0/255, green: 106/255, blue: 113/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 221/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 203/255, green: 234/255, blue: 237/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 211/255, green: 222/255, blue: 50/255, alpha: 1)))
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ratio = getVideoRatio(url: path as URL)
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
    
    @IBAction func play(_ sender: Any) {
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
    
    @IBAction func save(_ sender: Any) {
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        playerController.player?.pause()
        
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
            print("No BG")
        } else {
            if (startTime == 0 && endTime == durationTime) {
                if str == "" {
                    print("No Edit")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    DispatchQueue.main.async {
                        ZKProgressHUD.show()
                    }
                    if ratio == 1 {
                        print("No BG")
                        s = "-i \(filePath)  -aspect 1:1 -vf \"pad=iw:ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(final)"
                    }
                    else if ratio > 1{
                        s = "-i \(filePath)  -aspect 1:1 -vf \"pad=iw:ih*\(ratio!):(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(final)"
                    }
                    else {
                        s = "-i \(filePath)  -aspect 1:1 -vf \"pad=iw/\(ratio!):ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(final)"
                    }
                    let serialQueue = DispatchQueue(label: "serialQueue")
                    serialQueue.async {
                        MobileFFmpeg.execute(self.s)
                        self.BgURL = final
                        self.isSave = true
                        self.delegate.transformBackground(url: self.BgURL!)
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
                    if self.ratio == 1 {
                        print("No BG")
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw:ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    else if self.ratio > 1{
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw:ih*\(self.ratio!):(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    else {
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw/\(self.ratio!):ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    MobileFFmpeg.execute(self.s)
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
                    self.BgURL = final
                    self.isSave = true
                    self.delegate.transformBackground(url: self.BgURL!)
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
                    if self.ratio == 1 {
                        print("No BG")
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw:ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    else if self.ratio > 1{
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw:ih*\(self.ratio!):(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    else {
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw/\(self.ratio!):ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    MobileFFmpeg.execute(self.s)
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
                    self.BgURL = final
                    self.isSave = true
                    self.delegate.transformBackground(url: self.BgURL!)
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
                    if self.ratio == 1 {
                        print("No BG")
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw:ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    else if self.ratio > 1{
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw:ih*\(self.ratio!):(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    else {
                        self.s = "-i \(url2)  -aspect 1:1 -vf \"pad=iw/\(self.ratio!):ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(urltf)"
                    }
                    MobileFFmpeg.execute(self.s)
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
                    self.BgURL = final
                    self.isSave = true
                    self.delegate.transformBackground(url: self.BgURL!)
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
    //    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
    //        let playerItem = AVPlayerItem(asset: asset)
    //        player = AVPlayer(playerItem: playerItem)
    //        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
    //        layer.backgroundColor = UIColor.white.cgColor
    //        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
    //        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    //        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
    //        playerView.layer.addSublayer(layer)
    //    }
    
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
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BackgroundVideoColorController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
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

extension BackgroundVideoColorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundColorViewCell", for: indexPath) as! BackgroundColorViewCell
        let data = arr2[indexPath.row]
        cell.initView(uiColor: data.uiColor )
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.width/15, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playerController.view.backgroundColor = arr2[indexPath.row].uiColor
        switch indexPath.row {
        case 0: str = "EEEEEE"
        case 1: str = "DDDDDD"
        case 2: str = "CCCCCC"
        case 3: str = "BBBBBB"
        case 4: str = "AAAAAA"
        case 5: str = "999999"
        case 6: str = "888888"
        case 7: str = "777777"
        case 8: str = "666666"
        case 9: str = "555555"
        case 10: str = "444444"
        case 11: str = "333333"
        case 12: str = "222222"
        case 13: str = "111111"
        case 14: str = "000000"
        case 15: str = "FF0000"
        case 16: str = "DD0000"
        case 17: str = "CC0000"
        case 18: str = "BB0000"
        case 19: str = "AA0000"
        case 20: str = "990000"
        case 21: str = "880000"
        case 22: str = "770000"
        case 23: str = "660000"
        case 24: str = "550000"
        case 25: str = "440000"
        case 26: str = "330000"
        case 27: str = "220000"
        case 28: str = "110000"
        case 29: str = "FFFFFF"
        case 30: str = "FFFFCC"
        case 31: str = "FFFF99"
        case 32: str = "FFFF66"
        case 33: str = "FFFF33"
        case 34: str = "ccf0c3"
        case 35: str = "bca3ca"
        case 36: str = "7c4789"
        case 37: str = "4a0e5c"
        case 38: str = "006a71"
        case 39: str = "ffffdd"
        case 40: str = "cbeaed"
        case 41: str = "d3de32"
        case 42: str = "CCCCCC"
        case 43: str = "BBBBBB"
        case 44: str = "AAAAAA"
        case 45: str = "999999"
        case 46: str = "888888"
        case 47: str = "777777"
        case 48: str = "666666"
        case 49: str = "555555"
            
        default:
            print(indexPath.row)
        }
    }
}
extension BackgroundVideoColorController: TrimmerViewDelegate {
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
