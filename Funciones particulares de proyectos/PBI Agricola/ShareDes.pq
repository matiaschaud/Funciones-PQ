(AnioVendimia as number)=>
let
    Origen = #"Maestro PEPs",
    SeleccionaVendimiayDeja = Table.SelectRows(Origen, each (Number.From(Text.End([Vendimia],4))= AnioVendimia) and ([ED] <> "PP" and [ED] <> "TR" and [ED] <> "VP")),
    #"Total HAS x Finca" = Table.Group(SeleccionaVendimiayDeja, {"FINCA"}, {{"TOT HAS", each List.Sum([HAS]), type number}}),
    #"Adjunta PEP y HAS" = Table.NestedJoin(#"Total HAS x Finca",{"FINCA"},SeleccionaVendimiayDeja,{"FINCA"},"Total HAS x Finca",JoinKind.LeftOuter),
    #"Expande PEP y HAS" = Table.ExpandTableColumn(#"Adjunta PEP y HAS", "Total HAS x Finca", {"PEP", "HAS"}, {"PEP", "HAS"}),
    #"Calcula Share" = Table.AddColumn(#"Expande PEP y HAS", "Share", each [HAS]/[TOT HAS],Number.Type)
in
    #"Calcula Share"