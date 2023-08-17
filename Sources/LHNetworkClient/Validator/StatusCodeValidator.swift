//
//  StatusCodeValidator.swift
//  
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation

enum StatusCodeValidator {
    static func checkStatusCode(statusCode: Int) -> HttpError? {
        switch statusCode {
        case 200...299:
            return nil
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400...499:
            return .badRequest
        case 500...599:
            return .serverError
        default:
            return .unknown
        }
    }
}
