unit UnitTransferenciaConsumo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, uLoading;

type
  TExecuteOnClose = procedure of object;

  TFrmTransferenciaConsumo = class(TForm)
    rectToolbar: TRectangle;
    Label1: TLabel;
    btnFechar: TSpeedButton;
    Image2: TImage;
    Layout1: TLayout;
    Layout2: TLayout;
    Label2: TLabel;
    edtOrigem: TEdit;
    Layout3: TLayout;
    Label3: TLabel;
    edtDestino: TEdit;
    Image1: TImage;
    rectSalvar: TRectangle;
    btnConfirmar: TSpeedButton;
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConfirmarClick(Sender: TObject);
  private
    FExecuteOnClose: TExecuteOnClose;
    procedure TerminateTransferencia(Sender: TObject);
    { Private declarations }
  public
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmTransferenciaConsumo: TFrmTransferenciaConsumo;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmTransferenciaConsumo.TerminateTransferencia(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    if Assigned(ExecuteOnClose) then
      ExecuteOnClose;

    close;
end;

procedure TFrmTransferenciaConsumo.btnConfirmarClick(Sender: TObject);
var
  id_mesa_origem, id_mesa_destino: integer;
begin
    try
        id_mesa_origem := edtOrigem.Text.ToInteger;
    except
        showmessage('Mesa de origem inválida');
        exit;
    end;

    try
        id_mesa_destino := edtDestino.Text.ToInteger;
    except
        showmessage('Mesa de destino inválida');
        exit;
    end;

    TLoading.Show(FrmTransferenciaConsumo);

    TLoading.ExecuteThread(procedure
    begin
        Dm.TransferirConsumo(id_mesa_origem, id_mesa_destino);

    end, TerminateTransferencia);

end;

procedure TFrmTransferenciaConsumo.btnFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmTransferenciaConsumo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmTransferenciaConsumo := nil;
end;

end.
