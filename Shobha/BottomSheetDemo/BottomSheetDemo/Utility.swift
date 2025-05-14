//
//  Utility.swift
//  AutoAndManualScrollDemo
//
//  Created by 41_MacBook_Air on 12/05/25.
//

import UIKit

final class CustomVisualEffectView: UIVisualEffectView {
    private var animator: UIViewPropertyAnimator?
    private let theEffect: UIVisualEffect
    // Make intensity settable
    var intensity: CGFloat = 1.0 {
        didSet {
            animator?.fractionComplete = min(max(intensity, 0), 1)
        }
    }
    init(effect: UIVisualEffect, intensity: CGFloat) {
        self.theEffect = effect
        self.intensity = intensity
        super.init(effect: nil)
        setupAnimator()
    }
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    deinit {
        animator?.stopAnimation(true)
    }
    private func setupAnimator() {
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.pausesOnCompletion = true
        animator?.fractionComplete = intensity
    }
}
