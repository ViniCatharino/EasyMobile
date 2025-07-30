unit UnitConfig;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, uSession;

type
  TFrmConfig = class(TForm)
    rectToolbar: TRectangle;
    btnFechar: TSpeedButton;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Layout1: TLayout;
    edtServidor: TEdit;
    rectSalvar: TRectangle;
    btnSalvar: TSpeedButton;
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmConfig: TFrmConfig;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmConfig.btnFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmConfig.btnSalvarClick(Sender: TObject);
begin
    try
        Dm.SalvarConfig(edtServidor.Text);
        TSession.servidor := edtServidor.Text;
        close;
    except on ex:exception do
        showmessage('Erro ao salvar configurações: ' + ex.Message);
    end;
end;

procedure TFrmConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmConfig := nil;
end;

procedure TFrmConfig.FormShow(Sender: TObject);
begin
    Dm.BuscarConfig;
    edtServidor.Text := Dm.qryConfig.FieldByName('servidor').AsString;
end;

end.
