//
//  HelperClass.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 25/09/24.
//

import Foundation
import AVFoundation
import UIKit

import UIKit

class FadingLayout: UICollectionViewFlowLayout,UICollectionViewDelegateFlowLayout {

    //should be 0<fade<1
    private let fadeFactor: CGFloat = 0.5
    private let cellHeight : CGFloat = 80.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(scrollDirection:UICollectionView.ScrollDirection) {
        super.init()
        self.scrollDirection = scrollDirection

    }

    override func prepare() {
        setupLayout()
        super.prepare()
    }

    func setupLayout() {
        self.itemSize = CGSize(width: self.collectionView!.bounds.size.width,height:cellHeight)
        self.minimumLineSpacing = 8
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    func scrollDirectionOver() -> UICollectionView.ScrollDirection {
        return UICollectionView.ScrollDirection.horizontal
    }
    //this will fade both top and bottom but can be adjusted
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesSuper: [UICollectionViewLayoutAttributes] = (super.layoutAttributesForElements(in: rect) as [UICollectionViewLayoutAttributes]?)!
        if let attributes = NSArray(array: attributesSuper, copyItems: true) as? [UICollectionViewLayoutAttributes]{
            var visibleRect = CGRect()
            visibleRect.origin = collectionView!.contentOffset
            visibleRect.size = collectionView!.bounds.size
            for attrs in attributes {
                if attrs.frame.intersects(rect) {
                    let distance = visibleRect.midY - attrs.center.y
                    let normalizedDistance = abs(distance) / (visibleRect.height * fadeFactor)
                    let fade = 1 - normalizedDistance
                    attrs.alpha = fade
                }
            }
            return attributes
        }else{
            return nil
        }
    }
    //appear and disappear at 0
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: itemIndexPath)! as UICollectionViewLayoutAttributes
        attributes.alpha = 0
        return attributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: itemIndexPath)! as UICollectionViewLayoutAttributes
        attributes.alpha = 0
        return attributes
    }
}




class CircularCollectionViewLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        let centerX = collectionView!.bounds.midX
        let centerY = collectionView!.bounds.midY
        
        attributes?.forEach { attribute in
            let distanceFromCenter = abs(attribute.center.x - centerX)
            let normalizedDistance = distanceFromCenter / (collectionView!.bounds.width / 2)
            let zoom = max(1 - normalizedDistance, 0.8) // Scale down as you move away from center
            attribute.transform = CGAffineTransform(scaleX: zoom, y: zoom)
            attribute.zIndex = Int(zoom * 10) // Higher zIndex for larger items
        }
        
        return attributes
    }
}


class CatView: UIView {
    let dropDownImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDropDownImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDropDownImage()
    }

    // Setup drop down image
    private func setupDropDownImage() {
        dropDownImageView.translatesAutoresizingMaskIntoConstraints = false
        dropDownImageView.image = UIImage(systemName: "arrowtriangle.down.fill") // Make sure the arrow image is in your assets
        dropDownImageView.tintColor = UIColor(hex: "#3c3c3c")?.withAlphaComponent(0.6)
        self.addSubview(dropDownImageView)
        
        // Position the arrow in the center or wherever you like
        NSLayoutConstraint.activate([
            dropDownImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dropDownImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 12), // Adjust position
            dropDownImageView.widthAnchor.constraint(equalToConstant: 20),  // Adjust arrow size
            dropDownImageView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
}



extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
