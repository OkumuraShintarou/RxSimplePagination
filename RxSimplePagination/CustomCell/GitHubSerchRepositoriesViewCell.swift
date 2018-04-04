//
//  GitHubSerchRepositoriesViewCell.swift
//  RxSimplePagination
//
//  Created by 奥村晋太郎 on 2018/04/02.
//  Copyright © 2018年 奥村晋太郎. All rights reserved.
//

import UIKit

final class GitHubSerchRepositoriesViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var subtitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension GitHubSerchRepositoriesViewCell {
    func configureCell(title: String, subtitle: String) {
        self.title.text = title
        self.subtitle.text = subtitle
    }
}
