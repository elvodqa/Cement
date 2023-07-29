import std.stdio;

import graphics.window;
import graphics.texture;
import graphics.sprite;
import graphics.text;
import system.event;

import system.input;

int main()
{
	Window window = new Window(800, 600, "Hell");
	Texture hlTexture = new Texture("hl.png");
	Sprite hlSprite = new Sprite(hlTexture);
	hlSprite.width = 256;
	hlSprite.height = 256;
	hlSprite.x = 0;
	hlSprite.y = 0;

	Text text = new Text("./aller.ttf", 32);
	text.text = "Hello, World!";
	text.y = 300;
	writeln(window.bounds.width);

	while (window.isOpen()) {
		auto state = Keyboard.getState();
		if (state.isKeyDown(Keys.W)) {
			writeln("W pressed");
		}
		if (state.isKeyUp(Keys.W)) {
			writeln("W released");
		}

		window.clear(0.1, 0.2, 0.3);
		window.draw(hlSprite);
		window.draw(text);
		window.display();

		window.sleep(1000/60);
	}

	return 0;
}

