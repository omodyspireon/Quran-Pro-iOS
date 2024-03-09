//
//  WINPageContentViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class WINPageContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var exitButton: UIButton!

    @IBOutlet weak var whatIsNewLabel: UILabel!

    @objc var pageIndex: Int = 0
    @objc var titleText: String = ""
    @objc var imageName: String = ""
    @objc var labelVersion: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kAppColor
        self.backgroundImageView.image = UIImage(named: imageName)
        let layer = backgroundImageView.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 3, height: 3)

        whatIsNewLabel.text = labelVersion

        self.titleLabel.text = titleText

        self.exitButton.setTitle(" " + "Continue".local + " ", for: UIControl.State())
        self.exitButton.titleLabel?.textColor = kAppColor
        self.exitButton.layer.borderWidth = 0.1
        self.exitButton.backgroundColor = UIColor.white
        self.exitButton.tintColor = UIColor.black
        self.exitButton.layer.shadowColor = UIColor.black.cgColor
        self.exitButton.layer.shadowOpacity = 0.6
        self.exitButton.layer.shadowRadius = 5
        self.exitButton.layer.shadowOffset = CGSize(width: 3, height: 3)
    }

    @IBAction func exitHandler(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kExitWhatIsNewVCNotification), object: nil, userInfo: nil)
    }
}
