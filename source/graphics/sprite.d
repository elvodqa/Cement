module graphics.sprite;

import graphics.texture;
import graphics.drawable;
import graphics.shader;
import graphics.bufferobject;
import graphics.vertexarrayobject;
import graphics.window;

import bindbc.opengl;
import bindbc.sdl;
import gl3n.linalg;

import std.stdio;

const string vertexShaderSource = q{
    // vertex shader for sprite. Sprite has a texture and a position. 
    // It will use view and projection from window. It will have a x and y position and a width and height
    #version 330 core
    layout (location = 0) in vec3 aPos;
    layout (location = 1) in vec2 aTexCoord;

    out vec2 TexCoord;

    uniform mat4 projection;
    uniform mat4 view;
    uniform mat4 model;

    void main()
    {
        gl_Position = projection * view * model * vec4(aPos, 1.0);
        TexCoord = vec2(aTexCoord.x, aTexCoord.y);
    }
}; 

const string fragmentShaderSource = q{
    #version 330 core
    out vec4 FragColor;

    in vec2 TexCoord;

    uniform sampler2D texture1;

    void main()
    {
        FragColor = texture(texture1, TexCoord);
    }
};

class Sprite : Drawable {
    Texture texture;
    int x, y, width, height;
    private Shader shader;
    private BufferObject!float vbo;
    private BufferObject!uint ebo;
    private VertexArrayObject!(float, uint) vao;

    this(Texture texture) {
        this.texture = texture;
        this.x = 0;
        this.y = 0;
        this.width = texture.width;
        this.height = texture.height;
        this.shader = new Shader(vertexShaderSource, fragmentShaderSource);
        /*
        float[] vertices = [
            // positions          // texture coords
            0.0f,  0.0f, 0.0f,   0.0f, 0.0f, // top left
            0.0f,  height, 0.0f,   0.0f, 1.0f, // bottom left
            width, height, 0.0f,   1.0f, 1.0f, // bottom right
            width,  0.0f, 0.0f,   1.0f, 0.0f  // top right 
        ];*/
        // without using width and height. why i even did used this dunno
        float[] vertices = [
            // positions          // texture coords
            0.0f,  0.0f, 0.0f,   0.0f, 0.0f, // top left
            0.0f,  1.0f, 0.0f,   0.0f, 1.0f, // bottom left
            1.0f,  1.0f, 0.0f,   1.0f, 1.0f, // bottom right
            1.0f,  0.0f, 0.0f,   1.0f, 0.0f  // top right 
        ];

        uint[] indices = [
            0, 1, 3, // first triangle
            1, 2, 3  // second triangle
        ];

        ebo = new BufferObject!uint(indices, BufferTarget.ElementArrayBuffer);
        vbo = new BufferObject!float(vertices, BufferTarget.ArrayBuffer);
        vao = new VertexArrayObject!(float, uint)(vbo, ebo);

        vao.vertexAttributePointer(0, 3, VertexAttribPointerType.Float, 5 * float.sizeof, 0);
        vao.vertexAttributePointer(1, 2, VertexAttribPointerType.Float, 5 * float.sizeof, 3 * float.sizeof);

        
    }

    override void draw(Window window) {
        vao.bind();
        texture.bind();
        shader.use();

        // set uniforms
        mat4 projection = window.view.projection;
        mat4 view = window.view.view;
        mat4 model = mat4.identity;
        model = model.translate(x, y, 0);
        model = model.scale(width, height, 1);

        // transpose because opengl is column major and gl3n is row major
        projection.transpose();
        view.transpose();
        model.transpose();
        
        shader.setUniform("projection", projection);
        shader.setUniform("view", view);
        shader.setUniform("model", model);


        shader.setUniform("texture1", 0);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
    }
}