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
unit urpc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ulounge, ucontact, UContactList, uUser, ULoungeList, ustatus;

    type
        TIRPC = interface
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

               end;


implementation

end.

