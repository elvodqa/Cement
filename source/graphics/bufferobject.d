module graphics.bufferobject;

import bindbc.opengl;

import std.stdio;


enum BufferTarget {
    ArrayBuffer = GL_ARRAY_BUFFER,
    //AtomicCounterBuffer = GL_ATOMIC_COUNTER_BUFFER,
    CopyReadBuffer = GL_COPY_READ_BUFFER,
    CopyWriteBuffer = GL_COPY_WRITE_BUFFER,
    //DispatchIndirectBuffer = GL_DISPATCH_INDIRECT_BUFFER,
    DrawIndirectBuffer = GL_DRAW_INDIRECT_BUFFER,
    ElementArrayBuffer = GL_ELEMENT_ARRAY_BUFFER,
    PixelPackBuffer = GL_PIXEL_PACK_BUFFER,
    PixelUnpackBuffer = GL_PIXEL_UNPACK_BUFFER,
    //QueryBuffer = GL_QUERY_BUFFER,
    //ShaderStorageBuffer = GL_SHADER_STORAGE_BUFFER,
    TextureBuffer = GL_TEXTURE_BUFFER,
    TransformFeedbackBuffer = GL_TRANSFORM_FEEDBACK_BUFFER,
    UniformBuffer = GL_UNIFORM_BUFFER
}

class BufferObject(T) {
    uint handle;
    BufferTarget target;

    this(T[] data, BufferTarget target) {
        this.target = target;
        glGenBuffers(1, &handle);
        
        this.bind();
        glBufferData(target, data.length * T.sizeof, data.ptr, GL_STATIC_DRAW);
    }

    void bind() {
        glBindBuffer(target, handle);
    }

    void unbind() {
        glBindBuffer(target, 0);
    }

    ~this() {
        //glDeleteBuffers(1, handle);
    }

}
