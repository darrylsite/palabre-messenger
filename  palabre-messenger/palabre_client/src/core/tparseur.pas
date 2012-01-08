{*********************************************************************

    This file is part of the Palabre 1.0 messenger program.
    Copyright (c) 2010 by  Darryl Kpizingui
               http://www.darrylsite.com/

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    This program can be used, modified and distributed as long as you can
    specify that Darryl Kpizingui is the author of the source code your project
    has derived from.

    For anything, Darryl Kpizingui can be reached at nabster@darrylsite.com

 **********************************************************************}
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

