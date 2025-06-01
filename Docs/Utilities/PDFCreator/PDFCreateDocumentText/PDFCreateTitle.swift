//
//  PDFCreateTitle.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit
import PDFKit

extension PDFCreator {

    func pdfCreateTitle(originPoint: CGPoint) -> CGPoint {
        // 1) Преобразуем строку в DocumentType, а затем в Int
        guard let docType = DocumentType(rawValue: experience.rawValue),
              let titleTypeOfLeasing = Resources.TitleTypeOfLeasing(rawValue: docType.intValue) else {
            return CGPoint(x: 0, y: 0)
        }

        // 3) Формируем дату
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: Date())

        // 4) Заголовок
        let nameText = addText(
            originPoint: originPoint,
            text: """
                  Лицензионное соглашение
                  (НЕ ЭКСКЛЮЗИВНЫЕ ПРАВА / \
                  \(titleTypeOfLeasing.description) Лицензия)
                  Звукозапись / Биты
                  """,
            type: .bold,
            size: 15,
            color: .black
        )

        // 5) Основной абзац
        let licenceMainDescription = addText(
            originPoint: CGPoint(x: nameText.minX, y: nameText.maxY + 10),
            text: """
                  НАСТОЯЩЕЕ ЛИЦЕНЗИОННОЕ СОГЛАШЕНИЕ заключили \
                  \(dateString) («Дата вступления в силу») \
                  \(name) (далее именуемым «Лицензиат») и между ними, \
                  также, если применимо, профессионально известным как \
                  \(nickname) и \(producerName) \
                  (далее именуемый «Лицензиар»), также, если применимо, \
                  профессионально известный как \(producerName). \
                  Лицензиар гарантирует, что он контролирует права на \
                  механическое воспроизведение музыкальных произведений, \
                  охраняемых авторским правом, под названием \
                  "\(composition)" («Композиция») на дату и до даты, указанной выше. \
                  Композиция, включая музыку к ней, была написана \
                  Бородиным Матвеем («Автор песен») под управлением Лицензиара.
                  """,
            type: .regular,
            size: 10,
            color: .black
        )

        return CGPoint(x: licenceMainDescription.minX,
                       y: licenceMainDescription.maxY)
    }
}
