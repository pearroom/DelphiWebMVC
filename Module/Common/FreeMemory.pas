unit FreeMemory;

interface

uses
  System.Classes, System.SysUtils, uConfig, Winapi.Windows, command, superobject,
  Vcl.Forms;

type
  TFreeMemory = class(TThread)
  private
    procedure ClearMemory;
  protected
    procedure Execute; override;
  public
  end;

implementation

{ TFreeMemory }
procedure TFreeMemory.ClearMemory;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    SetProcessWorkingSetSize(GetCurrentProcess, $FFFFFFFF, $FFFFFFFF);
    application.ProcessMessages;
  end;
end;

procedure TFreeMemory.Execute;
var
  k, n: integer;
begin
  k := 0;
  n := auto_free_memory_timer * 60;
  while not Terminated do
  begin
    Sleep(100);
    Inc(k);
    if (k >= n * 10) then
    begin
      k := 0;
      Synchronize(ClearMemory);
    end;

  end;

end;

end.

