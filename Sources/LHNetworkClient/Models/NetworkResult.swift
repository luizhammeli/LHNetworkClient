//
//  NetworkResult.swift
//  
//
//  Created by Luiz Diniz Hammerli on 21/08/23.
//

import Foundation

public struct NetworkResult<T: Codable> {
    let result: Result<T, HttpError>
    var statusCode: Int
    var defaultData: Data?
}

