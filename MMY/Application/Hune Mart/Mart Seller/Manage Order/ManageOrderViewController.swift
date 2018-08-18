//
//  ManageStoreViewController.swift
//  
//
//  Created by Apple on 7/21/18.
//

import UIKit
import DropDown

class ManageOrderViewController: UIViewController {

    @IBOutlet weak var btFilterStatus: UIButton!
    
    @IBOutlet var tfFromDate: UITextField!
    @IBOutlet var tfToDate: UITextField!
    
    @IBOutlet var tableview: UITableView!
    
    var dataManageOrder = [ManageOrderModel]()
    let typeDropDown = DropDown()
    var checkFromDate = false
    var checkToDate = false
    
    init() {
        super.init(nibName: "ManageOrderViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error load xib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "MartSellerViewController3".localized()
        self.setupTableView()
        self.setupGesture()
        setupStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.setupUI()
        self.callData()
    }
    
    func setupTableView() {
        tableview.register(UINib(nibName: "ManageOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.estimatedRowHeight = 100.0
        tableview.rowHeight = UITableViewAutomaticDimension
    }
    
    func callData() {
        ServiceManager.martService.getSellerOrder(status: 0, fromDate: "", toDate: "") { (result) in
            switch result {
                case .success(let data, _):
                    self.dataManageOrder = data
                    self.tableview.reloadData()
                case .failure(let error):
                    print("error", error.errorCode)
            }
        }
    }
    
    func nameOrder(_ index: Int) -> String {
        var string = ""
        
        var quantity = ""
        if let quantityOrder = dataManageOrder[index].quantity {
            quantity = String(quantityOrder)
        }
        
        var typeProduct = ""
        for data in ShareData.arrProductType {
            if data.id == dataManageOrder[index].product_type{
                typeProduct = data.name!
            }
        }
        
        var type = ""
        for data in ShareData.arrType {
            if data.id == dataManageOrder[index].type {
                type = data.name!
            }
        }
        
        let subString = dataManageOrder[index].buyer_name! + " mua " + quantity + " "
        string = subString + typeProduct.lowercased() + " " + type.lowercased()
        return string
    }
    
    func setupUI() {
        tfToDate.layer.cornerRadius = 8.0
        tfFromDate.layer.cornerRadius = 8.0
        
        tfToDate.layer.borderWidth = 1.0
        tfFromDate.layer.borderWidth = 1.0
        
        tfToDate.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        tfFromDate.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        
        tfFromDate.layer.masksToBounds = true
        tfToDate.layer.masksToBounds = true
        
        tfToDate.delegate = self
        tfFromDate.delegate = self
    }
    
    func setupStatus() {
        typeDropDown.anchorView = btFilterStatus
        DispatchQueue.main.async {
            self.typeDropDown.bottomOffset = CGPoint(x: 0, y: self.btFilterStatus.bounds.height)
        }
        let typeDataSource = ["Chưa xác nhận", "Đã xác nhận"]
        typeDropDown.dataSource = typeDataSource
        typeDropDown.selectionAction = { [unowned self] (index, item) in
            ServiceManager.martService.getSellerOrder(status: (index + 1), fromDate: "", toDate: "") { (result) in
                switch result {
                case .success(let data, _):
                    self.dataManageOrder = data
                    self.tableview.reloadData()
                case .failure(let error):
                    print("error", error.errorCode)
                }
            }
        }
    }
    
    func setupGesture() {

    }
    
    func searchStatus() {
        
    }
    
    @IBAction func actionFilterStatus(_ sender: Any) {
        self.typeDropDown.show()
    }
    
}

extension ManageOrderViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Format Date of Birth dd-MM-yyyy
        
        //initially identify your textfield
        
        if textField == tfToDate {
            
            // check the chars length dd -->2 at the same time calculate the dd-MM --> 5
            if (tfToDate?.text?.characters.count == 2) || (tfToDate?.text?.characters.count == 5) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    tfToDate?.text = (tfToDate?.text)! + "/"
                }
            }
            
            if (textField.text!.characters.count >= 9 && (string.characters.count ) >= range.length) {
                checkToDate = true
            } else {
                checkToDate = false
            }
            
        }
        else {
            // check the chars length dd -->2 at the same time calculate the dd-MM --> 5
            if (tfFromDate?.text?.characters.count == 2) || (tfFromDate?.text?.characters.count == 5) {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    tfFromDate?.text = (tfFromDate?.text)! + "/"
                }
            }
            
            if (textField.text!.characters.count >= 9 && (string.characters.count ) >= range.length) {
                checkFromDate = true
            } else {
                checkFromDate = false
            }
        }
        
        if checkToDate == true && checkFromDate == true {
            ServiceManager.martService.getSellerOrder(status: 0, fromDate: (tfFromDate?.text)!, toDate: (tfToDate?.text)!) { (result) in
                switch result {
                case .success(let data, _):
                    self.dataManageOrder = data
                    self.tableview.reloadData()
                    self.checkToDate = false
                    self.checkFromDate = false
                case .failure(let error):
                    print("error", error.errorCode)
                }
            }
        }
        
        return !(textField.text!.characters.count > 9 && (string.characters.count ) > range.length)
    }
}

extension ManageOrderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManageOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! ManageOrderTableViewCell
        
        cell.lbOrder.text = nameOrder(indexPath.row)
        if let price = dataManageOrder[indexPath.row].price {
            cell.lbPrice.text = String(price)
        }
        
        if dataManageOrder[indexPath.row].status == 1 {
            cell.lbStatus.textColor = UIColor.red
            cell.lbStatus.text = "Đang chờ xác nhận"
        } else {
            cell.lbStatus.textColor = UIColor.blue
            cell.lbStatus.text = "Đã xác nhận"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NameOrderBuyerViewController(data: dataManageOrder[indexPath.row], nameTitle: nameOrder(indexPath.row))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
