//
//  DetailProductViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SDWebImage

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
    @IBOutlet weak var btDislike: UIButton!
    @IBOutlet weak var btLike: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgeOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    
    @IBOutlet weak var lbNumberLike: UILabel!
    @IBOutlet weak var lbNumberDislike: UILabel!
    
    var productDetail: ListProductBuyerModel?
    var listComment = [CommentModel]()
    var count = 1
    var checkLike = false
    var checkDislike = false
    
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
        setupTableView()
        getComment()
        customViewAmount()
        addTapGesture()
        showData()
        setupStar()
        imageProduct()
        showNumberLikeAndDislike()
        tapImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customButton()
    }
    
    func showNumberLikeAndDislike() {
        if let like = self.productDetail?.totalLike, let dislike = self.productDetail?.totalDisLike {
            lbNumberLike.text = String(describing: like)
            lbNumberDislike.text = String(describing: dislike)
        }
    }
    
    func tapImage() {
        let tapOne = UITapGestureRecognizer(target:self,action:#selector(tapImageOne))
        self.imgeOne.isUserInteractionEnabled = true
        self.imgeOne.addGestureRecognizer(tapOne)
        
        let tapTwo = UITapGestureRecognizer(target:self,action:#selector(tapImageTwo))
        self.imageTwo.isUserInteractionEnabled = true
        self.imageTwo.addGestureRecognizer(tapTwo)
        
        let tapThree = UITapGestureRecognizer(target:self,action:#selector(tapImageThree))
        self.imageThree.isUserInteractionEnabled = true
        self.imageThree.addGestureRecognizer(tapThree)
    }
    
    func imageProduct() {
        if productDetail?.image0 != "" {
            self.imgeOne.sd_setImage(with: URL(string: (productDetail?.image0)!), placeholderImage: UIImage(named: "placeholder0.png"), options: [], completed: nil)
        }
        
        if productDetail?.image1 != "" {
            self.imageTwo.sd_setImage(with: URL(string: (productDetail?.image1)!), placeholderImage: UIImage(named: "placeholder1.png"), options: [], completed: nil)
        }
        
        if productDetail?.image2 != "" {
            self.imageThree.sd_setImage(with: URL(string: (productDetail?.image2)!), placeholderImage: UIImage(named: "placeholder2.png"), options: [], completed: nil)
        }
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
        viewAmountStar.editable = false
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
            lbPrice.text = price.stringWithSepator
            viewAmountStar.rating = CGFloat(start)
        }
        
        lbNameBuyer.text = productDetail?.full_name
        lbNumberphone.text = productDetail?.phone
    }
    
    func tapImageOne() {
        if productDetail?.image0 != "" {
            let photoViewController = PhotoViewController(nibName: "PhotoViewController", bundle: nil)
            photoViewController.imageURLString = productDetail?.image0
            navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
    
    func tapImageTwo() {
        if productDetail?.image1 != ""{
            let photoViewController = PhotoViewController(nibName: "PhotoViewController", bundle: nil)
            photoViewController.imageURLString = productDetail?.image1
            navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
    
    func tapImageThree() {
        if  productDetail?.image2 != "" {
            let photoViewController = PhotoViewController(nibName: "PhotoViewController", bundle: nil)
            photoViewController.imageURLString = productDetail?.image2
            navigationController?.pushViewController(photoViewController, animated: true)
        }
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
    
    func getComment() {
        ServiceManager.martService.getComment((productDetail?.product_id)!) { (result) in
            switch result {
            case .success(let data):
                self.listComment = data.comments
                self.tableView.reloadData()
            case .failure(_):
                break
            }
        }
    }
    
    @IBAction func tapBuy(_ sender: Any) {
        ServiceManager.martService.buyerAddToCart(productDetail!, amount: count) { (result) in
            switch result {
            case .success( _):
                print("Okkkkkkkkkkkkkkk")
                if self.checkLike == true || self.checkDislike == true {
                    if self.checkLike == true {
                        ServiceManager.martService.likeProduct((self.productDetail?.product_id)!, action: "like", completion: { (result) in
                            switch result {
                            case .success(_):
                                self.navigationController?.pushViewController(ResponseBuyViewController(), animated: true)
                            case .failure(_):
                                self.showDialog(title: "HuNe Mart", message: "DetailProductError".localized(), handler:nil)
                            }
                        })
                        
                    }
                    
                    if self.checkDislike == true {
                        ServiceManager.martService.likeProduct((self.productDetail?.product_id)!, action: "dislike", completion: { (result) in
                            switch result {
                            case .success(_):
                                self.navigationController?.pushViewController(ResponseBuyViewController(), animated: true)
                            case .failure(_):
                                self.showDialog(title: "HuNe Mart", message: "DetailProductError".localized(), handler:nil)
                            }
                        })
                        
                    }
                    
                    
                } else {
                    self.navigationController?.pushViewController(ResponseBuyViewController(), animated: true)
                }
            case .failure(let error):
                print("Erorrrrrrrrrrrr", error.errorCode)
                self.showDialog(title: "HuNe Mart", message: "DetailProductError".localized(), handler:nil)
            }
        }
    }
    
    @IBAction func actionLike(_ sender: Any) {
        if checkDislike == false {
            btLike.setImage(UIImage(named:"dislike_is"), for: .normal)
            btDislike.setImage(UIImage(named:"ic_like"), for: .normal)
            checkLike = false
        } else {
            btLike.setImage(UIImage(named:"dislike"), for: .normal)
        }
        
        checkDislike = !checkDislike
    }
    
    @IBAction func actionDislike(_ sender: Any) {
        if checkLike == false {
            btDislike.setImage(UIImage(named:"ic_like_red"), for: .normal)
            btLike.setImage(UIImage(named:"dislike"), for: .normal)
            checkDislike = false
        } else {
            btDislike.setImage(UIImage(named:"ic_like"), for: .normal)
        }
        
        checkLike = !checkLike
    }
    
}

extension DetailProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailProductTableViewCell
        cell.textLabel?.text = listComment[indexPath.row].comment
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
}





