unit ulounge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson, fpjson, TParseur;

  type

  TLounge = class(TInterfacedObject, IJson)
            private
             name : String;
             id : integer;
             privilege : byte;
            public
             constructor init();
             procedure setName(name1 : String);
             procedure setId(id1 : integer);
             procedure setPrivilege(pv : byte);

             function getName(): String;
             function getId(): integer;
             function getPrivilege() : byte;

             procedure fromJson(data : String);
             function toJson() : String;
           end;

implementation

constructor TLounge.init();
begin
 id := 0;
 name :='public';
 privilege := 0;
end;

procedure TLounge.setName(name1 : String);
begin
 name := name1;
end;

procedure TLounge.setId(id1 : integer);
begin
 id := id1;
end;

procedure TLounge.setPrivilege(pv : byte);
begin
 self.privilege:= pv;
end;

function TLounge.getName(): String;
begin
 result := name;
end;

function TLounge.getId(): integer;
begin
 result := id;
end;

function TLounge.getPrivilege() : byte;
begin
 result := privilege;
end;

procedure TLounge.fromJson(data : String);
var obj : TJSONOBject;
begin
 obj := TParser.doParse(data);
 self.setId(obj.Integers['id']);
 self.setPrivilege(obj.Integers['privilege']);
 self.setName(obj.Strings['name']);
end;

function TLounge.toJson() : String;
var obj : TJSONObject;
begin
 obj := TJSONObject.Create;
 obj.Add('id', id);
 obj.add('privilege', privilege);
 obj.add('name', name);
 result := obj.AsJSON;
end;

end.

