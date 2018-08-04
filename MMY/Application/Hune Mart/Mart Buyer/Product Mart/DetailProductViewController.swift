//
//  DetailProductViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class DetailProductViewController: UIViewController {
    @IBOutlet weak var lbTypeProduct: UILabel!
    @IBOutlet weak var lbType: UILabel!
    @IBOutlet weak var lbNameBuyer: UILabel!
    @IBOutlet weak var lbNumberphone: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbUnit: UILabel!
    @IBOutlet weak var viewAmountStar: TPFloatRatingView!
    
    @IBOutlet weak var btBuy: UIButton!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var imgePlus: UIImageView!
    @IBOutlet weak var imgeFill: UIImageView!
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var btLike: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var productDetail: ListProductBuyerModel?
    var count = 1
    var checkLike = false
    
    init(_ productModel: ListProductBuyerModel) {
        super.init(nibName: "DetailProductViewController", bundle: nil)
        self.productDetail = productModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error load nib")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "DetailProduct".localized()
        customViewAmount()
        addTapGesture()
        showData()
        setupTableView()
        setupStar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customButton()
    }
    
    func setupStar() {
        viewAmountStar.emptySelectedImage = UIImage(named: "star_empty_yellow")
        viewAmountStar.fullSelectedImage = UIImage(named:"star_full_yellow")
        viewAmountStar.contentMode =  .scaleAspectFill
        viewAmountStar.maxRating = 5
        viewAmountStar.minRating = 1
        viewAmountStar.halfRatings = false
        viewAmountStar.floatRatings = false
        viewAmountStar.rating = 1
        viewAmountStar.editable = true
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "DetailProductTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func customViewAmount() {
        viewAmount.layer.cornerRadius = 15.0
        viewAmount.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        viewAmount.layer.borderWidth = 1.0
    }
    
    func addTapGesture() {
        let tapOne = UITapGestureRecognizer(target:self,action:#selector(tapFill))
        self.imgeFill.isUserInteractionEnabled = true
        self.imgeFill.addGestureRecognizer(tapOne)
        
        let tapTwo = UITapGestureRecognizer(target:self,action:#selector(tapPlus))
        self.imgePlus.isUserInteractionEnabled = true
        self.imgePlus.addGestureRecognizer(tapTwo)
    }
    
    func customButton() {
        btBuy.layer.cornerRadius = self.btBuy.frame.size.height/2
        btBuy.backgroundColor = UIColor(hexString: "00AB4E")
        btBuy.titleLabel?.textColor = UIColor.white
        btBuy.setTitle("Mua".uppercased(), for: .normal)
    }
    
    func showData() {
        //lbType
        for data in ShareData.arrType {
            if data.id == productDetail?.type {
                self.lbType.text = data.name!
            }
        }
        //lbUnit
        for data in ShareData.arrUnit {
            if data.id == productDetail?.unit {
                self.lbUnit.text = data.name!
            }
        }
        //lbTypeProduct
        for data in ShareData.arrProductType {
            if data.id == productDetail?.product_type {
                self.lbTypeProduct.text = data.name
                self.lbTypeProduct.text = data.name!
            }
        }
        
        if let price = productDetail?.price, let start = productDetail?.star {
            lbPrice.text = String(price)
            viewAmountStar.rating = CGFloat(start)
        }
        
        lbNameBuyer.text = productDetail?.full_name
        lbNumberphone.text = productDetail?.phone
    }
    
    func tapFill() {
        if count > 1 {
            count = count - 1
            lbAmount.text = String(count)
        } else {
            count = 1
            lbAmount.text = "1"
        }
    }
    
    func tapPlus() {
        if count < (productDetail?.quantity)! {
            count = count + 1
            lbAmount.text = String(count)
        } else {
            if let data = productDetail?.quantity {
                count = data
                lbAmount.text = String(count)
            }
        }
    }
    
    @IBAction func tapBuy(_ sender: Any) {
        ServiceManager.martService.buyerAddToCart(productDetail!, amount: count) { (result) in
            switch result {
            case .success( _):
                print("Okkkkkkkkkkkkkkk")
                 self.navigationController?.pushViewController(ResponseBuyViewController(), animated: true)
            case .failure(let error):
                print("Erorrrrrrrrrrrr", error.errorCode)
                self.showDialog(title: "HuNe Mart", message: "DetailProductError".localized(), handler:nil)
            }
        }
    }
    
    @IBAction func actionLike(_ sender: Any) {
        if checkLike == false {
            btLike.setImage(UIImage(named:"ic_like_red"), for: .normal)
        } else {
            btLike.setImage(UIImage(named:"ic_like"), for: .normal)
        }
        
        checkLike = !checkLike
    }
    
    
}

extension DetailProductViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailProductTableViewCell
        cell.lbComment.text = "Món ngon và hấp dẫn quá"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}





