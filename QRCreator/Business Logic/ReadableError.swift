//
//  ReadableError.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

/// Абстрактный тип читаемой пользователем ошибки.
public protocol ReadableError: Error {
    
    /// Стиль ошибки, который будет применен в алерте.
    var style: NSAlert.Style { get }
    
    /// Заголовок ошибки.
    var title: String { get }
    
    /// Описание ошибки.
    var description: String { get }
}

public extension NSAlert {
    
    /// Создает алерт из читаемой человеком ошибки.
    convenience init(to error: ReadableError) {
        self.init()
        self.messageText = error.title
        self.informativeText = error.description
        self.alertStyle = error.style
    }
}

/// Выводит пользователю ошибку.
public func show(_ error: ReadableError) {
    let alert = NSAlert(to: error)
    alert.runModal()
}
