//
//  PokeApiPokedex.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import Resolver

enum PokeApiPokedexError: Error {
    case noPage
    case noPokemon
}

class PokeApiPokedex: Pokedex {
    @Injected var apiClient: ApiClient

    private var pokemon: [Int:Pokemon] = [:]

    private let limit = 50

    func pokemon(number: Int, completionHandler: @escaping (Pokemon?, Error?) -> Void) {
        if number < 0 {
            return DispatchQueue.main.async {
                completionHandler(nil, PokeApiPokedexError.noPokemon)
            }
        }
        
//        if pokemon.count >= number {
//            return DispatchQueue.main.async {
//                completionHandler(self.pokemon[number - 1], nil)
//            }
//        }

        return apiClient.requestResouce("pokemon/\(number)",
                                             withParams: nil,
                                             completionHandler: { (pokeApiPokemon: PokeApiPokemon?, error: Error?) in
            if let error = error {
                return DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
            guard let pokeApiPokemon = pokeApiPokemon else {
                return DispatchQueue.main.async {
                    completionHandler(nil, PokeApiPokedexError.noPokemon)
                }
            }

            DispatchQueue.main.async {
                completionHandler(Pokemon(number: pokeApiPokemon.number,
                                          name: pokeApiPokemon.name,
                                          type: .grass,
                                          image: pokeApiPokemon.sprites.frontDefault), nil)
            }
        })
    }

    func page(number: Int, completionHandler: @escaping (PokedexPage?, Error?) -> Void) {
        if number < 1 {
            DispatchQueue.main.async {
                return completionHandler(nil, PokeApiPokedexError.noPage)
            }
        }

        return apiClient.requestResouce("pokemon",
                                        withParams: ["offset": "\((number - 1) * limit)", "limit": "\(limit)"],
                                        completionHandler: { (page: PokeApiPokemonPage?, error: Error?) in
            if let error = error {
                return DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }

            guard let page = page else {
                return DispatchQueue.main.async {
                    completionHandler(nil, PokeApiPokedexError.noPage)
                }
            }

            var pokedexPageItems: [PokedexPageItem] = []
            let totalPages = page.count / self.limit + (page.count % self.limit > 0 ? 1 : 0)
            for (index, result) in page.results.enumerated() {
                let pokemonNumber = self.limit * number - self.limit + index + 1
                pokedexPageItems.append(PokedexPageItem(number: pokemonNumber, name: result.name))
            }

            DispatchQueue.main.async {
                completionHandler(PokedexPage(number: number,
                                              totalPagesCount: totalPages,
                                              totalItemsCount: page.count,
                                              items: pokedexPageItems), nil)
            }
        })
    }
}
