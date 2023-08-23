//
//  DefaultNetworkLogger.swift
//  
//
//  Created by Luiz Diniz Hammerli on 21/08/23.
//

import Foundation

protocol NetworkLogger {
    func logSuccessRequest(data: Data, statusCode: Int)
    func logFailureRequest(error: HttpError, statusCode: Int)
    func logRequest(provider: HttpClientProvider)
}

final class DefaultNetworkLogger: NetworkLogger {
    let printer: Printer
    
    init(printer: Printer = NetworkPrinter()) {
        self.printer = printer
    }
    
    func logSuccessRequest(data: Data, statusCode: Int) {
        printer.print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅")
        printer.print("Success Request")
        printer.print("Request StatusCode: \(statusCode)")
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            printer.print("Response Data:")
            printer.print(String(decoding: jsonData, as: UTF8.self))
        } else {
            printer.print("json data malformed")
        }
    }
    
    func logFailureRequest(error: HttpError, statusCode: Int) {
        printer.print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌")
        printer.print("Failure Request")
        printer.print("Request StatusCode: \(statusCode)")
        printer.print("Request StatusCode Description Error: \(error)")
    }
    
    func logRequest(provider: HttpClientProvider) {
        printer.print("Network Request Started 🛜")
        printer.print("Default URL: \(provider.url.description)")
        printer.print("Complete URL: \(provider.makeURLWithQueryItems())")
        printer.print("Headers: \(provider.headers ?? [:])")
        printer.print("Method: \(provider.method.rawValue)")
        printer.print("Query Items: \(provider.queryParams ?? [:])")
        printer.print("Body: \(provider.body ?? [:])")
    }
}
