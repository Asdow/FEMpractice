module FEM

import LinearAlgebra
global const linAlg = LinearAlgebra

using StaticArrayUtils



include("barElement.jl")

export barElements, createElementStiffnessMatrix


include("Graphics.jl")




end # module
