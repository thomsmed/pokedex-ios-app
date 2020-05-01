//
//  PokemonSplitViewController.swift
//  Pokedex
//
//  Created by thomsmed on 01/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import UIKit

class PokemonSplitViewController: UISplitViewController {

    let displayModeBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    private var displayModeBarButtonItemImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        preferredDisplayMode = .allVisible

        displayModeBarButtonItem.target = displayModeButtonItem.target
        displayModeBarButtonItem.action = displayModeButtonItem.action
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if isCollapsed {
            displayModeBarButtonItemImage = displayModeBarButtonItem.image
            displayModeBarButtonItem.image = nil
        } else {
            displayModeBarButtonItem.image = displayModeBarButtonItemImage
        }
    }
}

// MARK: UISplitViewControllerDelegate
extension PokemonSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        guard let navigationController = secondaryViewController as? UINavigationController,
            let pokemonDetailViewController = navigationController.topViewController
                as? PokemonDetailViewController else {
            return false
        }

        return pokemonDetailViewController.pokemon == nil
    }

    func splitViewController(_ svc: UISplitViewController,
                             willChangeTo displayMode: UISplitViewController.DisplayMode) {
        if UIDevice.current.orientation.isPortrait && UIDevice.current.userInterfaceIdiom == .phone {
            // Ignore
        } else if displayMode == .allVisible {
            displayModeBarButtonItemImage = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        } else if displayMode == .primaryHidden {
            displayModeBarButtonItemImage = UIImage(systemName: "arrow.down.right.and.arrow.up.left")
        } else {
            displayModeBarButtonItemImage = UIImage(systemName: "chevron.left")
        }

        displayModeBarButtonItem.image = displayModeBarButtonItemImage
    }
}
