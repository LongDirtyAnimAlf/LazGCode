unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ExtCtrls, Types,
  SynEdit, SynEditHighlighter, SynHighlighterCNC,
  BGRAPath, BGRABitmapTypes, BGRABitmap, BGRACanvas2D, BGRAVirtualScreen, BGRALayers;

type
  TtkGCodeKind =
  (
  Unknown,
  G0,            //Coordinated Motion at Rapid Rate
  G1,            //Coordinated Motion at Feed Rate
  G2,G3,         //Coordinated Helical Motion at Feed Rate
  G4,            //Dwell
  G5,            //Cubic Spline
  G5_1,          //Quadratic B-Spline
  G5_2,          //NURBS, add control point
  G7,            //Diameter Mode (lathe)
  G8,            //Radius Mode (lathe)
  G10,
  G10_L1,        //Set Tool Table Entry
  G10_L10,       //Set Tool Table, Calculated, Workpiece
  G10_L11,       //Set Tool Table, Calculated, Fixture
  G10_L2,        //Coordinate System Origin Setting
  G10_L20,       //Coordinate System Origin Setting Calculated
  G12,G13,       //Circular pocket
  G15,G16,       //Polar/cartesian mode for G0/G1
  G17,G18,G19,   //Plane Select
  G20,G21,       //Set Units of Measure
  G28,           //Go to Predefined Position
  G30,           //Go to Predefined Position
  G33,           //Spindle Synchronized Motion
  G33_1,         //Rigid Tapping
  G38,           //Probing
  G40,           //Cancel Cutter Compensation
  G41,G42,       //Cutter Compensation
  G41_1,G42_1,   //Dynamic Cutter Compensation
  G43,           //Use Tool Length Offset from Tool Table
  G43_1,         //Dynamic Tool Length Offset
  G43_2,         //Apply additional Tool Length Offset
  G49,           //Cancel Tool Length Offset
  G52,           //Local Coordinate System Offset
  G53,           //Move in Machine Coordinates
  G54,           //Select Coordinate System (1 - 9)
  G55,
  G56,
  G57,
  G58,
  G59,
  G61,           //Exact Path Mode
  G61_1,         //Exact Stop Mode
  G64,           //Path Control Mode with Optional Tolerance
  G73,           //Drilling Cycle with Chip Breaking
  G74,           //Left-hand Tapping Cycle with Dwell
  G76,           //Multi-pass Threading Cycle (Lathe)
  G80,           //Cancel Motion Modes
  G81,           //Drilling Cycle
  G82,           //Drilling Cycle with Dwell
  G83,           //Drilling Cycle with Peck
  G84,           //Right-hand Tapping Cycle with Dwell
  G85,           //Boring Cycle, No Dwell, Feed Out
  G86,           //Boring Cycle, Stop, Rapid Out
  G87,
  G88,
  G89,           //Boring Cycle, Dwell, Feed Out
  G90,G91,       //Distance Mode
  G90_1,G91_1,   //Arc Distance Mode
  G92,           //Coordinate System Offset
  G92_1,G92_2,   //Cancel G92 Offsets
  G92_3,         //Restore G92 Offsets
  G93,G94,G95,   //Feed Modes
  G96,           //Spindle Control Mode
  G98,G99        //Canned Cycle Z Retract Mode
  );

  TtkPlane =
  (
    XY_plane,    // (G17)
    XZ_plane,    // (G18)
    YZ_plane     // (G19)
  );



const
  GCODE_NONMODAL: set of TtkGCodeKind = [G4, G10, G28, G30, G53, G92, G92_1, G92_2, G92_3];
  GCODE_MOTION : set of TtkGCodeKind = [G0, G1, G2, G3, G5, G5_1, G5_2, G80, G81, G82, G84, G85, G86, G87, G88, G89];
  GCODE_DISTANCE : set of TtkGCodeKind = [G90, G91];
  GCODE_ARCDISTANCE : set of TtkGCodeKind = [G90_1,G91_1];
  GCODE_PLANE : set of TtkGCodeKind = [G17, G18, G19];
  GCODE_FEED : set of TtkGCodeKind = [G93, G94];
  GCODE_UNIT : set of TtkGCodeKind = [G20, G21];
  GCODE_COORDINATE : set of TtkGCodeKind = [G54, G55, G56, G57, G58, G59];
  GCODE_CUTTERCOMP : set of TtkGCodeKind = [G40, G41, G42];

type
  { TGCodeViewer }

  TGCodeData = record
    PrevValue: double;
    NewValue: double;
    ValueSet:boolean;
  end;

  TGCodeDataArray = array[TtkTokenKind] of TGCodeData;

  TGCodeViewer = class(TForm)
    btnLoadLetters: TButton;
    btnRenderGCode: TButton;
    btnTraceGCode: TButton;
    btnLoadBear: TButton;
    btnTraceView: TButton;
    buttonQuit: TButton;
    CommandOutputScreen: TSynEdit;
    editFileInput: TFileNameEdit;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    memoLetters: TMemo;
    memoBear: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnLoadBearClick(Sender: TObject);
    procedure btnRenderGCodeClick(Sender: TObject);
    procedure btnTraceGCodeClick(Sender: TObject);
    procedure buttonQuitClick(Sender: TObject);
    procedure editFileInputAcceptFileName(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
  private
    { private declarations }
    GCData        : TGCodeDataArray;
    CNC           : TSynCNCSyn;

    newc          : TBGRACanvas2D;

    newp          : TBGRAPath;
    newp_boundsF  : TRectF;

    zoom          : double;
    moving        : boolean;
    moveOrigin    : TPoint;
    moveTranslate : TPoint;

    bmpl          : TBGRALayeredBitmap;
    FFlattened    : TBGRABitmap;
    FGCodeLayer   : TBGRABitmap;
    FCursorLayer  : TBGRABitmap;

    BGRAVirtualScreen2: TBGRAVirtualScreen;
    BGRAVirtualScreen3: TBGRAVirtualScreen;

    procedure BGRAVirtualScreen2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BGRAVirtualScreen2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BGRAVirtualScreen2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BGRAVirtualScreen2MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure BGRAVirtualScreen2Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure BGRAVirtualScreen3Redraw(Sender: TObject; Bitmap: TBGRABitmap);

    procedure UpdateFlattenedImage(ARect: TRect; AUpdateView: boolean=true);
    procedure UpdateGCodeImage(AUpdateView: boolean=true);
    procedure UpdateCursorImage(Location:TPoint;AUpdateView: boolean=true);

    procedure TraceGCode(Sender: TObject);
  public
    { public declarations }
  end;

var
  GCodeViewer: TGCodeViewer;

implementation

uses
  TypInfo,
  Tools,
  FPImage,
  FPCanvas;

{$R *.lfm}

{ TGCodeViewer }

procedure TGCodeViewer.FormCreate(Sender: TObject);
begin
  CNC := TSynCNCSyn.Create(CommandOutputScreen);
  CommandOutputScreen.Highlighter := CNC;

  newp_boundsF:=RectF(0,0,0,0);
  newp:=TBGRAPath.Create;

  BGRAVirtualScreen2:=TBGRAVirtualScreen.Create(Self);
  BGRAVirtualScreen2.Parent:=Panel1;
  BGRAVirtualScreen2.Align:=alClient;
  BGRAVirtualScreen2.OnRedraw:=@BGRAVirtualScreen2Redraw;
  BGRAVirtualScreen2.OnMouseDown:=@BGRAVirtualScreen2MouseDown;
  BGRAVirtualScreen2.OnMouseMove:=@BGRAVirtualScreen2MouseMove;
  BGRAVirtualScreen2.OnMouseUp:=@BGRAVirtualScreen2MouseUp;
  BGRAVirtualScreen2.OnMouseWheel:=@BGRAVirtualScreen2MouseWheel;
  BGRAVirtualScreen2.BitmapAutoScale:=False;

  BGRAVirtualScreen3:=TBGRAVirtualScreen.Create(Self);
  BGRAVirtualScreen3.Parent:=Panel2;
  BGRAVirtualScreen3.Align:=alClient;
  BGRAVirtualScreen3.OnRedraw:=@BGRAVirtualScreen3Redraw;
  BGRAVirtualScreen3.BitmapAutoScale:=False;

  zoom:=1;
  moveTranslate:=Point(0,0);

  bmpl := TBGRALayeredBitmap.Create(Panel1.Width,Panel1.Height);
  FGCodeLayer   := TBGRABitmap.Create(bmpl.Width,bmpl.Height);
  bmpl.AddOwnedLayer(FGCodeLayer{,boLinearBlend});
  FCursorLayer  := TBGRABitmap.Create(bmpl.Width,bmpl.Height);
  bmpl.AddOwnedLayer(FCursorLayer,boXor);
  FCursorLayer.Fill(BGRA(0,0,0,255),dmSet);
end;

procedure TGCodeViewer.FormDestroy(Sender: TObject);
begin
  BGRAVirtualScreen2.Free;
  BGRAVirtualScreen3.Free;
  if Assigned(FFlattened) then FFlattened.Free;
  bmpl.Free;
  newp.Free;
end;

procedure TGCodeViewer.Panel1Resize(Sender: TObject);
begin
  FreeAndNil(FFlattened);
  bmpl.SetSize(TControl(Sender).Width,TControl(Sender).Height);
  FGCodeLayer.SetSize(TControl(Sender).Width,TControl(Sender).Height);
  FCursorLayer.SetSize(TControl(Sender).Width,TControl(Sender).Height);
  UpdateGCodeImage;
end;

procedure TGCodeViewer.buttonQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TGCodeViewer.editFileInputAcceptFileName(Sender: TObject;
  var Value: String);
var
  SS:TStringList;
begin
  SS:=TStringList.Create;
  try
    SS.LoadFromFile(Value);
    CommandOutputScreen.BeginUpdate(False);
    CommandOutputScreen.Lines.Clear;
    CommandOutputScreen.Lines.Assign(SS);
    CommandOutputScreen.EndUpdate;
    btnRenderGCodeClick(nil);
  finally
    SS.Free;
  end;
end;

function GetDouble(d: shortstring): Double;
var
  my_Settings: TFormatSettings;
begin
  {$ifdef FPC}
  my_Settings:=DefaultFormatSettings;
  {$else}
  my_Settings.Create;
  {$endif}
  my_Settings.DecimalSeparator := '.';
  Result := 0.0;
  if (Length(d)<1) then exit;
  result := StrToFloat(d,my_Settings);
end;


function GetGCodeFromString(const s:string):TtkGCodeKind;
var
  lg:string;
  i:integer;
begin
  lg:=UpperCase(s);
  if (Length(lg)=3) AND (lg[1]='G') AND (lg[2]='0') then Delete(lg,2,1);
  i:=Pos('.',lg);
  if (i>0) then lg[i]:='_';
  i:=GetEnumValueSimple(TypeInfo(TtkGCodeKind),lg);
  if (i<>-1) then
    result:=TtkGCodeKind(i)
  else
    result:=TtkGCodeKind.Unknown;
end;

procedure TGCodeViewer.btnRenderGCodeClick(Sender: TObject);
var
  linenumber,i,j,k      : integer;
  t                     : string;
  SHA                   : TSynHighlighterAttributes;
  tTK                   : TtkTokenKind;
  GCode                 : TtkGCodeKind;
  ACenterX, ACenterY    : Double;
  ARadius, ADist, ASign : Double;
  SA,SE                 : double;

  FF,FI,FJ,FK           : PDouble;
  FP,FQ,FR              : PDouble;
  DestX,DestY,DestZ     : PDouble;
  LastX,LastY,LastZ     : PDouble;

  GotXYZ                : boolean;
  GotIJK                : boolean;
  GotPQ                 : boolean;
  GotR                  : boolean;
  Q1,Q2,Q3,Q4           : boolean;
  PolarMode             : boolean;

  GCodeEnum             : TtkTokenKind;
  GCodeMotion           : TtkGCodeKind;
  GCodePlane            : TtkGCodeKind;
  GCodeDistance         : TtkGCodeKind;
  GCodeArcDistance      : TtkGCodeKind;
  GCodeFeed             : TtkGCodeKind;
  GCodeUnits            : TtkGCodeKind;
  GCodeCoordinate       : TtkGCodeKind;
  GCodeCutterComp       : TtkGCodeKind;
begin
  zoom          := 1;
  moveTranslate := Point(0,0);

  newp_boundsF:=RectF(0,0,0,0);
  newp.resetTransform;
  newp.beginPath;

  GCodeMotion:=TtkGCodeKind.G0;
  GCodeDistance:=TtkGCodeKind.G91;
  GCodeArcDistance:=TtkGCodeKind.G91_1;
  GCodePlane:=TtkGCodeKind.G17;
  GCodeFeed:=TtkGCodeKind.G94;
  GCodeUnits:=TtkGCodeKind.G21;
  GCodeCoordinate:=TtkGCodeKind.G54;
  GCodeCutterComp:=TtkGCodeKind.G40;

  PolarMode:=False;

  GCData:=Default(TGCodeDataArray);

  FF:=@GCData[tkFcode].NewValue;
  FI:=@GCData[tkIcode].NewValue;
  FJ:=@GCData[tkJcode].NewValue;
  FK:=@GCData[tkKcode].NewValue;
  FP:=@GCData[tkPcode].NewValue;
  FQ:=@GCData[tkQcode].NewValue;
  FR:=@GCData[tkRcode].NewValue;

  DestX:=@GCData[tkXcode].NewValue;
  DestY:=@GCData[tkYcode].NewValue;
  DestZ:=@GCData[tkZcode].NewValue;

  LastX:=@GCData[tkXcode].PrevValue;
  LastY:=@GCData[tkYcode].PrevValue;
  LastZ:=@GCData[tkZcode].PrevValue;

  for linenumber:=0 to Pred(CommandOutputScreen.Lines.Count) do
  begin
    GCode:=TtkGCodeKind.Unknown;
    for GCodeEnum in TtkTokenKind do GCData[GCodeEnum].ValueSet:=False;
    k:=1;
    repeat
      TSynCNCSyn(CommandOutputScreen.Highlighter).GetHighlighterAttriAtRowColEx(TPoint.Create(k,linenumber+1),t,i,j,SHA);
      if (SHA=nil) then break;
      //if Assigned(SHA) then  Memo1.Lines.Append(SHA.Name);
      GCodeEnum:=TtkTokenKind(i);
      case GCodeEnum of
        tkGcode:
          begin
            GCode:=GetGCodeFromString(t);
            Inc(k,length(t));
            if (length(t)=0) then Inc(k);
          end;
        else
          begin
            if GCodeEnum in [
              tkComment,
              tkText,
              tkReserved,
              tkNull,
              tkNumber,
              tkSpace,
              tkAbstract,
              tkNormal,
              tkKey,
              tkIdentifier,
              tkNone
              ] then
              begin
                Inc(k,length(t));
                if (length(t)=0) then Inc(k);
              end
              else
              begin
                Inc(k);
                TSynCNCSyn(CommandOutputScreen.Highlighter).GetHighlighterAttriAtRowColEx(TPoint.Create(k,linenumber+1),t,i,j,SHA);
                tTK:=TtkTokenKind(i);
                if (tTK=tkNumber) then
                begin
                  GCData[GCodeEnum].ValueSet:=True;
                  GCData[GCodeEnum].NewValue:=GetDouble(t);
                  Inc(k,length(t));
                  if (length(t)=0) then Inc(k);
                end;
              end;
          end;
      end;
    until false;

    // Set modal modes, if any
    if GCode in GCODE_MOTION then GCodeMotion:=GCode;
    if GCode in GCODE_DISTANCE then GCodeDistance:=GCode;
    if GCode in GCODE_ARCDISTANCE then GCodeArcDistance:=GCode;
    if GCode in GCODE_PLANE then GCodePlane:=GCode;
    if GCode in GCODE_FEED then GCodeFeed:=GCode;
    if GCode in GCODE_UNIT then GCodeUnits:=GCode;
    if GCode in GCODE_COORDINATE then GCodeCoordinate:=GCode;
    if GCode in GCODE_CUTTERCOMP then GCodeCutterComp:=GCode;
    if GCode=TtkGCodeKind.G16 then PolarMode:=True;
    if GCode=TtkGCodeKind.G15 then PolarMode:=False;

    if GCode=TtkGCodeKind.Unknown then
    begin
      // No gcode received.
      // Modal values valid
    end;

    for GCodeEnum in [tkXcode,tkYcode,tkZcode] do
    begin
      GotXYZ:=GCData[GCodeEnum].ValueSet;
      if GotXYZ then break;
    end;
    for GCodeEnum in [tkIcode,tkJcode,tkKcode] do
    begin
      GotIJK:=GCData[GCodeEnum].ValueSet;
      if GotIJK then break;
    end;
    for GCodeEnum in [tkPcode,tkQcode] do
    begin
      GotPQ:=GCData[GCodeEnum].ValueSet;
      if GotPQ then break;
    end;
    GotR    := ((GCData[tkRcode].ValueSet));

    // Did we receive a line with XYZ coordinates ?
    if GotXYZ then
    begin
      // Lines / moves
      if (GCodeMotion in [TtkGCodeKind.G0,TtkGCodeKind.G1]) then
      begin
        if (GCodeMotion=TtkGCodeKind.G0) then newp.moveTo(DestX^,DestY^);
        if (GCodeMotion=TtkGCodeKind.G1) then newp.lineTo(DestX^,DestY^);
        if GCData[tkZcode].ValueSet then
        begin
          newp.addColor(MapHeightToBGRA(0.5+(DestZ^/(100000)),255));
        end;
        //newp.arcDeg(DestX^,DestY^,0.1,0,360);
        //newp.moveTo(DestX^,DestY^);
      end;

      // Splines
      if (GCodeMotion in [TtkGCodeKind.G5]) then
      begin
        //  (start point): we are already standing on first point, G5 won't contain it
        //  I<pos>	 X incremental offset from start point to first control point  - IJ 1st control point, relative to (start point)
        //  J<pos>	 Y incremental offset from start point to first control point
        //  P<pos>	 X incremental offset from end point to second control point  - PQ 2nd control point, relative to XY (end point)
        //  Q<pos>	 Y incremental offset from end point to second control point
        //  X<pos>	 A coordinate on the X axis
        //  Y<pos>	 A coordinate on the Y axis  - (end point)
        if (GotPQ) then
        begin
          if (NOT GotIJK) then
          begin
            FI^:=-GCData[tkPcode].PrevValue;
            FJ^:=-GCData[tkQcode].PrevValue;
          end;
          newp.bezierCurveTo(LastX^+FI^,LastY^+FJ^,DestX^+FP^,DestY^+FQ^,DestX^,DestY^);
          newp.arcDeg(DestX^,DestY^,0.1,0,360);
          newp.moveTo(DestX^,DestY^);
        end;
      end;
    end;

    // Arcs
    if (GCodeMotion in [TtkGCodeKind.G2,TtkGCodeKind.G3]) then
    begin
      if (GotIJK OR GotR) then
      begin
        if GotIJK then
        begin
          // Simple copy
          ARadius:=SQRT(SQR(FI^)+SQR(FJ^));
          if (GCodeArcDistance=TtkGCodeKind.G91_1) then
          begin
            ARadius:=SQRT(SQR(FI^)+SQR(FJ^));
            ACenterX:=LastX^+FI^;
            ACenterY:=LastY^+FJ^;
          end
          else
          begin
            ARadius:=SQRT(SQR(DestX^-FI^)+SQR(DestY^-FJ^));
            ACenterX:=FI^;
            ACenterY:=FJ^;
          end;
        end;
        if GotR then
        begin
          ARadius:=FR^;
          //Distance between points
          ADist:=sqrt(sqr(DestX-LastX)+sqr(DestY-LastY));
          if (GCodeMotion=TtkGCodeKind.G3) then ASign:=-1 else ASign:=1;
          // Center of circle
          ACenterX:=0.5*(LastX^+DestX^)+ASign*0.5*sqrt(2*((2*sqr(ARadius))/sqr(ADist))-1)*(DestY^-LastY^);
          ACenterY:=0.5*(LastY^+DestY^)+ASign*0.5*sqrt(2*((2*sqr(ARadius))/sqr(ADist))-1)*(LastX^-DestX^);
          // Calculate FI and FJ
          FI^:=ACenterX-LastX^;
          FJ^:=ACenterY-LastY^;
        end;

        // Calculate start angle
        Q1:=((LastX^>=ACenterX) AND (LastY^>=ACenterY));
        Q2:=((LastX^<ACenterX) AND (LastY^>=ACenterY));
        Q3:=((LastX^<ACenterX) AND (LastY^<ACenterY));
        Q4:=((LastX^>=ACenterX) AND (LastY^<ACenterY));
        SA:=180*(arctan((LastY^-ACenterY)/(LastX^-ACenterX)))/Pi;
        if (Q1) then SA:=0+SA;
        if (Q2 OR Q3) then SA:=180+SA;
        if (Q4) then SA:=360+SA;

        // Calculate stop angle
        Q1:=((DestX^>=ACenterX) AND (DestY^>=ACenterY));
        Q2:=((DestX^<ACenterX) AND (DestY^>=ACenterY));
        Q3:=((DestX^<ACenterX) AND (DestY^<ACenterY));
        Q4:=((DestX^>=ACenterX) AND (DestY^<ACenterY));
        SE:=180*(arctan((DestY^-ACenterY)/(DestX^-ACenterX)))/Pi;
        if (Q1) then SE:=0+SE;
        if (Q2 OR Q3) then SE:=180+SE;
        if (Q4) then SE:=360+SE;

        if (GCodeMotion=TtkGCodeKind.G3) then
        begin
          // if counter-clockwise, SA must always be smaller than SE
          if (SA>SE) then
          begin
            SA:=360-SA;
          end;
        end
        else
        begin
          // if clockwise, SE must always be smaller than SA
          if (SE>SA) then
          begin
            SE:=SE-360;
          end;
        end;

        // Finally, draw circle
        newp.arcTo(ARadius,ARadius,0,(NOT GotR),(GCodeMotion=TtkGCodeKind.G2),DestX^,DestY^);
        newp.moveTo(DestX^, DestY^);
      end;
    end;

    // Circles
    if GotIJK then
    begin
      if (GCode in [TtkGCodeKind.G12,TtkGCodeKind.G13]) then
      begin
        //if (GCode=TtkGCodeKind.G12) then  ent:=FirstPage.AddCircularArc(LastX+I,LastY,I,0,-360,colGreen);
        //if (GCode=TtkGCodeKind.G13) then  ent:=FirstPage.AddCircularArc(LastX+I,LastY,I,0,360,colLime);
      end;
    end;


    if (GCode in [TtkGCodeKind.G15,TtkGCodeKind.G16]) then
    begin

    end;

    for GCodeEnum in TtkTokenKind do
    begin
      if GCData[GCodeEnum].ValueSet then GCData[GCodeEnum].PrevValue:=GCData[GCodeEnum].NewValue;
    end;

    // GOTO NEXT GCODE LINE
  end;

  newp.closePath;
  newp_boundsF:=newp.GetBounds(1);
  newp_boundsF.Inflate(4,4);

  // Update small gcode parser output
  BGRAVirtualScreen3.DiscardBitmap;

  // Update main gcode parser output
  UpdateGCodeImage;

  Memo1.Lines.Append('Render ready');
end;

procedure TGCodeViewer.btnTraceGCodeClick(Sender: TObject);
begin
  TraceGCode(Sender);
end;

procedure TGCodeViewer.TraceGCode(Sender: TObject);
const
  OFFSET = 0;
  RESOLUTION = 2000;
var
  ac:TBGRACustomPathCursor;
  cp:TPointF;
  cc:TBGRAPixel;
  i:integer;
  sx,sy:double;
  px,py:integer;
  md,ad: single;
  newlocalp : TBGRAPath;
  newplocal_boundsF:TRectF;
begin
  newlocalp:=newp;
  newplocal_boundsF:=newp_boundsF;

  if (Sender=btnTraceView) then
  begin
    newlocalp:=TBGRAPath.Create;
    newlocalp.translate(newplocal_boundsF.Left,newplocal_boundsF.Top);
  end;
  if newplocal_boundsF.Width=0 then exit;
  if newplocal_boundsF.Height=0 then exit;

  sx:=(Image1.Width-2*OFFSET)/newplocal_boundsF.Width;
  sy:=(Image1.Height-2*OFFSET)/newplocal_boundsF.Height;

  if sy<sx then sx:=sy;
  if sx<sy then sy:=sx;

  if (Sender=btnTraceView) then
  begin
    newlocalp.SetPoints(newc.currentPath);
  end;

  md:=(newplocal_boundsF.Width+newplocal_boundsF.Height)/RESOLUTION;
  ac:=newlocalp.CreateCursor(md);

  Image1.Picture.Clear;

  repeat
    cp:=ac.CurrentCoordinate;
    cc:=TBGRAPathCursor(ac).CurrentSegmentColor;
    if cc=BGRABlack then cc:=CSSRed;
    ad:=MapHeight(cc);
    ad:=(ad-0.5)*100000;
    px:=(Round((cp.x-newplocal_boundsF.Left)*sx)+OFFSET);
    if (Sender=btnTraceGCode) then
    begin
      py:=(Image1.Height-(round((cp.y-newplocal_boundsF.Top)*sy))-OFFSET);
    end;
    if (Sender=btnTraceView) then
    begin
      py:=Round((cp.y-newplocal_boundsF.Top)*sy)+OFFSET;
    end;
    if ((px>=0) AND (px<Image1.Width) AND (py>=0) AND (py<Image1.Height)) then
    begin
      //Image1.Canvas.DrawPixel(px,py,,FPColor($8FF*abs(round(ad)),$8FF*abs(round(ad)),0,alphaOpaque));
      Image1.Canvas.DrawPixel(px,py,FPColor(cc.red*256,cc.green*256,cc.blue*256));
      Application.ProcessMessages;
    end;
    ad:=ac.MoveForward(md,true);
    if ad=0 then break;
  until false;

  ac.Destroy;

  if (Sender=Self.btnTraceView) then
  begin
    newlocalp.Free;
  end;

  Memo1.Lines.Append('Tracing ready');
end;


procedure TGCodeViewer.BGRAVirtualScreen2Redraw(Sender: TObject;
  Bitmap: TBGRABitmap);
begin
  if FFlattened = nil then UpdateFlattenedImage(rect(0,0,bmpl.Width,bmpl.Height),false);
  Bitmap.PutImage(0,0,FFlattened,dmSet);
end;

procedure TGCodeViewer.BGRAVirtualScreen3Redraw(Sender: TObject;
  Bitmap: TBGRABitmap);
var
  newlocalc: TBGRACanvas2D;
  sx,sy:Double;
  vs:TBGRAVirtualScreen;
begin
  if (NOT Assigned(newp)) then exit;
  if newp.IsEmpty then exit;

  vs:=TBGRAVirtualScreen(Sender);

  if newp_boundsF.Width=0 then exit;
  if newp_boundsF.Height=0 then exit;

  sx:=vs.Width/newp_boundsF.Width;
  sy:=vs.Height/newp_boundsF.Height;

  newlocalc:=Bitmap.Canvas2D;

  newlocalc.resetTransform;
  newlocalc.strokeResetTransform;
  newlocalc.lineJoinLCL:= pjsBevel;
  newlocalc.beginPath;
  newlocalc.scale(sx,-sy);
  newlocalc.strokeStyle(clRed);
  if (newp_boundsF.Bottom>0) then newlocalc.translate(0,-newp_boundsF.Bottom);
  newlocalc.translate(-newp_boundsF.Left,0);
  newlocalc.addPath(newp);
  newlocalc.closePath;
  newlocalc.stroke;
end;

procedure TGCodeViewer.btnLoadBearClick(Sender: TObject);
begin
  CommandOutputScreen.BeginUpdate(False);
  CommandOutputScreen.Lines.Clear;
  if (Sender=btnLoadLetters) then CommandOutputScreen.Lines.Assign(memoLetters.Lines);
  if (Sender=btnLoadBear) then CommandOutputScreen.Lines.Assign(memoBear.Lines);
  CommandOutputScreen.EndUpdate;
  btnRenderGCodeClick(nil);
end;

procedure TGCodeViewer.BGRAVirtualScreen2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (button = mbLeft) then
  begin
    moving := true;
    moveOrigin := point(X,Y);
  end;
end;

procedure TGCodeViewer.BGRAVirtualScreen2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if moving then
  begin
    moveTranslate.X:=moveTranslate.X+(X-moveOrigin.X);
    moveTranslate.Y:=moveTranslate.Y+(Y-moveOrigin.Y);
  end;

  // First draw the new lines
  UpdateCursorImage(Point(X,Y));
  // Erase the old ones
  UpdateCursorImage(moveOrigin);

  moveOrigin := point(X,Y);

  if moving then UpdateGCodeImage;
end;

procedure TGCodeViewer.BGRAVirtualScreen2MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then moving := false;
end;

procedure TGCodeViewer.BGRAVirtualScreen2MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  b,c:TPoint;
begin
  Handled:= true;

  // This is the real world coordiate of the mouse-pointer on the gcode drawing before zoom
  c.X:=Round((moveTranslate.X-MousePos.X)/zoom);
  c.Y:=Round((moveTranslate.Y-MousePos.Y)/zoom);

  if WheelDelta>0 then
  begin
    zoom:=zoom*(1.1);
  end;
  if WheelDelta<0 then
  begin
    zoom:=zoom*(1/1.1);
  end;
  Handled:=True;

  // This is the real world coordiate of the mouse-pointer on the gcode drawing after zoom
  b.X:=Round((moveTranslate.X-MousePos.X)/zoom);
  b.Y:=Round((moveTranslate.Y-MousePos.Y)/zoom);

  // Now try to find the correct shift
  moveTranslate.X:=moveTranslate.X+Round((c.X-b.X)*(zoom));
  moveTranslate.Y:=moveTranslate.Y+Round((c.Y-b.Y)*(zoom));

  UpdateGCodeImage;
end;

procedure TGCodeViewer.UpdateFlattenedImage(ARect: TRect; AUpdateView: boolean);
begin
  if FFlattened = nil then
    FFlattened := bmpl.ComputeFlatImage
  else
  if not IsRectEmpty(ARect) then
  begin
    FFlattened.ClipRect := ARect;
    bmpl.Draw(FFlattened, 0,0, false, true);
    FFlattened.NoClip;
  end;

  if AUpdateView then
  begin
    BGRAVirtualScreen2.RedrawBitmap(ARect);
  end;
end;

procedure TGCodeViewer.UpdateGCodeImage(AUpdateView: boolean=true);
var
  sx,sy:Double;
  vs:TBGRAVirtualScreen;
begin
  if (NOT Assigned(newp)) then exit;
  if newp.IsEmpty then exit;

  vs:=BGRAVirtualScreen2;

  if newp_boundsF.Width=0 then exit;
  if newp_boundsF.Height=0 then exit;

  sx:=zoom*(vs.Width/newp_boundsF.Width);
  sy:=zoom*(vs.Height/newp_boundsF.Height);

  if sy<sx then sx:=sy;
  if sx<sy then sy:=sx;

  FGCodeLayer.Fill(BGRABlack,dmSet);

  newc:=FGCodeLayer.Canvas2D;
  newc.resetTransform;
  newc.strokeResetTransform;
  newc.lineJoinLCL:= pjsBevel;
  newc.beginPath;

  newc.translate(moveTranslate.X,moveTranslate.Y);

  newc.scale(sx,-sy);
  newc.strokeStyle(clRed);
  if (newp_boundsF.Bottom>0) then newc.translate(0,-newp_boundsF.Bottom);
  newc.translate(-newp_boundsF.Left,0);
  newc.addPath(newp);
  newc.closePath;
  newc.stroke;

  UpdateFlattenedImage(rect(0,0,bmpl.Width,bmpl.Height),AUpdateView);
end;

procedure TGCodeViewer.UpdateCursorImage(Location:TPoint;AUpdateView: boolean=true);
var
  ar: array[0..1] of TRect;
begin
  FCursorLayer.HorizLine(0,Location.Y,FCursorLayer.Width-1, BGRA(255,255,255,0), dmXor);
  ar[0]:=Rect(0,Location.Y-1,FCursorLayer.Width-1,Location.Y+1);
  UpdateFlattenedImage(ar[0],False);
  FCursorLayer.VertLine(Location.X,0,FCursorLayer.Height-1, BGRA(255,255,255,0), dmXor);
  ar[1]:=Rect(Location.X-1,0,Location.X+1,FCursorLayer.Height-1);
  UpdateFlattenedImage(ar[1],False);
  BGRAVirtualScreen2.RedrawBitmap(slice(ar,2));
end;

end.

