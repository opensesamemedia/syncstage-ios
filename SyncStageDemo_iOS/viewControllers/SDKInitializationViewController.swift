//
//  SDKInitializationViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import UIKit
import SyncStageSDK

class SDKInitializationViewController: UIViewController {

    @IBOutlet var accessTokenTextView: UITextView!
    @IBOutlet var userPicker: UIPickerView!
    @IBOutlet var initializeSDKButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private let accessTokenKey = "AccessToken"

    var selectedUser: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        accessTokenTextView.layer.borderColor = UIColor.systemGray.cgColor
        accessTokenTextView.layer.borderWidth = 1

        if let accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
            accessTokenTextView.text = accessToken
        }
    }

    func showAlert(with error: SyncStageError) {
        let okAction = UIAlertAction(title: "Ok", style: .default)
        self.presentAlert(with: "Warning", message: "Failed to initiate the SyncStageSDK with error: \(error.localizedDescription)", actions: [okAction])
    }

    @IBAction func initializeSDK(sender: UIButton) {
        if accessTokenTextView.text.isEmpty {
            let okAction = UIAlertAction(title: "Ok", style: .default)
            self.presentAlert(with: "Warning", message: "The access token is missing", actions: [okAction])
            return
        }

        activityIndicator.startAnimating()
        initializeSDKButton.isEnabled = false
        SyncStageManager.shared.initSDK(accessToken: accessTokenTextView.text, userId: selectedUser) { [weak self] error in
            self?.activityIndicator.stopAnimating()
            self?.initializeSDKButton.isEnabled = true

            if let error = error {
                self?.showAlert(with: error)
                return
            }
            if let token = self?.accessTokenTextView.text, let key = self?.accessTokenKey {
                UserDefaults.standard.set(token, forKey: key)
            }
            self?.performSegue(withIdentifier: "Session", sender: self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
}

extension SDKInitializationViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
}

extension SDKInitializationViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "User \(row)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUser = row
    }
}
