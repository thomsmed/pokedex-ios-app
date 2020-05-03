//
//  Pokemon.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 05/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import Foundation

struct PokeApiPokemon: Decodable {
    var identifier: Int
    var name: String
    var baseExperience: Int
    var height: Int
    var isDefault: Bool
    var order: Int
    var weight: Int
//    var forms: [Any]
//    var gameIndices: [Any]
//    var heldItems: [Any]
    var locationAreaEncounters: String
//    var moves: [Any]
    var sprites: PokeApiPokemonSprites
//    var species: Any
//    var stats: [Any]
//    var types: [Any]
}

struct PokeApiPokemonSprites: Decodable {
    var backFemale: String
    var backShinyFemale: String
    var backDefault: String
    var frontFemale: String
    var frontShinyFemale: String
    var backShiny: String
    var frontDefault: String
    var frontShiny: String
}

struct PokeApiPokemonPageItem: Decodable {
    var name: String
    var url: String
}

struct PokeApiPokemonPage: Decodable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [PokeApiPokemonPageItem]?
}
