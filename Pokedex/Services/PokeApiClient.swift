//
//  PokeApiClient.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 21/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import Foundation

class PokeApiClient: ApiClient {
    static let baseUrl: String = "https://pokeapi.co/api/v2/"

    func requestResouce<T: Decodable>(_ resource: String,
                                      withParams params: [String: String]?,
                                      completionHandler callback: @escaping (_ result: T?, _ error: Error?) -> Void) {

        var urlString = "\(PokeApiClient.baseUrl)\(resource)"

        if let paramsDictionary = params {
            urlString += "?"
            for (param, value) in paramsDictionary {
                urlString += "\(param)=\(value)&"
            }
        }

        let url = URL(string: urlString)!

        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in

            if let error = error {
                return callback(nil, error)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return callback(nil, nil)
            }

            if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data {

                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(T.self, from: data)
                    return callback(result, nil)
                } catch {
                    print(error)
                    return callback(nil, nil)
                }
            }

            return callback(nil, nil)

        }).resume()
    }
}
