unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes,
  DataSet.Serialize,
  DataSet.Serialize.Config,
  RESTRequest4D,
  DataSet.Serialize.Adapter.RESTRequest4D,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, System.IOUtils,
  FireDAC.DApt, uSession, Core.Utils.Tipos;

type
  TDm = class(TDataModule)
    TabUsuario: TFDMemTable;
    Conn: TFDConnection;
    qryUsuario: TFDQuery;
    qryConfig: TFDQuery;
    TabMesa: TFDMemTable;
    TabComanda: TFDMemTable;
    TabCategoria: TFDMemTable;
    TabProduto: TFDMemTable;
    TabComandaItem: TFDMemTable;
    TabAdicionais: TFDMemTable;
    qryItem: TFDQuery;
    qryAdicional: TFDQuery;
    tabItemAdicional: TFDMemTable;
    tabItemAdicionalId: TFDMemTable;
    qryItensId: TFDQuery;
    qryInserirAdicionais: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ListarAdiconalItensPorId(AidItem: Integer);
  private

  public
    procedure DeletarRegistrosTabelas;
    procedure Login(login, senha: string);
    procedure ExcluirUsuario;
    procedure InserirUsuario(id_usuario: integer; nome, login, token: string);
    procedure SalvarConfig(servidor: string);
    procedure BuscarConfig;
    procedure ListarUsuario;
    procedure ListarMesas;
    procedure TransferirConsumo(id_mesa_origem, id_mesa_destino: integer);
    procedure ReservarMesa(id_mesa: integer; nome_reserva: string);
    procedure ListarMesaId(id_mesa: integer);
    procedure CancelarReserva(id_mesa: integer);
    procedure AbrirComanda(id_mesa         : integer;
                           cliente_comanda : string;
                           Telefone        : String;
                           TipoAtendimento : TOrigemPedido);
    procedure InserirItemAdicionais(AIdItem,
                                    id_Adicional   : integer;
                                    Qtd,
                                    Valor          : real);
    procedure ListarCategorias;
    procedure ListarProdutos(id_categoria: integer; descricao: string);
    procedure ExcluirItens(id_item: integer);
    procedure ListarItens;
    procedure ListarItensId(AId_Item: Integer);
    procedure EditarItem(id_item, qtd: integer);
    procedure ListarAdicionalPorId(AIdItem: Integer);


    // INSERT LOCAL
    function  InserirItem(id_produto, qtd: integer; descricao, obs: string; preco: double): integer;
    procedure FinalizarPedido(id_comanda       : integer;
                              TipoAtendimento : TOrigemPedido;
                              Telefone         : String;
                              itens, AItensAdicionais: TFDQuery);
    procedure ListarAdiconal;
    function  CalcularTotalAdicionaisPorIdPedido(AID : Integer) : currency;
    procedure InserirAdicional(AId_Adicional : integer;
                               ANome         : String;
                               ADescricao    : String;
                               AValor        : Double);

    procedure ListarAdicionalPorIdItem(AId_Item : Integer);


    // INTERAÇÃO COM API
    procedure ListarItensComanda(id_comanda: integer);
    procedure ExcluirItemPedido(id_pedido, id_item: integer);
    procedure EncerrarComanda(id_comanda: integer);
    procedure ListarAdicionais;
    procedure ListarAdicionaisPorId(AIdItem : Integer);
    procedure ListarAdicionaisItens;
  end;

var
  Dm: TDm;


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses
  System.JSON;

//{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

 //Acrescentar na tag application do arquivo "AndroidManifest.template.xml":
// android:usesCleartextTraffic="true"

procedure TDm.ConnAfterConnect(Sender: TObject);
begin
    Conn.ExecSQL('create table if not exists USUARIO ( ' +
                            'ID_USUARIO    INTEGER NOT NULL PRIMARY KEY, ' +
                            'NOME           VARCHAR (100), ' +
                            'LOGIN          VARCHAR (100), ' +
                            'TOKEN          VARCHAR (100));'
                );

    Conn.ExecSQL('create table if not exists CONFIG ( ' +
                            'SERVIDOR  VARCHAR (500));'
                );

    Conn.ExecSQL('create table if not exists PEDIDO_ITEM ( ' +
                            'ID_ITEM    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
                            'ID_PRODUTO INTEGER,        ' +
                            'QTD        INTEGER,        ' +
                            'DESCRICAO  VARCHAR(100),   ' +
                            'OBS        VARCHAR(500),   ' +
                            'PRECO      DECIMAL(12,2)); '
                );

    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS ADICIONAIS_ITEM (  ' +
                           'ID_ITEM      INTEGER      NOT NULL, ' +
                           'ID_ADICIONAL INTEGER      NOT NULL, ' +
                           'QUANTIDADE   REAL (6, 2),           ' +
                           'VALOR        REAL (10, 2));         '
                );

     Conn.ExecSQL('CREATE TABLE IF NOT EXISTS ADICIONAL (      ' +
                           'ID_ADICIONAL INTEGER     NOT NULL, ' +
                           'NOME         VARCHAR(50) NOT NULL, ' +
                           'DESCRICAO    VARCHAR(500),         ' +
                           'VALOR        REAL (12, 2));        '
                );

end;

procedure TDm.ConnBeforeConnect(Sender: TObject);
begin
    Conn.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    Conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\comanda.db';
    {$ELSE}
    Conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'comanda.db');
    {$ENDIF}
end;

procedure TDm.DataModuleCreate(Sender: TObject);
begin
    Conn.AfterConnect := ConnAfterConnect;
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

    Conn.Connected := True;
end;

procedure TDm.DataModuleDestroy(Sender: TObject);
begin
  Conn.Connected := False;
end;

procedure TDm.Login(login, senha: string);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJSONObject.Create;
        json.AddPair('login', login);
        json.AddPair('senha', senha);

        resp := TRequest.New.BaseURL(TSession.servidor)
                            .Resource('usuarios/login')
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Adapters(TDataSetSerializeAdapter.New(TabUsuario))
                            .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;
end;

procedure TDm.ExcluirUsuario;
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('delete from usuario');
    qryUsuario.ExecSQL;
end;

procedure TDm.ListarUsuario;
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('select * from usuario');
    qryUsuario.active := true;
end;

procedure TDm.InserirUsuario(id_usuario: integer;
                             nome, login, token: string);
begin
    qryUsuario.Active := false;
    qryUsuario.SQL.Clear;
    qryUsuario.SQL.Add('insert into usuario(id_usuario, nome, login, token)');
    qryUsuario.SQL.Add('values(:id_usuario, :nome, :login, :token)');
    qryUsuario.ParamByName('id_usuario').Value := id_usuario;
    qryUsuario.ParamByName('nome').Value := nome;
    qryUsuario.ParamByName('login').Value := login;
    qryUsuario.ParamByName('token').Value := token;
    qryUsuario.ExecSQL;
end;

procedure TDm.SalvarConfig(servidor: string);
var
    cont: integer;
begin
    qryConfig.Active := false;
    qryConfig.SQL.Clear;
    qryConfig.SQL.Add('select * from config');
    qryConfig.Active := true;

    cont := qryConfig.RecordCount;

    qryConfig.Active := false;
    qryConfig.SQL.Clear;

    if cont = 0 then
        qryConfig.SQL.Add('insert into config(servidor) values(:servidor)')
    else
        qryConfig.SQL.Add('update config set servidor=:servidor');

    qryConfig.ParamByName('servidor').Value := servidor;
    qryConfig.ExecSQL;
end;

procedure TDm.BuscarConfig;
begin
    qryConfig.Active := false;
    qryConfig.SQL.Clear;
    qryConfig.SQL.Add('select * from config');
    qryConfig.Active := true;
end;

procedure TDm.ListarMesas;
var
    resp: IResponse;
begin
    TabMesa.FieldDefs.Clear;

    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('mesas')
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabMesa))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ListarMesaId(id_mesa: integer);
var
    resp: IResponse;
    json: TJSONObject;
begin
    TabMesa.FieldDefs.Clear;

    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('mesas')
                        .ResourceSuffix(id_mesa.ToString)
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabMesa))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);

    // Montar o lista das comandas
    json := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(resp.Content), 0) as TJSONObject;

    if TabComanda.Active then
      TabComanda.EmptyDataSet;

    TabComanda.LoadFromJSON(json.GetValue<TJSONArray>('comandas'), false);
    json.Free;
end;

procedure TDm.CancelarReserva(id_mesa: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('mesas')
                        .ResourceSuffix(id_mesa.ToString + '/reserva')
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Delete;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.TransferirConsumo(id_mesa_origem, id_mesa_destino: integer);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJSONObject.Create;
        json.AddPair('id_mesa_destino', id_mesa_destino.ToString);

        resp := TRequest.New.BaseURL(TSession.servidor)
                            .Resource('mesas')
                            .ResourceSuffix(id_mesa_origem.ToString + '/transferencia')
                            .TokenBearer(TSession.token)
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;
end;

procedure TDm.ReservarMesa(id_mesa: integer; nome_reserva: string);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJSONObject.Create;
        json.AddPair('nome_reserva', nome_reserva);

        resp := TRequest.New.BaseURL(TSession.servidor)
                            .Resource('mesas')
                            .ResourceSuffix(id_mesa.ToString + '/reserva')
                            .TokenBearer(TSession.token)
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;
end;

procedure TDm.AbrirComanda(id_mesa         : integer;
                           cliente_comanda : string;
                           Telefone        : String;
                           TipoAtendimento : TOrigemPedido);
var
    resp: IResponse;
    json: TJsonObject;
    LTipo_Atendimento : String;
begin

    case TipoAtendimento of
      tosBalcao:  LTipo_Atendimento := OrigemPedido[integer(TOrigemPedido.tosBalcao)];
      tosIntegracao: ;
      tosSalao: LTipo_Atendimento := OrigemPedido[integer(TOrigemPedido.tosSalao)];
    end;

    try
        json := TJSONObject.Create;
        json
          .AddPair('id_mesa', id_mesa.ToString)
          .AddPair('cliente_comanda', cliente_comanda)
          .AddPair('telefone_cliente',Telefone)
          .AddPair('tipo_atendimento', LTipo_Atendimento);

        resp := TRequest.New.BaseURL(TSession.servidor)
                            .Resource('comandas')
                            .TokenBearer(TSession.token)
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;
end;



procedure TDm.ListarAdicionaisPorId(AIdItem : Integer);
var
    resp: IResponse;

begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('adicionais')
                        .ResourceSuffix(AidItem.ToString + '/itens-adicionais')
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(tabItemAdicionalId))
                        .Get;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);

end;

procedure TDm.ListarAdicionalPorId(AIdItem : Integer);
var
    resp: IResponse;

begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('adicionais/' + AidItem.ToString)
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabAdicionais))
                        .Get;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);

end;

procedure TDm.ListarAdicionalPorIdItem(AId_Item: Integer);
begin
  qryAdicional.Close;
  qryAdicional.SQL.Clear;
  qryAdicional.SQL.Add('SELECT AI.id_item,                                          ');
  qryAdicional.SQL.Add('AI.id_adicional,                                            ');
  qryAdicional.SQL.Add('A.id_adicional,                                             ');
  qryAdicional.SQL.Add('A.nome,                                                     ');
  qryAdicional.SQL.Add('A.valor,                                                    ');
  qryAdicional.SQL.Add('A.descricao                                                 ');
  qryAdicional.SQL.Add('FROM adicionais_item AS AI                                  ');
  qryAdicional.SQL.Add('LEFT JOIN ADICIONAL AS A ON A.id_adicional = AI.id_adicional');
  qryAdicional.SQL.Add('WHERE AI.id_item = :id_Item                                 ');

  qryAdicional.ParamByName('ID_Item').Value := AId_Item;

  try
    qryAdicional.open;
  except
    on e:exception do
    begin
      raise Exception.Create('Error Message: ' + e.ToString);
    end;
  end;

end;

procedure TDm.ListarAdiconal;
begin
  qryAdicional.Active := false;
  qryAdicional.SQL.Clear;
  qryAdicional.SQL.Add('select * from ADICIONAIS_ITEM order by id_item');
  qryAdicional.active := true;
end;

procedure TDm.ListarAdiconalItensPorId(AidItem: Integer);
begin
  qryAdicional.Active := false;
  qryAdicional.SQL.Clear;
  qryAdicional.SQL.Add('select * from ADICIONAIS_ITEM ');
  qryAdicional.SQL.Add('where Id_Item = :id           ');
  qryAdicional.ParamByName('id').Value := AidItem;
  qryAdicional.active := true;
end;

procedure TDm.ListarCategorias;
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('categorias')
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabCategoria))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ListarProdutos(id_categoria: integer; descricao: string);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('categorias')
                        .ResourceSuffix(id_categoria.ToString + '/produtos')
                        .AddParam('descricao', descricao)
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabProduto))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ExcluirItens(id_item: integer);
begin
  qryItem.Active := false;
  qryItem.SQL.Clear;
  qryItem.SQL.Add('delete from pedido_item');

  if id_item > 0 then
  begin
    qryItem.SQL.Add('where id_item = :id_item');
    qryItem.ParamByName('id_item').Value := id_item;
  end;

  qryItem.ExecSQL;
end;

procedure TDm.ListarItens;
begin
  qryItem.Active := false;
  qryItem.SQL.Clear;
  qryItem.SQL.Add('select * from pedido_item order by id_item');
  qryItem.active := true;
end;

procedure TDm.ListarItensId(AId_Item: Integer);
begin
  qryItensId.Active := false;
  qryItensId.SQL.Clear;
  qryItensId.SQL.Add('select * from pedido_item');
  qryItensId.SQL.Add('where Id_Item = :Id      ');
  qryItensId.ParamByName('id').Value := Aid_Item;
  qryItensId.active := true;
end;

procedure TDm.EditarItem(id_item, qtd: integer);
begin
  if qtd = 0 then
    ExcluirItens(id_item)
  else
  begin
    qryItem.Active := false;
    qryItem.SQL.Clear;
    qryItem.SQL.Add('update pedido_item set qtd = :qtd');
    qryItem.SQL.Add('where id_item = :id_item');
    qryItem.ParamByName('qtd').Value := qtd;
    qryItem.ParamByName('id_item').Value := id_item;
    qryItem.ExecSQL;
  end;
end;

procedure TDm.InserirAdicional(AId_Adicional: integer;
                               ANome,
                               ADescricao: String;
                               AValor: Double);
begin

  if not dm.TabAdicionais.IsEmpty then
  begin
    qryInserirAdicionais.Close;
    qryInserirAdicionais.SQL.Clear;
    qryInserirAdicionais.SQL.Add('delete from adicional');
    qryInserirAdicionais.ExecSQL;
  end;

  qryInserirAdicionais.Close;
  qryInserirAdicionais.SQL.Clear;
  qryInserirAdicionais.SQL.Add('insert into adicional(id_adicional, nome, descricao, valor)');
  qryInserirAdicionais.SQL.Add('values (:id_adicional, :nome, :descricao, :valor)');

  dm.TabAdicionais.First;
  while not dm.TabAdicionais.Eof do
  begin
    qryInserirAdicionais.ParamByName('id_adicional').AsInteger := dm.TabAdicionais.FieldByName('id_adicional').AsInteger;
    qryInserirAdicionais.ParamByName('nome').AsString          := dm.TabAdicionais.FieldByName('nome').AsString;
    qryInserirAdicionais.ParamByName('descricao').AsString     := dm.TabAdicionais.FieldByName('descricao').AsString;
    qryInserirAdicionais.ParamByName('valor').AsFloat          := dm.TabAdicionais.FieldByName('valor').AsFloat;

    try
      qryInserirAdicionais.ExecSQL;
    except
      on e:exception do
      begin
        raise Exception.Create('Error Message: ' + e.ToString);
      end;
    end;
    Dm.TabAdicionais.Next;
  end;
end;

function TDm.InserirItem(id_produto, qtd: integer;
                          descricao, obs: string;
                          preco: double): integer;
begin
  Result := 0;

  qryItem.Active := false;
  qryItem.SQL.Clear;
  qryItem.SQL.Add('insert into pedido_item(id_produto, qtd, descricao, obs, preco)');
  qryItem.SQL.Add('values(:id_produto, :qtd, :descricao, :obs, :preco)');
  qryItem.SQL.Add('returning id_item');
  qryItem.ParamByName('id_produto').Value := id_produto;
  qryItem.ParamByName('qtd').Value        := qtd;
  qryItem.ParamByName('descricao').Value  := descricao;
  qryItem.ParamByName('obs').Value        := obs;
  qryItem.ParamByName('preco').Value      := preco;
  qryItem.Active := True;

  Result := qryItem.FieldByName('id_item').AsInteger;

end;

procedure TDm.InserirItemAdicionais(AIdItem, id_Adicional : integer;
                                    Qtd,
                                    Valor     : real);
begin

  qryAdicional.Active := false;
  qryAdicional.SQL.Clear;
  qryAdicional.SQL.Add('INSERT INTO ADICIONAIS_ITEM (ID_ITEM, ID_ADICIONAL, QUANTIDADE, VALOR)');
  qryAdicional.SQL.Add('values                     (:id_item, :id_Adicional, :Qtd,       :Valor)');

  qryAdicional.ParamByName('id_item').Value      := AIdItem;
  qryAdicional.ParamByName('Id_adicional').Value := Id_Adicional;
  qryAdicional.ParamByName('Qtd').Value          := Qtd;
  qryAdicional.ParamByName('Valor').Value        := Valor;
  qryAdicional.ExecSQL;

end;

procedure TDm.FinalizarPedido(id_comanda              : integer;
                              TipoAtendimento         : TOrigemPedido;
                              Telefone                : String;
                              itens, AItensAdicionais : TFDQuery);
var
    resp             : IResponse;
    json             : TJsonObject;
    LTipo_Atendimento: String;
begin

  case TipoAtendimento of
    tosBalcao:  LTipo_Atendimento := OrigemPedido[integer(TOrigemPedido.tosBalcao)];
    tosIntegracao: ;
    tosSalao:   LTipo_Atendimento   := OrigemPedido[integer(TOrigemPedido.tosSalao)];
  end;


    try
        json := TJSONObject.Create;
        json
          .AddPair('id_comanda',       id_comanda.ToString)
          .AddPair('itens',            itens.ToJSONArray)
          .AddPair('itensAdicionais',  AItensAdicionais.ToJSONArray)
          .AddPair('tipo_atendimento', LTipo_Atendimento)
          .AddPair('telefone_cliente', Telefone);

        resp := TRequest.New.BaseURL(TSession.servidor)
                            .Resource('pedidos')
                            .TokenBearer(TSession.token)
                            .AddBody(json.ToJSON)
                            .Accept('application/json')
                            .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.Free;
    end;
end;

procedure TDm.ListarItensComanda(id_comanda: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('comandas')
                        .ResourceSuffix(id_comanda.ToString)
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabComandaItem))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ListarAdicionais;
var
  resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('adicionais')
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabAdicionais))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ListarAdicionaisItens;
var
  resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('adicionais')
                        .Accept('application/json')
                        .ResourceSuffix('/itens-adicionais')
                        .TokenBearer(TSession.token)
                        .Adapters(TDataSetSerializeAdapter.New(TabItemAdicional))
                        .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.ExcluirItemPedido(id_pedido, id_item: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('pedidos')
                        .ResourceSuffix(id_pedido.ToString + '/itens/' + id_item.ToString)
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Delete;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDm.EncerrarComanda(id_comanda: integer);
var
    resp: IResponse;
    LJSONResposta : TJSONValue;
begin
    resp := TRequest.New.BaseURL(TSession.servidor)
                        .Resource('comandas')
                        .ResourceSuffix(id_comanda.tostring + '/encerramento')
                        .Accept('application/json')
                        .TokenBearer(TSession.token)
                        .Post;

    if resp.StatusCode <> 200 then
    begin
        try
          LJSONResposta := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(resp.content), 0) as TJSONObject;
          raise Exception.Create((LJSONResposta as TJSONObject).GetValue<string>('message', ''));
        finally
          LJSONResposta.Free;
        end;
    end;
end;

procedure TDm.DeletarRegistrosTabelas;
begin

  try

     qryItem.Close;
     qryItem.SQL.Clear;
     qryItem.SQL.Add('Delete * from Pedido_Item');
     qryItem.ExecSQL;

     qryAdicional.Close;
     qryAdicional.SQL.Clear;
     qryAdicional.SQL.Add('Delete * from Adicionais_Item');
     qryAdicional.ExecSQL;

  finally

  end;



end;

function Tdm.CalcularTotalAdicionaisPorIdPedido(AID : Integer) : currency;

begin

    Result := 0;

    qryAdicional.Close;
    qryAdicional.SQL.Clear;
    qryAdicional.Sql.Add('Select Coalesce(Sum(Valor), 0) as valor from ADICIONAIS_ITEM ');
    qryAdicional.Sql.Add('where Id_Item = :ID                    ');
    qryAdicional.Params.ParamByName('Id').Value := Aid;
    qryAdicional.Open;

    if not qryAdicional.IsEmpty then
      result := qryAdicional.FieldByName('valor').AsCurrency;

end;


end.
