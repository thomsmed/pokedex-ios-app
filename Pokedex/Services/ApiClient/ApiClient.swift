//
//  ApiClient.swift
//  Pokedex
//
//  Created by thomsmed on 01/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation

protocol ApiClient {
    func requestResouce<T: Decodable>(_ resource: String,
                                      withParams params: [String: String]?,
                                      completionHandler callback:
                                        @escaping (Result<T, Error>) -> Void) -> URLSessionTask
}
