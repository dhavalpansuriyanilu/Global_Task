//
//  videoCollectionCell.swift
//  ImageProcessing
//
//  Created by Developer 1 on 09/11/23.
//

import UIKit

class videoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var lblVideoName: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Add a border when the cell is selected
                layer.borderWidth = 2.0
                layer.borderColor = UIColor.white.cgColor
            } else {
                // Remove the border when the cell is deselected
                layer.borderWidth = 0.0
            }
        }
    }
}
