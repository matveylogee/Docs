//
//  HTTPCode.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

struct HTTPCode {
    
    // MARK: - Информация (сотые)
    static let continueRequest = 100
    static let switchingProtocols = 101
    static let processing = 102
    static let earlyHints = 103

    // MARK: - Успешные (двухсотые)
    static let success = 200
    static let created = 201
    static let accepted = 202
    static let nonAuthoritativeInformation = 203
    static let noContent = 204
    static let resetContent = 205
    static let partialContent = 206
    static let multiStatus = 207
    static let alreadyReported = 208
    static let imUsed = 226

    // MARK: - Перенаправление (трехсотые)
    static let multipleChoices = 300
    static let movedPermanently = 301
    static let found = 302
    static let seeOther = 303
    static let notModified = 304
    static let useProxy = 305
    static let temporaryRedirect = 307
    static let permanentRedirect = 308

    // MARK: - Это наша проблема (четырехсотые)
    static let badRequest = 400
    static let unauthorized = 401
    static let paymentRequired = 402
    static let forbidden = 403
    static let notFound = 404
    static let methodNotAllowed = 405
    static let notAcceptable = 406
    static let proxyAuthenticationRequired = 407
    static let requestTimeout = 408
    static let conflict = 409
    static let gone = 410
    static let lengthRequired = 411
    static let preconditionFailed = 412
    static let payloadTooLarge = 413
    static let uriTooLong = 414
    static let unsupportedMediaType = 415
    static let rangeNotSatisfiable = 416
    static let expectationFailed = 417
    static let imATeapot = 418
    static let misdirectedRequest = 421
    static let unprocessableEntity = 422
    static let locked = 423
    static let failedDependency = 424
    static let tooEarly = 425
    static let upgradeRequired = 426
    static let preconditionRequired = 428
    static let tooManyRequests = 429
    static let requestHeaderFieldsTooLarge = 431
    static let unavailableForLegalReasons = 451

    // MARK: - Это проблема бэка (пятисотые)
    static let internalServerError = 500
    static let notImplemented = 501
    static let badGateway = 502
    static let serviceUnavailable = 503
    static let gatewayTimeout = 504
    static let httpVersionNotSupported = 505
    static let variantAlsoNegotiates = 506
    static let insufficientStorage = 507
    static let loopDetected = 508
    static let notExtended = 510
    static let networkAuthenticationRequired = 511
}

