#version 330 core
layout (location = 0) in vec3 vertexPosition;


uniform mat4 modelMatrix;
layout(std140) uniform Matrices{
    mat4 viewMatrix;
    mat4 projectionMatrix;
};
// uniform vec3 nodePositions[4];

void main()
{
    // vec3 vertexPosition = nodePositions[ gl_InstanceID ];
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4( vertexPosition, 1.0 );
    gl_PointSize = 3.0;
}
