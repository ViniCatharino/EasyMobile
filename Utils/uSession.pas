unit uSession;

interface

type
  TSession = class
  private
    class var Ftoken: string;
    class var Flogin: string;
    class var Fnome: string;
    class var Fid_usuario: integer;
    class var Fservidor: string;
  public
    class property id_usuario: integer read Fid_usuario write Fid_usuario;
    class property nome: string read Fnome write Fnome;
    class property login: string read Flogin write Flogin;
    class property token: string read Ftoken write Ftoken;
    class property servidor: string read Fservidor write Fservidor;
  end;

implementation

end.
