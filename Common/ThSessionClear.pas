unit ThSessionClear;

interface

uses
  System.Classes, System.SysUtils, uConfig, Winapi.Windows, command, superobject;

type
  TThSessionClear = class(TThread)
  private
    procedure clearMap;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    isstop: boolean;
  end;

implementation

{ TThSession }
procedure TThSessionClear.clearMap();
var
  i: integer;
begin
  try
    if SessionListMap <> nil then
    begin
      for i := 0 to SessionListMap.Count - 1 do
      begin
        if Now() >= SessionListMap.item(i).timerout then
        begin
          log('«Â¿ÌSession'+SessionListMap.item(i).SessionID);
          SessionListMap.remove(i);
        end;
      end;
    end;
  except
    Exit;
  end;
end;

procedure TThSessionClear.Execute;
begin
  FreeOnTerminate := true;
  while not Terminated do
  begin
    try
      Synchronize(clearMap);
    finally
      Sleep(60000);
    end;

  end;
end;

end.

