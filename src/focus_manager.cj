package cjform

import std.collection.*

public class FocusManager {
    private static var instance: Option<FocusManager> = None<FocusManager>
    
    private var focusables: ArrayList<TextBox>
    private var currentFocusIndex: Int32
    
    private init() {
        this.focusables = ArrayList<TextBox>()
        this.currentFocusIndex = -1
    }
    
    public static func getInstance(): FocusManager {
        match (instance) {
            case Some(fm) => fm
            case None =>
                let fm = FocusManager()
                instance = Some<FocusManager>(fm)
                fm
        }
    }
    
    public func register(textBox: TextBox): Unit {
        focusables.add(textBox)
    }
    
    public func clearFocus(): Unit {
        for (f in focusables) {
            f.setFocus(false)
        }
        currentFocusIndex = -1
    }
    
    public func setFocus(textBox: TextBox): Unit {
        clearFocus()
        textBox.setFocus(true)
        
        for (i in 0..focusables.size) {
            if (focusables[Int64(i)].getTabIndex() == textBox.getTabIndex()) {
                currentFocusIndex = Int32(i)
                break
            }
        }
    }
    
    public func focusNext(): Unit {
        if (focusables.size == 0) {
            return
        }
        
        clearFocus()
        
        if (currentFocusIndex < 0 || currentFocusIndex >= Int32(focusables.size) - 1) {
            currentFocusIndex = 0
        } else {
            currentFocusIndex = currentFocusIndex + 1
        }
        
        let next = focusables[Int64(currentFocusIndex)]
        next.setFocus(true)
    }
    
    public func focusPrevious(): Unit {
        if (focusables.size == 0) {
            return
        }
        
        clearFocus()
        
        if (currentFocusIndex <= 0) {
            currentFocusIndex = Int32(focusables.size) - 1
        } else {
            currentFocusIndex = currentFocusIndex - 1
        }
        
        let prev = focusables[Int64(currentFocusIndex)]
        prev.setFocus(true)
    }
    
    public func getFocusedIndex(): Int32 {
        currentFocusIndex
    }
    
    public func hasFocusedWidget(): Bool {
        currentFocusIndex >= 0
    }
}
