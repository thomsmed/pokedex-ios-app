//
//  Pokedex.swift
//  Pokedex
//
//  Created by thomsmed on 03/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation

protocol Pokedex {
    func pokemon(number: Int, completionHandler: @escaping (_ pokemon: Pokemon?) -> Void)
    func page(number: Int, completionHandler: @escaping (_ pokedexPage: PokedexPage?) -> Void)
}
