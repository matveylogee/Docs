//
//  AuthTokenStorage.swift
//  generator
//
//  Created by Матвей on 26.05.2025.
//

import Foundation

protocol TokenProviderProtocol {
    var token: String? { get }
    func save(token: String)
}

final class AuthTokenStorage: TokenProviderProtocol {
    
    private(set) var token: String?
    
    init(initialToken: String? = nil) {
        self.token = initialToken
    }
    
    func save(token: String) {
        self.token = token
    }
}
