//
//  Pokedex.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation

protocol PokedexFetchTask {
    func cancel()
}

protocol Pokedex {
    func fetchPokemon(_ pokemonNumber: Int,
                      completionHandler: @escaping (Result<Pokemon, Error>) -> Void) -> PokedexFetchTask
    func fetchPage(_ pageNumber: Int,
                   completionHandler: @escaping (Result<PokedexPage, Error>) -> Void) -> PokedexFetchTask
}
