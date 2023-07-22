module graphics.vertexarrayobject;

import graphics.bufferobject;
import bindbc.opengl;

enum VertexAttribPointerType {
    Byte = GL_BYTE,
    UnsignedByte = GL_UNSIGNED_BYTE,
    Short = GL_SHORT,
    UnsignedShort = GL_UNSIGNED_SHORT,
    Int = GL_INT,
    UnsignedInt = GL_UNSIGNED_INT,
    Float = GL_FLOAT,
    Double = GL_DOUBLE
}

class VertexArrayObject(TVertexType, TIndexType) {
    uint handle;

    this(BufferObject!TVertexType vbo, BufferObject!TIndexType ebo) {
        glGenVertexArrays(1, &handle);
        this.bind();
        vbo.bind();
        ebo.bind();
    }
    
    void vertexAttributePointer(uint index, int count, VertexAttribPointerType type, uint vertexSize, int offset) {
        glVertexAttribPointer(index, count, type, false, vertexSize * cast(uint)TVertexType.sizeof, 
            cast(void*)(offset * cast(uint)TVertexType.sizeof));
        glEnableVertexAttribArray(index);
    }

    void bind() {
        glBindVertexArray(handle);
    }

    void unbind() {
        glBindVertexArray(0);
    }

    ~this() {
        //glDeleteVertexArrays(handle);
    }
}