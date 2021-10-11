unit _3DScene;

interface

uses _Types, Types, Graphics, _3DCameraView, _Utils, Classes;

type

  T3DTriangle = class
    RP: array [1..3] of T3DPoint;
    RV: array [1..3] of Boolean;
    BColor, PColor: TColor;
    SP: array [1..3] of TPoint;
    ClockWise: Boolean;

    LSP,RSP: array [1..3] of TPoint;
    LClockWise,RClockWise: Boolean;

    constructor Create(Pnt1,Pnt2,Pnt3: T3DPoint; Rbr1,Rbr2,Rbr3: Boolean; BrushColor,PenColor: TColor);
    procedure CalcScreenPoints(cam: T3DCameraViewAnaglyph);
    procedure Draw(Canvas: TCanvas);
    procedure DrawLeft(Canvas: TCanvas; penColor: TColor);
    procedure DrawRight(Canvas: TCanvas; penColor: TColor);
  end;

  T3DObject = class
    ListObj: TList;
    VisibleObj: TList;
    CenterPoint: T3DPoint;
    DistToCamera: RealType;
    constructor Create(x,y,z: RealType);
    destructor Destroy; override;
    procedure CalcScreenCoords(cam: T3DCameraViewAnaglyph);
    procedure Draw(Canvas: TCanvas);
    procedure DrawLeft(Canvas: TCanvas; penColor: TColor);
    procedure DrawRight(Canvas: TCanvas; penColor: TColor);
    procedure Clear;
    procedure Add3(P1,P2,P3: T3DPoint; R1,R2,R3: Boolean; BrushColor,PenColor: TColor);
    procedure Add4(P1,P2,P3,P4: T3DPoint; R1,R2,R3,R4: Boolean; BrushColor,PenColor: TColor);
  end;

  T3DScene = class
    List3DObj: TList;
    constructor Create;
    destructor Destroy; override;
    procedure CalcScreenCoords(cam: T3DCameraViewAnaglyph);
    procedure Add(obj: T3DObject);
    procedure Draw(Canvas: TCanvas);
    procedure DrawLeft(Canvas: TCanvas; penColor: TColor);
    procedure DrawRight(Canvas: TCanvas; penColor: TColor);
  end;

implementation


constructor T3DTriangle.Create(Pnt1,Pnt2,Pnt3: T3DPoint; Rbr1,Rbr2,Rbr3: Boolean; BrushColor,PenColor: TColor);
begin
  inherited Create;
  RP[1] := Pnt1;
  RP[2] := Pnt2;
  RP[3] := Pnt3;
  RV[1] := Rbr1;
  RV[2] := Rbr2;
  RV[3] := Rbr3;
  BColor := BrushColor;
  PColor := PenColor;
end;

procedure T3DTriangle.CalcScreenPoints(cam: T3DCameraViewAnaglyph);
var
  i: Integer;
begin
  for i := 1 to 3 do SP[i] := cam.GetPixelCoord(RP[i].X, RP[i].Y, RP[i].Z);
  ClockWise := ClockWise3Point(SP[1],SP[2],SP[3]);

  // stereo
  for i := 1 to 3 do cam.GetLRPixelCoord(RP[i].X, RP[i].Y, RP[i].Z, LSP[i], RSP[i]);
  LClockWise := ClockWise3Point(LSP[1],LSP[2],LSP[3]);
  RClockWise := ClockWise3Point(RSP[1],RSP[2],RSP[3]);
end;

procedure T3DTriangle.Draw(Canvas: TCanvas);
var
  i,l: Integer;
begin
  if ClockWise then Exit;
  with Canvas do
    begin
      Brush.Color := BColor;
      Pen.Style := psClear;
      Canvas.Polygon(SP);
      Pen.Style := psSolid;
      Pen.Color := PColor;
      for i := 1 to 3 do
        if RV[i] then
          begin
            l := i mod 3 + 1;
            MoveTo(SP[i].X, SP[i].Y);
            LineTo(SP[l].X, SP[l].Y);
          end;
    end;
end;


procedure T3DTriangle.DrawLeft(Canvas: TCanvas; penColor: TColor);
var
  i,l: Integer;
begin
  if LClockWise then Exit;
  with Canvas do
    begin
      Brush.Color := clWhite;
      Pen.Style := psClear;
      Canvas.Polygon(LSP);
      Pen.Style := psSolid;
      Pen.Color := penColor;
      for i := 1 to 3 do
        if RV[i] then
          begin
            l := i mod 3 + 1;
            MoveTo(LSP[i].X, LSP[i].Y);
            LineTo(LSP[l].X, LSP[l].Y);
          end;
    end;
end;

procedure T3DTriangle.DrawRight(Canvas: TCanvas; penColor: TColor);
var
  i,l: Integer;
begin
  if RClockWise then Exit;
  with Canvas do
    begin
      Brush.Color := clWhite;
      Pen.Style := psClear;
      Canvas.Polygon(RSP);
      Pen.Style := psSolid;
      Pen.Color := penColor;
      for i := 1 to 3 do
        if RV[i] then
          begin
            l := i mod 3 + 1;
            MoveTo(RSP[i].X, RSP[i].Y);
            LineTo(RSP[l].X, RSP[l].Y);
          end;
    end;
end;


//

constructor T3DObject.Create;
begin
  inherited Create;
  CenterPoint := _3DPoint(x,y,z);
  ListObj := TList.Create;
  VisibleObj := TList.Create;
end;

destructor T3DObject.Destroy;
begin
  Clear;
  ListObj.Free;
  VisibleObj.Free;
  inherited Destroy;
end;

procedure T3DObject.CalcScreenCoords(cam: T3DCameraViewAnaglyph);
var
  i: Integer;
  tr: T3DTriangle;
begin
  VisibleObj.Clear;
  for i := 0 to ListObj.Count - 1 do
    begin
      TR := T3DTriangle(ListObj[i]);
      TR.CalcScreenPoints(cam);
      if not TR.ClockWise then VisibleObj.Add(TR);
    end;
  DistToCamera := Sqr(CenterPoint.X-cam.CoordCamera.X) + Sqr(CenterPoint.Y-cam.CoordCamera.Y) + Sqr(CenterPoint.Z-cam.CoordCamera.Z);
end;

procedure T3DObject.Draw(Canvas: TCanvas);
var
  i: Integer;
begin
  for i := 0 to VisibleObj.Count - 1 do T3DTriangle(VisibleObj[i]).Draw(Canvas);
end;

procedure T3DObject.DrawLeft(Canvas: TCanvas; penColor: TColor);
var
  i: Integer;
begin
  for i := 0 to VisibleObj.Count - 1 do T3DTriangle(VisibleObj[i]).DrawLeft(Canvas, penColor);
end;

procedure T3DObject.DrawRight(Canvas: TCanvas; penColor: TColor);
var
  i: Integer;
begin
  for i := 0 to VisibleObj.Count - 1 do T3DTriangle(VisibleObj[i]).DrawRight(Canvas, penColor);
end;

procedure T3DObject.Clear;
var
  i: Integer;
begin
  VisibleObj.Clear;
  for i := 0 to ListObj.Count - 1 do T3DTriangle(ListObj[i]).Free;
  ListObj.Clear;
end;

procedure T3DObject.Add3(P1,P2,P3: T3DPoint; R1,R2,R3: Boolean; BrushColor,PenColor: TColor);
begin
  ListObj.Add(T3DTriangle.Create(_Move(P1,CenterPoint),_Move(P2,CenterPoint),_Move(P3,CenterPoint), R1,R2,R3, BrushColor, PenColor));
end;

procedure T3DObject.Add4(P1,P2,P3,P4: T3DPoint; R1,R2,R3,R4: Boolean; BrushColor,PenColor: TColor);
begin
  Add3(P1,P2,P3, R1,R2,False, BrushColor, PenColor);
  Add3(P1,P3,P4, False,R3,R4, BrushColor, PenColor);
end;

/////

constructor T3DScene.Create;
begin
  inherited Create;
  List3DObj := TList.Create;
end;

destructor T3DScene.Destroy;
var
  i: Integer;
begin
  for i := 0 to List3DObj.Count - 1 do T3DObject(List3DObj[i]).Free;
  List3DObj.Free;
  inherited Destroy;
end;

procedure T3DScene.Draw(Canvas: TCanvas);
var
  i: Integer;
begin
  for i := 0 to List3DObj.Count - 1 do T3DObject(List3DObj[i]).Draw(Canvas);
end;

procedure T3DScene.DrawLeft(Canvas: TCanvas; penColor: TColor);
var
  i: Integer;
begin
  for i := 0 to List3DObj.Count - 1 do T3DObject(List3DObj[i]).DrawLeft(Canvas, penColor);
end;

procedure T3DScene.DrawRight(Canvas: TCanvas; penColor: TColor);
var
  i: Integer;
begin
  for i := 0 to List3DObj.Count - 1 do T3DObject(List3DObj[i]).DrawRight(Canvas, penColor);
end;

procedure T3DScene.Add(obj: T3DObject);
begin
  List3DObj.Add(obj);
end;

procedure T3DScene.CalcScreenCoords(cam: T3DCameraViewAnaglyph);
var
  i,j: Integer;
  obj1,obj2: T3DObject;
begin
  for i := 0 to List3DObj.Count - 1 do T3DObject(List3DObj[i]).CalcScreenCoords(cam);

  for i := 0 to List3DObj.Count - 1 do
  for j := 0 to List3DObj.Count - 1 do
    if i <> j then
      begin
        obj1 := T3DObject(List3DObj[i]);
        obj2 := T3DObject(List3DObj[j]);
        if obj1.DistToCamera > obj2.DistToCamera then
          List3DObj.Exchange(i,j);
      end;
end;

end.
