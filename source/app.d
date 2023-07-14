import bindbc.sdl;
import bindbc.opengl;

import std.stdio;
import std.string;
import core.thread;

import graphics.shader;

bool quit = false;
SDL_Event event;
SDL_Window* window;

int main()
{
	SDLSupport sdlStatus = loadSDL();
	if (sdlStatus != sdlSupport)
	{
		writeln("Failed loading SDL: ", sdlStatus);
		return 1;
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

	window = SDL_CreateWindow("Cement", SDL_WINDOWPOS_UNDEFINED,
			SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
	if (!window)
		throw new SDLException();

	const context = SDL_GL_CreateContext(window);
	if (!context)
		throw new SDLException();

	if (SDL_GL_SetSwapInterval(1) < 0)
		writeln("Failed to set VSync");

	GLSupport glStatus = loadOpenGL();
	if (glStatus < glSupport)
	{
		writeln("Failed loading minimum required OpenGL version: ", glStatus);
		return 1;
	}

	// Load ICON using SDL2 Image
	SDL_Surface* icon = IMG_Load("hl.png");
	if (icon !is null) {
		SDL_SetWindowIcon(window, icon);
		SDL_FreeSurface(icon);
	}

	loadScene();
	scope (exit)
		unloadScene();

	while (!quit)
	{
		update();

		render();

		SDL_Delay(1000 / 60);
	}
	
	return 0;
}

void update() {
	while (SDL_PollEvent(&event))
	{
		switch (event.type)
		{
		case SDL_QUIT:
			quit = true;
			break;
		case SDL_WINDOWEVENT:
			switch (event.window.event)
			{
			case SDL_WINDOWEVENT_RESIZED:
				glViewport(0, 0, event.window.data1, event.window.data2);
				break;
			default: break;
			}
			break;
		default:
			break;
		}
	}

	SDL_Delay(1000 / 64);
}

void render() {
	renderScene();

	SDL_GL_SwapWindow(window);
}

//dfmt off
const float[] vertexBufferPositions = [
	-0.5f, -0.5f, 0,
	0.5f, -0.5f, 0,
	0, 0.5f, 0
];
const float[] vertexBufferColors = [
	1, 0, 0,
	0, 1, 0,
	0, 0, 1
];
//dfmt on
GLuint vertexBuffer;
GLuint colorBuffer;
Shader shader;
GLuint vertexArrayID;

void loadScene()
{
	// create OpenGL buffers for vertex position and color data
	glGenVertexArrays(1, &vertexArrayID);
	glBindVertexArray(vertexArrayID);

	// load position data
	glGenBuffers(1, &vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertexBufferPositions.length,
			vertexBufferPositions.ptr, GL_STATIC_DRAW);

	// load color data
	glGenBuffers(1, &colorBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
	glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertexBufferColors.length,
			vertexBufferColors.ptr, GL_STATIC_DRAW);

	GLint result;
	int infoLogLength;

	shader = new Shader("shader");
}

void unloadScene()
{
	glDeleteBuffers(1, &vertexBuffer);
	glDeleteBuffers(1, &colorBuffer);
	glDeleteVertexArrays(1, &vertexArrayID);
	//glDeleteProgram(programID);
}

void renderScene()
{
	glClear(GL_COLOR_BUFFER_BIT);

	shader.use();

	glEnableVertexAttribArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glVertexAttribPointer(0, // attribute 0. No particular reason for 0, but must match the layout in the shader.
			3, // size
			GL_FLOAT, // type
			false, // normalized?
			0, // stride
			null  // array buffer offset
			);
	glEnableVertexAttribArray(1);
	glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
	glVertexAttribPointer(1, // attribute 1
			3, // size
			GL_FLOAT, // type
			false, // normalized?
			0, // stride
			null  // array buffer offset
			);
	// Draw the triangle!
	glDrawArrays(GL_TRIANGLES, 0, 3); // Starting from vertex 0; 3 vertices total -> 1 triangle
	glDisableVertexAttribArray(0);
	glDisableVertexAttribArray(1);
}

/// Exception for SDL related issues
class SDLException : Exception
{
	/// Creates an exception from SDL_GetError()
	this(string file = __FILE__, size_t line = __LINE__) nothrow @nogc
	{
		super(cast(string) SDL_GetError().fromStringz, file, line);
	}
}
