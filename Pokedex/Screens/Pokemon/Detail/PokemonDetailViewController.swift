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

    private var fetchPokemonTask: PokedexFetchTask?
    private var fetchImageTask: PokedexFetchTask?

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchPokemonTask?.cancel()
        fetchImageTask?.cancel()
    }

    // MARK: Methods
    private func initialize() {
        guard let pokemonListItem = pokemonListItem else {
            return
        }

        if let pokemonSplitViewController = splitViewController as? PokemonSplitViewController {
            navigationItem.leftBarButtonItem = pokemonSplitViewController.displayModeBarButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
        
        if pokemonListItem.name.isEmpty {
            fetchPokemonTask = pokedex.fetchPokemon(pokemonListItem.number,
                                                    completionHandler: { (result: Result<Pokemon, Error>) -> Void in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let pokemon):
                    self.pokemon = pokemon
                }
            })
        } else {
            fetchPokemonTask = pokedex.fetchPokemon(pokemonListItem.name,
                                                    completionHandler: { (result: Result<Pokemon, Error>) -> Void in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let pokemon):
                    self.pokemon = pokemon
                }
            })
        }
    }

    private func prepareView() {
        guard let pokemonListItem = pokemonListItem else {
            return
        }

        navigationItem.title = pokemonListItem.name

        if let imageData = pokemonListItem.imageData {
            imageView.image = UIImage(data: imageData)
        }
    }

    private func updateView() {
        guard let pokemon = pokemon else {
            return
        }

        navigationItem.title = pokemon.name

        guard imageView.image == nil,
              let imageUrl = pokemon.imageUrl else {
            return
        }

        fetchImageTask = pokedex.fetchImage(imageUrl, completionHandler: { (result: Result<Data, Error>) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let imageData):
                self.imageView.image = UIImage(data: imageData)
            }
        })
    }

}
