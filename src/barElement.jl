struct barElements{T<:Real}
    nodes::Vector{SVec{2,Int}}
    Ymoduli::Vector{T}
    Areas::Vector{T}
end


function createElementStiffnessMatrix(coordinatesNodeA, coordinatesNodeB, Ymodulus, Area)
    elementVector = coordinatesNodeB - coordinatesNodeA

    elementLength = linAlg.norm( elementVector )
    stiffnessMultiplier = ( Ymodulus*Area ) / ( elementLength^3 )


    x = elementVector[1]
    y = elementVector[2]
    z = elementVector[3]


    stiffnessMatrix = zeros(6,6)

    stiffnessMatrix[1,1] = x^2
    stiffnessMatrix[2,1] = x*y
    stiffnessMatrix[3,1] = x*z
    stiffnessMatrix[4,1] = -x^2
    stiffnessMatrix[5,1] = -x*y
    stiffnessMatrix[6,1] = -x*z

    stiffnessMatrix[1,2] = x*y
    stiffnessMatrix[2,2] = y^2
    stiffnessMatrix[3,2] = y*z
    stiffnessMatrix[4,2] = -x*y
    stiffnessMatrix[5,2] = -y^2
    stiffnessMatrix[6,2] = -y*z

    stiffnessMatrix[1,3] = x*z
    stiffnessMatrix[2,3] = y*z
    stiffnessMatrix[3,3] = z^2
    stiffnessMatrix[4,3] = -x*z
    stiffnessMatrix[5,3] = -y*z
    stiffnessMatrix[6,3] = -z^2

    stiffnessMatrix[1,4] = -x^2
    stiffnessMatrix[2,4] = -x*y
    stiffnessMatrix[3,4] = -x*z
    stiffnessMatrix[4,4] = x^2
    stiffnessMatrix[5,4] = x*y
    stiffnessMatrix[6,4] = x*z

    stiffnessMatrix[1,5] = -x*y
    stiffnessMatrix[2,5] = -y^2
    stiffnessMatrix[3,5] = -y*z
    stiffnessMatrix[4,5] = x*y
    stiffnessMatrix[5,5] = y^2
    stiffnessMatrix[6,5] = y*z

    stiffnessMatrix[1,6] = -x*z
    stiffnessMatrix[2,6] = -y*z
    stiffnessMatrix[3,6] = -z^2
    stiffnessMatrix[4,6] = x*z
    stiffnessMatrix[5,6] = y*z
    stiffnessMatrix[6,6] = z^2


    stiffnessMatrix .*= stiffnessMultiplier

    return stiffnessMatrix
end


function createGlobalStiffnessMatrix(elements::barElements{T}, nodes) where {T}
    Nnodes = length(nodes)
    globalStiffness = zeros(3Nnodes, 3Nnodes)


    for i in 1:length(elements.nodes)
        id1 = elements.nodes[i][1]
        id2 = elements.nodes[i][2]

        coordinatesNodeA = nodes[ id1 ]
        coordinatesNodeB = nodes[ id2 ]

        elementStiffness = createElementStiffnessMatrix(
            coordinatesNodeA,
            coordinatesNodeB,
            elements.Ymoduli[i],
            elements.Areas[i]
        )

        rangeA = (3*(id1-1)+1):3id1
        rangeB = (3*(id2-1)+1):3id2
        globalStiffness[rangeA, rangeA] += elementStiffness[1:3, 1:3]
        globalStiffness[rangeA, rangeB] += elementStiffness[1:3, 4:6]
        globalStiffness[rangeB, rangeA] += elementStiffness[4:6, 1:3]
        globalStiffness[rangeB, rangeB] += elementStiffness[4:6, 4:6]
    end


    return globalStiffness
end
