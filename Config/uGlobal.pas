unit uGlobal;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Generics.Collections;

type
  TGlobal = class
  public
    test: string;
  //  list: TList;
    constructor Create();
    destructor Destroy; override;
  end;

var
  Global: TGlobal;

implementation

{ TGlobal }

constructor TGlobal.Create();
begin
 // list := TList.Create;
end;

destructor TGlobal.Destroy;
begin
 // list.Clear;
 // list.Free;
  inherited;
end;

end.

