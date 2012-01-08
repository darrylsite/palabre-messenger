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
unit UClientThread;

{$mode objfpc}{$H+}
{$M+}

interface

uses
  Classes, SysUtils, servContext, ureflect, fpjson, TParseur, UMessage, blcksock, synsock,
  servClient, uuser, ustatus, ulounge, ucontact;

type

     { TClientThread }

     TClientThread = class(TThread)
                       private
                        reflection : TReflect;
                        cSocket : TSocket;
                        Sock:TTCPBlockSocket;
                        wClient : TServClient;

                        procedure registerFunc(meth : String);
                        procedure registerAll();
                        function  unBind(msg : string) : boolean;
                        function  Bind(msg : string) : boolean;
                        procedure process(msg : string);
                        function socketRead() : string;
                        procedure sendMsg(msg : string);

                       public
                         constructor init(aSocket: TSocket; sus : boolean);
                         procedure execute; override;

                         (******** interface**********)
                         published

                         function createAccount(args : string) : string;

                         function connect(args : string) : string;
                         function disconnect(args : string) : string;

                         function setStatus(args : string) : string;
                         function getStatus(args : string) : string;

                         function getLoungeList(args : string) : string;
                         function getLoungeContacts(args : string) : string;
                         function joinLounge(args : string) : string;

                         function addContact(args : string) : string;
                         function getContacts(args : string) : string;

                         function inviteContact(args : string) : string;
                         function acceptContact(args : string) : string;
                         function rejectContact(args : string) : string;
                         function getInvitations(args : string) : string;

                         function sendMessageToLounge(args : string) : string;
                         function retrieveMessages(args : string) : string;

                         function sendPrivateMessage(args : string) : string;
                         function retrievePrivateMessages(args : string) : string;
                     end;

implementation

constructor TClientThread.init(aSocket: TSocket; sus : boolean);
begin
  reflection := TReflect.init();
  registerAll();
  //{$IF DEFINED(LINUX)}
  //{$ELSE}
  inherited Create(sus);
//  {$ENDIF}
 FreeOnTerminate := True;
 cSocket := aSocket;
 wClient := TServClient.init();
end;

procedure TClientThread.registerFunc(meth : String);
 var routine : TMethod;
begin
   Routine.Data := Pointer(self) ;
   Routine.Code := self.MethodAddress(meth);
   reflection.addElement(meth, routine);
end;

procedure TClientThread.registerAll();
 const imax = 18;
 var methods : array[1..imax] of string[50] =
              ('createAccount', 'connect', 'disconnect', 'setStatus', 'getStatus', 'addContact',
               'getContacts', 'getLoungeList', 'inviteContact', 'acceptContact', 'rejectContact', 'sendMessageToLounge',
               'retrieveMessages', 'joinlounge', 'getloungecontacts', 'getInvitations', 'sendPrivateMessage', 'retrievePrivateMessages');
    i : byte;
begin
  for i:=1 to imax do
   self.registerFunc(LowerCase(methods[i]));
end;

procedure TClientThread.execute;
 var err : byte;
begin
 sock:=TTCPBlockSocket.create;
 err := 0;
try
    Sock.socket:=cSocket;
    sock.GetSins;
 while (not self.Terminated) and (err<10) do
 begin
   if not bind(socketRead()) then
    continue;
    process(socketRead());
   if (not unbind(socketRead())) then
    raise Exception.create('illegal state exception');
    err := 0;
 end;
 Except
  on e: Exception do
   begin
    writeln('error '+e.Message);
   end;
end;
disconnect('');
end;

function TClientThread.socketRead() : string;
begin
  result := Sock.RecvString(10000);
  if(sock.LastError<>0) then
   self.Terminate;
end;

function TClientThread.bind(msg : string) : boolean;
 var mm : TMessage;
begin
if(length(msg)<5) then
 begin
 result := false;
 exit;
 end;
 mm := TMessage.init();
 mm.fromJson(lowerCase(msg));
 result := false;
 if(mm.getCommand() = Ecore) then
  begin
   if(mm.getMessage()='bind') then
    result := true;
    sendMsg('{"command" : "ecore", "msg" : "bind"}');
  end;
end;

function TClientThread.unBind(msg : string) : boolean;
var mm : TMessage;
begin
 mm := TMessage.init();
 mm.fromJson(lowerCase(msg));
 result := false;
 //if(mm.getCommand() = Ecore) then
  begin
   if(mm.getMessage()='unbind') then
    result := true;
    sendMsg('{"command" : "ecore", "msg" : "unbind"}');

  end;
end;

procedure TClientThread.process(msg : string);
 var
   Routine: TMethod;
   Exec: TFExec;
   obj, meth, args : TJSONObject;
   mth, response : string;
begin
   obj := TParser.DoParse(msg);
   meth := obj.Objects['methode'];
   mth := meth.Strings['name'];
   args := meth.Objects['args'];
   if(not reflection.existElement(mth)) then
     raise Exception.Create('cantFindMethodException !');
   Routine := reflection.getElement(mth) ;
   if NOT Assigned(Routine.Code) then
     raise Exception.create('CantLoadMethodException ');
   Exec := TFExec(Routine) ;

   response := Exec(args.AsJSON);

   sendMsg(response);
end;

procedure TClientThread.sendMsg(msg : string);
begin
  Sock.SendString(msg+CRLF);
end;

                         (******** interface**********)
function TClientThread.createAccount(args : string) : string;
 var msg : TResponseMessage;
     usr : User;
     b : boolean;
begin
 usr := User.init();
 usr.fromJson(TParser.DoParse(args).Objects['usr'].AsJSON);
 b := wClient.createAccount(usr);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 if(b) then
  msg.setReturn('true')
 else
  msg.setReturn('false');
 result := msg.toJson();
end;

function TClientThread.connect(args : string) : string;
var msg : TResponseMessage;
    b : boolean;
    s1, s2 : String[20];
begin
s1 := TParser.DoParse(args).Strings['log'];
s2 := TParser.DoParse(args).Strings['pwd'];
b := wClient.connect(s1, s2);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 if(b) then
 begin
  msg.setReturn('true');
 end
 else
  msg.setReturn('false');
 result := msg.toJson();
end;

function TClientThread.disconnect(args : string) : string;
var msg : TResponseMessage;
begin
 wClient.disconnect();
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.setStatus(args : string) : string;
var msg : TResponseMessage;
    st : status;
begin
 st := status.init();
 st.fromJson(TParser.DoParse(args).Objects['st'].AsJSON);
 wClient.setStatus(st.getStatus());
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.getStatus(args : string) : string;
var msg : TResponseMessage;
    st : status;
begin
(*response*)
 st := Status.init();
 st.setStatus(wClient.getStatus());

 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(st.toJson());
 result := msg.toJson();
end;

function TClientThread.addContact(args : string) : string;
var msg : TResponseMessage;
    c : Contact;
begin
 c := Contact.init();
 c.fromJson(TParser.DoParse(args).Objects['c'].AsJSON);
 wClient.addContact(c);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.getContacts(args : string) : string;
var msg : TResponseMessage;
begin
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(wClient.getContacts().toJson());
 result := msg.toJson();
end;

function TClientThread.inviteContact(args : string) : string;
var msg : TResponseMessage;
    nam : String;
    mesg : String;
begin
 nam := TParser.DoParse(args).Strings['name'];
 mesg := TParser.DoParse(args).Strings['msg'];
 wClient.inviteContact(nam, mesg);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.acceptContact(args : string) : string;
var msg : TResponseMessage;
    nam : String;
begin
 nam := TParser.DoParse(args).Strings['name'];
 wClient.acceptContact(nam);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.rejectContact(args : string) : string;
var msg : TResponseMessage;
    nam : String;
begin
 nam := TParser.DoParse(args).Strings['name'];
 wClient.rejectContact(nam);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.getInvitations(args : string) : string;
var msg : TResponseMessage;
begin
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(wClient.getInvitations().toJson());
 result := msg.toJson();
end;

function TClientThread.sendMessageToLounge(args : string) : string;
var msg : TResponseMessage;
    m : string;
    l : TLounge;
begin
 m := TParser.DoParse(args).Strings['msg'];
 l := TLounge.init();
 l.fromJson(TParser.DoParse(args).Objects['l'].AsJSON);
 wClient.sendMessageToLounge(l, m);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.retrieveMessages(args : string) : string;
  var msg : TResponseMessage;
    liste : TStringList;
begin;
 liste := wClient.retrieveMessages();
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(liste.Text);
 result := msg.toJson();
end;

function TClientThread.getLoungeList(args : string) : string;
 var msg : TResponseMessage;
begin;
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(wClient.getLoungeList().toJson());
 result := msg.toJson();
end;

function TClientThread.joinLounge(args : string) : string;
 var msg : TResponseMessage;
     l : TLounge;
begin
 l := TLounge.init();
 l.fromJson(TParser.DoParse(args).Objects['l'].AsJSON);
 wClient.joinLounge(l);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERVOID);
 msg.setReturn('void');
 result := msg.toJson();
end;

function TClientThread.getLoungeContacts(args : string) : string;
var msg : TResponseMessage;
    l : TLounge;
begin
 l := TLounge.init();
 l.fromJson(TParser.DoParse(args).Objects['l'].AsJSON);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(wClient.getLoungeContacts(l).toJson());
 result := msg.toJson();
end;

function TClientThread.sendPrivateMessage(args : string) : string;
var msg : TResponseMessage;
    m      : String;
    pseudo : String;
    b : boolean;
begin
 m := TParser.DoParse(args).Strings['msg'];
 pseudo := TParser.DoParse(args).Strings['pseud'];
 b := wClient.sendPrivateMessage(pseudo, m);
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 if(b) then
  msg.setReturn('true')
 else
  msg.setReturn('false');
 result := msg.toJson();
end;

function TClientThread.retrievePrivateMessages(args : string) : string;
var msg : TResponseMessage;
    liste : TStringList;
begin;
 liste := wClient.retrievePrivateMessages();
(*response*)
 msg := TResponseMessage.init();
 msg.setMessage('response');
 msg.setResponseType(ERRESULT);
 msg.setReturn(liste.Text);
 result := msg.toJson();
end;

end.

