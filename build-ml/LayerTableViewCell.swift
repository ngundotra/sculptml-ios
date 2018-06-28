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
    
    let layerImg = UIImageView()
    let layerName = UILabel()
    let layerDesc = UILabel()
    
    // FIXME: add layer description, maybe button to detail page
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setEverything()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setEverything() {
        let layerDescSize: CGFloat = 12.5
        
        contentView.addSubview(layerName)
        contentView.addSubview(layerImg)
        contentView.addSubview(layerDesc)
        
        // Layer Name constraints
        layerName.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(10)
        }
        // make layer name bold
        layerName.font = UIFont.boldSystemFont(ofSize: layerName.font.pointSize)
        
        // Layer Description constraints
        layerDesc.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(layerName.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(20)
        }
        // set layer description font size
        layerDesc.font = UIFont(name: layerDesc.font.fontName, size: layerDescSize)
        
        // Layer Image constraints
        layerImg.snp.makeConstraints{(make) -> Void in
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    // No longer used because there is no storyboard connection XD
    override func awakeFromNib() {
        super.awakeFromNib()
        setEverything()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
