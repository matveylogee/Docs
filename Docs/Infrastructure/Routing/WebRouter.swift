//
//  WebRouter.swift
//  generator
//
//  Created by Матвей on 21.03.2025.
//

import UIKit

class WebRouter: WebRouterProtocol {

    func openWebPage(from view: UIViewController?, urlString: String) {
        guard let webURL = URL(string: urlString), let view else { return }

        let safariVC = SFSafariViewController(url: webURL)
        view.present(safariVC, animated: true, completion: nil)
    }
}
