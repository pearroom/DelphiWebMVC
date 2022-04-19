unit IndexController;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Classes, MVC.Route,
  MVC.JSON, MVC.Controller, MVC.LogUnit, System.JSON, MVC.DataSet,
  BaseController, MVC.Verify, MVC.Tool, IndexService;

type
  [MURL('')]                                //���ÿ�ֵΪ��Ŀ¼
  TIndexContrller = class(TBaseController)  //�̳и���

  public
    [MURL('index')]                         //index�������������·�������û�����ã�����·��Ϊ�������� ��Ĭ����get��ʽ����
    procedure index;
    procedure login;
    procedure check;                        //check û������ ����·��������check ·������
    procedure verifycode;
    function Intercept: Boolean; override;  //ʵ���Լ��������� �����ﲻ��ȡ���ط��� false
    [MURL('getdata', GET)]                 //��������rqdata��ַ����������post��ʽ��������� getdata ����,
    procedure getdata;
    procedure getone;
    procedure socket;
  end;

implementation




{ TIndexContrller }

procedure TIndexContrller.verifycode;
begin
  ShowText('data:image/jpeg;base64,' + getVCode);
end;

procedure TIndexContrller.check;
var
  vcode, scode: string;
  map: IJObject;
  ds: IDataSet;
  name: string;
begin
  vcode := input('vcode');

  scode := Session.getValue('vcode');
  map := InputToJSON;
  ds := Service.Index.checkuser(map);

  if ds.IsEmpty then
  begin
    Fail(-1, '�˺��������');
  end
  else if vcode.ToUpper = scode.ToUpper then
  begin
    name := ds.DS.FieldByName('realname').Value;
    Session.setValue('username', name);

    Success();
  end
  else
    Fail(-1, '��֤�����');
end;

procedure TIndexContrller.getdata;
begin
  ShowJSON(Service.Index.getdata);
end;

procedure TIndexContrller.getone;
begin

end;

procedure TIndexContrller.index;
var
  jo: IJObject;
  verify: IVerify;
  ret: IJArray;
  msg: string;
  i: Integer;
begin

  SetAttr('username', 'hello');
  SetAttr('kk', '20');
  SetAttr('dd', 'ok');
  jo := IIJObject;
  jo.SetS('name', '���');
  jo.SetS('sex', '��');
  jo.SetS('idcard', '130124198312');
  jo.SetS('phone', '15512132874');
  SetAttr('data', jo);

  verify := IIVerify;
  verify.Add('idcard', VerifyType.vIdCard, '���֤��ʽ����');
  verify.Add('phone', VerifyType.vPhone, '�ֻ��Ŵ���');

  ret := IIJArray();
  if verify.Verify(jo, ret) then
    SetAttr('msg', 'лл֧��')
  else
  begin
    for i := 0 to ret.A.Count - 1 do
      msg := msg + ret.A.Items[i].FindValue('Error').Value + '|';
    SetAttr('msg', msg);
  end;
end;

function TIndexContrller.Intercept: Boolean;
begin
  Result := false;
end;

procedure TIndexContrller.login;
begin
  Session.remove('username');
end;

procedure TIndexContrller.socket;
begin
  Show('socket');
end;

end.

