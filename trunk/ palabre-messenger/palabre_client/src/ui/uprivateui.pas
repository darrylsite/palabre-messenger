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
unit uPrivateUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  LCLType, ExtCtrls, StdCtrls, Buttons, IpHtml, Ipfilebroker, myApplication, ucontact,
  UContactList,  ustatus, uRPCStube, StringsToHtml;

type

  { TFriendForm }

  TFriendForm = class(TForm)
    BitBtn1: TBitBtn;
    btSend: TBitBtn;
    GroupBox1: TGroupBox;
    htmlReceive2: TIpHtmlPanel;
    Image1: TImage;
    Image11: TImage;
    Image13: TImage;
    Image16: TImage;
    Image17: TImage;
    Image2: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    IpFileDataProvider1: TIpFileDataProvider;
    htmlReceive: TIpHtmlPanel;
    Panel5: TPanel;
    statusLabel: TLabel;
    privateImg: TImage;
    statusTimer: TTimer;
    txtSend: TMemo;
    Panel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure htmlReceive2Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image13Click(Sender: TObject);
    procedure Image16Click(Sender: TObject);
    procedure Image17Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure statusTimerTimer(Sender: TObject);
    procedure txtSendKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
   ownPseudo : string;
   friendPsudo : string;

   msgHistory : TStringList;
   htmlConv : TStringToHtml;
   buffred : boolean;

   procedure checkStatus();
   procedure loadPage(url : string);
  public
   procedure setOwnPseudo(s : string);
   procedure setFriendPseudo(s : string);
   function getOwnPseudo() : string;
   function getFriendPseudo() : string;

   procedure addMessage(ps : string; msg : string);
   procedure setTitle(title : string);
   procedure doConfig();
  end; 

var
  FriendForm: TFriendForm;

implementation

{ TFriendForm }


procedure TFriendForm.FormCreate(Sender: TObject);
begin
 msgHistory := TStringList.create();
 statusTimerTimer(self);
 checkStatus();
 buffred:= false;
end;

procedure TFriendForm.loadPage(url : string);
begin
try
 if(not buffred) then
  begin
   htmlReceive2.OpenURL(expandLocalHtmlFileName(url));
   htmlReceive2.VScrollPos:= 10000;
   htmlReceive2.Visible := true;
   htmlReceive.visible := false;
  end
  else
  begin
   htmlReceive.OpenURL(expandLocalHtmlFileName(url));
   htmlReceive.VScrollPos:= 10000;
   htmlReceive.Visible := true;
   htmlReceive2.visible :=false;
  end;
  buffred:= not buffred;
  Except
   on e : Exception do
   begin
   end
   else
    begin
    end;
  end;
end;

procedure TFriendForm.htmlReceive2Click(Sender: TObject);
begin

end;

 procedure TFriendForm.doConfig();
 begin
   htmlConv := TStringToHtml.init(self.friendPsudo+'.html');
   htmlConv.setSource(msgHistory);
   htmlConv.doTransform();
   loadPage(self.friendPsudo+'.html');
 end;

 procedure  TFriendForm.checkStatus();
 var i, l : shortint;
    c : Contact;
    s : String[10];
begin
  l := TMtyApplication.clist.length()-1;
  c := nil;
  statusLabel.Caption:=friendPsudo;
  if(l>0) then
  for i:=0 to l do
   if (TMtyApplication.clist.getElement(i).getPseudo()=self.friendPsudo) then
    begin
     c := TMtyApplication.clist.getElement(i);
     break;
    end;
  if (c<>nil) then
  begin
   if (c.getStatus().getStatus()=online) then
    s:='online'
   else if (c.getStatus().getStatus()=offline) then
    s := 'offline'
   else
    s := 'busy';
   statusLabel.Caption:=friendPsudo+' ('+s+')';
   if(c.getStatus().getStatus()=offline) then
   begin
    self.Close;
    i := TMtyApplication.privateMsgForms.FindIndexOf(self.friendPsudo);
    if(i>=0) then
     TMtyApplication.privateMsgForms.Delete(i);
   end;
  end;
end;

procedure TFriendForm.statusTimerTimer(Sender: TObject);
begin
  checkStatus();
end;

procedure TFriendForm.txtSendKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(key = VK_RETURN) then
  begin
   self.btSend.Click;
  end;
end;

procedure TFriendForm.btSendClick(Sender: TObject);
var i : byte;
    b : boolean;
begin
  b := TRPCStube(TMtyApplication.RemoteObj).sendPrivateMessage(friendPsudo, txtSend.Lines.Text);
  addMessage(getOwnPseudo(),txtSend.Lines.Text);
  if(not b) then
   addMessage('#Error#','Error : The message has not been sent !');
  for i:= 0 to (txtSend.Lines.Count-1) do
   txtSend.Lines.Delete(i);
  txtSend.Clear;
end;

procedure TFriendForm.BitBtn1Click(Sender: TObject);
begin
 msgHistory.Clear;
 htmlConv.doTransform();
 loadPage(self.friendPsudo+'.html');
end;

procedure TFriendForm.setOwnPseudo(s : string);
begin
 self.ownPseudo:= s;

end;

procedure TFriendForm.setFriendPseudo(s : string);
begin
  self.friendPsudo:= s;
end;

function TFriendForm.getOwnPseudo() : string;
begin
 result := self.ownPseudo;
end;

function TFriendForm.getFriendPseudo() : string;
begin
 result := self.friendPsudo;
end;

procedure TFriendForm.addMessage(ps : string; msg : string);
begin
 msgHistory.Values['['+FormatDateTime('hh:nn:ss', Now)+'@'+ps+'] : '] := msg;
 htmlConv.doTransform();
 loadPage(self.friendPsudo+'.html');
 if (not self.Visible) then
 begin
  self.Show;
  BringToFront;
  Beep;
 end;
end;

procedure TFriendForm.setTitle(title : string);
begin
 self.Caption:= title;
end;

procedure TFriendForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  self.Hide;
end;

procedure TFriendForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  self.Hide;
end;

procedure TFriendForm.Image11Click(Sender: TObject);
begin
  txtSend.SelText:=':aie:';
end;

procedure TFriendForm.Image13Click(Sender: TObject);
begin
  txtSend.SelText:=':ccool:';
end;

procedure TFriendForm.Image16Click(Sender: TObject);
begin
  txtSend.SelText:=':lun:';
end;

procedure TFriendForm.Image17Click(Sender: TObject);
begin
  txtSend.SelText:=':mrgreen:';
end;

procedure TFriendForm.Image1Click(Sender: TObject);
begin
  txtSend.SelText:=':)';
end;

procedure TFriendForm.Image2Click(Sender: TObject);
begin
  txtSend.SelText:=':D';
end;

procedure TFriendForm.Image4Click(Sender: TObject);
begin
  txtSend.SelText:=':(';
end;

procedure TFriendForm.Image5Click(Sender: TObject);
begin
  txtSend.SelText:=':lol:';
end;

procedure TFriendForm.Image6Click(Sender: TObject);
begin
  txtSend.SelText:=':evil:';
end;

procedure TFriendForm.Image7Click(Sender: TObject);
begin
  txtSend.SelText:=':rose:';
end;

procedure TFriendForm.Image8Click(Sender: TObject);
begin
  txtSend.SelText:=':angry:';
end;


initialization
  {$I uprivateui.lrs}

end.

