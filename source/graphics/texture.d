module graphics.texture;

import std.string;

import bindbc.opengl;
import bindbc.sdl;

class Texture {
    uint handle;
    SDL_Surface* image;

    this(SDL_Surface* image) {
        glGenTextures(1, &handle);
        this.bind();
        
        this.image = image;
        scope(exit) {
            SDL_FreeSurface(image);
        }
        auto format = image.format;
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.w, image.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 8); 

        glGenerateMipmap(GL_TEXTURE_2D);

        glBindTexture(GL_TEXTURE_2D, 0);
    }

    this(string path) {
        glGenTextures(1, &handle);
        this.bind();
        
        //auto image = IMG_Load(("textures/" ~ name).toStringz);
        image = IMG_Load(path.toStringz);
        if (image is null) {
            throw new Exception("Failed to load texture: " ~ path);
        }
        scope(exit) {
            SDL_FreeSurface(image);
        }
        auto format = image.format;
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.w, image.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 8);

        glGenerateMipmap(GL_TEXTURE_2D);

        glBindTexture(GL_TEXTURE_2D, 0);
    }

    void bind(uint textureSlot = GL_TEXTURE0) {
        glActiveTexture(textureSlot);
        glBindTexture(GL_TEXTURE_2D, handle);
    }

    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    ~this() {
        glDeleteTextures(1, &handle);
    }

    @property int width() const {
        return image.w;
    }

    @property int height() const {
        return image.h;
    }

    @property SDL_Surface* surface() {
        return image;
    }
}