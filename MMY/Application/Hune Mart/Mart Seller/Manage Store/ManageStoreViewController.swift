//
//  ManageStoreViewController.swift
//  MMY
//
//  Created by Apple on 7/21/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class ManageStoreViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var dataManageStore = [ManageStoreModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "MartSellerViewController2".localized()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callData()
    }
    
    func setupTableView() {
        tableview.register(UINib(nibName: "ManageStoreTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        
    }
    
    func callData() {
        ServiceManager.martService.getSellerProduct { (result) in
            switch result {
            case .success(let data, _):
                self.dataManageStore = data
                self.tableview.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func nameProduct(_ index: Int) -> String{
        // type product
        var string = ""
        for data in ShareData.arrProductType {
            if data.id == dataManageStore[index].product_type {
                string = data.name!
            }
        }
        
        var price = ""
        if let priceProduct = dataManageStore[index].price {
            price = String(priceProduct)
        }
        
        var type = ""
        for data in ShareData.arrType {
            if data.id == dataManageStore[index].type {
                type = data.name!
            }
        }
        
        var unit = ""
        for data in ShareData.arrUnit {
            if data.id == dataManageStore[index].unit {
                unit = data.name!
            }
        }
        
        let priceInt = Int(price)?.stringWithSepator
        
        let subString = string + " " + type.lowercased() + " " + priceInt!
        string = subString + ".000 VNĐ" + " " + unit.lowercased()
        return string
    }

}

extension ManageStoreViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManageStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ManageStoreTableViewCell
        cell.imageStore.sd_setImage(with: URL(string: (dataManageStore[indexPath.row].thumbnail)!), placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
        cell.lbTile.text = self.nameProduct(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            ServiceManager.martService.deleteSellerProduct(self.dataManageStore[indexPath.row].product_id!, completion: { (result) in
                
                switch result {
                case .success( _):
                    self.dataManageStore.remove(at: indexPath.row)
                    self.tableview.reloadData()
                case .failure(let error):
                    print("error", error.errorCode)
                }
            })
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            ServiceManager.martService.editSellerProduct(productId: self.dataManageStore[indexPath.row].product_id!, completion: { (result) in
                switch result {
                case .success(_):
                    let vc = PostNewsViewController(checkEdit: true, dataEdit: self.dataManageStore[indexPath.row])
                    self.navigationController?.pushViewController(vc, animated: true)
                case .failure(let error):
                    print("error", error)
                }
            })
        }
        
        share.backgroundColor = UIColor.blue
        
        return [delete, share]
    }

}



