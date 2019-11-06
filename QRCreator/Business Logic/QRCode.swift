//
//  QRCode.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa
import CoreImage

/// Протокол генератора изображений различных кодировок.
public protocol CodeGeneration {
    
    /// Цвет заднего фона.
    var backgroundColor: NSColor { get set }
    
    /// Цвет QR-фигур.
    var foregroundColor: NSColor { get set }
    
    /// Создает изображение из значения с определенным размером.
    func image(from value: String, with size: NSSize, completion: @escaping (NSImage?) -> Void)
}

/// Уровень стойкости QR-кода к повреждениям.
///
/// Определяет, какой процерт повреждением может получить
/// изображение с QR-кодом и при этом остаться
/// восстанавливаемым.
public enum QRCodeLevel: String {
    
    /// Слабый уровень защиты, выдерживает 7% повреждений.
    case low = "L"
    
    /// Средний уровень защиты, выдерживает 15% повреждений.
    case medium = "M"
    
    /// Хороший уровень защиты, выдерживает 25% повреждений.
    case quartile = "Q"
    
    /// Высокий уровень защиты, выдерживает 30% повреждений.
    case high = "H"
}

public enum Code: Int, RawRepresentable {
    
    case qrCode
    
    case barCode
}

/// Протокол генератора изображений QR-кода.
public protocol QRCodeGeneration: CodeGeneration {
    
    /// Уровень стойкости QR-кода к повреждениям.
    var codeLevel: QRCodeLevel { get set }
}

/// Протокол генератора изображений Bar-кода.
public protocol BarCodeGeneration: CodeGeneration {
}


/// Генератор QR-кода.
final public class QRCode: CodeGenerator, QRCodeGeneration {
    
    /// Уровень стойкости QR-кода к повреждениям.
    public var codeLevel: QRCodeLevel = .medium
    
    /// Генерирует изображение с кодированными данными.
    public override func codeImage(from data: Data, in size: NSSize) -> CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValuesForKeys([
            "inputMessage": data,
            "inputCorrectionLevel": codeLevel.rawValue,
        ])
        
        return filter.outputImage
    }
}

/// Генератор Bar-кода.
final public class BarCode: CodeGenerator, BarCodeGeneration {
    
    /// Генерирует изображение с кодированными данными.
    public override func codeImage(from data: Data, in size: NSSize) -> CIImage? {
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValuesForKeys([
            "inputMessage": data,
        ])
        
        return filter.outputImage
    }
}
