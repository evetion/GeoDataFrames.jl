@setup_workload begin
    ring = [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 0.0)]
    polygon = GI.Polygon([ring])
    point = GI.Point(1.0, 2.0)
    df = DataFrame(int=1:2, float=[1.0, 2.0], string=["a", "b"], geometry=[polygon, polygon])
    points = DataFrame(int=1:2, geometry=[point, point])
    @compile_workload begin
        mktempdir() do dir
            for (i, table) in enumerate((df, points))
                fn = joinpath(dir, "precompile$i.gpkg")
                write(fn, table)
                read(fn)
            end
        end
    end
end
