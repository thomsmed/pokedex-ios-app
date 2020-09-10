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
    func fetchPokemon(_ pokemonNumber: Int, completionHandler: @escaping (_ pokemon: Pokemon?, _ error: Error?) -> Void) -> PokedexFetchTask
    func fetchPage(_ pageNumber: Int, completionHandler: @escaping (_ pokedexPage: PokedexPage?, _ error: Error?) -> Void) -> PokedexFetchTask
}
