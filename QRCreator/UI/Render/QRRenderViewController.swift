//
//  ViewController.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

/// Интерфейс отображения модуля отрисовки QR-кода.
public protocol QRRenderView: AnyObject {
    
    /// Текущий размер превью.
    var previewSize: NSSize { get }
    
    /// Текущий текст.
    var text: String { get }
    
    /// Текуущая доступность действий.
    var currentAccessibility: Bool { get }
    
    /// Обновляет превью QR.
    func update(with image: NSImage?)
    
    /// Меняет доступность кнопок действия.
    func changeAccessibility(to state: Bool)
    
    /// Меняет видимость превью  текста.
    func setShowPreviewText(_ flag: Bool)
}

/// Контроллер отрисовки QR-кода.
final public class QRRenderViewController: NSViewController, QRRenderView, NSTextFieldDelegate {
    
    /// Текстовое поле ввода данных для кодирования.
    @IBOutlet private var textField: NSTextField!
    
    /// Превью кодированных данных.
    @IBOutlet private var preview: NSImageView!
    
    /// Текст о превью.
    @IBOutlet private var previewText: NSView!
    
    /// Кнопка сохранения картинки.
    @IBOutlet private var saveButton: NSButton!
    
    /// Кнопка копирования картинки в буфер обмена.
    @IBOutlet private var copyButton: NSButton!
    
    /// Кнопка перехода в настройки.
    @IBOutlet private var settingsButton: NSButton!
    
    /// Презентер модуля.
    private lazy var presenter: QRRenderPresentable = {
        let p = QRRenderPresenter()
        p.controller = self
        return p
    }()
    
    /// Размер превью QR-кода.
    public var previewSize: NSSize {
        return preview.frame.size
    }
    
    /// Текущий текст.
    public var text: String {
        return textField.stringValue
    }
    
    /// Текуущая доступность действий.
    public var currentAccessibility: Bool {
        return copyButton.isEnabled
    }
    
    /// Модуль будет отображен.
    public override func viewWillAppear() {
        presenter.viewWillAppear()
    }
    
    // MARK: - NSTextFieldDelegate
    
    /// Входные данные были изменены.
    public func controlTextDidChange(_ obj: Notification) {
        presenter.textDidChange(textField.stringValue)
    }
    
    // MARK: - QRRenderView
    
    /// Обновляет отображение.
    public func update(with image: NSImage?) {
        preview.image = image
    }
    
    /// Меняет доступность кнопок действия.
    public func changeAccessibility(to state: Bool) {
        guard state != currentAccessibility else { return }
        saveButton.isEnabled = state
        copyButton.isEnabled = state
        previewText.isHidden = state
    }
    
    /// Меняет видимость превью  текста.
    public func setShowPreviewText(_ flag: Bool) {
        previewText.isHidden = !flag
    }
    
    // MARK: - IBAction
    
    /// Пользователь хочет сохранить картинку.
    @IBAction func onSave(_ sender: NSButton) {
        presenter.onSave()
    }
    
    /// Пользователь хочет скопировать изображение в буфер обмена.
    @IBAction func onCopy(_ sender: NSButton) {
        presenter.onCopy()
    }
    
    /// Пользователь сменил код.
    @IBAction func onSelectCode(_ sender: NSSegmentedControl) {
        presenter.didSelectCode(at: sender.selectedSegment)
    }
}
