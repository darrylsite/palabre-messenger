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
unit servClient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, typinfo, servContext, uUser, ustatus, urpc,
  ucontact, uContactList, uLoungeList, uLounge, contnrs;

  type

      { TServClient }

      TServClient = class(TInterfacedObject,  TIRPC)
                      private
                       procedure sendSystemMessage(l : TLounge; msg : string);
                       function connectedUser(usr : String) : Contact;
                      public
                        connected : boolean;
                        pseudo : string;
                        stat : TEstatus;
                        loungeName : string;

                       loungeMessages : TStringList;
                       privateMessage : TStringList;
                       procedure storePrivateMessage(pseud : String; msg : string);

                       function createAccount(usr : User) : boolean;

                       function connect(log : String; pwd : String) : boolean;
                       procedure disconnect();

                       procedure setStatus(st : TEstatus);
                       function getStatus() : TEstatus;

                       procedure addContact(c : Contact);
                       function getContacts() : ContactList;

                       function getLoungeList() : TLoungeList;
                       procedure joinLounge(l : TLounge);
                       function getLoungeContacts(l : TLounge) : ContactList;

                       procedure inviteContact(name : String; msg : String);
                       procedure acceptContact(name :String);
                       procedure rejectContact(name : string);
                       function getInvitations() : ContactList;

                       procedure sendMessageToLounge(l : TLounge; msg : string);
                       function retrieveMessages() : TStringList;

                       function sendPrivateMessage(pseud : String; msg : string) : boolean;
                       function retrievePrivateMessages() : TStringList;

                       constructor init();
                    end;

implementation

 constructor TservClient.init();
 begin
  connected := false;
  stat := offline;
  loungeMessages := TStringList.create();
  privateMessage := TStringList.create();
  loungeName:='accueil';
 end;

 function TServClient.createAccount(usr : User) : boolean;
 begin
  if (not TServContext.userAccess.existUser(usr.getPseudo())) then
   result := false;
  TServContext.userAccess.createUser(usr.getPseudo(), usr.getPasswd());
  result := true;
 end;

function TServClient.connect(log : String; pwd : String) : boolean;
begin
  result := false;
  if (TServContext.userAccess.verifLogin(log, pwd)) then
  begin
   result := true;
   connected:= true;
   pseudo := log;
   result := true;
   TServContext.getLounge(loungeName).Add(self);
  end;
end;

procedure TServClient.disconnect();
begin
  TServContext.getLounge(loungeName).Remove(self);
  connected:= false;
end;

procedure TServClient.setStatus(st : TEstatus);
begin
  stat:= st;
end;

function TServClient.getStatus() : TEstatus;
begin
 result := stat;
end;

procedure TServClient.addContact(c : Contact);
begin
 TServContext.userAccess.addFriend(self.pseudo, c);
end;

(**
  retrieve friend list of a specific user from the userModel, et check if those friends are online
**)
function TServClient.getContacts() : ContactList;
 var liste, liste2 : ContactList;
  var i, l : word;
begin
 liste := ContactList.init();
 liste2 := TServContext.userAccess.getFriends(self.pseudo);
 l := liste2.length()-1;
 if(liste2.length()>0) then
  for i:=0 to l do
   liste.addElement(connectedUser(liste2.getElement(i).getPseudo()));
 result := liste;
end;

function TServClient.getLoungeList() : TLoungeList;
 var liste :  TLoungeList;
     l : TLounge;
     i : byte;
     sn, sv : string;
begin
  liste :=  TLoungeList.init();
  for i:=0 to TServContext.lstLoungeTitle.Count-1 do
   begin
    TServContext.lstLoungeTitle.GetNameValue(i, sn, sv);
    l := TLounge.init();
    l.setName(sv);
    liste.addElement(l);
   end;

   result := liste;
end;

procedure TServClient.inviteContact(name : String; msg : String);
 var c : Contact;
begin
 c := contact.init();
 c.setPseudo(self.pseudo);
 TServContext.userAccess.addInvitation(name, c);
end;

procedure TServClient.acceptContact(name :String);
 var c : Contact;
begin
 c := Contact.init();
 c.setPseudo(name);
 TServContext.userAccess.deleteInvitation(self.pseudo, c);
 TServContext.userAccess.addFriend(self.pseudo, c);
  c.setPseudo(self.pseudo);
 TServContext.userAccess.addFriend(name, c);
end;

procedure TServClient.rejectContact(name : string);
 var c : Contact;
begin
 c := Contact.init();
 c.setPseudo(name);
 TServContext.userAccess.deleteInvitation(self.pseudo, c);
end;

function TServClient.getInvitations() : ContactList;
begin
 result := TServContext.userAccess.getInvitations(self.pseudo);
end;

procedure TServClient.sendMessageToLounge(l : TLounge; msg : string);
 var i : word;
begin
 if (TServContext.getLounge(l.getName()).Count>0) then
 for i:=0 to TServContext.getLounge(l.getName()).Count-1 do
  TServClient(TServContext.getLounge(l.getName()).Items[i]).loungeMessages.Values[self.pseudo] := msg;
end;

procedure TServClient.sendSystemMessage(l : TLounge; msg : string);
 var i : word;
begin
 if (TServContext.getLounge(l.getName()).Count>0) then
 for i:=0 to TServContext.getLounge(l.getName()).Count-1 do
  TServClient(TServContext.getLounge(l.getName()).Items[i]).loungeMessages.Values['#Admin#'] := msg;
end;

function  TServClient.retrieveMessages() : TStringList;
  var liste : TStringList;
begin
 liste := TStringList.Create;
  if (loungeMessages.Count>0) then
  begin
   liste.Text:= loungeMessages.Text;
   loungeMessages.Clear;
  end;
 result := liste;
end;

procedure TServClient.joinLounge(l : TLounge);
 var liste : TFPObjectList;
begin
 TServContext.getLounge(l.getName()).Add(self);
 //TServContext.getLounge(loungeName).Remove(self);
 liste := TServContext.getLounge(loungeName);
 liste.Extract(self);
 self.loungeName:= l.getName();
 self.sendSystemMessage(l, self.pseudo+' has join the Lounge '+l.getName());
end;

function TServClient.getLoungeContacts(l : TLounge) : ContactList;
 var liste : ContactList;
     c : Contact;
     ll : TFPObjectList;
     i : word;
     client : TServClient;
     s : Status;
begin
  liste := ContactList.init();
  ll := TServContext.getLounge(l.getName());
  if(ll.Count>0) then
  for i:= 0 to ll.Count-1 do
  begin
   client := TServClient(ll.Items[i]);
   if(client.getStatus()=offline) then
    continue;
   c := Contact.init();
   c.setPseudo(client.pseudo);
   s := Status.init();
   s.setStatus(client.getStatus());
   c.setStatus(s);
   liste.addElement(c);
  end;
  result := liste;
end;

function TServClient.sendPrivateMessage(pseud : String; msg : string) : boolean;
 var i, j : word;
     ll : TLoungeList;
     s : string[20];
     success : boolean;
begin
success := false;
 ll := self.getLoungeList();
 for i:=0 to ll.length()-1do
 begin
  s:= ll.getElement(i).getName();
  if (TServContext.getLounge(s).Count>0) then
   for j:=0 to TServContext.getLounge(s).Count-1 do
    if(TServClient(TServContext.getLounge(s).Items[j]).pseudo=pseud ) then
    begin
      TServClient(TServContext.getLounge(s).Items[j]).privateMessage.Values[self.pseudo] := msg;
      success:= true;
    end;
 end;
 result :=success;
end;

function TServClient.retrievePrivateMessages() : TStringList;
var liste : TStringList;
begin
 liste := TStringList.Create;
  if (privateMessage.Count>0) then
  begin
   liste.Text:= privateMessage.Text;
   privateMessage.Clear;
  end;
 result := liste;
end;

function TServClient.connectedUser(usr : String) : Contact;
var
     c : Contact;
     ll : TFPObjectList;
     i, j : word;
     client : TServClient;
     s : Status;
     Tl : TLoungeList;
begin
  c := Contact.init();
  c.setPseudo(usr);
  result := c;
  tl := self.getLoungeList();
  if (tl.length()>0) then
  for j:=0 to (tl.length()-1) do
   begin
    ll := TServContext.getLounge(tl.getElement(j).getName());
    if(ll.Count>0) then
    for i:= 0 to ll.Count-1 do
    if (TServClient(ll.Items[i]).pseudo=usr) then
    begin
      client := TServClient(ll.Items[i]);
      c := Contact.init();
      c.setPseudo(client.pseudo);
      s := Status.init();
      s.setStatus(client.getStatus());
      c.setStatus(s);
      result := c;
      break;
    end;
   end;
end;

procedure TServClient.storePrivateMessage(pseud : String; msg : string);
begin
  self.privateMessage.Values[pseud] := msg;
end;

end.

