import Cocoa
import SwiftUI
import Carbon


var window: NSWindow!
//var overlayWindow : NSWindow?

let windowHeight : CGFloat = 50
let windowOriginY : CGFloat = 20

//@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSApplication.shared.windows.first
        
        let level = 100
        
//        overlayWindow = NSWindow(
//            contentRect: NSScreen.screens.first!.frame,
//            styleMask: [.fullSizeContentView],
//            backing: .buffered,
//            defer: false
//        )
//        overlayWindow!.level = NSWindow.Level(level - 1)
//        overlayWindow!.collectionBehavior = .stationary
//        overlayWindow!.isMovableByWindowBackground  = false
//        overlayWindow!.backgroundColor = NSColor.init(calibratedWhite: 0, alpha: 0.6)
//        overlayWindow.standardWindowButton(.zoomButton)?.isHidden = true
//        overlayWindow.standardWindowButton(.closeButton)?.isHidden = true
//        overlayWindow.standa  rdWindowButton(.miniaturizeButton)?.isHidden = true

        // TODO: it would be nice to make macOS respect this dock for window maximizing. visibleFrame
//        window.setContentSize(NSSize(width: NSScreen.screens.first!.frame.width, height: windowHeight))
//        window.setFrameOrigin(NSPoint(x: 0, y: windowOriginY))
        window.hasShadow = false
        window.backgroundColor = NSColor.init(calibratedWhite: 0, alpha: 0.8)
        window.setFrame(NSScreen.screens.first!.frame, display: true, animate: false)
        window.level = NSWindow.Level(level)
        window.collectionBehavior = .canJoinAllSpaces

        window.isMovableByWindowBackground  = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.hidesOnDeactivate = true
        window.orderOut(nil)
        
        // on macOS Sonoma this assert crashes...
        //assert(NSApp.windows.count == 1)
       
//        registerHotkey(keyCode: kVK_Tab, id: 0, modifierFlags: getCarbonFlagsFromCocoaFlags(cocoaFlags: .control))
//        registerHotkey(keyCode: kVK_CapsLock, id: 0, modifierFlags: getCarbonFlagsFromCocoaFlags(cocoaFlags: .command))
        registerHotkey(keyCode: kVK_F20, id: 0, modifierFlags: 0)
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
}
