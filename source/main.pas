unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ExtCtrls, Types, fgl,
  SynEdit, SynEditHighlighter, SynHighlighterCNC,SynEditTypes, SynEditMarkup, SynEditMarkupBracket, SynEditMarkupBracketCNC,
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
  G28,           //Go to Predefined Position (Home all axes (X, Y, and Z))
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
  G59_1,
  G59_2,
  G59_3,
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

  GCODE_MOTION : set of TtkGCodeKind = [G0, G1, G2, G3, G5, G5_1, G5_2, G33, G38, G73, G76, G80, G81, G82, G84, G85, G86, G87, G88, G89];
  GCODE_PLANE : set of TtkGCodeKind = [G17, G18, G19];
  GCODE_DISTANCE : set of TtkGCodeKind = [G90, G91];
  GCODE_ARCDISTANCE : set of TtkGCodeKind = [G90_1,G91_1];
  GCODE_FEED : set of TtkGCodeKind = [G93, G94];
  GCODE_UNIT : set of TtkGCodeKind = [G20, G21];
  GCODE_CUTTERCOMP : set of TtkGCodeKind = [G40, G41, G42];
  //Group 8 {G43, G43.1, G49} tool length offset
  //Group 10 {G98, G99} return mode in canned cycles
  GCODE_COORDINATE : set of TtkGCodeKind = [G54, G55, G56, G57, G58, G59];
  //Group 13 {G61, G61.1, G64} path control mode
  //Group 14 {G96, G97} spindle speed mode
  //Group 15 {G07, G08} lathe diameter mode

  //MCODE
  //Group 4 {M00, M01, M02, M30, M60} stopping
  //Group 7 {M03, M04, M05} spindle turning
  //Group 8 {M07, M08, M09} coolant (special case: M07 and M08 may be active at the same time)
  //Group 9 {M48, M49} enable/disable feed and speed override controls
  //Group 10 {operator defined M100 to M199}



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
    editXPosition: TEdit;
    editFileInput: TFileNameEdit;
    editYPosition: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    memoLetters: TMemo;
    memoBear: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadBearClick(Sender: TObject);
    procedure btnRenderGCodeClick(Sender: TObject);
    procedure btnTraceGCodeClick(Sender: TObject);
    procedure buttonQuitClick(Sender: TObject);
    procedure editFileInputAcceptFileName(Sender: TObject; var Value: String);
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

    realzoomx,realzoomy,realposx,realposy:double;

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

    procedure RenderGCode;
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

function Compare(const ACode1,ACode2:TtkGCodeKind):Integer;
var
  GCodeEnumerator : TtkGCodeKind;
  result1,result2:integer;
  presult:pinteger;

begin
  result1:=0;
  result2:=0;

  for GCodeEnumerator in [ACode1,ACode2] do
  begin
     if GCodeEnumerator=ACode1 then presult:=@result1;
     if GCodeEnumerator=ACode2 then presult:=@result2;

     if GCodeEnumerator in [G93, G94] then presult^:=1;
     if GCodeEnumerator in [G17, G18, G19] then presult^:=2;
     if GCodeEnumerator in [G20, G21] then presult^:=3;
     if GCodeEnumerator in [G40, G41, G42] then presult^:=4;
     if GCodeEnumerator in [G43, G49] then presult^:=5;
     if GCodeEnumerator in [G54, G55, G56, G57, G58, G59, G59_1, G59_2, G59_3] then presult^:=6;
     if GCodeEnumerator in [G61, G61_1, G64] then presult^:=7;
     if GCodeEnumerator in [G90, G91] then presult^:=8;
     if GCodeEnumerator in [G98, G99] then presult^:=9;
     if GCodeEnumerator in [G28, G30,G10,G52, G92, G92_1, G92_2, G94] then presult^:=10;
     if GCodeEnumerator in [G0,G1,G2,G3, G33, G38, G73, G76,   G81,G82,G83,G84,G85,G86,G87,G88,G89] then presult^:=11;
  end;

  result:=result1-result2;

  (*
  O-word commands (optionally followed by a comment but no other words allowed on the same line)
  Comment (including message)
  Set feed rate mode (G93, G94).
  Set feed rate (F).
  Set spindle speed (S).
  Select tool (T).
  HAL pin I/O (M62-M68).
  Change tool (M6) and Set Tool Number (M61).
  Spindle on or off (M3, M4, M5).
  Save State (M70, M73), Restore State (M72), Invalidate State (M71).
  Coolant on or off (M7, M8, M9).
  Enable or disable overrides (M48, M49,M50,M51,M52,M53).
  User-defined Commands (M100-M199).
  Dwell (G4).
  Set active plane (G17, G18, G19).
  Set length units (G20, G21).
  Cutter radius compensation on or off (G40, G41, G42)
  Cutter length compensation on or off (G43, G49)
  Coordinate system selection (G54, G55, G56, G57, G58, G59, G59.1, G59.2, G59.3).
  Set path control mode (G61, G61.1, G64)
  Set distance mode (G90, G91).
  Set retract mode (G98, G99).
  Go to reference location (G28, G30) or change coordinate system data (G10) or set axis offsets (G52, G92, G92.1, G92.2, G94).
  Perform motion (G0 to G3, G33, G38.n, G73, G76, G80 to G89), as modified (possibly) by G53.
  Stop (M0, M1, M2, M30, M60).
  *)
end;

procedure TGCodeViewer.FormCreate(Sender: TObject);
var
  tmp:TSynEditMarkupBracket;
  new:TSynEditMarkupBracketCNC;
  mc:TSynEditMarkup;
begin
  CNC := TSynCNCSyn.Create(CommandOutputScreen);
  CommandOutputScreen.Highlighter := CNC;

  // Remove standard bracket markup
  mc:=TSynEditMarkupBracket(CommandOutputScreen.MarkupByClass[TSynEditMarkupBracket]);
  CommandOutputScreen.MarkupManager.RemoveMarkUp(mc);
  mc.Free;

  // Add CNC bracket markup
  new:=TSynEditMarkupBracketCNC.Create(CommandOutputScreen);
  CommandOutputScreen.MarkupManager.AddMarkUp(new);
  CommandOutputScreen.Options:=CommandOutputScreen.Options+[eoBracketHighlight];
  TSynEditMarkupBracket(CommandOutputScreen.MarkupByClass[TSynEditMarkupBracketCNC]).MarkupInfo.Background:=clBlue;
  TSynEditMarkupBracket(CommandOutputScreen.MarkupByClass[TSynEditMarkupBracketCNC]).MarkupInfo.BackPriority:=99999+1;

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
begin
  RenderGCode;

  // Update small gcode parser output
  BGRAVirtualScreen3.DiscardBitmap;

  // Update main gcode parser output
  UpdateGCodeImage;

  Memo1.Lines.Append('Render ready');
end;

procedure TGCodeViewer.RenderGCode;
const
  AXISNUMBERS : set of TtkTokenKind = [tkXcode, tkYcode, tkZcode, tkAcode, tkBcode, tkCcode, tkUcode, tkVcode, tkWcode];
type
  TGCodeList = specialize TFPGList<TtkGCodeKind>;
  TTokenList = specialize TFPGList<TtkTokenKind>;
  TParameters = specialize TFPGMap<shortstring,double>;
var
  GCodeList             : TGCodeList;
  TokenList             : TTokenList;
  ParameterList         : TParameters;

  j                     : integer;
  linenumber,lineindex  : integer;
  tokenindex            : integer;
  s,tokentext           : string;
  ParamName             : string;
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

  ParamData             : boolean;

  GotAxis               : boolean;
  GotIJK                : boolean;
  GotPQ                 : boolean;
  GotR                  : boolean;
  Q1,Q2,Q3,Q4           : boolean;
  PolarMode             : boolean;
  OffsetMode            : boolean;

  TokenEnumerator       : TtkTokenKind;
  GCodeEnumerator       : TtkGCodeKind;

  GCodeMotion           : TtkGCodeKind;
  GCodePlane            : TtkGCodeKind;
  GCodeDistance         : TtkGCodeKind;
  GCodeArcDistance      : TtkGCodeKind;
  GCodeFeed             : TtkGCodeKind;
  GCodeUnits            : TtkGCodeKind;
  GCodeCoordinate       : TtkGCodeKind;
  GCodeCutterComp       : TtkGCodeKind;
begin
  GCodeList:=TGCodeList.Create;
  ParameterList:=TParameters.Create;

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
  OffsetMode:=False;

  GCData:=Default(TGCodeDataArray);

  GCode:=TtkGCodeKind.Unknown;

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
    for TokenEnumerator in TtkTokenKind do GCData[TokenEnumerator].ValueSet:=False;
    GCodeList.Clear;
    SHA:=nil;
    tokenindex:=0;
    tokentext:='';
    lineindex:=1;
    repeat
      if SHA<>nil then
      begin
        TokenEnumerator:=TtkTokenKind(tokenindex);
        case TokenEnumerator of
          tkGcode:
            begin
              GCode:=GetGCodeFromString(tokentext);
              // Store received line gcodes
              GCodeList.Add(GCode);
              Inc(lineindex,length(tokentext));
              if (length(tokentext)=0) then Inc(lineindex);
            end;
          tkNcode:
            begin
              Inc(lineindex,length(tokentext));
              if (length(tokentext)=0) then Inc(lineindex);
            end;
          tkParam:
            begin
              // This should only happen if we have new data !!
              ParamData:=false;
              Inc(lineindex,length(tokentext));
              if (length(tokentext)=0) then Inc(lineindex);
              ParamName:=tokentext;
              if (ParameterList.IndexOf(ParamName)=-1) then
              begin
                // Key not yet defined.
                // So, get its value !
                repeat
                  TSynCNCSyn(CommandOutputScreen.Highlighter).GetHighlighterAttriAtRowColEx(TPoint.Create(lineindex,linenumber+1),tokentext,tokenindex,j,SHA);
                  if (SHA=nil) then break;
                  tTK:=TtkTokenKind(tokenindex);
                  if tTK in [tkSpace,tkEqual] then
                  begin
                    if (tTK=tkEqual) then ParamData:=True;
                    Inc(lineindex,length(tokentext));
                    if (length(tokentext)=0) then Inc(lineindex);
                  end else break;
                until false;
                // We have skipped all spaces leading and trailing the equal sign
                // Now get the parameter datavalue itself
                if ParamData then
                begin
                  s:='';
                  repeat
                    tTK:=TtkTokenKind(tokenindex);
                    if tTK in [tkSpace,tkNumber] then
                    begin
                      if (tTK=tkNumber) then s:=s+tokentext;
                      Inc(lineindex,length(tokentext));
                      if (length(tokentext)=0) then Inc(lineindex);
                    end else break;
                    TSynCNCSyn(CommandOutputScreen.Highlighter).GetHighlighterAttriAtRowColEx(TPoint.Create(lineindex,linenumber+1),tokentext,tokenindex,j,SHA);
                    if (SHA=nil) then break;
                  until false;
                  if (Length(s)>0) then
                  begin
                    ParameterList.Add(ParamName,GetDouble(s));
                  end;
                end
                else
                begin
                  // We should newer get here
                  raise EArgumentException.Create ('Got parameter definition ('+ParamName+'), but no value defined !');
                end;
                if (SHA=nil) then break else continue;
              end;
            end;
          else
            begin
              if TokenEnumerator in [
                tkComment,
                tkText,
                tkReserved,
                tkNull,
                tkNumber,
                tkSpace,
                tkAbstract,
                tkNormal,
                tkFunction,
                tkIdentifier,
                tkNcode,
                tkNone
                ] then
                begin
                  Inc(lineindex,length(tokentext));
                  if (length(tokentext)=0) then Inc(lineindex);
                end
                else
                begin
                  Inc(lineindex);
                  s:='';
                  ParamData:=false;
                  repeat
                    TSynCNCSyn(CommandOutputScreen.Highlighter).GetHighlighterAttriAtRowColEx(TPoint.Create(lineindex,linenumber+1),tokentext,tokenindex,j,SHA);
                    if (SHA=nil) then break;
                    tTK:=TtkTokenKind(tokenindex);
                    if tTK in [tkSpace,tkNumber,tkParam] then
                    begin
                      if (tTK=tkParam) then ParamData:=True;
                      if (tTK<>tkSpace) then s:=s+tokentext;
                      Inc(lineindex,length(tokentext));
                      if (length(tokentext)=0) then Inc(lineindex);
                    end else break;
                  until false;
                  if (Length(s)>0) then
                  begin
                    // We got data !!!
                    tTK:=TokenEnumerator;
                    // Tokens U,V and W are same as Tokes A,B and C
                    if tTK=tkUcode then tTK:=tkAcode;
                    if tTK=tkVcode then tTK:=tkBcode;
                    if tTK=tkWcode then tTK:=tkCcode;

                    GCData[tTK].ValueSet:=True;

                    if ParamData then
                    begin
                      // We got a ParamName !!
                      ParamName:=s;
                      GCData[tTK].ValueSet:=True;
                      if (ParameterList.IndexOf(ParamName)=-1) then
                      begin
                        GCData[tTK].NewValue:=0;
                        //raise EArgumentException.Create('Got parameter ('+ParamName+'), but no value defined !');
                      end
                      else
                      begin
                        GCData[tTK].NewValue:=ParameterList.KeyData[ParamName];
                      end;
                     end
                    else
                    begin
                      // We got normal number data
                      GCData[tTK].ValueSet:=True;
                      GCData[tTK].NewValue:=GetDouble(s);
                    end;
                  end;
                  if (SHA=nil) then break else continue;
                end;
            end;
        end;
      end;
      TSynCNCSyn(CommandOutputScreen.Highlighter).GetHighlighterAttriAtRowColEx(TPoint.Create(lineindex,linenumber+1),tokentext,tokenindex,j,SHA);
      if (SHA=nil) then break;
    until false;


    // Process received GCodes
    if (GCodeList.Count>0) then
    begin
      // Sort the gcodes according to their prescribed priority
      if (GCodeList.Count>1) then GCodeList.Sort(@Compare);
      for GCodeEnumerator in GCodeList do
      begin
        // Set modal modes, if any
        if GCodeEnumerator in GCODE_MOTION then GCodeMotion:=GCode;
        if GCodeEnumerator in GCODE_DISTANCE then GCodeDistance:=GCode;
        if GCodeEnumerator in GCODE_ARCDISTANCE then GCodeArcDistance:=GCode;
        if GCodeEnumerator in GCODE_PLANE then GCodePlane:=GCode;
        if GCodeEnumerator in GCODE_FEED then GCodeFeed:=GCode;
        if GCodeEnumerator in GCODE_UNIT then GCodeUnits:=GCode;
        if GCodeEnumerator in GCODE_COORDINATE then GCodeCoordinate:=GCode;
        if GCodeEnumerator in GCODE_CUTTERCOMP then GCodeCutterComp:=GCode;
        if GCodeEnumerator=TtkGCodeKind.G16 then PolarMode:=True;
        if GCodeEnumerator=TtkGCodeKind.G15 then PolarMode:=False;
        if GCodeEnumerator=TtkGCodeKind.G92 then OffsetMode:=True;
        if GCodeEnumerator=TtkGCodeKind.G92_1 then OffsetMode:=False;
      end;
    end;



    for TokenEnumerator in AXISNUMBERS do
    begin
      GotAxis:=GCData[TokenEnumerator].ValueSet;
      if GotAxis then break;
    end;
    for TokenEnumerator in [tkIcode,tkJcode,tkKcode] do
    begin
      GotIJK:=GCData[TokenEnumerator].ValueSet;
      if GotIJK then break;
    end;
    for TokenEnumerator in [tkPcode,tkQcode] do
    begin
      GotPQ:=GCData[TokenEnumerator].ValueSet;
      if GotPQ then break;
    end;
    GotR :=((GCData[tkRcode].ValueSet));

    if (GCodeMotion=TtkGCodeKind.G91) then
    begin
      for TokenEnumerator in AXISNUMBERS do
      begin
        // If we got a value, add it to its previous value: we are in relative mode
        if GCData[TokenEnumerator].ValueSet then
        begin
          GCData[TokenEnumerator].NewValue:=GCData[TokenEnumerator].PrevValue+GCData[TokenEnumerator].NewValue;
        end;
      end;
    end;


    if GCodePlane=TtkGCodeKind.G18 then
    begin
      // We are in the XZ plane
      // Force it into the XY plane
      if GCData[tkZcode].ValueSet then
      begin
        GCData[tkYcode].NewValue:=GCData[tkZcode].NewValue;
        GCData[tkYcode].ValueSet:=True;
        GCData[tkZcode].NewValue:=GCData[tkZcode].PrevValue;
        GCData[tkZcode].ValueSet:=False;
      end;

      if GCData[tkKcode].ValueSet then
      begin
        GCData[tkJcode].NewValue:=GCData[tkKcode].NewValue;
        GCData[tkJcode].ValueSet:=True;
        GCData[tkKcode].NewValue:=GCData[tkKcode].PrevValue;
        GCData[tkKcode].ValueSet:=False;
      end;

    end;

    // Did we receive a line with axis coordinates ?
    if GotAxis then
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
          //newp.arcDeg(DestX^,DestY^,0.1,0,360);
          //newp.moveTo(DestX^,DestY^);
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

    // All done
    // Process the data for the next line of GCode

    for TokenEnumerator in TtkTokenKind do
    begin
      // If we got a value, store it for later use
      if GCData[TokenEnumerator].ValueSet then GCData[TokenEnumerator].PrevValue:=GCData[TokenEnumerator].NewValue;
    end;

    for GCodeEnumerator in TtkGCodeKind do
    begin
      // Reset GCode if in non-modal group
      if GCodeEnumerator in GCODE_NONMODAL then GCode:=TtkGCodeKind.Unknown;
    end;


    // GOTO NEXT GCODE LINE
  end;

  newp.closePath;
  newp_boundsF:=newp.GetBounds(1);
  newp_boundsF.Inflate(4,4);

  ParameterList.Free;
  GCodeList.Free;
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
  //btnRenderGCodeClick(nil);
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
  if realzoomx=0 then realzoomx:=1;
  if realzoomy=0 then realzoomy:=1;

  editXPosition.Text:=FloattoStr(((X-realposx)/realzoomx));
  editYPosition.Text:=FloattoStr(((Y-realposy)/realzoomy));

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

  realzoomx:=sx;
  realzoomy:=-sy;
  realposx:=moveTranslate.X;
  realposy:=moveTranslate.Y;
  if (newp_boundsF.Bottom>0) then realposy:=realposy-(realzoomy*newp_boundsF.Bottom);
  realposx:=realposx-realzoomx*newp_boundsF.Left;
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

