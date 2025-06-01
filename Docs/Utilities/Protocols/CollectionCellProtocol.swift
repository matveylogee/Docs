//
//  CollectionCellProtocol.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import Foundation

protocol CollectionCellProtocol {
    static var reuseID: String { get }
    func setupCell(item: CollectionItem)
    func setConstraints()
}
