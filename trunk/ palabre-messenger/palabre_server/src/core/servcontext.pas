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
unit servContext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, uTrueHashTable, uUserModel;

  type

   TServContext = class
                     lstLounge : TFPHashObjectList; static;
                     lstLoungeTitle : TStringList; static;
                    public
                     userAccess : TUserModel; static;
                     cUsers :  TFPObjectList; static;

                     class function getLounge(n : string) : TFPObjectList;
                     class procedure  addLounge(n : string);
                     class function  getLoungeTitle() : TStringList;
                  end;

implementation

class function TServContext.getLounge(n : string) : TFPObjectList;
begin
  result :=  TFPObjectList(lstLounge.find(n));
end;

class procedure  TServContext.addLounge(n : string);
begin
 lstLounge.Add(n, TFPObjectList.create);
 lstLoungeTitle.Append(n);
end;

class function  TServContext.getLoungeTitle() : TStringList;
begin
 result := lstLoungeTitle;
end;

begin
 TServContext.cUsers :=  TFPObjectList.Create();
 TServContext.lstLoungeTitle := TStringList.Create;
 TServContext.lstLounge :=TFPHashObjectList.create;

 TServContext.addLounge('accueil');
 TServContext.addLounge('computer');
 TServContext.addLounge('awesome');
 TServContext.userAccess := TUserModel.init();
end.

