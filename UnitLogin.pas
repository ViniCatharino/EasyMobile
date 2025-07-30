unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Edit,
  uLoading, uSession, FMX.DialogService, FMX.Consts;

type
  TFrmLogin = class(TForm)
    Layout1: TLayout;
    Image1: TImage;
    Layout2: TLayout;
    btnConfig: TSpeedButton;
    Image2: TImage;
    Layout3: TLayout;
    Label1: TLabel;
    edtLogin: TEdit;
    Label2: TLabel;
    edtSenha: TEdit;
    rectLogin: TRectangle;
    btnLogin: TSpeedButton;
    Timer: TTimer;
    procedure btnLoginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConfigClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    procedure TerminateLogin(Sender: TObject);
    procedure TeminateCargaAdicionais(Sender: TObject);
    procedure OpenMainForm;
    procedure TranslateConsts;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitConfig, DataModule.Global;

procedure TFrmLogin.TranslateConsts;
var
  lStrList: TStringList;
begin
  lStrList := TStringList.Create;
  lStrList.AddPair(SMsgDlgInformation, 'Informação');
  lStrList.AddPair(SMsgDlgError,       'Erro');
  lStrList.AddPair(SMsgDlgConfirm,     'Confirmação');
  lStrList.AddPair(SMsgDlgWarning,     'Atenção');
  lStrList.AddPair(SMsgDlgYes,         'Sim');
  lStrList.AddPair(SMsgDlgNo,          'Não');
  lStrList.AddPair(SMsgDlgCancel,      'Cancelar');
  lStrList.AddPair(SMsgDlgClose,       'Fechar');
  lStrList.AddPair(SMsgDlgOK,          'OK');
  lStrList.AddPair(SMsgDlgHelp,        'Ajuda');
  lStrList.AddPair(SMsgDlgHelpHelp,    'Ajuda');

  LoadLangFromStrings(lStrList);
  lStrList.Free;
end;

procedure TFrmLogin.OpenMainForm;
begin
    try
        Dm.BuscarConfig;
        TSession.servidor := Dm.qryConfig.FieldByName('servidor').AsString;

        Dm.ListarUsuario;
    except on ex:exception do
      begin
          showmessage(ex.Message);
          exit;
      end;
    end;

    if Dm.qryUsuario.FieldByName('token').AsString <> '' then
    begin
        if NOT Assigned(FrmPrincipal) then
            Application.CreateForm(TFrmPrincipal, FrmPrincipal);

        TSession.id_usuario := Dm.qryUsuario.FieldByName('id_usuario').AsInteger;
        TSession.nome       := Dm.qryUsuario.FieldByName('nome').AsString;
        TSession.login      := Dm.qryUsuario.FieldByName('login').AsString;
        TSession.token      := Dm.qryUsuario.FieldByName('token').AsString;

//         TLoading.Show(FrmLogin);
         TLoading.ExecuteThread(procedure
         begin
            Dm.ListarAdicionais;

            Dm.InserirAdicional(Dm.TabAdicionais.FieldByName('id_adicional').AsInteger,
                                Dm.TabAdicionais.FieldByName('nome').AsString,
                                Dm.TabAdicionais.FieldByName('descricao').AsString,
                                Dm.TabAdicionais.FieldByName('valor').AsFloat);

         end, TeminateCargaAdicionais);

        Application.MainForm := FrmPrincipal;
        FrmPrincipal.Show;
        FrmLogin.Close;
    end;

end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmLogin := nil;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
    TranslateConsts;
    Timer.Enabled := true;
end;

procedure TFrmLogin.TeminateCargaAdicionais(Sender: TObject);
begin
//  TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;
end;

procedure TFrmLogin.TerminateLogin(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    OpenMainForm;
end;

procedure TFrmLogin.TimerTimer(Sender: TObject);
begin
    Timer.Enabled := false;
    OpenMainForm;
end;

procedure TFrmLogin.btnConfigClick(Sender: TObject);
begin
    if NOT Assigned(FrmConfig) then
        Application.CreateForm(TFrmConfig, FrmConfig);

    FrmConfig.Show;
end;

procedure TFrmLogin.btnLoginClick(Sender: TObject);
begin
    if (Tsession.servidor = '') then
    begin
        showmessage('Servidor não configurado no aplicativo');
        exit;
    end;

    TLoading.Show(FrmLogin);

    TLoading.ExecuteThread(procedure
    begin
        Dm.Login(edtLogin.Text, edtSenha.Text);

        Dm.ExcluirUsuario;

        Dm.InserirUsuario(Dm.TabUsuario.FieldByName('id_usuario').AsInteger,
                          Dm.TabUsuario.FieldByName('nome').AsString,
                          Dm.TabUsuario.FieldByName('login').AsString,
                          Dm.TabUsuario.FieldByName('token').AsString);

    end, TerminateLogin);
end;

end.
