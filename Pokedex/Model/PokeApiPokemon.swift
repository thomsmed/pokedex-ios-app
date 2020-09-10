//
//  Pokemon.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 05/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import Foundation

struct PokeApiPokemon: Decodable {
    let number: Int
    let name: String
    let order: Int
    let height: Int
    let weight: Int
    let sprites: PokeApiPokemonSprites

    enum CodingKeys: String, CodingKey {
        case number = "id"
        case name
        case order
        case height
        case weight
        case sprites
    }
}

struct PokeApiPokemonSprites: Decodable {
    let frontDefault: String
    let frontShiny: String
    let backDefault: String
    let backShiny: String

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case backDefault = "back_default"
        case frontShiny = "front_shiny"
        case backShiny = "back_shiny"
    }
}

struct PokeApiPokemonPageItem: Decodable {
    let name: String
    let url: String
}

struct PokeApiPokemonPage: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokeApiPokemonPageItem]
}
