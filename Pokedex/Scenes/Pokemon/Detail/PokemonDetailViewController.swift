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
            initialize()
        }
    }
    private var pokemon: Pokemon? {
        didSet {
            updateView()
        }
    }

    // MARK: Outlets
    @IBOutlet var imageView: UIImageView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        prepareView()
    }

    // MARK: Methods
    private func initialize() {
        guard let pokedexPageItem = pokedexPageItem else {
            return
        }

        if let pokemonSplitViewController = splitViewController as? PokemonSplitViewController {
            navigationItem.leftBarButtonItem = pokemonSplitViewController.displayModeBarButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }

        pokedex.pokemon(number: pokedexPageItem.number, completionHandler: { (pokemon: Pokemon?) -> Void in
            self.pokemon = pokemon
        })
    }
    
    private func prepareView() {
        guard let pokedexPageItem = pokedexPageItem else {
            return
        }
        
        pokemon = Pokemon(number: pokedexPageItem.number,
                          name: pokedexPageItem.name,
                          type: pokedexPageItem.type,
                          image: pokedexPageItem.image)
    }

    private func updateView() {
        guard let pokemon = pokemon else {
            return
        }
        
        navigationItem.title = pokemon.name
        imageView.image = pokemon.image
    }

}
