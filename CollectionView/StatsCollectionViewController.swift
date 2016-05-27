//
//  StatsCollectionViewController.swift
//  Smartertime
//
//  Created by thibaut noah on 13/10/15.
//  Copyright © 2015 Smarter Time. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class StatsCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    var arrayForBool : [Bool] = []
    var sections:[String] = []
    var items:[[String]] = []
    var itemsBis:[[String]] = []
    var itemsTres:[[String]] = []
    var mapCategory = JavaUtilHashMap()
    var mapTime = JavaUtilHashMap()
    var category:[String] = []
    var cellDisplay: [String] = []
    var draggedCellIndexPath: NSIndexPath?
    var draggedCellIndexPathOnLocation: NSIndexPath?
    var draggingView: UIView?
    var touchOffsetFromCenterOfCell: CGPoint?
    var isWiggling = false
    let pingInterval = 0.3
    var isAutoScrolling = false
    
    // init UILongPressGestureRecognizer for the drag & drop
    var longPressRecognizer: UILongPressGestureRecognizer = {
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.delaysTouchesBegan = false
        longPressRecognizer.cancelsTouchesInView = false
        longPressRecognizer.numberOfTouchesRequired = 1
        longPressRecognizer.minimumPressDuration = 0.1
        longPressRecognizer.allowableMovement = 10.0
        return longPressRecognizer
        }()
    
    var sectionCell: UICollectionReusableView?
    var tempSectionIndex = Int()
    var tempPath: NSIndexPath?
    
    static var selectedPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.registerClass(StatsCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(StatsCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        
        // set offset for top and bottom (navigation bar and tab bar)
        self.collectionView?.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
        
        // Do any additional setup after loading the view.
        //        category = ["TRANSPORT", "ART & ENTERTAINMENT", "UNKNOWN","CHORES", "HEALTH & HYGIENE", "HOBBIES", "PERSONAL LIFE", "PROFESIONAL LIFE", "RESTING", "SOCIAL", "SPORT & FITNESS"]
        //        for var index = 0; index < category.count; ++index{
        //            arrayForBool.append(false)
        //        }
        //        mapCategory.putWithId(11, withId: 1)
        //        mapCategory.putWithId(20, withId: 2)
        //        mapCategory.putWithId(42, withId: 5)
        //        mapCategory.putWithId(103, withId: 9)
        //        mapCategory.putWithId(51, withId: 2)
        //        mapCategory.putWithId(66, withId: 5)
        //        mapCategory.putWithId(21, withId: 0)
        //        mapTime.putWithId(11, withId: 10.00)
        //        mapTime.putWithId(20, withId: 720.00)
        //        mapTime.putWithId(42, withId: 150.00)
        //        mapTime.putWithId(103, withId: 60.00)
        //        mapTime.putWithId(51, withId: 6000.00)
        //        mapTime.putWithId(66, withId: 360.00)
        //        mapTime.putWithId(21, withId: 400.20)
        sections = []
        addSection("Pizza", item: ["Margherita","BBQ Chicken","Pepperoni","Sausage","Seafood","Special"], boolArray: true )
        addSection("Deep Dish Pizza", item: ["Sausage","Meat Lover's","Veggie Lover's","BBQ Chicken","Mushroom","Special"], boolArray: true)
        addSection("Calzone", item: ["Sausage","Chicken Pesto","Prawns and Mushrooms","Primavera", "Meatball"], boolArray: true)
        addSection("test", item: ["yolo","truc Pesto","machin and Mushrooms","Primavera", "Meatball"], boolArray: true)
        
        // adding UILongPressGestureRecognizer to the view
        longPressRecognizer.addTarget(self, action: "handleLongPress:")
        self.collectionView!.addGestureRecognizer(longPressRecognizer)
        self.collectionView!.backgroundColor = UIColor.orangeColor()
        self.automaticallyAdjustsScrollViewInsets = false
        itemsBis = items
        itemsTres = items
        // activity and duration
        let day = STMODay()
        STUSTimeslotHistory_getDurationHashmapWithSTMODay_withSTMODay_withBoolean_(day, day, false)
        
        let categories = STDACategories_getCategories()
    }
    
    func addSection(section: String, item:[String], boolArray: Bool){
        sections += [section]
        arrayForBool += [boolArray]
        items += [item]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("stats collectionview warning")
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Drag & Drop
    
    func handleLongPress(longPressRecognizer: UILongPressGestureRecognizer)
    {
        // get the current location inside the view
        let touchLocation = longPressRecognizer.locationInView(self.collectionView)
        switch (longPressRecognizer.state) {
        case UIGestureRecognizerState.Began:
            
            // get indexPath from location
            draggedCellIndexPath = self.collectionView!.indexPathForItemAtPoint(touchLocation)
            if draggedCellIndexPath != nil {
                
                // get cel for indexPath and create visual copy of the cell
                let draggedCell = self.collectionView?.cellForItemAtIndexPath(draggedCellIndexPath!) as UICollectionViewCell!
                draggingView = UIImageView(image: getRasterizedImageCopyOfCell(draggedCell))
                draggingView!.center = draggedCell.center
                self.collectionView!.addSubview(draggingView!)
                
                // put copy cell on screen with animation
                touchOffsetFromCenterOfCell = CGPoint(x: draggedCell.center.x - touchLocation.x, y: draggedCell.center.y - touchLocation.y)
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    self.draggingView!.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    self.draggingView!.alpha = 0.8
                })
            }
            break;
        case UIGestureRecognizerState.Changed:
            if draggedCellIndexPath != nil {
                
                // update copy cell position
                draggingView!.center = CGPoint(x: touchLocation.x + touchOffsetFromCenterOfCell!.x, y: touchLocation.y + touchOffsetFromCenterOfCell!.y)
                if !isAutoScrolling {
                    let scroller = self.shouldAutoScroll(touchLocation)
                    if  (scroller.shouldScroll) {
                        self.autoScroll(scroller.direction)
                    }
                }
                // get list of headers indexPaths and parse it
                if let paths = self.collectionView?.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader)
                {
                    for path in paths
                    {
                        // if the section is not the original section of the dragging view
                        if path.section != draggedCellIndexPath!.section
                        {
                            // get header section attributes for current indexPath
                            if let attributes = self.collectionView?.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: path)
                            {
                                // get header section cell for current indexPath
                                if let tempSectionCell = self.collectionView?.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: path)
                                {
                                    // check intersection between copy cell and header section cell
                                    if attributes.frame.intersects(draggingView!.frame)
                                    {
                                        // highlight the header cell
                                        tempSectionCell.backgroundColor = UIColor.purpleColor()
                                        // set temp variables to keep path and section cell
                                        sectionCell = tempSectionCell
                                        tempPath = path
                                    }
                                    else
                                    {
                                        // unlight the header cell
                                        tempSectionCell.backgroundColor = UIColor.whiteColor()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        case UIGestureRecognizerState.Ended:
            
            // if section cell is highlighted and different from the origin section then
            if sectionCell?.backgroundColor == UIColor.purpleColor() && draggedCellIndexPath!.section != tempPath!.section
            {
                // remove highlighting
                sectionCell!.backgroundColor = UIColor.whiteColor()
                // check if section is collapse or expand
                if arrayForBool[tempPath!.section] == true
                {
                    // swap datas and move the cell (animation)
                    self.itemsBis[tempPath!.section].insert(self.itemsBis[draggedCellIndexPath!.section].removeAtIndex(draggedCellIndexPath!.row), atIndex: tempPath!.row)
                    self.collectionView?.moveItemAtIndexPath(draggedCellIndexPath!, toIndexPath: tempPath!)
                }
                else
                {
                    // swap datas and destroy the cell
                    self.itemsTres[tempPath!.section].insert(self.itemsTres[draggedCellIndexPath!.section].removeAtIndex(draggedCellIndexPath!.row), atIndex: tempPath!.row)
                    self.itemsBis[draggedCellIndexPath!.section].removeAtIndex(draggedCellIndexPath!.row)
                    self.collectionView!.reloadData()
//                    self.collectionView?.moveItemAtIndexPath(draggedCellIndexPath!, toIndexPath: tempPath!)
                }
            }
            
            // delete copy cell and reset variables
            if draggingView != nil
            {
                self.draggingView!.removeFromSuperview()
            }
            self.draggingView = nil
            self.draggedCellIndexPath = nil
            self.isAutoScrolling = false
            sectionCell?.backgroundColor = UIColor.whiteColor()
            break;
        default: ()
        }
    }
    
    enum AutoScrollDirection: Int {
        case Invalid = 0
        case TowardsOrigin = 1
        case AwayFromOrigin = 2
    }
    
    func autoScroll(direction: AutoScrollDirection) {
        let currentLongPressTouchLocation = self.longPressRecognizer.locationInView(self.collectionView)
        var increment: CGFloat
        var newContentOffset: CGPoint
        if (direction == AutoScrollDirection.TowardsOrigin) {
            increment = -50.0
        } else {
            increment = 50.0
        }
        newContentOffset = CGPoint(x: self.collectionView!.contentOffset.x, y: self.collectionView!.contentOffset.y + increment)
        
        // check if the offset is enough to scroll
        if ((direction == AutoScrollDirection.TowardsOrigin && newContentOffset.y < 0) || (direction == AutoScrollDirection.AwayFromOrigin && newContentOffset.y > self.collectionView!.contentSize.height - self.collectionView!.frame.height)) {
            self.isAutoScrolling = false
        } else {
            UIView.animateWithDuration(0.0
                , delay: 0.1
                , options: UIViewAnimationOptions.CurveLinear
                , animations: { () -> Void in
                    
                    // update frame with new offset
                    self.collectionView!.setContentOffset(newContentOffset, animated: false)
                    if (self.draggingView != nil) {
                        var draggingFrame = self.draggingView!.frame
                        draggingFrame.origin.y += increment
                        self.draggingView!.frame = draggingFrame
                    }
                }) { (finished) -> Void in
                    
                    // update touchLocation and check if scroll again or not
                    let updatedTouchLocationWithNewOffset = CGPoint(x: currentLongPressTouchLocation.x, y: currentLongPressTouchLocation.y + increment)
                    let scroller = self.shouldAutoScroll(updatedTouchLocationWithNewOffset)
                    if scroller.shouldScroll {
                        self.autoScroll(scroller.direction)
                    } else {
                        self.isAutoScrolling = false
                    }
            }
        }
    }
    
    func distanceBetweenPoints(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let xDistance = firstPoint.x - secondPoint.x
        let yDistance = firstPoint.y - secondPoint.y
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }
    
    func shouldAutoScroll(previousTouchLocation: CGPoint) -> (shouldScroll: Bool, direction: AutoScrollDirection) {
        
        // get touch location for the view
        let previousTouchLocation = self.collectionView!.convertPoint(previousTouchLocation, toView: self.collectionView!.superview)
        let currentTouchLocation = self.longPressRecognizer.locationInView(self.collectionView!.superview)
        
        if currentTouchLocation.x != NSDecimalNumber.notANumber() && currentTouchLocation.y != NSDecimalNumber.notANumber() {
            
            // check for wrong location
            if distanceBetweenPoints(previousTouchLocation, secondPoint: currentTouchLocation) < CGFloat(20.0) {
                
                var scrollBoundsSize: CGSize
                // change this value to determine how far of the edge you want to screen
                let scrollBoundsLength: CGFloat = 60.0
                var scrollRectAtEnd: CGRect
                
                // create rectangles with coordinates, check intersection
                scrollBoundsSize = CGSize(width: self.collectionView!.frame.width, height: scrollBoundsLength)
                scrollRectAtEnd = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y + self.collectionView!.frame.height - scrollBoundsSize.height, width: self.collectionView!.frame.width, height: scrollBoundsSize.height)
                let scrollRectAtOrigin = CGRect(origin: self.collectionView!.frame.origin, size: scrollBoundsSize)
                if scrollRectAtOrigin.contains(currentTouchLocation) {
                    return (true, AutoScrollDirection.TowardsOrigin)
                } else if scrollRectAtEnd.contains(currentTouchLocation) {
                    return (true, AutoScrollDirection.AwayFromOrigin)
                }
            }
        }
        return (false, AutoScrollDirection.Invalid)
    }
    
    // create visual copy of cell
    func getRasterizedImageCopyOfCell(cell: UICollectionViewCell) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
        cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: Expand collapse

    func sectionHeaderTapped(sender: UIButton) {
        
        // sender.tag == indexPath.section, check if the section is already collapse or not
        if arrayForBool[sender.tag] == false
        {
            // get items back from clone array and reload data
            itemsBis[sender.tag] = itemsTres[sender.tag]
            self.collectionView!.reloadData()
        }
        else
        {
            // remove items from array and reload data
            itemsBis[sender.tag] = []
            self.collectionView!.reloadData()
        }
        // modify bolean value associate to the cell
        let collapsed = (arrayForBool[sender.tag] == false ? true : false)
        arrayForBool[sender.tag] = collapsed
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsBis[section].count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // creating the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StatsCollectionViewCell
        
        // Configure the cell
        cell.activityNameLabel.backgroundColor = UIColor.redColor()
        cell.activityButton.backgroundColor = UIColor.purpleColor()
        cell.timeLabel.backgroundColor = UIColor.blackColor()
        cell.histogramView.backgroundColor = UIColor.yellowColor()
        cell.activityNameLabel.text = itemsBis[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // creating the cell
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! StatsCollectionViewCell
        
        // configuring the cell
        headerView.activityNameLabel.text = sections[indexPath.section]
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.activityButton.backgroundColor = UIColor.greenColor()
        headerView.activityNameLabel.text = sections[indexPath.section]
        //        headerView.timeLabel.backgroundColor = UIColor.purpleColor()
        //        headerView.histogramView.backgroundColor = UIColor.yellowColor()
        
        // creating button for expand collapse
        headerView.activityButton.addTarget(self, action: "sectionHeaderTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // adding tag == indexPath.section to the button so the path can be retrieve on tap
        headerView.activityButton.tag = indexPath.section

        
        
        return headerView
        
    }
    
    //    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //        StatsCollectionViewController.selectedPath = indexPath
    //        //calling popup
    //        let SB = UIStoryboard(name: "PopUpStoryboard", bundle: nil)
    //        let controller = SB.instantiateViewControllerWithIdentifier("stats")
    //        controller.view.backgroundColor = .clearColor()
    //        controller.modalPresentationStyle = .OverFullScreen
    //
    ////        self.addChildViewController(controller)
    ////        self.view.addSubview(controller.view)
    ////        controller.didMoveToParentViewController(self)
    //        self.presentViewController(controller, animated: true, completion: nil)
    //
    ////        self.view.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    //    }
    
    // MARK: UICollectionViewLayout
    
    // init collectionview layout
    override init(collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(collectionViewLayout: layout)
        collectionView!.backgroundColor = UIColor.orangeColor()
    }

    // configuring the layout for the collectionView
    convenience required init?(coder aDecoder: NSCoder) {
        let flowLayout = UICollectionViewFlowLayout()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: screenWidth, height: 60)
        flowLayout.scrollDirection = .Vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.sectionHeadersPinToVisibleBounds = true
        flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 60)
        self.init(collectionViewLayout: flowLayout)
    }
    
    // configuring cell size
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: self.view.frame.width, height: 60)
    }
    
    // configuring section header cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.frame.width, 60)
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}
