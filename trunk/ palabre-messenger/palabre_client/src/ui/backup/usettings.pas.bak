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
unit usettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, myApplication;

type

  { TSettingForm }

  TSettingForm = class(TForm)
    Button1: TButton;
    txtIP: TEdit;
    txtPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    procedure  loadSettings();
  end; 


implementation

{ TSettingForm }

procedure TSettingForm.Button1Click(Sender: TObject);
var saver : TStringList;
    port, err : integer;
begin
 saver := TStringList.Create;
 saver.Values[txtIP.text] :=txtPort.text;
 saver.SaveToFile('settings.dat');
 TMtyApplication.servIP:= txtIP.text;
 Val(txtPort.text, port, err);
 if(err=0) then
  TMtyApplication.servPort := port;
 self.Close;
end;

procedure TSettingForm.FormCreate(Sender: TObject);
begin
  loadSettings();
end;

procedure  TSettingForm.loadSettings();
  var loader : TStringList;
       port, err : integer;
 begin
  if(FileExists('settings.dat')) then
   begin
    loader := TStringList.Create;
    loader.LoadFromFile('settings.dat');
    txtIP.text := loader.Names[0];
    txtPort.text := loader.ValueFromIndex[0];
    Val(txtPort.text, port, err);
    if(err=0) then
     TMtyApplication.servPort := port;
   end;
 end;

initialization
  {$I usettings.lrs}

end.

