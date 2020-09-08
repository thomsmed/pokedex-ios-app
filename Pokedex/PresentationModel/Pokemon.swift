//
//  Pokemon.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import UIKit

enum PokemonType {
    case grass
    case fire
    case water
    case normal
    case bug
    case flying
}

struct Pokemon {
    let number: Int
    let name: String
    let type: PokemonType
    let image: String
}

struct PokedexPage {
    let number: Int
    let totalPagesCount: Int
    let totalItemsCount: Int
    let items: [PokedexPageItem]
}

struct PokedexPageItem {
    let number: Int
    let name: String
}
