//Distribuye el gasto agrícola, tomandolo desde archivos Excel de contabilidad
//El gasto es distribuido anualmente, esto es necesario hacerlo de este modo debido a que se modifica el estado de los cuarteles agrícolas

(AnioVendimia as number)=>
let
    Origen = Table.SelectRows(GastosAgricolas, each Number.From(Text.End([Vendimia],4))= AnioVendimia and [Tipo de registro]="Ejecutado"),
    GCecoGENERAL = Table.SelectRows(Origen, each ([ORIGEN] = "CECO") and ([Finca o general] = "General")),
    #"Adjunta PEP sin TR" = Table.AddColumn(GCecoGENERAL, "ShareGeneral", each ShareGeneral(AnioVendimia)),
    #"Se expandió ShareGeneral" = Table.ExpandTableColumn(#"Adjunta PEP sin TR", "ShareGeneral", {"PEP", "Share"}, {"PEP", "Share"}),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Se expandió ShareGeneral",{{"Share", type number}}),
    #"Gasto GENERAL Repartido" = Table.AddColumn(#"Tipo cambiado", "Gasto Repartido", each [ARS]*[Share],Number.Type),
    #"Distribuye Cantidades general" = Table.AddColumn(#"Gasto GENERAL Repartido", "Cantidad repartida", each [#"Ctd.reg."]*[Share],Number.Type),
    GCecoPRODUCCION = Table.SelectRows(Origen, each ([ORIGEN] = "CECO") and ([Finca o general] <> "General") and ([TIPO GASTO] = "PRODUCCION") or (([TIPO GASTO] = "PRODUCCION") and ([ORIGEN] = "PEP") and Text.Length([#"Ce.coste/Pep"])<21)),
    #"Texto en mayúsculas" = Table.TransformColumns(GCecoPRODUCCION,{{"Finca o general", Text.Upper, type text}}),
    #"Adjunta los PEP productivos" = Table.NestedJoin(#"Texto en mayúsculas",{"Finca o general"},ShareProd(AnioVendimia),{"FINCA"},"ShareProd",JoinKind.Inner),
    #"Se expandió ShareProd2018" = Table.ExpandTableColumn(#"Adjunta los PEP productivos", "ShareProd", {"PEP", "Share"}, {"PEP", "Share"}),
    #"Gasto PRODUCTIVOS Repartido" = Table.AddColumn(#"Se expandió ShareProd2018", "Gasto Repartido", each [ARS]*[Share]),
    #"Distribuye Cantidades Productivos" = Table.AddColumn(#"Gasto PRODUCTIVOS Repartido", "Cantidad repartida", each [#"Ctd.reg."]*[Share]),
    #"Finca o general Formato" = Table.TransformColumns(#"Distribuye Cantidades Productivos",{{"Finca o general", Text.Proper, type text}}),
    #"Reemplaza Del por del" = Table.ReplaceValue(#"Finca o general Formato","Del","del",Replacer.ReplaceText,{"Finca o general"}),
    GCecoDESARROLLO = Table.SelectRows(Origen, each ([ORIGEN] = "CECO") and ([Finca o general] <> "General") and ([TIPO GASTO] = "DESARROLLO") or (([TIPO GASTO] = "DESARROLLO") and ([ORIGEN] = "PEP") and Text.Length([#"Ce.coste/Pep"])<21)),
    #"Texto en mayúsculas1" = Table.TransformColumns(GCecoDESARROLLO,{{"Finca o general", Text.Upper, type text}}),
    #"Adjunta PEP en desarrollo" = Table.NestedJoin(#"Texto en mayúsculas1",{"Finca o general"},ShareDes(AnioVendimia),{"FINCA"},"ShareDes",JoinKind.LeftOuter),
    #"Se expandió ShareDes2019" = Table.ExpandTableColumn(#"Adjunta PEP en desarrollo", "ShareDes", {"PEP", "Share"}, {"PEP", "Share"}),
    #"Gasto DESARROLLO Repartido" = Table.AddColumn(#"Se expandió ShareDes2019", "Gasto Repartido", each [ARS]*[Share],Number.Type),
    #"Distribuye Cantidades Desarrollo" = Table.AddColumn(#"Gasto DESARROLLO Repartido", "Cantidad repartida", each [#"Ctd.reg."]*[Share],Number.Type),
    #"Formatea Finca o general" = Table.TransformColumns(#"Distribuye Cantidades Desarrollo",{{"Finca o general", Text.Proper, type text}}),
    #"Reemplaza  Del por del" = Table.ReplaceValue(#"Formatea Finca o general","Del","del",Replacer.ReplaceText,{"Finca o general"}),
    GastosPEP = Table.SelectRows(Origen, each ([ORIGEN] = "PEP") and Text.Length([#"Ce.coste/Pep"])=21),
    CambiaEncabezado = Table.RenameColumns(GastosPEP,{{"ARS", "Gasto Repartido"}, {"Ctd.reg.", "Cantidad repartida"}}),
    AgregaPEPGASTOSPEP = Table.AddColumn(CambiaEncabezado, "PEP", each [#"Ce.coste/Pep"]),
    #"Consulta anexada" = Table.Combine({#"Distribuye Cantidades general", #"Reemplaza Del por del",#"Reemplaza  Del por del",AgregaPEPGASTOSPEP}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Consulta anexada",{"ARS", "Ctd.reg."}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Columnas quitadas",{{"Gasto Repartido", "ARS"}, {"Cantidad repartida", "Ctd.reg."}}),
    TipoNumber = Table.TransformColumnTypes(#"Columnas con nombre cambiado",{{"ARS", type number}, {"Ctd.reg.", type number}})
in
    TipoNumber