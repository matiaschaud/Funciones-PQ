(AnioVendimia as number)=>
let
    Origen = #"Maestro PEPs",
    SeleccionaVendimiayEliminaTR = Table.SelectRows(Origen, each (Number.From(Text.End([Vendimia],4))= AnioVendimia) and ([ED] <> "TR")),
    CalculaShare = Table.AddColumn(SeleccionaVendimiayEliminaTR, "Share", each [HAS]/List.Sum(Table.Column(SeleccionaVendimiayEliminaTR,"HAS")),Number.Type),
    OtrasColumnasQuitadas = Table.SelectColumns(#"CalculaShare",{"PEP", "PRODUCCION PPTO (Kg)", "PRODUCCION REAL (Kg)", "Share"})
in
    OtrasColumnasQuitadas