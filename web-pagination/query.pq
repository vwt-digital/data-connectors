let
    Config = Json.Document(File.Contents("C:\Users\John\Documents\config.json")),
    BaseUrl = Config[BaseUrl],
    Token = Config[Token],
    Query = Config[Query],

    GetJson = (url) =>
        let Url = BaseUrl & url & "&key=" & Token,
            raw      = Web.Contents(Url),
            json     = Json.Document(raw),
            results  = try json[results] otherwise {},
            next     = try json[next] otherwise "",
            response = [Results=results, Next=next]
        in  
            response,

    Data = List.Generate(
        () => [res = GetJson(Query)],
        each List.Count([res][Results]) > 0,
        each [res = GetJson([res][Next])],
        each [res][Results]
    ),

    Combined = List.Combine(Data),
    Schema = Record.FieldNames(List.First(Combined)),
    Converted = Table.FromList(Combined, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Expanded = Table.ExpandRecordColumn(Converted, "Column1", Schema, Schema)
in
    Expanded
