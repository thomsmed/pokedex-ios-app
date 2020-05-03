//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 04/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import UIKit
import Resolver

class PokemonDetailViewController: UIViewController {
    
    @Injected var pokedex: Pokedex

    // MARK: Properties
    var pokedexPageItem: PokedexPageItem? {
        didSet {
            configureView()
        }
    }
    private var pokemon: Pokemon? {
        didSet {
            updateView()
        }
    }

    // MARK: Outlets

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    // MARK: Methods
    private func configureView() {
        guard let pokemon = pokedexPageItem else {
            return
        }

        if let pokemonSplitViewController = splitViewController as? PokemonSplitViewController {
            navigationItem.leftBarButtonItem = pokemonSplitViewController.displayModeBarButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }

        navigationItem.title = pokemon.name
        
        pokedex.pokemon(number: pokemon.number, completionHandler: { (pokemon: Pokemon?) -> Void in
            self.pokemon = pokemon
        })
    }
    
    private func updateView() {
        
    }

}
