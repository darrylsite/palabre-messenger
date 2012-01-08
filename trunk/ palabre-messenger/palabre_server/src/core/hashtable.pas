unit hashtable;
 {$mode objfpc}{$H+}
(**
  thanks to http://dada.perl.it/shootout/fpascal_allsrc.html for the source code
  I modify the code to fit my needs
**)
 interface
uses SysUtils, Classes;

type

   THashEntryPtr = ^THashEntryRec;
   THashEntryRec = record
      name : string;
      number : TMethod;
      next : THashEntryPtr;
   end;

const
   TABLE_SIZE = 100;

type THash = class
    private
        hashtable : array[0..TABLE_SIZE - 1] of THashEntryRec;
        function hash(s : string) : longint;
    public
        constructor Create;
        function store(name : string; number : TMethod; var error : longint) : boolean;
        function fetch(name : string; var number : TMethod) : boolean;
        function exists(name : string) : boolean;
end;

implementation

constructor THash.Create;
var
   i : longint;
begin
   for i := 0 to TABLE_SIZE - 1 do
      hashtable[i].next := nil;
end;


function THash.hash(s : string) : longint;
var
   i, j : longint;
begin
    if length(s) = 0 then Result := 0
    else
    begin
        j := ord(s[1]) mod TABLE_SIZE;
        for i := 2 to length(s) do
            j := (j shl 8 + ord(s[i])) mod TABLE_SIZE;
        Result := j;
    end;
end;

function THash.store(name : string; number : TMethod; var error : longint) : boolean;
var
   node, prev : THashEntryPtr;
begin
   error := 0;

   prev := @hashtable[hash(name)];
   node := prev^.next;

   while (node <> nil) and (node^.name <> name) do
   begin
      prev := node;
      node := node^.next;
   end;

   if node <> nil then error := 1
   else begin
      new(prev^.next);
      node := prev^.next;
      if node = nil then error := -1
      else begin
         node^.name := name;
     node^.number := number;
     node^.next := nil;
      end;
   end;

   Result := error = 0;
end;

function THash.fetch(name : string; var number : TMethod) : boolean;
var
   node : THashEntryPtr;
begin
   node := hashtable[hash(name)].next;
   while (node <> nil) and (node^.name <> name) do
      node := node^.next;
   if node <> nil then number := node^.number;
   Result := node <> nil;
end;

function THash.exists(name : string) : boolean;
var
   node : THashEntryPtr;
begin
   node := hashtable[hash(name)].next;
   while (node <> nil) and (node^.name <> name) do
      node := node^.next;
   Result := node <> nil;
end;

end.
