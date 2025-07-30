unit UnitPedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.TabControl, uLoading, Core.Utils.Tipos;

type
  TExecuteOnClose = procedure of object;
  TExecuteCloseProduto = procedure of object;

  TFrmPedido = class(TForm)
    TabControl: TTabControl;
    TabConfPedido: TTabItem;
    rectFundo2: TRectangle;
    rectToolbar: TRectangle;
    lblTitulo: TLabel;
    btnVoltar: TSpeedButton;
    Image2: TImage;
    lblComanda: TLabel;
    lvProdutos: TListView;
    imgIconeMais: TImage;
    TabMensagem: TTabItem;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Image1: TImage;
    Rectangle4: TRectangle;
    btnFinalizar: TSpeedButton;
    lblTotal: TLabel;
    imgIconeMenos: TImage;
    btnLimpar: TSpeedButton;
    TimerClose: TTimer;
    TabItem1: TTabItem;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    Image3: TImage;
    lblNomedoItem: TLabel;
    imgAdd: TImage;
    lvAdicionais: TListView;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFinalizarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvProdutosItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure btnLimparClick(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FExecuteOnClose      : TExecuteOnClose;
    Fcliente_comanda     : string;
    Fid_comanda          : integer;
    FExecuteCloseProduto : TExecuteCloseProduto;
    Ftelefone_Cliente    : string;
    FTipoAtendimento     : TorigemPedido;
    FExisteItemAdicional : Boolean;

    procedure RefreshProdutos;
    procedure AddProdutoListview(id_item, id_produto: integer;
                                        descricao, obs     : string;
                                        qtd                : integer;
                                        preco              : double;
                                        ValorAdicional     : Double);

    procedure EditarQtd(ItemIndex: integer; valor: double);
    procedure CalcularTotal;
    procedure TerminatePedido(Sender: TObject);
    procedure RefreshAdicionais(AidItem : Integer);
    procedure TerminateAdicionais(Sender: TObject);
    procedure AddAdicionaisListBox(Id_Adicional    : integer;
                                   Nome,descricao  : string;
                                   Valor           : double);
    { Private declarations }
  public
    property ExecuteOnClose     : TExecuteOnClose      read FExecuteOnClose write FExecuteOnClose;
    property ExecuteCloseProduto: TExecuteCloseProduto read FExecuteCloseProduto write FExecuteCloseProduto;
    property id_comanda         : integer          read Fid_comanda       write Fid_comanda;
    property cliente_comanda    : string           read Fcliente_comanda  write Fcliente_comanda;
    property telefone_Cliente   : string           read Ftelefone_Cliente write Ftelefone_Cliente;
    property TipoAtendimento    : TorigemPedido    read FtipoAtendimento  write FTipoAtendimento;

  end;

var
  FrmPedido: TFrmPedido;

implementation

{$R *.fmx}

uses UnitPrincipal, DataModule.Global, FMX.DialogService;

procedure TFrmPedido.AddProdutoListview(id_item, id_produto: integer;
                                        descricao, obs     : string;
                                        qtd                : integer;
                                        preco              : double;
                                        ValorAdicional     : Double);
var
    item: TListViewItem;
begin
    item     := lvProdutos.Items.Add;
    item.Tag := id_Item;

    TListItemText(item.Objects.FindDrawable('txtDescricao')).Text := descricao;
    TListItemText(item.Objects.FindDrawable('txtObs')).Text := obs;

    TListItemText(item.Objects.FindDrawable('txtTotal')).Text := FormatFloat('R$ #,##0.00', qtd * preco);
    TListItemText(item.Objects.FindDrawable('txtTotal')).TagFloat := preco;

    TListItemText(item.Objects.FindDrawable('txtQtd')).Text := FormatFloat('#,##', qtd);
    TListItemText(item.Objects.FindDrawable('txtQtd')).TagFloat := qtd;

    TListItemImage(item.Objects.FindDrawable('imgMenos')).Bitmap := imgIconeMenos.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgMenos')).TagFloat := -1;

    TListItemImage(item.Objects.FindDrawable('imgMais')).Bitmap := imgIconeMais.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgMais')).TagFloat := 1;

   // TListItemImage(item.Objects.FindDrawable('imgAdd')).Bitmap := imgAdd.Bitmap;
    TListItemImage(item.Objects.FindDrawable('imgAdd')).Visible   := False;
    TListItemImage(item.Objects.FindDrawable('imgAdd')).Width     := 0;
    TListItemImage(item.Objects.FindDrawable('imgAdd')).TagFloat  := ValorAdicional;

    if ValorAdicional > 0 then

    begin
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Visible := True;
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Bitmap  := imgAdd.Bitmap;
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Width   := 32;
    //  TlistItemText(item.Objects.FindDrawable('txtQuantidadeAdicionais')).Text := AQuantidadeAdicionais.ToString;
    end;

end;

procedure TFrmPedido.TerminatePedido(Sender: TObject);
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;
    TabControl.GotoVisibleTab(2);
    TimerClose.Enabled := true;

end;


procedure TFrmPedido.TimerCloseTimer(Sender: TObject);
begin
  TimerClose.Enabled := false;

  if Assigned(ExecuteCloseProduto) then
    ExecuteCloseProduto;

  close;
end;

procedure TFrmPedido.btnFinalizarClick(Sender: TObject);
begin
  TLoading.Show(FrmPedido);

  TLoading.ExecuteThread(procedure
  begin
    Dm.ListarItens;
    Dm.ListarAdiconal;
    Dm.FinalizarPedido(id_comanda,
                       FTipoAtendimento,
                       Ftelefone_Cliente,
                       Dm.qryItem,
                       Dm.qryAdicional);
    Dm.DeletarRegistrosTabelas;
  end,
  TerminatePedido);

end;

procedure TFrmPedido.btnLimparClick(Sender: TObject);
begin
  TDialogService.MessageDialog('Confirma exclusão dos itens?',
                               TMsgDlgType.mtConfirmation,
                               [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                               TMsgDlgBtn.mbNo,
                               0,
                               procedure (const AResult: TModalResult)
                               begin
                                  if AResult = mrYes then
                                  begin
                                    try
                                      Dm.ExcluirItens(0);
                                      Close;
                                    except on ex:exception do
                                      showmessage('Erro ao limpar itens: ' + ex.Message);
                                    end;
                                  end;
                               end);

end;

procedure TFrmPedido.btnVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPedido.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(ExecuteOnClose) then
    ExecuteOnClose;

  Action := TCloseAction.caFree;
  FrmPedido := nil;
end;

procedure TFrmPedido.FormCreate(Sender: TObject);
begin
    TabControl.ActiveTab := TabConfPedido;
end;

procedure TFrmPedido.FormShow(Sender: TObject);
begin
  lblComanda.Text := cliente_comanda;
  RefreshProdutos;
end;

procedure TFrmPedido.EditarQtd(ItemIndex: integer; valor: double);
var
  txtQtd, txtTotal: TListItemText;
  id_item: integer;
begin
  txtQtd := TListItemText(lvProdutos.Items[ItemIndex].Objects.FindDrawable('txtQtd'));
  txtTotal := TListItemText(lvProdutos.Items[ItemIndex].Objects.FindDrawable('txtTotal'));
  id_item := lvProdutos.Items[ItemIndex].Tag;

  txtQtd.TagFloat := txtQtd.TagFloat + valor;
  txtQtd.Text := txtQtd.TagFloat.ToString;
  txtTotal.Text := FormatFloat('R$ #,##0.00', txtQtd.TagFloat * txtTotal.TagFloat);

  if txtQtd.TagFloat < 1 then
  begin
    Dm.ExcluirItens(id_item);
    lvProdutos.Items.Delete(ItemIndex);
  end
  else
    Dm.EditarItem(id_item, Trunc(txtQtd.TagFloat));

  CalcularTotal;
end;

procedure TFrmPedido.lvProdutosItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
  var
    LId             : Integer;
begin

  if ItemObject <> nil then
  begin
    if (ItemObject.Name = 'imgMenos') or (ItemObject.Name = 'imgMais') then
    begin
      try
        EditarQtd(ItemIndex, ItemObject.TagFloat);
      except on ex:exception do
        showmessage('Erro ao editar quantidade: ' + ex.Message);
      end;
    end;

    if ItemObject.Name = 'imgAdd' then
    begin
      if  ItemObject.TagFloat <> 0 then
      begin
        try
          LId := lvProdutos.Items[ItemIndex].Tag;

         // Dm.ListarAdiconalItensPorId(Lid);
         // RefreshAdicionais(Lid);

         Dm.ListarAdicionalPorIdItem(Lid);
         TerminateAdicionais(Sender);


          if FExisteItemAdicional then
          begin
            TabControl.GotoVisibleTab(1);
            lblNomedoItem.Text := TListItemText(lvProdutos.Items[ItemIndex].Objects.FindDrawable('txtDescricao')).Text;
          end;


        except on ex:exception do
          showmessage('Consultar Adicionais: ' + ex.Message);
        end;
      end;
    end;

  end;


end;

procedure TFrmPedido.RefreshAdicionais(AidItem : Integer);
begin

  TLoading.Show(FrmPedido);

  TLoading.ExecuteThread(procedure
  begin

    Dm.ListarAdicionalPorId(AidItem);

  end,
  TerminateAdicionais);

end;

procedure TFrmPedido.TerminateAdicionais(Sender: TObject);
var
  modo: string;
  i   : Integer;
begin
//  TLoading.Hide;

  if Assigned(TThread(Sender).FatalException) then
  begin
      showmessage(Exception(TThread(sender).FatalException).Message);
      exit;
  end;

  lvAdicionais.Items.Clear;

   Dm.qryAdicional.First;

   While NOT Dm.qryAdicional.Eof do
    begin
        AddAdicionaisListBox(Dm.qryAdicional.FieldByName('id_adicional').AsInteger,
                             Dm.qryAdicional.FieldByName('descricao').AsString,
                             dm.qryAdicional.FieldByName('nome').AsString,
                             Dm.qryAdicional.FieldByName('valor').Value);

        Dm.qryAdicional.Next;
    end;
    FExisteItemAdicional := True;




end;

procedure TFrmPedido.AddAdicionaisListBox(Id_Adicional    : integer;
                                          Nome,descricao  : string;
                                          Valor           : double);

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

procedure TFrmPedido.CalcularTotal;
var
  total,ValorAdicionais : double;
  i                     : integer;
  txtQtd, txtTotal      : TListItemText;
begin
  total           := 0;
  ValorAdicionais := 0;

  for i := 0 to lvProdutos.Items.Count - 1 do
  begin
    txtQtd   := TListItemText(lvProdutos.Items[i].Objects.FindDrawable('txtQtd'));
    txtTotal := TListItemText(lvProdutos.Items[i].Objects.FindDrawable('txtTotal'));

//   ValorAdicionais := Dm.CalcularTotalAdicionaisPorIdPedido(lvProdutos.Items[i].Tag);




    total := total + (txtQtd.TagFloat * txtTotal.TagFloat) + ValorAdicionais;

  end;

  lblTotal.Text := FormatFloat('R$ #,##0.00', total);
end;

procedure TFrmPedido.RefreshProdutos;
var
  ValorAdicionais : Double;
begin
  lvProdutos.Items.Clear;

  dm.ListarItens;
  ValorAdicionais := 0.0;

  while NOT dm.qryItem.Eof do
  begin
    ValorAdicionais := dm.CalcularTotalAdicionaisPorIdPedido(dm.qryItem.FieldByName('Id_Item').AsInteger);

    AddProdutoListview(dm.qryItem.FieldByName('id_item').AsInteger,
                       dm.qryItem.FieldByName('id_produto').AsInteger,
                       dm.qryItem.FieldByName('descricao').AsString,
                       dm.qryItem.FieldByName('obs').AsString,
                       dm.qryItem.FieldByName('qtd').AsInteger,
                       dm.qryItem.FieldByName('preco').AsFloat + ValorAdicionais,
                       ValorAdicionais);
    dm.qryItem.Next;
  end;

  CalcularTotal;
end;

procedure TFrmPedido.SpeedButton1Click(Sender: TObject);
begin
  TabControl.GotoVisibleTab(0);
end;

end.
