module graphics.window;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.freetype;


import std.string;
import std.stdio;

import graphics.drawable;
import graphics.view;

import system.event;

struct Bounds {
    int x;
    int y;
    int width;
    int height;
}

class Window {
private:
    int width;
    int height;
    string title;
    SDL_Window* window;
    SDL_GLContext context;
    bool running;
    View defaultView;

    
public:
    @property Bounds bounds() {
        return Bounds(0, 0, this.width, this.height);
    }

    this(int width, int height, string title) {
        this.width = width;
        this.height = height;
        this.title = title;
        this.defaultView = new View(0, 0, width, height);

        SDLSupport sdlStatus = loadSDL();
        if (sdlStatus != sdlSupport)
        {
            writeln("Failed loading SDL: ", sdlStatus);
            throw new Exception("Failed loading BindBC SDL");
        }
        if(loadSDLImage() < sdlImageSupport) { 
            throw new Exception("Failed loading BindBC SDL_image");
        }
        if (loadSDLTTF() < sdlTTFSupport) {
            throw new Exception("Failed loading BindBC SDL_ttf");
        }
        
        if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
            throw new SDLException();
        
        if (TTF_Init() < 0)
            throw new SDLException();
        
        if (IMG_Init(IMG_INIT_PNG | IMG_INIT_JPG) < 0)
            throw new SDLException();
        
        if (loadFreeType() < ftSupport) {
            throw new Exception("Failed loading BindBC FreeType");
        }

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
        version (OSX) {
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
        } else {
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
        }

        this.window = SDL_CreateWindow(this.title.toStringz, SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED, this.width, this.height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
        if (!window)
            throw new SDLException();

        this.context = SDL_GL_CreateContext(this.window);
        if (!context)
            throw new SDLException();

        if (SDL_GL_SetSwapInterval(1) < 0)
            writeln("Failed to set VSync");

        GLSupport glStatus = loadOpenGL();
        if (glStatus < glSupport)
        {
            writeln("Failed loading minimum required OpenGL version: ", glStatus);
            throw new Exception("Failed loading BindBC OpenGL");
        }

        // Load ICON using SDL2 Image
        SDL_Surface* icon = IMG_Load("hl.png");
        if (icon !is null) {
            SDL_SetWindowIcon(window, icon);
            SDL_FreeSurface(icon);
        }

        this.running = true;
        glViewport(0, 0, this.width, this.height);
    }

    void clear(float r, float g, float b) {
        glClearColor(r, g, b, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    void display() {
        SDL_GL_SwapWindow(this.window);
        
    }

    bool isOpen() {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                return false;
            }
            else if (e.type == SDL_WINDOWEVENT) {
                if (e.window.event == SDL_WINDOWEVENT_RESIZED) {
                    glViewport(0, 0, e.window.data1, e.window.data2);
                    //this.defaultView.resize(e.window.data1, e.window.data2);
                }
            }
        }
        return true;
    }

    void setView(View view) {
        this.defaultView = view;
        glViewport(view.x, view.y, view.width, view.height);
    }

    void draw(Drawable drawable) {
        drawable.draw(this);
    }

    void sleep(uint ms) {
        SDL_Delay(ms);
    }

    @property View view() {
        return this.defaultView;
    }

    /*
    bool pollEvent(Event e) {
        SDL_Event sdlEvent;
        while (SDL_PollEvent(&sdlEvent)) {
            auto win = SDL_GetWindowFromID(sdlEvent.window.windowID);
            if (this.window != win)
                continue;
            switch (sdlEvent.type) {
                case SDL_QUIT:
                    e.type = EventType.Closed;
                    return true;
                case SDL_KEYDOWN:
                    e.type = EventType.KeyDown;
                    e.key = cast(Keys) sdlEvent.key.keysym.sym;
                    return true;
                case SDL_KEYUP:
                    e.type = EventType.KeyUp;
                    e.key = cast(Keys) sdlEvent.key.keysym.sym;
                    return true;
                case SDL_MOUSEBUTTONDOWN:
                    e.type = EventType.MouseButtonDown;
                    e.mouse.button = cast(MouseButton) sdlEvent.button.button;
                    return true;
                case SDL_MOUSEBUTTONUP:
                    e.type = EventType.MouseButtonUp;
                    e.mouse.button = cast(MouseButton) sdlEvent.button.button;
                    return true;
                case SDL_MOUSEMOTION:
                    e.type = EventType.MouseMove;
                    e.mouse.x = sdlEvent.motion.x;
                    e.mouse.y = sdlEvent.motion.y;
                    return true;
                case SDL_MOUSEWHEEL:
                    e.type = EventType.MouseWheel;
                    e.mouse.wheelX = sdlEvent.wheel.x;
                    e.mouse.wheelY = sdlEvent.wheel.y;
                    return true;
                case SDL_WINDOWEVENT:
                    switch (sdlEvent.window.event) {
                        case SDL_WINDOWEVENT_RESIZED:
                            e.type = EventType.WindowResized;
                            e.window.width = sdlEvent.window.data1;
                            e.window.height = sdlEvent.window.data2;
                            return true;
                        case SDL_WINDOWEVENT_FOCUS_GAINED:
                            e.type = EventType.WindowFocusGained;
                            return true;
                        case SDL_WINDOWEVENT_FOCUS_LOST:
                            e.type = EventType.WindowFocusLost;
                            return true;
                        case SDL_WINDOWEVENT_ENTER:
                            e.type = EventType.WindowMouseEnter;
                            return true;
                        case SDL_WINDOWEVENT_LEAVE:
                            e.type = EventType.WindowMouseLeave;
                            return true;
                        case SDL_WINDOWEVENT_MOVED:
                            e.type = EventType.WindowMoved;
                            e.window.x = sdlEvent.window.data1;
                            e.window.y = sdlEvent.window.data2;
                            return true;
                        default:
                            return false;
                    }
                default:
                    return false;
            }
        }
        return false;
    }
    */
}

class SDLException : Exception
{
	this(string file = __FILE__, size_t line = __LINE__) nothrow @nogc
	{
		super(cast(string) SDL_GetError().fromStringz, file, line);
	}
}
