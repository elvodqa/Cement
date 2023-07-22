module graphics.window;

import bindbc.sdl;
import bindbc.opengl;

import std.string;
import std.stdio;

import graphics.drawable;
import graphics.view;

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
        
        if (SDL_Init(SDL_INIT_VIDEO) < 0)
            throw new SDLException();

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
    }

    void clear(float r, float g, float b) {
        glClearColor(r, g, b, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    void display() {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_WINDOWEVENT) {
                if (e.window.event == SDL_WINDOWEVENT_RESIZED) {
                    glViewport(0, 0, e.window.data1, e.window.data2);
                    //this.defaultView = new View(0, 0, e.window.data1, e.window.data2);
                }
            }
        }
        
        SDL_GL_SwapWindow(this.window);
    }

    bool isOpen() {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                return false;
            }
        }
        return true;
    }

    void draw(Drawable drawable) {
        drawable.draw(this);
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
