unit _Utils;

interface

uses _Types, Windows, Math;

function _2DPoint(const aX,aY: RealType): T2DPoint;
function _3DPoint(const aX,aY,aZ: RealType): T3DPoint;

procedure StartTimemeter;                       // �������� ����������
function GetTimeAfterStartTimemeter: Cardinal;  // ������� ��������� ������������ ����� ��� ������ [������������] = 10E-6

procedure RotatePointInPlan(var Point: T3DPoint; const Ang: RealType);                                    // ������������ ����� Point � ��������� XY �� ���� Ang ������������ ������ ���������
procedure RotatePointInPlanByPoint(var Point: T3DPoint; const Ang: RealType; const MainPoint: T2DPoint);  // ������������ ����� Point � ��������� XY �� ���� Ang ������������ ����� MainPoint

function VectorProduct(const A,B: T3DPoint): T3DPoint;                    // ��������� ������������ (����������� ������� �������� ������, ���������������� ���������, ����������� �� ���� ������������)
function VectorAddition3D(const A,B: T3DPoint): T3DPoint;                 // ��������� �������� ���������� �������� (����������� ������� �������� ������ - ��������� ���������������)
function VectorAddition2D(const A,B: T2DPoint): T2DPoint;                 // ��������� �������� ���������� �������� (����������� ������� �������� ������ - ��������� ���������������)
function ScalarProduct(const A,B: T3DPoint): RealType;                    // c�������� ������������ (������������� ����� ��������-������������ � ���� ����� ����)
function ScaleVector(const A: T3DPoint; const Scale: RealType): T3DPoint; // ������������ ������
function CreateVector(const A,B: T3DPoint): T3DPoint;                     // ������� ������� ������ �� ���� ����� A,B. �� = (�.�-�.�,�.y-�.y,�.z-�.z)

function ClockWise3Point(P1,P2,P3: TPoint): Boolean;                      // �� ������� �� 3 �����
function _Move(P: T3DPoint; BP: T3DPoint): T3DPoint;

implementation

var
  timefortimemeter: Cardinal; // ���������� ���������� ���������� ����� ��� ������������

function _2DPoint(const aX,aY: RealType): T2DPoint;
begin
  Result.X := aX;
  Result.Y := aY;
end;

function _3DPoint(const aX,aY,aZ: RealType): T3DPoint;
begin
  Result.X := aX;
  Result.Y := aY;
  Result.Z := aZ;
end;

function _Move(P: T3DPoint; BP: T3DPoint): T3DPoint;
begin
  Result := _3DPoint(P.X+BP.X, P.Y+BP.Y, P.Z+BP.Z);
end;

function GetTimer: Cardinal;
var 
  t,f: Int64;
begin
  QueryPerformanceFrequency(f);
  QueryPerformanceCounter(t);
  Result:= Round(1000 * 1000 * t / f);
end;

procedure StartTimemeter; 
begin 
  timefortimemeter := GetTimer; 
end;

function GetTimeAfterStartTimemeter: Cardinal; 
begin
  Result := GetTimer - timefortimemeter;
end;

procedure RotatePointInPlan(var Point: T3DPoint; const Ang: RealType);
var
  DistInPlan: RealType;
  AngInPlan: RealType;
  sin_A,cos_A: Extended;
begin
  DistInPlan := Hypot(Point.x, Point.y);
  AngInPlan := ArcTan2(Point.y, Point.x);
  SinCos(AngInPlan + Ang, sin_A, cos_A);
  Point.X := DistInPlan*cos_A;
  Point.Y := DistInPlan*sin_A;
end;

procedure RotatePointInPlanByPoint(var Point: T3DPoint; const Ang: RealType; const MainPoint: T2DPoint);
begin
  Point.X := Point.X - MainPoint.X;
  Point.Y := Point.Y - MainPoint.Y;
  RotatePointInPlan(Point, Ang);
  Point.X := Point.X + MainPoint.X;
  Point.Y := Point.Y + MainPoint.Y;
end;

function VectorProduct(const A,B: T3DPoint): T3DPoint;
begin
  VectorProduct.x := A.y*B.z - B.y*A.z;
  VectorProduct.y := A.z*B.x - B.z*A.x;
  VectorProduct.z := A.x*B.y - B.x*A.y;
end;

function VectorAddition3D(const A,B: T3DPoint): T3DPoint;
begin
  VectorAddition3D := _3DPoint(A.x + B.x, A.y + B.y, A.z + B.z);
end;

function VectorAddition2D(const A,B: T2DPoint): T2DPoint;
begin
  VectorAddition2D := _2DPoint(A.x + B.x, A.y + B.y);
end;

function ScalarProduct(const A,B: T3DPoint): RealType;
begin
  ScalarProduct := A.x*B.x + A.y*B.y + A.z*B.z;
end;

function ScaleVector(const A: T3DPoint; const Scale: RealType): T3DPoint;
begin
  ScaleVector.x := A.x*Scale;
  ScaleVector.y := A.y*Scale;
  ScaleVector.z := A.z*Scale;    
end;

function CreateVector(const A,B: T3DPoint): T3DPoint;
begin
  CreateVector.x := B.x - A.x;
  CreateVector.y := B.y - A.y;
  CreateVector.z := B.z - A.z;
end;

function ClockWise3Point(P1,P2,P3: TPoint): Boolean;
begin
  Result := (P2.X - P1.X) * (P3.Y - P1.Y) >= (P2.Y - P1.Y) * (P3.X - P1.X);
end;

(*

�������, ����������� ��������� �������� ������� ������������:

int triangle_area_2 (int x1, int y1, int x2, int y2, int x3, int y3) {
	return (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
}

�������, ������������ ������� ������� ������������:

double triangle_area (int x1, int y1, int x2, int y2, int x3, int y3) {
	return abs (triangle_area_2 (x1, y1, x2, y2, x3, y3)) / 2.0;
}

�������, �����������, �������� �� ��������� ������ ����� ������� �� ������� �������:

bool clockwise (int x1, int y1, int x2, int y2, int x3, int y3) {
	return triangle_area_2 (x1, y1, x2, y2, x3, y3) < 0;
}

�������, �����������, �������� �� ��������� ������ ����� ������� ������ ������� �������:

bool counter_clockwise (int x1, int y1, int x2, int y2, int x3, int y3) {
	return triangle_area_2 (x1, y1, x2, y2, x3, y3) > 0;
*)


end.
