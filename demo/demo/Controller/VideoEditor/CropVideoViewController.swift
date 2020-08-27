import UIKit
import Photos
import PryntTrimmerView
import AVFoundation
import AVKit
import ZKProgressHUD

protocol TransformCropVideoDelegate {
    func transformCropVideo(url: URL)
    func transformTrimVideo(url: URL)
    func transformDuration(url: URL)
    func transformBackground(url: URL)
    func transformReal(url: URL)
    func transformDuplicate(url: URL)
}

class CropVideoViewController: AssetSelectionVideoViewController {
    
    @IBOutlet weak var videoCropView: VideoCropView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var selectRatio: UICollectionView!
    @IBOutlet weak var LblStartTime: UILabel!
    @IBOutlet weak var LblEndTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var player = AVPlayer()
    var playerController = AVPlayerViewController()
    var path : URL!
    var cropURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var array = [RatioCrop]()
    var newRatio: CGSize?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var ratio1: CGFloat!
    var ratio2: CGFloat!
    var ratio3: CGFloat!
    var a = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectRatio.register(UINib(nibName: "CropCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CropCollectionViewCell")
        array.append(RatioCrop(ratio: "1:1"))
        array.append(RatioCrop(ratio: "4:5"))
        array.append(RatioCrop(ratio: "16:9"))
        array.append(RatioCrop(ratio: "9:16"))
        array.append(RatioCrop(ratio: "3:4"))
        array.append(RatioCrop(ratio: "4:3"))
        array.append(RatioCrop(ratio: "2:3"))
        array.append(RatioCrop(ratio: "3:2"))
        array.append(RatioCrop(ratio: "2:1"))
        array.append(RatioCrop(ratio: "1:2"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCropView.setAspectRatio(CGSize(width: 16, height: 9), animated: false)
        let asset = AVAsset(url: path as URL)
        loadAsset(asset)
        setlabel()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func crop(_ sender: Any) {
        
        //        if let selectedTime = selectThumbView.selectedTime, let asset = videoCropView.asset {
        //            let generator = AVAssetImageGenerator(asset: asset)
        //            generator.requestedTimeToleranceBefore = CMTime.zero
        //            generator.requestedTimeToleranceAfter = CMTime.zero
        //            generator.appliesPreferredTrackTransform = true
        //            var actualTime = CMTime.zero
        //            let image = try? generator.copyCGImage(at: selectedTime, actualTime: &actualTime)
        //            if let image = image {
        //                let selectedImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
        //                let croppedImage = selectedImage.crop(in: videoCropView.getImageCropFrame())!
        //                UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        //            }
        try? prepareAssetComposition()
        
        //        }
    }
    
    func prepareAssetComposition() throws {
        
        guard let asset = videoCropView.asset, let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        let assetComposition = AVMutableComposition()
        let frame1Time = CMTime(seconds: 0.2, preferredTimescale: asset.duration.timescale)
        let trackTimeRange = CMTimeRangeMake(start: .zero, duration: frame1Time)
        
        guard let videoCompositionTrack = assetComposition.addMutableTrack(withMediaType: .video,
                                                                           preferredTrackID: kCMPersistentTrackID_Invalid) else {
                                                                            return
        }
        
        try videoCompositionTrack.insertTimeRange(trackTimeRange, of: videoTrack, at: CMTime.zero)
        
        if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
            let audioCompositionTrack = assetComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
        }
        
        let cropFrame = videoCropView.getImageCropFrame()
        
        let w = cropFrame.width
        let h = cropFrame.height
        let x = cropFrame.minX
        let y = cropFrame.minY
        
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        
        let startTime = CGFloat(CMTimeGetSeconds(trimmerView.startTime!))
        let endTime = CGFloat(CMTimeGetSeconds(trimmerView.endTime!))
        let tftime = CGFloat(CMTimeGetSeconds(trimmerView.endTime! - trimmerView.startTime!))
        let lateTime = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)! - trimmerView.endTime!))
        let durationTime = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
        
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
        player.pause()
        
        if a == -1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            if (startTime == 0 && endTime == durationTime) {
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let crop = "-i \(filePath) -vf \"crop=\(w):\(h):\(x):\(y)\" \(final)"
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(crop)
                    self.cropURL = final
                    self.delegate.transformCropVideo(url: self.cropURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                        ZKProgressHUD.dismiss(0.5)
                        self.navigationController?.popViewController(animated: true)
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
                    let crop = "-i \(url2) -vf \"crop=\(w):\(h):\(x):\(y)\" \(urltf)"
                    MobileFFmpeg.execute(crop)
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
                    self.cropURL = final
                    self.delegate.transformCropVideo(url: self.cropURL!)
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
                    let crop = "-i \(url2) -vf \"crop=\(w):\(h):\(x):\(y)\" \(urltf)"
                    MobileFFmpeg.execute(crop)
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
                    self.cropURL = final
                    self.delegate.transformCropVideo(url: self.cropURL!)
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
                    let crop = "-i \(url2) -vf \"crop=\(w):\(h):\(x):\(y)\" \(urltf)"
                    MobileFFmpeg.execute(crop)
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
                    self.cropURL = final
                    self.delegate.transformCropVideo(url: self.cropURL!)
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
    @IBAction func play(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            stopPlaybackTimeChecker()
        } else {
            player.play()
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
    }
    
    override func loadAsset(_ asset: AVAsset) {
        addVideoPlayer(with: asset, playerView: videoCropView.videoScrollView)
        videoCropView.asset = asset
        trimmerView.asset = asset
        trimmerView.delegate = self
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
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player.seek(to: startTime)
        }
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
    }
    
    func setlabel() {
        LblStartTime.text = trimmerView.startTime?.positionalTime
        LblEndTime.text = trimmerView.endTime?.positionalTime
    }
    
    func changeIconBtnPlay() {
        if player.isPlaying {
            playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    func startPlaybackTimeChecker() {
        
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(TrimmerViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        
        guard let start = trimmerView.startTime, let end = trimmerView.endTime else {
            return
        }
        
        let playbackTime = player.currentTime()
        trimmerView.seek(to: playbackTime)
        
        if playbackTime >= end {
            player.seek(to: start, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: start)
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

extension CropVideoViewController: ThumbSelectorViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CropCollectionViewCell", for: indexPath) as! CropCollectionViewCell
        let data = array[indexPath.row]
        cell.initView(ratio: data.ratio)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.width/6.1, height: collectionView.frame.height/1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        a = indexPath.row
        switch a {
        case 0:
            newRatio = CGSize(width: 1, height: 1)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 1:
            newRatio = CGSize(width: 4, height: 5)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 2:
            newRatio = CGSize(width: 16, height: 9)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 3:
            newRatio = CGSize(width: 9, height: 16)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 4:
            newRatio = CGSize(width: 3, height: 4)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 5:
            newRatio = CGSize(width: 4, height: 3)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 6:
            newRatio = CGSize(width: 2, height: 3)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 7:
            newRatio = CGSize(width: 3, height: 2)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 8:
            newRatio = CGSize(width: 2, height: 1)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 9:
            newRatio = CGSize(width: 1, height: 2)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        default:
            print(a)
        }
    }
    
    func didChangeThumbPosition(_ imageTime: CMTime) {
        videoCropView.player?.seek(to: imageTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

extension CropVideoViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        startPlaybackTimeChecker()
        setlabel()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        setlabel()
    }
}
