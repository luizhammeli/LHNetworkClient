//
//  NetworkPrinter.swift
//  
//
//  Created by Luiz Diniz Hammerli on 21/08/23.
//

import Foundation

protocol Printer {
    func print(_ value: String)
}

final class NetworkPrinter: Printer {
    func print(_ value: String) {
        debugPrint(value)
    }
}
