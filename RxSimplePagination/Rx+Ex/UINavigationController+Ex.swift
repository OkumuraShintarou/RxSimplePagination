//
//  UINavigationController+Ex.swift
//  RxSimplePagination
//
//  Created by 奥村晋太郎 on 2018/04/02.
//  Copyright © 2018年 奥村晋太郎. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct Colors {
    static let offlineColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
    static let onlineColor = nil as UIColor?

    // Nope
    init() {}
}

extension Reactive where Base: UINavigationController {
    // offlineかそうでないかを色で識別するためのExtention
    var isOffline: Binder<Bool> {
        return Binder(base) { navigationController, isOffline in
            navigationController.navigationBar.barTintColor = isOffline
            ? Colors.offlineColor
            : Colors.onlineColor
        }
    }
}
