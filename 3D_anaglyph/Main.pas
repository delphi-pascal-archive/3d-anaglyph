unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, _3DCameraView, ExtCtrls, _Utils, _Types, _3DScene, StdCtrls,
  ComCtrls;

type
  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    PanelL: TPanel;
    PanelR: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PanelClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    cam: T3DCameraViewAnaglyph;
    tstscn: T3DScene;
    ModeDraw: Byte; // 0 - stereo, 1 - 3D color, 2 - Left, 3 - Right
    bmL,bmR: TBitmap;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  pnts: array [0..11] of T3DPoint;
  testobj: T3DObject;

  procedure initfig(obj: T3DObject; clrBrush,clrPen: TColor; Scale: RealType);
  var
    newp: array [0..11] of T3DPoint;
    i: Integer;
  begin
    for i := 0 to 11 do
      begin
        newp[i].X := pnts[i].X * Scale;
        newp[i].Y := pnts[i].Y * Scale;
        newp[i].Z := pnts[i].Z * Scale;
      end;
    obj.Add3(newp[0],newp[2],newp[1], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[0],newp[3],newp[2], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[0],newp[4],newp[3], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[0],newp[5],newp[4], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[0],newp[1],newp[5], True,True,True, clrBrush, clrPen);

    obj.Add3(newp[1],newp[2],newp[6], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[2],newp[7],newp[6], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[2],newp[3],newp[7], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[3],newp[8],newp[7], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[3],newp[4],newp[8], True,True,True, clrBrush, clrPen);

    obj.Add3(newp[4],newp[9],newp[8], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[4],newp[5],newp[9], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[5],newp[10],newp[9], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[5],newp[1],newp[10], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[1],newp[6],newp[10], True,True,True, clrBrush, clrPen);

    obj.Add3(newp[7],newp[11],newp[6], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[7],newp[8],newp[11], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[9],newp[11],newp[8], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[9],newp[10],newp[11], True,True,True, clrBrush, clrPen);
    obj.Add3(newp[10],newp[6],newp[11], True,True,True, clrBrush, clrPen);
  end;

  procedure initkub(obj: T3DObject; clrBrush,clrPen: TColor; x,y,z: RealType);
  begin
    obj.Add4(_3DPoint(-x,-y,-z), _3DPoint(-x,y,-z),_3DPoint(x,y,-z),_3DPoint(x,-y,-z), True,True,True,True, clrBrush,clrPen);
    obj.Add4(_3DPoint(-x,-y,z), _3DPoint(x,-y,z),_3DPoint(x,y,z),_3DPoint(-x,y,z), True,True,True,True, clrBrush,clrPen);
    obj.Add4(_3DPoint(-x,-y,-z), _3DPoint(x,-y,-z),_3DPoint(x,-y,z),_3DPoint(-x,-y,z), True,True,True,True, clrBrush,clrPen);
    obj.Add4(_3DPoint(x,-y,-z), _3DPoint(x,y,-z),_3DPoint(x,y,z),_3DPoint(x,-y,z), True,True,True,True, clrBrush,clrPen);
    obj.Add4(_3DPoint(x,y,-z), _3DPoint(-x,y,-z),_3DPoint(-x,y,z),_3DPoint(x,y,z), True,True,True,True, clrBrush,clrPen);
    obj.Add4(_3DPoint(-x,y,-z), _3DPoint(-x,-y,-z),_3DPoint(-x,-y,z),_3DPoint(-x,y,z), True,True,True,True, clrBrush,clrPen);
  end;

begin
  DoubleBuffered := True;

  cam := T3DCameraViewAnaglyph.Create(_2DPoint(0,0), 15, 0, 0, 100, 0.5, ClientWidth, ClientHeight);
  pnts[0] := _3DPoint(0,1,0);
  pnts[1] := _3DPoint(0.951, 0.5, -0.309);
  pnts[2] := _3DPoint(0.587, 0.5, 0.809);
  pnts[3] := _3DPoint(-0.587, 0.5, 0.809);
  pnts[4] := _3DPoint(-0.951, 0.5, -0.309);
  pnts[5] := _3DPoint(0, 0.5, -1);
  pnts[6] := _3DPoint(0.951, -0.5, 0.309);
  pnts[7] := _3DPoint(0, -0.5, 1);
  pnts[8] := _3DPoint(-0.951, -0.5, 0.309);
  pnts[9] := _3DPoint(-0.587, -0.5, -0.809);
  pnts[10] := _3DPoint(0.587, -0.5, -0.809);
  pnts[11] := _3DPoint(0, -1, 0);

  tstscn := T3DScene.Create;

  testobj := T3DObject.Create(3,3,0);
  initfig(testobj, clGreen, clLime, 1.5);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(5,-2,0);
  initfig(testobj, clMaroon, clRed, 2);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(-3,0,-1);
  initfig(testobj, clNavy, clBlue, 1.8);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(2,2,5);
  initfig(testobj, clBlack, clGray, 2.5);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(0,4,0);
  initkub(testobj, clPurple,clFuchsia, 1,1,1);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(-3,-3,0);
  initkub(testobj, clYellow,clBlack, 1,0.5,5);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(2,-5,-2);
  initkub(testobj, clMoneyGreen,clGreen, 3,0.5,0.8);
  tstscn.Add(testobj);

  testobj := T3DObject.Create(0,0,0);
  initkub(testobj, clMoneyGreen,clGreen, 0.5,0.5,0.5);
  tstscn.Add(testobj);

  ModeDraw := 0;
  bmL := TBitmap.Create;
  bmR := TBitmap.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  tstscn.Free;
  bmL.Free;
  bmR.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  cam.SetBoundsToScreen(ClientWidth, ClientHeight);
  tstscn.CalcScreenCoords(cam);

  bmL.Width := ClientWidth;
  bmL.Height := ClientHeight;

  bmR.Width := ClientWidth;
  bmR.Height := ClientHeight;

  Invalidate;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Nothing: Boolean;
const
  dang = 3;
begin
  Nothing := False;
  case Key of
    VK_UP: cam.AngleSlopeCamera := cam.AngleSlopeCamera - dang;
    VK_DOWN: cam.AngleSlopeCamera := cam.AngleSlopeCamera + dang;
    VK_LEFT: cam.AngleTurnCamera := cam.AngleTurnCamera - dang;
    VK_RIGHT: cam.AngleTurnCamera := cam.AngleTurnCamera + dang;
    VK_ESCAPE: ModeDraw := (ModeDraw + 1) mod 4;
    109: cam.DistToLookPoint := cam.DistToLookPoint * 1.05;
    107: cam.DistToLookPoint := cam.DistToLookPoint / 1.05;
  else
    Nothing := True;
  end;

  if not Nothing then
    begin
      tstscn.CalcScreenCoords(cam);
      Invalidate;
    end
//  else
  //  Caption := inttostr(Key);
end;

procedure MixBitmaps(Bm1, Bm2: TBitmap);
var
  dstPixel, srcPixel: PRGBQuad;
  I: Integer;
begin
  if (Assigned(Bm1) and Assigned(Bm2)) then
  begin
    Bm1.PixelFormat := pf32bit;
    Bm2.PixelFormat := pf32bit;
    srcPixel := Bm2.ScanLine[Bm2.Height - 1];
    dstPixel := Bm1.ScanLine[Bm1.Height - 1];
    for I := (Bm1.Width * Bm1.Height) - 1 downto 0 do
    begin
      with dstPixel^ do
      begin
        rgbRed := rgbRed and srcPixel^.rgbRed;
        rgbGreen := rgbGreen and srcPixel^.rgbGreen;
        rgbBlue := rgbBlue and srcPixel^.rgbBlue;
      end;
      Inc(srcPixel);
      Inc(dstPixel);
    end;
  end;
end;

procedure TForm1.PanelClick(Sender: TObject);
begin
  ColorDialog1.Color := (Sender as TPanel).Color;
  if ColorDialog1.Execute then
    begin
      (Sender as TPanel).Color := ColorDialog1.Color;
      Invalidate;
    end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  case ModeDraw of
    0:  begin
          with bmL.Canvas do begin FillRect(ClientRect); Pen.Width := 2; end;
          with bmR.Canvas do begin FillRect(ClientRect); Pen.Width := 2; end;
          tstscn.DrawLeft(bmL.Canvas, PanelL.Color);
          tstscn.DrawRight(bmR.Canvas, PanelR.Color);
          MixBitmaps(bmL,bmR);
          Canvas.Draw(0,0,bmL);
        end;
    1: tstscn.Draw(Canvas);
    2: tstscn.DrawLeft(Canvas, PanelL.Color);
    3: tstscn.DrawRight(Canvas, PanelR.Color);
  end;
end;

end.
