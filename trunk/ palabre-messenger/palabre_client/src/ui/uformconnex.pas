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
unit uformconnex;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, StdCtrls, Buttons,
  ExtCtrls, myApplication, uRPCStube, ucoreClient, palabreui, uuser,
  uErrorTigger, usettings;

type

  { TFormConnex }

  { TTFormConnex }

  TTFormConnex = class(TForm)
    BitBtn1: TBitBtn;
    btLogin: TBitBtn;
    btCreate: TBitBtn;
    chkSave: TCheckBox;
    txtSPseuso: TEdit;
    txtSPass: TEdit;
    txtRPseudo: TEdit;
    txtRPass1: TEdit;
    txtRPass2: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbSignError: TLabel;
    lbRegisterError: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure btCreateClick(Sender: TObject);
    procedure btLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FrameClick(Sender: TObject);
    procedure txtRPass1Change(Sender: TObject);
    procedure txtRPass2Change(Sender: TObject);
    procedure txtRPseudoChange(Sender: TObject);
    procedure txtSPassChange(Sender: TObject);
    procedure txtSPseusoChange(Sender: TObject);
  private
   pseudo : string[30];
   passwd : string[30];
   stub : TRPCStube ;
   connected : boolean;

   procedure connect();
   procedure createAccount();
   procedure saveLogin();
   procedure loadLogin();
  public
    function getPseudo () : String;
    function isConnected() : boolean;
  end;

implementation

procedure TTFormConnex.connect();
 var chat : TUIPalabre;
 errStr : string;
begin
  if(txtSPseuso.Text='') or (txtSPass.Text='') then
   exit;
 chat := nil;
  if(assigned(TMtyApplication.RemoteObj)) then
    begin
      TRPCStube(TMtyApplication.RemoteObj).disconnect();
      FreeAndNil(TMtyApplication.RemoteObj);
      TMtyApplication.coreCLient.disconect();
      FreeAndNil( TMtyApplication.coreCLient);
      TMtyApplication.connected := false;
    end;
 if(chkSave.Checked) then
  saveLogin();
 connected := false;
 TMtyApplication.coreCLient := TCoreClient.init(TMtyApplication.servPort, TMtyApplication.servIP);
 lbSignError.Caption := 'Negotiating connexion ...';
 TMtyApplication.coreCLient.connect();
 errStr :='can''t reach the server at '+TMtyApplication.servIP+':'+IntToStr(TMtyApplication.servPort);
 if(TMtyApplication.coreCLient.connected) then
   begin
    stub := TRPCStube.Create;
    TMtyApplication.RemoteObj := stub;
    errStr := 'Please verify your login !' ;
     if(stub.connect(txtSPseuso.Text, txtSPass.Text)) then
     begin
      connected:=true;
      TMtyApplication.connected:=true;
     end;
   end;
  if(not connected) then
   lbSignError.Caption := errStr
  else
   lbSignError.Caption := '';
  pseudo := txtSPseuso.Text;
  if(connected) then
  begin
    chat := TUIPalabre.Create(self);
    chat.setPseudo(pseudo);
    chat.setStub(stub);
    chat.Show;
   self.Hide;
  end;
end;

function TTFormConnex.isConnected() : boolean;
begin
  result := connected;
end;

procedure TTFormConnex.createAccount();
begin

end;

 function TTFormConnex.getPseudo () : String;
 begin
  result := pseudo;
 end;

procedure TTFormConnex.saveLogin();
 var saver : TStringList;
begin
 saver := TStringList.Create;
 saver.Values[txtSPseuso.text] :=txtSPass.text;
 saver.SaveToFile('connex.dat');
end;

 procedure  TTFormConnex.loadLogin();
  var loader : TStringList;
 begin
  if(FileExists('connex.dat')) then
   begin
    loader := TStringList.Create;
    loader.LoadFromFile('connex.dat');
    txtSPseuso.text := loader.Names[0];
    txtSPass.text := loader.ValueFromIndex[0];
    chkSave.Checked:= true;
   end;
 end;

procedure TTFormConnex.btLoginClick(Sender: TObject);
begin
 connect();
end;

procedure TTFormConnex.FormCreate(Sender: TObject);
  var loader : TStringList;
       port, err : integer;
 begin
  if(FileExists('settings.dat')) then
   begin
    loader := TStringList.Create;
    loader.LoadFromFile('settings.dat');
    TMtyApplication.servIP:= loader.Names[0];
    Val(loader.ValueFromIndex[0], port, err);
    if(err=0) then
     TMtyApplication.servPort := port;
   end;
 end;

procedure TTFormConnex.FormPaint(Sender: TObject);
begin

end;

procedure TTFormConnex.FormShow(Sender: TObject);
begin
  loadLogin();
end;

procedure TTFormConnex.btCreateClick(Sender: TObject);
var ps, p1 , p2 : string[30];
     usr : user;
     errStr : string;
     created :boolean;
begin
created := false;
 ps := txtRPseudo.text;
 p1 := txtRPass1.text;
 p2 := txtRPass2.text;
 if(ps='') or (p1='') or (p1<>p2) then
  errStr := 'Please check the given informations'
 else
 begin
  TMtyApplication.coreCLient := TCoreClient.init(TMtyApplication.servPort, TMtyApplication.servIP);
  lbSignError.Caption := 'Negotiating connexion ...';
  TMtyApplication.coreCLient.connect;
  errStr :='can''t reach the server at '+TMtyApplication.servIP+':'+IntToStr(TMtyApplication.servPort);
  if(TMtyApplication.coreCLient.connected) then
   begin
    stub := TRPCStube.Create;
    TMtyApplication.RemoteObj := stub;
    usr := user.init();
    usr.setPseudo(ps);
    usr.setPasswd(p1);
     if(stub.createAccount(usr)) then
     begin
      lbRegisterError.caption := 'Account created !';
      created := true;
      sleep(500);
      txtSPseuso.text := ps;
      txtSPass.text := p1;
       connect();
     end;
   end;
  end;
  if(not created) then
   lbRegisterError.Caption := errStr
  else
   lbSignError.Caption := '';
end;

procedure TTFormConnex.BitBtn1Click(Sender: TObject);
 var  sett : TSettingForm;
begin
  sett := TSettingForm.Create(self);
  sett.loadSettings();
  sett.Show;
end;

procedure TTFormConnex.FrameClick(Sender: TObject);
 begin

 end;

procedure TTFormConnex.txtRPass1Change(Sender: TObject);
begin
   lbSignError.Caption:= '';
end;

procedure TTFormConnex.txtRPass2Change(Sender: TObject);
begin
  lbSignError.Caption:= '';
end;

procedure TTFormConnex.txtRPseudoChange(Sender: TObject);
begin
  lbSignError.Caption:= '';
end;

procedure TTFormConnex.txtSPassChange(Sender: TObject);
begin
  lbSignError.Caption:='';
end;

procedure TTFormConnex.txtSPseusoChange(Sender: TObject);
begin
  lbSignError.Caption:='';
end;


initialization
  {$I uformconnex.lrs}

end.

