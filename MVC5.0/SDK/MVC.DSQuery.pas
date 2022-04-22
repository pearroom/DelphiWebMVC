unit MVC.DSQuery;

interface

uses
  FireDAC.Phys.FBDef, FireDAC.Phys.FB, FireDAC.DApt, Data.DB,
  FireDAC.Comp.Client;

type
  TDSQuery = class(TFDQuery)
  private
    function GetB(key: string): boolean;
    function GetD(key: string): TDateTime;
    function GetF(key: string): double;
    function GetI(key: string): integer;
    function GetS(key: string): string;
    procedure SetB(key: string; const Value: boolean);
    procedure SetD(key: string; const Value: TDateTime);
    procedure SetF(key: string; const Value: double);
    procedure SetI(key: string; const Value: integer);
    procedure SetS(key: string; const Value: string);
  public
    property S[key: string]: string read GetS write SetS;
    property I[key: string]: integer read GetI write SetI;
    property B[key: string]: boolean read GetB write SetB;
    property D[key: string]: TDateTime read GetD write SetD;
    property F[key: string]: double read GetF write SetF;
  end;

implementation
{ TDSQuery }

function TDSQuery.GetB(key: string): boolean;
begin
  Result := FieldByName(key).value;
end;

function TDSQuery.GetD(key: string): TDateTime;
begin
  Result := FieldByName(key).value;
end;

function TDSQuery.GetF(key: string): double;
begin
  Result := FieldByName(key).value;
end;

function TDSQuery.GetI(key: string): integer;
begin
  Result := FieldByName(key).value;
end;

function TDSQuery.GetS(key: string): string;
begin
  Result := FieldByName(key).value;
end;

procedure TDSQuery.SetB(key: string; const Value: boolean);
begin
  FieldByName(key).Value := Value;
end;

procedure TDSQuery.SetD(key: string; const Value: TDateTime);
begin
  FieldByName(key).Value := Value;
end;

procedure TDSQuery.SetF(key: string; const Value: double);
begin
  FieldByName(key).Value := Value;
end;

procedure TDSQuery.SetI(key: string; const Value: integer);
begin
  FieldByName(key).Value := Value;
end;

procedure TDSQuery.SetS(key: string; const Value: string);
begin
  FieldByName(key).Value := Value;
end;

end.

