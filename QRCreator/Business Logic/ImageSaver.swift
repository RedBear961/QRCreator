//
//  ImageSaver.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

/// Интерфейс финализатора работы с QR-кодом.
/// Объект, который может сохранять изображения на диск или
/// копировать в буффер обмена.
public protocol ImageSaving {
    
    /// Копирует изображение в буффер обмена.
    func copy(_ image: NSImage)
    
    /// Сохраняет изображение на диск.
    func save(_ image: NSImage) throws
}

/// Сохраняет изображения на диск или в буффер обмена.
final public class ImageSaver: ImageSaving {
    
    /// Ошибка сохранения файла.
    private struct SaveError: ReadableError {
        
        /// Стиль ошибки.
        public let style: NSAlert.Style = .critical
        
        /// Заголовок ошибки.
        public let title: String = "Ошибка сохранения файла"
        
        /// Описание ошибки.
        public let description: String
        
        /// Не удалось получить доступ к домашней директории.
        public static let notOpened = SaveError(
            description: "Не удалось получить доступ к домашней директории."
        )
        
        /// Не удалось получить путь к указанной директории.
        public static let notFound = SaveError(
            description: "Не удалось получить путь к указанной директории."
        )
        
        /// Не удалось сохранить файл по указанному пути, попробуйте другой путь.
        public static let notSaved = SaveError(
            description: "Не удалось сохранить файл по указанному пути, попробуйте другой путь."
        )
    }

    /// Копирует изображение в буффер обмена.
    public func copy(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    /// Сохраняет изображение на диск.
    public func save(_ image: NSImage) throws {
        let savePanel = NSSavePanel()
        savePanel.directoryURL = try documentDirectory()
        savePanel.canCreateDirectories = true
        savePanel.level = .modalPanel
        savePanel.allowedFileTypes = ["png"]
        savePanel.beginSheetModal(for: NSApp.keyWindow!) { (response) in
            if response == .OK {
                self.save(image, to: savePanel.url)
            }
        }
    }
    
    /// Получает домашнюю директорию.
    private func documentDirectory() throws -> URL {
        let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        if url == nil {
            let error = SaveError.notOpened
            show(error)
            throw error
        }
        
        return url!
    }
    
    /// Сохраняет файл на диск.
    private func save(_ image: NSImage, to url: URL?) {
        guard let url = url else {
            show(SaveError.notFound)
            return
        }
        
        DispatchQueue.global().async {
            do {
                try image.tiffRepresentation!.write(to: url)
            } catch {
                show(SaveError.notSaved)
            }
        }
    }
}
