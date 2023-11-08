//
//  WhatIsNewPageContentViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import UIKit

class WhatIsNewViewController: UIPageViewController, UIPageViewControllerDataSource {
    @objc var version: Double = 0.0
    @objc var currentIndex: Int = 0
    @objc var viewControllerTitles = [1.2: ["New Reciters".local, "Background Audio".local],
                                1.3: ["Chapter info extended".local, "New Font".local, isIpad ? "Share".local + " Facebook, Twitter, Mail..." : "Share".local + " Facebook, Twitter, Whatsapp...", "Copy verse".local],
                                1.4: ["Ajza' added".local]]

    @objc var viewControllerImages = [1.2: ["new-reciters", "backgound-audio"],
                                1.3: ["chapter-info", "new-font", "share", "copy"],
                                1.4: ["ajza"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self

        let initPageContentViewController = viewControllerAtIndex(0)
        setViewControllers([initPageContentViewController!], direction: .forward, animated: false, completion: nil)
    }

    @objc func viewControllerAtIndex(_ index: Int) -> WINPageContentViewController? {
        if viewControllerTitles[version]!.count == 0 || index >= self.viewControllerTitles[version]!.count {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let pageContentViewController = UIStoryboard.winPageContentViewController()!
        pageContentViewController.imageName = viewControllerImages[version]![index]
        pageContentViewController.titleText = viewControllerTitles[version]![index]
        pageContentViewController.labelVersion = "What is new in".local + " " + String(version)

        pageContentViewController.pageIndex = index
        currentIndex = index

        return pageContentViewController
    }

    // MARK
    // UIPageViewControllerDataSource
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerTitles[version]!.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WINPageContentViewController).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }

        index -= 1

        return viewControllerAtIndex(index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WINPageContentViewController).pageIndex
        if index == NSNotFound {
            return nil
        }

        index += 1

        if index == viewControllerTitles[version]!.count {
            return nil
        }

        return viewControllerAtIndex(index)
    }

}
