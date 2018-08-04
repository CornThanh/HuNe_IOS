//
//  CouponListViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class CouponListViewController: BaseViewController {
    
    var items: [CouponModel] = [CouponModel]()
    
    @IBOutlet weak var lbMyCoinTitle: UILabel!
    @IBOutlet weak var lbMyCoinValue: UILabel!
    @IBOutlet weak var ivCoinIcon: UIImageView!
    
    @IBOutlet weak var cvContent: UICollectionView!
    
    
    var userModel: UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "BuyCoupon".localized()
        lbMyCoinTitle.text = "MyCoin".localized()
        
        cvContent.delegate = self
        cvContent.dataSource = self
        cvContent.register(UINib(nibName: "CouponCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        getCoupons()
        getUser()
    }
    
    
    func getUser() {
        ServiceManager.userService.get(userId: "") { [unowned self] (result) in
            switch result {
            case .success(let user):
                self.userModel = user
                if let coin = self.userModel?.remainCoin {
                    self.lbMyCoinValue.text = coin.stringWithSepator
                }
            case .failure(_):
                break
                //                log.debug(error.errorMessage)
            }
        }
    }
    
    func getCoupons() {
        ServiceManager.storeService.getCoupons { (result) in
            if let value = result.value {
                self.items = value
                self.cvContent.reloadData()
            }
        }
    }
    
    func buyCoupon(_ coupon: CouponModel) {
        ServiceManager.storeService.buyCoupon(coupon.id!) { (result) in
            if let error = result.error {
                self.showErrorDialog(error)
            }
            else {
                self.showDialog(title: "", message: "Successful".localized(), handler: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension CouponListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CouponCollectionViewCell
            else {
                return UICollectionViewCell()
        }
        let item = items[indexPath.row]
        cell.ivIcon.kf.setImage(with: URL(string: item.imageListCoupon ?? ""))
        cell.lbPrice.text = "Price".localized() + " : " + (item.price?.stringWithSepator ?? "")
        cell.lbTime.text = (item.fromDate ?? "") + " " + "To".localized() + " " + (item.toDate ?? "")
        cell.lbName.text = item.name
        cell.handleBuyAction = { () in
            self.buyCoupon(item)
        }
        return cell
    }
    
}

extension CouponListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if let id = item.id {
            let idCoupon = String(describing: id)
            let vc = CouponDetailViewController(idCoupon)
            vc.coupon = item
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

extension CouponListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthPerItem = (UIScreen.main.bounds.size.width / 2) - 12
        let sizeForItem = CGSize(width: widthPerItem, height: widthPerItem * (12/9))
        
        return sizeForItem
    }
}
