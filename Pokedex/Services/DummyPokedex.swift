//
//  DummyPokedex.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import UIKit

class DummyPokedex: Pokedex {
    func pokemon(number: Int, completionHandler: @escaping (Pokemon?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1, execute: {
            let thePokemon = self.pokemon.count <= number ? self.pokemon[number - 1] : nil
            DispatchQueue.main.async {
                completionHandler(thePokemon)                
            }
        })
    }

    func page(number: Int, completionHandler: @escaping (PokedexPage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1, execute: {
            if number != 1 {
                return completionHandler(nil)
            }
            
            let pokedexPage = PokedexPage(number: 1, totalPagesCount: 1, totalItemsCount: self.pokemon.count, items: self.pokemon.map({ pokemon in
                return PokedexPageItem(number: pokemon.number, name: pokemon.name, type: pokemon.type, image: pokemon.image)
            }))
            
            DispatchQueue.main.async {
                completionHandler(pokedexPage)
            }
        })
    }

    private let pokemon: [Pokemon] = [
        Pokemon(number: 1, name: "Bulbasaur", type: .grass, image: UIImage(named: "bulbasaur")!),
        Pokemon(number: 2, name: "Ivysaur", type: .grass, image: UIImage(named: "ivysaur")!),
        Pokemon(number: 3, name: "Venusaur", type: .grass, image: UIImage(named: "venusaur")!),
        Pokemon(number: 4, name: "Charmander", type: .fire, image: UIImage(named: "charmander")!),
        Pokemon(number: 5, name: "Charmeleon", type: .fire, image: UIImage(named: "charmeleon")!),
        Pokemon(number: 6, name: "Charizard", type: .fire, image: UIImage(named: "charizard")!),
        Pokemon(number: 7, name: "Squirtle", type: .water, image: UIImage(named: "squirtle")!),
        Pokemon(number: 8, name: "Wartortle", type: .water, image: UIImage(named: "wartortle")!),
        Pokemon(number: 9, name: "Blastoise", type: .water, image: UIImage(named: "blastoise")!),
        Pokemon(number: 10, name: "Caterpie", type: .bug, image: UIImage(named: "caterpie")!),
        Pokemon(number: 11, name: "Metapod", type: .bug, image: UIImage(named: "metapod")!),
        Pokemon(number: 12, name: "Butterfree", type: .bug, image: UIImage(named: "butterfree")!),
        Pokemon(number: 13, name: "Weedle", type: .bug, image: UIImage(named: "weedle")!),
        Pokemon(number: 14, name: "Kakuna", type: .bug, image: UIImage(named: "kakuna")!),
        Pokemon(number: 15, name: "Beedrill", type: .bug, image: UIImage(named: "beedrill")!),
        Pokemon(number: 16, name: "Pidgey", type: .flying, image: UIImage(named: "pidgey")!),
        Pokemon(number: 17, name: "Pidgeotto", type: .flying, image: UIImage(named: "pidgeotto")!),
        Pokemon(number: 18, name: "Pidgeot", type: .flying, image: UIImage(named: "pidgeot")!),
        Pokemon(number: 19, name: "Rattata", type: .normal, image: UIImage(named: "rattata")!),
        Pokemon(number: 20, name: "Raticate", type: .normal, image: UIImage(named: "raticate")!)
    ]
}
