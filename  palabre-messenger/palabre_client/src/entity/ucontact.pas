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
unit ucontact;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson, ustatus, fpjson, TParseur;
  type
       Contact = class(TInterfacedObject, IJSON)
                   private
                    pseudo : string;
                    privilege : byte;
                    categorie : string;
                    stat : Status;
                   public
                    function getPseudo() : string;
                    function getPrivilege : byte;
                    function getCategorie() : String;
                    function getStatus() : Status;

                    procedure setPseudo(ps : String);
                    procedure setPrivilege(pv : byte);
                    procedure setCategorie(cat : String);
                    procedure setStatus(stat1 : Status);

                    procedure fromJson(data : String);
                    function toJson() : String;

                    constructor init();
                 end;

implementation

constructor Contact.init();
begin
 pseudo := '';
 privilege :=0;
 stat := Status.init();
 categorie := '';
end;

function Contact.getPseudo() : string;
begin
 result := pseudo;
end;

function Contact.getPrivilege : byte;
begin
 result := privilege;
end;

function Contact.getCategorie() : String;
begin
 result := categorie;
end;

function Contact.getStatus() : Status;
begin
 result := stat;
end;

procedure Contact.setPseudo(ps : String);
begin
 pseudo := ps;
end;

procedure Contact.setPrivilege(pv : byte);
begin
 privilege := pv;
end;

procedure Contact.setCategorie(cat : String);
begin
 categorie := cat;
end;

procedure Contact.setStatus(stat1 : Status);
begin
 stat := stat1;
end;

procedure Contact.fromJson(data : String);
 var obj : TJSONOBject;
begin
 obj := TParser.doParse(data);
 self.setCategorie(obj.Strings['categorie']);
 self.setPrivilege(obj.Integers['privilege']);
 self.setPseudo(obj.Strings['pseudo']);
 stat.fromJson(obj.Objects['stat'].AsJSON);
end;

function Contact.toJson() : String;
 var obj : TJSONObject;
begin
 obj := TJSONObject.Create;
 obj.Add('pseudo', self.pseudo);
 obj.add('privilege', self.privilege);
 obj.add('categorie', self.categorie);
 obj.add('stat', TParser.doParse(self.getStatus().toJson()));
 result := obj.AsJSON;
end;

end.

