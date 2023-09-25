module graphics.window;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.freetype;

import std.string;
import std.stdio;
import std.functional;

import graphics.drawable;
import graphics.view;


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

    void delegate(Window*, int, int) onResizedCallback;
    
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
            SDL_Log("Failed loading SDL: ", sdlStatus);
            throw new Exception("Failed loading BindBC SDL");
        }
        if(loadSDLImage() < sdlImageSupport) { 
            throw new Exception("Failed loading BindBC SDL_image");
        }
        
        if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
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
            SDL_Log("Failed to set VSync");

        GLSupport glStatus = loadOpenGL();
        if (glStatus < glSupport)
        {
            SDL_Log("Failed loading minimum required OpenGL version: ", glStatus);
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

    void onResized(void delegate(Window*, int, int) dg) { 
        onResizedCallback = dg;
    }
    void onResized(void function(Window*, int, int) fn) { return onResized(toDelegate(fn)); }

    bool isOpen() {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                IMG_Quit();
                SDL_Quit();
                SDL_Log("Window quit.");
                return false;
            }
            if (e.type == SDL_WINDOWEVENT && e.window.event == SDL_WINDOWEVENT_RESIZED) {
                auto win = SDL_GetWindowFromID(e.window.windowID);
                if (win == this.window) {
                    glViewport(0, 0, e.window.data1, e.window.data2);
                    int w, h;
                    SDL_GetWindowSize(window, &w, &h);
                    if (this.onResizedCallback != null) {
                        this.onResizedCallback(&this, w, h);
                    }  
                }
            }
        }
        return true;
    }

    void setBounds(Bounds bounds) {
        SDL_SetWindowPosition(window, bounds.x, bounds.y);
        SDL_SetWindowSize(window, bounds.width, bounds.height);
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
}

class SDLException : Exception
{
	this(string file = __FILE__, size_t line = __LINE__) nothrow @nogc
	{
		super(cast(string) SDL_GetError().fromStringz, file, line);
	}
}
