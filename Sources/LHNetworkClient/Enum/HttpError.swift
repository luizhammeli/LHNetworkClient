//
//  HttpError.swift
//  
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation

public enum HttpError: Error, Equatable {
    case noConnectivity
    case forbidden
    case notFound
    case unauthorized
    case serverError
    case badRequest
    case invalidData
    case invalidRequest
    case unknown
}
