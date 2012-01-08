unit UMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson, fpjson, TParseur, TypInfo;

  type
   TCommand = (Emsg, Ecmd, Ecore, Erpc, Eexecpt, EResponse);

   TMessage = class(TInterfacedObject, IJSON)
                 private
                  msg : String;
                  command : TCommand;
                 public
                  constructor init();
                   procedure setMessage(m : String);
                   procedure setCommand(s : String);

                   function getMessage() : String;
                   function getCommand() : TCommand;

                   procedure fromJson(data : String);virtual;
                   function toJson() : String; virtual;
              end;

    TEResponse =(ERVOID, EREXCEPTION, ERRESULT);

    TResponseMessage = class(TMessage)
                          private
                           rType : TEResponse;
                           rreturn : string;
                          public
                           constructor init();
                           procedure setResponseType(t : TEResponse);
                           function getResponseType() : TEResponse;
                           procedure setReturn(rr : string);
                           function getReturn() : String;

                           procedure fromJson(data : String); override;
                           function toJson() : String;        override;
                       end;


implementation

constructor TMessage.init();
begin
 msg :='';
 command := ERPC;
end;

procedure TMessage.setMessage(m : String);
begin
  msg := m;
end;

procedure TMessage.setCommand(s : String);
 var tbCmd : array[1..6] of string =('emsg', 'ecmd', 'ecore', 'erpc', 'Eexecpt', 'EResponse');
      tbECmd : array[1..6] of TCommand =(Emsg, Ecmd, Ecore, Erpc, Eexecpt, EResponse);
      i : integer;
begin
 for i:=1 to 6 do
  if (s=tbCmd[i]) then
   command := tbECmd[i];
end;

function TMessage.getMessage() : String;
begin
   result := msg;
end;

function TMessage.getCommand() : TCommand;
begin
   result := command;
end;

procedure TMessage.fromJson(data : String);
 var obj : TJSONOBject;
begin
try
 obj := TParser.doParse(data);
 self.setMessage(obj.Strings['msg']);
 self.setCommand(obj.Strings['command']);
 except
  on e : Exception do begin
   writeln(e.message);
  end;
 end;
end;

function TMessage.toJson() : String;
 var obj : TJSONObject;
begin
 obj := TJSONObject.Create;
 obj.Add('msg', self.msg);
 obj.add('command', GetEnumName(TypeInfo(TCommand),Ord(command)));
 result := obj.AsJSON;
end;

(**************************** TResponseMessage *************)

constructor TResponseMessage.init();
begin
 inherited;
 self.command:= EResponse;
end;

procedure TResponseMessage.setResponseType(t : TEResponse);
begin
  self.rType:= t;
end;

function TResponseMessage.getResponseType() : TEResponse;
begin
  result := self.rType;
end;

procedure TResponseMessage.setReturn(rr : string);
begin
   self.rreturn:= rr;
end;

function TResponseMessage.getReturn() : String;
begin
    result := self.rreturn;
end;

procedure TResponseMessage.fromJson(data : String);
 var obj : TJSONOBject;

begin
try
 Inherited fromJson(data);
 obj := TParser.doParse(data);
 if(self.getMessage()='ervoid') then
  self.setResponseType(ERVOID)
 else if(self.getMessage()='erexception') then
  self.setResponseType(EREXCEPTION)
  else
   self.setResponseType(ERRESULT);

   if(self.getResponseType()=ERRESULT) then
    if(obj.Types['return']=jtString) then
     self.rreturn :=  obj.Strings['return']
    else
     self.rreturn := obj.Objects['return'].AsJSON;
 except
  on e : Exception do begin
   writeln(e.message);
  end;
 end;
end;

function TResponseMessage.toJson() : String;
 var obj : TJSONObject;
begin
 obj := TParser.DoParse(inherited toJson());

 if (length(self.rreturn)>0) then
  if (self.rreturn[1]='{') then
   obj.Add('return', TParser.DoParse(self.rreturn))
  else
   obj.Add('return', self.rreturn);
  result := obj.AsJSON;
end;

end.

