//
//  InfoView.swift
//  generator
//
//  Created by Матвей on 07.03.2024.
//

import UIKit

final class InfoView: UIView {
    
    private let titleLabel = UILabel(text: "")
    private let infoTextField = InfoTextField()
    private let lineView = UIView()
    private var type: ViewType = .name
    
    var isFailed = false {
        didSet {
            if self.isFailed {
                titleLabel.textColor = .red
                lineView.backgroundColor = .red
                lineView.alpha = 1
                shake()
            } else {
                titleLabel.textColor = .lightGray
                lineView.backgroundColor = .lightGray
                lineView.alpha = 0.2
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTitlelabel()
        configureInfoTextField()
        configureLineView()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ title: String, type: ViewType) {
        self.init()
        self.titleLabel.text = title
        self.type = type
    }
    
    func getText() -> String {
        guard let text = infoTextField.text else { return "" }
        
        return text
    }

}

//MARK: - Delegate

extension InfoView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isFailed = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        infoTextField.resignFirstResponder()
    }
    
}

//MARK: - Setup UI

extension InfoView {
    
    private func configureTitlelabel() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    private func configureInfoTextField() {
        infoTextField.delegate = self
        infoTextField.isUserInteractionEnabled = true 
        infoTextField.autocapitalizationType = .none
        infoTextField.textColor = .white
        infoTextField.tintColor = UIColor(hex: "5E5CDF")
        addSubview(infoTextField)
        NSLayoutConstraint.activate([
            infoTextField.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            infoTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            infoTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            infoTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    private func configureLineView() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .lightGray
        lineView.alpha = 0.2
        
        addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
