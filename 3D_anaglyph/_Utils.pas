unit _Utils;

interface

uses _Types, Windows, Math;

function _2DPoint(const aX,aY: RealType): T2DPoint;
function _3DPoint(const aX,aY,aZ: RealType): T3DPoint;

procedure StartTimemeter;                       // стартует секундомер
function GetTimeAfterStartTimemeter: Cardinal;  // снимает показания секундометра после его старта [микросекунды] = 10E-6

procedure RotatePointInPlan(var Point: T3DPoint; const Ang: RealType);                                    // поворачивает точку Point в плоскости XY на угол Ang относительно начала координат
procedure RotatePointInPlanByPoint(var Point: T3DPoint; const Ang: RealType; const MainPoint: T2DPoint);  // поворачивает точку Point в плоскости XY на угол Ang относительно точки MainPoint

function VectorProduct(const A,B: T3DPoint): T3DPoint;                    // векторное произведение (результатом которой является вектор, перпендикулярный плоскости, построенной по двум сомножителям)
function VectorAddition3D(const A,B: T3DPoint): T3DPoint;                 // векторное сложение трехмерных векторов (результатом которой является вектор - диагональ параллелограмма)
function VectorAddition2D(const A,B: T2DPoint): T2DPoint;                 // векторное сложение двухмерных векторов (результатом которой является вектор - диагональ параллелограмма)
function ScalarProduct(const A,B: T3DPoint): RealType;                    // cкалярное произведение (характеризует длины векторов-сомножителей и угол между ними)
function ScaleVector(const A: T3DPoint; const Scale: RealType): T3DPoint; // масштабирует вектор
function CreateVector(const A,B: T3DPoint): T3DPoint;                     // функция создает вектор из двух точек A,B. АВ = (В.х-А.х,В.y-А.y,В.z-А.z)

function ClockWise3Point(P1,P2,P3: TPoint): Boolean;                      // по часовой ли 3 точки
function _Move(P: T3DPoint; BP: T3DPoint): T3DPoint;

implementation

var
  timefortimemeter: Cardinal; // внутренняя глобальная переменная юнита для секундометра

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

Функция, вычисляющая удвоенную знаковую площадь треугольника:

int triangle_area_2 (int x1, int y1, int x2, int y2, int x3, int y3) {
	return (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
}

Функция, возвращающая обычную площадь треугольника:

double triangle_area (int x1, int y1, int x2, int y2, int x3, int y3) {
	return abs (triangle_area_2 (x1, y1, x2, y2, x3, y3)) / 2.0;
}

Функция, проверяющая, образует ли указанная тройка точек поворот по часовой стрелке:

bool clockwise (int x1, int y1, int x2, int y2, int x3, int y3) {
	return triangle_area_2 (x1, y1, x2, y2, x3, y3) < 0;
}

Функция, проверяющая, образует ли указанная тройка точек поворот против часовой стрелки:

bool counter_clockwise (int x1, int y1, int x2, int y2, int x3, int y3) {
	return triangle_area_2 (x1, y1, x2, y2, x3, y3) > 0;
*)


end.
