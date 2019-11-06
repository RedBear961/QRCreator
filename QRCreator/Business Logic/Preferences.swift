//
//  Preferences.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Foundation

/// Подписчик на события изменения настроек.
public protocol PreferencesSubscriber: AnyObject {
    
    /// Был изменен параметр.
    func parameterDidChange(_ parameter: Preferences.Parameter, with newValue: Any?)
}

/// Глобальные настройки приложения.
final public class Preferences {
    
    /// Экземпляр настроек.
    public static let shared = Preferences()
    
    /// Перечисление настроек приложения.
    public enum Parameter {
        
        /// Настройка живой генерации QR-кода.
        case liveGeneration
        
        /// Качество выходных картинок.
        case resolution
        
        /// Стиль представления QR.
        case codeStyle
        
        /// Уровень стойкости QR-кода к повреждениям.
        case qrCodeLevel
    }
    
    /// Стиль представления QR.
    public enum CodeStyle: UInt, RawRepresentable {
        
        /// Белый стиль.
        case white
        
        /// Черный стиль.
        case black
    }
    
    /// Подписчики на события.
    private var subscribers = NSHashTable<AnyObject>.weakObjects()
    
    
    // MARK: - Настройки приложения
    
    /// Показатель живой генерации QR-кода.
    @UserDefaults(key: "isLiveGeneration", default: true)
    public var isLiveGeneration: Bool {
        didSet {
            notify(about: .liveGeneration, with: isLiveGeneration)
        }
    }
    
    /// Качество выходных картинок.
    @UserDefaults(key: "resolution", default: 200)
    public var resolution: UInt {
        didSet {
            notify(about: .resolution, with: resolution)
        }
    }
    
    /// Качество выходных картинок.
    @UserDefaultsRawSet(key: "codeStyle", default: .white)
    public var codeStyle: CodeStyle {
        didSet {
            notify(about: .codeStyle, with: codeStyle)
        }
    }
    
    /// Уровень стойкости QR-кода к повреждениям.
    @UserDefaultsRawSet(key: "qrCodeLevel", default: .medium)
    public var qrCodeLevel: QRCodeLevel {
        didSet {
            notify(about: .qrCodeLevel, with: qrCodeLevel)
        }
    }
    
    
    // MARK: - Public
    
    /// Подписывает объект на события изменения параметров.
    public func subscribe(_ object: PreferencesSubscriber) {
        subscribers.add(object)
    }
    
    /// Отписывает объект  от рассылки.
    public func unsubscribe(_ object: PreferencesSubscriber) {
        subscribers.remove(object)
    }
    
    /// Сбрасывает настройки.
    public func reset() {
        isLiveGeneration = _isLiveGeneration.defaultValue
        resolution = _resolution.defaultValue
        codeStyle = _codeStyle.defaultValue
        qrCodeLevel = _qrCodeLevel.defaultValue
    }
    
    
    // MARK: - Private
    
    /// Оповещает подписчиков об изменении параметра.
    private func notify(about param: Parameter, with newValue: Any?) {
        subscribers.allObjects.forEach {
            let subscriber = $0 as! PreferencesSubscriber
            subscriber.parameterDidChange(param, with: newValue)
        }
    }
}
