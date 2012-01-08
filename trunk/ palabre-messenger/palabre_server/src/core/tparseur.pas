unit TParseur;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, jsonparser, fpjson;
type

    TParser = class
                public
                 class function DoParse(s : string) : TJSONObject;
              end;


implementation

class function TParser.DoParse(s : string) : TJSONObject;
Var
  js : TJSONData;
  parse : TJSONParser;
   obj : TJSONObject;
begin
    Try
      parse :=TJSONParser.Create(s);
      js:=parse.Parse;
      If Assigned(js) then
        begin
         obj := TJSONObject(js);
         DoParse := obj;
        end
      else
        Writeln('Pas de données disponibles');
    Finally
      //FreeAndNil(js);
  end;
end;

end.

