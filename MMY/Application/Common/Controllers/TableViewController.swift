//
//  BaseTableViewController.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/9/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import MJRefresh
import NVActivityIndicatorView
import Localize_Swift

class TableViewController<T: BaseModel>: BaseViewController,  UITableViewDelegate, UITableViewDataSource {

    //MARK: - Properties
    
    var records = [T]()
    var tableView: UITableView?
    var hasMore = true
    var isLoading = false
    var nextToken: String?
    var offset: UInt = 0
    var maxResults: UInt = 0
    
    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        
        if let tableView = tableView {
            view.addSubview(tableView);
        }
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        tableView?.register(TableViewCell.LoadingCell.self, forCellReuseIdentifier: TableViewCell.LoadingCell.description())
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 44.0
        
        setupGifHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    // Remove the LCLLanguageChangeNotification on viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Setup views

    func setupGifHeader() {
        let gifHeader = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView?.mj_header = gifHeader
        guard let image1 = UIImage(named: "refreshing-icon1") else {
            return
        }
        guard let image2 = UIImage(named: "refreshing-icon") else {
            return
        }
       
        let images = [image1, image2]
        gifHeader?.setImages(images, for: MJRefreshState.pulling)
        gifHeader?.setImages(images, for: MJRefreshState.refreshing)
        
    }

    
    //MARK: - Data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count + (hasMore ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if checkIfLoadMoreCell(at: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.LoadingCell.description(), for: indexPath) as! TableViewCell.LoadingCell
            cell.activityIndicator?.startAnimating()
            log.debug("activity indicator animating")
            return cell;
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
  
        if checkIfLoadMoreCell(at: indexPath) {
            self.loadData()
        }
    }
    
    //MARK: - Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.debug("did select row")
    }
    
    
    //MARK: -  Methods
    
    func setText() {
        tableView?.reloadData()
    }
    
    func loadData() {
        
    }
    
    func checkIfLoadMoreCell(at indexPath: IndexPath) -> Bool {
        return indexPath.row == records.count && hasMore
    }


    func didFinishLoad(with result: ListResult<T>) {
        isLoading = false
        tableView?.mj_header.endRefreshing()
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
            self.tableView?.reloadData()
        }
    }

    func refresh() {
        nextToken = nil
        offset = 0
        loadData()
    }

}
