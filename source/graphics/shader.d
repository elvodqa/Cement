module graphics.shader;

import bindbc.opengl;

import std.stdio;
import std.string;
import std.file;

class Shader {
    const(char*) vertSource;
    const(char*) fragSource;
    GLuint programID;

    this(string name) {
        this.vertSource = readText("shaders/" ~ name ~ ".vert").toStringz;
        this.fragSource = readText("shaders/" ~ name ~ ".frag").toStringz;
        this.programID = glCreateProgram();

        GLint result;
	    int infoLogLength;

        // Vertex shader
        GLuint vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShaderID, 1, &vertSource, null);
        glCompileShader(vertexShaderID);
        glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, &result);
        glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char* errorMessage;
            glGetShaderInfoLog(vertexShaderID, infoLogLength, null, errorMessage);
            writeln(errorMessage[0 .. infoLogLength]);
        }

        // Fragment shader
        GLuint fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShaderID, 1, &fragSource, null);
        glCompileShader(fragmentShaderID);
        glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &result);
        glGetShaderiv(fragmentShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char* errorMessage;
            glGetShaderInfoLog(fragmentShaderID, infoLogLength, null, errorMessage);
            writeln(errorMessage[0 .. infoLogLength]);
        }

        // Link
        programID = glCreateProgram();
        glAttachShader(programID, vertexShaderID);
        glAttachShader(programID, fragmentShaderID);
        glLinkProgram(programID);
        glGetProgramiv(programID, GL_LINK_STATUS, &result);
        glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char* errorMessage;
            glGetProgramInfoLog(programID, infoLogLength, null, errorMessage);
            writeln(errorMessage[0 .. infoLogLength]);
        }

        // Delete unused compiled shaders because program is linked already
        glDetachShader(programID, vertexShaderID);
        glDetachShader(programID, fragmentShaderID);

        glDeleteShader(vertexShaderID);
        glDeleteShader(fragmentShaderID);
    }

    void use() {
        glUseProgram(this.programID);
    }
}