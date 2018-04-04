//
//  GitHubSerchRepositoriesViewController.swift
//  RxSimplePagination
//
//  Created by 奥村晋太郎 on 2018/04/02.
//  Copyright © 2018年 奥村晋太郎. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIScrollView {}

final class GitHubSerchRepositoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension GitHubSerchRepositoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
}
