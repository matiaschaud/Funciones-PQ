//Renombra encabezados de una tabla, si no encuentra alguna no hace nada (MissingField.Ignore)
//(tabla as table, renombres as list) - renombre es una lista de listas {{nombre viejo},{nombre nuevo}}
(tabla as table, renombres as list) =>
let
    #"Saca espacios en nombre columna" = Table.TransformColumnNames(tabla,Text.Trim),
    #"Estandariza encabezados" = Table.RenameColumns(#"Saca espacios en nombre columna",renombres,MissingField.Ignore)

in
    #"Estandariza encabezados"