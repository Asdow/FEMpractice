using StaticArrayUtils
using FEM

import ModernGL
global const GL = ModernGL;
import GLFW
import GLU

import Dates


function testi()

    nodes = [
        SVec3(0.0),
        SVec3x(4.0),
        SVec3x(8.0),
        SVec3(4.0, -3.0, 0.0)
    ]

    Ymodulus = 3000.0
    Area = 2.0

    elements = barElements(
        [
            SVec2(1,2),
            SVec2(2,3),
            SVec2(1,4),
            SVec2(2,4),
            SVec2(3,4)
        ],
        [Ymodulus for i in 1:5],
        [Area for i in 1:5]
    )


    #---------------------------------------------------------------
    # OPENGL STUFF
    xRes = 800;
    yRes = 600;
    # Open window and draw nodes as points/circles/whatever.
    window = GLU.createWindow(xRes, yRes, "FEM Nodes")
    GL.glEnable(GL.GL_VERTEX_PROGRAM_POINT_SIZE)
    # Capture mouse
    GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_DISABLED)

    camera = GLU.Camera(xRes, yRes)
    camera.position = SVec3(1.0, 0.0, 5.0)
    mouse = GLU.Mouse(xRes, yRes)


    # Create a lookAt matrix that transforms the world coordinates to view space.
    lookAt = GLU.lookAtMatrix( camera )




    shaderProgram = GLU.createShaderProgram(
        "./../GLSL/shaders/nodes.vert",
        "./../GLSL/shaders/nodes.frag"
    )
    GL.glUseProgram(shaderProgram)

    shaderBarElement = GLU.createShaderProgram(
        "./../GLSL/shaders/barElement.vert",
        "./../GLSL/shaders/barElement.frag"
    )



    modelMatrix = SMat44(Float32)
    # send the transformation matrices to the shader
    GLU.setUniform( shaderProgram, "modelMatrix", modelMatrix)




    VAO = GLU.createVertexArrayObject()[]
    GL.glBindVertexArray(VAO)

    nodePositions = convert( Array{SVec{3,Float32},1}, nodes )

    VBO = GLU.createBufferObject()[]
    # Load vertex data into a buffer
    GL.glBindBuffer(GL.GL_ARRAY_BUFFER, VBO)
    dataSize = sizeof( nodePositions )
    GL.glBufferData(GL.GL_ARRAY_BUFFER, dataSize, nodePositions, GL.GL_STATIC_DRAW)

    # Vertex position
    dataStride = sizeof( eltype(nodePositions) )
    GL.glVertexAttribPointer( 0, 3, GL.GL_FLOAT, GL.GL_FALSE, dataStride, C_NULL )
    GL.glEnableVertexAttribArray(0)

    # Element Buffer Object sauvaelementtien piirtoa varten
    EBO = GLU.createBufferObject()[]
    GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, EBO)

    elementData = [ convert(SVec{2,UInt32}, SVec2(elements.nodes[i]) ) - SVec2(UInt32(1)) for i in 1:length(elements.nodes) ]

    GL.glBufferData(
        GL.GL_ELEMENT_ARRAY_BUFFER,
        sizeof(elementData),
        elementData,
        GL.GL_STATIC_DRAW
    )

    GL.glBindVertexArray(0)



    CSVAO = GLU.createVertexArrayObject()[]
    GL.glBindVertexArray(CSVAO)

    CSVBO = GLU.createBufferObject()[]


    CSshader = GLU.createShaderProgram(
        "./../GLSL/shaders/coordinateSystem.vert",
        "./../GLSL/shaders/coordinateSystem.frag"
    )

    # send the transformation matrices to the shader
    GLU.setUniform( CSshader, "modelMatrix", modelMatrix)


    luoKoordinaatisto!(CSVAO, CSVBO, 0.1f0)



    UBO = GLU.createBufferObject()[]
    GLU.setUniformBlock( shaderProgram, "Matrices", 0 )
    GLU.setUniformBlock( CSshader, "Matrices", 0 )

    GL.glBindBuffer( GL.GL_UNIFORM_BUFFER, UBO )

    GL.glBufferData( GL.GL_UNIFORM_BUFFER, 2*sizeof(camera.projection), C_NULL, GL.GL_STATIC_DRAW )
    GL.glBindBufferRange( GL.GL_UNIFORM_BUFFER, 0, UBO, 0, 2*sizeof(camera.projection) )

    GL.glBufferSubData( GL.GL_UNIFORM_BUFFER, sizeof(camera.projection), sizeof(camera.projection), camera.projection )
    GL.glBindBuffer( GL.GL_UNIFORM_BUFFER, 0 )


    # deltaTime to make the camera movement steady.
    Δt = 0.0f0;
    LastFrame = Dates.now();
    # Renderloop
    while !GLFW.WindowShouldClose(window)
        # Calculate the cameraSpeed for smooth camera movement
        currentFrame = Dates.now()
        Δt = convert( Float32, Dates.value(currentFrame - LastFrame) ) * 0.001f0
        LastFrame = currentFrame

        GLU.handleInput(window, mouse, camera, Δt)


        viewMatrix = GLU.lookAtMatrix( camera )
        GL.glBindBuffer( GL.GL_UNIFORM_BUFFER, UBO )
        GL.glBufferSubData( GL.GL_UNIFORM_BUFFER, Int8(0), sizeof(viewMatrix), viewMatrix )
        GL.glBindBuffer( GL.GL_UNIFORM_BUFFER, Int8(0) )



        # All the rendering commands go here. Between processInput and SwapBuffers.
        clearScreen()

        GL.glUseProgram(shaderProgram)
        GL.glBindVertexArray(VAO)
        GL.glDrawArrays(GL.GL_POINTS, 0, 4)


        GL.glUseProgram(shaderBarElement)
        GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, EBO)
        GL.glDrawElements(GL.GL_LINES, 2*length(elementData), GL.GL_UNSIGNED_INT, C_NULL)
        GL.glBindVertexArray(0)


        GL.glUseProgram(CSshader)
        drawGlobalCS(CSVAO, UInt32(6), CSshader, SMat44(Float32))


        # Swap the buffers and check and call events
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    GLFW.Terminate()
    return nothing
end


function clearScreen()
    GL.glClearColor(0.10f0,0.12f0, 0.15f0, 1.0f0)
    GL.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT)
    return nothing
end


function luoKoordinaatisto!(VAO!, VBO!, pituus=0.3f0)
    Vdata = [
        # Position data
        SVec3( 0.0f0 ),
        SVec3x( pituus ),
        SVec3( 0.0f0 ),
        SVec3y( pituus ),
        SVec3( 0.0f0 ),
        SVec3z( pituus ),
        # Color data
        SVec3x( 1.0f0 ),
        SVec3x( 1.0f0 ),
        SVec3y( 1.0f0 ),
        SVec3y( 1.0f0 ),
        SVec3z( 1.0f0 ),
        SVec3z( 1.0f0 )
    ];


    GL.glBindVertexArray(VAO!)
    GL.glBindBuffer( GL.GL_ARRAY_BUFFER, VBO! )


    GL.glBufferData(
        GL.GL_ARRAY_BUFFER,
        sizeof(Vdata),
        Vdata,
        GL.GL_STATIC_DRAW
    )
    # Vertex position
    GLU.setVertexAttribute!(0, 3, 3*sizeof(Float32), 0)
    # Vertex color
    offset = 6*sizeof( SVec3( 0.0f0 ) )
    GLU.setVertexAttribute!(1, 3, 3*sizeof(Float32), offset)

    GL.glBindVertexArray(0)
    return nothing
end


function drawGlobalCS(VAO, nElements, shader, modelMatrix)
    # GL.glDisable( GL.GL_CULL_FACE )
    GL.glUseProgram( shader )
    GLU.setUniform( shader, "modelMatrix", modelMatrix )

    GL.glBindVertexArray( VAO )
    GL.glDrawArrays( GL.GL_LINES, 0, nElements )
    GL.glBindVertexArray( 0 )
    return nothing
end
