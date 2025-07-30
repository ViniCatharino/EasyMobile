unit UnitProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.TabControl, uLoading, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, Core.Utils.Tipos;

type
  TExecuteOnClose = procedure of object;

  TFrmProduto = class(TForm)
    TabControl: TTabControl;
    TabProduto: TTabItem;
    rectFundo2: TRectangle;
    rectToolbar: TRectangle;
    lblTitulo2: TLabel;
    btnVoltar: TSpeedButton;
    Image2: TImage;
    lytBusca: TLayout;
    edtDescricao: TEdit;
    lblCategoria: TLabel;
    TabCategoria: TTabItem;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    lblTitulo: TLabel;
    btnFechar: TSpeedButton;
    Image1: TImage;
    Layout2: TLayout;
    Label2: TLabel;
    lbCategorias: TListBox;
    Rectangle4: TRectangle;
    btnCancelarPed: TSpeedButton;
    lytBotoesRodape: TLayout;
    Rectangle6: TRectangle;
    btnRevisar: TSpeedButton;
    Rectangle1: TRectangle;
    btnBusca: TSpeedButton;
    lvProdutos: TListView;
    imgIconeMais: TImage;
    rectFundoQtd: TRectangle;
    lytQtd: TLayout;
    lblDescricao: TLabel;
    LytBotoesQtd: TLayout;
    btnMenos: TSpeedButton;
    btnMais: TSpeedButton;
    lblQtd: TLabel;
    Image3: TImage;
    Image4: TImage;
    edtObs: TEdit;
    lytBotoes: TLayout;
    rectConfirmar: TRectangle;
    btnConfirmar: TSpeedButton;
    rectLogin: TRectangle;
    btnCancelar: TSpeedButton;
    lblAdicionais: TLabel;
    StyleBook1: TStyleBook;
    rectQtd: TRectangle;
    lvAdicionais: TListView;
    imgUnCheck: TImage;
    imgCheck: TImage;
    procedure FormShow(Sender: TObject);
    procedure lbCategoriasItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure btnVoltarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lvProdutosItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure imgFecharQtdClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnRevisarClick(Sender: TObject);
    procedure btnBuscaClick(Sender: TObject);
    procedure btnMenosClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnCancelarPedClick(Sender: TObject);
    procedure lvProdutosUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lvAdicionaisItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    Fcliente_comanda  : string;
    FTelefone_Cliente : string;
    Fid_mesa          : integer;
    FExecuteOnClose   : TExecuteOnClose;
    Fid_comanda       : integer;
    Fid_categoria     : integer;
    FTipoAtendimento  : TOrigemPedido;
    FTipoAberturaTela : TTipoAberturaTelaProduto;

    procedure AddCategoriaListbox(id_categoria: integer; categoria: string);
    procedure RefreshCategorias;
    procedure TerminateCategoria(Sender: TObject);
    procedure AddProdutoListview(id_produto: integer; descricao: string;
      preco: double; modo: string);
    procedure RefreshProdutos(id_categoria: integer; descricao: string);
    procedure TerminateProduto(Sender: TObject);
    procedure EditarQtd(btn: TSpeedButton);
    procedure ExibeBarraBotoes;
    procedure CloseFormProduto;
    procedure refreshAdicionais;
    procedure TerminateAdicionais(Sender: TObject);
    procedure AddAdicionaisListBox(Id_Adicional   : integer;
                                   Nome,descricao : string;
                                   Valor          : double);
    procedure SelecionarItemAdicionais(Item: TlistViewItem);
    procedure SetupItemAdicionais(lv: TlistView; item: TlistViewItem; Img_Check,
      img_Uncheck: TBitMap);
    procedure VerificarItensCheckAdicionais(AIdItem: integer; lv: TlistView);
    { Private declarations }
  public
    property id_mesa         : integer read Fid_mesa          write Fid_mesa;
    property id_comanda      : integer read Fid_comanda       write Fid_comanda;
    property cliente_comanda : string  read Fcliente_comanda  write Fcliente_comanda;
    property ExecuteOnClose  : TExecuteOnClose  read FExecuteOnClose  write FExecuteOnClose;
    property telefone_Cliente: string  read Ftelefone_Cliente write Ftelefone_Cliente;
    property TipoAtendimento : TorigemPedido    read FtipoAtendimento write FTipoAtendimento;
    property TipoAberturaTela: TTipoAberturaTelaProduto read FTipoAberturaTela write FTipoAberturaTela;
  end;

var
  FrmProduto: TFrmProduto;

implementation

{$R *.fmx}

uses UnitFrameCategoria,
     UnitPrincipal,
     UnitPedido,
     DataModule.Global,
     unitFrameAdicionais;

procedure TFrmProduto.AddCategoriaListbox(id_categoria: integer;
                                categoria: string);
var
  item : TListBoxItem;
  frame: TFrameCategoria;
begin
    // Item da listbox
    item := TListBoxItem.Create(lbCategorias);
    item.Text := '';
    item.Height := 60;
    item.Tag := id_categoria;
    item.TagString := categoria;
    item.Selectable := false;

    // Frame
    frame := TFrameCategoria.Create(item);
    frame.lblCategoria.Text := categoria;

    item.AddObject(frame);

    lbCategorias.AddObject(item);
end;

// modo: "Inclusao" ou "Consulta"
procedure TFrmProduto.AddProdutoListview(id_produto: integer;
                                         descricao: string;
                                         preco: double;
                                         modo: string);
var
    item: TListViewItem;
begin
    item := lvProdutos.Items.Add;
    item.Tag := id_produto;
    item.TagString := modo;

    TListItemText(item.Objects.FindDrawable('txtDescricao')).Text := descricao;
    TListItemText(item.Objects.FindDrawable('txtPreco')).Text := FormatFloat('R$ #,##0.00', preco);
    TListItemText(item.Objects.FindDrawable('txtPreco')).TagFloat := preco;

    if modo = 'Inclusao' then
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Bitmap := imgIconeMais.Bitmap
    else
      TListItemImage(item.Objects.FindDrawable('imgAdd')).Visible := false;
end;

procedure TFrmProduto.btnBuscaClick(Sender: TObject);
begin
  RefreshProdutos(Fid_categoria, edtDescricao.Text);
end;

procedure TFrmProduto.btnCancelarClick(Sender: TObject);
begin
    lytQtd.Visible := false;
end;

procedure TFrmProduto.btnCancelarPedClick(Sender: TObject);
begin
  close;
end;

procedure TFrmProduto.btnConfirmarClick(Sender: TObject);
var
  LResultInserirItem: integer;
begin
  try
    LResultInserirItem := Dm.InserirItem(lblDescricao.Tag,
                                         lblQtd.Tag,
                                         lblDescricao.Text,
                                         edtObs.Text,
                                         lblDescricao.TagFloat);

    lytQtd.Visible := false;
    ExibeBarraBotoes;

    VerificarItensCheckAdicionais(LResultInserirItem, lvAdicionais);

  except on ex:exception do
    showmessage('Erro ao inserir item na comanda: ' + ex.Message);
  end;
end;

procedure TFrmProduto.btnFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmProduto.CloseFormProduto;
begin
  close;
end;

procedure TFrmProduto.btnRevisarClick(Sender: TObject);
begin
    if NOT Assigned(FrmPedido) then
        Application.CreateForm(TFrmPedido, FrmPedido);

    FrmPedido.ExecuteCloseProduto := CloseFormProduto;
    FrmPedido.id_comanda          := id_comanda;
    FrmPedido.cliente_comanda     := cliente_comanda;
    FrmPedido.ExecuteOnClose      := ExibeBarraBotoes;
    FrmPedido.telefone_Cliente    := FTelefone_Cliente;
    FrmPedido.TipoAtendimento     := FTipoAtendimento;
    FrmPedido.Show;
end;

procedure TFrmProduto.btnVoltarClick(Sender: TObject);
begin
    TabControl.GotoVisibleTab(0);
end;

procedure TFrmProduto.TerminateCategoria(Sender: TObject);
var
    i: integer;
begin
    TLoading.Hide;

    if Assigned(TThread(Sender).FatalException) then
    begin
        showmessage(Exception(TThread(sender).FatalException).Message);
        exit;
    end;

    Dm.TabCategoria.First;
    While NOT Dm.TabCategoria.Eof do
    begin
        AddCategoriaListbox(Dm.TabCategoria.FieldByName('id_categoria').AsInteger,
                            Dm.TabCategoria.FieldByName('categoria').AsString);

        Dm.TabCategoria.Next;
    end;
end;

procedure TFrmProduto.TerminateProduto(Sender: TObject);
var
  modo: string;
begin
  TLoading.Hide;

  if Assigned(TThread(Sender).FatalException) then
  begin
      showmessage(Exception(TThread(sender).FatalException).Message);
      exit;
  end;

  if TipoAberturaTela = TTipoAberturaTelaProduto.tapConsultaCardapio then
    modo := 'Consulta'
  else
    modo := 'Inclusao';


  Dm.TabProduto.First;
  while NOT Dm.TabProduto.eof do
  begin
    AddProdutoListview(Dm.TabProduto.FieldByName('id_produto').AsInteger,
                       Dm.TabProduto.FieldByName('descricao').AsString,
                       Dm.TabProduto.FieldByName('preco').AsFloat,
                       modo);

    Dm.TabProduto.Next;
  end;
end;

procedure TFrmProduto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(ExecuteOnClose) then
    ExecuteOnClose;

  Action := TCloseAction.caFree;
  FrmProduto := nil;
end;

procedure TFrmProduto.FormCreate(Sender: TObject);
begin
    TabControl.ActiveTab := TabCategoria;
    lytQtd.Visible       := false;
end;

procedure TFrmProduto.ExibeBarraBotoes;
begin
  try
    Dm.ListarItens;

    lytBotoesRodape.Visible := Dm.qryItem.RecordCount > 0;

  except on ex:exception do
    showmessage('Erro ao exibir botões: ' + ex.message)
  end;


end;

procedure TFrmProduto.FormShow(Sender: TObject);
begin


  lblTitulo.Text  := cliente_comanda;
  lblTitulo2.Text := cliente_comanda;

  RefreshCategorias;

  try
    Dm.ExcluirItens(0);
  except on ex:exception do
    showmessage('Erro ao excluir itens: ' + ex.Message);
  end;

  ExibeBarraBotoes;
end;

procedure TFrmProduto.imgFecharQtdClick(Sender: TObject);
begin
    lytQtd.Visible := false;
end;

procedure TFrmProduto.lbCategoriasItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  Fid_categoria     := Item.Tag;
  lblCategoria.Text := Item.TagString;
  edtDescricao.Text := '';

  RefreshProdutos(Item.Tag, '');
  TabControl.GotoVisibleTab(1);



end;

procedure TFrmProduto.lvAdicionaisItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  SelecionarItemAdicionais(Aitem);
end;

procedure TfrmProduto.VerificarItensCheckAdicionais(AIdItem: integer;lv : TlistView);
var
  x : Integer;
begin

  for x := lv.ItemCount -1 downto 0 do
    if lv.items[x].Checked then
      Dm.InserirItemAdicionais(AIdItem,
                               lv.Items[x].Tag,
                               1,
                               lv.items[x].TagFloat);



end;

procedure TFrmProduto.lvProdutosItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if ItemObject <> nil then
    if ItemObject.Name = 'imgAdd' then
    begin
      lblQtd.Tag  := 1;
      lblQtd.Text := '1';
      edtObs.Text := '';
      lblDescricao.Text := TListItemText(
                        lvProdutos.Items[ItemIndex].Objects.FindDrawable('txtDescricao')
                        ).Text;

      lblDescricao.Tag := lvProdutos.Items[ItemIndex].Tag; // id_produto

      lblDescricao.TagFloat := TListItemText(
                        lvProdutos.Items[ItemIndex].Objects.FindDrawable('txtPreco')
                        ).TagFloat;  // preco

      lytQtd.Visible := true;
      refreshAdicionais;
    end;
end;

procedure TFrmProduto.lvProdutosUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
    if AItem.TagString = 'Inclusao' then
      TListItemImage(AItem.Objects.FindDrawable('imgAdd')).Bitmap := imgIconeMais.Bitmap
    else
      TListItemImage(AItem.Objects.FindDrawable('imgAdd')).Visible := false;
end;

procedure TFrmProduto.RefreshCategorias;
begin
    lbCategorias.Items.Clear;

    TLoading.Show(FrmProduto);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarCategorias;

    end,
    TerminateCategoria);
end;

procedure TFrmProduto.refreshAdicionais;
begin
   // lbAdicionais.Items.Clear;

    TLoading.Show(FrmProduto);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarAdicionais;
    end,
    TerminateAdicionais);
end;

procedure TFrmProduto.TerminateAdicionais(Sender: TObject);
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

   Dm.TabAdicionais.First;
    While NOT Dm.TabAdicionais.Eof do
    begin
        AddAdicionaisListBox(Dm.TabAdicionais.FieldByName('id_adicional').AsInteger,
                             Dm.TabAdicionais.FieldByName('descricao').AsString,
                             dm.TabAdicionais.FieldByName('nome').AsString,
                             Dm.TabAdicionais.FieldByName('valor').Value);

        Dm.TabAdicionais.Next;
    end;



end;

procedure TFrmProduto.AddAdicionaisListBox(Id_Adicional   : integer;
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
    TListItemimage(item.Objects.FindDrawable('imgCheck')).Bitmap  := imgUnCheck.Bitmap;


end;

procedure TFrmProduto.SelecionarItemAdicionais(Item : TlistViewItem);
begin

  Item.Checked := Not Item.Checked;

  SetupItemAdicionais(lvAdicionais,
                      item,
                      imgCheck.bitmap,
                      imgunCheck.bitmap);

end;

procedure TFrmProduto.SetupItemAdicionais(lv          : TlistView;
                                          item        : TlistViewItem;
                                          Img_Check   : TbitMap;
                                          img_Uncheck : TBitMap);
begin

  if Item.Checked then
    TListItemimage(item.Objects.FindDrawable('imgCheck')).Bitmap  := img_Check
  else
    TListItemimage(item.Objects.FindDrawable('imgCheck')).Bitmap  := img_unCheck;


end;

procedure TFrmProduto.RefreshProdutos(id_categoria: integer;
                                      descricao: string);
begin
    lvProdutos.Items.Clear;

    TLoading.Show(FrmProduto);

    TLoading.ExecuteThread(procedure
    begin
      Dm.ListarProdutos(id_categoria, descricao);
    end,
    TerminateProduto);
end;

procedure TFrmProduto.EditarQtd(btn: TSpeedButton);
begin
  lblQtd.Tag := lblQtd.Tag + btn.Tag;

  if lblQtd.Tag < 1 then
    lblQtd.Tag := 1;

  lblQtd.Text := lblQtd.Tag.ToString;
end;

procedure TFrmProduto.btnMenosClick(Sender: TObject);
begin
  EditarQtd(TSpeedButton(Sender));
end;


end.
