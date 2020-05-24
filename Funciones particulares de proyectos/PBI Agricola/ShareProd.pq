(AnioVendimia as number)=>
let
    Origen = #"Maestro PEPs",
    SeleccionaVendimiayDejaVPyPP = Table.SelectRows(Origen, each ([ED] = "PP" or [ED] = "VP") and (Number.From(Text.End([Vendimia],4))= AnioVendimia)),
    #"Total HAS x Finca" = Table.Group(SeleccionaVendimiayDejaVPyPP, {"FINCA"}, {{"TOT HAS", each List.Sum([HAS]), type number}}),
    #"Adjunta PEP y HAS" = Table.NestedJoin(#"Total HAS x Finca",{"FINCA"},SeleccionaVendimiayDejaVPyPP,{"FINCA"},"Total HAS x Finca",JoinKind.LeftOuter),
    #"Expande PEP y HAS" = Table.ExpandTableColumn(#"Adjunta PEP y HAS", "Total HAS x Finca", {"PEP", "HAS"}, {"PEP", "HAS"}),
    #"Calcula Share" = Table.AddColumn(#"Expande PEP y HAS", "Share", each [HAS]/[TOT HAS],Number.Type)
in
    #"Calcula Share"