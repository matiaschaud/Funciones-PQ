//Estandariza el tipo de datos de los campos, según configuración predeterminada en archivo STDCampos (Q:\CONTROL DE GESTION\Repositorios\Archivos utilizados por las funciones).
//(Tabla as table) - Tabla a estandarizar
(Tabla as table) =>
let
    Origen = Excel.Workbook(File.Contents("Q:\CONTROL DE GESTION\Repositorios\Archivos utilizados por las funciones\STDCampos.xlsx"), null, true),
    TiposDatosSTD = Origen{[Item="TiposDatosSTD",Kind="Table"]}[Data],
    #"Tipo cambiado" = Table.TransformColumnTypes(TiposDatosSTD ,{{"Tipo", type text}, {"Nombre de columna", type text}}),
    TipoMinuscula = Table.TransformColumns(#"Tipo cambiado",{{"Tipo", Text.Lower, type text}}),                        //Hace minúsculas los tipos de texto para después comparar en los condicionales
    EliminaEspacios = Table.TransformColumns(TipoMinuscula, {{"Nombre de columna", Text.Trim, type text}, 	       //Elimina espacios en los nombres estandarizados.
                                                                {"Tipo", Text.Trim, type text}}),
    IdentificaTipoDato = Table.AddColumn(EliminaEspacios, "TipoDeDato", each if [Tipo]="number" then
Value.Type(1)
else if [Tipo]="text" then
Value.Type("A")
else if [Tipo]="date" then
Value.Type(Date.From(1))
else if [Tipo]="datetime" then
Value.Type(DateTime.From(1))
else if [Tipo]="datetimezone" then
Value.Type(DateTimeZone.From(1))
else if [Tipo]="duration" then
Value.Type(Duration.From(1))
else if [Tipo]="time" then
Value.Type(Time.From("00:00:00"))
else if [Tipo]="logical" then
Value.Type(Logical.From(true))
else null,Text.Type),
    #"Indice agregado" = Table.AddIndexColumn(IdentificaTipoDato, "Indice", 0, 1),                                            //Agrega índice para después filtrar.
    EliminaEspaciosColumns = List.Transform(Table.ColumnNames(Tabla),Text.Trim),	       //Elimina espacios en los campos de la Tabla a modificar de tipos.
    EncuentraIndiceAFiltrar = List.PositionOfAny(Table.Column(#"Indice agregado","Nombre de columna"),EliminaEspaciosColumns,Table.ColumnCount(Tabla)),      //Identifica los índices a filtrar.
    FiltraCampos = if EncuentraIndiceAFiltrar = -1 then "No se encontraron coincidencias" else 
                         if EncuentraIndiceAFiltrar = 0 then Table.SelectRows(#"Indice agregado",(each List.Contains({0},[Indice]))) else             
                         Table.SelectRows(#"Indice agregado",(each List.Contains(EncuentraIndiceAFiltrar,[Indice]))),               //Filtra según lo identificado.
    MantieneColumnasUtiles = Table.SelectColumns(FiltraCampos,{"Nombre de columna", "TipoDeDato"}),                                   //Deja solo el nombre de las columnas y el tipo de datos.
    GeneraLista= Table.ToRows(MantieneColumnasUtiles),                                                                               //Genera lista con formato para incluir en la función posterior
    EstandarizaTipoDatos = Table.TransformColumnTypes(Tabla,GeneraLista)
in
    EstandarizaTipoDatos