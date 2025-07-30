program EasyComanda;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  uLoading in 'Utils\uLoading.pas',
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  UnitConfig in 'UnitConfig.pas' {FrmConfig},
  UnitFrameMesa in 'Frames\UnitFrameMesa.pas' {FrameMesa: TFrame},
  uActionSheet in 'Utils\uActionSheet.pas',
  UnitTransferenciaConsumo in 'UnitTransferenciaConsumo.pas' {FrmTransferenciaConsumo},
  UnitReservaMesa in 'UnitReservaMesa.pas' {FrmReservaMesa},
  UnitMesaAbertura in 'UnitMesaAbertura.pas' {FrmMesaAbertura},
  UnitFrameComanda in 'Frames\UnitFrameComanda.pas' {FrameComanda: TFrame},
  UnitProduto in 'UnitProduto.pas' {FrmProduto},
  UnitFrameCategoria in 'Frames\UnitFrameCategoria.pas' {FrameCategoria: TFrame},
  UnitPedido in 'UnitPedido.pas' {FrmPedido},
  uListboxLayout in 'Utils\uListboxLayout.pas',
  UnitFechamento in 'UnitFechamento.pas' {FrmFechamento},
  uSession in 'Utils\uSession.pas',
  DataModule.Global in 'DataModules\DataModule.Global.pas' {Dm: TDataModule},
  unitFrameAdicionais in 'Frames\unitFrameAdicionais.pas' {FrameAdicionais: TFrame},
  unitPedidoBalcao in 'unitPedidoBalcao.pas' {FrmPedidoBalcao},
  Core.Utils.Tipos in '..\Core\Utils\Core.Utils.Tipos.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TDm, Dm);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmPedidoBalcao, FrmPedidoBalcao);
  Application.Run;
end.
