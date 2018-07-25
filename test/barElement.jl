using Test
using StaticArrayUtils
using FEM


function testi()
    nodes = [
        SVec3(0.0),
        SVec3(2.0, 3.0, 6.0)
    ]


    element = barElements(
        [SVec2(1,2)],
        [343.0],
        [10.0]
    )


    K = createElementStiffnessMatrix(
        nodes[ element.nodes[1][1] ],
        nodes[ element.nodes[1][2] ],
        element.Ymoduli[1],
        element.Areas[1]
    )


    return K
end


@testset begin

    Kfunc = testi()
    Kcheck = [ [40.0, 60.0, 120.0, -40.0, -60.0, -120.0] [60.0, 90.0, 180.0, -60.0, -90.0, -180.0] [120.0, 180.0, 360.0, -120.0, -180.0, -360.0] [-40.0, -60.0, -120.0, 40.0, 60.0, 120.0] [-60.0, -90.0, -180.0, 60.0, 90.0, 180.0] [-120.0, -180.0, -360.0, 120.0, 180.0, 360.0] ]

    @test isapprox(Kfunc, Kcheck)

end # testset
