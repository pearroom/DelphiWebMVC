unit uGlobal;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Generics.Collections;

type
  TGlobal = class
  public
    test: string;
    // 这里可以存储一些全局变量或全局类
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
  //类的创建
 // list := TList.Create;
end;

destructor TGlobal.Destroy;
var
  i: Integer;
begin
  //类的释放
 // list.Clear;
 // list.Free;
  inherited;
end;

end.

