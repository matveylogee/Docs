//
//  CustomView.swift
//  generator
//
//  Created by Матвей on 04.02.2025.
//

//import UIKit
//
//final class CustomView: UIView {
//    
//    private let label = UILabel()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        configureLabel()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
////MARK: - SetupUI
//extension CustomView {
//    
//    func configureLabel() {
//        label.text = "Статистика"
//        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.tintColor = .black
//        super.addSubview(label)
//        
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
//            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
//            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
//            label.heightAnchor.constraint(equalToConstant: 15)
//        ])
//    }
//}
