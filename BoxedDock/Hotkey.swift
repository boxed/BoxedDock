//
//  Hotkey.swift
//  BoxedDock
//
//  Created by Anders Hovmöller on 2022-04-24.
//

import Foundation
import Carbon
import AppKit


extension String {
  /// This converts string to UInt as a fourCharCode
  public var fourCharCodeValue: Int {
    var result: Int = 0
    if let data = self.data(using: String.Encoding.macOSRoman) {
      data.withUnsafeBytes({ (rawBytes) in
        let bytes = rawBytes.bindMemory(to: UInt8.self)
        for i in 0 ..< data.count {
          result = result << 8 + Int(bytes[i])
        }
      })
    }
    return result
  }
}

func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
    let flags = cocoaFlags.rawValue
    var newFlags: Int = 0

    if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
      newFlags |= controlKey
    }

    if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
      newFlags |= cmdKey
    }

    if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
      newFlags |= shiftKey;
    }

    if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
      newFlags |= optionKey
    }

    if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
      newFlags |= alphaLock
    }

    return UInt32(newFlags);
}


func registerHotkey(keyCode: Int, id: Int, modifierFlags: UInt32) {
    var hotKeyRef: EventHotKeyRef?

    var gMyHotKeyID = EventHotKeyID()
    gMyHotKeyID.id = UInt32(id)

    // Not sure what "swat" vs "htk1" do.
    gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)
    // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)

    var eventType = EventTypeSpec()
    eventType.eventClass = OSType(kEventClassKeyboard)
    eventType.eventKind = OSType(kEventHotKeyReleased)

    // Install handler.
    InstallEventHandler(GetApplicationEventTarget(), {
      (nextHanlder, theEvent, userData) -> OSStatus in
        // on macOS Sonoma this assert crashes...
        //assert(NSApp.windows.count == 1)
        
        if window!.isVisible {
            window!.orderOut(nil)
        }
        else {
            contentView!.apps = getRunningApplications()
            window!.setFrame(NSScreen.screens.first!.frame, display: true, animate: false)
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first!.makeKeyAndOrderFront(nil)
            window!.orderFrontRegardless()
        }
        NSLog("Hotkey hit!")
        // on macOS Sonoma this assert crashes...
        //assert(NSApp.windows.count == 1)

        return noErr
    }, 1, &eventType, nil, nil)

    // Register hotkey.
    let status = RegisterEventHotKey(UInt32(keyCode),
                                     modifierFlags,
                                     gMyHotKeyID,
                                     GetApplicationEventTarget(),
                                     0,
                                     &hotKeyRef)
    assert(status == noErr)
  }
