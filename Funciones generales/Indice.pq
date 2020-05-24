//Brinda información de las funciones PQ custom creadas, busca el ejemplo en el repositorio del Lanshare.
//RutaRepositorio sirve para agregar la ruta del repositorio en forma manual
(optional RutaRepositorio as text) =>
let
    Seleccion = if RutaRepositorio = null then "\\192.168.223.7\Lanshare\CONTROL DE GESTION\Repositorios\funcionesPQ\Funciones generales"
    else RutaRepositorio,   
    Origen = Folder.Files(Seleccion),
    ObtieneSoloPQ = Table.SelectRows(Origen, each ([Extension] = ".pq")),
    OrdenaAZ = Table.Sort(ObtieneSoloPQ,{{"Name", Order.Ascending}}),
    AgregaFuncionalidad = Table.AddColumn(OrdenaAZ, "Funcionalidad", each if Text.Start(Lines.FromBinary([Content], null, null, 65001){0},2) = "//" then Lines.FromBinary([Content], null, null, 65001){0} else null,Text.Type),
    AgregaInfoAdicional = Table.AddColumn(AgregaFuncionalidad, "Info adicional", each if Text.Start(Lines.FromBinary([Content], null, null, 65001){1},2) = "//" then Lines.FromBinary([Content], null, null, 65001){1} else null,Text.Type),
    #"Saca//Funcionalidad" = Table.ReplaceValue(AgregaInfoAdicional,"//","",Replacer.ReplaceText,{"Funcionalidad"}),
    #"Saca//InfoAdicional" = Table.ReplaceValue(#"Saca//Funcionalidad","//","",Replacer.ReplaceText,{"Info adicional"}),
    MantieneColumnasUtiles = Table.SelectColumns(#"Saca//InfoAdicional",{"Name", "Funcionalidad","Info adicional", "Date modified", "Date created"}),
    #"Columnas reordenadas" = Table.ReorderColumns(MantieneColumnasUtiles,{"Name", "Funcionalidad", "Info adicional", "Date modified", "Date created"})
in
    #"Columnas reordenadas"