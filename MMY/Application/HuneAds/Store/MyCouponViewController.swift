//
//  MyCouponViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class MyCouponViewController: BaseViewController {

    var items: [MyCouponModel] = []

    @IBOutlet weak var cvContent: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title =  "MyCoupon".localized()
        cvContent.delegate = self
        cvContent.dataSource = self
        cvContent.register(UINib(nibName: "MyCouponCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        getCoupons()
    }

    func getCoupons() {
        ServiceManager.storeService.getMyCoupons { (result) in
            if let value = result.value {
                self.items = value
                self.cvContent.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension MyCouponViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MyCouponCollectionViewCell
            else {
                return UICollectionViewCell()
        }
        let item = items[indexPath.row]
        cell.lbTitle.text = item.coupon?.name
        cell.lbCode.text = item.code
        cell.ivIcon.kf.setImage(with: URL(string: item.coupon?.imageListCoupon ?? ""))
        cell.handleCopyAction = { () in
            UIPasteboard.general.string = item.code ?? " "
            self.showDialog(title: "", message: "Copied".localized(), handler: nil)
        }
        return cell
    }
}

extension MyCouponViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = items[indexPath.row]
//        let vc = CouponDetailViewController.loadFromNib()
//        navigationController?.pushViewController(vc, animated: true)
    }


}

extension MyCouponViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let widthPerItem = (UIScreen.main.bounds.size.width / 2) - 12
        let sizeForItem = CGSize(width: widthPerItem, height: widthPerItem * (12/7))

        return sizeForItem
    }
}
