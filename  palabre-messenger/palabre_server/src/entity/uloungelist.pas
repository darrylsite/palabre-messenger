unit ULoungeList;

{$mode objfpc}{$H+}

interface

uses  Classes, SysUtils, contnrs, ulounge, fpjson, TParseur, uijson, ucontact;

  type
       TLoungeList = class(TInterfacedObject, IJSON)
                       private
                          liste : TFPObjectList;
                       public
                         constructor init();
                         procedure addElement(c : TLounge);
                         function getElement(i : integer) : TLounge;
                         function existElement(c : TLounge) : boolean;
                         procedure removeElement(c : TLounge);
                         function length() : integer;

                         procedure fromJson(data : String);
                         function toJson() : String;
                     end;

implementation

constructor TLoungeList.init();
begin
 liste := TFPObjectList.Create;
end;

function TLoungeList.length() : integer;
begin
  result := liste.count;
end;

procedure TLoungeList.addElement(c : TLounge);
begin
 liste.Add(c);
end;

function TLoungeList.getElement(i : integer) : TLounge;
begin
 result := TLounge(liste.Items[i]) ;
end;

function TLoungeList.existElement(c : TLounge) : boolean;
 var b : boolean;
 i : integer;
begin
 b := false;
 for i:=0 to self.length()-1 do
  if (self.getElement(i)=c) then
   b := true;
 result := b;
end;

procedure TLoungeList.removeElement(c : TLounge);
begin
 liste.Remove(c);
end;


procedure TLoungeList.fromJson(data : String);
var obj : TJSONOBject;
    arr : TJSONArray;
    i : integer;
    c : TLounge;
begin
 obj := TParser.doParse(data);
 arr := obj.Arrays['liste'];
 for i:=0 to arr.Count -1 do
  begin
  c := TLounge.init();
  c.fromJson(arr.Objects[i].AsJSON);
  self.addElement(c);
  end;
end;

function TLoungeList.toJson() : String;
 var obj : TJSONObject;
     arr : TJSONArray;
     i : integer;
begin
 obj := TJSONObject.Create;
 arr := TJSONArray.Create;
 for i:=0 to self.length()-1 do
  begin
   arr.Add(TParser.doParse(self.getElement(i).toJson()));
  end;
  obj.Add('liste', arr);
  result := obj.AsJSON;
end;


end.
