unit MVC.DBPoolClear;

interface

uses
  System.Classes, System.SysUtils;

type
  TDBPoolClear = class(TThread)
  private
    procedure Cleardata();
    { Private declarations }
  protected
    procedure Execute; override;
  public
    isstop: boolean;
  end;

var
  _DBPoolClear: TDBPoolClear;

implementation

uses
  MVC.DBPoolList;

{ TDBPoolClear }

procedure TDBPoolClear.Cleardata;
begin
  _DBPoolList.ClearAction;
end;

procedure TDBPoolClear.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(10);
    Inc(k);
    if k >= 1000 then
    begin
      k := 0;
      Cleardata;

    end;

  end;
  _DBPoolList.isstop:=true;
  Sleep(200);
end;

end.

