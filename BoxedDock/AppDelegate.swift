import Cocoa
import SwiftUI
import Carbon


var overlayWindow : NSWindow?

//@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    var window2: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSApplication.shared.windows.first
        
        let level = 100
        
        overlayWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height),
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        overlayWindow!.level = NSWindow.Level(level - 1)
        overlayWindow!.collectionBehavior = .stationary
        overlayWindow!.isMovableByWindowBackground  = false
        overlayWindow!.backgroundColor = NSColor.init(calibratedWhite: 0, alpha: 0.6)
//        overlayWindow.standardWindowButton(.zoomButton)?.isHidden = true
//        overlayWindow.standardWindowButton(.closeButton)?.isHidden = true
//        overlayWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true

        // TODO: it would be nice to make macOS respect this dock for window maximizing. visibleFrame
        window.setContentSize(NSSize(width: NSScreen.main!.frame.width, height: 50))
        window.setFrameOrigin(NSPoint(x: 0, y: 20))
        window.hasShadow = false
        window.backgroundColor = .black
        window.level = NSWindow.Level(level)
        window.collectionBehavior = .canJoinAllSpaces

        window.isMovableByWindowBackground  = false
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    
//        registerHotkey(keyCode: kVK_Tab, id: 0, modifierFlags: getCarbonFlagsFromCocoaFlags(cocoaFlags: .control))
//        registerHotkey(keyCode: kVK_CapsLock, id: 0, modifierFlags: getCarbonFlagsFromCocoaFlags(cocoaFlags: .command))
        registerHotkey(keyCode: kVK_F20, id: 0, modifierFlags: 0)
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
}
