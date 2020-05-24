//Busca el listado de relacion de nombres y estandariza el nombre de los encabezados de los campos usados por los archivos de CG (Q:\CONTROL DE GESTION\Repositorios\Archivos utilizados por las funciones).
//(tabla as table) - Solo debe introducirse el nombre de la tabla.

(tabla as table) =>

let

//Paso 1: generar lista de listas (formato para ingresar en el parametro 2 de la función Table.RenameColumns)

    Origen = Excel.Workbook(File.Contents("Q:\CONTROL DE GESTION\Repositorios\Archivos utilizados por las funciones\STDCampos.xlsx"),
                null, true){[Item="RenombresSTD",Kind="Table"]}[Data],
    NamesBuffered = List.Buffer(Table.ColumnNames(Origen) ),
    NewNames = {"Nombre Viejo", "Nombre Nuevo","Otro"},
    CambiaEncabezados= Table.RenameColumns(Origen,List.Zip( { NamesBuffered, NewNames } ) ),
    EliminaColumnaExtra= Table.SelectColumns(CambiaEncabezados,{"Nombre Viejo", "Nombre Nuevo"}),        // Elimina la columna que se usa para explicar cada campo.
    EliminaEspacios = Table.TransformColumns(EliminaColumnaExtra,{{"Nombre Viejo", Text.Trim, type text}, 
                                                                {"Nombre Nuevo", Text.Trim, type text}}),
    EliminaDuplicados = Table.Distinct(EliminaEspacios),
    EliminaNulls= Table.SelectRows(EliminaDuplicados , each [Nombre Nuevo] <> ""),
    GeneraLista = Table.ToRows(EliminaNulls),

//Paso 2: modifica el nombre de los encabezados.

    EliminaEspacios2 = Table.TransformColumnNames(tabla,Text.Trim),
    EstandarizaEncabezados = Table.RenameColumns(EliminaEspacios2,GeneraLista,MissingField.Ignore)

in
    EstandarizaEncabezados