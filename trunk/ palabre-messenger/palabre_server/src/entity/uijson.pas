unit uijson;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
 type

  IJson = interface
            procedure fromJson(data : String);
            function toJson() : String;
          end;

implementation

end.

