import bindbc.sdl;
import bindbc.opengl;

import std.stdio;
import std.string;
import core.thread;

import graphics.shader;
import graphics.texture;
import graphics.bufferobject;
import graphics.vertexarrayobject;

import graphics.window;
import graphics.texture;
import graphics.sprite;

int main()
{
	Window window = new Window(800, 600, "Hell");
	Texture hlTexture = new Texture("hl.png");
	Sprite hlSprite = new Sprite(hlTexture);
	hlSprite.width = 100;
	hlSprite.height = 100;

	while (window.isOpen()) {
		window.clear(0.1, 0.2, 0.3);
		window.draw(hlSprite);
		window.display();
	}

	return 0;
}

// ignore-------_!!_!_!_!__!_!_
void update() {
	/*
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
	}*/

	SDL_Delay(1000 / 64);
}


BufferObject!float vbo;
BufferObject!uint ebo;
VertexArrayObject!(float, uint) vao;

Texture texture;
Shader shader;

float[] vertices =
[
	//X    Y      Z     S    T
	0.5f,  0.5f, 0.0f, 1.0f, 0.0f,
	0.5f, -0.5f, 0.0f, 1.0f, 1.0f,
	-0.5f, -0.5f, 0.0f, 0.0f, 1.0f,
	-0.5f,  0.5f, 0.5f, 0.0f, 0.0f
];

uint[] indices =
[
	0, 1, 3,
	1, 2, 3
];


void loadScene()
{
	ebo = new BufferObject!uint(indices, BufferTarget.ElementArrayBuffer);
	vbo = new BufferObject!float(vertices, BufferTarget.ArrayBuffer);
	vao = new VertexArrayObject!(float, uint)(vbo, ebo);

	vao.vertexAttributePointer(0, 3, VertexAttribPointerType.Float, 5, 0);
	vao.vertexAttributePointer(1, 2, VertexAttribPointerType.Float, 5, 3);

	shader = new Shader("shader");
	texture = new Texture("hl.png");
}

void renderScene()
{
	glClear(GL_COLOR_BUFFER_BIT);
	vao.bind();
	shader.use();
	texture.bind();
	shader.setUniform("uTexture", 0);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
}

void unloadScene()
{
	
}


