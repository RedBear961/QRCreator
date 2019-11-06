//
//  CodeGenerator.swift
//  QRCreator
//
//  Created by Георгий Черемных on 05.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

open class CodeGenerator: CodeGeneration {
    
    /// Цвет заднего фона.
    public var backgroundColor: NSColor = .clear
    
    /// Цвет QR-фигур.
    public var foregroundColor: NSColor = .white
    
    /// Ассинхронная очередь генератора QR-кода.
    private let queue = DispatchQueue(label: "com.webviewlab.qrcreator.qrcode")
    
    /// Графический контекст отрисовки изображений.
    private let ciContext = CIContext()
    
    /// Создает изображение из значения с определенным размером.
    public func image(
        from value: String,
        with size: NSSize,
        completion: @escaping (NSImage?) -> Void
    ) {
        queue.async {
            guard let data = value.data(using: .utf8) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let qrImage = self.image(from: data, size: size)
            DispatchQueue.main.async {
                completion(qrImage)
            }
        }
    }
    
    /// Генерирует изображение с кодированными данными.
    open func codeImage(from data: Data, in size: NSSize) -> CIImage? {
        return nil
    }
    
    /// Отрисовывает данные в указанном размере.
    private func image(from data: Data, size: NSSize) -> NSImage? {
        guard let image = codeImage(from: data, in: size),
              let filled = fillBackground(for: image) else {
            return nil
        }
        
        return draw(filled, in: size)
    }
    
    /// Заполняет задний фон изображения.
    private func fillBackground(for image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIFalseColor") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValuesForKeys([
            "inputImage": image,
            "inputColor0": foregroundColor.ciColor,
            "inputColor1": backgroundColor.ciColor,
        ])
        return filter.outputImage
    }
    
    /// Рисует `NSImage`.
    private func draw(_ image: CIImage, in size: NSSize) -> NSImage? {
        guard let cgImage = ciContext.createCGImage(image, from: image.extent) else {
            return nil
        }
        
        let output = NSImage(size: size)
        output.lockFocus()
        
        guard let context = NSGraphicsContext.current?.cgContext else { return nil }
        context.interpolationQuality = .none
        context.setShouldAntialias(false)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        
        output.unlockFocus()
        return output
    }
}

fileprivate extension NSColor {
    
    /// Получает `CIColor`.
    var ciColor: CIColor {
        return CIColor(cgColor: cgColor)
    }
}
