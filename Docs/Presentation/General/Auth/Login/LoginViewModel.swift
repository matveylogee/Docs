//
//  LoginViewModel.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

protocol LoginViewModelProtocol: AnyObject {
    var onSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func login(email: String, password: String)
}

final class LoginViewModel: LoginViewModelProtocol {
    
    // MARK: - Dependencies
    private let network: NetworkServiceProtocol
    private let tokenProvider: TokenProviderProtocol
    private let keychain: KeychainServiceProtocol
    
    // MARK: - Callbacks
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Init
    init(network: NetworkServiceProtocol, tokenProvider: TokenProviderProtocol, keychain: KeychainServiceProtocol) {
        self.network = network
        self.tokenProvider = tokenProvider
        self.keychain = keychain
    }
    
    // MARK: - Actions
    func login(email: String, password: String) {
        Task { @MainActor in
            do {
                /// Выполняем запрос — это всё происходит асинхронно, но в рамках MainActor
                let resp: TokenResponse = try await network.request(
                    endpoint: AuthEndpoint.login(email: email, password: password),
                    requestDTO: EmptyRequest()
                )
                /// Сохраняем токен и в in-memory storage, и в keychain
                tokenProvider.save(token: resp.value)
                try keychain.save(resp.value, for: .authToken)
                /// Вызываем колл-бек
                onSuccess?()
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
}
