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
unit uRPCStube;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, myApplication, ucontact, uijson, uilist, ulounge, ustatus, uuser,
  UContactList, UMessage, urpc, ULoungeList, fpjson, TParseur;

  type
      TRPCStube = class(TInterfacedObject,  TIRPC)
                   private
                    function getCorpseMsg() : TJSONObject;
                    function getMethodResponse(msg : String) : TJSONObject;
                    function analyzeResponse(s : String) : TResponseMessage;

                   public
                    function createAccount(usr : User) : boolean;

                    function connect(log : String; pwd : String) : boolean;
                    procedure disconnect();

                    procedure setStatus(st : TEstatus);
                    function getStatus() : TEstatus;

                    function getLoungeList() : TLoungeList;
                    procedure joinLounge(l : TLounge);
                    function getLoungeContacts(l : TLounge) : ContactList;

                    procedure addContact(c : Contact);
                    function getContacts() : ContactList;
                    procedure inviteContact(name : String; msg : String);
                    procedure acceptContact(name :String);
                    procedure rejectContact(name : string);
                    function getInvitations() : ContactList;

                    procedure sendMessageToLounge(l : TLounge; msg : string);
                    function retrieveMessages() : TStringList;

                    function sendPrivateMessage(pseud : String; msg : string) : boolean;
                    function retrievePrivateMessages() : TStringList;
                   end;


implementation

function TRPCStube.getCorpseMsg() : TJSONObject;
 var msg : TMessage;
      obj : TJSONObject;
begin
  (**
   creation de l'entete du message
 **)
 msg := TMessage.init();
 msg.setCommand('erpc');
 msg.setMessage('call');
 obj := TParser.DoParse(msg.toJson());
 result := obj;
end;

function TRPCStube.getMethodResponse(msg : String) : TJSONObject;
 var ms : TMessage;
begin      //{"command" : "EResponse", "msg" : "void", "response" : ""}
           //msg = void, exception, response
  ms.fromJson(msg);
  if(ms.getCommand()=EResponse) then
  begin
   if(ms.getMessage()='exception') then
    raise Exception.Create('ReturnMethodeException !');
  end
  else
    raise Exception.Create('IllegalResposeException');

    if(ms.getMessage()='void') then
     result := nil
    else
    begin
     result:= TParser.DoParse(msg).objects['response'];
     end;
end;

function TRPCStube.createAccount(usr : User) : boolean;
 var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'createAccount');
 args := TJSONObject.Create();
 args.add('usr', TParser.DoParse(usr.toJson()));
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
  resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
  if(resp.getResponseType()=ERRESULT) then
   if(resp.getReturn()='true') then
    result := true
   else
    result := false;
end;

function TRPCStube.connect(log : String; pwd : String) : boolean;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'connect');
 args := TJSONObject.Create();
 args.add('log', log);
 args.Add('pwd', pwd);
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getResponseType()=ERRESULT) then
   if(resp.getReturn()='true') then
    result := true
   else
    result := false;
end;

procedure TRPCStube.disconnect();
var
     obj, meth, args : TJSONObject;
     msg : TMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'disconnect');
 args := TJSONObject.Create();
 args.add('void', 'void');
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 TMtyApplication.coreCLient.callMethod(obj.AsJSON);
  (*
  if(msg.getCommand()=EResponse) then
  begin
   if(msg.getMessage()='exception') then
    raise Exception.Create('return Methode Exception !');
  end
  else
    raise Exception.Create('illegal respose Exception');
  *)
end;

procedure TRPCStube.setStatus(st : TEstatus);
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     stst : Status;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'setStatus');

 args := TJSONObject.Create();
 stst := Status.init();
 stst.setStatus(st);
 args.add('st', TParser.DoParse(stst.toJson()));
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('return Methode Exception !');
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

function TRPCStube.getStatus() : TEstatus;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     stst : Status;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'getStatus');

 args := TJSONObject.Create();
 args.add('void', 'void');
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('return Methode Exception !');
   stst.fromJson(resp.getReturn());
   result := stst.getStatus();
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

procedure TRPCStube.addContact(c : Contact);
begin

end;

function TRPCStube.getContacts() : ContactList;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : ContactList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'getContacts');

 args := TJSONObject.Create();
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('Return Methode Exception !');
   liste := ContactList.init();
   liste.fromJson(resp.getReturn());
   result := liste;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

function TRPCStube.getLoungeList() : TLoungeList;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : TLoungeList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'getLoungeList');

 args := TJSONObject.Create();
 args.add('void', 'void');
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('Return Methode Exception !');
   liste := TLoungeList.init();
   liste.fromJson(resp.getReturn());
   result := liste;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

procedure TRPCStube.joinLounge(l : TLounge);
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'joinLounge');

 args := TJSONObject.Create();
 args.add('l', TParser.DoParse(l.toJson()));
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
end;

function TRPCStube.getLoungeContacts(l : TLounge) : ContactList;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : ContactList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'getLoungeContacts');

 args := TJSONObject.Create();
 args.add('l', TParser.DoParse(l.toJson()));
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('Return Methode Exception !');
   liste := ContactList.init();
   liste.fromJson(resp.getReturn());
   result := liste;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

procedure TRPCStube.inviteContact(name : String; msg : String);
var
     obj, meth, args : TJSONObject;
     resp : TResponseMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'inviteContact');

 args := TJSONObject.Create();
 args.add('name', name);
 args.add('msg', msg);
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
end;

procedure TRPCStube.acceptContact(name :String);
var
     obj, meth, args : TJSONObject;
     resp : TResponseMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'acceptContact');

 args := TJSONObject.Create();
 args.add('name', name);
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
end;

procedure TRPCStube.rejectContact(name : string);
var
     obj, meth, args : TJSONObject;
     resp : TResponseMessage;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'rejectContact');

 args := TJSONObject.Create();
 args.add('name', name);
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
end;

function TRPCStube.getInvitations() : ContactList;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : ContactList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'getInvitations');

 args := TJSONObject.Create();
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('Return Methode Exception !');
   liste := ContactList.init();
   liste.fromJson(resp.getReturn());
   result := liste;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

procedure TRPCStube.sendMessageToLounge(l : TLounge; msg : string);
var
     obj, meth, args : TJSONObject;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'sendMessageToLounge');
 args := TJSONObject.Create();
 args.add('l', TParser.DoParse(l.toJson()));
 args.Add('msg', msg);
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 TMtyApplication.coreCLient.callMethod(obj.AsJSON);
end;

function TRPCStube.retrieveMessages() : TStringList;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : TStringList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'retrieveMessages');

 args := TJSONObject.Create();
 args.add('void', 'void');
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('return Methode Exception !');
   liste := TStringList.create();
   liste.Text:=resp.getReturn();
   result := liste;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

function TRPCStube.sendPrivateMessage(pseud : String; msg : string) : boolean;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : ContactList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'sendPrivateMessage');

 args := TJSONObject.Create();
 args.add('pseud', pseud);
 args.add('msg', msg);
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('Return Methode Exception !');
    if(resp.getReturn()='true') then
     result := true
    else
     result := false;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

function TRPCStube.retrievePrivateMessages() : TStringList;
var
     obj, meth, args : TJSONObject;
     response : string;
     resp : TResponseMessage;
     liste : TStringList;
begin
(**
   creation de l'entete du message
 **)
 obj := getCorpseMsg();
(**
   creation du corps de message
 **)
 meth := TJSONObject.Create();
 meth.Add('name', 'retrievePrivateMessages');

 args := TJSONObject.Create();
 meth.Add('args', args);
 obj.Add('methode', meth);
(**
  appel de methode
 **)
 resp := analyzeResponse(TMtyApplication.coreCLient.callMethod(obj.AsJSON));
 if(resp.getCommand()=EResponse) then
  begin
   if(resp.getMessage()='exception') then
    raise Exception.Create('return Methode Exception !');
   liste := TStringList.create();
   liste.Text:=resp.getReturn();
   result := liste;
  end
  else
    raise Exception.Create('illegal respose Exception');
end;

function TRPCStube.analyzeResponse(s : String) : TResponseMessage;
  var resp : TResponseMessage;
 begin
   resp := TResponseMessage.init();
   resp.fromJson(s);
   result := resp;
 end;

end.

