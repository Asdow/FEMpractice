#version 330 core
layout(location=0) in vec3 vertexPosition;

layout(std140) uniform Matrices{
    mat4 viewMatrix;
    mat4 projectionMatrix;
};


void main()
{
    mat4 MVP = projectionMatrix * viewMatrix;
    gl_Position = MVP * vec4( vertexPosition, 1.0 );

}
