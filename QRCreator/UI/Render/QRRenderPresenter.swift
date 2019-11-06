//
//  QRRenderPresenter.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

/// Интерфейс презентера модуля отрисовки QR-кода.
public protocol QRRenderPresentable {
    
    /// Модуль будет отображен.
    func viewWillAppear()
    
    /// Входные данные были изменены.
    func textDidChange(_ text: String)
    
    /// Сохранить изображение.
    func onSave()
    
    /// Копировать изображение в буффер обмена.
    func onCopy()
    
    /// Выбран другой код.
    func didSelectCode(at raw: Int)
}

final public class QRRenderPresenter: QRRenderPresentable, PreferencesSubscriber {
    
    /// Контроллер модуля.
    public weak var controller: QRRenderView!
    
    /// Генератор изображений QR-кода.
    private var qrCode: QRCodeGeneration = QRCode()
    
    /// Генератор изображений Bar-кода.
    private var barCode: BarCodeGeneration = BarCode()
    
    /// Сервис сохранения картинок.
    private var imageSaver: ImageSaving = ImageSaver()
    
    /// Глобальные настройки приложения.
    private let preferences = Preferences.shared
    
    /// Текущий тип кода.
    private var code: Code = .qrCode
    
    /// Текущее  изображение.
    private var image: NSImage?
    
    /// Основной конструктор.
    public init() {
        preferences.subscribe(self)
    }
    
    /// Деаллоцирует класс.
    deinit {
        preferences.unsubscribe(self)
    }
    
    /// Модуль будет отображен.
    public func viewWillAppear() {
        updateColor(for: codeGenerator())
        controller.changeAccessibility(to: false)
        controller.setShowPreviewText(true)
    }
    
    /// Входные данные были изменены.
    public func textDidChange(_ text: String) {
        let state = !text.isEmpty
        controller.changeAccessibility(to: state)
        update(with: text)
    }
    
    /// Сохраняет изображение на диск.
    public func onSave() {
        let width = Int(preferences.resolution)
        let size = CGSize(width: width, height: width)
        codeGenerator().image(from: controller.text, with: size) { (image) in
            guard let image = image else {
                return
            }
            try? self.imageSaver.save(image)
        }
    }
    
    /// Копировать изображение в буффер обмена.
    public func onCopy() {
        let width = Int(preferences.resolution)
        let size = CGSize(width: width, height: width)
        codeGenerator().image(from: controller.text, with: size) { (image) in
            guard let image = image else {
                return
            }
            self.imageSaver.copy(image)
        }
    }
    
    /// Выбран другой код.
    public func didSelectCode(at raw: Int) {
        guard let selectedCode = Code(rawValue: raw) else {
            fatalError("Не удалось выбрать код для значения: \(raw)")
        }
        code = selectedCode
        let text = controller.text
        update(with: text)
    }
    
    /// Были изменены настройки.
    public func parameterDidChange(_ parameter: Preferences.Parameter, with newValue: Any?) {
        switch parameter {
            case .codeStyle,
                 .liveGeneration:
                let text = controller.text
                update(with: text)
            
            default:
                break
        }
    }
    
    /// Обновляет внешний вид контроллера.
    private func update(with text: String) {
        if text.isEmpty || !preferences.isLiveGeneration {
            controller.setShowPreviewText(true)
            controller.update(with: nil)
            return
        }
        
        let generator = codeGenerator()
        updateColor(for: generator)
        generator.image(from: text, with: controller.previewSize) { (image) in
            self.image = image
            self.controller?.update(with: image)
            self.controller.setShowPreviewText(false)
        }
    }
    
    /// Обновляет цвет QR-превью.
    private func updateColor(for generator: CodeGeneration) {
        var generator = generator
        let isWhite = preferences.codeStyle == .white
        let color: NSColor = isWhite ? .white : .black
        generator.foregroundColor = color
    }
    
    /// Находит текущий генератор кода.
    private func codeGenerator() -> CodeGeneration {
        switch code {
            case .qrCode:
                return qrCode
            
            case .barCode:
                return barCode
        }
    }
}
