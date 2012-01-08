unit uilist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson;
  type

    IList = interface(IJson)
               procedure addElement(c : TObject);
               function getElement(i : integer) : TObject;
               function existElement(c : TObject) : boolean;
               procedure removeElement(c : TObject);
            end;

implementation

end.

