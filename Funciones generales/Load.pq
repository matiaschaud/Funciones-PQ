//Sirve para utilizar funciones contenidos en repositorios configurados.
//(fnName as text, optional BasePath as text) - fnname debe estar entre " ya que se ingresa como texto, y BasePath es la dirección del repositorio, por defecto busca en la computadora, sino en la red y por último en github.
(fnName as text, optional BasePath as text) as function =>
// IvanBond version

    let
    //If you wish to hardcode the path to load the queries from, you can edit the following line:
    DefaultPath = "\\192.168.223.7\Lanshare\CONTROL DE GESTION\Repositorios\funcionesPQ\Funciones generales",
    GitHubPath = "https://raw.githubusercontent.com/Control-de-GestionTRV/funcionesPQ/master/Funciones generales/",
    
    BasePath = if (BasePath <> null) then BasePath else DefaultPath,
    Path = BasePath & (if Text.End(BasePath, 1) <> "\" then "\" else ""),
    File = Path & fnName & ".pq",
    
    Function = try Expression.Evaluate(Text.Replace(fnName, ".", "_"), #shared)  //if already imported into the workbook just use the existing one
    otherwise try Expression.Evaluate(Text.FromBinary(Binary.Buffer(File.Contents(File))), #shared) //if not imported yet try loading it from the text file in the folder
    otherwise Expression.Evaluate( Text.FromBinary(Binary.Buffer(Web.Contents(GitHubPath & fnName & ".pq"))), #shared) // if folder not found - take from GitHubPath
in
    Function
