unit UnitFechamento;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.TabControl, uLoading, uListboxLayout, FMX.Ani, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TExecuteCloseMesa = procedure of object;

  TFrmFechamento = class(TForm)
    TabControl: TTabControl;
    TabFechamento: TTabItem;
    Rectangle1: TRectangle;
    rectToolbar: TRectangle;
    lblTitulo2: TLabel;
    btnVoltar: TSpeedButton;
    Image2: TImage;
    Rectangle5: TRectangle;
    btnEncerrar: TSpeedButton;
    TabComanda: TTabItem;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    lblTitulo: TLabel;
    btnFechar: TSpeedButton;
    Image1: TImage;
    Layout2: TLayout;
    Label2: TLabel;
    lbComandas: TListBox;
    lblSubtitulo: TLabel;
    rectAbas: TRectangle;
    lblAbaResumo: TLabel;
    lblAbaResumoItens: TLabel;
    rectAbaSelecao: TRectangle;
    Layout1: TLayout;
    Label6: TLabel;
    lblTotal: TLabel;
    TabControlPersonal: TTabControl;
    TabResumo: TTabItem;
    TabResumoItens: TTabItem;
    Rectangle4: TRectangle;
    lvProdutos: TListView;
    Rectangle6: TRectangle;
    imgIconeDelete: TImage;
    tabResumoAdicionais: TTabItem;
    rectFundoTab: TRectangle;
    lvAdicionais: TListView;
    imgAdd: TImage;
    procedure FormShow(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblAbaResumoClick(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure lbComandasItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure lvProdutosItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure btnEncerrarClick(Sender: TObject);
  private
    Fid_mesa             : integer;
    Fnumero_mesa         : integer;
    Fid_comanda          : integer;
    Fcliente_comanda     : string;
    Ftotal               : double;
    FExecuteCloseMesa    : TExecuteCloseMesa;
    FExisteItemAdicional : Boolean;
    procedure RefreshComandas;
    procedure TerminateComanda(Sender: TObject);
    procedure SelecionarAba(lbl: TLabel);
    procedure AddProdutoListview(id_unico, id_pedido, id_produto: integer;
                                            descricao, obs: string;
                                            qtd: integer;
                                            preco: double;
                                            AQuantidadeAdicionais : Integer);
    procedure RefreshResumo;
    procedure TerminateResumo(Sender: TObject);
    procedure ExcluirItemPedido(id_pedido, id_item: integer);
    procedure TerminateExclusaoItem(Sender: TObject);
    procedure EncerrarComanda(id_comanda: integer);
    procedure TerminateEncerramento(Sender: TObject);
    procedure refreshAdicionais(AidItem: Integer);
    procedure TerminateAdicionais(Sender: TObject);
    procedure AddAdicionaisListBox(Id_Adicional: integer; Nome,
      descricao: string; Valor: double);
    { Private declarations }
  public
    property id_mesa: integer read Fid_mesa write Fid_mesa;
    property ExecuteCloseMesa: TExecuteCloseMesa read FExecuteCloseMesa write FExecuteCloseMesa;
  end;

var
  FrmFechamento: TFrmFechamento;

implementation

{$R *.fmx}

uses UnitPrincipal, DataModule.Global, FMX.DialogService;

procedure TFrmFechamento.AddProdutoListview(id_unico, id_pedido, id_produto: integer;
                                            descricao, obs: string;
                                            qtd: integer;
                                            preco: double;
                                            AQuantidadeAdicionais : Integer);
var
    item: TListViewItem;
begin
    item           := lvProdutos.Items.Add;
    item.Tag       := id_unico;
    item.TagString := id_pedido.ToString;

    TListItemText(item.Objects.FindDrawable('txtDescricao')).Text := FormatFloat('#,##', qtd) + ' x ' + descricao;
    TListItemText(item.Objects.FindDrawable('txtObs')).Text       := obs;
    TListItemText(item.Objects.FindDrawable('txtTotal')).Text     := FormatFloat('R$ #,##0.00', qtd * preco);
    TListItemImage(item.Objects.FindDrawable('imgAdd')).Visible   := False;
    TListItemImage(item.Objects.FindDrawable('imgAdd')).Width     := 0;
    TlistItemText(item.Objects.FindDrawable('txtQuantidadeAdicionais')).Text := '';

    if AQuantidadeAdicionais > 0 then
    begin
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Visible := True;
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Bitmap  := imgAdd.Bitmap;
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Width   := 32;
      TlistItemText(item.Objects.FindDrawable('txtQuantidadeAdicionais')).Text := AQuantidadeAdicionais.ToString;
    end;

end;

procedure TFrmFechamento.TerminateComanda(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;


      dm.TabComanda.First;
      while NOT dm.TabComanda.Eof do
      begin
        AddComandaListbox(lbComandas,
                          dm.TabComanda.FieldByName('id_comanda').AsInteger,
                          dm.TabComanda.FieldByName('cliente_comanda').AsString,
                          dm.TabComanda.FieldByName('vl_total').AsFloat);

        dm.TabComanda.next;
      end;

    // Titulos
    lblTitulo.Text := 'Fechamento - Mesa ' + dm.TabMesa.FieldByName('numero_mesa').AsString;
    Fnumero_mesa := dm.TabMesa.FieldByName('numero_mesa').AsInteger;
end;

procedure TFrmFechamento.TerminateEncerramento(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    if Assigned(ExecuteCloseMesa) then
      ExecuteCloseMesa;

    close;
end;


procedure TFrmFechamento.EncerrarComanda(id_comanda: integer);
begin
  TLoading.Show(FrmFechamento);

  TLoading.ExecuteThread(procedure
  begin
    Dm.EncerrarComanda(id_comanda);
  end,
  TerminateEncerramento);
end;

procedure TFrmFechamento.btnEncerrarClick(Sender: TObject);
begin
  TDialogService.MessageDialog('Confirma o encerramento da comanda?',
                               TMsgDlgType.mtConfirmation,
                               [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                               TMsgDlgBtn.mbNo,
                               0,
                               procedure (const AResult: TModalResult)
                               begin
                                  if AResult = mrYes then
                                    EncerrarComanda(Fid_comanda);
                               end);
end;

procedure TFrmFechamento.btnFecharClick(Sender: TObject);
begin
    close;
end;
procedure TFrmFechamento.refreshAdicionais(AidItem: Integer);
begin

    TLoading.Show(FrmFechamento);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarAdicionaisPorId(AidItem);
    end,
    TerminateAdicionais);
end;

procedure TFrmFechamento.TerminateAdicionais(Sender: TObject);
var
  modo: string;
  i   : Integer;
begin
  TLoading.Hide;

  if Assigned(TThread(Sender).FatalException) then
  begin
      showmessage(Exception(TThread(sender).FatalException).Message);
      exit;
  end;

  lvAdicionais.Items.Clear;

   if Dm.tabItemAdicionalId.IsEmpty then
   begin
    FExisteItemAdicional := false;
    exit;
   end;

   Dm.tabItemAdicionalId.First;

    While NOT Dm.tabItemAdicionalId.Eof do
    begin
        AddAdicionaisListBox(Dm.tabItemAdicionalId.FieldByName('id_adicional').AsInteger,
                             Dm.tabItemAdicionalId.FieldByName('descricao').AsString,
                             dm.tabItemAdicionalId.FieldByName('nome').AsString,
                             Dm.tabItemAdicionalId.FieldByName('valor').Value);

        Dm.tabItemAdicionalId.Next;
    end;
    FExisteItemAdicional := True;

end;
procedure TFrmfechamento.AddAdicionaisListBox(Id_Adicional   : integer;
                                              Nome,descricao : string;
                                              Valor          : double);
var
    item: TListViewItem;
begin
    item            := lvAdicionais.Items.Add;
    item.Tag        := id_Adicional;
    item.TagString  := nome;
    item.TagFloat   := Valor;
    item.Checked    := false;

    TListItemText(item.Objects.FindDrawable('txtDescricao')).Text := descricao;
    TListItemText(item.Objects.FindDrawable('txtNome')).Text      := nome;
    TListItemText(item.Objects.FindDrawable('txtValor')).Text     := FormatFloat('R$ #,##0.00', Valor);


end;

procedure TFrmFechamento.btnVoltarClick(Sender: TObject);
begin
  RefreshComandas;
  TabControl.GotoVisibleTab(0);
end;

procedure TFrmFechamento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmFechamento := nil;
end;

procedure TFrmFechamento.FormShow(Sender: TObject);
begin
    TabControl.ActiveTab := TabComanda;
    RefreshComandas;
end;

procedure TFrmFechamento.SelecionarAba(lbl: TLabel);
var
  I: Integer;
begin
    //rectAbaSelecao.Position.X := lbl.Position.X;
    TAnimator.AnimateFloat(rectAbaSelecao, 'Position.X', lbl.Position.X, 0.3,
                          TAnimationType.Out, TInterpolationType.Circular);

    TabControlPersonal.GotoVisibleTab(lbl.Tag);
end;

procedure TFrmFechamento.lbComandasItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    Fid_comanda      := Item.Tag;
    Fcliente_comanda := Item.TagString;

    SelecionarAba(lblAbaResumo);
    TabControl.GotoVisibleTab(1);
    RefreshResumo;
end;

procedure TFrmFechamento.lblAbaResumoClick(Sender: TObject);
begin
    SelecionarAba(TLabel(Sender));
end;

procedure TFrmFechamento.TerminateExclusaoItem(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    RefreshResumo;

    // Imprimir etiqueta com os detalhes da exclusao
    // (mesa, comanda, garçon)
end;


procedure TFrmFechamento.ExcluirItemPedido(id_pedido, id_item: integer);
begin
  TLoading.Show(FrmFechamento);

  TLoading.ExecuteThread(procedure
  begin
    Dm.ExcluirItemPedido(id_pedido, id_item);
  end,
  TerminateExclusaoItem);
end;

procedure TFrmFechamento.lvProdutosItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
var
  LId  : Integer;
begin
  if ItemObject <> nil then
    if ItemObject.Name = 'imgAdd' then
    begin

      LId := lvProdutos.Items[ItemIndex].Tag;
      refreshAdicionais(LId);

      if FExisteItemAdicional then
        TabControlPersonal.GotoVisibleTab(2);

    end;
end;

procedure TFrmFechamento.RefreshComandas;
begin
    lbComandas.Items.Clear;

    TLoading.Show(FrmFechamento);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarMesaId(id_mesa);
    end,
    TerminateComanda);
end;

procedure TFrmFechamento.TerminateResumo(Sender: TObject);
var
  LQuantidadeAdicionais : Integer;
  LTotalAdicionais      : Double;
begin
    Ftotal := 0;
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;


    while NOT Dm.TabComandaItem.eof do
    begin

      dm.tabItemAdicional.Filtered := False;
      dm.tabItemAdicional.Filter   := 'id_item_pedido = ' + Dm.TabComandaItem.FieldByName('id_item').AsString;
      dm.tabItemAdicional.Filtered := True;
      LQuantidadeAdicionais        := 0;
      LQuantidadeAdicionais        := dm.tabItemAdicional.RecordCount;
      LTotalAdicionais             := Dm.TabComandaItem.FieldByName('Total_Adicionais').AsFloat;


      AddProdutoListview(Dm.TabComandaItem.FieldByName('id_item').AsInteger,
                         Dm.TabComandaItem.FieldByName('id_pedido').AsInteger,
                         Dm.TabComandaItem.FieldByName('id_produto').AsInteger,
                         Dm.TabComandaItem.FieldByName('descricao').AsString,
                         Dm.TabComandaItem.FieldByName('obs').AsString,
                         Dm.TabComandaItem.FieldByName('qtd').AsInteger,
                         Dm.TabComandaItem.FieldByName('preco').AsFloat + LTotalAdicionais,
                         LQuantidadeAdicionais);

      Ftotal := Ftotal +
                LTotalAdicionais +
                (Dm.TabComandaItem.FieldByName('qtd').AsInteger *
                 Dm.TabComandaItem.FieldByName('preco').AsFloat);


      Dm.TabComandaItem.Next;
    end;

    lblSubtitulo.Text := 'Mesa ' + Fnumero_mesa.ToString + ' - ' + Fcliente_comanda;
    lblTotal.Text := FormatFloat('R$ #,##0.00', Ftotal);
end;

procedure TFrmFechamento.RefreshResumo;
begin
    lvProdutos.Items.Clear;

    TLoading.Show(FrmFechamento);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarItensComanda(Fid_comanda);
      dm.ListarAdicionaisItens;
    end,
    TerminateResumo);
end;

end.
