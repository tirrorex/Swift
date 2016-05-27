//
//  ViewController.swift
//  sampleapp
//
//  Created by thibaut noah on 30/01/16.
//  Copyright © 2016 thibaut noah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var collectionView:UICollectionView?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    private let reuseIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // set and init collectionview layout
        let flowLayout = UICollectionViewFlowLayout()
        let screenWidth = screenSize.width
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: screenWidth, height: 60)
        flowLayout.scrollDirection = .Vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.sectionHeadersPinToVisibleBounds = false
        flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 60)
        let height = screenSize.height
        let width = screenSize.width
        
        // init and configure the collectionview
        collectionView = UICollectionView(frame: CGRectMake(0, 0, width, height), collectionViewLayout: flowLayout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.view.addSubview(collectionView!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register cell classes
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.registerClass(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func swithToCollectionview() {
        let cell = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        for subview in (cell?.subviews)! {
            subview.removeFromSuperview()
        }
        // you need to implement your collectionviewControler first and you pass an instance of your controler.view
        let tableview = UICollectionView()
        cell!.addSubview(tableview)
    }
    
    func swithToTableview() {
        let cell = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        for subview in (cell?.subviews)! {
            subview.removeFromSuperview()
        }
        // you need to implement your tableviewControler first and you pass an instance of your controler.view
        let tableview = UITableView()
        cell!.addSubview(tableview)
    }
}

// MARK: - CollectionView DataSource


extension ViewController : UICollectionViewDataSource {
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
            return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // creating the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

        switch indexPath.row {
            
        case 0 :
            let view = UIView(frame: CGRectMake(0, 0, screenSize.width, 60))
            view.backgroundColor = UIColor.yellowColor()
            cell.addSubview(view)
            cell.backgroundColor = UIColor.orangeColor()
            
        case 1 :
            let button1 = UIButton()
            button1.frame = CGRectMake(0, 0, screenSize.width/2, 30)
            button1.addTarget(self, action: "swithToCollectionview", forControlEvents: .TouchUpInside)
            button1.setTitle("button1", forState: UIControlState.Normal)
            button1.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button1.backgroundColor = UIColor.whiteColor()
            let button2 = UIButton()
            button2.frame = CGRectMake(screenSize.width/2, 0, screenSize.width/2, 30)
            button2.addTarget(self, action: "swithToTableview", forControlEvents: .TouchUpInside)
            button2.setTitle("button2", forState: UIControlState.Normal)
            button2.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button2.backgroundColor = UIColor.whiteColor()
            cell.addSubview(button1)
            cell.addSubview(button2)
//            cell.backgroundColor = UIColor.redColor()
        case 2 :
            let tableview = UITableView()
//            cell.addSubview(tableview)
            cell.backgroundColor = UIColor.blueColor()
            
        default :
            break
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // creating the cell
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)

        return headerView
    }
    
}


// MARK: - CollectionView Delegate FlowLayout

extension ViewController : UICollectionViewDelegateFlowLayout {
    
    // configuring cell size
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        switch indexPath.row {
            
        case 0 :
            return CGSize(width: screenSize.width, height: 60)
        case 1 :
            return CGSize(width: screenSize.width, height: 30)
        case 2:
            return CGSize(width: screenSize.width, height: 200)
        default :
            return CGSize(width: screenSize.width, height: 60)
        }
    }
    
    // configuring section header cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSizeMake(screenSize.width, 60)
    }
    
    
}

// MARK: - CollectionView Delegate

extension ViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}
