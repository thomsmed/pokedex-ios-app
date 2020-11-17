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

enum PokedexError: Error {
    case noPage
    case noPokemon
}

class PokeApiPokedex: Pokedex {
    @Injected var apiClient: ApiClient

    private var pokemonNumbers: [String: Int] = [:]
    private var pokemon: [Int: Pokemon] = [:]
    private var pokedexPages: [Int: PokedexPage] = [:]

    private let limit = 50

    func fetchPokemon(_ pokemonNumber: Int,
                      completionHandler: @escaping (Result<Pokemon, Error>) -> Void) -> PokedexFetchTask {
        if pokemonNumber < 0 {
            DispatchQueue.main.async {
                completionHandler(Result.failure(PokedexError.noPokemon))
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
                                             completionHandler: { (result: Result<PokeApiPokemon, Error>) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            case .success(let pokeApiPokemon):
                let pokemon = Pokemon(number: pokeApiPokemon.number,
                                      name: pokeApiPokemon.name,
                                      type: .grass,
                                      imageUrl: pokeApiPokemon.sprites.frontDefault)
                self.pokemon[pokeApiPokemon.number] = pokemon
                self.pokemonNumbers[pokeApiPokemon.name] = pokemon.number
                DispatchQueue.main.async {
                    completionHandler(Result.success(pokemon))
                }
            }
        })
    }

    func fetchPokemon(_ pokemonName: String,
                      completionHandler: @escaping (Result<Pokemon, Error>) -> Void) -> PokedexFetchTask {
        if pokemonName.isEmpty {
            DispatchQueue.main.async {
                completionHandler(Result.failure(PokedexError.noPokemon))
            }
            return EmptyPokedexFetchTask()
        }

        if let pokemonNumber = pokemonNumbers[pokemonName], let pokemon = pokemon[pokemonNumber] {
            DispatchQueue.main.async {
                completionHandler(Result.success(pokemon))
            }
            return EmptyPokedexFetchTask()
        }

        return apiClient.requestResouce("pokemon/\(pokemonName)",
                                             withParams: nil,
                                             completionHandler: { (result: Result<PokeApiPokemon, Error>) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            case .success(let pokeApiPokemon):
                let pokemon = Pokemon(number: pokeApiPokemon.number,
                                      name: pokeApiPokemon.name,
                                      type: .grass,
                                      imageUrl: pokeApiPokemon.sprites.frontDefault)
                self.pokemon[pokeApiPokemon.number] = pokemon
                self.pokemonNumbers[pokeApiPokemon.name] = pokemon.number
                DispatchQueue.main.async {
                    completionHandler(Result.success(pokemon))
                }
            }
        })
    }

    func fetchPage(_ pageNumber: Int,
                   completionHandler: @escaping (Result<PokedexPage, Error>) -> Void) -> PokedexFetchTask {
        if pageNumber < 1 {
            DispatchQueue.main.async {
                completionHandler(Result.failure(PokedexError.noPage))
            }
            return EmptyPokedexFetchTask()
        }

        if let pokedexPage = pokedexPages[pageNumber] {
            DispatchQueue.main.async {
                completionHandler(Result.success(pokedexPage))
            }
            return EmptyPokedexFetchTask()
        }

        return apiClient.requestResouce("pokemon",
                                        withParams: ["offset": "\((pageNumber - 1) * limit)", "limit": "\(limit)"],
                                        completionHandler: { (result: Result<PokeApiPokemonPage, Error>) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(Result.failure(error))
                }
            case .success(let pokeApiPokemonPage):
                var pokedexPageItems: [PokedexPageItem] = []
                let totalPages = pokeApiPokemonPage.count / self.limit + (
                    pokeApiPokemonPage.count % self.limit > 0 ? 1 : 0
                )

                for (index, result) in pokeApiPokemonPage.results.enumerated() {
                    let pokemonNumber = self.limit * pageNumber - self.limit + index + 1
                    pokedexPageItems.append(PokedexPageItem(number: pokemonNumber, name: result.name))
                }

                let pokedexPage = PokedexPage(number: pageNumber,
                                              totalPagesCount: totalPages,
                                              totalItemsCount: pokeApiPokemonPage.count,
                                              items: pokedexPageItems)
                self.pokedexPages[pageNumber] = pokedexPage
                DispatchQueue.main.async {
                    completionHandler(Result.success(pokedexPage))
                }
            }
        })
    }
}
