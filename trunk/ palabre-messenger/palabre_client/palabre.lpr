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
  Interfaces, SysUtils, typinfo, // this includes the LCL widgetset
  Forms, LResources, palabreui, uformconnex, uprivateui, usettings,
  ucontact, UContactList, uijson, uilist, ulounge, uloungelist, UMessage,
  ustatus, uUser, myapplication, stringstohtml, TParseur, ucoreclient,
  uerrortigger, urpc, uRPCStube, TurboPowerIPro;

{$IFDEF WINDOWS}{$R palabre.rc}{$ENDIF}
   var
       connex :TTFormConnex;
begin
  {$I palabre.lrs}
  Application.Initialize;
  Application.CreateForm(TTFormConnex, connex);
  Application.Run;
end.

