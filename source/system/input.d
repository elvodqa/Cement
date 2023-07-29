module system.input;

import bindbc.sdl;
import std.stdio;

struct KeyboardState {
    Keys[] keys;
    bool capsLock;
    bool numLock;

    @property ulong pressedKeyCount() {
        return pressedKeys.length;
    }

    @property Keys[] pressedKeys() {
        Keys[] pressedKeys;
        foreach (key; keys) {
            // check with SDL
            SDL_Scancode scancode = cast(SDL_Scancode)key;
            if (SDL_GetKeyboardState(null)[scancode]) {
                pressedKeys ~= key;
            }
        }
        return pressedKeys;
    }

    bool isKeyDown(Keys key) {
        SDL_Scancode scancode = cast(SDL_Scancode)key;
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            //writeln("Event polled");
            if (event.type == SDL_KEYDOWN && event.key.keysym.scancode == scancode) {
                return true;
            }
        }
        return false;
    }

    bool isKeyUp(Keys key) {
        SDL_Scancode scancode = cast(SDL_Scancode)key;
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_KEYUP && event.key.keysym.scancode == scancode) {
                return true;
            }
        }
        return false;
    }
}

class Keyboard {
    public static KeyboardState getState() {
        // use SDL_GetKeyboardState
        KeyboardState state;
        auto keys = SDL_GetKeyboardState(null)[0 .. SDL_NUM_SCANCODES];
        // cast all to Keys
        state.keys = new Keys[keys.length];
        for (int i = 0; i < keys.length; i++) {
            state.keys[i] = cast(Keys)keys[i];
        }
        state.capsLock = SDL_GetModState() & (KMOD_CAPS != 0);
        state.numLock = SDL_GetModState() & (KMOD_NUM != 0);
        return state;
    }
}

enum MouseButton {
    Left = SDL_BUTTON_LEFT,
    Right = SDL_BUTTON_RIGHT,
    Middle = SDL_BUTTON_MIDDLE,
    X1 = SDL_BUTTON_X1,
    X2 = SDL_BUTTON_X2,
}

enum Keys {
    A = SDL_SCANCODE_A,
    B = SDL_SCANCODE_B,
    C = SDL_SCANCODE_C,
    D = SDL_SCANCODE_D,
    E = SDL_SCANCODE_E,
    F = SDL_SCANCODE_F,
    G = SDL_SCANCODE_G,
    H = SDL_SCANCODE_H,
    I = SDL_SCANCODE_I,
    J = SDL_SCANCODE_J,
    K = SDL_SCANCODE_K,
    L = SDL_SCANCODE_L,
    M = SDL_SCANCODE_M,
    N = SDL_SCANCODE_N,
    O = SDL_SCANCODE_O,
    P = SDL_SCANCODE_P,
    Q = SDL_SCANCODE_Q,
    R = SDL_SCANCODE_R,
    S = SDL_SCANCODE_S,
    T = SDL_SCANCODE_T,
    U = SDL_SCANCODE_U,
    V = SDL_SCANCODE_V,
    W = SDL_SCANCODE_W,
    X = SDL_SCANCODE_X,
    Y = SDL_SCANCODE_Y,
    Z = SDL_SCANCODE_Z,
    Num0 = SDL_SCANCODE_0,
    Num1 = SDL_SCANCODE_1,
    Num2 = SDL_SCANCODE_2,
    Num3 = SDL_SCANCODE_3,
    Num4 = SDL_SCANCODE_4,
    Num5 = SDL_SCANCODE_5,
    Num6 = SDL_SCANCODE_6,
    Num7 = SDL_SCANCODE_7,
    Num8 = SDL_SCANCODE_8,
    Num9 = SDL_SCANCODE_9,
    Escape = SDL_SCANCODE_ESCAPE,
    LControl = SDL_SCANCODE_LCTRL,
    LShift = SDL_SCANCODE_LSHIFT,
    LAlt = SDL_SCANCODE_LALT,
    LSystem = SDL_SCANCODE_LGUI,
    RControl = SDL_SCANCODE_RCTRL,
    RShift = SDL_SCANCODE_RSHIFT,
    RAlt = SDL_SCANCODE_RALT,
    RSystem = SDL_SCANCODE_RGUI,
    Menu = SDL_SCANCODE_MENU,
    LBracket = SDL_SCANCODE_LEFTBRACKET,
    RBracket = SDL_SCANCODE_RIGHTBRACKET,
    Semicolon = SDL_SCANCODE_SEMICOLON,
    Comma = SDL_SCANCODE_COMMA,
    Period = SDL_SCANCODE_PERIOD,
    Quote = SDL_SCANCODE_APOSTROPHE,
    Slash = SDL_SCANCODE_SLASH,
    Backslash = SDL_SCANCODE_BACKSLASH,
    Tilde = SDL_SCANCODE_GRAVE,
    Equal = SDL_SCANCODE_EQUALS,
    Hyphen = SDL_SCANCODE_MINUS,
    Space = SDL_SCANCODE_SPACE,
    Enter = SDL_SCANCODE_RETURN,
    Backspace = SDL_SCANCODE_BACKSPACE,
    Tab = SDL_SCANCODE_TAB,
    PageUp = SDL_SCANCODE_PAGEUP,
    PageDown = SDL_SCANCODE_PAGEDOWN,
    End = SDL_SCANCODE_END,
    Home = SDL_SCANCODE_HOME,
    Insert = SDL_SCANCODE_INSERT,
    Delete = SDL_SCANCODE_DELETE,
    Add = SDL_SCANCODE_KP_PLUS,
    Subtract = SDL_SCANCODE_KP_MINUS,
    Multiply = SDL_SCANCODE_KP_MULTIPLY,
    Divide = SDL_SCANCODE_KP_DIVIDE,
    Left = SDL_SCANCODE_LEFT,
    Right = SDL_SCANCODE_RIGHT,
    Up = SDL_SCANCODE_UP,
    Down = SDL_SCANCODE_DOWN,
    Numpad0 = SDL_SCANCODE_KP_0,
    Numpad1 = SDL_SCANCODE_KP_1,
    Numpad2 = SDL_SCANCODE_KP_2,
    Numpad3 = SDL_SCANCODE_KP_3,
    Numpad4 = SDL_SCANCODE_KP_4,
    Numpad5 = SDL_SCANCODE_KP_5,
    Numpad6 = SDL_SCANCODE_KP_6,
    Numpad7 = SDL_SCANCODE_KP_7,
    Numpad8 = SDL_SCANCODE_KP_8,
    Numpad9 = SDL_SCANCODE_KP_9,
    F1 = SDL_SCANCODE_F1,
    F2 = SDL_SCANCODE_F2,
    F3 = SDL_SCANCODE_F3,
    F4 = SDL_SCANCODE_F4,
    F5 = SDL_SCANCODE_F5,
    F6 = SDL_SCANCODE_F6,
    F7 = SDL_SCANCODE_F7,
    F8 = SDL_SCANCODE_F8,
    F9 = SDL_SCANCODE_F9,
    F10 = SDL_SCANCODE_F10,
    F11 = SDL_SCANCODE_F11,
    F12 = SDL_SCANCODE_F12,
    F13 = SDL_SCANCODE_F13,
    F14 = SDL_SCANCODE_F14,
    F15 = SDL_SCANCODE_F15,
    Pause = SDL_SCANCODE_PAUSE,
    NumLock = SDL_SCANCODE_NUMLOCKCLEAR,
    CapsLock = SDL_SCANCODE_CAPSLOCK,
    ScrollLock = SDL_SCANCODE_SCROLLLOCK,
}