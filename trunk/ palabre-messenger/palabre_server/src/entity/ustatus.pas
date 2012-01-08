unit ustatus;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson, fpjson, TParseur;

  {$static on}
  type
   TEstatus = (busy, offline, online);

       Status = class(TInterfacedObject, IJson)
                  currentStat : TEstatus;
                 public
                  procedure fromJson(data : String);
                  function toJson() : String;

                  function getStatus() : TEstatus;
                  procedure setStatus(st : TEstatus);
                  constructor init();
                end;


implementation


constructor Status.init();
begin
  currentStat := offline;
end;

procedure  Status.fromJson(data : String);
 var stat : TJSONObject;
     s : string;
begin
stat := TParser.doParse(data);
  s := stat.Strings['currentstat'];
  if(s='offline') then
   self.currentStat := offline
  else if(s='online') then
   self.currentStat := online
  else
   self.currentStat := busy;
end;

function  Status.toJson() : String;
 var st : string;
begin
 case currentStat of
  busy :
         st :='busy';
  offline :
         st := 'offline';
  online :
         st := 'online';
  end;

  result := '{"currentstat" : "'+st+'"}';

end;

function  Status.getStatus() : TEstatus;
begin
  result := currentStat;
end;

procedure  Status.setStatus(st : TEstatus);
begin
 currentStat := st;
end;

end.

