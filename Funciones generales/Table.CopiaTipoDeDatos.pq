//Copia el tipo de dato de los encabezados de otro paso o tabla al paso actual de la consulta.
//(Tabla as table,TablaEjemplo as table) - Los campos deben llamarse igual para ser identificados y modificados.
(Tabla as table,TablaEjemplo as table) =>
let
    ObtieneInfoDeTablaEjemplo = Table.Schema(TablaEjemplo),
    DejaNombreYTipo = Table.SelectColumns(ObtieneInfoDeTablaEjemplo,{"Name", "Kind"}),
    ModificaKindPorTipo = Table.RenameColumns(DejaNombreYTipo,{{"Kind", "Tipo"}}),
    IdentificaTipoDato = Table.AddColumn(ModificaKindPorTipo, "TipoDeDato", each if [Tipo]="number" then
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
    MantieneColumnasUtiles = Table.SelectColumns(IdentificaTipoDato,{"Name", "TipoDeDato"}),
    FiltraNulos = Table.SelectRows(MantieneColumnasUtiles, each ([TipoDeDato] <> null)),
    EliminaEspaciosEjemplo = Table.TransformColumns(FiltraNulos, {{"Name", Text.Trim, type text}}),       //Elimina espacios en los nombres estandarizados.          
    EliminaEspaciosColumns = List.Transform(Table.ColumnNames(Tabla),Text.Trim),
    EncuentraColumnasCoincidentes = List.Intersect({Table.Column(EliminaEspaciosEjemplo,"Name"),EliminaEspaciosColumns}),
    ConvierteListaEnTabla = Table.FromList(EncuentraColumnasCoincidentes, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    LeftJoinTipoDeDato = Table.NestedJoin(ConvierteListaEnTabla,{"Column1"},MantieneColumnasUtiles,{"Name"},"TipoDeDato",JoinKind.LeftOuter),
    ExpandeTipoDeDato = Table.ExpandTableColumn(LeftJoinTipoDeDato, "TipoDeDato", {"TipoDeDato"}, {"TipoDeDato"}),
    GeneraLista = Table.ToRows(ExpandeTipoDeDato),
    TransformaTipoDeDato = Table.TransformColumnTypes(Tabla,GeneraLista)
in
    TransformaTipoDeDato