unit UTrueHashTable;
 {$mode objfpc}{$H+}

interface

uses SysUtils, Classes;

type

   TTrueHash = class
                name : string;
                value : TObject;
                next : TTrueHash;
               end;

const
   TABLE_SIZE = 30;

type TTrueHashTable = class
    private
        hashtable : array[0..TABLE_SIZE - 1] of TTrueHash;
        function hash(s : string) : longint;
    public
        constructor Create;
        function store(name : string; value : TObject; var error : longint) : boolean;
        function fetch(name : string;  value : TObject) : boolean;
        function remove(name : string) : boolean;
        function exists(name : string) : boolean;
end;

implementation

constructor TTrueHashTable.Create;
var
   i : longint;
begin
 for i := 0 to TABLE_SIZE - 1 do
 begin
    hashtable[i] := TTrueHash.Create;
    hashtable[i].next :=nil;
 end;
end;


function TTrueHashTable.hash(s : string) : longint;
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

function TTrueHashTable.store(name : string; value : TObject; var error : longint) : boolean;
var
   node, prev : TTrueHash;
begin
   error := 0;
   prev :=TTrueHash.Create;
   prev := hashtable[hash(name)];
   node := prev.next;

   while (node <> nil) and (node.name <> name) do
   begin
      prev := node;
      node := node.next;
   end;

   if node <> nil then error := 1
   else begin
      prev.next := TTrueHash.Create;
      node := prev.next;
      if node = nil then error := -1
      else begin
         node.name := name;
     node.value := value;
     node.next := nil;
      end;
   end;

   Result := error = 0;
end;

function TTrueHashTable.fetch(name : string; value : TObject) : boolean;
var
   node : TTrueHash;
begin
   node := hashtable[hash(name)].next;
   while (node <> nil) and (node.name <> name) do
      node := node.next;
   if node <> nil then value := node.value;
   Result := node <> nil;
end;

function TTrueHashTable.exists(name : string) : boolean;
var
   node : TTrueHash;
begin
   node := hashtable[hash(name)].next;
   while (node <> nil) and (node.name <> name) do
      node := node.next;
   Result := node <> nil;
end;

function TTrueHashTable.remove(name : string) : boolean;
 var
   node, node2 : TTrueHash;
begin
  Result := false;
  node := hashtable[hash(name)].next;
  node2 := node;
   while (node2 <> nil) and (node2.name <> name) do
   begin
      node := node2;
      node2 := node2.next;
   end;
   if (node2=node) then
    hashtable[hash(name)].next := nil
   else
   begin
    node.next := node2.next;
    Result := true;
   end;
end;

end.
