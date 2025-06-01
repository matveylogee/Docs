//
//  CurrentDate.swift
//  generator
//
//  Created by Матвей on 04.02.2025.
//

import UIKit

protocol CurrentDateProtocol {
    /// Старая версия — только для хранения в БД (дата без времени)
    func pdfCreateData() -> String
    
    /// Новая версия — для хранения в БД и времени
    func pdfCreateTimestamp() -> String
    
    /// Для отображения: принимает строку вида "dd/MM/yy HH:mm"
    /// — если сегодня: "HH:mm"
    /// — если вчера: "Yesterday"
    /// — иначе: "dd/MM/yy"
    func pdfDisplayDate(from dateTimeString: String) -> String
}

final class CurrentDate: CurrentDateProtocol {
    
    // 1) Оставляем «чистую» дату для тех мест, где вы не хотите трогать БД и
    //    уже лежат старые записи в формате "dd/MM/yy"
    public func pdfCreateData() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: Date())
    }
    
    // 2) Новый метод: возвращает и дату, и время
    public func pdfCreateTimestamp() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy HH:mm"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: Date())
    }
    
    // 3) Отображение «человекочитаемой» строки
    public func pdfDisplayDate(from dateTimeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yy HH:mm"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: dateTimeString) else {
            // Если формат строки не тот, что ожидаем — возвращаем как есть
            return dateTimeString
        }
        
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let tf = DateFormatter()
            tf.dateFormat = "HH:mm"
            return tf.string(from: date)
            
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
            
        } else {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yy"
            df.locale = Locale(identifier: "en_US_POSIX")
            return df.string(from: date)
        }
    }
}
