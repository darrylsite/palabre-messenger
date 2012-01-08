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
unit ucoreClient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, umessage, blcksock, synsock,  uErrorTigger, jsonparser, fpJSON;

   type

   TRPCStep = (EIDLE, EBIND, ETFR, EUNBIND);

     TCoreClient = class
                    private
                     port : word;
                     Address : string;
                     cSocket : TTCPBlockSocket;
                     step : TRPCStep;
                     response : string;
                     canRead : boolean;
                     ErrorListener : IErrorTrigger;
                     procedure sendMsg(msg : string);
                     function recvMsg() : string;

                     procedure bind();
                     procedure unBind();

                     procedure tiggerErrorListener(msg : string);

                   public
                    connected : boolean;

                     constructor init(p :word; adel : string);
                     destructor Destroy; override;

                     procedure connect;
                     procedure disconect;

                     function getStep() : TRPCStep;
                     function readMsg() : string;
                     function callMethod(arg : String) : string;

                     procedure addErrorListener(l : IErrorTrigger);

                   end;

implementation
constructor TCoreClient.init(p : word; adel :string);
begin
  port := p;
  self.address := adel;
  connected := false;
  step := EIDLE;
  cSocket := TTCPBlockSocket.Create;
end;

procedure TCoreClient.sendMsg(msg : string);
begin
  cSocket.SendString(msg+CRLF);
end;

procedure  TCoreClient.addErrorListener(l : IErrorTrigger);
begin
 ErrorListener := l;
end;

procedure TCoreClient.tiggerErrorListener(msg : string);
 var i : shortInt;
begin
 if(assigned(ErrorListener)) then
   ErrorListener.triggerError(msg);
end;

function TCoreClient.recvMsg() : string;
 var err : byte;
begin
 err :=0;
 repeat
  try
   cSocket.ExceptCheck;
   result := cSocket.RecvString(3500);
   err :=0;
   except
    on e :  ESynapseError do
     inc(err);
   end;
until (err=0) or(err>2);
end;

procedure TCoreClient.bind();
 var msg : TMessage;
     s : string;
begin
  if(step <>EIDLE) then
   raise Exception.create('Illegal state exception');
  step := EBIND;
  msg := TMessage.Create;
  msg.setCommand('ecore');
  msg.setMessage('bind');
  sendMsg(msg.toJson());
  s := readMsg();
  msg.fromJson(s);
end;

procedure TCoreClient.unBind();
 var msg : TMessage;
 s : string;
begin
  if(step <>ETFR) and (step<>EBIND) then
   raise Exception.create('Illegal state exception');
  step := EUNBIND;

  msg := TMessage.init();
  msg.setCommand('ecore');
  msg.setMessage('unbind');
  sendMsg(msg.toJson());
  s := readMsg();
  msg.fromJson(s);
end;

destructor TCoreClient.Destroy;
begin
cSocket.Destroy;
  inherited Destroy;
end;

procedure TCoreClient.connect;
begin
    connected := false;
    cSocket.Connect( self.Address, IntToStr(port));
    if(cSocket.LastError=0) then
    begin
     connected := true;
    end;
end;

 function TCoreClient.callMethod(arg : String) : string;
 begin
 try
  self.bind();
  step := ETFR;
  sendMsg(arg);
  result := self.readMsg();
  self.unBind();
  step := EIDLE;
 except
   on e : EJSON do
     tiggerErrorListener(e.Message);
   on e :  EJSONScanner do
     tiggerErrorListener(e.Message);
   on e : ESynapseError do
    tiggerErrorListener(e.Message);
    on e : ESynapseError do
    tiggerErrorListener(e.Message);
   else
    begin

    end;
  end;
 end;

 function TCoreClient.getStep() : TRPCStep;
 begin
  result := step;
 end;

 function TCoreClient.readMsg() : string;
 begin
  result := recvMsg();
 end;

 procedure TCoreClient.disconect;
 begin
   cSocket.CloseSocket;
 end;

end.

