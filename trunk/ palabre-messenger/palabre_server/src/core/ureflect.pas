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
unit ureflect;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, hashtable;

  type
        TFExec = function(param : string) : String of object;
        TPExec = procedure(param : string) of object;
        MethodNotFoundException  = class(Exception);

       TReflect = class
                   private
                     liste : THash;
                   public
                     constructor init();
                     procedure addElement(name : string; m : TMethod);
                     function getElement(name : string) : TMethod;
                     function existElement(name : string) : boolean;
                     function length() : integer;

                     procedure PExec(name : String; param : String);
                     function FExec(name : String; param : String) : String;

                  end;



implementation


constructor TReflect.init();
begin
 liste := THash.create();
end;

function TReflect.length() : integer;
begin
  result := 0;
end;

procedure TReflect.addElement(name : string; m : TMethod);
 var l : longint;
begin
  liste.store(LowerCase(name), m, l);
  if(l<>0) then
   write('erreur hash');
end;


function TReflect.getElement(name : string) : TMethod;
 var mm : TMethod;
begin
 liste.fetch(LowerCase(name), mm);
 result := mm;
end;

function TReflect.existElement(name : string) : boolean;
 var b : boolean;
 i : integer;
begin
 result :=liste.exists(LowerCase(name));
end;

procedure TReflect.PExec(name : String; param : String);
var
   Routine: TMethod;
   Exec: TPExec;
begin
   routine :=  self.getElement(LowerCase(name));
   if NOT Assigned(Routine.Code) then
     raise MethodNotFoundException.Create('Can not create dynamic method');
   Exec := TPExec(Routine) ;
   Exec(param);
end;

function  TReflect.FExec(name : String; param : String) : String;
var
   Routine: TMethod;
   Exec: TFExec;
begin
   Routine := self.getElement(LowerCase(name));
   if NOT Assigned(Routine.Code) then
     raise MethodNotFoundException.Create('Can not create dynamic method');
   Exec := TFExec(Routine) ;
   result := Exec(param);
end;

end.

