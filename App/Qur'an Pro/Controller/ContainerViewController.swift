//
//  ContainerViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

enum SlideOutState {
    case bothCollapsed
    case chaptersPanelExpanded
    case morePanelExpanded
}

import UIKit

class ContainerViewController: UIViewController, CenterViewControllerDelegate, UIGestureRecognizerDelegate, SKStoreProductViewControllerDelegate {

    @objc var centerNavigationController: UINavigationController!
    @objc var centerViewController: CenterViewController!

    @objc var chaptersNavigationController: UINavigationController!
    @objc var chaptersViewController: ChaptersViewController?

    @objc var moreNavigationController: UINavigationController!
    @objc var moreViewController: MoreViewController?
    @objc var whatIsNewViewController: WhatIsNewViewController?
    var currentState: SlideOutState = SlideOutState.bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != SlideOutState.bothCollapsed
            self.showShadowForCenterViewController(shouldShowShadow)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.exitWhatIsNewVCdHandler(_:)), name: NSNotification.Name(rawValue: kExitWhatIsNewVCNotification), object: nil)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "openSKControllerHandler:", name:kOpenSKControllerNotification, object: nil)

//        let defaults = NSUserDefaults.standardUserDefaults()
//        let currentVersion = Double(kApplicationVersion as String)
        if isPro {
//            //what is new in 1.4
//            if currentVersion == 1.4  && defaults.stringForKey(kWhatIsNew1dot4) == nil {
//                whatIsNewViewController = WhatIsNewViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
//                whatIsNewViewController?.version = 1.4
//                view.addSubview(whatIsNewViewController!.view)
//                addChildViewController(whatIsNewViewController!)
//                defaults.setObject("new_in_1.4", forKey: kWhatIsNew1dot4)
//            }
//            else{
                initCenterViewControllers()
//            }
        } else {
            initCenterViewControllers()
        }
    }

    @objc func initCenterViewControllers() {

        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self

        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChild(centerNavigationController)

        centerNavigationController.didMove(toParent: self)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

    }

    @objc func exitWhatIsNewVCdHandler(_ notification: Notification) {
        if whatIsNewViewController != nil {
            whatIsNewViewController!.view.removeFromSuperview()
            whatIsNewViewController!.removeFromParent()
            whatIsNewViewController = nil
        }
        initCenterViewControllers()
    }

    /*func openSKControllerHandler(notification: NSNotification){
        let storeViewController:SKStoreProductViewController = SKStoreProductViewController()
        storeViewController.delegate = self;
        let someitunesid:String = kQuranProId;
        let productparameters = [SKStoreProductParameterITunesItemIdentifier:someitunesid];
        storeViewController.loadProductWithParameters(productparameters, completionBlock: {success, error in
            if success {
                print(success)
                //self.presentViewController(storeViewController, animated: true, completion: nil);
                //self.view.addSubview(storeViewController.view)
                //self.addChildViewController(storeViewController)
                self.centerNavigationController.presentViewController(storeViewController, animated: false, completion: {
                    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
                })
            } else {
                print(error)
            }
        })
    }*/

    // this is SKStoreProductViewControllerDelegate implementation
    override func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: false, completion: nil)
    }

    // MARK: CenterViewController delegate methods

    func toggleChaptersPanel() {
        let notAlreadyExpanded = (currentState != SlideOutState.chaptersPanelExpanded)
        if notAlreadyExpanded {
            addCategoriesPanelViewController()
        }

        animateCategoriesPanel(shouldExpand: notAlreadyExpanded, duration: 0.5)
    }

    func toggleMorePanel() {

        let notAlreadyExpanded = (currentState != SlideOutState.morePanelExpanded)
        if notAlreadyExpanded {
            addMorePanelViewController()
        }

        animateMoretPanel(shouldExpand: notAlreadyExpanded, duration: 0.5)
    }

    @objc func addCategoriesPanelViewController() {

        if chaptersViewController == nil {
            chaptersViewController = UIStoryboard.chaptersViewController()
            chaptersNavigationController = UINavigationController(rootViewController: chaptersViewController!)
        }
        if chaptersNavigationController.view.superview == nil {
            view.insertSubview(chaptersNavigationController!.view, at: 0)
            addChild(chaptersNavigationController!)
        }
        chaptersNavigationController!.didMove(toParent: self)
    }

    @objc func addMorePanelViewController() {
        if moreViewController == nil {
            moreViewController = UIStoryboard.moreViewController()
            moreNavigationController = UINavigationController(rootViewController: moreViewController!)
        }

        if moreNavigationController.view.superview == nil {
            view.insertSubview(moreNavigationController!.view, at: 0)
            addChild(moreNavigationController!)
        }
        moreNavigationController!.didMove(toParent: self)
    }

    @objc func animateCategoriesPanel(shouldExpand: Bool, duration: TimeInterval) {
        if shouldExpand {
            currentState = SlideOutState.chaptersPanelExpanded
            self.chaptersNavigationController.view.frame.size.width = centerNavigationController.view.frame.width - kCenterPanelExpandedOffset
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - kCenterPanelExpandedOffset, duration: duration)
        } else {
            animateCenterPanelXPosition(targetPosition: 0, duration: duration) { _ in
                self.currentState = SlideOutState.bothCollapsed

                self.chaptersViewController?.view.removeFromSuperview()
                self.chaptersNavigationController?.view.removeFromSuperview()
                // self.chaptersViewController = nil
               // self.chaptersNavigationController = nil
            }
        }
    }

    @objc func animateMoretPanel(shouldExpand: Bool, duration: TimeInterval) {
        if shouldExpand {
            currentState = SlideOutState.morePanelExpanded
            self.moreNavigationController.view.frame.origin.x = kCenterPanelExpandedOffset
            self.moreNavigationController.view.frame.size.width = centerNavigationController.view.frame.width - kCenterPanelExpandedOffset
            self.moreNavigationController.view.frame.size.height = centerNavigationController.view.frame.height
            animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width + kCenterPanelExpandedOffset, duration: duration)
        } else {
            animateCenterPanelXPosition(targetPosition: 0, duration: 0.5) { _ in
                self.currentState = SlideOutState.bothCollapsed

                self.moreViewController!.view.removeFromSuperview()
                self.moreNavigationController?.view.removeFromSuperview()
                // self.moreViewController = nil
                // self.moreNavigationController = nil
            }
        }
    }

    @objc func animateCenterPanelXPosition(targetPosition: CGFloat, duration: TimeInterval, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }

    @objc func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }

    func isPanelVisble() -> Int {
        switch currentState {
        case SlideOutState.morePanelExpanded:
            return 1
        case SlideOutState.chaptersPanelExpanded:
            return 1
        default:
            break
        }
        return 0
    }

    func collapseSidePanels() {
        switch currentState {
        case SlideOutState.morePanelExpanded:
            toggleMorePanel()
        case SlideOutState.chaptersPanelExpanded:
            toggleChaptersPanel()
        default:
            break
        }
    }

    // MARK: Gesture recognizer
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)

        switch recognizer.state {
        case .began:
            if currentState == SlideOutState.bothCollapsed {
                if gestureIsDraggingFromLeftToRight {
                    addCategoriesPanelViewController()
                } else {
                    addMorePanelViewController()
                }
                showShadowForCenterViewController(true)
            }
        case .changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
            recognizer.setTranslation(CGPoint.zero, in: view)
        case .ended:
            if chaptersNavigationController != nil && chaptersNavigationController.view.superview != nil {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateCategoriesPanel(shouldExpand: hasMovedGreaterThanHalfway, duration: 0.5)
            } else if moreNavigationController != nil && moreNavigationController.view.superview != nil {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateMoretPanel(shouldExpand: hasMovedGreaterThanHalfway, duration: 0.5)
            }
        default:
            break
        }
    }

    // MARK: Orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if self.currentState == SlideOutState.morePanelExpanded {
                self.animateMoretPanel(shouldExpand: true, duration: 0.0)
            } else if self.currentState == SlideOutState.chaptersPanelExpanded {
                self.animateCategoriesPanel(shouldExpand: true, duration: 0.0)
            }
            }, completion: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
        })
    }
}
