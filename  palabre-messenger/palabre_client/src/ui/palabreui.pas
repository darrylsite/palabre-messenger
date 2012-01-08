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
unit palabreui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, contnrs, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Menus, Buttons, IpHtml, Ipfilebroker, uRPCStube,
  ulounge, ustatus, uLoungeList, UContactList,LCLType,
  myApplication, uPrivateUI, StringsToHtml, uErrorTigger;

type

  { TUIPalabre }

  TUIPalabre = class(TForm, IErrorTrigger)
    BitBtn1: TBitBtn;
    btSend: TBitBtn;
    cbLounge: TComboBox;
    cbStatus: TComboBox;
    FriendHtml2: TIpHtmlPanel;
    Image1: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    htmlReceive: TIpHtmlPanel;
    IpFileDataProvider1: TIpFileDataProvider;
    IpFileDataProvider2: TIpFileDataProvider;
    FriendHtml: TIpHtmlPanel;
    htmlReceive2: TIpHtmlPanel;
    lblStatus: TLabel;
    InviteMenu: TMenuItem;
    contactMenu: TPopupMenu;
    InviteTimer: TTimer;
    friendMenuItem: TMenuItem;
    Label2: TLabel;
    lstUser: TListBox;
    Panel2: TPanel;
    FriendPopUp: TPopupMenu;
    Panel3: TPanel;
    StaticText1: TStaticText;
    txtMsg: TMemo;
    Panel1: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    CheckMsgTimer: TTimer;
    procedure BitBtn1Click(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure cbLoungeChange(Sender: TObject);
    procedure cbLoungeClick(Sender: TObject);
    procedure cbStatusChange(Sender: TObject);
    procedure cbStatusSelect(Sender: TObject);
    procedure CheckMsgTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FriendHtml2HotClick(Sender: TObject);
    procedure FriendHtmlHotClick(Sender: TObject);
    procedure htmlDisplay2Click(Sender: TObject);
    procedure htmlReceive2Click(Sender: TObject);
    procedure htmlReceive2HotClick(Sender: TObject);
    procedure htmlReceiveClick(Sender: TObject);
    procedure htmlReceiveHotClick(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
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
    procedure InviteMenuClick(Sender: TObject);
    procedure InviteTimerTimer(Sender: TObject);
    procedure lblStatussClick(Sender: TObject);
    procedure lstUserDblClick(Sender: TObject);
    procedure friendMenuItemClick(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure txtDisplayChange(Sender: TObject);
    procedure txtMsgKeyPress(Sender: TObject; var Key: char);
    procedure txtMsgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    stub : TRPCStube ;
    rtv : Shortint;
    SelectedUser : string[20];
    SelectedFriend : string[20];
    pseudo : string;
    myContacts : ContactList;
    msgHistory : TStringList;
    htmlConv : TStringToHtml;
    htmlFriendConv : TContactListToHtml;
    pageDisplay : boolean;
    friendDisplay : boolean;

    procedure loadPage(url : string);
    procedure displayFriend(url : String);
    procedure launchPrivateForm(ps : string);
    procedure loadLounge();
    procedure timerLoadLoungeUser();
    procedure RetrieveMesg();
    procedure retrievePrivateMsg();
    procedure checkInvitation();
    procedure loadFriends();
    procedure deliverPrivateMsg(ps : String; msg : string);
  public
    procedure setPseudo(p : String);
    procedure setStub(st : TRPCStube);
    procedure triggerError(msg : string);
    destructor Destroy; override;
  end; 


implementation
uses uFormConnex;
{ TUIPalabre }

procedure TUIPalabre.FormCreate(Sender: TObject);
begin
 rtv :=0;
 pageDisplay := false;
 friendDisplay := false;

 loadLounge();
 cbLounge.Caption:= cbLounge.Items[0];
 cbLoungeChange(self);
 cbStatus.Caption:= cbStatus.Items[0];
 cbStatusChange(self);
 myContacts := ContactList.init();
 TMtyApplication.clist := ContactList.init();
 TMtyApplication.privateMsgForms := TFPHashObjectList.Create;
 msgHistory := TStringList.Create;

 htmlConv := TStringToHtml.init('public.html');
 htmlConv.setSource(msgHistory);
 htmlConv.doTransform();

 htmlReceive.AllowTextSelect:=true;
 htmlReceive2.AllowTextSelect:=true;
 loadPage('public.html');

 htmlFriendConv := TContactListToHtml.init('friend.html');
 htmlFriendConv.setSource(myContacts);
 htmlFriendConv.doTransform();
 displayFriend('friend.html');

 TMtyApplication.coreCLient.addErrorListener(self);
 timerLoadLoungeUser();
end;

procedure TUIPalabre.loadPage(url : string);
begin
 try
 if(not pageDisplay) then
  begin
   htmlReceive2.OpenURL(expandLocalHtmlFileName(url));
   htmlReceive2.VScrollPos:= 10000;
   htmlReceive2.Visible := true;
   htmlReceive.visible := false;
   htmlReceive.enabled := false;
   htmlReceive.OpenURL(expandLocalHtmlFileName(url));
  end
  else
  begin
   htmlReceive.OpenURL(expandLocalHtmlFileName(url));
   htmlReceive.VScrollPos:= 10000;
   htmlReceive.Visible := true;
   htmlReceive2.visible :=false;
   htmlReceive2.enabled := false;
   htmlReceive2.OpenURL(expandLocalHtmlFileName(url));
  end;
  pageDisplay:= not pageDisplay;
  Except
   on e : Exception do
    begin
    end
    else
    begin
    end;
  end;
end;

procedure TUIPalabre.displayFriend(url : String);
begin
try
 if(not friendDisplay) then
  begin
   FriendHtml2.OpenURL(expandLocalHtmlFileName(url));
   FriendHtml2.Visible := true;
   FriendHtml.visible := false;
  end
  else
  begin
   FriendHtml.OpenURL(expandLocalHtmlFileName(url));
   FriendHtml.Visible := true;
   FriendHtml2.visible :=false;
  end;
  friendDisplay:= not friendDisplay;
  Except
   on e : Exception do
   begin
   end
   else
   begin
   end;
  end;
end;

procedure TUIPalabre.triggerError(msg : string);
begin
  self.Close;
end;

procedure TUIPalabre.Panel4Click(Sender: TObject);
begin

end;

procedure TUIPalabre.txtDisplayChange(Sender: TObject);
begin

end;

procedure TUIPalabre.txtMsgKeyPress(Sender: TObject; var Key: char);
begin

end;

procedure TUIPalabre.txtMsgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if(key = VK_RETURN) then
  begin
   self.btSend.Click;
  end;
end;

procedure TUIPalabre.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
 begin

 end;

procedure TUIPalabre.FriendHtml2HotClick(Sender: TObject);
begin
  FriendHtmlHotClick(self);
end;

procedure TUIPalabre.FriendHtmlHotClick(Sender: TObject);
var i : shortint;
    ps : string;
    href : string;
begin
  if(pageDisplay)  then
  begin
   FriendHtml.Visible := false;
   FriendHtml2.Visible := true;
   href := FriendHtml2.HotURL;
  end
  else
  begin
   FriendHtml.Visible := true;
   FriendHtml2.Visible := false;
   href := FriendHtml.HotURL;
  end;

  ps := StringReplace(href, '#', '', [rfReplaceAll]+[rfIgnoreCase]) ;
  for i:=0 to TMtyApplication.clist.length() -1 do
   if(TMtyApplication.clist.getElement(i).getPseudo()=ps) then
   if(TMtyApplication.clist.getElement(i).getStatus().getStatus()<>offline) then
   begin
     SelectedFriend := ps;
     self.FriendPopUp.PopUp();
     break;
   end;
end;

procedure TUIPalabre.htmlDisplay2Click(Sender: TObject);
begin

end;

procedure TUIPalabre.htmlReceive2Click(Sender: TObject);
begin
  htmlReceive.CopyToClipboard;
end;

procedure TUIPalabre.htmlReceive2HotClick(Sender: TObject);
begin

end;

procedure TUIPalabre.htmlReceiveClick(Sender: TObject);
begin
  htmlReceive.CopyToClipboard;
end;

procedure TUIPalabre.htmlReceiveHotClick(Sender: TObject);
begin

end;

procedure TUIPalabre.InviteMenuClick(Sender: TObject);
 var b : boolean;
     i : byte;
begin
  b:= false;
  if(assigned(TMtyApplication.clist)) then
  if(TMtyApplication.clist.length()>0) then
  for i:=0 to TMtyApplication.clist.length()-1 do
   if(TMtyApplication.clist.getElement(i).getPseudo()=SelectedUser) then
   begin
    b := true;
    break;
   end;
  if(not b) then
  begin
   ShowMessage('Votre invitation va etre envoyée à '+SelectedUser);
   stub.inviteContact(SelectedUser, '');
  end;
end;

procedure TUIPalabre.InviteTimerTimer(Sender: TObject);
begin
  InviteTimer.Enabled:= false;
  checkInvitation();
  loadFriends();
  InviteTimer.Enabled:= true;
end;

procedure TUIPalabre.lblStatussClick(Sender: TObject);
begin

end;

procedure TUIPalabre.deliverPrivateMsg(ps : String; msg : string);
 var index : shortint;
     s : string;
begin
 s := '['+FormatDateTime('hh:nn', Now)+'@'+ps+'] '+msg;
 index := TMtyApplication.privateMsgForms.FindIndexOf(ps);
 if (index>=0) then
  begin
   TFriendForm(TMtyApplication.privateMsgForms.Find(ps)).addMessage(ps, msg);
  end
  else
  begin
    launchPrivateForm(ps);
    TFriendForm(TMtyApplication.privateMsgForms.Find(ps)).addMessage(ps, s);
  end;
end;

procedure TUIPalabre.lstUserDblClick(Sender: TObject);
 var i : byte;
begin
  if(length(self.lstUser.GetSelectedText)>0) then
   if (self.lstUser.GetSelectedText<>pseudo) then
  begin
    SelectedUser := self.lstUser.GetSelectedText;
    i := Pos('(', SelectedUser);
    if(i>0) then
     SelectedUser := Copy(SelectedUser, 1, i-1);
    self.contactMenu.PopUp();
  end;
end;

procedure TUIPalabre.friendMenuItemClick(Sender: TObject);
begin
 launchPrivateForm(SelectedFriend);
end;

procedure TUIPalabre.launchPrivateForm(ps : string);
 var fn : TFriendForm;
     index : shortint;
begin
 index := TMtyApplication.privateMsgForms.FindIndexOf(ps);
 if (index>=0) then
  begin
   TFriendForm(TMtyApplication.privateMsgForms.Find(ps)).Show;
  end
  else
  begin
   fn := TFriendForm.Create(self);
   fn.setFriendPseudo(ps);
   fn.setOwnPseudo(self.pseudo);
   fn.setTitle(ps);
   fn.doConfig();
   TMtyApplication.privateMsgForms.Add(ps, fn);
   fn.Show;
  end;
end;

procedure  TUIPalabre.loadLounge();
  var lst : TLoungeList;
     i : integer;
begin
 lst := stub.getLoungeList();
 cbLounge.Items.Clear;
 for i:=0 to lst.length()-1 do
 begin
  cbLounge.Items.Append(lst.getElement(i).getName());
 end;
end;

procedure TUIPalabre.cbLoungeChange(Sender: TObject);
 var l : TLounge;
begin
   l := TLounge.init();
   l.setName(cbLounge.Text);
   stub.joinLounge(l);
   rtv := -5;
end;

procedure TUIPalabre.cbLoungeClick(Sender: TObject);
begin
end;

procedure TUIPalabre.cbStatusChange(Sender: TObject);
begin
  if (cbStatus.Caption='online') then
  stub.setStatus(online)
else if (cbStatus.Caption='offline') then
  stub.setStatus(offline)
 else if (cbStatus.Caption='busy') then
  stub.setStatus(busy);
end;

procedure TUIPalabre.cbStatusSelect(Sender: TObject);
begin

end;

procedure TUIPalabre.CheckMsgTimerTimer(Sender: TObject);
begin

  CheckMsgTimer.Enabled:= false;
  inc(rtv);
  RetrieveMesg();
  retrievePrivateMsg();
  if(rtv>3) then
  begin
   timerLoadLoungeUser();
   rtv := 0;
  end;
  CheckMsgTimer.Enabled:= true;

end;

procedure TUIPalabre.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  InviteTimer.Enabled:= false;
 CheckMsgTimer.Enabled:= false;
end;

procedure TUIPalabre.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  InviteTimer.Enabled:= false;
 CheckMsgTimer.Enabled:= false;
  TTFormConnex(self.Owner).Show;
end;

procedure TUIPalabre.timerLoadLoungeUser();
 var
      cl : ContactList;
      i : word;
      l : TLounge;
      s : string[10];
begin
   l := TLounge.init();
   l.setName(cbLounge.Items[cbLounge.ItemIndex]);
   cl := stub.getLoungeContacts(l);
   lstUser.Items.Clear;
   if(cl.length()>0) then
   for i:= 0 to cl.length()-1 do
   begin
   if(cl.getElement(i).getStatus().getStatus()=busy) then
    s := '(busy)'
   else
    s:='';
   lstUser.Items.Append(cl.getElement(i).getPseudo()+s);
   end;
end;

procedure TUIPalabre.RetrieveMesg();
var s :TStringList;
 sn, sv : string;
     i : byte;
begin
  s := stub.retrieveMessages();
  for i:=1 to s.Count do
  begin
   s.GetNameValue(0, sn, sv);
   if(length(sn)>0) then
   begin
    msgHistory.Values['['+FormatDateTime('hh:nn:ss', Now)+'@'+sn+'] : '] := sv;
    htmlConv.doTransform();
    loadPage('public.html');
   end;
  end;
  //timerLoadLoungeUser();
end;

procedure TUIPalabre.retrievePrivateMsg();
var  s :TStringList;
     sn, sv : string;
     i : byte;
begin
 s := stub.retrievePrivateMessages();
 for i:=1 to s.Count do
  begin
   s.GetNameValue(0, sn, sv);
   if(length(sn)>0) then
    self.deliverPrivateMsg(sn, sv);
  end;
end;

procedure TUIPalabre.setStub(st : TRPCStube);
begin
  self.stub := st;
end;

procedure TUIPalabre.setPseudo(p : String);
begin
  pseudo:= p;
  self.Caption:= self.Caption +' - '+p;
  self.lblStatus.Caption:= p;
end;

procedure  TUIPalabre.checkInvitation();
 var cl : ContactList;
     i : integer;
     reply, boxstyle: integer;
begin
  boxstyle :=  MB_ICONQUESTION + MB_YESNO;
  cl := stub.getInvitations();
  if(cl.length()>0) then
   for i:=0 to cl.length()-1 do
   begin
       reply := Application.MessageBox(Pchar(cl.getElement(i).getPseudo()+' wants to be your friend. Would you like to?'), 'Invitation', boxstyle);
       if reply = IDYES then
        stub.acceptContact(cl.getElement(i).getPseudo())
       else
        stub.rejectContact(cl.getElement(i).getPseudo());
   end;
end;

procedure TUIPalabre.loadFriends();
 var lst : ContactList;
     i : integer;
     re : boolean;
begin
 re := false;
 lst := stub.getContacts();
 if(lst.length()<>TMtyApplication.clist.length()) then
  re := true;
 if(not re) then
  for i:=0 to lst.length()-1 do
   if(lst.getElement(i).toJson()<>TMtyApplication.clist.getElement(i).toJson()) then
    re := true;
  if not re then
   exit;
 TMtyApplication.clist := lst;
 if(lst.length()>0) then
 for i:=0 to (lst.length()-1) do
 begin
  htmlFriendConv.setSource(lst);
  htmlFriendConv.doTransform();
  displayFriend('friend.html');
 end;

end;

procedure TUIPalabre.Panel2Click(Sender: TObject);
begin

end;

procedure TUIPalabre.btSendClick(Sender: TObject);
 var l : Tlounge;
     i : byte;
begin
  l := TLounge.init();
  l.setName(cbLounge.Text);
  l.setId(1);
  l.setPrivilege(0);
  self.stub.sendMessageToLounge(l, txtMsg.Lines.Text);
  for i:= 0 to txtMsg.Lines.Count-1 do
   txtMsg.Lines.Delete(i);
   txtMsg.Clear;
end;

procedure TUIPalabre.BitBtn1Click(Sender: TObject);
begin
 msgHistory.Clear;
 htmlConv.doTransform();
 loadPage('public.html');
end;

procedure TUIPalabre.Image11Click(Sender: TObject);
begin
  txtMsg.SelText:=':aie:';
end;

procedure TUIPalabre.Image12Click(Sender: TObject);
begin

end;

procedure TUIPalabre.Image13Click(Sender: TObject);
begin
  txtMsg.SelText:=':ccool:';
end;

procedure TUIPalabre.Image16Click(Sender: TObject);
begin
  txtMsg.SelText:=':lun:';
end;

procedure TUIPalabre.Image17Click(Sender: TObject);
begin
  txtMsg.SelText:=':mrgreen:';
end;

procedure TUIPalabre.Image1Click(Sender: TObject);
begin
  txtMsg.SelText:=':)';
end;

procedure TUIPalabre.Image2Click(Sender: TObject);
begin
  txtMsg.SelText:=':D';
end;

procedure TUIPalabre.Image4Click(Sender: TObject);
begin
  txtMsg.SelText:=':(';
end;

procedure TUIPalabre.Image5Click(Sender: TObject);
begin
  txtMsg.SelText:=':lol:';
end;

procedure TUIPalabre.Image6Click(Sender: TObject);
begin
  txtMsg.SelText:=':evil:';
end;

procedure TUIPalabre.Image7Click(Sender: TObject);
begin
  txtMsg.SelText:=':rose:';
end;

procedure TUIPalabre.Image8Click(Sender: TObject);
begin
  txtMsg.SelText:=':angry:';
end;

destructor TUIPalabre.Destroy;
begin
 inherited destroy;
 InviteTimer.Enabled:= false;
 CheckMsgTimer.Enabled:= false;
end;

initialization
  {$I palabreui.lrs}

end.

