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
unit uUserModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uContactList, uContact, fpjson, TParseur, jsonparser;

  type
       TUserModel = class
                      data : TJSONObject;
                      dbPath : string; static;
                      procedure loadData();
                      procedure saveData();
                      Procedure ParseFile (FileName : String);
                     public
                      constructor init();
                      procedure createUser(usr : string; pwd : string);
                      function  existUser(usr : string) : boolean;
                      procedure setPassword(usr : string; pwd : string);
                      function  getPasswd(usr : string) : string;
                      function  verifLogin(login : string; pwd : string) : boolean;
                      procedure addFriend(usr : string; cont : Contact);
                      function  getFriends(usr : string) : ContactList;
                      procedure addInvitation(usr : string; cont : Contact);
                      function getInvitations(usr : string) : ContactList;
                      procedure deleteInvitation(usr : string; cont : Contact);
                    end;

implementation

constructor TUserModel.init();
begin
 loadData();
end;

procedure TUserModel.createUser(usr : string; pwd : string);
var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
begin
  obj := TJSONObject.create();
  obj.Add('pseudo', usr);
  obj.add('passwd', pwd);
  obj.Add('friends', TJSONArray.Create());
  obj.Add('invite', TJSONArray.Create());

  data.Arrays['palabre'].Add(obj);
  saveData();
end;

function TUserModel.existUser(usr : string) : boolean;
var arr : TJSONArray;
     i : Word;
     b : boolean ;
begin
  arr := data.Arrays['palabre'];
  b := false;
  if(arr.Count>0) then
  for i:=0 to (arr.Count-1) do
  begin
   writeln(i);
   if (arr.Objects[i].Strings['pseudo']=usr) then
     b := true;
  end;
end;

procedure TUserModel.setPassword(usr : string; pwd : string);
var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
begin
  obj := nil;
  arr := data.Arrays['palabre'];
  for i:=0 to arr.Count-1 do
   if (arr.Objects[i].Strings['pseudo']=usr) then
     obj := arr.Objects[i];
  if (obj<>nil) then
  begin
   obj.Arrays['passwd'].Add(pwd);
  end;
  saveData();
end;

function TUserModel.getPasswd(usr : string) : string;
var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
begin
 result := '';
  obj := nil;
  arr := data.Arrays['palabre'];
  if(arr.Count>0) then
   for i:=0 to arr.Count-1 do
    if (arr.Objects[i].Strings['pseudo']=usr) then
      obj := arr.Objects[i];

  if (obj<>nil) then
  begin
   result := obj.Strings['passwd'];
  end;
end;

procedure TUserModel.addFriend(usr : string; cont : Contact);
 var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
begin
obj := nil;
  arr := data.Arrays['palabre'];
  for i:=0 to arr.Count-1 do
   if (arr.Objects[i].Strings['pseudo']=usr) then
     obj := arr.Objects[i];
  if (obj<>nil) then
  begin
  obj.Arrays['friends'].Add(cont.getPseudo());
  end;
  saveData();
end;

function  TUserModel.getFriends(usr : string) : ContactList;
 var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
     cls : ContactList;
     cc : Contact;
begin
  result := ContactList.init();
  obj := nil;
  arr := data.Arrays['palabre'];
  if (arr.Count>0) then
  for i:=0 to (arr.Count-1) do
   if (arr.Objects[i].Strings['pseudo']=usr) then
     obj := arr.Objects[i];
  if (obj<>nil) then
  begin
  arr := obj.Arrays['friends'];
  cls := ContactList.init();
  if (arr.Count>0) then
  for i:=0 to arr.Count-1 do
   begin
    cc := Contact.init();
    cc.setPseudo(arr.Strings[i]);
    cls.addElement(cc);
   end;
   result := cls;
  end;
end;

procedure TUserModel.loadData();
begin
 If FileExists(dbPath) then
    ParseFile(dbPath)
  else
   begin
    data := TJSONObject.Create;
    data.Add('palabre', TJSONArray.Create);
    saveData();
   end;
end;

procedure TUserModel.saveData();
 var fichier : textfile;
begin
 assign(fichier, dbPath);
 rewrite(fichier);
 writeln(fichier, data.AsJSON);
 close(fichier);
end;

Procedure TUserModel.ParseFile (FileName : String);
Var
  flux : TFileStream;
  Parseur : TJSONParser;
begin
  flux:=TFileStream.Create(FileName, fmopenRead);
  try
    parseur:=TJSONParser.Create(flux);
    data := TJSONObject(Parseur.Parse);
  finally
  FreeAndNil(parseur);
    flux.Destroy;
  end;
end;

function TUserModel.verifLogin(login : string; pwd : string) : boolean;
begin
  result := false;
  if(self.getPasswd(login)=pwd) then
   result := true;
end;

procedure TUserModel.addInvitation(usr : string; cont : Contact);
var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
begin
obj := nil;
  arr := data.Arrays['palabre'];
  for i:=0 to arr.Count-1 do
   if (arr.Objects[i].Strings['pseudo']=usr) then
     obj := arr.Objects[i];
  if (obj<>nil) then
  begin
  obj.Arrays['invite'].Add(cont.getPseudo());
  end;
  saveData();
end;

function TUserModel.getInvitations(usr : string) : ContactList;
 var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
     cls : ContactList;
     cc : Contact;
begin
  obj := nil;
  result := ContactList.init();
  arr := data.Arrays['palabre'];
  if (arr.Count>0) then
  for i:=0 to arr.Count-1 do
   if (arr.Objects[i].Strings['pseudo']=usr) then
     obj := arr.Objects[i];
  if (obj<>nil) then
  begin
  arr := obj.Arrays['invite'];
  cls := ContactList.init();
  if (arr.Count>0) then
  for i:=0 to arr.Count-1 do
   begin
    cc := Contact.init();
    cc.setPseudo(arr.Strings[i]);
    cls.addElement(cc);
   end;
   result := cls;
  end;
end;

procedure TUserModel.deleteInvitation(usr : string; cont : Contact);
var arr : TJSONArray;
     i : Word;
     obj : TJSONObject;
begin
  obj := nil;
  arr := data.Arrays['palabre'];
  for i:=0 to arr.Count-1 do
   if (arr.Objects[i].Strings['pseudo']=usr) then
     obj := arr.Objects[i];
  if (obj<>nil) then
  begin
  arr := obj.Arrays['invite'];
  for i:=0 to arr.Count-1 do
   if(arr.Strings[i]=cont.getPseudo()) then
    arr.Delete(i);
  end;
end;

begin
 TUserModel.dbPath := 'dbpalabre.jsn';
end.

