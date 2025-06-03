//
//  URLSession.swift
//  Docs
//
//  Created by Матвей on 03.06.2025.
//

//import Foundation
//
//// 1) Протокол, описывающий нужные нам асинхронные методы
//protocol URLSessionProtocol {
//    func data(for request: URLRequest) async throws -> (Data, URLResponse)
//    func download(for request: URLRequest) async throws -> (URL, URLResponse)
//}
//
//// 2) Расширяем URLSession, чтобы он удовлетворял протоколу.
////    Чтобы не уходить в бесконечную рекурсию, вместо `self.data(...)`
////    вызываем `URLSession.shared.data(...)` (так мы попадаем сразу в
////    «оригинальный» метод Foundation, а не в своё расширение).
//extension URLSession: URLSessionProtocol {
//    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
//        return try await URLSession.shared.data(for: request)
//    }
//
//    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
//        return try await URLSession.shared.download(for: request)
//    }
//}

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func download(for request: URLRequest) async throws -> (URL, URLResponse)
}

extension URLSession: URLSessionProtocol {

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data, let response = response else {
                    continuation.resume(throwing: URLError(.unknown))
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.downloadTask(with: request) { localURL, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let localURL = localURL, let response = response else {
                    continuation.resume(throwing: URLError(.unknown))
                    return
                }
                continuation.resume(returning: (localURL, response))
            }
            task.resume()
        }
    }
}
