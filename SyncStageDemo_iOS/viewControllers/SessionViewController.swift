//
//  SessionViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import Foundation
import UIKit
import SyncStageSDK
import AVFAudio

class SessionViewController: StreamBaseViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var connectionData: ConnectionData?
    var isConnected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.reloadData()
        updateInfo()
    }
    
    override func didEnterBackground() {
        SyncStageManager.shared.disconnect { error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        }
        isConnected = false
        updateConnectionButtonTitle()
        connectionData = nil
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SyncStageManager.shared.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SyncStageManager.shared.delegate = nil
        if self.isMovingFromParent {
            SyncStageManager.shared.disconnect { error in
                if let error = error {
                    NSLog(error.localizedDescription)
                }
            }
        }
    }

    @IBAction func connect(sender: UIButton) {
        activityIndicator.startAnimating()
        connectButton.isEnabled = false
        if isConnected {
            SyncStageManager.shared.disconnect { [weak self] error in
                if let error = error {
                    NSLog(error.localizedDescription)
                }
                self?.updateUI()
                self?.activityIndicator.stopAnimating()
                self?.connectButton.isEnabled = true
            }
        } else {
            SyncStageManager.shared.connect { [weak self] error in
                if let error = error {
                    NSLog(error.localizedDescription)
                    self?.showAlert()
                }
                self?.updateUI()
                self?.activityIndicator.stopAnimating()
                self?.connectButton.isEnabled = true
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Warning",
                                      message: "Session does not exist!",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func updateUI() {
        isConnected.toggle()
        updateConnectionButtonTitle()
        if !isConnected {
            connectionData = nil
            tableView.reloadData()
        }
    }
    
    @IBAction func refresh() {
        connectionData = SyncStageManager.shared.getConnectionData()
        update(with: connectionData)
    }

    func updateConnectionButtonTitle() {
        connectButton.setTitle(isConnected ? "DISCONNECT" : "CONNECT", for: .normal)
    }

    func updateInfo() {
        versionLabel.text = "version \(SyncStageManager.shared.getSDKVersion())"
    }
    
    func update(with connectionData: ConnectionData?) {
        self.connectionData = connectionData
        tableView.reloadData()
        updateConnectionButtonTitle()
    }
}

extension SessionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let connectionData = self.connectionData {
            switch section {
            case 0:
                return 1
            case 1:
                return connectionData.rxStreams.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = connectionData {
            return 2
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Transmitter"
        case 1:
            return "Receivers"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TransmitterCell") as? TransmitterCell {
                if let connectionData = connectionData {
                    let stream = connectionData.txStream
                    cell.streamId.text = "Stream Id: \(stream?.streamId ?? "")"
                    cell.streamNameLabel.text = "Stream Name: \(stream?.streamName ?? "")"
                    cell.isConnectedLabel.text = "Is Connected: \(stream?.isConnected == true ? "true" : "false")"
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StreamCell") as? StreamCell {
                if let connectionData = connectionData {
                    let stream = connectionData.rxStreams[indexPath.row]
                    cell.streamId.text = "Stream Id: \(stream.streamId)"
                    cell.streamNameLabel.text = "Stream Name: \(stream.streamName)"
                    cell.volumeLabel.text = "Stream Volume: \(stream.volume)"
                    cell.isConnectedLabel.text = "Is Connected: \(stream.isConnected)"
                    cell.qualityLabel.text = "Quality: \(stream.quality)"
                    cell.networkJitterLabel.text = "Network Jitter Ms: \(stream.networkJitterMs ?? 0)"
                    cell.patcketsOnTimeLabel.text = "Packets On Time: \(stream.packetsOnTime ?? 0)"
                    cell.networkDelayLabel.text = "Network Delay Ms: \(stream.networkDelayMs ?? 0)"
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension SessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let stream = connectionData?.rxStreams[indexPath.row] {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let streamDetailVC = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as? StreamDetailViewController {
                streamDetailVC.stream = stream
                self.navigationController?.pushViewController(streamDetailVC, animated: true)
            }
        }
    }
}

extension SessionViewController: SyncStageDelegate {
    func onOperationError(errorCode: SyncStageErrorCode, message: String) {
        NSLog(message)
    }
    
    func onConnectionDataChange(connectionData: ConnectionData) {
        NSLog("connectionData changed")
        update(with: connectionData)
    }
    
    func onStreamListChange(connectionData: ConnectionData) {
        NSLog("onStreamListChange changed")
        update(with: connectionData)
    }
}

class StreamCell: UITableViewCell {
    @IBOutlet var streamNameLabel: UILabel!
    @IBOutlet var streamId: UILabel!
    @IBOutlet var isConnectedLabel: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    @IBOutlet var qualityLabel: UILabel!
    @IBOutlet var networkJitterLabel: UILabel!
    @IBOutlet var patcketsOnTimeLabel: UILabel!
    @IBOutlet var networkDelayLabel: UILabel!
}

class TransmitterCell: UITableViewCell {
    @IBOutlet var streamNameLabel: UILabel!
    @IBOutlet var streamId: UILabel!
    @IBOutlet var isConnectedLabel: UILabel!
}
