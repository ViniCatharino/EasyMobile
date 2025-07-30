unit UnitReservaMesa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, uLoading;

type
  TExecuteOnClose = procedure of object;

  TFrmReservaMesa = class(TForm)
    Layout1: TLayout;
    Label2: TLabel;
    edtMesa: TEdit;
    rectSalvar: TRectangle;
    btnReservar: TSpeedButton;
    rectToolbar: TRectangle;
    Label1: TLabel;
    btnFechar: TSpeedButton;
    Image2: TImage;
    Label3: TLabel;
    edtCliente: TEdit;
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnReservarClick(Sender: TObject);
  private
    FExecuteOnClose: TExecuteOnClose;
    procedure TerminateReserva(Sender: TObject);
    { Private declarations }
  public
    property ExecuteOnClose: TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmReservaMesa: TFrmReservaMesa;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmReservaMesa.TerminateReserva(Sender: TObject);
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

procedure TFrmReservaMesa.btnFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmReservaMesa.btnReservarClick(Sender: TObject);
var
  id_mesa: integer;
begin
    try
        id_mesa := edtMesa.Text.ToInteger;
    except
        showmessage('Número da mesa inválido');
        exit;
    end;

    if (edtCliente.Text = '') then
    begin
        showmessage('Informe o nome do cliente');
        exit;
    end;

    TLoading.Show(FrmReservaMesa);

    TLoading.ExecuteThread(procedure
    begin
        Dm.ReservarMesa(id_mesa, edtCliente.Text);

    end, TerminateReserva);

end;

procedure TFrmReservaMesa.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmReservaMesa := nil;
end;

end.
