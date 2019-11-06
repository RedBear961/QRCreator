//
//  AppDelegate.swift
//  QRCreator
//
//  Created by Георгий Черемных on 04.11.2019.
//  Copyright © 2019 Georgiy Cheremnykh. All rights reserved.
//

import Cocoa

/// Делегат приложения.
@NSApplicationMain
final public class AppDelegate: NSObject, NSApplicationDelegate {

    /// Закрывает приложение,  если закрыто последнее окно.
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
