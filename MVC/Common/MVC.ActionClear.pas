unit MVC.ActionClear;

interface

uses
  System.Classes, System.SysUtils,MVC.Command;

type
  TActionClear = class(TThread)
  private
    procedure Cleardata();
    { Private declarations }
  protected
    procedure Execute; override;
  public
    isstop: boolean;
  end;

var
  _ActoinClear: TActionClear;

implementation

uses
  MVC.ActionList;

{ TActionClear }

procedure TActionClear.Cleardata;
begin
  _ActionList.ClearAction;
end;

procedure TActionClear.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(10);
    Inc(k);
    if k >= 100 then
    begin
      k := 0;
      Cleardata;

    end;

  end;
end;

end.

