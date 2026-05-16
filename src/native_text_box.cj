package cjform

public class NativeTextBox {
    private let hEdit: CPointer<Byte>
    private var x: Int32
    private var y: Int32
    private var width: Int32
    private var height: Int32
    
    public init(parent: CPointer<Byte>, x: Int32, y: Int32, width: Int32, height: Int32, placeholder: String) {
        this.x = x
        this.y = y
        this.width = width
        this.height = height
        
        let placeholderCStr = unsafe { LibC.mallocCString(placeholder) }
        this.hEdit = unsafe { bridge_edit_create(parent, x, y, width, height, placeholderCStr) }
        unsafe { LibC.free(placeholderCStr) }
    }
    
    public func destroy(): Unit {
        unsafe { bridge_edit_destroy(hEdit) }
    }
    
    public func setText(text: String): Unit {
        let textCStr = unsafe { LibC.mallocCString(text) }
        unsafe { bridge_edit_set_text(hEdit, textCStr) }
        unsafe { LibC.free(textCStr) }
    }
    
    public func getText(): String {
        let buffer = unsafe { LibC.malloc<Byte>(count: 256) }
        unsafe { bridge_edit_get_text(hEdit, buffer, 256) }
        let cStr = unsafe { CString(buffer) }
        let result = cStr.toString()
        unsafe { LibC.free(buffer) }
        result
    }
    
    public func setFocus(): Unit {
        unsafe { bridge_edit_set_focus(hEdit) }
    }
    
    public func setReadonly(readonly: Bool): Unit {
        unsafe { bridge_edit_set_readonly(hEdit, readonly) }
    }
    
    public func selectAll(): Unit {
        unsafe { bridge_edit_select_all(hEdit) }
    }
    
    public func setPosition(x: Int32, y: Int32, width: Int32, height: Int32): Unit {
        this.x = x
        this.y = y
        this.width = width
        this.height = height
        unsafe { bridge_edit_set_pos(hEdit, x, y, width, height) }
    }
    
    public func show(show: Bool): Unit {
        unsafe { bridge_edit_show(hEdit, show) }
    }
    
    public func setBorderColor(r: UInt8, g: UInt8, b: UInt8): Unit {
        unsafe { bridge_edit_set_border_color(hEdit, r, g, b) }
    }
    
    public func setBackgroundColor(r: UInt8, g: UInt8, b: UInt8): Unit {
        unsafe { bridge_edit_set_bg_color(hEdit, r, g, b) }
    }
    
    public func setBorderColor(color: Color): Unit {
        unsafe { bridge_edit_set_border_color(hEdit, color.r, color.g, color.b) }
    }
    
    public func setBackgroundColor(color: Color): Unit {
        unsafe { bridge_edit_set_bg_color(hEdit, color.r, color.g, color.b) }
    }
    
    public func getHandle(): CPointer<Byte> {
        hEdit
    }
    
    public func getX(): Int32 { x }
    public func getY(): Int32 { y }
    public func getWidth(): Int32 { width }
    public func getHeight(): Int32 { height }
}
