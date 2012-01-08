unit dataAccess;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, servContext;

  type TDataAccess = class
                      public
                       class function existUser(user : string) : boolean;
                       class procedure createAccount(user : string; pass : string);
                       class function verifLogin(user : string; pass : string) : boolean;
                     end;

implementation

class function TDataAccess.existUser(user : string) : boolean;
begin
 result := TServContext.users.IndexOfName(user) <> -1;
end;

class procedure TDataAccess.createAccount(user : string; pass : string);
begin
  TServContext.users.Values[user] := pass;
  TServContext.saveDb();
end;

class function TDataAccess.verifLogin(user : string; pass : string) : boolean;
begin
 result := false;
 if (existUser(user)) then
   if(TServContext.users.Values[user]=pass) then
    result := true;
end;

end.

