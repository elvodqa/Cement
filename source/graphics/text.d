module graphics.text;

import graphics.texture;
import graphics.drawable;
import graphics.shader;
import graphics.bufferobject;
import graphics.vertexarrayobject;
import graphics.window;

import bindbc.opengl;
import bindbc.sdl;
import gl3n.linalg;
import bindbc.freetype;

import std.stdio;
import std.string;

import graphics.sprite;

struct Character {
    uint textureID; // ID handle of the glyph texture
    vec2i size;     // Size of glyph
    vec2i bearing;  // Offset from baseline to left/top of glyph
    uint advance;   // Offset to advance to next glyph
}

class Text : Drawable {

    private Character[char] characters;
    private Shader shader;

    float x = 0;
    float y = 0;
    float scale = 1;
    string text;

    uint VAO, VBO;

    this(string fontPath, int fontSize) {
        FT_Library ft;
        if (FT_Init_FreeType(&ft)) {
            writeln("ERROR::FREETYPE: Could not init FreeType Library");
        }

        FT_Face face;
        if (FT_New_Face(ft, fontPath.toStringz, 0, &face)) {
            writeln("ERROR::FREETYPE: Failed to load font");
        }

        FT_Set_Pixel_Sizes(face, 0, fontSize);

        if (FT_Load_Char(face, 'X', FT_LOAD_RENDER))
        {
            writeln("ERROR::FREETYTPE: Failed to load Glyph");
        }

        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
       
        for (char c = 0; c < 128; c++) {
            if (FT_Load_Char(face, c, FT_LOAD_RENDER)) {
                writeln("ERROR::FREETYTPE: Failed to load Glyph");
                continue;
            }
            uint texture;
            glGenTextures(1, &texture);
            glBindTexture(GL_TEXTURE_2D, texture);
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         GL_RED,
                         face.glyph.bitmap.width,
                         face.glyph.bitmap.rows,
                         0,
                         GL_RED,
                         GL_UNSIGNED_BYTE,
                         face.glyph.bitmap.buffer);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);

            Character character = Character(
                texture,
                vec2i(face.glyph.bitmap.width, face.glyph.bitmap.rows),
                vec2i(face.glyph.bitmap_left, face.glyph.bitmap_top),
                cast(uint)face.glyph.advance.x
            );
            
            characters[c] = character;
        }
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

        FT_Done_Face(face);
        FT_Done_FreeType(ft);

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        glBindVertexArray(VAO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, 6 * 4 * float.sizeof, null, GL_DYNAMIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(void*)0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
        shader = new Shader(vertexShaderSource, fragmentShaderSource);
    }

  
    override void draw(Window window) {
        shader.use();
        auto projection = window.view.projection;
        auto view = window.view.view;
        auto model = mat4.identity;
        
       
        
        shader.setUniform("projection", projection);
        shader.setUniform("view", view);
        shader.setUniform("model", model);
        shader.setUniform("textColor", vec3(1.0f, 1.0f, 1.0f));
        glActiveTexture(GL_TEXTURE0);
        glBindVertexArray(VAO);

        float oldX = x;

        foreach (char c; text) {
            Character ch = characters[c];
            
            float xpos = x + ch.bearing.x * scale;
            //float ypos = y - (ch.size.y - ch.bearing.y) * scale;
            // flip y
            float ypos = y + (ch.size.y - ch.bearing.y) * scale;

            float w = ch.size.x * scale;
            float h = ch.size.y * scale * -1; // !! added -1 later

            float[] vertices = [
                xpos,     ypos + h,   0.0, 0.0,
                xpos,     ypos,       0.0, 1.0,
                xpos + w, ypos,       1.0, 1.0,

                xpos,     ypos + h,   0.0, 0.0,
                xpos + w, ypos,       1.0, 1.0,
                xpos + w, ypos + h,   1.0, 0.0
            ];

            glBindTexture(GL_TEXTURE_2D, ch.textureID);

            glBindBuffer(GL_ARRAY_BUFFER, VBO);
            glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.length * float.sizeof, vertices.ptr);
            glBindBuffer(GL_ARRAY_BUFFER, 0);


            glDrawArrays(GL_TRIANGLES, 0, 6);

            x += (ch.advance >> 6) * scale; // Bitshift by 6 to get value in pixels (2^6 = 64)
        }
        glBindVertexArray(0);
        glBindTexture(GL_TEXTURE_2D, 0);
        x = oldX;
        
    }

    ~this() {
        glDeleteVertexArrays(1, &VAO);
        glDeleteBuffers(1, &VBO);
        shader.dispose();
    }

    string vertexShaderSource = q{
        #version 330 core
        layout (location = 0) in vec4 vertex; // <vec2 pos, vec2 tex>
        out vec2 TexCoords;
        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 model;
        
        void main()
        {
            gl_Position = projection * view * model * vec4(vertex.xy, 0.0, 1.0);
            TexCoords = vertex.zw;
        }
    };

    string fragmentShaderSource = q{
        #version 330 core
        in vec2 TexCoords;
        out vec4 color;

        uniform sampler2D text;
        uniform vec3 textColor;

        void main()
        {    
            vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, TexCoords).r);
            color = vec4(textColor, 1.0) * sampled;
        }  
    };
}

