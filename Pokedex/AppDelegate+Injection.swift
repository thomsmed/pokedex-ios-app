//
//  AppDelegate+Injection.swift
//  Smed1Bank
//
//  Created by thomsmed on 17/04/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { PokeApiClient() as ApiClient }
    }
}
