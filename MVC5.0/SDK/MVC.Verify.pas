unit MVC.Verify;

interface

uses
  System.SysUtils, System.DateUtils, System.Classes, System.StrUtils,
  System.Generics.Collections, MVC.JSON, System.RegularExpressions, System.JSON;

type
  TVerifyType = record
    vNumber: string; //数字格式
    vIdCard: string; //身份证格式
    vPhone: string; //身份证格式
    vEmail: string; //电子邮件格式
    vURL: string; //网址格式
    vTel: string; //固定电话格式
    vChina: string; //汉字格式
    vMonth: string; //月格式12月内
    vDay: string; //日格式31天内

    procedure init; //数据初始化
  end;

  IVerify = interface
    ['{8D7D66E0-EE72-4850-AD5C-1FFF3CEFD52F}']
    procedure Add(sKey: string; sVerify: string; sErrMsg: string);
    function Verify(sParam: IJObject; var retArr: IJArray): boolean;
  end;

  TVerifyItem = class
  private
    Fkey: string;
    FerrMsg: string;
    Ftext: string;
    procedure SeterrMsg(const Value: string);
    procedure Setkey(const Value: string);
    procedure Settext(const Value: string);
  public
    property key: string read Fkey write Setkey;
    property text: string read Ftext write Settext;
    property errMsg: string read FerrMsg write SeterrMsg;
  end;

  TVerify = class(TInterfacedObject, IVerify)
  private
    FData: TObjectList<TVerifyItem>;
    function check(value: string; sVerify: string): Boolean;
  public
    procedure Add(sKey: string; sVerify: string; sErrMsg: string);
    function Verify(sParam: IJObject; var retArr: IJArray): boolean;
    constructor Create();
    destructor Destroy; override;
  end;

var
  VerifyType: TVerifyType;

function IIVerify: IVerify;

implementation

function IIVerify: IVerify;
begin
  result := Tverify.create as IVerify;
end;
{ TVerify }

procedure TVerify.Add(sKey, sVerify, sErrMsg: string);
var
  vData: TVerifyItem;
begin
  vData := TVerifyItem.Create;
  vData.key := sKey;
  vData.text := sVerify;
  vData.errMsg := sErrMsg;
  FData.Add(vData);
end;

function TVerify.check(value, sVerify: string): Boolean;
var
  matchs: TMatchCollection;
begin
  matchs := TRegEx.Matches(value, sVerify, [roIgnoreCase]);
  Result := matchs.Count > 0;
end;

constructor TVerify.Create();
begin
  FData := TObjectList<TVerifyItem>.Create;
end;

destructor TVerify.Destroy;
begin
  FData.Clear;
  FData.Free;
  inherited;
end;

function TVerify.Verify(sParam: IJObject; var retArr: IJArray): boolean;
var
  item: TVerifyItem;
  jo: TJSONObject;
  key, value, verifi, err: string;
  isSucc: boolean;
begin
  isSucc := true;
  for item in FData do
  begin
    key := item.key;
    value := sParam.GetS(key);
    verifi := item.text;
    err := item.errMsg;
    if not check(value, verifi) then
    begin
      jo := TJSONObject.Create;
      jo.AddPair('Key', key);
      jo.AddPair('Error', err);
      retArr.A.Add(jo);
      if isSucc then
        isSucc := false;
    end;
  end;
  Result := isSucc;
end;

{ TVerifyItem }

procedure TVerifyItem.SeterrMsg(const Value: string);
begin
  FerrMsg := Value;
end;

procedure TVerifyItem.Setkey(const Value: string);
begin
  Fkey := Value;
end;

procedure TVerifyItem.Settext(const Value: string);
begin
  Ftext := Value;
end;

{ TVerifyType }

procedure TVerifyType.init;
begin
  self.vNumber := '^\+?[1-9][0-9]*$'; //非0正整数
  self.vIdCard := '^\d{15}|\d{18}$';
  self.vPhone := '^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$';
  self.vEmail := '^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$';
  self.vURL := '^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$';
  self.vTel := '^(\(\d{3,4}-)|\d{3.4}-)?\d{7,8}$';
  self.vChina := '^[\u4e00-\u9fa5]{0,}$';
  self.vDay := '^((0?[1-9])|((1|2)[0-9])|30|31)$';
  self.vMonth := '^(0?[1-9]|1[0-2])$';
end;

initialization
  VerifyType.init;

end.

