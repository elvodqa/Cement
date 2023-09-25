import std.stdio;

import graphics.window;
import graphics.texture;
import graphics.sprite;
import graphics.text;
import graphics.view;


void onResize(Window* window, int w, int h) {
	writeln(w, "x", h);
	window.setView(new View(0, 0, w, h));
}

int main()
{
	Window window;

	window = new Window(1200, 720, "Test");
	Texture hlTexture = new Texture("hl.png");
	Sprite hlSprite = new Sprite(hlTexture);
	hlSprite.width = 256;
	hlSprite.height = 256;
	hlSprite.x = 0;
	hlSprite.y = 0;

	Text text = new Text("./aller.ttf", 32);
	text.text = "Hello, World!";
	text.y = 300;

	window.onResized = &onResize;

	while (window.isOpen()) {
		hlSprite.x += 1;
	
		window.clear(0.1, 0.2, 0.3);
		window.draw(hlSprite);
		window.draw(text);
		window.display();
	}

	return 0;
}

