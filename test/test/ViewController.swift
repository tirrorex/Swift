//
//  ViewController.swift
//  test
//
//  Created by thibaut noah on 20/12/15.
//  Copyright © 2015 thibaut noah. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UISearchDisplayDelegate  {

    var collectionView:UICollectionView?
    var searchBar:UISearchBar?
    var searchBarBoundsY = CGFloat()
    var refreshControl:UIRefreshControl?
    var searchBarActive = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // set and init collectionview layout
        
        let flowLayout = UICollectionViewFlowLayout()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: screenWidth, height: 60)
        flowLayout.scrollDirection = .Vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.sectionHeadersPinToVisibleBounds = false
        flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 60)
        let height = self.view.frame.height
        let width = self.view.frame.width
        
        // init and configure the collectionview
        collectionView = UICollectionView(frame: CGRectMake(0, 0, width, height), collectionViewLayout: flowLayout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset = UIEdgeInsets(top: 64+90, left: 0, bottom: 50+60, right: 0)
//        self.view.addSubview(collectionView!)
        collectionView?.backgroundColor = UIColor.redColor()
//        searchBar = UISearchBar(frame: CGRectMake(0, 0, 320, 64))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.prepareUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: actions
    func refreashControlAction() {
        self.cancelSearching()
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // stop refreshing after 2 seconds
//        self.collectionView.reloadData()
//        self.refreshControl.endRefreshing()
//        })
    }
    
    // MARK: search
    func filterContentForSearchText(searchText: NSString, scope: NSString) {
        let resultPredicate = NSPredicate(format: "self contains[c] %@", searchText)
//        self.dataSourceForSearchResult  = [self.dataSource filteredArrayUsingPredicate:resultPredicate];
    }
        
    func searchBar(searchBar: UISearchBar, searchText: NSString){
        // user did type something, check our datasource for text that looks the same
        if (searchText.length>0) {
            // search and reload data source
            self.searchBarActive = true
            self.filterContentForSearchText(searchText, scope: self.searchDisplayController!.searchBar.scopeButtonTitles![self.searchDisplayController!.searchBar.selectedScopeButtonIndex])
            self.collectionView!.reloadData()
        } else {
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.cancelSearching()
        self.collectionView!.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        self.searchBar!.setShowsCancelButton(true, animated:true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        self.searchBarActive = false
        self.searchBar!.setShowsCancelButton(false, animated:true)
    }
    
    func cancelSearching() {
    self.searchBarActive = false
    self.searchBar!.resignFirstResponder()
    self.searchBar!.text  = ""
    }
    
    
    // MARK: prepare VC
    
    func prepareUI() {
        self.addSearchBar()
        self.addRefreshControl()
    }

    func addSearchBar() {
        if ((self.searchBar == nil)) {
            self.searchBarBoundsY = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
            self.searchBar = UISearchBar(frame:CGRectMake(0,self.searchBarBoundsY, UIScreen.mainScreen().bounds.size.width, 44))
            self.searchBar!.searchBarStyle = .Minimal
            self.searchBar!.tintColor = UIColor.whiteColor()
            self.searchBar!.barTintColor = UIColor.whiteColor()
            self.searchBar!.delegate = self
            self.searchBar!.placeholder = "search here"
//            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.classForCoder()])
//            UITextField.appearanceWhenContainedInInstancesOfClasses([MyViewController.self]).keyboardAppearance = .Light

//            [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
            
            // add KVO observer.. so we will be informed when user scroll colllectionView
//          self.addObservers()
        }
//        
        if (((self.searchBar?.isDescendantOfView(self.view)) == nil)) {
            self.view.addSubview(self.searchBar!)
        }
    }
    
    func addRefreshControl() {
        if ((self.refreshControl == nil)) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl!.tintColor = UIColor.whiteColor()
            self.refreshControl?.addTarget(self, action: "refreashControlAction", forControlEvents: .ValueChanged)
        }
            if (((self.refreshControl?.isDescendantOfView(self.collectionView!)) == nil)) {
                self.collectionView!.addSubview(self.refreshControl!)
            }
    }
    
    func startRefreshControl() {
        if (!self.refreshControl!.refreshing) {
            self.refreshControl!.beginRefreshing()
        }
    }
    
    // MARK: observer
    
    func addObservers() {
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
    }
    
    func removeObservers() {
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
//    func observeValueForKeyPath(keyPath: NSString, object: UICollectionView, change: NSDictionary, context: AnyObject) {
////        :(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
//        if (keyPath.isEqualToString("contentOffset") && object == self.collectionView ) {
//        self.searchBar!.frame = CGRectMake(self.searchBar!.frame.origin.x, self.searchBarBoundsY + ((-1*object.contentOffset.y)-self.searchBarBoundsY), self.searchBar!.frame.size.width, self.searchBar!.frame.size.height)
//        }
//    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if (self.searchBarActive) {
//            return self.dataSourceForSearchResult.count;
//        }
//        return self.dataSource.count;
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //        let colorText = UIColor.blueColor()
        // creating the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) 
//        if (self.searchBarActive) {
//            cell.laName.text = self.dataSourceForSearchResult[indexPath.row];
//        }else{
//            cell.laName.text = self.dataSource[indexPath.row];
//        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        //        let colorText = UIColor.redColor()
        // creating the cell
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! UICollectionViewCell
        
//        let searchDisplayController = UISearchController(searchResultsController: self)
//        searchDisplayController.delegate = self
//        searchDisplayController.searchResultsDataSource = self.collectionView
//        
//        self.collectionView. = searchBar

        return headerView
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
//        let value = StatsCollectionViewController.groupByCategory.value
//        if  value == true
//        {
//            return CGSizeMake(self.view.frame.width, 60)
//        }
//        else
//        {
//            return CGSizeMake(0,0)
//        }
        return CGSizeMake(0,0)
    }


}

