//
//  ProfileViewModel.swift
//  generator
//
//  Created by Матвей on 27.05.2025.
//

import Foundation

protocol ProfileViewModelProtocol: AnyObject {
    var onProfileLoaded: ((UserPublic) -> Void)? { get set }
    var onProfileUpdated: ((UserPublic) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func fetchProfile()
    func updateProfile(username: String?, email: String?, password: String?)
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    private let network: NetworkServiceProtocol

    var onProfileLoaded: ((UserPublic) -> Void)?
    var onProfileUpdated: ((UserPublic) -> Void)?
    var onError: ((String) -> Void)?

    init(network: NetworkServiceProtocol) {
        self.network = network
    }

    func fetchProfile() {
        Task {
            do {
                let profile: UserPublic = try await network.request(
                    endpoint: UserEndpoint.me,
                    requestDTO: EmptyRequest()
                )
                onProfileLoaded?(profile)
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }

    func updateProfile(username: String?, email: String?, password: String?) {
        Task {
            do {
                let dto = UpdateUserDTO(
                    username: username,
                    email:    email,
                    password: password
                )
                let updated: UserPublic = try await network.request(
                    endpoint: UserEndpoint.update(request: dto),
                    requestDTO: dto
                )
                // уведомляем об обновлении
                onProfileUpdated?(updated)
                // обновляем и “перезагружаем” карточку
                onProfileLoaded?(updated)
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
}
