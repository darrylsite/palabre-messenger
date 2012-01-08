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
program palabre;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  forms, Interfaces, uusermodel, ucontact, UContactList,
  uijson, uilist, ulounge, uloungelist, UMessage, ustatus, uUser, servclient,
  servcontext, TParseur, uclientthread, upalabreserver, ureflect, urpc,
  UTrueHashTable, hashtable, SysUtils;

{$IFDEF WINDOWS}{$R palabre.rc}{$ENDIF}
   var server : TPalabreServer;
       port : integer;
begin
   port := 1987;
   if(Application.ParamCount>0) then
    port := StrToInt(Application.Params[0]);
   server := TPalabreServer.init(port);
   server.Run;
end.

