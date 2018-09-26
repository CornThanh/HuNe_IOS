//
//  CheckOrderViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class CheckOrderViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var dataOrder = [OrderModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MartBuyerViewController2".localized()
        addLeftBarButton()
        setupTableview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callData()
    }
    
    func callData() {
        ServiceManager.martService.getBuyerOrder { (result) in
            switch result {
            case .success(let data, _):
                self.dataOrder = data
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupTableview() {
        tableView.register(UINib(nibName: "CheckOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func nameOrder(_ index: Int) -> String {
        var string = ""
        
        var quantity = ""
        if let quantityOrder = dataOrder[index].quantity {
            quantity = String(quantityOrder)
        }
        
        var unit = ""
        for data in ShareData.arrUnit {
            if data.id == dataOrder[index].unit {
                unit = data.name!
            }
        }
        
        var nameProduct = dataOrder[index].name
        
        var type = ""
        for data in ShareData.arrType {
            if data.id == dataOrder[index].type {
                type = data.name!
            }
        }
        
        let subString = quantity + " " + unit + " " + nameProduct!.lowercased()
        string = subString + " " + type.lowercased()
        
        return string
    }

}

extension CheckOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CheckOrderTableViewCell
        cell.textLabel?.text = nameOrder(indexPath.row)
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 13)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NameOrderBuyerViewController(orderData: dataOrder[indexPath.row], nameOrder: nameOrder(indexPath.row))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
