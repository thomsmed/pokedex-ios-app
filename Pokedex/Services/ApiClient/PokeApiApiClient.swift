//
//  PokeApiClient.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 21/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import Foundation

enum PokeApiApiClientError: Error {
    case noResponse
    case wrongMimeType
}

class PokeApiApiClient: ApiClient {
    static let baseUrl: String = "https://pokeapi.co/api/v2/"

    // TODO: RETURN RESULT WITH SUCCESS(T) AND FAILURE(ERROR)
    func requestResouce<T: Decodable>(_ resource: String,
                                      withParams params: [String: String]?,
                                      completionHandler callback: @escaping (_ result: T?, _ error: Error?) -> Void) {

        var urlString = "\(PokeApiApiClient.baseUrl)\(resource)"

        if let paramsDictionary = params {
            urlString += "?"
            for (param, value) in paramsDictionary {
                urlString += "\(param)=\(value)&"
            }
        }

        let url = URL(string: urlString)!

        URLSession.shared.dataTask(with: url,
                                   completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in

            if let error = error {
                return callback(nil, error)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return callback(nil, PokeApiApiClientError.noResponse)
            }

            guard let mimeType = httpResponse.mimeType,
                  mimeType == "application/json",
                  let data = data else {
                return callback(nil, PokeApiApiClientError.wrongMimeType)
            }

            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(T.self, from: data)
                callback(result, nil)
            } catch {
                callback(nil, error)
            }

        }).resume()
    }
}
