unit unitFrameAdicionais;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrameAdicionais = class(TFrame)
    a: TRectangle;
    lytBotão: TLayout;
    lyt: TLayout;
    lblAdicionais: TLabel;
    lblValor: TLabel;
    Layout1: TLayout;
    btnMenos: TSpeedButton;
    Image3: TImage;
    btnMais: TSpeedButton;
    Image1: TImage;
    lblQtd: TLabel;
    procedure btnMaisClick(Sender: TObject);
  private
    procedure EditarQtd(btn: TSpeedButton);
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrameAdicionais.EditarQtd(btn: TSpeedButton);
begin
  lblQtd.Tag := lblQtd.Tag + btn.Tag;

  if lblQtd.Tag < 0 then
    lblQtd.Tag := 0;

  lblQtd.Text := lblQtd.Tag.ToString;
end;



procedure TFrameAdicionais.btnMaisClick(Sender: TObject);
begin
  EditarQtd(TSpeedButton(Sender));


  if btnMenos.Visible = False then
  begin
    btnMenos.Visible := True;
    lblQtd.Visible   := True;
  end;



end;



end.
