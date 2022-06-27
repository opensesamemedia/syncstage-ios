//
//  StreamDetailViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 06/06/2022.
//

import UIKit
import SyncStageSDK

class StreamDetailViewController: StreamBaseViewController {

    @IBOutlet var streamIdLabel: UILabel!
    @IBOutlet var streamNameLabel: UILabel!
    @IBOutlet var isConnectedLabel: UILabel!
    @IBOutlet var qualityLabel: UILabel!
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet var volumeLabel: UILabel!
    @IBOutlet var networkJitterLabel: UILabel!
    @IBOutlet var patcketsOnTimeLabel: UILabel!
    @IBOutlet var networkDelayLabel: UILabel!
    
    var stream: RxStream!

    @IBAction func VolumeChanged(_ sender: Any) {
        let result = SyncStageManager.shared.changeStreamVolume(with: stream.streamId, volume: Int(volumeSlider.value))
        NSLog("Updating volume result: \(result)")
        volumeLabel.text = "\(Int(volumeSlider.value))%"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        streamIdLabel.text = stream.streamId
        streamNameLabel.text = stream.streamName
        isConnectedLabel.text = stream.isConnected ? "true" : "false"
        qualityLabel.text = "\(stream.quality)"
        volumeSlider.value = Float(stream.volume)
        volumeSlider.isEnabled = stream.isConnected
        volumeLabel.text = "\(stream.volume)%"
        networkJitterLabel.text = "\(stream.networkJitterMs ?? 0)"
        patcketsOnTimeLabel.text = "\(stream.packetsOnTime ?? 0)"
        networkDelayLabel.text = "\(stream.networkDelayMs ?? 0)"
    }
    
    override func didEnterBackground() {
        SyncStageManager.shared.disconnect { error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        }
    }
}
