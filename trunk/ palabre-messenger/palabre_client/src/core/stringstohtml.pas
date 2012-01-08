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
unit StringsToHtml;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Ipfilebroker, ustatus, UContactList;

type
     TStringToHtml = class
                       fileName : String;
                       source : TStringlist;
                      public
                       constructor init(fs : string);
                       procedure setSource(src : TStringlist);
                       procedure doTransform();
                       function getHtml(ns, nv : String) : string;
                     end;

    TContactListToHtml = class
                            fileName : String;
                            source : ContactList;
                           public
                           constructor init(fs : string);
                           procedure setSource(src : ContactList);
                           procedure doTransform();
                           function getHtml(ns : string; nv : TEstatus) : string;
                     end;

implementation

constructor TStringToHtml.init(fs : string);
begin
 fileName:= fs;
end;

procedure TStringToHtml.setSource(src :  TStringlist);
begin
 source := src;
end;

procedure TStringToHtml.doTransform();
 var fls : TextFile;
     i, j : integer;
begin
 assign(fls, fileName);
 rewrite(fls);
 writeln(fls,'<html><head></head><body style="font-size:12px;" bgcolor="edf3f4">');
 if(source.Count>0) then
  for i:=0 to (source.Count-1) do
  begin
   writeln(fls, getHtml(source.Names[i], source.ValueFromIndex[i]));
  end;
 writeln(fls,'</body></html>');
 close(fls);
end;

function TStringToHtml.getHtml(ns, nv : String) : string;
 var s : string;
     i : byte;
     img : string;
     smileys : TStringList;
begin
 smileys := TStringList.Create;
 smileys.LoadFromFile('images/smiley/smiley.db');
 for i:= 0 to smileys.Count-1 do
 begin
  img := '<img width ="17" height="17" src="'+expandLocalHtmlFileName('images/smiley/'+smileys.ValueFromIndex[i])+'">';
  nv:=StringReplace(nv, smileys.Names[i], img, [rfReplaceAll]+[rfIgnoreCase]);
 end;
 s := '<font color="blue"><i>'+ns+'</i></font>';
 s := s+'<font color="07565d">'+nv+'</font>'+'<br/>';
 result := s;
end;

(******************************)
constructor TContactListToHtml.init(fs : string);
begin
 fileName:= fs;
end;

procedure TContactListToHtml.setSource(src : ContactList);
begin
 source := src;
end;

procedure TContactListToHtml.doTransform();
 var fls : TextFile;
     i, j : integer;
begin
 assign(fls, fileName);
 rewrite(fls);
 writeln(fls,'<html><head></head><body style="font-size:14px;" bgcolor="edf3f4">');
 if(source.length()>0) then
  for i:=0 to (source.length()-1) do
  begin
   writeln(fls, getHtml(source.getElement(i).getPseudo(), source.getElement(i).getStatus().getStatus()));
  end;
 writeln(fls,'</body></html>');
 close(fls);
end;

function TContactListToHtml.getHtml(ns : string; nv : TEstatus) : string;
 var s : string;
     href : string;
begin
 case nv of
  online : s :=' <img src="'+expandLocalHtmlFileName('images/status/online.png')+'" width="17" height="17">';
  offline : s :=' <img src="'+expandLocalHtmlFileName('images/status/offline.png')+'" width="17" height="17">';
  busy : s :=' <img src="'+expandLocalHtmlFileName('images/status/busy.png')+'" width="17" height="17">';
 end;
 href:='<b><a href="#'+ns+'">'+ns+'</a></b> ';
 result := s+'&nbsp;'+href+'<br/>';
end;

end.

