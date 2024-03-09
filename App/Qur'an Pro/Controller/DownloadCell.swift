//
//  DownloadCell.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

class DownloadCell: UITableViewCell {

    @IBOutlet var chapterName: UILabel!
    @IBOutlet var downloadState: UILabel!
    @IBOutlet var downlaodSize: UILabel!
    @IBOutlet var downloadPercentage: UILabel!
    @IBOutlet weak var progressView: ABCircularProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isDownloading = false
        // Initialization code
        chapterName.font = kCellTextLabelFont
        chapterName.textColor = kCellTextLabelColor
        downloadPercentage.font = kPercentageFont
        downloadPercentage.textColor = kCellTextLabelColor
        downloadState.font = kDownloadFont
        downloadState.textColor = kAppColor
        downlaodSize.font = kPercentageFont
        downlaodSize.textColor = kCellTextLabelColor
    }

    var isDownloading: Bool! {
        didSet {
            if isDownloading == false {
                progressView.isHidden = true
                downloadPercentage.isHidden = true
                downlaodSize.isHidden = false
                downloadState.isHidden = false
            } else {
                downlaodSize.isHidden = true
                downloadState.isHidden = true
                progressView.isHidden = false
                downloadPercentage.isHidden = false
            }
        }
    }
}
