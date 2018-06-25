//
//  LayerTableViewCell.swift
//  
//
//  Created by Noah Gundotra on 6/25/18.
//

import UIKit
import SnapKit

class LayerTableViewCell: UITableViewCell {
    // This is the programmatic design of the UI for layer cells...
    
//    let imgUser = UIImageView()
//    let labUserName = UILabel()
//    let labMessage = UILabel()
//    let labTime = UILabel()
//    var viewsDict = [String: UIView]()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        imgUser.backgroundColor = UIColor.blue
//
//        imgUser.translatesAutoresizingMaskIntoConstraints = false
//        labUserName.translatesAutoresizingMaskIntoConstraints = false
//        labMessage.translatesAutoresizingMaskIntoConstraints = false
//        labTime.translatesAutoresizingMaskIntoConstraints = false
//
//        contentView.addSubview(imgUser)
//        contentView.addSubview(labUserName)
//        contentView.addSubview(labMessage)
//        contentView.addSubview(labTime)
//
//        viewsDict = [
//            "image" : imgUser,
//            "username" : labUserName,
//            "message" : labMessage,
//            "labTime" : labTime,
//            ]
//
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-[image(10)]", options: [], metrics: nil, views: viewsDict))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[labTime]-|", options: [], metrics: nil, views: viewsDict))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-[username]-[message]-|", options: [], metrics: nil, views: viewsDict))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-[username]-[image(10)]-|", options: [], metrics: nil, views: viewsDict))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-[message]-[labTime]-|", options: [], metrics: nil, views: viewsDict))
//    }
    
    let layerImg = UIImageView()
    let layerName = UILabel()
    // FIXME: add layer description, maybe button to detail page
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(layerName)
        contentView.addSubview(layerImg)
        
        self.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(70)
        }
        
        layerImg.snp.makeConstraints {(make) -> Void in
            make.width.equalTo(50)
            make.height.equalTo(50)
//            make.right.equalTo(self.snp.right)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
