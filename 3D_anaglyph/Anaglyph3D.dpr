program Anaglyph3D;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  _3DCameraView in '_3DCameraView.pas',
  _Types in '_Types.pas',
  _Utils in '_Utils.pas',
  _3DScene in '_3DScene.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
