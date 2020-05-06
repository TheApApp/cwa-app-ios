//
//  SettingsViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
import UIKit
import MessageUI

class SettingsViewController: UIViewController {

    @IBOutlet weak var trackingStatusLabel: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var dataInWifiOnlySwitch: UISwitch!
    @IBOutlet weak var sendLogFileView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    @IBAction func sendLogFile(_ sender: Any) {
        let alert = UIAlertController(title: "Send Log", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Please enter email"
        }

        let action = UIAlertAction(title: "Send Log File", style: .default) { [weak self] _ in
            guard let emailText = alert.textFields?[0].text else {
                return
            }

            if !MFMailComposeViewController.canSendMail() {
                return
            }

            let composeVC = MFMailComposeViewController()
            composeVC.delegate = self
            composeVC.setToRecipients([emailText])
            composeVC.setSubject("Log File")

            guard let logFile = appLogger.getLoggedData() else {
                return
            }
            composeVC.addAttachmentData(logFile, mimeType: "txt", fileName: "Log")

            self?.present(composeVC, animated: true, completion: nil)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

    private func setupView() {
        #if DEBUG
            sendLogFileView.isHidden = false
        #endif
        // receive status of manager
        let status = ENStatus.active
        setTrackingStatus(for: status)
    }

    private func setTrackingStatus(for status: ENStatus) {
        switch status {
        case .active:
            DispatchQueue.main.async {
                self.trackingStatusLabel.text = NSLocalizedString("status_Active", comment: "")
            }
        default:
            DispatchQueue.main.async {
                self.trackingStatusLabel.text = NSLocalizedString("status_Inactive", comment: "")
            }
        }
    }

}

extension SettingsViewController : UINavigationControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
}