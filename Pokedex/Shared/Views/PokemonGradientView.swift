//
//  PokemonGradientView.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PokemonGradientView: UIView {
    @IBInspectable var primaryColor: UIColor? {
        didSet {
            updateLayer()
        }
    }
    @IBInspectable var secondaryColor: UIColor? {
        didSet {
            updateLayer()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskLayer()
    }

    private func initLayer() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)

        addMaskLayer()
    }

    private func addMaskLayer() {
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [UIColor.black.cgColor, UIColor.clear]

        layer.mask = maskLayer
    }

    private func updateMaskLayer() {
        guard let mask = layer.mask else {
            return
        }

        if bounds.width > mask.frame.width {
            mask.frame = bounds
            mask.removeAllAnimations()
        }
    }

    private func updateLayer() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        if let primaryColor = primaryColor, let secondaryColor = secondaryColor {
            gradientLayer.colors = [primaryColor.cgColor, secondaryColor.cgColor]
        } else if let primaryColor = primaryColor {
            gradientLayer.colors = [primaryColor.cgColor]
        } else if let secondaryColor = secondaryColor {
            gradientLayer.colors = [secondaryColor.cgColor]
        }

        layer.setNeedsDisplay()
    }

}
