#include <windows.h>
#include <gdiplus.h>
#include <dwmapi.h>
#include <shobjidl.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

#pragma comment(lib, "gdiplus.lib")
#pragma comment(lib, "dwmapi.lib")

using namespace Gdiplus;

extern "C" {

static ULONG_PTR         g_gdiplusToken;
static GdiplusStartupInput g_gdiplusInput;

typedef void (*RenderCallback)(void* ctx, int width, int height);

typedef struct {
    HWND hwnd;
    HDC   hdc;
    HDC   memDC;
    HBITMAP memBitmap;
    HBITMAP oldBitmap;
    int   width, height;
    RenderCallback renderCallback;
    void* renderContext;
    bool  needsRender;
    int  mouseX, mouseY, mouseButton, mouseEventType;
    bool hasMouseEvent;
    unsigned int keyCode;
    int  keyEventType;
    bool hasKeyEvent;
    bool ctrlDown, shiftDown, altDown;
    wchar_t keyChar;
    bool  hasClipRect;
    float clipX, clipY, clipW, clipH;
    int  mouseWheelDelta;
    bool hasMouseWheelEvent;
    int  mouseWheelX, mouseWheelY;
    int  minWidth, minHeight;
    bool isResizable;
    bool isAlwaysOnTop;
    bool isNoTitleBar;
    bool hasDropEvent;
    wchar_t* dropFileList;
    int  dropFileCount;
} WindowContext;

static wchar_t* utf8_to_utf16(const char* utf8_str) {
    if (!utf8_str) return NULL;
    int len = MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, NULL, 0);
    if (len == 0) return NULL;
    wchar_t* w = (wchar_t*)malloc(len * sizeof(wchar_t));
    if (!w) return NULL;
    if (MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, w, len) == 0) {
        free(w); return NULL;
    }
    return w;
}

static char* utf16_to_utf8(const wchar_t* wstr) {
    if (!wstr) return NULL;
    int len = WideCharToMultiByte(CP_UTF8, 0, wstr, -1, NULL, 0, NULL, NULL);
    if (len == 0) return NULL;
    char* s = (char*)malloc(len);
    if (!s) return NULL;
    WideCharToMultiByte(CP_UTF8, 0, wstr, -1, s, len, NULL, NULL);
    return s;
}

static void applyClipIfNeeded(Graphics* g, WindowContext* ctx) {
    if (ctx && ctx->hasClipRect)
        g->SetClip(RectF(ctx->clipX, ctx->clipY, ctx->clipW, ctx->clipH));
}

static void setupHighQualityGraphics(Graphics* graphics) {
    graphics->SetSmoothingMode(SmoothingModeNone);
    graphics->SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    graphics->SetCompositingQuality(CompositingQualityDefault);
    graphics->SetInterpolationMode(InterpolationModeNearestNeighbor);
}

static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    switch (uMsg) {
        case WM_DESTROY:
            if (ctx) {
                KillTimer(hwnd, 1);
                if (ctx->dropFileList) free(ctx->dropFileList);
                if (ctx->memBitmap) {
                    SelectObject(ctx->memDC, ctx->oldBitmap);
                    DeleteObject(ctx->memBitmap);
                }
                if (ctx->memDC) DeleteDC(ctx->memDC);
                if (ctx->hdc)   ReleaseDC(hwnd, ctx->hdc);
                free(ctx);
            }
            RemovePropW(hwnd, L"CjFormCtx");
            PostQuitMessage(0);
            return 0;
        case WM_CLOSE:
            DestroyWindow(hwnd); return 0;
        case WM_SIZE:
            if (ctx) {
                ctx->width  = LOWORD(lParam);
                ctx->height = HIWORD(lParam);
                if (ctx->memBitmap) {
                    SelectObject(ctx->memDC, ctx->oldBitmap);
                    DeleteObject(ctx->memBitmap);
                }
                ctx->memBitmap = CreateCompatibleBitmap(ctx->hdc, ctx->width, ctx->height);
                ctx->oldBitmap  = (HBITMAP)SelectObject(ctx->memDC, ctx->memBitmap);
                ctx->needsRender = true;
            }
            InvalidateRect(hwnd, NULL, FALSE);
            return 0;
        case WM_PAINT: {
            PAINTSTRUCT ps;
            BeginPaint(hwnd, &ps);
            if (ctx)
                BitBlt(ctx->hdc, 0, 0, ctx->width, ctx->height, ctx->memDC, 0, 0, SRCCOPY);
            EndPaint(hwnd, &ps);
            return 0;
        }
        case WM_ERASEBKGND: return 1;
        case WM_TIMER:
            if (ctx) ctx->needsRender = true; return 0;
        case WM_MOUSEMOVE:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 0; ctx->mouseEventType = 1; ctx->hasMouseEvent = true; } return 0;
        case WM_LBUTTONDOWN:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 1; ctx->mouseEventType = 2; ctx->hasMouseEvent = true; } return 0;
        case WM_LBUTTONUP:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 1; ctx->mouseEventType = 3; ctx->hasMouseEvent = true; } return 0;
        case WM_RBUTTONDOWN:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 2; ctx->mouseEventType = 2; ctx->hasMouseEvent = true; } return 0;
        case WM_RBUTTONUP:
            if (ctx) { ctx->mouseX = LOWORD(lParam); ctx->mouseY = HIWORD(lParam);
                ctx->mouseButton = 2; ctx->mouseEventType = 3; ctx->hasMouseEvent = true; } return 0;
        case WM_KEYDOWN:
            if (ctx) { ctx->keyCode = (unsigned int)wParam; ctx->keyEventType = 1;
                ctx->ctrlDown = (GetKeyState(VK_CONTROL)&0x8000)!=0;
                ctx->shiftDown = (GetKeyState(VK_SHIFT)&0x8000)!=0;
                ctx->altDown = (GetKeyState(VK_MENU)&0x8000)!=0; ctx->hasKeyEvent = true; } return 0;
        case WM_CHAR:
            if (ctx) { ctx->keyChar = (wchar_t)wParam; ctx->keyEventType = 2;
                ctx->ctrlDown = (GetKeyState(VK_CONTROL)&0x8000)!=0;
                ctx->shiftDown = (GetKeyState(VK_SHIFT)&0x8000)!=0;
                ctx->altDown = (GetKeyState(VK_MENU)&0x8000)!=0; ctx->hasKeyEvent = true; } return 0;
        case WM_MOUSEWHEEL:
            if (ctx) {
                POINT pt = { LOWORD(lParam), HIWORD(lParam) };
                ScreenToClient(hwnd, &pt);
                ctx->mouseWheelX = pt.x;
                ctx->mouseWheelY = pt.y;
                ctx->mouseWheelDelta = GET_WHEEL_DELTA_WPARAM(wParam);
                ctx->hasMouseWheelEvent = true;
            }
            return 0;
        case WM_GETMINMAXINFO:
            if (ctx && (ctx->minWidth > 0 || ctx->minHeight > 0)) {
                MINMAXINFO* mmi = (MINMAXINFO*)lParam;
                if (ctx->minWidth > 0)  mmi->ptMinTrackSize.x = ctx->minWidth;
                if (ctx->minHeight > 0) mmi->ptMinTrackSize.y = ctx->minHeight;
            }
            return 0;
        case WM_DROPFILES:
            if (ctx) {
                HDROP hDrop = (HDROP)wParam;
                ctx->dropFileCount = DragQueryFileW(hDrop, 0xFFFFFFFF, NULL, 0);
                if (ctx->dropFileCount > 0) {
                    size_t totalLen = 0;
                    for (int i = 0; i < ctx->dropFileCount; i++) {
                        totalLen += DragQueryFileW(hDrop, i, NULL, 0) + 1;
                    }
                    ctx->dropFileList = (wchar_t*)malloc((totalLen + 1) * sizeof(wchar_t));
                    if (ctx->dropFileList) {
                        wchar_t* ptr = ctx->dropFileList;
                        for (int i = 0; i < ctx->dropFileCount; i++) {
                            int len = DragQueryFileW(hDrop, i, ptr, totalLen - (ptr - ctx->dropFileList));
                            ptr += len + 1;
                        }
                        *ptr = L'\0';
                    }
                }
                DragFinish(hDrop);
                ctx->hasDropEvent = true;
            }
            return 0;
    }
    return DefWindowProcW(hwnd, uMsg, wParam, lParam);
}

__declspec(dllexport) void* bridge_gdip_init() {
    GdiplusStartup(&g_gdiplusToken, &g_gdiplusInput, NULL);
    return (void*)g_gdiplusToken;
}
__declspec(dllexport) void bridge_gdip_cleanup() {
    GdiplusShutdown(g_gdiplusToken);
}

__declspec(dllexport) HWND bridge_window_create(const char* title, int width, int height,
    bool resizable, bool alwaysOnTop, bool noTitleBar) {
    static bool registered = false;
    if (!registered) {
        WNDCLASSEXW wc = {0};
        wc.cbSize = sizeof(WNDCLASSEXW);
        wc.style = CS_HREDRAW | CS_VREDRAW;
        wc.lpfnWndProc = WindowProc;
        wc.hInstance = GetModuleHandleW(NULL);
        wc.hCursor = LoadCursor(NULL, IDC_ARROW);
        wc.hbrBackground = NULL;
        wc.lpszClassName = L"CjFormWindow";
        if (!RegisterClassExW(&wc)) return NULL;
        registered = true;
    }
    wchar_t* tw = utf8_to_utf16(title);
    if (!tw) tw = (wchar_t*)L"CjForm Window";

    DWORD dwStyle = noTitleBar ? (WS_POPUP | WS_BORDER) : WS_OVERLAPPEDWINDOW;
    if (!resizable && !noTitleBar) {
        dwStyle &= ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
    }
    DWORD dwExStyle = WS_EX_ACCEPTFILES;
    if (alwaysOnTop) dwExStyle |= WS_EX_TOPMOST;

    HWND hwnd = CreateWindowExW(dwExStyle, L"CjFormWindow", tw,
        dwStyle, CW_USEDEFAULT, CW_USEDEFAULT,
        width, height, NULL, NULL, GetModuleHandleW(NULL), NULL);
    if (tw != L"CjForm Window") free(tw);
    if (!hwnd) return NULL;
    DragAcceptFiles(hwnd, TRUE);

    WindowContext* ctx = (WindowContext*)calloc(1, sizeof(WindowContext));
    ctx->hwnd = hwnd;
    ctx->hdc  = GetDC(hwnd);
    ctx->memDC = CreateCompatibleDC(ctx->hdc);
    RECT r; GetClientRect(hwnd, &r);
    ctx->width  = r.right - r.left; if (ctx->width <=0) ctx->width=width;
    ctx->height = r.bottom - r.top; if (ctx->height<=0) ctx->height=height;
    ctx->memBitmap = CreateCompatibleBitmap(ctx->hdc, ctx->width, ctx->height);
    ctx->oldBitmap = (HBITMAP)SelectObject(ctx->memDC, ctx->memBitmap);
    ctx->isResizable = resizable;
    ctx->isAlwaysOnTop = alwaysOnTop;
    ctx->isNoTitleBar = noTitleBar;
    SetPropW(hwnd, L"CjFormCtx", (HANDLE)ctx);
    return hwnd;
}

__declspec(dllexport) void bridge_window_set_render_callback(HWND hwnd, RenderCallback cb, void* c) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->renderCallback = cb; ctx->renderContext = c; }
}
__declspec(dllexport) void bridge_window_show(HWND hwnd) {
    if (hwnd) { ShowWindow(hwnd, SW_SHOW); UpdateWindow(hwnd); }
}
__declspec(dllexport) void bridge_window_close(HWND hwnd) { if (hwnd) CloseWindow(hwnd); }
__declspec(dllexport) int bridge_run_loop() {
    MSG msg; while (GetMessageW(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg); DispatchMessageW(&msg); }
    return (int)msg.wParam;
}
__declspec(dllexport) int bridge_process_message() {
    MSG msg;
    if (GetMessageW(&msg, NULL, 0, 0)) { TranslateMessage(&msg); DispatchMessageW(&msg); return 1; }
    return 0;
}
__declspec(dllexport) void bridge_post_quit() { PostQuitMessage(0); }
__declspec(dllexport) long long bridge_get_tick_count() { return (long long)GetTickCount64(); }
__declspec(dllexport) void bridge_start_blink_timer(HWND hwnd, int ms) { if (hwnd) SetTimer(hwnd, 1, ms, NULL); }
__declspec(dllexport) void bridge_stop_blink_timer(HWND hwnd) { if (hwnd) KillTimer(hwnd, 1); }

__declspec(dllexport) void bridge_window_set_dark_mode(HWND hwnd, bool dark) {
    BOOL value = dark ? TRUE : FALSE;
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &value, sizeof(value));
}

__declspec(dllexport) void bridge_start_animation_timer(HWND hwnd) {
    if (hwnd) SetTimer(hwnd, 2, 16, NULL);
}

__declspec(dllexport) void bridge_stop_animation_timer(HWND hwnd) {
    if (hwnd) KillTimer(hwnd, 2);
}

__declspec(dllexport) void bridge_gdip_push_clip(HWND hwnd, float x, float y, float w, float h) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->hasClipRect = true; ctx->clipX = x; ctx->clipY = y; ctx->clipW = w; ctx->clipH = h; }
}
__declspec(dllexport) void bridge_gdip_pop_clip(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) ctx->hasClipRect = false;
}
__declspec(dllexport) void bridge_gdip_fill_rect(HWND hwnd, float x, float y, float w, float h,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        SolidBrush br(Color(a, r, g, b));
        graphics.FillRectangle(&br, x, y, w, h);
    }
}
__declspec(dllexport) void bridge_gdip_draw_text(HWND hwnd, float x, float y, const char* text,
    const char* font_family, float font_size,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC && text) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        wchar_t* tw = utf8_to_utf16(text);
        wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
        if (tw) {
            FontFamily ff(fw ? fw : L"Microsoft YaHei");
            Font f(&ff, font_size, FontStyleRegular, UnitPixel);
            SolidBrush br(Color(a, r, g, b));
            StringFormat fmt(StringFormat::GenericTypographic());
            fmt.SetAlignment(StringAlignmentNear);
            fmt.SetLineAlignment(StringAlignmentNear);
            graphics.DrawString(tw, -1, &f, PointF(x, y), &fmt, &br);
            free(tw); if (fw) free(fw);
        }
    }
}
__declspec(dllexport) void bridge_gdip_draw_shadow(HWND hwnd, float x, float y, float w, float h,
    float radius, float blur_radius, float offset_x, float offset_y,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        graphics.SetSmoothingMode(SmoothingModeAntiAlias);
        graphics.SetCompositingQuality(CompositingQualityHighQuality);
        int layers = 5;
        float as = (float)a / (float)(layers * layers);
        for (int i = layers; i > 0; i--) {
            float expand = blur_radius * (float)i / (float)layers;
            float alpha  = as * i;
            SolidBrush br(Color((unsigned char)alpha, r, g, b));
            if (radius > 0.0f) {
                GraphicsPath path;
                float d = radius * 2.0f; if (d > w) d = w; if (d > h) d = h;
                float sx = x + offset_x - expand, sy = y + offset_y - expand;
                float sw = w + expand * 2.0f, sh = h + expand * 2.0f;
                path.AddArc(sx, sy, d, d, 180.0f, 90.0f);
                path.AddArc(sx + sw - d, sy, d, d, 270.0f, 90.0f);
                path.AddArc(sx + sw - d, sy + sh - d, d, d, 0.0f, 90.0f);
                path.AddArc(sx, sy + sh - d, d, d, 90.0f, 90.0f);
                path.CloseFigure();
                graphics.FillPath(&br, &path);
            } else {
                graphics.FillRectangle(&br, x + offset_x - expand, y + offset_y - expand,
                    w + expand * 2.0f, h + expand * 2.0f);
            }
        }
    }
}
__declspec(dllexport) void bridge_gdip_measure_text(HWND hwnd, const char* text,
    const char* font_family, float font_size,
    float* out_width, float* out_height) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC && text) {
        Graphics graphics(ctx->memDC);
        graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
        wchar_t* tw = utf8_to_utf16(text);
        if (tw) {
            wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
            FontFamily ff(fw ? fw : L"Microsoft YaHei");
            Font f(&ff, font_size, FontStyleRegular, UnitPixel);
            StringFormat fmt(StringFormat::GenericTypographic());
            RectF br; graphics.MeasureString(tw, -1, &f, PointF(0, 0), &fmt, &br);
            *out_width = br.Width; *out_height = br.Height;
            if (fw) free(fw); free(tw);
        }
    } else { *out_width = 0; *out_height = 0; }
}
__declspec(dllexport) void bridge_gdip_clear(HWND hwnd,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) { Graphics graphics(ctx->memDC); graphics.Clear(Color(a, r, g, b)); }
}
__declspec(dllexport) void bridge_gdip_fill_rounded_rect(HWND hwnd, float x, float y, float w, float h,
    float radius, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        if (radius > 0.0f) {
            GraphicsPath path; float d = radius * 2.0f;
            path.AddArc(x, y, d, d, 180.0f, 90.0f);
            path.AddArc(x + w - d, y, d, d, 270.0f, 90.0f);
            path.AddArc(x + w - d, y + h - d, d, d, 0.0f, 90.0f);
            path.AddArc(x, y + h - d, d, d, 90.0f, 90.0f);
            path.CloseFigure();
            SolidBrush br(Color(a, r, g, b)); graphics.FillPath(&br, &path);
        } else {
            SolidBrush br(Color(a, r, g, b)); graphics.FillRectangle(&br, x, y, w, h);
        }
    }
}
__declspec(dllexport) void bridge_gdip_draw_rounded_rect(HWND hwnd, float x, float y, float w, float h,
    float radius, float border_width, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        Pen pen(Color(a, r, g, b), border_width); pen.SetAlignment(PenAlignmentInset);
        if (radius > 0.0f) {
            GraphicsPath path; float d = radius * 2.0f;
            if (d > w) d = w; if (d > h) d = h;
            path.AddArc(x, y, d, d, 180.0f, 90.0f);
            path.AddArc(x + w - d, y, d, d, 270.0f, 90.0f);
            path.AddArc(x + w - d, y + h - d, d, d, 0.0f, 90.0f);
            path.AddArc(x, y + h - d, d, d, 90.0f, 90.0f);
            path.CloseFigure();
            graphics.DrawPath(&pen, &path);
        } else {
            graphics.DrawRectangle(&pen, x, y, w, h);
        }
    }
}
__declspec(dllexport) void bridge_gdip_draw_text_aligned(HWND hwnd, float x, float y, float w, float h,
    const char* text, const char* font_family, float font_size, int alignment,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC && text) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        wchar_t* tw = utf8_to_utf16(text);
        wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
        if (tw) {
            FontFamily ff(fw ? fw : L"Microsoft YaHei");
            Font f(&ff, font_size, FontStyleRegular, UnitPixel);
            SolidBrush br(Color(a, r, g, b));
            StringFormat fmt(StringFormat::GenericTypographic());
            if (alignment == 0) fmt.SetAlignment(StringAlignmentNear);
            else if (alignment == 1) fmt.SetAlignment(StringAlignmentCenter);
            else fmt.SetAlignment(StringAlignmentFar);
            fmt.SetLineAlignment(StringAlignmentCenter);
            RectF lr(x, y, w, h);
            graphics.DrawString(tw, -1, &f, lr, &fmt, &br);
            free(tw); if (fw) free(fw);
        }
    }
}
__declspec(dllexport) bool bridge_window_needs_render(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->needsRender : false;
}
__declspec(dllexport) void bridge_window_clear_needs_render(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) ctx->needsRender = false;
}
__declspec(dllexport) void bridge_window_present(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { BitBlt(ctx->hdc, 0, 0, ctx->width, ctx->height, ctx->memDC, 0, 0, SRCCOPY);
               InvalidateRect(hwnd, NULL, FALSE); }
}
__declspec(dllexport) int bridge_window_get_width(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->width : 0;
}
__declspec(dllexport) int bridge_window_get_height(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->height : 0;
}
__declspec(dllexport) bool bridge_window_has_mouse_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->hasMouseEvent : false;
}
__declspec(dllexport) int bridge_window_get_mouse_x(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseX : 0;
}
__declspec(dllexport) int bridge_window_get_mouse_y(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseY : 0;
}
__declspec(dllexport) int bridge_window_get_mouse_button(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseButton : 0;
}
__declspec(dllexport) int bridge_window_get_mouse_event_type(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->mouseEventType : 0;
}
__declspec(dllexport) void bridge_window_clear_mouse_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); if (ctx) ctx->hasMouseEvent = false;
}
__declspec(dllexport) bool bridge_window_has_key_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->hasKeyEvent : false;
}
__declspec(dllexport) unsigned int bridge_window_get_key_code(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->keyCode : 0;
}
__declspec(dllexport) int bridge_window_get_key_event_type(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->keyEventType : 0;
}
__declspec(dllexport) wchar_t bridge_window_get_key_char(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->keyChar : 0;
}
__declspec(dllexport) bool bridge_window_get_ctrl_down(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->ctrlDown : false;
}
__declspec(dllexport) bool bridge_window_get_shift_down(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->shiftDown : false;
}
__declspec(dllexport) bool bridge_window_get_alt_down(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx"); return ctx ? ctx->altDown : false;
}
__declspec(dllexport) void bridge_window_clear_key_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->hasKeyEvent = false; ctx->keyChar = 0; }
}
__declspec(dllexport) void bridge_gdip_draw_line(HWND hwnd, float x1, float y1, float x2, float y2,
    float line_width, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx && ctx->memDC) {
        Graphics graphics(ctx->memDC); applyClipIfNeeded(&graphics, ctx);
        setupHighQualityGraphics(&graphics);
        Pen pen(Color(a, r, g, b), line_width); graphics.DrawLine(&pen, x1, y1, x2, y2);
    }
}

__declspec(dllexport) float bridge_gdip_measure_text_range(HWND hwnd, const char* text,
    int char_count, const char* font_family, float font_size) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (!ctx || !ctx->memDC || !text || char_count <= 0) return 0.0f;
    wchar_t* tw = utf8_to_utf16(text);
    if (!tw) return 0.0f;
    int len = (int)wcslen(tw);
    if (char_count > len) char_count = len;

    Graphics graphics(ctx->memDC);
    graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    wchar_t* fw = font_family ? utf8_to_utf16(font_family) : NULL;
    FontFamily ff(fw ? fw : L"Microsoft YaHei");
    Font f(&ff, font_size, FontStyleRegular, UnitPixel);
    if (fw) free(fw);

    StringFormat fmt(StringFormat::GenericTypographic());
    fmt.SetAlignment(StringAlignmentNear);
    fmt.SetLineAlignment(StringAlignmentNear);
    fmt.SetFormatFlags(fmt.GetFormatFlags() | StringFormatFlagsMeasureTrailingSpaces);
    CharacterRange range(0, char_count);
    fmt.SetMeasurableCharacterRanges(1, &range);

    Region region;
    RectF layoutRect(0.0f, 0.0f, 10000.0f, 10000.0f);
    graphics.MeasureCharacterRanges(tw, len, &f, layoutRect, &fmt, 1, &region);

    RectF bounds;
    region.GetBounds(&bounds, &graphics);
    free(tw);
    return bounds.Width;
}

__declspec(dllexport) void* bridge_gdip_load_image(const char* filePath) {
    int len = MultiByteToWideChar(CP_UTF8, 0, filePath, -1, NULL, 0);
    if (len == 0) return NULL;
    wchar_t* wpath = (wchar_t*)malloc(len * sizeof(wchar_t));
    MultiByteToWideChar(CP_UTF8, 0, filePath, -1, wpath, len);
    Bitmap* bmp = Bitmap::FromFile(wpath, FALSE);
    free(wpath);
    if (bmp && bmp->GetLastStatus() == Ok) return bmp;
    if (bmp) delete bmp;
    return NULL;
}

__declspec(dllexport) void bridge_gdip_get_image_size(void* img, float* out_w, float* out_h) {
    Bitmap* bmp = (Bitmap*)img;
    if (bmp) { *out_w = (float)bmp->GetWidth(); *out_h = (float)bmp->GetHeight(); }
    else { *out_w = 0; *out_h = 0; }
}

__declspec(dllexport) void bridge_gdip_draw_image(HWND hwnd, void* img,
    float x, float y, float w, float h) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (!ctx || !ctx->memDC || !img) return;
    Bitmap* bmp = (Bitmap*)img;
    Graphics graphics(ctx->memDC);
    applyClipIfNeeded(&graphics, ctx);
    graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    graphics.DrawImage(bmp, RectF(x, y, w, h), 0, 0, (REAL)bmp->GetWidth(), (REAL)bmp->GetHeight(), UnitPixel);
}

__declspec(dllexport) void bridge_gdip_free_image(void* img) {
    if (img) delete (Bitmap*)img;
}

__declspec(dllexport) void bridge_free_string(void* str) {
    if (str) free(str);
}

static wchar_t* build_filter(const char* filter) {
    if (!filter) return NULL;
    int len = (int)strlen(filter);
    wchar_t* wf = (wchar_t*)malloc((len + 2) * sizeof(wchar_t));
    if (!wf) return NULL;
    for (int i = 0; i < len; i++) {
        wf[i] = (filter[i] == '|') ? L'\0' : (wchar_t)filter[i];
    }
    wf[len] = L'\0'; wf[len + 1] = L'\0';
    return wf;
}

__declspec(dllexport) char* bridge_show_open_dialog(HWND hwnd, const char* title,
    const char* filter, bool multiSelect) {
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    IFileOpenDialog* dlg = NULL;
    if (FAILED(CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
        IID_IFileOpenDialog, (void**)&dlg))) {
        char* empty = (char*)malloc(1); empty[0] = '\0'; return empty;
    }

    wchar_t* wtitle = title ? utf8_to_utf16(title) : NULL;
    if (wtitle) { dlg->SetTitle(wtitle); free(wtitle); }

    wchar_t* wf = build_filter(filter);
    if (wf) {
        COMDLG_FILTERSPEC fs;
        fs.pszName = L"Files"; fs.pszSpec = wf;
        dlg->SetFileTypes(1, &fs);
    }

    DWORD flags; dlg->GetOptions(&flags);
    flags |= FOS_FORCEFILESYSTEM;
    if (multiSelect) flags |= FOS_ALLOWMULTISELECT;
    dlg->SetOptions(flags);

    char* result = NULL;
    if (SUCCEEDED(dlg->Show(hwnd))) {
        IShellItem* item;
        if (SUCCEEDED(dlg->GetResult(&item))) {
            wchar_t* wpath;
            if (SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &wpath))) {
                result = utf16_to_utf8(wpath);
                CoTaskMemFree(wpath);
            }
            item->Release();
        }
    }
    dlg->Release();
    if (wf) free(wf);
    if (!result) { result = (char*)malloc(1); result[0] = '\0'; }
    return result;
}

__declspec(dllexport) char* bridge_show_save_dialog(HWND hwnd, const char* title,
    const char* filter, const char* defaultName) {
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    IFileSaveDialog* dlg = NULL;
    if (FAILED(CoCreateInstance(CLSID_FileSaveDialog, NULL, CLSCTX_ALL,
        IID_IFileSaveDialog, (void**)&dlg))) {
        char* empty = (char*)malloc(1); empty[0] = '\0'; return empty;
    }

    wchar_t* wtitle = title ? utf8_to_utf16(title) : NULL;
    if (wtitle) { dlg->SetTitle(wtitle); free(wtitle); }

    wchar_t* wf = build_filter(filter);
    if (wf) {
        COMDLG_FILTERSPEC fs;
        fs.pszName = L"Files"; fs.pszSpec = wf;
        dlg->SetFileTypes(1, &fs);
    }

    if (defaultName) {
        wchar_t* wdn = utf8_to_utf16(defaultName);
        if (wdn) { dlg->SetFileName(wdn); free(wdn); }
    }

    DWORD flags; dlg->GetOptions(&flags);
    flags |= FOS_FORCEFILESYSTEM;
    dlg->SetOptions(flags);

    char* result = NULL;
    if (SUCCEEDED(dlg->Show(hwnd))) {
        IShellItem* item;
        if (SUCCEEDED(dlg->GetResult(&item))) {
            wchar_t* wpath;
            if (SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &wpath))) {
                result = utf16_to_utf8(wpath);
                CoTaskMemFree(wpath);
            }
            item->Release();
        }
    }
    dlg->Release();
    if (wf) free(wf);
    if (!result) { result = (char*)malloc(1); result[0] = '\0'; }
    return result;
}

__declspec(dllexport) HWND bridge_edit_create(HWND parent, int x, int y, int w_, int h_,
    const char* placeholder) {
    wchar_t* ph = placeholder ? utf8_to_utf16(placeholder) : NULL;
    HWND hEdit = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", ph ? ph : L"",
        WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | ES_AUTOHSCROLL,
        x, y, w_, h_, parent, NULL, GetModuleHandleW(NULL), NULL);
    if (ph) free(ph);
    if (hEdit) {
        HFONT hFont = CreateFontW(14, 0, 0, 0, FW_NORMAL,
            FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
            CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE,
            L"Microsoft YaHei");
        SendMessageW(hEdit, WM_SETFONT, (WPARAM)hFont, TRUE);
    }
    return hEdit;
}
__declspec(dllexport) void bridge_edit_destroy(HWND hEdit) { if (hEdit) DestroyWindow(hEdit); }
__declspec(dllexport) void bridge_edit_set_text(HWND hEdit, const char* text) {
    if (hEdit && text) { wchar_t* w = utf8_to_utf16(text); if (w) { SetWindowTextW(hEdit, w); free(w); } }
}
__declspec(dllexport) int bridge_edit_get_text(HWND hEdit, char* buffer, int bs) {
    if (hEdit && buffer && bs > 0) {
        int len = GetWindowTextLengthW(hEdit);
        if (len == 0) { buffer[0] = '\0'; return 0; }
        wchar_t* wb = (wchar_t*)malloc((len + 1) * sizeof(wchar_t));
        if (wb) { GetWindowTextW(hEdit, wb, len + 1);
            int r = WideCharToMultiByte(CP_UTF8, 0, wb, -1, buffer, bs, NULL, NULL);
            free(wb); return r; }
    }
    buffer[0] = '\0'; return 0;
}
__declspec(dllexport) void bridge_edit_set_focus(HWND hEdit) { if (hEdit) SetFocus(hEdit); }
__declspec(dllexport) void bridge_edit_set_readonly(HWND hEdit, bool ro) {
    if (hEdit) SendMessageW(hEdit, EM_SETREADONLY, ro ? TRUE : FALSE, 0);
}
__declspec(dllexport) void bridge_edit_select_all(HWND hEdit) {
    if (hEdit) SendMessageW(hEdit, EM_SETSEL, 0, -1);
}
__declspec(dllexport) void bridge_edit_set_pos(HWND hEdit, int x, int y, int w_, int h_) {
    if (hEdit) SetWindowPos(hEdit, NULL, x, y, w_, h_, SWP_NOZORDER);
}
__declspec(dllexport) void bridge_edit_show(HWND hEdit, bool show) {
    if (hEdit) ShowWindow(hEdit, show ? SW_SHOW : SW_HIDE);
}
__declspec(dllexport) void bridge_edit_set_border_color(HWND hEdit,
    unsigned char r, unsigned char g, unsigned char b) {
    if (hEdit) {
        SetWindowLongW(hEdit, GWL_EXSTYLE,
            GetWindowLongW(hEdit, GWL_EXSTYLE) & ~WS_EX_CLIENTEDGE);
        SetWindowPos(hEdit, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED);
    }
}
__declspec(dllexport) void bridge_edit_set_bg_color(HWND hEdit,
    unsigned char r, unsigned char g, unsigned char b) {
    if (hEdit) {
        HBRUSH hBrush = CreateSolidBrush(RGB(r, g, b));
        SetPropW(hEdit, L"BgBrush", hBrush);
        InvalidateRect(hEdit, NULL, TRUE);
    }
}

__declspec(dllexport) void bridge_clipboard_set_text(const char* text) {
    if (!text || !OpenClipboard(NULL)) return;
    EmptyClipboard();
    int len = MultiByteToWideChar(CP_UTF8, 0, text, -1, NULL, 0);
    if (len > 0) {
        HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, len * sizeof(wchar_t));
        if (hMem) { wchar_t* ws = (wchar_t*)GlobalLock(hMem);
            if (ws) { MultiByteToWideChar(CP_UTF8, 0, text, -1, ws, len);
                GlobalUnlock(hMem); SetClipboardData(CF_UNICODETEXT, hMem); } }
    }
    CloseClipboard();
}
__declspec(dllexport) int bridge_clipboard_get_text(char* buffer, int bs) {
    if (!buffer || bs <= 0) return 0; buffer[0] = '\0';
    if (!OpenClipboard(NULL)) return 0; int r = 0;
    HGLOBAL hMem = GetClipboardData(CF_UNICODETEXT);
    if (hMem) { wchar_t* ws = (wchar_t*)GlobalLock(hMem);
        if (ws) { r = WideCharToMultiByte(CP_UTF8, 0, ws, -1, buffer, bs, NULL, NULL);
            GlobalUnlock(hMem); } }
    CloseClipboard(); return r;
}
__declspec(dllexport) bool bridge_clipboard_has_text() {
    if (!OpenClipboard(NULL)) return false;
    bool has = IsClipboardFormatAvailable(CF_UNICODETEXT);
    CloseClipboard(); return has;
}

__declspec(dllexport) void bridge_window_set_min_size(HWND hwnd, int minW, int minH) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) { ctx->minWidth = minW; ctx->minHeight = minH; }
}

__declspec(dllexport) bool bridge_window_has_mouse_wheel_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->hasMouseWheelEvent : false;
}
__declspec(dllexport) int bridge_window_get_mouse_wheel_delta(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->mouseWheelDelta : 0;
}
__declspec(dllexport) int bridge_window_get_mouse_wheel_x(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->mouseWheelX : 0;
}
__declspec(dllexport) int bridge_window_get_mouse_wheel_y(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->mouseWheelY : 0;
}
__declspec(dllexport) void bridge_window_clear_mouse_wheel_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) ctx->hasMouseWheelEvent = false;
}

__declspec(dllexport) bool bridge_window_has_drop_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->hasDropEvent : false;
}
__declspec(dllexport) int bridge_window_get_drop_count(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    return ctx ? ctx->dropFileCount : 0;
}
__declspec(dllexport) int bridge_window_get_drop_file(HWND hwnd, int index, char* buffer, int bufferSize) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (!ctx || !ctx->dropFileList || index < 0 || index >= ctx->dropFileCount || !buffer || bufferSize <= 0) {
        buffer[0] = '\0'; return 0;
    }
    wchar_t* ptr = ctx->dropFileList;
    for (int i = 0; i < index; i++) { ptr += wcslen(ptr) + 1; }
    char* utf8 = utf16_to_utf8(ptr);
    if (utf8) {
        int len = (int)strlen(utf8);
        int copyLen = len < bufferSize - 1 ? len : bufferSize - 1;
        memcpy(buffer, utf8, copyLen); buffer[copyLen] = '\0';
        free(utf8);
        return copyLen;
    }
    buffer[0] = '\0'; return 0;
}
__declspec(dllexport) void bridge_window_clear_drop_event(HWND hwnd) {
    WindowContext* ctx = (WindowContext*)GetPropW(hwnd, L"CjFormCtx");
    if (ctx) {
        ctx->hasDropEvent = false;
        if (ctx->dropFileList) { free(ctx->dropFileList); ctx->dropFileList = NULL; }
        ctx->dropFileCount = 0;
    }
}

__declspec(dllexport) int bridge_window_get_x(HWND hwnd) {
    RECT r; if (GetWindowRect(hwnd, &r)) return r.left; return 0;
}
__declspec(dllexport) int bridge_window_get_y(HWND hwnd) {
    RECT r; if (GetWindowRect(hwnd, &r)) return r.top; return 0;
}
__declspec(dllexport) void bridge_window_set_pos(HWND hwnd, int x, int y, int w, int h) {
    if (hwnd) SetWindowPos(hwnd, NULL, x, y, w, h, SWP_NOZORDER);
}

__declspec(dllexport) void bridge_config_write_string(const char* section, const char* key, const char* value) {
    wchar_t* ws = utf8_to_utf16(section);
    wchar_t* wk = utf8_to_utf16(key);
    wchar_t* wv = utf8_to_utf16(value);
    if (ws && wk && wv) {
        WritePrivateProfileStringW(ws, wk, wv, L".\\cjform.ini");
    }
    if (ws) free(ws); if (wk) free(wk); if (wv) free(wv);
}
__declspec(dllexport) int bridge_config_read_string(const char* section, const char* key,
    const char* defaultVal, char* buffer, int bufferSize) {
    wchar_t* ws = utf8_to_utf16(section);
    wchar_t* wk = utf8_to_utf16(key);
    wchar_t* wd = utf8_to_utf16(defaultVal);
    if (!ws || !wk || !buffer || bufferSize <= 0) {
        if (ws) free(ws); if (wk) free(wk); if (wd) free(wd);
        buffer[0] = '\0'; return 0;
    }
    wchar_t wbuf[4096];
    GetPrivateProfileStringW(ws, wk, wd ? wd : L"", wbuf, 4096, L".\\cjform.ini");
    char* utf8 = utf16_to_utf8(wbuf);
    if (utf8) {
        int len = (int)strlen(utf8);
        int copyLen = len < bufferSize - 1 ? len : bufferSize - 1;
        memcpy(buffer, utf8, copyLen); buffer[copyLen] = '\0';
        free(utf8);
        if (ws) free(ws); if (wk) free(wk); if (wd) free(wd);
        return copyLen;
    }
    buffer[0] = '\0';
    if (ws) free(ws); if (wk) free(wk); if (wd) free(wd);
    return 0;
}

__declspec(dllexport) void bridge_config_write_int(const char* section, const char* key, int value) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", value);
    bridge_config_write_string(section, key, buf);
}
__declspec(dllexport) int bridge_config_read_int(const char* section, const char* key, int defaultVal) {
    char buf[32];
    char def[32];
    snprintf(def, sizeof(def), "%d", defaultVal);
    bridge_config_read_string(section, key, def, buf, sizeof(buf));
    return atoi(buf);
}

}
