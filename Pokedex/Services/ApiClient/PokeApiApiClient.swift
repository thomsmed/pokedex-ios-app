//
//  PokeApiClient.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 21/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import Foundation

enum ApiClientError: Error {
    case noResponse
    case noData
}

class PokeApiApiClient: ApiClient {
    static let baseUrl: String = "https://pokeapi.co/api/v2/"

    func requestResouce<T: Decodable>(_ resource: String,
                                      withParams params: [String: String]?,
                                      completionHandler callback:
                                        @escaping (Result<T, Error>) -> Void) -> URLSessionTask {

        var urlString = "\(PokeApiApiClient.baseUrl)\(resource)"

        if let paramsDictionary = params {
            urlString += "?"
            for (param, value) in paramsDictionary {
                urlString += "\(param)=\(value)&"
            }
        }

        let url = URL(string: urlString)!

        let task = URLSession.shared.dataTask(with: url,
                                   completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in

            if let error = error {
                return callback(Result.failure(error))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return callback(Result.failure(ApiClientError.noResponse))
            }

            guard let mimeType = httpResponse.mimeType,
                  mimeType == "application/json",
                  let data = data else {
                return callback(Result.failure(ApiClientError.noData))
            }

            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(T.self, from: data)
                callback(Result.success(result))
            } catch {
                callback(Result.failure(error))
            }
        })

        task.resume()

        return task
    }
}
