unit UnitMesaAbertura;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts,
  FMX.ListBox, uLoading, uListboxLayout, Core.Utils.Tipos;

type
  TExecuteOnClose = procedure of object;

  TFrmMesaAbertura = class(TForm)
    TabControl: TTabControl;
    TabAbertura: TTabItem;
    TabComanda: TTabItem;
    Rectangle1: TRectangle;
    rectToolbar: TRectangle;
    lblTitulo: TLabel;
    btnFechar: TSpeedButton;
    Image2: TImage;
    Layout1: TLayout;
    edtComanda: TEdit;
    Label3: TLabel;
    rectSalvar: TRectangle;
    btnAbrirComanda: TSpeedButton;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    lblTitulo2: TLabel;
    btnFechar2: TSpeedButton;
    Image1: TImage;
    Layout2: TLayout;
    Label2: TLabel;
    btnNovaComanda: TSpeedButton;
    Image3: TImage;
    rectFechamento: TRectangle;
    btnFechamento: TSpeedButton;
    lbComandas: TListBox;
    rectReserva: TRectangle;
    btnReserva: TSpeedButton;
    lblReserva: TLabel;
    TabDesativada: TTabItem;
    Rectangle4: TRectangle;
    Label1: TLabel;
    btnFecharDesativ: TSpeedButton;
    Image4: TImage;
    lblTelefone: TLabel;
    edtTelefone: TEdit;
    procedure FormShow(Sender: TObject);
    procedure lbComandasItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFechamentoClick(Sender: TObject);
    procedure btnReservaClick(Sender: TObject);
    procedure btnAbrirComandaClick(Sender: TObject);
    procedure btnFecharDesativClick(Sender: TObject);
    procedure btnNovaComandaClick(Sender: TObject);
  private
    Fid_mesa: integer;
    FExecuteOnClose: TExecuteOnClose;
    Ftelefone_Cliente : string;
    FTipoAberturaTela : TTipoAberturaTelaProduto;
    procedure RefreshComandas;
    procedure TerminateComanda(Sender: TObject);
    procedure TerminateCancelarReserva(Sender: TObject);
    procedure TerminateAbrirComanda(Sender: TObject);
    procedure FecharTela;
    { Private declarations }
  public
    property id_mesa          : integer         read Fid_mesa          write Fid_mesa;
    property ExecuteOnClose   : TExecuteOnClose read FExecuteOnClose   write FExecuteOnClose;
    property telefone_Cliente : string          read Ftelefone_Cliente write Ftelefone_Cliente;
    property TipoAberturaTela : TTipoAberturaTelaProduto read FTipoAberturaTela write FTipoAberturaTela;
  end;

var
  FrmMesaAbertura: TFrmMesaAbertura;

implementation

{$R *.fmx}

uses
  UnitFrameComanda,
  UnitProduto,
  UnitFechamento,
  DataModule.Global,
  FMX.DialogService;



procedure TFrmMesaAbertura.TerminateComanda(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;


    // Lista das comandas
    if dm.TabComanda.RecordCount > 0 then
    begin
      TabControl.ActiveTab := TabComanda;

      dm.TabComanda.First;
      while NOT dm.TabComanda.Eof do
      begin
        AddComandaListbox(lbComandas,
                          dm.TabComanda.FieldByName('id_comanda').AsInteger,
                          dm.TabComanda.FieldByName('cliente_comanda').AsString,
                          dm.TabComanda.FieldByName('vl_total').AsFloat);

        dm.TabComanda.next;
      end;
    end
    else
      TabControl.ActiveTab := TabAbertura;

    // Reserva
    if dm.TabMesa.FieldByName('status').AsString = 'R' then
    begin
      lblReserva.Text := 'Mesa reservada para ' +
                         dm.TabMesa.FieldByName('nome_reserva').AsString;
    end
    else
    // Mesa desativada
    if dm.TabMesa.FieldByName('status').AsString = 'D' then
      TabControl.ActiveTab := TabDesativada
    else
    begin
      lblReserva.Visible := false;
      rectReserva.Visible := false;
    end;

    // Titulos
    lblTitulo.Text  := 'Mesa ' + dm.TabMesa.FieldByName('numero_mesa').AsString;
    lblTitulo2.Text := 'Mesa ' + dm.TabMesa.FieldByName('numero_mesa').AsString;
end;

procedure TFrmMesaAbertura.TerminateAbrirComanda(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    TabControl.GotoVisibleTab(1);
    RefreshComandas;
end;

procedure TFrmMesaAbertura.btnAbrirComandaClick(Sender: TObject);
begin
  if (edtComanda.Text = '') then
  begin
    showmessage('Informe o nome do cliente ou a comanda');
    exit;
  end;

  TLoading.Show(FrmMesaAbertura);

  TLoading.ExecuteThread(procedure
  begin
    Dm.AbrirComanda(id_mesa, edtComanda.Text, edtTelefone.Text,tosSalao);
  end,
  TerminateAbrirComanda);

end;

procedure TFrmMesaAbertura.FecharTela;
begin
  close;
end;

procedure TFrmMesaAbertura.btnFechamentoClick(Sender: TObject);
begin
    if NOT Assigned(FrmFechamento) then
        Application.CreateForm(TFrmFechamento, FrmFechamento);

    FrmFechamento.ExecuteCloseMesa := FecharTela;
    FrmFechamento.id_mesa := id_mesa;
    FrmFechamento.Show;
end;

procedure TFrmMesaAbertura.btnFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmMesaAbertura.btnFecharDesativClick(Sender: TObject);
begin
    close;
end;

procedure TFrmMesaAbertura.btnNovaComandaClick(Sender: TObject);
begin
    TabControl.GotoVisibleTab(0);
end;

procedure TFrmMesaAbertura.TerminateCancelarReserva(Sender: TObject);
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

procedure TFrmMesaAbertura.btnReservaClick(Sender: TObject);
begin
  TDialogService.MessageDialog('Confirma cancelamento da reserva?',
                               TMsgDlgType.mtConfirmation,
                               [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                               TMsgDlgBtn.mbNo,
                               0,
                               procedure (const AResult: TModalResult)
                               begin
                                  if AResult = mrYes then
                                  begin
                                    TLoading.Show(FrmMesaAbertura);

                                    TLoading.ExecuteThread(procedure
                                    begin
                                      Dm.CancelarReserva(id_mesa);
                                    end,
                                    TerminateCancelarReserva);
                                  end;
                               end);
end;

procedure TFrmMesaAbertura.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Dm.TabMesa.Active then
    Dm.TabMesa.EmptyDataSet;

  if Dm.TabComanda.Active then
    Dm.TabComanda.EmptyDataSet;

  if Assigned(ExecuteOnClose) then
    ExecuteOnClose;

  Action := TCloseAction.caFree;
  FrmMesaAbertura := nil;
end;

procedure TFrmMesaAbertura.FormShow(Sender: TObject);
begin
  RefreshComandas;
end;

procedure TFrmMesaAbertura.lbComandasItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    if NOT Assigned(FrmProduto) then
        Application.CreateForm(TFrmProduto, FrmProduto);

    FrmProduto.ExecuteOnClose   := RefreshComandas;
    FrmProduto.id_mesa          := id_mesa;
    FrmProduto.cliente_comanda  := item.TagString;
    FrmProduto.id_comanda       := item.Tag;
    FrmProduto.TipoAtendimento  := tosSalao;
    frmProduto.TipoAberturaTela := tapInserirItem;
    FrmProduto.Show;
end;

procedure TFrmMesaAbertura.RefreshComandas;
begin
    lbComandas.Items.Clear;

    TLoading.Show(FrmMesaAbertura);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarMesaId(id_mesa);
    end,
    TerminateComanda);
end;

end.
