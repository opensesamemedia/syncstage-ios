//
//  MicrophoneAccessViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import UIKit
import AVFAudio

class MicrophoneAccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    func openSettings(alert: UIAlertAction!) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showAlert() {
        let openAction = UIAlertAction(title: "Open Settings",
                                      style: UIAlertAction.Style.default,
                                      handler: openSettings)
        let cancelAction = UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                      handler: nil)
        self.presentAlert(with: "Settings", message: "Please enable microphone access in the application settings", actions: [openAction, cancelAction])
    }

    @IBAction func requestAccess(sender: UIButton) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            NSLog("Access denied")
            showAlert()
        case .granted:
            NSLog("Access granted")
            self.performSegue(withIdentifier: "initializeSDK", sender: self)
        case .undetermined:
            NSLog("Access undetermined")
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.performSegue(withIdentifier: "initializeSDK", sender: self)
                    } else {
                        self?.showAlert()
                    }
                }
            }
        @unknown default:
            NSLog("Unkown")
        }
    }
}

extension UIViewController {
    func presentAlert(with title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        actions.forEach { action in
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
