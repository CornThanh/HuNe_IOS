//
//  ProductMartViewController.swift
//  MMY
//
//  Created by Apple on 8/4/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SDWebImage
import DropDown

class ProductMartViewController: UIViewController {
    @IBOutlet weak var btOne: UIButton!
    @IBOutlet weak var btTwo: UIButton!
    
    @IBOutlet weak var searchStar: UITextField!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrProduct = [ListProductBuyerModel]()
    var sortTypeProduct = 0
    var sortType = 0
    
    let typeDropDown1 = DropDown()
    let typeDropDown2 = DropDown()
    let typeDropDown3 = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "MartBuyerViewController1".localized()
        searchStar.delegate = self
        setUpFilter()
        setUpCollectionView()
        callData()
        setupDropDown()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callData()
    }
    
    func callData() {
        ServiceManager.martService.getProduct { (result) in
            switch result {
            case .success(let data, _):
                print("okkkkkkkkkkkkkkkkk")
                self.arrProduct = data
                self.collectionView.reloadData()
            case .failure(let error):
                print("errorrrrrrrrrrrrrrrr",error )
            }
        }
    }
    
    func setUpCollectionView() {
        self.collectionView.register(UINib(nibName: "ProductMartCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setUpFilter() {
        btOne.setTitle("TypeProduct".localized(), for: .normal)
        btTwo.setTitle("Type".localized(), for: .normal)
    }
    
    func nameProduct(index: Int) -> String {
        var string = ""
        var type = ""
        for data in ShareData.arrType {
            if data.id == arrProduct[index].type {
                type = data.name!
            }
        }
        
        string = arrProduct[index].name! + " " + type.lowercased()
        return string
    }
    
    func setupDropDown() {
        self.setupTypeDropDown()
        self.setupTypeProduct()
    }
    
    func setupTypeDropDown() {
        typeDropDown1.anchorView = btTwo
        typeDropDown1.bottomOffset = CGPoint(x: 0, y: viewOne.bounds.height)
        var typeDataSource = [String]()
        for data in ShareData.arrType {
            typeDataSource.append(data.name!)
        }
        typeDropDown1.dataSource = typeDataSource
        typeDropDown1.selectionAction = { [unowned self] (index, item) in
            self.sortProduct(type: ShareData.arrType[index].id!, typeProduct: 0, start: -1)
        }
    }
    
    func setupTypeProduct() {
        typeDropDown3.anchorView = btOne
        DispatchQueue.main.async {
            self.typeDropDown3.bottomOffset = CGPoint(x: 0, y: self.viewThree.bounds.height)
        }
        var typeDataSource = [String]()
        for data in ShareData.arrProductType {
            typeDataSource.append(data.name!)
        }
        typeDropDown3.dataSource = typeDataSource
        typeDropDown3.selectionAction = { [unowned self] (index, item) in
            self.sortProduct(type: 0, typeProduct: ShareData.arrProductType[index].id!, start: -1)
        }
    }
    
    func sortProduct(type: Int, typeProduct: Int, start: Int) {
        ServiceManager.martService.orderBuyerProduct(type, sortTypeProduct: typeProduct, countStar: start) { (result) in
            switch result {
            case .success(let data, _):
                if data.count > 0 {
                    self.arrProduct = data
                }
                 self.collectionView.reloadData()
            case .failure(let error):
                print("error", error.errorCode)
            }
        }
    }
    
    
    
    @IBAction func actionOrder(_ sender: UIButton) {
        if sender.tag == 0 {
            self.typeDropDown3.show()
        } else if sender.tag == 1 {
            self.typeDropDown1.show()
        }
    }
    
    
}

extension ProductMartViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let count = Int(updatedText) ?? 0
        self.sortProduct(type: -1, typeProduct: -1, start: count)
        
        return true
    }
}

extension ProductMartViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrProduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProductMartCollectionViewCell
        
        cell.imgProduct.sd_setImage(with: URL(string: (arrProduct[indexPath.row].thumbnail)!), placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
        if let amount = arrProduct[indexPath.row].quantity {
            cell.lbAmount.text = String(describing: amount)
        }
        cell.lbNameProduct.text = self.nameProduct(index: indexPath.row)
        if let price = arrProduct[indexPath.row].price {
            for data in ShareData.arrUnit {
                if data.id == arrProduct[indexPath.row].unit {
                    if let name = data.name {
                        cell.lbPrice.text = price.stringWithSepator + " đ/ 1\(name.lowercased())"
                    }
                }
            }
        }
        cell.lbNameSeller.text = arrProduct[indexPath.row].full_name
        
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        cell.layer.cornerRadius = 5.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailProductViewController(arrProduct[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthCell: CGFloat = (collectionView.frame.size.width - 10.0)/2
        let heightCell: CGFloat = 230.0
        return CGSize(width: widthCell, height: heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}
