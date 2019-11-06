//
//  PreferencesViewController.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

/// Контроллер настроек.
final public class PreferencesViewController: NSViewController, NSTextFieldDelegate {
    
    /// Чекбокс живой генерации.
    @IBOutlet var liveGeneration: NSButton!
    
    /// Качество выходных картинок.
    @IBOutlet var resolution: NSTextField!
    
    /// Радио батонка  белого стиля.
    @IBOutlet var whiteStyle: NSButton!
    
    /// Радио батонка черного стиля.
    @IBOutlet var blackStyle: NSButton!
    
    /// Глобальные настройки приложения.
    private let preferences = Preferences.shared
    
    /// Модуль был загружен.
    public override func viewWillAppear() {
        update()
    }
    
    /// Параметр живой генерации изменен.
    @IBAction func didChangeLiveGeneration(_ sender: NSButton) {
        preferences.isLiveGeneration = sender.state == .on
    }
    
    /// Разрешение изменено.
    public func controlTextDidChange(_ obj: Notification) {
        preferences.resolution = UInt(resolution.integerValue)
    }
    
    /// Выбран белый стиль.
    @IBAction func didChangeWhiteStyle(_ sender: NSButton) {
        blackStyle.state = .off
        preferences.codeStyle = .white
    }
    
    /// Выбран черный стиль.
    @IBAction func didChangeBlackStyle(_ sender: NSButton) {
        whiteStyle.state = .off
        preferences.codeStyle = .black
    }
    
    /// Сбросить настройки.
    @IBAction func onReset(_ sender: Any) {
        preferences.reset()
        update()
    }
    
    /// Обновить параметры.
    private func update() {
        liveGeneration.state = preferences.isLiveGeneration ? .on : .off
        resolution.stringValue = String(preferences.resolution)
        whiteStyle.state = preferences.codeStyle == .white ? .on : .off
        blackStyle.state = preferences.codeStyle == .black ? .on : .off
    }
}
