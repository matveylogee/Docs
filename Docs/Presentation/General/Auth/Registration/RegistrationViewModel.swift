//
//  RegistrationViewModel.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

protocol RegistrationViewModelProtocol: AnyObject {
    var onSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func register(username: String, email: String, password: String)
}

final class RegistrationViewModel: RegistrationViewModelProtocol {
    
    // MARK: - Dependencies
    private let network: NetworkServiceProtocol
    private let keychain: KeychainServiceProtocol
    
    // MARK: - Callbacks
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Init
    init(network: NetworkServiceProtocol, keychain: KeychainServiceProtocol) {
        self.network = network
        self.keychain = keychain
    }
    
    // MARK: - Actions
    func register(username: String, email: String, password: String) {
        let req = RegisterRequest(username: username, email: email, password: password)
        Task {
            do {
                let tokenResp: TokenResponse = try await network.request(
                    endpoint: AuthEndpoint.register(request: req),
                    requestDTO: req
                )
                
                try keychain.save(tokenResp.value, for: .authToken)
                
                onSuccess?()
            } catch let error as NetworkError {
                onError?("Сервер вернул ошибку: \(error)")
            } catch {
                onError?("Неизвестная ошибка: \(error.localizedDescription)")
            }
        }
    }
}
