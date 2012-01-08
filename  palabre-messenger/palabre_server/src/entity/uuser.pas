unit uUser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson, fpjson, TParseur;

type

     User = class(TInterfacedObject, IJSON)
             private
               pseudo : string;
               passwd : string;
              public
               procedure fromJson(data : String);
               function toJson() : String;

               function getPasswd() : String;
               procedure setPasswd(p : String);
               function getPseudo() : String;
               procedure setPseudo(p : String);

               constructor init();
            end;


implementation

 constructor User.init();
 begin
  pseudo := '';
  passwd :='';
 end;

 function  User.getPasswd() : String;
 begin
  result := passwd;
 end;

 function User.getPseudo() : String;
 begin
  result := pseudo;
 end;

 procedure User.setPasswd(p : String);
 begin
  passwd := p;
 end;

 procedure User.setPseudo(p : String);
 begin
  pseudo := p;
 end;

  procedure User.fromJson(data : String);
   var obj : TJSONOBject;
  begin
   obj := TParser.doParse(data);
   self.setPasswd(obj.Strings['passwd']);
   self.setPseudo(obj.Strings['pseudo']);
  end;


 function User.toJson() : String;
 var obj : TJSONObject;
begin
 obj := TJSONObject.Create;
 obj.Add('pseudo', pseudo);
 obj.add('passwd', passwd);
 result := obj.AsJSON;
end;


end.

