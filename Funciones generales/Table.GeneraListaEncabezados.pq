//Genera una lista de listas con formato para ingresar en la función "EstandarizaEncabezados"
//(tabla as table) - La tabla debe tener dos campos, A la izquierda el nombre viejo y a la derecha el nombre nuevo correspondiente.
(tabla as table) =>
let  
    NamesBuffered = List.Buffer(Table.ColumnNames(tabla) ),
    NewNames = {"Nombre Viejo", "Nombre Nuevo"},
    CambiaEncabezados= Table.RenameColumns(tabla,
                                  List.Zip( { NamesBuffered, NewNames } ) ),
    EliminaEspacios = Table.TransformColumns(CambiaEncabezados,{{"Nombre Viejo", Text.Trim, type text}, 
                                                                {"Nombre Nuevo", Text.Trim, type text}}),
    EliminaDuplicados = Table.Distinct(EliminaEspacios),
    EliminaNulls= Table.SelectRows(EliminaDuplicados , each [Nombre Nuevo] <> null),
    GeneraLista = Table.ToRows(EliminaNulls)
in
    GeneraLista