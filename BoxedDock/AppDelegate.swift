import Cocoa
import SwiftUI
import Carbon


var window: NSWindow!
//var overlayWindow : NSWindow?

let windowHeight : CGFloat = 50
let windowOriginY : CGFloat = 20

// Borderless so it covers the menu bar and dock, but it still has to take keyboard input
class DockWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

//@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = DockWindow(
            contentRect: NSScreen.screens.first!.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: ContentView().ignoresSafeArea())
        
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
        // The dimming layer is drawn by ContentView, newer macOS ignores the window background color
        window.isOpaque = false
        window.backgroundColor = .clear
        window.appearance = NSAppearance(named: .darkAqua)
        window.setFrame(NSScreen.screens.first!.frame, display: true, animate: false)
        window.level = NSWindow.Level(level)
        window.collectionBehavior = .canJoinAllSpaces

        window.isMovableByWindowBackground  = false
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
