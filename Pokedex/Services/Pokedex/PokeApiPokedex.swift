//
//  PokeApiPokedex.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import Resolver

extension URLSessionTask: PokedexFetchTask { }
struct EmptyPokedexFetchTask: PokedexFetchTask {
    func cancel() {
        // Do nothng lol
    }
}

enum PokeApiPokedexError: Error {
    case noPage
    case noPokemon
}

class PokeApiPokedex: Pokedex {
    @Injected var apiClient: ApiClient

    private var pokemon: [Int: Pokemon] = [:]

    private let limit = 50

    func fetchPokemon(_ pokemonNumber: Int,
                      completionHandler: @escaping (Result<Pokemon, Error>) -> Void) -> PokedexFetchTask {
        if pokemonNumber < 0 {
            DispatchQueue.main.async {
                completionHandler(Result.failure(PokeApiPokedexError.noPokemon))
            }
            return EmptyPokedexFetchTask()
        }

        if let pokemon = pokemon[pokemonNumber] {
            DispatchQueue.main.async {
                completionHandler(Result.success(pokemon))
            }
            return EmptyPokedexFetchTask()
        }

        return apiClient.requestResouce("pokemon/\(pokemonNumber)",
                                             withParams: nil,
                                             completionHandler: { (pokeApiPokemon: PokeApiPokemon?, error: Error?) in
            if let error = error {
                return DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            }
            guard let pokeApiPokemon = pokeApiPokemon else {
                return DispatchQueue.main.async {
                    completionHandler(Result.failure(PokeApiPokedexError.noPokemon))
                }
            }

            let pokemon = Pokemon(number: pokeApiPokemon.number,
                                  name: pokeApiPokemon.name,
                                  type: .grass,
                                  image: pokeApiPokemon.sprites.frontDefault)
            self.pokemon[pokeApiPokemon.number] = pokemon
            DispatchQueue.main.async {
                completionHandler(Result.success(pokemon))
            }
        })
    }

    func fetchPage(_ pageNumber: Int,
                   completionHandler: @escaping (Result<PokedexPage, Error>) -> Void) -> PokedexFetchTask {
        if pageNumber < 1 {
            DispatchQueue.main.async {
                completionHandler(Result.failure(PokeApiPokedexError.noPage))
            }
            return EmptyPokedexFetchTask()
        }

        return apiClient.requestResouce("pokemon",
                                        withParams: ["offset": "\((pageNumber - 1) * limit)", "limit": "\(limit)"],
                                        completionHandler: { (page: PokeApiPokemonPage?, error: Error?) in
            if let error = error {
                return DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            }

            guard let page = page else {
                return DispatchQueue.main.async {
                    completionHandler(Result.failure(PokeApiPokedexError.noPage))
                }
            }

            var pokedexPageItems: [PokedexPageItem] = []
            let totalPages = page.count / self.limit + (page.count % self.limit > 0 ? 1 : 0)
            for (index, result) in page.results.enumerated() {
                let pokemonNumber = self.limit * pageNumber - self.limit + index + 1
                pokedexPageItems.append(PokedexPageItem(number: pokemonNumber, name: result.name))
            }

            DispatchQueue.main.async {
                completionHandler(Result.success(PokedexPage(number: pageNumber,
                                              totalPagesCount: totalPages,
                                              totalItemsCount: page.count,
                                              items: pokedexPageItems)))
            }
        })
    }
}
