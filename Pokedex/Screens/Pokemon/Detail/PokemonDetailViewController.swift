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
    var pokemonListItem: PokemonListItem? {
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
        guard let pokedexPageItem = pokemonListItem else {
            return
        }

        if let pokemonSplitViewController = splitViewController as? PokemonSplitViewController {
            navigationItem.leftBarButtonItem = pokemonSplitViewController.displayModeBarButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }

        _ = pokedex.fetchPokemon(pokedexPageItem.name,
                                 completionHandler: { (result: Result<Pokemon, Error>) -> Void in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pokemon):
                self.pokemon = pokemon
            }
        })
    }

    private func prepareView() {
        guard let pokedexPageItem = pokemonListItem else {
            return
        }

        navigationItem.title = pokedexPageItem.name
    }

    private func updateView() {
        guard let pokemon = pokemon else {
            return
        }

        navigationItem.title = pokemon.name
//        imageView.image = pokemon.image
    }

}
