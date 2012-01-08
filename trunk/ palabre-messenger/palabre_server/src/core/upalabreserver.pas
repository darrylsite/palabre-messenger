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
unit UpalabreServer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UClientThread, blcksock, synsock;

  type
       TPalabreServer = class
                    private
                     port : Word;
                     quit : boolean;
                     cSocket :  TTCPBlockSocket;
                   public
                     constructor init(p : Word);
                     destructor Destroy; override;
                     procedure Run;
                   end;

implementation

constructor TpalabreServer.init(p : Word);
begin
  self.port := p;
  cSocket := TTCPBlockSocket.create;;
end;

destructor TpalabreServer.Destroy;
begin
  inherited Destroy;
end;

procedure TpalabreServer.Run;
var
    ClientSock:TSocket;
begin
      write('Trying to launch the server ...');
      cSocket.CreateSocket;
      cSocket.setLinger(true,10000);
      cSocket.bind('0.0.0.0', IntToStr(port));
      cSocket.listen;
      writeln(' OK !');
      repeat
        if quit then break;
        if cSocket.canread(1) then
          begin
            ClientSock:=cSocket.accept;
            if cSocket.lastError=0 then
            begin
              TClientThread.init(ClientSock, false);
              writeln('New connexion from ',csocket.GetRemoteSinIP);
            end;
          end;
      until false;
end;


end.

