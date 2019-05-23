unit MHashMap;

interface

uses
  SynCommons;

type
  TMHashMap = Variant;

procedure MHashMapNew(var map: TMHashMap);

implementation

procedure MHashMapNew(var map: TMHashMap);
begin
  TDocVariant.New(map);
end;

end.

