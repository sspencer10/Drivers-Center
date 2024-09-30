//
//  SendMsg.swift
//  Drivers Center
//
//  Created by Steven Spencer on 8/16/24.
//

import UIKit
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    static let shared = MessageComposer()
    
    private override init() {}

    func presentMessageComposer(with message: MessageToSend) {
        guard MFMessageComposeViewController.canSendText() else {
            // Handle the case where SMS services are not available
            print("SMS unavailable")
            return
        }
        let str = "driverscenter://"
        let url: URL = URL(string: str)!
        TemplateManager().carplayScene?.open(url, options: nil, completionHandler: nil)
        let messageVC = MFMessageComposeViewController()
        messageVC.body = message.body
        messageVC.recipients = [message.recipient]
        messageVC.messageComposeDelegate = self

        
    }

    // MARK: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

struct MessageToSend {
    let recipient: String
    let body: String
}
