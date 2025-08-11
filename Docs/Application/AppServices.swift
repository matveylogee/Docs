//
//  AppServices.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import Foundation

final class AppServices {
    let dateService: CurrentDateProtocol
    let networkService: NetworkServiceProtocol
    let keychainService: KeychainServiceProtocol
    let tokenProvider: TokenProviderProtocol

    init() {
        self.keychainService = KeychainService()

        let savedToken: String?
        do { savedToken = try keychainService.fetch(.authToken) } catch { savedToken = nil }

        let provider = AuthTokenStorage(initialToken: savedToken)
        self.tokenProvider = provider

        self.dateService = CurrentDate()
        self.networkService = NetworkService(session: URLSession.shared, tokenProvider: provider)
    }
}
