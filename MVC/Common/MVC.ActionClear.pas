unit MVC.ActionClear;

interface

uses
  System.Classes, System.SysUtils,MVC.LogUnit;

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

    try
      Inc(k);
      if k >= 1000 then
      begin
        k := 0;
        try
          Cleardata;
        except
          on e: Exception do
            log(e.Message);
        end;
      end;
    finally
      Sleep(10);
    end;
  end;
  _ActionList.isstop := true;
  Sleep(200);
end;

end.

