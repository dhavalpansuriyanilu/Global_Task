//
//  FilterCollectionCell.swift
//  ImageProcessing
//
//  Created by Developer 1 on 07/11/23.
//

import UIKit

class FilterCollectionCell: UICollectionViewCell {
   
    @IBOutlet weak var lblFilterName: UILabel!
    
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
