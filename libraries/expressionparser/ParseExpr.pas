unit ParseExpr;
{--------------------------------------------------------------
| TExpressionParser
| a flexible and fast expression parser for logical and
| mathematical functions
| Author: Egbert van Nes  (Egbert.vanNes@wur.nl)
| With contributions of: John Bultena, Ralf Junker, Arnulf Sortland
| and Xavier Mor-Mur
| Status: Freeware with source
| Version: 1.2
| Date: Sept 2002
| Homepage: http://www.dow.wau.nl/aew/parseexpr.html
|
| The fast evaluation algorithm ('pseudo-compiler' generating a linked list
| that evaluates fast) is based upon TParser - an extremely fast component
| for parsing and evaluating mathematical expressions
|('pseudo-compiled' code is only 40-80% slower than compiled Delphi code).
|
| see also: http://www.datalog.ro/delphi/parser.html
|   (Renate Schaaf (schaaf@math.usu.edu), 1993
|    Alin Flaider (aflaidar@datalog.ro), 1996
|    Version 9-10: Stefan Hoffmeister, 1996-1997)
|
| I used this valuable free parser for some years but needed to add logical
| operands, which was more difficult for me than rewriting the parser.
|
| TExpressionParser is approximately equally fast in evaluating
| expressions as TParser, but the compiling is made object oriented,
| and programmed recursively, requiring much less code and making
| it easier to customize the parser. Furthermore, there are several operands added:
|   comparison: > < <> = <= >= (work also on strings)
|   logical: and or xor not
|   factorial: !
|   percentage: %
|   assign to variables: :=
|   user defined functions can have maximal maxArg (=4) parameters
|   set MaxArg (in unit ParseClass) to a higher value if needed.
|
| The required format of the expression is Pascal style with
| the following additional operands:
|    - factorial (x!)
|    - power (x^y)
|    - pecentage (x%)
|
| Implicit multiplying is not supported: e.g. (X+1)(24-3) generates
| a syntax error and should be replaced by (x+1)*(24-3)
|
| Logical functions evaluate in 0 if False and 1 if True
| The AsString property returns True/False if the expression is logical.
|
| The comparison functions (< <> > etc.) work also with string constants ('string') and string
| variables and are not case sensitive then.
|
| The precedence of the operands is little different from Pascal (Delphi), giving
| a lower precedence to logical operands, as these only act on Booleans
| (and not on integers like in Pascal)
|
|  1 (highest): ! -x +x %
|  2: ^
|  3: * / div mod
|  4: + -
|  5: > >= < <= <> =
|  6: not
|  7: or and xor
|  8: (lowest): :=
|
| This precedence order is easily customizable by overriding/changing
| FillExpressList (the precedence order is defined there)
|
| You can use user-defined variables in the expressions and also assign to
| variables using the := operand
|
| The use of this object is very simple, therefore it doesn't seem necessary
| to make a non-visual component of it.
|
| NEW IN VERSION 1.1:
| Optimization, increasing the efficiency for evaluating an expression many times
| (with a variable in the expression).
| The 'compiler' then removes constant expressions and replaces
| these with the evaluated result.
| e.g.  4*4*x becomes 16*x
|       ln(5)+3*x becomes 1.609437912+3*x
| limitation:
|       4*x+3+3+5 evaluates as 4*x+3+3+5  (due to precedence rules)
| whereas:
|       4*x+(3+3+5) becomes 4*x+11 (use brackets to be sure that constant
|       expressions are removed by the compiler)
|  If optimization is possible, the code is often faster than compiled
|  Delphi code.
|
|  Hexadecimal notation supported: $FF is converted to 255
|  the Hexadecimals characted ($) is adjustable by setting the HexChar
|  property
|
|  The variable DecimalSeparator (SysUtils) now determines the
|  decimal separator (propery DecimSeparator). If the decimal separator
|  is a comma then the function argument separator is a semicolon ';'
|
|  'in' operator for strings added (John Bultena):
|     'a' in 'dasad,sdsd,a,sds' evaluates True
|     's' in 'dasad,sdsd,a,sds' evaluates False
|
|  NEW IN VERSION 1.2:
|  More flexible string functions (still only from string-> double)
|
|  Possibility to return NaN (not a number = 0/0)
|  instead of math exceptions (see: NAN directive)
|  using this option makes the evaluator somewhat slower
|
|---------------------------------------------------------------}

{$mode Delphi}{$H+}

interface
{.$DEFINE NAN}
{use this directive to suppress math exceptions,
instead NAN is returned.
Note that using this directive is less efficient}

uses
  SysUtils, OObjects, Classes, ParseClass;

type
  TCustomExpressionParser = class
  private
    FHexChar: Char;
    FDecimSeparator: Char; // default SysUtils.DecimalSeparator
    FArgSeparator: Char; // default SysUtils.ListSeparator
    FOptimize: Boolean;
    ConstantsList: TOCollection;
    LastRec: PExpressionRec;
    CurrentRec: PExpressionRec;
    function ParseString(AnExpression: string): TExprCollection;
    function MakeTree(var Expr: TExprCollection): PExpressionRec;
    function MakeRec: PExpressionRec;
    function MakeLinkedList(ExprRec: PExpressionRec): PDouble;
    function CompileExpression(AnExpression: string): Boolean;
    function isBoolean: Boolean;
    procedure Check(AnExprList: TExprCollection);
    function CheckArguments(ExprRec: PExpressionRec): Boolean;
    procedure DisposeTree(ExprRec: PExpressionRec);
    function EvaluateDisposeTree(ExprRec: PExpressionRec; var isBool: Boolean):
      Double;
    function EvaluateList(ARec: PExpressionRec): Double;
    function RemoveConstants(ExprRec: PExpressionRec): PExpressionRec;
    function ResultCanVary(ExprRec: PExpressionRec): Boolean;
    procedure DisposeList(ARec: PExpressionRec);
    procedure SetArgSeparator(const Value: Char);
    procedure SetDecimSeparator(const Value: Char);
  protected
    WordsList: TSortedCollection;
    procedure ReplaceExprWord(OldExprWord, NewExprWord: TExprWord); virtual;
    procedure FillExpressList; virtual; abstract;
    function CurrentExpression: string; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddReplaceExprWord(AExprWord: TExprWord);
    procedure DefineVariable(AVarName: string; AValue: PDouble);
    procedure DefineStringVariable(AVarName: string; AValue: PString);
    procedure DefineFunction(AFunctName, ADescription: string; AFuncAddress:
      TDoubleFunc; NArguments: Integer);
    procedure DefineStringFunction(AFunctName, ADescription: string;
      AFuncAddress: TStringFunc);
    procedure ReplaceFunction(OldName: string; AFunction: TObject);
    function Evaluate(AnExpression: string): Double;
    function EvaluateCurrent: Double; //fastest
    function AddExpression(AnExpression: string): Integer; virtual;
    procedure ClearExpressions; virtual;
    procedure GetGeneratedVars(AList: TList);
    procedure GetFunctionNames(AList: TStrings);
    function GetFunctionDescription(AFunction: string): string;
    property HexChar: Char read FHexChar write FHexChar;
    property ArgSeparator: Char read FArgSeparator write SetArgSeparator;
    property DecimSeparator: Char read FDecimSeparator write SetDecimSeparator;
    property Optimize: Boolean read FOptimize write FOptimize;
    //if optimize is selected, constant expressions are tried to remove
    //such as: 4*4*x is evaluated as 16*x and exp(1)-4*x is repaced by 2.17 -4*x
  end;

  TExpressionParser = class(TCustomExpressionParser)
  private
    Expressions: TStringList;
    FCurrentIndex: Integer;
    function GetResults(AIndex: Integer): Double;
    function GetAsString(AIndex: Integer): string;
    function GetAsBoolean(AIndex: Integer): Boolean;
    function GetExprSize(AIndex: Integer): Integer;
    function GetAsHexadecimal(AIndex: Integer): string;
    function GetExpression(AIndex: Integer): string;
  protected
    procedure ReplaceExprWord(OldExprWord, NewExprWord: TExprWord); override;
    procedure FillExpressList; override;
    function CurrentExpression: string; override;
  public
    constructor Create;
    destructor Destroy; override;
    function AddExpression(AnExpression: string): Integer;  override;
    procedure ClearExpressions; override;
    property ExpressionSize[AIndex: Integer]: Integer read GetExprSize;
    property Expression[AIndex: Integer]: string read GetExpression;
    property AsFloat[AIndex: Integer]: Double read GetResults;
    property AsString[AIndex: Integer]: string read GetAsString;
    property AsBoolean[AIndex: Integer]: Boolean read GetAsBoolean;
    property AsHexadecimal[AIndex: Integer]: string read GetAsHexadecimal;
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
  end;

  {------------------------------------------------------------------
  Example of creating a user-defined Parser,
  here are Pascal operators replaced by C++ style,
  note that sometimes the ParseString function needs to be changed,
  if you define new operators (characters).
  Also some special checks do not work: like 'not not x' should be
  replaced by 'x', but this does not work with !!x (c style)
  --------------------------------------------------------------------}
  TCStyleParser = class(TExpressionParser)
    FCStyle: Boolean;
  private
    procedure SetCStyle(const Value: Boolean);
  protected
    procedure FillExpressList; override;
  public
    property CStyle: Boolean read FCStyle write SetCStyle;
  end;

implementation

uses
  Math;

const
  errorPrefix='Error in math expression: ';

procedure _Power(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Args[0]^ < 0 then
      Res := Nan
    else
{$ENDIF}
      Res := Power(Args[0]^, Args[1]^);
end;

function _Pos(str1,str2:string):double;
begin
  result:=pos(str1,str2);
end;

procedure _IntPower(Param: PExpressionRec);
begin
  with Param^ do
    Res := IntPower(Args[0]^, Round(Args[1]^));
end;

procedure _ArcCos(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcCos(Args[0]^);
end;

procedure _ArcSin(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcSin(Args[0]^);
end;

procedure _ArcSinh(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcSinh(Args[0]^);
end;

procedure _ArcCosh(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcCosh(Args[0]^);
end;

procedure _ArcTanh(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcTanh(Args[0]^);
end;

procedure _ArcTan2(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcTan2(Args[0]^, Args[1]^);
end;

procedure _arctan(Param: PExpressionRec);
begin
  with Param^ do
    Res := ArcTan(Args[0]^);
end;

procedure _Cosh(Param: PExpressionRec);
begin
  with Param^ do
    Res := Cosh(Args[0]^);
end;

procedure _tanh(Param: PExpressionRec);
begin
  with Param^ do
    Res := Tanh(Args[0]^);
end;

procedure _Sinh(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sinh(Args[0]^);
end;

procedure _DegToRad(Param: PExpressionRec);
begin
  with Param^ do
    Res := DegToRad(Args[0]^);
end;

procedure _RadToDeg(Param: PExpressionRec);
begin
  with Param^ do
    Res := RadToDeg(Args[0]^);
end;

procedure _ln(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Args[0]^ < 0 then
      Res := Nan
    else
{$ENDIF}
      Res := Ln(Args[0]^);
end;

procedure _log10(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Args[0]^ < 0 then
      Res := Nan
    else
{$ENDIF}
      Res := Log10(Args[0]^);
end;

procedure _logN(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Args[0]^ < 0 then
      Res := Nan
    else
{$ENDIF}
      Res := LogN(Args[0]^, Args[1]^);
end;

procedure _negate(Param: PExpressionRec);
begin
  with Param^ do
    Res := -Args[0]^;
end;

procedure _plus(Param: PExpressionRec);
begin
  with Param^ do
    Res := +Args[0]^;
end;

procedure _exp(Param: PExpressionRec);
begin
  with Param^ do
    Res := Exp(Args[0]^);
end;

procedure _sin(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sin(Args[0]^);
end;

procedure _Cos(Param: PExpressionRec);
begin
  with Param^ do
    Res := Cos(Args[0]^);
end;

procedure _tan(Param: PExpressionRec);
begin
  with Param^ do
    Res := Tan(Args[0]^);
end;

procedure _Add(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ + Args[1]^;
end;

procedure _Assign(Param: PExpressionRec);
begin
  with Param^ do
  begin
    Res := Args[1]^;
    Args[0]^ := Args[1]^;
  end;
end;

procedure _mult(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ * Args[1]^;
end;

procedure _minus(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ - Args[1]^;
end;

procedure _realDivide(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Abs(Args[1]^) < 1E-30 then
      Res := Nan
    else
{$ENDIF}
      Res := Args[0]^ / Args[1]^;
end;

procedure _Div(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Round(Args[1]^) = 0 then
      Res := Nan
    else
{$ENDIF}
      Res := Round(Args[0]^) div Round(Args[1]^);
end;

procedure _mod(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Round(Args[1]^) = 0 then
      Res := Nan
    else
{$ENDIF}
      Res := Round(Args[0]^) mod Round(Args[1]^);
end;

//procedure _pi(Param: PExpressionRec);
//begin
//  with Param^ do
//    Res := Pi;
//end;

procedure _random(Param: PExpressionRec);
begin
  with Param^ do
    Res := Random;
end;

procedure _randG(Param: PExpressionRec);
begin
  with Param^ do
    Res := RandG(Args[0]^, Args[1]^);
end;

procedure _gt(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ > Args[1]^);
end;

procedure _ge(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ + 1E-30 >= Args[1]^);
end;

procedure _lt(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ < Args[1]^);
end;

procedure _eq(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Abs(Args[0]^ - Args[1]^) < 1E-30);
end;

procedure _ne(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Abs(Args[0]^ - Args[1]^) > 1E-30);
end;

procedure _le(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(Args[0]^ <= Args[1]^ + 1E-30);
end;

procedure _if(Param: PExpressionRec);
begin
  with Param^ do
    if Boolean(Round(Args[0]^)) then
      Res := Args[1]^
    else
      Res := Args[2]^;
end;

procedure _And(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) and Round(Args[1]^);
end;

procedure _or(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) or Round(Args[1]^);
end;

procedure _not(Param: PExpressionRec);
var
  b: Integer;
begin
  with Param^ do
  begin
    b := Round(Args[0]^);
    Res := Byte(not Boolean(b));
  end;
end;

procedure _xor(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^) xor Round(Args[1]^);
end;

procedure _round(Param: PExpressionRec);
begin
  with Param^ do
    Res := Round(Args[0]^);
end;

procedure _trunc(Param: PExpressionRec);
begin
  with Param^ do
    Res := Trunc(Args[0]^);
end;

procedure _sqrt(Param: PExpressionRec);
begin
  with Param^ do
{$IFDEF NAN}
    if Args[0]^ < 0 then
      Res := Nan
    else
{$ENDIF}Res := Sqrt(Args[0]^);
end;

procedure _Percentage(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^ * 0.01;
end;

procedure _factorial(Param: PExpressionRec);
  function Factorial(X: Extended): Extended;
  begin
    if X <= 1.1 then
      Result := 1
    else
      Result := X * Factorial(X - 1);
  end;
begin
  with Param^ do
    Res := Factorial(Round(Args[0]^));
end;

procedure _sqr(Param: PExpressionRec);
begin
  with Param^ do
    Res := Sqr(Args[0]^);
end;

procedure _Abs(Param: PExpressionRec);
begin
  with Param^ do
    Res := Abs(Args[0]^);
end;

procedure _max(Param: PExpressionRec);
begin
  with Param^ do
    if Args[0]^ < Args[1]^ then
      Res := Args[1]^
    else
      Res := Args[0]^
end;

procedure _min(Param: PExpressionRec);
begin
  with Param^ do
    if Args[0]^ > Args[1]^ then
      Res := Args[1]^
    else
      Res := Args[0]^
end;

procedure _Add1(Param: PExpressionRec);
begin
  with Param^ do
  begin
    Args[0]^ := Args[0]^ + 1;
    Res := Args[0]^;
  end;
end;

procedure _minus1(Param: PExpressionRec);
begin
  with Param^ do
  begin
    Args[0]^ := Args[0]^ - 1;
    Res := Args[0]^;
  end;
end;

procedure _isNaN(Param: PExpressionRec);
begin
  with Param^ do
    Res := Byte(isNan(Args[0]^));
end;

{ TCustomExpressionParser }

function TCustomExpressionParser.CompileExpression(AnExpression: string):
  Boolean;
var
  ExpColl: TExprCollection;
  ExprTree: PExpressionRec;
begin
  ExprTree := nil;
  ExpColl := nil;
  try
    //    FCurrentExpression := anExpression;
    ExpColl := ParseString(LowerCase(AnExpression));
    Check(ExpColl);
    ExprTree := MakeTree(ExpColl);
    CurrentRec := nil;
    if CheckArguments(ExprTree) then
    begin
      if Optimize then
      try
        ExprTree := RemoveConstants(ExprTree);
      except
        on EMathError do
        begin
          ExprTree := nil;
          raise;
        end;
      end;
      // all constant expressions are evaluated and replaced by variables
      if ExprTree^.ExprWord.isVariable then
        CurrentRec := ExprTree
      else
        MakeLinkedList(ExprTree);
    end
    else
      raise
        EParserException.Create(errorprefix+'Syntax error: function or operand has too few arguments');
  except
    ExpColl.Free;
    DisposeTree(ExprTree);
    raise;
  end;
  Result := True;
end;

constructor TCustomExpressionParser.Create;
begin
  FDecimSeparator := SysUtils.DecimalSeparator;
  FArgSeparator := SysUtils.ListSeparator;
  HexChar := '$';
  WordsList := TExpressList.Create(30);
  ConstantsList := TOCollection.Create(10);
  Optimize := True;
  FillExpressList;
end;

destructor TCustomExpressionParser.Destroy;
begin
  inherited;
  WordsList.Free;
  ConstantsList.Free;
  ClearExpressions;
end;

function TCustomExpressionParser.CheckArguments(ExprRec: PExpressionRec):
  Boolean;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    Result := True;
    for I := 0 to ExprWord.NFunctionArg - 1 do
      if Args[I] = nil then
      begin
        Result := False;
        Exit;
      end
      else
      begin
        Result := CheckArguments(ArgList[I]);
        if not Result then
          Exit;
      end;
  end;
end;

function TCustomExpressionParser.ResultCanVary(ExprRec: PExpressionRec):
  Boolean;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    Result := ExprWord.CanVary;
    if not Result then
      for I := 0 to ExprWord.NFunctionArg - 1 do
        if ResultCanVary(ArgList[I]) then
        begin
          Result := True;
          Exit;
        end
  end;
end;

function TCustomExpressionParser.RemoveConstants(ExprRec: PExpressionRec):
  PExpressionRec;
var
  I: Integer;
  isBool: Boolean;
  D: Double;
begin
  Result := ExprRec;
  with ExprRec^ do
  begin
    if not ResultCanVary(ExprRec) then
    begin
      if not ExprWord.isVariable then
      begin
        D := EvaluateDisposeTree(ExprRec, isBool);
        Result := MakeRec;
        if isBool then
          Result^.ExprWord := TBooleanConstant.CreateAsDouble('', D)
        else
          Result^.ExprWord := TDoubleConstant.CreateAsDouble('', D);
        //TDoubleConstant(Result.ExprWord).Value := D;
        Result^.Oper := Result^.ExprWord.DoubleFunc;
        Result^.Args[0] := Result^.ExprWord.AsPointer;
        ConstantsList.Add(Result^.ExprWord);
      end;
    end
    else
      for I := 0 to ExprWord.NFunctionArg - 1 do
        ArgList[I] := RemoveConstants(ArgList[I]);
  end;
end;

procedure TCustomExpressionParser.DisposeTree(ExprRec: PExpressionRec);
var
  I: Integer;
begin
  if ExprRec <> nil then
    with ExprRec^ do
    begin
      if ExprWord <> nil then
        for I := 0 to ExprWord.NFunctionArg - 1 do
          DisposeTree(ArgList[I]);
      Dispose(ExprRec);
    end;
end;

function TCustomExpressionParser.EvaluateDisposeTree(ExprRec: PExpressionRec; var
  isBool: Boolean): Double;
begin
  if ExprRec^.ExprWord.isVariable then
    CurrentRec := ExprRec
  else
    MakeLinkedList(ExprRec);
  isBool := isBoolean;
  try
    Result := EvaluateList(CurrentRec);
  finally
    DisposeList(CurrentRec);
    CurrentRec := nil;
  end;
end;

function TCustomExpressionParser.MakeLinkedList(ExprRec: PExpressionRec):
  PDouble;
var
  I: Integer;
begin
  with ExprRec^ do
  begin
    for I := 0 to ExprWord.NFunctionArg - 1 do
      Args[I] := MakeLinkedList(ArgList[I]);
    if ExprWord.isVariable {@Oper = @_Variable} then
    begin
      Result := Args[0];
      Dispose(ExprRec);
    end
    else
    begin
      Result := @Res;
      if CurrentRec = nil then
      begin
        CurrentRec := ExprRec;
        LastRec := ExprRec;
      end
      else
      begin
        LastRec^.Next := ExprRec;
        LastRec := ExprRec;
      end;
    end;
  end;
end;

function TCustomExpressionParser.MakeTree(var Expr: TExprCollection):
  PExpressionRec;
{This is the most complex routine, it breaks down the expression and makes
a linked tree which is used for fast function evaluations
it is implemented recursively}
var
  I, IArg, IStart, IEnd, brCount: Integer;
  FirstOper: TExprWord;
  Expr2: TExprCollection;
  Rec: PExpressionRec;
begin
  FirstOper := nil;
  IStart := 0;
  try
    Result := nil;
    repeat
      Rec := MakeRec;
      if Result <> nil then
      begin
        IArg := 1;
        Rec^.ArgList[0] := Result;
      end
      else
        IArg := 0;
      Result := Rec;
      Expr.EraseExtraBrackets;
      if Expr.Count = 1 then
      begin
        Result^.ExprWord := TExprWord(Expr.Items[0]);
        Result^.Oper := @Result^.ExprWord.DoubleFunc;
        if not Result^.ExprWord.isVariable then
          Result^.Oper := @Result^.ExprWord.DoubleFunc
        else
        begin
          Result^.Args[0] := Result^.ExprWord.AsPointer;
        end;
        Exit;
      end;
      IEnd := Expr.NextOper(IStart);
      if IEnd = Expr.Count then
        raise EParserException.Create(errorprefix+'Syntax error in expression ' +
          CurrentExpression);
      if TExprWord(Expr.Items[IEnd]).NFunctionArg > 0 then
      begin
        FirstOper := TExprWord(Expr.Items[IEnd]);
        Result.ExprWord := FirstOper;
        Result.Oper := FirstOper.DoubleFunc;
      end
      else
        raise EParserException.Create(errorprefix+'Can not find operand/function');
      if not FirstOper.IsOper then
      begin // parse function arguments
        IArg := 0;
        IStart := IEnd + 1;
        IEnd := IStart;
        if TExprWord(Expr.Items[IEnd]).VarType = vtLeftBracket then
          brCount := 1
        else
          brCount := 0;
        while (IEnd < Expr.Count - 1) and (brCount <> 0) do
        begin
          Inc(IEnd);
          case TExprWord(Expr.Items[IEnd]).VarType of
            vtLeftBracket: Inc(brCount);
            vtComma:
              if brCount = 1 then
              begin
                Expr2 := TExprCollection.Create(IEnd - IStart);
                for I := IStart + 1 to IEnd - 1 do
                  Expr2.Add(Expr.Items[I]);
                Result.ArgList[IArg] := MakeTree(Expr2);
                Inc(IArg);
                IStart := IEnd;
              end;
            vtRightBracket: Dec(brCount);
          end;
        end;
        Expr2 := TExprCollection.Create(IEnd - IStart + 1);
        for I := IStart + 1 to IEnd - 1 do
          Expr2.Add(Expr.Items[I]);
        Result.ArgList[IArg] := MakeTree(Expr2);
      end
      else if IEnd - IStart > 0 then
      begin
        Expr2 := TExprCollection.Create(IEnd - IStart + 1);
        for I := 0 to IEnd - 1 do
          Expr2.Add(Expr.Items[I]);
        Result.ArgList[IArg] := MakeTree(Expr2);
        Inc(IArg);
      end;
      IStart := IEnd + 1;
      IEnd := IStart - 1;
      repeat
        IEnd := Expr.NextOper(IEnd + 1);
      until (IEnd >= Expr.Count) or
        (TFunction(Expr.Items[IEnd]).OperPrec >= TFunction(FirstOper).OperPrec);
      if IEnd <> IStart then
      begin
        Expr2 := TExprCollection.Create(IEnd);
        for I := IStart to IEnd - 1 do
          Expr2.Add(Expr.Items[I]);
        Result.ArgList[IArg] := MakeTree(Expr2);
      end;
      IStart := IEnd;
    until IEnd >= Expr.Count;
  finally
    Expr.Free;
    Expr := nil;
  end;
end;

function TCustomExpressionParser.ParseString(AnExpression: string):
  TExprCollection;
var
  isConstant: Boolean;
  I, I1, I2, Len: Integer;
  W, S: string;
  Word: TExprWord;
  OldDecim: Char;
  procedure ReadConstant(AnExpr: string; isHex: Boolean);
  begin
    isConstant := True;
    while (I2 <= Len) and ((AnExpr[I2] in ['0'..'9']) or
      (isHex and (AnExpr[I2] in ['a'..'f']))) do
      Inc(I2);
    if I2 <= Len then
    begin
      if AnExpr[I2] = DecimSeparator then
      begin
        Inc(I2);
        while (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) do
          Inc(I2);
      end;
      if (I2 <= Len) and (AnExpr[I2] = 'e') then
      begin
        Inc(I2);
        if (I2 <= Len) and (AnExpr[I2] in ['+', '-']) then
          Inc(I2);
        while (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) do
          Inc(I2);
      end;
    end;
  end;
  procedure ReadWord(AnExpr: string);
  var
    OldI2: Integer;
  begin
    isConstant := False;
    I1 := I2;
    while (I1 < Len) and (AnExpr[I1] = ' ') do
      Inc(I1);
    I2 := I1;
    if I1 <= Len then
    begin
      if AnExpr[I2] = HexChar then
      begin
        Inc(I2);
        OldI2 := I2;
        ReadConstant(AnExpr, True);
        if I2 = OldI2 then
        begin
          isConstant := False;
          while (I2 <= Len) and (AnExpr[I2] in ['a'..'z', '_', '0'..'9']) do
            Inc(I2);
        end;
      end
      else if AnExpr[I2] = DecimSeparator then
        ReadConstant(AnExpr, False)
      else
        case AnExpr[I2] of
          '''':
            begin
              isConstant := True;
              Inc(I2);
              while (I2 <= Len) and (AnExpr[I2] <> '''') do
                Inc(I2);
              if I2 <= Len then
                Inc(I2);
            end;
          'a'..'z', '_':
            begin
              while (I2 <= Len) and (AnExpr[I2] in ['a'..'z', '_', '0'..'9']) do
                Inc(I2);
            end;
          '>', '<':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['=', '<', '>'] then
                Inc(I2);
            end;
          '=':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['<', '>', '='] then
                Inc(I2);
            end;
          '&':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['&'] then
                Inc(I2);
            end;
          '|':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] in ['|'] then
                Inc(I2);
            end;
          ':':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] = '=' then
                Inc(I2);
            end;
          '!':
            begin
              if (I2 <= Len) then
                Inc(I2);
              if AnExpr[I2] = '=' then //support for !=
                Inc(I2);
            end;
          '+':
            begin
              Inc(I2);
              if (I2 <= Len)and(AnExpr[I2] = '+') and WordsList.Search(pchar('++'), I) then
                Inc(I2);
            end;
          '-':
            begin
              Inc(I2);
              if (I2 <= Len) and (AnExpr[I2] = '-') and WordsList.Search(pchar('--'), I) then
                Inc(I2);
            end;
          '^', '/', '\', '*', '(', ')', '%', '~', '$', '[', ']':
            Inc(I2);
          '0'..'9':
            ReadConstant(AnExpr, False);
        else
          begin
            Inc(I2);
          end;
        end;
    end;
  end;
begin
  OldDecim := SysUtils.DecimalSeparator;
  SysUtils.DecimalSeparator := DecimSeparator;
  Result := TExprCollection.Create(10);
  I2 := 1;
  S := Trim(LowerCase(AnExpression));
  Len := Length(S);
  repeat
    ReadWord(S);
    W := Trim(Copy(S, I1, I2 - I1));
    if isConstant then
    begin
      if W[1] = HexChar then
      begin
        W[1] := '$';
        W := IntToStr(StrToInt(W));
      end;
      if W[1] = '''' then
        Word := TStringConstant.Create(W)
      else
        Word := TDoubleConstant.Create(W, W);
      Result.Add(Word);
      ConstantsList.Add(Word);
    end
    else if W <> '' then
      if WordsList.Search(pchar(W), I) then
        Result.Add(WordsList.Items[I])
      else
      begin
        Word := TGeneratedVariable.Create(W);
        Result.Add(Word);
        WordsList.Add(Word);
      end;
  until I2 > Len;
  SysUtils.DecimalSeparator := OldDecim;
end;

procedure TCustomExpressionParser.Check(AnExprList: TExprCollection);

var
  I, J, K, L: Integer;
  Word: TSimpleStringFunction;
  function GetStringFunction(ExprWord, Left, Right: TExprWord):
      TSimpleStringFunction;
  begin
    with TSimpleStringFunction(ExprWord) do
      if CanVary then
        Result := TVaryingStringFunction.Create(Name, Description,
          StringFunc, Left, Right)
      else
        Result := TSimpleStringFunction.Create(Name, Description,
          StringFunc, Left, Right);
  end;
begin
  AnExprList.Check;
  with AnExprList do
  begin
    I := 0;
    while I < Count do
    begin
      {----CHECK ON DOUBLE MINUS OR DOUBLE PLUS----}
      if ((TExprWord(Items[I]).Name = '-') or
        (TExprWord(Items[I]).Name = '+'))
        and ((I = 0) or
        (TExprWord(Items[I - 1]).VarType = vtComma) or
        (TExprWord(Items[I - 1]).VarType = vtLeftBracket) or
        (TExprWord(Items[I - 1]).IsOper and (TExprWord(Items[I - 1]).NFunctionArg
        = 2))) then
      begin
        {replace e.g. ----1 with +1}
        if TExprWord(Items[I]).Name = '-' then
          K := -1
        else
          K := 1;
        L := 1;
        while (I + L < Count) and ((TExprWord(Items[I + L]).Name = '-')
          or (TExprWord(Items[I + L]).Name = '+')) and ((I + L = 0) or
          (TExprWord(Items[I + L - 1]).VarType = vtComma) or
          (TExprWord(Items[I + L - 1]).VarType = vtLeftBracket) or
          (TExprWord(Items[I + L - 1]).IsOper and (TExprWord(Items[I + L -
          1]).NFunctionArg = 2))) do
        begin
          if TExprWord(Items[I + L]).Name = '-' then
            K := -1 * K;
          Inc(L);
        end;
        if L > 0 then
        begin
          Dec(L);
          for J := I + 1 to Count - 1 - L do
            Items[J] := Items[J + L];
          Count := Count - L;
        end;
        if K = -1 then
        begin
          if WordsList.Search(pchar('-@'), J) then
            Items[I] := WordsList.Items[J];
        end
        else if WordsList.Search(pchar('+@'), J) then
          Items[I] := WordsList.Items[J];
      end;
      {----CHECK ON DOUBLE NOT----}
      if (TExprWord(Items[I]).Name = 'not')
        and ((I = 0) or
        (TExprWord(Items[I - 1]).VarType = vtLeftBracket) or
        TExprWord(Items[I - 1]).IsOper) then
      begin
        {replace e.g. not not 1 with 1}
        K := -1;
        L := 1;
        while (I + L < Count) and (TExprWord(Items[I + L]).Name = 'not') and ((I
          + L = 0) or
          (TExprWord(Items[I + L - 1]).VarType = vtLeftBracket) or
          TExprWord(Items[I + L - 1]).IsOper) do
        begin
          K := -K;
          Inc(L);
        end;
        if L > 0 then
        begin
          if K = 1 then
          begin //remove all
            for J := I to Count - 1 - L do
              Items[J] := Items[J + L];
            Count := Count - L;
          end
          else
          begin //keep one
            Dec(L);
            for J := I + 1 to Count - 1 - L do
              Items[J] := Items[J + L];
            Count := Count - L;
          end
        end;
      end;
      {-----MISC CHECKS-----}
      if (TExprWord(Items[I]).isVariable) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).isVariable)) then
        raise EParserException.Create(errorprefix+TExprWord(Items[I]).Name +
          ' two space limited variables/constants');
      if (TExprWord(Items[I]).ClassType = TGeneratedVariable) and ((I < Count -
        1) and
        (TExprWord(Items[I + 1]).VarType = vtLeftBracket)) then
        raise EParserException.Create(errorprefix+TExprWord(Items[I]).Name +
          ' is an unknown function');
      if (TExprWord(Items[I]).VarType = vtLeftBracket) and ((I >= Count - 1) or
        (TExprWord(Items[I + 1]).VarType = vtRightBracket)) then
        raise EParserException.Create(errorprefix+'Empty brackets ()');
      if (TExprWord(Items[I]).VarType = vtRightBracket) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).VarType = vtLeftBracket)) then
        raise EParserException.Create(errorprefix+'Missing operand between )(');
      if (TExprWord(Items[I]).VarType = vtRightBracket) and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).isVariable)) then
        raise
          EParserException.Create(errorprefix+'Missing operand between ) and constant/variable');
      if (TExprWord(Items[I]).VarType = vtLeftBracket) and ((I > 0) and
        (TExprWord(Items[I - 1]).isVariable)) then
        raise
          EParserException.Create(errorprefix+'Missing operand between constant/variable and (');

      {-----CHECK ON INTPOWER------}
      if (TExprWord(Items[I]).Name = '^') and ((I < Count - 1) and
        (TExprWord(Items[I + 1]).ClassType = TDoubleConstant) and
        (Pos(DecimSeparator, TExprWord(Items[I + 1]).Name) = 0)) then
        if WordsList.Search(pchar('^@'), J) then
          Items[I] := WordsList.Items[J]; //use the faster intPower if possible
      Inc(I);
    end;

    {-----CHECK STRING COMPARE--------}
    I := Count - 2;
    while I >= 0 do
    begin
      if (TExprWord(Items[I]).VarType = vtString) then
      begin
        if (I >= 2) and (TExprWord(Items[I - 2]) is TSimpleStringFunction) then
        begin
          if (I + 2 < Count) and (TExprWord(Items[I + 2]).VarType = vtString)
            then
          begin
            Word := GetStringFunction(TExprWord(Items[I - 2]),
              TExprWord(Items[I]), TExprWord(Items[I + 2]));
            Items[I - 2] := Word;
            for J := I - 1 to Count - 6 do
              Items[J] := Items[J + 5];
            Count := Count - 5;
            I := I - 1;
            ConstantsList.Add(Word);
          end
          else
          begin
            with TSimpleStringFunction(Items[I - 2]) do
              Word := GetStringFunction(TExprWord(Items[I - 2]),
                TExprWord(Items[I]), nil);
            Items[I - 2] := Word;
            for J := I - 1 to Count - 4 do
              Items[J] := Items[J + 3];
            Count := Count - 3;
            I := I - 1;
            ConstantsList.Add(Word);
          end;
        end
        else if (I + 2 < Count) and (TExprWord(Items[I + 2]).VarType = vtString)
          then
        begin
          Word := TLogicalStringOper.Create(TExprWord(Items[I + 1]).Name,
            TExprWord(Items[I]), TExprWord(Items[I + 2]));
          Items[I] := Word;
          for J := I + 1 to Count - 3 do
            Items[J] := Items[J + 2];
          Count := Count - 2;
          ConstantsList.Add(Word);
        end;
      end;
      Dec(I);
    end;
  end;
end;

{$IFDEF NAN}
function HasNaN(LastRec1: PExpressionRec): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to LastRec1^.ExprWord.NFunctionArg- 1 do
    if (comp(LastRec1^.Args[I]^)= comp(Nan))
      //much faster than CompareMem(LastRec1^.Args[I], @Nan, SizeOf(Double))
    and (@LastRec1^.ExprWord.DoubleFunc <> @_isNaN) and
      (@LastRec1^.ExprWord.DoubleFunc <> @_Assign) then
    begin
      Result := True;
      exit;
    end;
end;
{$ENDIF}

function TCustomExpressionParser.EvaluateList(ARec: PExpressionRec): Double;
var
  LastRec1: PExpressionRec;
begin
  if ARec <> nil then
  begin
    LastRec1 := ARec;
    while LastRec1^.Next <> nil do
    begin
{$IFDEF NAN}
      if HasNaN(LastRec1) then
        LastRec1^.Res := Nan
      else
{$ENDIF}
        LastRec1^.Oper(LastRec1);
      LastRec1 := LastRec1^.Next;
    end;
{$IFDEF NAN}
      if HasNaN(LastRec1) then
        LastRec1^.Res := Nan
      else
{$ENDIF}
        LastRec1^.Oper(LastRec1);
    Result := LastRec1^.Res;
  end
  else
    Result := Nan;
end;

procedure TCustomExpressionParser.DefineFunction(AFunctName, ADescription:
  string;
  AFuncAddress: TDoubleFunc; NArguments: Integer);
begin
  AddReplaceExprWord(TFunction.Create(AFunctName, ADescription, AFuncAddress,
    NArguments));
end;

procedure TCustomExpressionParser.DefineVariable(AVarName: string; AValue:
  PDouble);
begin
  AddReplaceExprWord(TDoubleVariable.Create(AVarName, AValue));
end;

procedure TCustomExpressionParser.DefineStringVariable(AVarName: string; AValue:
  PString);
begin
  AddReplaceExprWord(TStringVariable.Create(AVarName, AValue));
end;

procedure TCustomExpressionParser.GetGeneratedVars(AList: TList);
var
  I: Integer;
begin
  AList.Clear;
  with WordsList do
    for I := 0 to Count - 1 do
    begin
      if TObject(Items[I]).ClassType = TGeneratedVariable then
        AList.Add(Items[I]);
    end;
end;

function TCustomExpressionParser.isBoolean: Boolean;
var
  LastRec1: PExpressionRec;
begin
  if CurrentRec = nil then
    Result := False
  else
  begin
    LastRec1 := CurrentRec;
    //LAST operand should be boolean -otherwise If(,,) doesn't work
    while (LastRec1^.Next <> nil) do
      LastRec1 := LastRec1^.Next;
    Result := (LastRec1.ExprWord <> nil) and (LastRec1.ExprWord.VarType =
      vtBoolean);
  end;
end;

procedure TCustomExpressionParser.ReplaceExprWord(OldExprWord, NewExprWord:
  TExprWord);
var
  J: Integer;
  Rec: PExpressionRec;
  p, pnew: pointer;
begin
  if OldExprWord.NFunctionArg <> NewExprWord.NFunctionArg then
    raise
      Exception.Create(errorprefix+'Cannot replace variable/function NFuntionArg doesn''t match');
  p := OldExprWord.AsPointer;
  pnew := NewExprWord.AsPointer;
  Rec := CurrentRec;
  repeat
    if (Rec.ExprWord = OldExprWord) then
    begin
      Rec.ExprWord := NewExprWord;
      Rec.Oper := NewExprWord.DoubleFunc;
    end;
    if p <> nil then
      for J := 0 to Rec.ExprWord.NFunctionArg - 1 do
        if Rec.Args[J] = p then
          Rec.Args[J] := pnew;
    Rec := Rec.Next;
  until Rec = nil;
end;

function TCustomExpressionParser.MakeRec: PExpressionRec;
var
  I: Integer;
begin
  Result := New(PExpressionRec);
  Result.Oper := nil;
  for I := 0 to MaxArg - 1 do
    Result.ArgList[I] := nil;
  Result.Res := 0;
  Result.Next := nil;
  Result.ExprWord := nil;
end;

function TCustomExpressionParser.Evaluate(AnExpression: string): Double;
begin
  if AnExpression <> '' then
  begin
    AddExpression(AnExpression);
    Result := EvaluateList(CurrentRec);
  end
  else
    Result := Nan;
end;

function TCustomExpressionParser.AddExpression(AnExpression: string): Integer;
begin
  if AnExpression <> '' then
  begin
    Result := 0;
    CompileExpression(AnExpression);
  end
  else
    Result := -1;
end;

procedure TCustomExpressionParser.ReplaceFunction(OldName: string; AFunction:
  TObject);
var
  I: Integer;
begin
  if WordsList.Search(pchar(OldName), I) then
  begin
    ReplaceExprWord(WordsList.Items[I], TExprWord(AFunction));
    WordsList.AtFree(I);
  end;
  if AFunction <> nil then
    WordsList.Add(AFunction);
end;

procedure TCustomExpressionParser.ClearExpressions;
begin
  DisposeList(CurrentRec);
  LastRec := nil;
end;

procedure TCustomExpressionParser.DisposeList(ARec: PExpressionRec);
var
  TheNext: PExpressionRec;
begin
  if ARec <> nil then
    repeat
      TheNext := ARec.Next;
      Dispose(ARec);
      ARec := TheNext;
    until ARec = nil;
end;

function TCustomExpressionParser.EvaluateCurrent: Double;
begin
  Result := EvaluateList(CurrentRec);
end;

procedure TCustomExpressionParser.AddReplaceExprWord(AExprWord: TExprWord);
var
  IOldVar: Integer;
begin
  if WordsList.Search(pchar(AExprWord.Name), IOldVar) then
  begin
    ReplaceExprWord(WordsList.Items[IOldVar], AExprWord);
    WordsList.AtFree(IOldVar);
    WordsList.Add(AExprWord);
  end
  else
    WordsList.Add(AExprWord);
end;

function TCustomExpressionParser.GetFunctionDescription(AFunction: string):
  string;
var
  S: string;
  p, I: Integer;
begin
  S := AFunction;
  p := Pos('(', S);
  if p > 0 then
    S := Copy(S, 1, p - 1);
  if WordsList.Search(pchar(S), I) then
    Result := TExprWord(WordsList.Items[I]).Description
  else
    Result := '';
end;

procedure TCustomExpressionParser.GetFunctionNames(AList: TStrings);
var
  I, J: Integer;
  S: string;
begin
  with WordsList do
    for I := 0 to Count - 1 do
      with TExprWord(WordsList.Items[I]) do
        if Description <> '' then
        begin
          S := Name;
          if NFunctionArg > 0 then
          begin
            S := S + '(';
            for J := 0 to NFunctionArg - 2 do
              S := S + ArgSeparator;
            S := S + ')';
          end;
          AList.Add(S);
        end;
end;

procedure TCustomExpressionParser.DefineStringFunction(AFunctName,
  ADescription: string; AFuncAddress: TStringFunc);
begin
  AddReplaceExprWord(TSimpleStringFunction.Create(AFunctName, ADescription,
    AFuncAddress,
    nil, nil));
end;

procedure TCustomExpressionParser.SetArgSeparator(const Value: Char);
begin
  ReplaceFunction(FArgSeparator, TComma.Create(Value, nil));
  FArgSeparator := Value;
  if (DecimSeparator = ArgSeparator) then
  begin
    if DecimSeparator = ',' then
      DecimSeparator := '.'
    else
      DecimSeparator := ',';
  end;

end;

procedure TCustomExpressionParser.SetDecimSeparator(const Value: Char);
begin
  FDecimSeparator := Value;
  if (DecimSeparator = ArgSeparator) then
  begin
    if DecimSeparator = ',' then
      ArgSeparator := ';'
    else
      ArgSeparator := ',';
  end;
end;

{ TExpressionParser }

procedure TExpressionParser.ClearExpressions;
var
  I: Integer;
begin
  for I := 0 to Expressions.Count - 1 do
    DisposeList(PExpressionRec(Expressions.Objects[I]));
  Expressions.Clear;
  CurrentIndex := -1;
  CurrentRec := nil;
  LastRec := nil;
end;

{function TExpressionParser.Evaluate(AnExpression: string): Double;
begin
  if AnExpression <> '' then
  begin
    AddExpression(AnExpression);
    Result := EvaluateList(CurrentRec);
  end
  else
    Result := Nan;
end;
 }

function TExpressionParser.AddExpression(AnExpression: string): Integer;
begin
  if AnExpression <> '' then
  begin
    Result := Expressions.IndexOf(AnExpression);
    if (Result < 0) and CompileExpression(AnExpression) then
      Result := Expressions.AddObject(AnExpression, TObject(CurrentRec))
    else
      CurrentRec := PExpressionRec(Expressions.Objects[Result]);
  end
  else
    Result := -1;
  CurrentIndex := Result;
end;

function TExpressionParser.GetResults(AIndex: Integer): Double;
begin
  if AIndex >= 0 then
  begin
    CurrentRec := PExpressionRec(Expressions.Objects[AIndex]);
    Result := EvaluateList(CurrentRec);
  end
  else
    Result := Nan;
end;

function TExpressionParser.GetAsBoolean(AIndex: Integer): Boolean;
var
  D: Double;
begin
  D := AsFloat[AIndex];
  if not isBoolean then
    raise EParserException.Create(errorprefix+'Expression is not boolean')
  else if (D < 0.1) and (D > -0.1) then
    Result := False
  else
    Result := True;
end;

function TExpressionParser.GetAsString(AIndex: Integer): string;
var
  D: Double;
begin
  D := AsFloat[AIndex];
  if isBoolean then
  begin
{$IFDEF nan}
     if isNan(D) then
      Result := 'NAN'
    else
{$ENDIF}if (D < 0.1) and (D > -0.1) then
        Result := 'False'
      else if (D > 0.9) and (D < 1.1) then
        Result := 'True'
      else
        Result := Format('%.10g', [D]);
  end
  else
    Result := Format('%.10g', [D]);
end;

constructor TExpressionParser.Create;
begin
  inherited;
  Expressions := TStringList.Create;
  Expressions.Sorted := False;
end;

destructor TExpressionParser.Destroy;
begin
  inherited;
  Expressions.Free;
end;

procedure TExpressionParser.FillExpressList;
begin
  with WordsList do
  begin
    Add(TLeftBracket.Create('[', nil));
    Add(TRightBracket.Create(']', nil));
    Add(TComma.Create(ArgSeparator, nil));
    Add(TConstant.CreateAsDouble('pi', 'pi = 3.1415926535897932385', Pi));
{$IFDEF NAN}
    Add(TConstant.CreateAsDouble('nan',
      'Not a number, mathematical error in result', Nan));
    Add(TBooleanFunction.Create('isnan', 'Is Not a Number (has error)?', _isNaN,
      1));
{$ENDIF}
    Add(TVaryingFunction.Create('random',
      'random number between 0 and 1', _random, 0));
    // definitions of operands:
    // the last number is used to determine the precedence
    Add(TFunction.CreateOper('!', _factorial, 1,
      True { isOperand}, 10 {precedence}));
    Add(TFunction.CreateOper('++', _Add1, 1, True, 5));
    Add(TFunction.CreateOper('--', _minus1, 1, True, 5));
    Add(TFunction.CreateOper('%', _Percentage, 1, True, 10));
    Add(TFunction.CreateOper('-@', _negate, 1, True, 10));
    Add(TFunction.CreateOper('+@', _plus, 1, True, 10));
    Add(TFunction.CreateOper('^', _Power, 2, True, 20));
    Add(TFunction.CreateOper('^@', _IntPower, 2, True, 20));
    Add(TFunction.CreateOper('*', _mult, 2, True, 30));
    Add(TFunction.CreateOper('/', _realDivide, 2, True, 30));
    Add(TFunction.CreateOper('div', _Div, 2, True, 30));
    Add(TFunction.CreateOper('mod', _mod, 2, True, 30));
    Add(TFunction.CreateOper('+', _Add, 2, True, 40));
    Add(TFunction.CreateOper('-', _minus, 2, True, 40));
    Add(TBooleanFunction.CreateOper('>', _gt, 2, True, 50));
    Add(TBooleanFunction.CreateOper('>=', _ge, 2, True, 50));
    Add(TBooleanFunction.CreateOper('<=', _le, 2, True, 50));
    Add(TBooleanFunction.CreateOper('<', _lt, 2, True, 50));
    Add(TBooleanFunction.CreateOper('<>', _ne, 2, True, 50));
    Add(TBooleanFunction.CreateOper('=', _eq, 2, True, 50));
    Add(TBooleanFunction.CreateOper('in', _eq, 2, True, 10));
    Add(TBooleanFunction.CreateOper('not', _not, 1, True, 60));
    Add(TBooleanFunction.CreateOper('or', _or, 2, True, 70));
    Add(TBooleanFunction.CreateOper('and', _And, 2, True, 70));
    Add(TBooleanFunction.CreateOper('xor', _xor, 2, True, 70));
    Add(TFunction.CreateOper(':=', _Assign, 2, True, 200));
    Add(TFunction.Create('exp', 'the value of e raised to the power of x'
      , _exp, 1));
    Add(TFunction.Create('if', 'if x=True(or 1) then y else z', _if, 3));
    Add(TVaryingFunction.Create('randg',
      'draw from normal distrib. (mean=x, sd =y)'
      , _randG, 2));
    Add(TFunction.Create('sqr', 'the square of a number (x*x)', _sqr, 1));
    Add(TFunction.Create('sqrt', 'the square root of a number', _sqrt, 1));
    Add(TFunction.Create('abs', 'absolute value', _Abs, 1));
    Add(TFunction.Create('round', 'round to the nearest integer', _round, 1));
    Add(TFunction.Create('trunc', 'truncates a real number to an integer',
      _trunc, 1));
    Add(TFunction.Create('ln', 'natural logarithm of x', _ln, 1));
    Add(TFunction.Create('log10', 'logarithm base 10 of x', _log10, 1));
    Add(TFunction.Create('logN', 'logarithm base x of y', _logN, 2));
    Add(TFunction.Create('power', 'power: x^y', _Power, 2));
    Add(TFunction.Create('pow', 'power: x^y', _Power, 2));
    Add(TFunction.Create('intpower', 'integer power: x^y', _IntPower, 2));
    Add(TFunction.Create('max', 'the maximum of both arguments', _max, 2));
    Add(TFunction.Create('min', 'the minimum of both arguments', _min, 2));
    Add(TFunction.Create('sin', 'sine of an angle in rad', _sin, 1));
    Add(TFunction.Create('cos', 'cosine of an angle in rad', _Cos, 1));
    Add(TFunction.Create('tan', 'tangent of an angle in rad', _tan, 1));
    Add(TFunction.Create('arcsin', 'inverse sine in rad', _ArcSin, 1));
    Add(TFunction.Create('arccos', 'inverse cosine in rad', _ArcCos, 1));
    Add(TFunction.Create('arctan2', 'inverse tangent (x/y) in rad', _ArcTan2,
      2));
    Add(TFunction.Create('arctan', 'inverse tangent (x/y) in rad', _arctan, 1));
    Add(TFunction.Create('sinh', 'hyperbolic sine of an angle in rad', _Sinh,
      1));
    Add(TFunction.Create('cosh', 'hyperbolic sine of an angle in rad', _Cosh,
      1));
    Add(TFunction.Create('tanh', 'hyperbolic tangent of an angle in rad', _tanh,
      1));
    Add(TFunction.Create('arcsinh', 'inverse sine in rad', _ArcSinh, 1));
    Add(TFunction.Create('arccosh', 'inverse hyperbolic cosine in rad',
      _ArcCosh, 1));
    Add(TFunction.Create('arctanh', 'inverse hyperbolic tangent in rad',
      _ArcTanh, 1));
    Add(TFunction.Create('degtorad', 'conversion of degrees to radians',
      _DegToRad, 1));
    Add(TFunction.Create('radtodeg', 'conversion of rad to degrees', _RadToDeg,
      1));

    DefineStringFunction('pos','Position in of substring in string',_pos);
  end;
end;

function TExpressionParser.GetAsHexadecimal(AIndex: Integer): string;
var
  D: Double;
begin
  D := AsFloat[AIndex];
  Result := Format(HexChar + '%x', [Round(D)]);
end;

function TExpressionParser.GetExpression(AIndex: Integer): string;
begin
  Result := Expressions.Strings[AIndex];
end;

function TExpressionParser.GetExprSize(AIndex: Integer): Integer;
var
  TheNext, ARec: PExpressionRec;
begin
  Result := 0;
  if AIndex >= 0 then
  begin
    ARec := PExpressionRec(Expressions.Objects[AIndex]);
    while ARec <> nil do
    begin
      TheNext := ARec.Next;
      if (ARec.ExprWord <> nil) and
        not ARec.ExprWord.isVariable then
        Inc(Result);
      ARec := TheNext;
    end;
  end;
end;

procedure TExpressionParser.ReplaceExprWord(OldExprWord, NewExprWord:
  TExprWord);
var
  I: Integer;
begin
  if OldExprWord.NFunctionArg <> NewExprWord.NFunctionArg then
    raise
      Exception.Create(errorprefix+'Cannot replace variable/function NFuntionArg doesn''t match');
  if Expressions <> nil then
    for I := 0 to Expressions.Count - 1 do
    begin
      CurrentRec := PExpressionRec(Expressions.Objects[I]);
      inherited;
    end
end;

function TExpressionParser.CurrentExpression: string;
begin
  Result := Expressions.Strings[CurrentIndex];
end;

{ TCStyleParser }

procedure TCStyleParser.FillExpressList;
begin
  inherited;
  CStyle := True;
end;

procedure TCStyleParser.SetCStyle(const Value: Boolean);
begin
  FCStyle := Value;
  if Value then
  begin
    //note: mind the correct order of replacements
    ReplaceFunction('!', TFunction.Create('fact', 'factorial', _factorial, 1));
    ReplaceFunction('div', TFunction.Create('div', 'integer division', _Div,
      2));
    ReplaceFunction('%', TFunction.Create('perc', 'percentage', _Percentage,
      1));
    ReplaceFunction('mod', TFunction.CreateOper('%', _mod, 2, True, 30));
    ReplaceFunction('or', TBooleanFunction.CreateOper('||', _or, 2, True, 70));
    ReplaceFunction('and', TBooleanFunction.CreateOper('&&', _And, 2, True,
      70));
    ReplaceFunction('=', TBooleanFunction.CreateOper('==', _eq, 2, True, 50));
    ReplaceFunction(':=', TFunction.CreateOper('=', _Assign, 2, True, 200));
    ReplaceFunction('<>', TBooleanFunction.CreateOper('!=', _ne, 2, True, 50));
    ReplaceFunction('not', TBooleanFunction.CreateOper('!', _not, 1, True, 60));
  end
  else
  begin
    //note: mind the correct order of replacements
    ReplaceFunction('!', TBooleanFunction.CreateOper('not', _not, 1, True, 60));
    ReplaceFunction('fact', TFunction.CreateOper('!', _factorial, 1, True, 10));
    ReplaceFunction('div', TFunction.CreateOper('div', _Div, 2, True, 30));
    ReplaceFunction('%', TFunction.CreateOper('mod', _mod, 2, True, 30));
    ReplaceFunction('perc', TFunction.CreateOper('%', _Percentage, 1, True,
      10));
    ReplaceFunction('||', TBooleanFunction.CreateOper('or', _or, 2, True, 70));
    ReplaceFunction('&&', TBooleanFunction.CreateOper('and', _And, 2, True,
      70));
    ReplaceFunction('=', TFunction.CreateOper(':=', _Assign, 2, True, 200));
    ReplaceFunction('==', TBooleanFunction.CreateOper('=', _eq, 2, True, 50));
    ReplaceFunction('!=', TBooleanFunction.CreateOper('<>', _ne, 2, True, 50));
  end;
end;

end.


