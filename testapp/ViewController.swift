//
//  ViewController.swift
//  testapp
//
//  Created by Ryan Paglinawan on 5/16/19.
//  Copyright © 2019 Ryan Paglinawan. All rights reserved.
//

import UIKit
//import PlayerKit
import AVKit
import VimeoNetworking
import SafariServices

//MARK: APP
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var vimeo : VimeoDelegate?
    
//    private let _player : RegularPlayer = RegularPlayer()
    
    var plistData : [String : Any] = [ : ] {
        didSet {
            print("key:\(plistData.keys)\nvalue:\(plistData.values)")
        }
    }
    
    var videoMetadata : [VIMVideo]? {
        didSet {
            // MARK: Debugging output to make sure I am getting my data back
//            print("first vc: \(videoMetadata)")
//            videoMetadata!.forEach{
//                x in
//                print(x.link ?? "No Link")
//            }
            _vimeoPlayerTableView.reloadData()
        }
    }
    
    let vimeoDispatch = DispatchQueue.init(label: "vimeoDispatch")
    
    lazy var _vimeoPlayerTableView : UITableView  = {
        let tableView = UITableView()
        return tableView
    }()
    
//    lazy var _embeddedViewPlayerView : UIView = {
//       let view = UIView(frame: self._player.view.frame)
//        view.addSubview(self._player.view)
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _vimeoPlayerTableView.frame = self.view.frame
        
        _vimeoPlayerTableView.dataSource = self
        _vimeoPlayerTableView.delegate = self
        
//        _player.delegate = self
        
        _vimeoPlayerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "VimeoVideos")
        
        _vimeoPlayerTableView.insetsContentViewsToSafeArea = true
        self.view.addSubview(_vimeoPlayerTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard vimeo != nil else {
            return
        }
        
        vimeoDispatch.async {
            self.videoMetadata = self.vimeo!.loadList()
            print("in dispatcher: \(self.videoMetadata!.count)")
            DispatchQueue.main.async {
                self._vimeoPlayerTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let plistPath : String? = Bundle.main.path(forResource: "VimeoConfig", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        var pListFormat = PropertyListSerialization.PropertyListFormat.xml
        
        vimeoDispatch.async {
            do {
                self.self.plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &pListFormat) as! [String : Any]
                
                self.self.self.vimeo = VimeoDelegate.init(clientID: self.self.plistData["Client ID"] as! String, clientSecret: self.self.plistData["Client Secret"] as! String, scopes: [.Public], keychainServices: "", baseURL: URL(string: "https://vimeo.com/fitplan")!, additional: self.self.plistData)
                
                guard self.self.self.vimeo != nil else {
                    return
                }
                
            } catch {
                print("ERROR")
            }
        }
    }
    
    func showEmdededView(link : String){
//        update constraints
        
//        self._player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self._player.view.frame = self.view.bounds
        print("outgoing link \(link)")
        
//        let vimeoURL = URL(string: link)!
//        self._player.set(AVURLAsset(url: vimeoURL))
//        self.view.insertSubview(_player.view, at: 0)

//        print("embedded view: \(self._embeddedViewPlayerView.frame.height) tableview: \(self._vimeoPlayerTableView.frame.height) playerView: \(_player.view.frame.size)")


//        self.view.addSubview(_embeddedViewPlayerView)
//        UIView.animate(withDuration: 0.5, animations: {
//            self._vimeoPlayerTableView.frame.size.height = self._vimeoPlayerTableView.frame.height - self._embeddedViewPlayerView.frame.height
//        })
        
        let safariVC = SFSafariViewController(url: NSURL(string: link)! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


//MARK: UITableView related code
extension ViewController : SFSafariViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Load video
        guard let video = videoMetadata?[indexPath.row], let link = video.link else {
            return
//            this should be a possible throw value
        }
//        vimeo!.loadURL(extention: video)
        
//        links spawn like this https://vimeo.com/334772450 which is not could not with out making it more coomplicated than it needs to be load ergo why vimeo links on the reddit mobile apps kickback to a webivew
        print(link)
        print(String(describing: video.playRepresentation?.playabilityStatus))
        showEmdededView(link: link)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = videoMetadata?.count else {
            return 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "VimeoVideos"
//        let cell = UITableViewCell(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 500.0))
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        guard let videoTitle = videoMetadata?[indexPath.row].name else {
            cell.textLabel?.text = "Loading..."
            cell.accessibilityHint = "Waiting for videos to load in"
            return cell
        }
        cell.textLabel?.text = videoTitle
//        We can't read out that this is video 0
        cell.accessibilityHint = "Video: \(videoTitle). Tap to Play."
//        setup tableview cell and internalviews
        return cell
    }
    
//    func playerDidUpdateState(player: Player, previousState: PlayerState) {
//        switch player.state {
//        case .loading:
//            print("loading...")
//        case .ready:
//
//            break
//        case .failed:
//            NSLog("Loading failed\(String(describing:player.error))")
//        default:
//            NSLog("😢")
//        }
//    }
//
//    func playerDidUpdatePlaying(player: Player) {
//        print("playing")
//    }
//
//    func playerDidUpdateTime(player: Player) {
//        guard player.duration > 0 else {
//            return
//        }
//    }
//
//    func playerDidUpdateBufferedTime(player: Player) {
//        guard player.duration > 0 else {
//            return
//        }
//    }
}

//MARK: Vimeo API Handler
extension VimeoDelegate {
    func loadList() -> [VIMVideo] {
//        Read from BASE_URL
//        get base_url +/videos
        
        var videoMeta : [VIMVideo] = []
        
        let queryURL = URL(string: "/users/fitplan/videos/")
        let videoRequest = Request<[VIMVideo]>(path: queryURL!.absoluteString)

        let _ = VimeoClient.defaultClient.request(videoRequest) {[weak self] results in
            
            guard let strongRef = self else {
                return
            }
            
            switch results {
            case .success(let response):
                strongRef.vVideo = response.model
                videoMeta = strongRef.vVideo
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
        
        print("within loadList func: \(videoMeta)")
        while videoMeta.isEmpty {
            print("waiting")
        }
        print("broke")
        return videoMeta
    }
}
