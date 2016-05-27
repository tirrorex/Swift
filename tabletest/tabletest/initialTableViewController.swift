//
//  initialTableViewController.swift
//  tabletest
//
//  Created by thibaut noah on 23/09/15.
//  Copyright © 2015 web-improving. All rights reserved.
//

import UIKit
import QuartzCore
class initialTableViewController: UITableViewController, UINavigationBarDelegate, UIGestureRecognizerDelegate {
    
    var sections:[String] = []
    var items:[[String]] = []
    var autoscrollTimer = NSTimer()
    var autoscrollDistance = NSInteger()
    var autoscrollThreshold = NSInteger()
    private let pingInterval = 0.3
    private var isAutoScrolling = false
    private var draggingView: UIView?
    var longpress: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Auto-set the UITableViewCells height (requires iOS8)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        self.tableView.registerClass(CustomViewCell.self, forCellReuseIdentifier: "Cell")
        longpress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        self.tableView.addGestureRecognizer(longpress)
        
        addSection("Pizza", item: ["Margherita","BBQ Chicken","Pepperoni","Sausage","Seafood","Special"])
        addSection("Deep Dish Pizza", item: ["Sausage","Meat Lover's","Veggie Lover's","BBQ Chicken","Mushroom","Special"])
        addSection("Calzone", item: ["Sausage","Chicken Pesto","Prawns and Mushrooms","Primavera", "Meatball"])
        addSection("test", item: ["yolo","truc Pesto","machin and Mushrooms","Primavera", "Meatball"])
        
    }
    
    struct Drag {
        static var placeholderView: UIView!
        static var sourceIndexPath: NSIndexPath!
    }
    
    func addSection(section: String, item:[String]){
        sections += [section]
        items += [item]
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)
        switch gesture.state {
        case .Began:
            if let indexPath = indexPath
            {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
                Drag.sourceIndexPath = indexPath
                
                // center the snapshot view with current location
                var center = cell.center
                Drag.placeholderView = placeholderFromView(cell)
                Drag.placeholderView.center = center
                Drag.placeholderView.alpha = 0
                
                tableView.addSubview(Drag.placeholderView)
                
                // transform the cell selected to the special snapshot view and hide the cell
                UIView.animateWithDuration(0.25, animations: {
                    center.y = point.y
                    Drag.placeholderView.center = center
                    Drag.placeholderView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    Drag.placeholderView.alpha = 0.95
                    cell.alpha = 0
                    }, completion: { (_) in
                        cell.hidden = true
                })
            }
        case .Changed:
            guard let indexPath = indexPath else
            {
                return
            }
            if !isAutoScrolling
            {
                let scroller = self.shouldAutoScroll(previousTouchLocation: point)
                if  (scroller.shouldScroll) {
                    self.autoScroll(scroller.direction)
                    self.isAutoScrolling = true
                }
                else
                {
                    // recenter the snapshot view with current location
                    var center = Drag.placeholderView.center
                    center.y = point.y
                    Drag.placeholderView.center = center
                }
            }
                if indexPath != Drag.sourceIndexPath
                {
                    // swap the data between the 2 (internal) arrays
                    let dataPiece = self.items[Drag.sourceIndexPath.section][Drag.sourceIndexPath.row]
                    self.items[indexPath.section].insert(dataPiece, atIndex: indexPath.row)
                    self.items[Drag.sourceIndexPath.section].removeAtIndex(Drag.sourceIndexPath.row)
                    
                    //------=-=-=-=[
                    // This line errors when it is uncommented. When I comment it out, the error is gone,
                    // and the cells /do/ reorder.. ¯\_(ツ)_/¯
                    // swap(&currentList.orderItems[indexPath.row], &currentList.orderItems[Drag.sourceIndexPath.row])
                    self.tableView.moveRowAtIndexPath(Drag.sourceIndexPath, toIndexPath: indexPath)
                    Drag.sourceIndexPath = indexPath
//                    print("test")
                    // error is definitly here imo but cannot find it :/
                }

        case .Ended:
            if let cell = tableView.cellForRowAtIndexPath(Drag.sourceIndexPath)
            {
                // unhide the cell and untransform + delete the snapshot view
                cell.hidden = false
//                cell.alpha = 0
                UIView.animateWithDuration(0.25, animations: {
                    Drag.placeholderView.center = cell.center
                    // reset the transformation
                    Drag.placeholderView.transform = CGAffineTransformIdentity
                    Drag.placeholderView.alpha = 0
                    cell.alpha = 1
                    }, completion: { (_) in
                        Drag.sourceIndexPath = nil
                        Drag.placeholderView.removeFromSuperview()
                        Drag.placeholderView = nil
                })
            }
        default: ()
        }
    }
    
    // create the snapshot view
    func placeholderFromView(view: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        // set the snapshowview with shadow etc
        let snapshotView : UIView = UIImageView(image: image)
        snapshotView.layer.masksToBounds = false
        snapshotView.layer.cornerRadius = 0.0
        snapshotView.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshotView.layer.shadowRadius = 5.0
        snapshotView.layer.shadowOpacity = 0.4
        return snapshotView
    }
    
    //AutoScroll direction enum
    enum AutoScrollDirection: Int {
        case Invalid = 0
        case TowardsOrigin = 1
        case AwayFromOrigin = 2
    }
    
    private func autoScroll(direction: AutoScrollDirection)
    {
        let currentLongPressTouchLocation = longpress.locationInView(self.tableView)
        var increment: CGFloat
        var newContentOffset: CGPoint
        if (direction == AutoScrollDirection.TowardsOrigin) {
            increment = -50.0
        } else {
            increment = 50.0
        }
        // calculate offset and set the corresponding scrolling direction if offset is on the frame
        newContentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y + increment)
        if ((direction == AutoScrollDirection.TowardsOrigin && newContentOffset.y < 0) || (direction == AutoScrollDirection.AwayFromOrigin && newContentOffset.y > self.tableView.contentSize.height - self.tableView.frame.height))
        {
            dispatchOnMainQueueAfterDelay(0.0, closure: { () -> () in
                self.isAutoScrolling = false
            })
        } else
        {
            UIView.animateWithDuration(0.3
                , delay: 0.0
                , options: UIViewAnimationOptions.CurveLinear
                , animations:
                { () -> Void in

                    // modify the .center so that the snapshot view will follow the scrolling
                    var center = Drag.placeholderView.center
                    center.y = currentLongPressTouchLocation.y + increment
                    Drag.placeholderView.center = center
                    
                    self.tableView.setContentOffset(newContentOffset, animated: false)
                    if (self.draggingView != nil)
                    {
                        var draggingFrame = self.draggingView!.frame
                        draggingFrame.origin.y += increment
                        self.draggingView!.frame = draggingFrame
                    }
                }) { (finished) -> Void in
                    // update the touch location with the new offset and check if need to scroll again
                    self.dispatchOnMainQueueAfterDelay(0.0, closure: { () -> () in
                        let updatedTouchLocationWithNewOffset = CGPoint(x: currentLongPressTouchLocation.x, y: currentLongPressTouchLocation.y + increment)
                        let scroller = self.shouldAutoScroll(previousTouchLocation: updatedTouchLocationWithNewOffset)
                        if scroller.shouldScroll {
                            self.autoScroll(scroller.direction)
                        } else {
                            self.isAutoScrolling = false
                        }
                    })
            }
        }
    }
    
    private func shouldAutoScroll(previousTouchLocation previousTouchLocation: CGPoint) -> (shouldScroll: Bool, direction: AutoScrollDirection)
    {
        let previousTouchLocation = self.tableView.convertPoint(previousTouchLocation, toView: self.tableView.superview)
        let currentTouchLocation = longpress.locationInView(self.tableView.superview)
        
        if currentTouchLocation.x != NSDecimalNumber.notANumber() && currentTouchLocation.y != NSDecimalNumber.notANumber() {
            if distanceBetweenPoints(previousTouchLocation, secondPoint: currentTouchLocation) < CGFloat(20.0)
            {
                var scrollBoundsSize: CGSize
                let scrollBoundsLength: CGFloat = 50.0
                var scrollRectAtEnd: CGRect
                scrollBoundsSize = CGSize(width: self.tableView.frame.width, height: scrollBoundsLength)
                
                // create square zones to scroll to
                scrollRectAtEnd = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y + self.tableView.frame.height - scrollBoundsSize.height, width: self.tableView.frame.width, height: scrollBoundsSize.height)
                let scrollRectAtOrigin = CGRect(origin: self.tableView.frame.origin, size: scrollBoundsSize)
                
                // calculate if the current location is either on the top or bottom square zone
                if scrollRectAtOrigin.contains(currentTouchLocation) {
                    return (true, AutoScrollDirection.TowardsOrigin)
                } else if scrollRectAtEnd.contains(currentTouchLocation) {
                    return (true, AutoScrollDirection.AwayFromOrigin)
                }
            }
        }
        return (false, AutoScrollDirection.Invalid)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items[section].count
    }
    
//    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        super.tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
//        print("log")
//    }
//    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomViewCell
        
        // setting up the cells
        //        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        //        tapGestureRecognizer.numberOfTapsRequired = 1
        //        tapGestureRecognizer.numberOfTouchesRequired = 1
        cell.tag = indexPath.row
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        cell.label.frame = CGRectMake(20, 0, screenWidth - 20, 44)
        cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //NSLog("You selected cell number: \(indexPath.row)!")
    }
    
    // MARK: - Helper methods
    
    func dispatchOnMainQueueAfterDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func distanceBetweenPoints(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let xDistance = firstPoint.x - secondPoint.x
        let yDistance = firstPoint.y - secondPoint.y
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }
    
}
