//
//  DetailViewController.swift
//  pokedex
//
//  Created by Thomas A. Smedmann on 04/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import UIKit

class PokemonDetailViewController: UIViewController {

    // MARK: Properties
    var pokemon: PokemonPageItem? {
        didSet {
            configureView()
        }
    }

    // MARK: Outlets

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    // MARK: Methods
    func configureView() {
        guard let pokemon = pokemon else {
            return
        }
        
        if let pokemonSplitViewController = splitViewController as? PokemonSplitViewController {
            navigationItem.leftBarButtonItem = pokemonSplitViewController.displayModeBarButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
        
        navigationItem.title = pokemon.name
    }

}
