package triangle

import "core:os"
import "core:fmt"
import "base:runtime"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:c"

GL_MAJOR_VERSION : c.int = 3
GL_MINOR_VERSION :: 3

vertices : [9]f32 = {
    -1.0, -0.5, 0.0,
    0.0, -0.5, 0.0,
    -0.5, 0.5, 0.0
}

vertices1 : [9]f32 = {
    0.0, -0.5, 0.0,
    1.0, -0.5, 0.0,
    0.5, 0.5, 0.0
}

main :: proc() {
    glfw.SetErrorCallback(error_callback)
    if glfw.Init() == false {
        fmt.println("Failed to initialize GLFW")
        return
    }

    glfw.WindowHint(glfw.RESIZABLE, 1)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window := glfw.CreateWindow(800, 600, "OpenGL Window", nil, nil)
    if window == nil {
        fmt.println("Failed to create GLFW window")
        glfw.Terminate()
        return
    }

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)
    
    glfw.SetKeyCallback(window, key_callback)
    glfw.SetFramebufferSizeCallback(window, size_callback)

    gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address) 

    Shaders, Shaders1, VBO, VAO := init()

    for !glfw.WindowShouldClose(window) {
        update()
        draw(Shaders, Shaders1, VAO)
        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }

    gl.DeleteVertexArrays(2, VAO)
    gl.DeleteBuffers(2, VBO)
    gl.DeleteProgram(Shaders)
    gl.DeleteProgram(Shaders1)

    exit()
}

init :: proc() -> (u32, u32, [^]u32, [^]u32) {
    // Load, compile shaders and link them
    Shaders, _ := gl.load_shaders_file("vertex.glsl", "fragment.glsl", false)
    Shaders1, _ := gl.load_shaders_file("vertex.glsl", "frag_ment.glsl", false)

    // Initialize VBO and VAO
    VBO := make([^]u32, 2)
    VAO := make([^]u32, 2)
    gl.GenVertexArrays(2, VAO)
    gl.GenBuffers(2, VBO)

    // Setup first VAO
    gl.BindVertexArray(VAO[0])
    gl.BindBuffer(gl.ARRAY_BUFFER, VBO[0])
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices[0], gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3*size_of(f32), uintptr(0))
    gl.EnableVertexAttribArray(0)

    // Setup second VAO
    gl.BindVertexArray(VAO[1])
    gl.BindBuffer(gl.ARRAY_BUFFER, VBO[1])
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices1), &vertices1[0], gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3*size_of(f32), uintptr(0))
    gl.EnableVertexAttribArray(0)

    // Unbind the buffers
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindVertexArray(0)
    
    return Shaders, Shaders1, VBO, VAO
}

update :: proc() {
    // Own update code here
}

draw :: proc(Shaders: u32, Shaders1: u32, VAO: [^]u32) {
    gl.ClearColor(0.2, 0.3, 0.3, 1.0)
    gl.Clear(gl.COLOR_BUFFER_BIT)
    
    gl.UseProgram(Shaders)
    gl.BindVertexArray(VAO[0])
    gl.DrawArrays(gl.TRIANGLES, 0, 3)
    
    gl.UseProgram(Shaders1)
    gl.BindVertexArray(VAO[1])
    gl.DrawArrays(gl.TRIANGLES, 0, 3)
}

exit :: proc() {
    // Own termination code here
    glfw.Terminate()
}

// Called when glfw keystate changes
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    if key == glfw.KEY_ESCAPE {
        glfw.SetWindowShouldClose(window, true)
    }
}

size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    // Set the OpenGL viewport size
    gl.Viewport(0, 0, width, height)
}

error_callback :: proc "c" (error: c.int, description: cstring) {
    context = runtime.default_context()
    fmt.eprintln("GLFW Error:", error, description)
}
