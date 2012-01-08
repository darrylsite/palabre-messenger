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
unit UContactList;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, ucontact, fpjson, TParseur, uijson;

  type
       ContactList = class(TInterfacedObject, IJSON)
                       private
                          liste : TFPObjectList;
                       public
                         constructor init();
                         procedure addElement(c : Contact);
                         function getElement(i : integer) : Contact;
                         function existElement(c : Contact) : boolean;
                         procedure removeElement(c : Contact);
                         function length() : integer;

                         procedure fromJson(data : String);
                         function toJson() : String;
                     end;

implementation

constructor ContactList.init();
begin
 liste := TFPObjectList.Create;
end;

function ContactList.length() : integer;
begin
  result := liste.count;
end;

procedure ContactList.addElement(c : Contact);
begin
 liste.Add(c);
end;

function ContactList.getElement(i : integer) : Contact;
begin
 result := Contact(liste.Items[i]) ;
end;

function ContactList.existElement(c : Contact) : boolean;
 var b : boolean;
 i : integer;
begin
 b := false;
 for i:=0 to self.length()-1 do
  if (self.getElement(i)=c) then
   b := true;
 result := b;
end;

procedure ContactList.removeElement(c : Contact);
begin
 liste.Remove(c);
end;


procedure ContactList.fromJson(data : String);
var obj : TJSONOBject;
    arr : TJSONArray;
    i : integer;
    c : Contact;
begin
 obj := TParser.doParse(data);
 arr := obj.Arrays['liste'];
 for i:=0 to arr.Count -1 do
  begin
  c := Contact.init();
  c.fromJson(arr.Objects[i].AsJSON);
  self.addElement(c);
  end;
end;

function ContactList.toJson() : String;
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

