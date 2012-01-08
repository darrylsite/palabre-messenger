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
unit uilist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uijson;
  type

    IList = interface(IJson)
               procedure addElement(c : TObject);
               function getElement(i : integer) : TObject;
               function existElement(c : TObject) : boolean;
               procedure removeElement(c : TObject);
            end;

implementation

end.

