unit _3DCameraView;

interface

uses _Types, Types, Math;

type

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//  TCamera3DView - ����������� ������ � ������������                        //
//                                                                           //
//  ���������� ��������� ������� ������������:                               //
//  ������� ��������� 3D - 2D, ��� ��������� �������������� �����������      //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  T3DCameraViewAnaglyph = class
  private
    { ��. property }
    fLookPoint        : T2DPoint;
    fDistToLookPoint  : RealType;
    fAngleSlope       : RealType;
    fAngleTurn        : RealType;
    fViewAngle        : RealType;
    fCoordCamera      : T3DPoint;
    fLeftCam,fRightCam: T3DPoint;
    fDistLeftRight    : RealType;
    { ������������� ���������� ��� �������� }
    Xaxis,Yaxis,Zaxis: T3DPoint;  // ��������� �������, ��������������� ���������� ��������� ������������� � ������������
    DistToScreen     : RealType;  // ��������� �� ������ �� ��������� ��� ������������� �������������� �����������
    HalfWidthScr     : RealType;  // �������� ������ ������
    HalfHeightScr    : RealType;  // �������� ������ ������
    HalfDiagonal     : RealType;  // �������� ��������� ������
    { ����������� ������ }
    procedure CalcCoordOfCamera;  // ���������� ���������� ������
    procedure CalcDistToScreen;   // ���������� ���������� �� ������� �� ��������� ������������� �����������
    procedure CalcOrientation;    // ���������� ��������� �������� Xaxis, Yaxis � Zaxis
    { ��. property }
    procedure SetLookPoint(LP: T2DPoint);
    procedure SetDistToLookPoint(DistToLP: RealType);
    procedure SetAngleSlope(AngSlopeInDeg: RealType);
    procedure SetAngleTurn(AngTurnInDeg: RealType);
    procedure SetViewAngle(ViewAngInDeg: RealType);
    procedure SetDistLeftRight(DistLeftRight: RealType);
    function GetAngleSlope: RealType;
    function GetAngleTurn: RealType;
    function GetViewAngle: RealType;
  public
    { �������� ��� ������������ }
    property LookPoint: T2DPoint read fLookPoint write SetLookPoint;                     // ����� � ��������� XY �������� ������������, �� ������� ������� ������
    property DistToLookPoint: RealType read fDistToLookPoint write SetDistToLookPoint;   // ���������� ����� ������� � ������ LookPoint
    property AngleSlopeCamera: RealType read GetAngleSlope write SetAngleSlope;          // ���� ������� ������
    property AngleTurnCamera: RealType read GetAngleTurn write SetAngleTurn;             // ���� �������� ������ � ��������� XY �������� ������������
    property ViewAngle: RealType read GetViewAngle write SetViewAngle;                   // ���� ������ ������ (���������� DistToScreen ����� �������� ������)
    property CoordCamera: T3DPoint read fCoordCamera;                                    // ���������� ������ (�������)
    property CoordLeftCamera: T3DPoint read fLeftCam;                                    // ���������� ����� ������
    property CoordRightCamera: T3DPoint read fRightCam;                                  // ���������� ������ ������
    property DistLeftRightCamera: RealType read fDistLeftRight write SetDistLeftRight;   // ���������� ����� ����� � ������� ��������
    { ������ ��� ������������ }
    constructor Create(_LookPoint: T2DPoint; _DistToLookPoint, _AngleSlope, _AngleTurn,  // ������������� ������
                       _ViewAngle, _DistLeftRightCamera: RealType; WidthScreen, HeightScreen: Integer);        //
    procedure SetBoundsToScreen(WidthScreen, HeightScreen: Integer);                     // ������������� ������� ������� ������ �����������
    function GetPixelCoord(const X,Y,Z: RealType): TPoint;                               // ��������� ���������� ����� �� ������� ������ � ������ ���� ���������� ������
    procedure GetLRPixelCoord(const X,Y,Z: RealType; var LeftP,RightP: TPoint);          // --//-- ��� ����� � ������ �����
    function GetWorldPlanCoord(PixelPoint: TPoint): T2DPoint;                            // ��������� ���������� ����� ��������� XY ������������ ����� �������� ����������
    procedure MoveCameraByMouse(FromMousePos, ToMousePos: TPoint);                       // �������� ������ ������������ ��������� ������� FromMousePos � ToMousePos
    procedure ChangeDistFromCameraByCurrentPoint(MousePos: TPoint; Koef: RealType);      // ���������� ���� �������� ������ ������������ ����� MousePos
  end;

implementation

uses _Utils;

procedure T3DCameraViewAnaglyph.SetLookPoint(LP: T2DPoint);
begin
  fCoordCamera := VectorAddition3D(fCoordCamera, _3DPoint(LP.X - fLookPoint.X, LP.Y - fLookPoint.Y, 0));
  fLookPoint := LP;
end;

procedure T3DCameraViewAnaglyph.CalcCoordOfCamera;
begin
  fCoordCamera := VectorAddition3D(ScaleVector(Zaxis, fDistToLookPoint), _3DPoint(fLookPoint.X, fLookPoint.Y, 0));
  fLeftCam := VectorAddition3D(ScaleVector(Xaxis, -fDistLeftRight/2), fCoordCamera);
  fRightCam := VectorAddition3D(ScaleVector(Xaxis, fDistLeftRight/2), fCoordCamera);
end;

procedure T3DCameraViewAnaglyph.CalcDistToScreen;
begin
  DistToScreen := HalfDiagonal/Tan(fViewAngle/2);
end;

procedure T3DCameraViewAnaglyph.CalcOrientation;
begin
  Xaxis := _3DPoint(1,0,0);
  Yaxis := _3DPoint(0, Cos(fAngleSlope), Sin(fAngleSlope));
  RotatePointInPlan(Xaxis, fAngleTurn);
  RotatePointInPlan(Yaxis, fAngleTurn);
  Zaxis := VectorProduct(Xaxis, Yaxis);
end;

procedure T3DCameraViewAnaglyph.SetDistToLookPoint(DistToLP: RealType);
begin
  fDistToLookPoint := DistToLP;
  CalcCoordOfCamera;
end;

procedure T3DCameraViewAnaglyph.SetDistLeftRight(DistLeftRight: RealType);
begin
  fDistLeftRight := DistLeftRight;
  CalcCoordOfCamera;
end;


function T3DCameraViewAnaglyph.GetAngleSlope: RealType;
begin
  Result := RadToDeg(fAngleSlope);
end;

function T3DCameraViewAnaglyph.GetAngleTurn: RealType;
begin
  Result := RadToDeg(fAngleTurn);
end;

procedure T3DCameraViewAnaglyph.SetAngleSlope(AngSlopeInDeg: RealType);
begin
  fAngleSlope := DegToRad(AngSlopeInDeg);
  CalcOrientation;
  CalcCoordOfCamera;  
end;

procedure T3DCameraViewAnaglyph.SetAngleTurn(AngTurnInDeg: RealType);
begin
  fAngleTurn := DegToRad(AngTurnInDeg);
  CalcOrientation;
  CalcCoordOfCamera;  
end;

function T3DCameraViewAnaglyph.GetViewAngle: RealType;
begin
  Result := RadToDeg(fViewAngle);
end;

procedure T3DCameraViewAnaglyph.SetViewAngle(ViewAngInDeg: RealType);
begin
  fViewAngle := DegToRad(ViewAngInDeg);
  CalcDistToScreen;
end;

procedure T3DCameraViewAnaglyph.SetBoundsToScreen(WidthScreen, HeightScreen: Integer);
begin
  HalfWidthScr := WidthScreen/2;
  HalfHeightScr := HeightScreen/2;
  HalfDiagonal := Sqrt(Sqr(HalfWidthScr) + Sqr(HalfHeightScr));
  CalcDistToScreen;
end;

constructor T3DCameraViewAnaglyph.Create(_LookPoint: T2DPoint; _DistToLookPoint, _AngleSlope, _AngleTurn,
                                 _ViewAngle, _DistLeftRightCamera: RealType; WidthScreen, HeightScreen: Integer);
begin
  inherited Create;
  fLookPoint := _LookPoint;
  fAngleSlope := DegToRad(_AngleSlope);
  fAngleTurn := DegToRad(_AngleTurn);
  fViewAngle := DegToRad(_ViewAngle);
  fDistLeftRight := _DistLeftRightCamera;
  CalcOrientation;
  SetDistToLookPoint(_DistToLookPoint);
  SetBoundsToScreen(WidthScreen, HeightScreen);
end;

function T3DCameraViewAnaglyph.GetPixelCoord(const X,Y,Z: RealType): TPoint;
var
  Vector: T3DPoint;
  E,D: RealType;
begin
(*
  Vector := CreateVector(fCoordCamera, _3DPoint(X, Y, Z)); // ������� ������: ������ -> ����� ����
  E := ScalarProduct(Zaxis, Vector);
  { �� ���� ��� ����� �������� ������� �� ���� /E }
  Vector := ScaleVector(Vector, -DistToScreen/E); // ������� ������: ������ -> ����� ����������� � ���������� �������������
  // � ��� � ���������:
  Result.X := Round(HalfWidthScr + ScalarProduct(Xaxis, Vector));
  Result.Y := Round(HalfHeightScr - ScalarProduct(Yaxis, Vector));
*)

// ��� ������� ��� ��� (* ... *):

  { ������� ������: ������ -> ����� ���� }
  Vector.X := X - fCoordCamera.X;
  Vector.Y := Y - fCoordCamera.Y;
  Vector.Z := Z - fCoordCamera.Z;

  E := Zaxis.X*Vector.X + Zaxis.Y*Vector.Y + Zaxis.Z*Vector.Z;
  if E = 0 then D := 0 else D := -DistToScreen/E;

  { ������� ������: ������ -> ����� ����������� � ���������� ������������� }
  Vector.X := Vector.X*D;
  Vector.Y := Vector.Y*D;
  Vector.Z := Vector.Z*D;

  // � ��� � ���������:
  Result.X := Round(HalfWidthScr + Xaxis.X*Vector.X + Xaxis.Y*Vector.Y + Xaxis.Z*Vector.Z);
  Result.Y := Round(HalfHeightScr - Yaxis.X*Vector.X - Yaxis.Y*Vector.Y - Yaxis.Z*Vector.Z);
end;

procedure T3DCameraViewAnaglyph.GetLRPixelCoord(const X,Y,Z: RealType; var LeftP,RightP: TPoint);
var
  Vector: T3DPoint;
  E,D: RealType;
begin
  { ������� ������: ����� ������ -> ����� ���� }
  Vector.X := X - fLeftCam.X;
  Vector.Y := Y - fLeftCam.Y;
  Vector.Z := Z - fLeftCam.Z;

  E := Zaxis.X*Vector.X + Zaxis.Y*Vector.Y + Zaxis.Z*Vector.Z;
  if E = 0 then D := 0 else D := -DistToScreen/E;

  { ������� ������: ������ -> ����� ����������� � ���������� ������������� }
  Vector.X := Vector.X*D;
  Vector.Y := Vector.Y*D;
  Vector.Z := Vector.Z*D;

  // � ��� � ��������� ��� ����� �����:
  LeftP.X := Round(HalfWidthScr + Xaxis.X*Vector.X + Xaxis.Y*Vector.Y + Xaxis.Z*Vector.Z);
  LeftP.Y := Round(HalfHeightScr - Yaxis.X*Vector.X - Yaxis.Y*Vector.Y - Yaxis.Z*Vector.Z);

  { ������� ������: ������ ������ -> ����� ���� }
  Vector.X := X - fRightCam.X;
  Vector.Y := Y - fRightCam.Y;
  Vector.Z := Z - fRightCam.Z;

  E := Zaxis.X*Vector.X + Zaxis.Y*Vector.Y + Zaxis.Z*Vector.Z;
  if E = 0 then D := 0 else D := -DistToScreen/E;

  { ������� ������: ������ -> ����� ����������� � ���������� ������������� }
  Vector.X := Vector.X*D;
  Vector.Y := Vector.Y*D;
  Vector.Z := Vector.Z*D;

  // � ��� � ��������� ��� ������ �����:
  RightP.X := Round(HalfWidthScr + Xaxis.X*Vector.X + Xaxis.Y*Vector.Y + Xaxis.Z*Vector.Z);
  RightP.Y := Round(HalfHeightScr - Yaxis.X*Vector.X - Yaxis.Y*Vector.Y - Yaxis.Z*Vector.Z);
end;


function T3DCameraViewAnaglyph.GetWorldPlanCoord(PixelPoint: TPoint): T2DPoint;
var
  A: T3DPoint;   // ����� PixelPoint � ������� ����������� �� ��������� �������������
begin
  A := VectorAddition3D(VectorAddition3D(ScaleVector(Zaxis, fDistToLookPoint - DistToScreen), _3DPoint(fLookPoint.X, fLookPoint.Y, 0)),         // ���������� ����������� ����� ��������� ������������� � ������������
                        VectorAddition3D(ScaleVector(Xaxis, PixelPoint.X - HalfWidthScr), ScaleVector(Yaxis, HalfHeightScr - PixelPoint.Y)));   // ������ �������� ����������� ����� ��������� ������������� ��� PixelPoint � ������������
  // ���������:
  Result.X := A.Z*(A.X - fCoordCamera.X)/(fCoordCamera.Z - A.Z) + A.X;
  Result.Y := A.Z*(A.Y - fCoordCamera.Y)/(fCoordCamera.Z - A.Z) + A.Y;
end;

procedure T3DCameraViewAnaglyph.MoveCameraByMouse(FromMousePos, ToMousePos: TPoint);
var
  P1,P2: T2DPoint;
begin
  P1 := GetWorldPlanCoord(FromMousePos);
  P2 := GetWorldPlanCoord(ToMousePos);
  SetLookPoint(VectorAddition2D(fLookPoint, _2DPoint(P1.X - P2.X, P1.Y - P2.Y)));
end;

procedure T3DCameraViewAnaglyph.ChangeDistFromCameraByCurrentPoint(MousePos: TPoint; Koef: RealType);
var
  P1,P2: T2DPoint;
begin
  P1 := GetWorldPlanCoord(MousePos);   
  SetDistToLookPoint(fDistToLookPoint*Koef); 
  P2 := GetWorldPlanCoord(MousePos);   
  SetLookPoint(VectorAddition2D(fLookPoint, _2DPoint(P1.X - P2.X, P1.Y - P2.Y)));  
end;

end.
