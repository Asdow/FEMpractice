#version 330 core
layout(location=0) in vec3 vertexPosition;
layout(location=1) in vec3 vertexColor;

uniform mat4 modelMatrix;
layout(std140) uniform Matrices{
    mat4 viewMatrix;
    mat4 projectionMatrix;
};

// Specifies an output and if a shader in the next stage has an input that matches the type and name, they get linked together.
out vec4 vColor;

void main()
{
    mat4 MVP = projectionMatrix * viewMatrix * modelMatrix;
    gl_Position = MVP * vec4( vertexPosition, 1.0 );


    vColor = vec4( vertexColor, 1.0);
}
