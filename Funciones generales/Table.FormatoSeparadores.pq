//Concatena una lista (luego de eliminar duplicados), con delimitadores medios y extremos
//(Tabla as table,columna as text,optional DelimitadorMedio as text,optional DelimitadorExtremos as text) - Tabla que contiene el campo a concatenar, columna a concatenar, delimitador medio (por defecto ',' ) y delimitadorExtremo (por defecto ' )
(Tabla as table,columna as text,optional DelimitadorMedio as text,optional DelimitadorExtremos as text)=>
let
    ObtieneLista = Table.Column(Tabla,columna),
    EliminaDuplicados= List.Distinct(ObtieneLista),
    OrdenAZ= List.Sort(EliminaDuplicados),
    CombinaLista = if DelimitadorMedio is null then Text.Combine(OrdenAZ, "','") else Text.Combine(OrdenAZ, DelimitadorMedio),
    //El próximo paso agrega comillas simples al principio y al final del texto
    ListForSQL = if DelimitadorExtremos is null then Text.Insert(Text.Insert(CombinaLista,0,"'"),Text.Length(CombinaLista)+1,"'") 
                 else Text.Insert(Text.Insert(CombinaLista,0,DelimitadorExtremos),Text.Length(CombinaLista)+1,DelimitadorExtremos)
in
    ListForSQL