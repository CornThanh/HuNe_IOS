//
//  ShareData.swift
//  MMY
//
//  Created by Dream Digits on 4/18/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation

struct ShareData {
    static var changePhoneVerify = false // true: english, false: viet nam / GuestSignInViewController
    static var totalDateChoose = 0 // get totalDate(PickerDateViewController) pass data to BannerAdsViewController
    static var  arrNewPost = [Int : TempPostModel]() // model post new job (DefaultFindJobViewController)
    static var datePicker = [String: String]() // get date(PickerDateNotiViewController) pass data to  NotiAdsViewController
    static var arrDates = [String]() // get arr dates (PickerDateViewController) pass data to BannerAdsViewController
    static var typeManager = "" // check type manager Red or Blue of MMYProfileViewController
    static var arrUnit = [ConfigTypeOrProductTypeModel]() // get config of PostNewsViewController
    static var arrProductType = [ConfigTypeOrProductTypeModel]() // get config of PostNewsViewController
    static var arrType = [ConfigTypeOrProductTypeModel]() // get config of PostNewsViewController
}
