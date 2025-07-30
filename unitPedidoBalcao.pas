unit unitPedidoBalcao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, core.Utils.Tipos;

type
  TFrmPedidoBalcao = class(TForm)
    rectToolbar: TRectangle;
    lblTitulo: TLabel;
    btnVoltar: TSpeedButton;
    imgVoltar: TImage;
    Layout1: TLayout;
    lblTelefone: TLabel;
    edtNomeCliente: TEdit;
    lblNomeCliente: TLabel;
    edtTelefone: TEdit;
    rectContinuar: TRectangle;
    btnContinuar: TSpeedButton;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnContinuarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPedidoBalcao: TFrmPedidoBalcao;

implementation

{$R *.fmx}

uses UnitPedido,
     UnitProduto;

procedure TFrmPedidoBalcao.btnContinuarClick(Sender: TObject);
begin
  if edtNomeCliente.Text = '' then
  begin
    showmessage('Informe o Nome');
    exit;
  end;


  if NOT Assigned(FrmProduto) then
        Application.CreateForm(TFrmProduto, FrmProduto);

    FrmProduto.cliente_comanda   := EdtNomeCliente.text;
    FrmProduto.telefone_Cliente  := edtTelefone.Text;
    FrmProduto.TipoAtendimento   := tosBalcao;
    FrmProduto.Show;
end;

procedure TFrmPedidoBalcao.btnVoltarClick(Sender: TObject);
begin
  Close;
end;

end.
