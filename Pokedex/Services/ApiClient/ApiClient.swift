//
//  ApiClient.swift
//  Pokedex
//
//  Created by thomsmed on 01/05/2020.
//  Copyright © 2020 Thomas A. Smedmann. All rights reserved.
//

import Foundation

protocol ApiClient {
    func requestObject<T: Decodable>(atRelativePath relativePath: String,
                                      withParams params: [String: String]?,
                                      completionHandler callback:
                                        @escaping (Result<T, Error>) -> Void) -> URLSessionTask
    func requestData(atAbsolutePath absolutePath: String,
                                      withParams params: [String: String]?,
                                      completionHandler callback:
                                        @escaping (Result<Data, Error>) -> Void) -> URLSessionTask
}
