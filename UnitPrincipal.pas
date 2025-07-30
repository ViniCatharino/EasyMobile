unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts,
  FMX.ListBox, uLoading, uActionSheet, Core.Utils.Tipos;

type
  TFrmPrincipal = class(TForm)
    TabControl: TTabControl;
    Tab1: TTabItem;
    Tab2: TTabItem;
    Tab3: TTabItem;
    rectFundo1: TRectangle;
    rectToolbar: TRectangle;
    Label1: TLabel;
    Layout1: TLayout;
    Label2: TLabel;
    edtMesa: TEdit;
    rectSalvar: TRectangle;
    btnDetalhesMesa: TSpeedButton;
    Rectangle1: TRectangle;
    btnCardapio: TSpeedButton;
    rectAbas: TRectangle;
    imgAba1: TImage;
    imgAba3: TImage;
    imgAba2: TImage;
    rectFundo2: TRectangle;
    Rectangle3: TRectangle;
    Label3: TLabel;
    btnMenuMesas: TSpeedButton;
    Image2: TImage;
    lbMesas: TListBox;
    rectAba3: TRectangle;
    Rectangle4: TRectangle;
    Label4: TLabel;
    rectMenuConfig: TRectangle;
    Label5: TLabel;
    Image1: TImage;
    rectMenuLogout: TRectangle;
    Label6: TLabel;
    Image3: TImage;
    StyleBook1: TStyleBook;
    btnRefreshMesas: TSpeedButton;
    Image4: TImage;
    procedure imgAba1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lbMesasItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure rectMenuConfigClick(Sender: TObject);
    procedure rectMenuLogoutClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnMenuMesasClick(Sender: TObject);
    procedure btnRefreshMesasClick(Sender: TObject);
    procedure btnDetalhesMesaClick(Sender: TObject);
    procedure btnCardapioClick(Sender: TObject);
  private
    menu_mesas: TActionSheet;
    FTipoAberturaTela : TTipoAberturaTelaProduto;
    procedure SelecionarAba(Img: TImage);
    procedure AddMesaListbox(id_mesa: integer; mesa, status, descr_status, cor,
                            nome_reserva: string; total: double);
    procedure RefreshMesas;
    procedure TerminateMesas(Sender: TObject);
    procedure Logout;
    procedure MontaMenuMesas;
    procedure ClickTransferirConsumo(Sender: TObject);
    procedure ClickReservaMesas(Sender: TObject);
    procedure ClickPedidoBalcao(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    property TipoAberturaTela: TTipoAberturaTelaProduto read FTipoAberturaTela write FTipoAberturaTela;

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses UnitFrameMesa, UnitConfig, UnitLogin, UnitTransferenciaConsumo,
  UnitReservaMesa, UnitMesaAbertura, DataModule.Global, UnitProduto,
  unitPedidoBalcao;

procedure TFrmPrincipal.ClickTransferirConsumo(Sender: TObject);
begin
    menu_mesas.HideMenu;

    if NOT Assigned(FrmTransferenciaConsumo) then
        Application.CreateForm(TFrmTransferenciaConsumo, FrmTransferenciaConsumo);

    FrmTransferenciaConsumo.ExecuteOnClose := RefreshMesas;
    FrmTransferenciaConsumo.Show;
end;

procedure TFrmPrincipal.ClickReservaMesas(Sender: TObject);
begin
    menu_mesas.HideMenu;

    if NOT Assigned(FrmReservaMesa) then
        Application.CreateForm(TFrmReservaMesa, FrmReservaMesa);

    FrmReservaMesa.ExecuteOnClose := RefreshMesas;
    FrmReservaMesa.Show;
end;

procedure TFrmPrincipal.btnCardapioClick(Sender: TObject);
begin
    if NOT Assigned(FrmProduto) then
        Application.CreateForm(TFrmProduto, FrmProduto);

    FrmProduto.ExecuteOnClose  := nil;
    FrmProduto.id_mesa         := 0;
    FrmProduto.cliente_comanda := 'Consultar Cardápio';
    FrmProduto.id_comanda      := 0;
    FrmProduto.TipoAberturaTela := TTipoAberturaTelaProduto.tapConsultaCardapio;
    FrmProduto.Show;
end;

procedure TFrmPrincipal.btnDetalhesMesaClick(Sender: TObject);
begin
    try
        edtMesa.Text.ToInteger;
    except
        showmessage('Número da mesa inválido');
        exit;
    end;

    if NOT Assigned(FrmMesaAbertura) then
        Application.CreateForm(TFrmMesaAbertura, FrmMesaAbertura);

    FrmMesaAbertura.id_mesa := edtMesa.Text.ToInteger;
    FrmMesaAbertura.ExecuteOnClose := nil;
    FrmMesaAbertura.Show;
    edtMesa.Text := '';
end;

procedure TFrmPrincipal.btnMenuMesasClick(Sender: TObject);
begin
    menu_mesas.ShowMenu;
end;

procedure TFrmPrincipal.btnRefreshMesasClick(Sender: TObject);
begin
    RefreshMesas;
end;

procedure TFrmPrincipal.MontaMenuMesas;
begin
    menu_mesas := TActionSheet.Create(FrmPrincipal);

    menu_mesas.TitleFontSize := 12;
    menu_mesas.TitleMenuText := 'Mesas';
    menu_mesas.TitleFontColor := $FFA3A3A3;

    menu_mesas.CancelMenuText := 'Cancelar';
    menu_mesas.CancelFontSize := 15;
    menu_mesas.CancelFontColor := $FF4162FF;

    menu_mesas.BackgroundOpacity := 0.5;
    menu_mesas.MenuColor := $FFFFFFFF;

    menu_mesas.AddItem('', 'Transferir Consumo',
                      ClickTransferirConsumo, $FF4A70F7, 15);
    menu_mesas.AddItem('', 'Reserva de Mesas',
                      ClickReservaMesas, $FF4A70F7, 15);

    menu_mesas.AddItem('', 'Novo Pedido Balcão',
                      ClickPedidoBalcao, $FF4A70F7, 15);
end;

procedure TFrmPrincipal.ClickPedidoBalcao(Sender: TObject);
begin
    menu_mesas.HideMenu;

    if NOT Assigned(FrmPedidoBalcao) then
        Application.CreateForm(TFrmPedidoBalcao, FrmPedidoBalcao);


    FrmPedidoBalcao.Show;

end;

procedure TFrmPrincipal.AddMesaListbox(id_mesa: integer;
                                mesa, status, descr_status, cor, nome_reserva: string;
                                total: double);
var
  item: TListBoxItem;
  frame: TFrameMesa;
  rodape: string;
begin
    // Calcula texto do rodape
    if status = 'O' then
        rodape := FormatFloat('#,##0.00', total)
    else if status = 'R' then
        rodape := nome_reserva
    else
        rodape := '';

    // Item da listbox
    item := TListBoxItem.Create(lbMesas);
    item.Text := '';
    item.Height := 110;
    item.Tag := id_mesa;
    item.TagString := mesa;
    item.Selectable := false;

    // Frame
    frame := TFrameMesa.Create(item);
    frame.lblStatus.Text := descr_status;
    frame.lblMesa.Text := mesa;
    frame.lblRodape.Text := rodape;

    // Tratamento cor dos status
    frame.rectMesa.Fill.Color := TAlphaColor(StrToInt(cor));

    item.AddObject(frame);

    lbMesas.AddObject(item);
end;

procedure TFrmPrincipal.TerminateMesas(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    while NOT Dm.TabMesa.Eof do
    begin
        AddMesaListbox(Dm.TabMesa.FieldByName('id_mesa').AsInteger,
                       FormatFloat('00', Dm.TabMesa.FieldByName('numero_mesa').AsInteger),
                       Dm.TabMesa.FieldByName('status').AsString,
                       Dm.TabMesa.FieldByName('descr_status').AsString,
                       Dm.TabMesa.FieldByName('cor').AsString,
                       Dm.TabMesa.FieldByName('nome_reserva').AsString,
                       Dm.TabMesa.FieldByName('vl_total').AsFloat);

        Dm.TabMesa.Next;
    end;
end;

procedure TFrmPrincipal.RefreshMesas;
begin
    lbMesas.Items.Clear;

    TLoading.Show(FrmPrincipal);

    TLoading.ExecuteThread(procedure
    begin
        Dm.ListarMesas;
    end,
    TerminateMesas);
end;

procedure TFrmPrincipal.SelecionarAba(Img: TImage);
begin
    imgAba1.Opacity := 0.3;
    imgAba2.Opacity := 0.3;
    imgAba3.Opacity := 0.3;
    Img.Opacity := 1;

    TabControl.GotoVisibleTab(Img.Tag);

    if Img.Tag = 1 then
        RefreshMesas;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
    SelecionarAba(imgAba1);
    MontaMenuMesas;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
    menu_mesas.Free;
end;

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
    lbMesas.Columns := Trunc(lbMesas.Width / 110);
end;

procedure TFrmPrincipal.imgAba1Click(Sender: TObject);
begin
    SelecionarAba(TImage(Sender));
end;

procedure TFrmPrincipal.lbMesasItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    if NOT Assigned(FrmMesaAbertura) then
        Application.CreateForm(TFrmMesaAbertura, FrmMesaAbertura);

    FrmMesaAbertura.id_mesa          := item.Tag;
    FrmMesaAbertura.ExecuteOnClose   := RefreshMesas;
    frmMesaAbertura.TipoAberturaTela := tapInserirItem;
    FrmMesaAbertura.Show;
end;

procedure TFrmPrincipal.rectMenuConfigClick(Sender: TObject);
begin
    if NOT Assigned(FrmConfig) then
        Application.CreateForm(TFrmConfig, FrmConfig);

    FrmConfig.Show;
end;

procedure TFrmPrincipal.Logout;
begin
    try
      Dm.ExcluirUsuario;
    except on ex:exception do
      begin
        showmessage(ex.Message);
        exit;
      end;
    end;

    if NOT Assigned(FrmLogin) then
        Application.CreateForm(TFrmLogin, FrmLogin);

    Application.MainForm := FrmLogin;
    FrmLogin.Show;
    FrmPrincipal.Close;
end;

procedure TFrmPrincipal.rectMenuLogoutClick(Sender: TObject);
begin
    Logout;
end;

end.
