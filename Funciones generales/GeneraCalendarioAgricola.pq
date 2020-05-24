//Genera tabla calendario con campos adicionales (incluye Vendimia y periodo agrícola), desde una fecha dada hasta el ultimo dia del calendario agricola.
//(AnioDesde_Vendimia as number) - Año de Vendimia desde el cual comenzará el calendario

(AnioDesde_Vendimia as number)=>
let
    Source = List.Dates(#date(AnioDesde_Vendimia-1,5,1), Number.From(#date(Date.Year(DateTime.LocalNow())+1,5,1))- Number.From(#date(AnioDesde_Vendimia-1,5,1)) ,#duration(1,0,0,0)),
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "Date"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Date", type date}}),
    #"Día insertado" = Table.AddColumn(#"Changed Type", "Día", each Date.Day([Date]), Int64.Type),
    #"Día de la semana insertado" = Table.AddColumn(#"Día insertado", "Día de la semana", each Date.DayOfWeek([Date]), Int64.Type),
    #"Día del año insertado" = Table.AddColumn(#"Día de la semana insertado", "Día del año", each Date.DayOfYear([Date]), Int64.Type),
    #"Nombre del día insertado" = Table.AddColumn(#"Día del año insertado", "Nombre del día", each Date.DayOfWeekName([Date]), type text),
    #"Semana del mes insertada" = Table.AddColumn(#"Nombre del día insertado", "Semana del mes", each Date.WeekOfMonth([Date]), Int64.Type),
    #"Semana del año insertada" = Table.AddColumn(#"Semana del mes insertada", "Semana del año", each Date.WeekOfYear([Date]), Int64.Type),
    #"Trimestre insertado" = Table.AddColumn(#"Semana del año insertada", "Trimestre", each Date.QuarterOfYear([Date]), Int64.Type),
    #"Mes insertado" = Table.AddColumn(#"Trimestre insertado", "Mes", each Date.Month([Date]), Int64.Type),
    #"Nombre del mes insertado" = Table.AddColumn(#"Mes insertado", "Nombre del mes", each Date.MonthName([Date]), type text),
    #"Días insertados en mes" = Table.AddColumn(#"Nombre del mes insertado", "Días del mes", each Date.DaysInMonth([Date]), Int64.Type),
    #"Año insertado" = Table.AddColumn(#"Días insertados en mes", "Año", each Date.Year([Date]), Int64.Type),
    #"Año Vendimia" = Table.AddColumn(#"Año insertado", "Año Vendimia", each if [Mes]>4 then [Año]+1 else [Año],Int64.Type),
    #"Added Custom" = Table.AddColumn(#"Año Vendimia", "Periodo Agricola", each if [Mes]>4 then [Mes]-4 else [Mes]+8,Int64.Type)
in
    #"Added Custom"