
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
    @IBOutlet weak var trimmerView: TrimmerView!
    
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var arr2 = [ModelBackgroundColor]()
    var playerController = AVPlayerViewController()
    var str = ""
    var path:URL!
    var BgURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var ratio:CGFloat!
    
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
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)))
        
        let player = AVPlayer(url: path as URL)
        
        playerController.player = player
        playerController.view.frame.size.height = videoView.frame.size.height
        playerController.view.frame.size.width = videoView.frame.size.width
        playerController.showsPlaybackControls = false
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height:  videoView.frame.height)
        
        self.videoView.addSubview(playerController.view)
        playerController.player?.play()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ratio = getVideoRatio(url: path as URL)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func play(_ sender: Any) {
    }
    
    @IBAction func background(_ sender: Any) {
        
        let url = squareVideo(url: path as URL, ratio: ratio)
        let final = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: final)
        let s = "-i \(url) \(final)"
        
        playerController.player?.pause()
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.async {
            MobileFFmpeg.execute(s)
            self.BgURL = final
            self.isSave = true
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss(0.5)
                ZKProgressHUD.showSuccess()
            }
        }
    }
    
    
    @IBAction func save(_ sender: Any) {
        if isSave {
            self.delegate.transformBackground(url: self.BgURL!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
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
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
    
    func currentDate()->String{
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddhhmmss"
        return df.string(from: Date())
    }
    func squareVideo(url : URL, ratio : CGFloat) -> URL{
        let furl = createUrlInApp(name: "video1.MOV")
        removeFileIfExists(fileURL: furl)
        let furl2 = createUrlInApp(name: "video2.MOV")
        removeFileIfExists(fileURL: furl2)
        let s1 = "-i \(url) \(furl)"
        MobileFFmpeg.execute(s1)
        if ratio == 1 {
            return url
        }
        else if ratio > 1{
            let s = "-i \(furl)  -aspect 1:1 -vf \"pad=iw:ih*\(ratio):(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(furl2)"
             MobileFFmpeg.execute(s)
        }
        else {
            let s = "-i \(furl)  -aspect 1:1 -vf \"pad=iw/\(ratio):ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(furl2)"

                MobileFFmpeg.execute(s)
        }
        return furl2
    }
    func getVideoRatio(url:URL) -> CGFloat{
        let size = resolutionSizeForLocalVideo(url: url)
        return size!.width/size!.height
    }
    
    func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
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
}

extension BackgroundVideoColorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TrimmerViewDelegate{
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
        return CGSize(width:collectionView.frame.width/10, height: collectionView.frame.width)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playerController.view.backgroundColor = arr2[indexPath.row].uiColor
        switch indexPath.row {
        case 0: str = "eeeeee"
        case 1: str = "dddddd"
        case 2: str = "cccccc"
        case 3: str = "bbbbbb"
        case 4: str = "aaaaaa"
        case 5: str = "999999"
        case 6: str = "888888"
        case 7: str = "777777"
        case 8: str = "666666"
            
        default:
            print(indexPath.row)
        }
        
    }
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
    }
    
}

