//
//  CollectionViewController.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/6/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds
import MJRefresh

class CollectionViewController<T: BaseModel>: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    
    var records = [T]()
    var hasMore = true
    var isLoading = false
    var nextToken: String?
    var offset: UInt = 0
    var maxResults: UInt = 0
    
    var collectionView: UICollectionView?
    var sizeForItem: CGSize?
    var headerSize: CGSize?
    var footerSize: CGSize?
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupGifHeader()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        if let collectionView = collectionView{
            view.addSubview(collectionView);
        }
        
        collectionView?.snp.makeConstraints({ (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        })
        
        // Setup collection view
        collectionView?.dataSource = self;
        collectionView?.delegate = self;
        collectionView?.register(CollectionViewCell.LoadingCell.self, forCellWithReuseIdentifier: CollectionViewCell.LoadingCell.description())
        collectionView?.register(CollectionViewCell.MyAdViewCell.classForCoder(), forCellWithReuseIdentifier: CollectionViewCell.MyAdViewCell.description())
        collectionView?.register(CollectionViewCell.MyHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewCell.MyHeaderView.description())
        collectionView?.register(CollectionViewCell.MyFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewCell.MyFooterView.description())
        
        
        
        setHeaderSize(CGSize(width: view.bounds.size.width, height: 50.0))
        setFooterSize(CGSize(width: view.bounds.size.width, height: 50.0))
    }
    
    func setupGifHeader() {
        let gifHeader = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        guard let image1 = UIImage(named: "refreshing-icon1") else {
            return
        }
        guard let image2 = UIImage(named: "refreshing-icon") else {
            return
        }
        
        let images = [image1, image2]
        gifHeader?.setImages(images, for: MJRefreshState.pulling)
        gifHeader?.setImages(images, for: MJRefreshState.refreshing)
        collectionView?.mj_header = gifHeader
        
    }
    
    //MARK: - Methods
    
    func calculatePadding() -> CGFloat{
        let padding : CGFloat?
        if UIDevice.current.userInterfaceIdiom == .phone{
            padding = 10.0
        }else if UIDevice.current.userInterfaceIdiom == .pad{
            padding = 30.0
        }else {
            padding = 0.0
        }
        
        return padding!
    }
    
    func calculateItemsPerRow() -> Int{
        let itemPerRow : Int?
        if UIDevice.current.userInterfaceIdiom == .phone{
            itemPerRow = 1
        }else if UIDevice.current.userInterfaceIdiom == .pad{
            itemPerRow = 3
        }else {
            itemPerRow = 0
        }
        
        return itemPerRow!
    }
    
    func setHeaderSize(_ size:CGSize){
        headerSize = size
        collectionView?.reloadData()
    }
    
    func setFooterSize(_ size:CGSize){
        footerSize = size
        collectionView?.reloadData()
    }
    
    func loadData() {
        
    }
    
    func checkIfLoadMoreCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row == records.count && hasMore
    }
    
    
    func didFinishLoad(with result: ListResult<T>) {
        isLoading = false
        collectionView?.mj_header.endRefreshing()
        switch result {
        case let .success(data, nextToken):
            updateData(with: data, and: nextToken)
        case let .failure(error):
            log.debug(error.errorMessage)
        }
    }
    
    func updateData(with dataArray: [T], and nextToken: String?) {
        if offset == 0  {
            records = dataArray
        } else {
            records.append(contentsOf: dataArray)
        }
        
        hasMore = nextToken != nil
        offset += maxResults
        self.nextToken = nextToken
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func refresh() {
        nextToken = nil
        offset = 0
        loadData()
    }
    
    
    // MARK: -CollectionView - Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return records.count + (hasMore ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if checkIfLoadMoreCell(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.LoadingCell.description(), for: indexPath) as! CollectionViewCell.LoadingCell
            cell.activityIndicator?.startAnimating()
            log.debug("activity indicator animating")
            return cell;
        }
        
        return UICollectionViewCell()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = calculatePadding()
        let itemsPerRow = calculateItemsPerRow()
        
        let paddingSpace = padding * CGFloat((itemsPerRow + 2))
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        sizeForItem = CGSize(width: widthPerItem, height: widthPerItem * (9/16))
        
        return sizeForItem!
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding = calculatePadding()
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return calculatePadding()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat{
        return calculatePadding()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return CGSize.zero
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview : UICollectionReusableView?;
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewCell.MyHeaderView.description(), for: indexPath)
            
            reusableview = headerView;
        }
        
        if kind == UICollectionElementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewCell.MyFooterView.description(), for: indexPath)
            
            
            reusableview = footerView;
        }
        
        
        return reusableview!;
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if checkIfLoadMoreCell(at: indexPath) {
            self.loadData()
        }
    }
}

