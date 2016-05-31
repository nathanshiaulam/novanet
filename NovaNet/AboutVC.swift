//
//  AboutVC.swift
//  NovaNet
//
//  Created by Nathan Lam on 8/25/15.
//  Copyright (c) 2015 Nova. All rights reserved.
//


import UIKit
import Parse
import Bolts

class AboutVC: ViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!;
    var pageTitles: NSArray!;
    var pageImages: NSArray!;
    
    override func viewDidLoad() {
        let firstString = "At Nova, we believe in the power of connections-that every conversation should count."
        let secondString = "Start a conversation with Novas around you and meet them for a coffee."
        let thirdString = "Create a meet up, an afterwork, study group or another event to bring Novas together."
        let fourthString = "Build your network that will last a lifetime."
        self.pageTitles = NSArray(objects:firstString, secondString, thirdString, fourthString);
        self.pageImages = NSArray(objects: "about_chat_bubbles", "about_map", "about_event", "about_people");
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self;
        
        let startVC = self.viewControllerAtIndex(0) as AboutContentVC;
        let viewControllers = NSArray(object: startVC);
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil);
        self.pageViewController.view.frame = CGRectMake(0,70, self.view.frame.width, self.view.frame.size.height - 90);

        
        self.addChildViewController(self.pageViewController);
        self.view.addSubview(self.pageViewController.view);
        self.pageViewController.didMoveToParentViewController(self);
    }
    
    @IBAction func skipPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func viewControllerAtIndex(index: Int) -> AboutContentVC {
        if (self.pageTitles.count == 0 || index >= self.pageTitles.count) {
            return AboutContentVC();
        }
        
        let vc:AboutContentVC = self.storyboard?.instantiateViewControllerWithIdentifier("AboutContentVC") as! AboutContentVC;
        
        vc.imageFile = self.pageImages[index] as! String;
        vc.titleText =  self.pageTitles[index] as! String;
        vc.pageIndex = index;
        return vc;
    }
    
    // MARK - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! AboutContentVC;
        var index = vc.pageIndex as Int;
        
        if (index == 0 || index == NSNotFound)
        {
            return nil;
        }
        index -= 1;
        return self.viewControllerAtIndex(index);
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! AboutContentVC;
        var index = vc.pageIndex as Int;
        
        if (index == NSNotFound)
        {
            return nil;
        }
        
        index += 1;
        
        if (index == self.pageTitles.count) {
            return nil;
        }
        return self.viewControllerAtIndex(index);
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count;
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0;
    }
    
    
}
