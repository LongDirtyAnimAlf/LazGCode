{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

-------------------------------------------------------------------------------}
unit SynEditMarkupBracketCNC;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, SynEditMarkup, SynEditMiscClasses, SynEditTypes, SynEditMarkupBracket, Controls, LCLProc;

type
  TSynEditMarkupBracketCNC = class(TSynEditMarkupBracket)
  private
  protected
    procedure FindMatchingBracketPair(LogCaret: TPoint; var StartBracket,
      EndBracket: TPoint);override;
  public
  end;

implementation

procedure TSynEditMarkupBracketCNC.FindMatchingBracketPair(LogCaret: TPoint; var StartBracket,
  EndBracket: TPoint);
const
  Brackets: set of Char = ['<','>','(',')','{','}','[',']', '''', '"' ];
var
  StartLine: string;
  x: Integer;
begin
  StartBracket.Y := -1;
  EndBracket.Y := -1;
  if (LogCaret.Y < 1) or (LogCaret.Y > Lines.Count) or (LogCaret.X < 1) then
    Exit;

  StartLine := Lines[LogCaret.Y - 1];

  // check for bracket, left of cursor
  if (HighlightStyle in [sbhsLeftOfCursor, sbhsBoth]) and (LogCaret.x > 1) then
  begin
    x := Lines.LogicPosAddChars(StartLine, LogCaret.x, -1);
    if (x <= length(StartLine)) and (StartLine[x] in Brackets) then
    begin
      StartBracket := LogCaret;
      StartBracket.x := x;
      EndBracket := SynEdit.FindMatchingBracketLogical(StartBracket, False, False, False, False);
      if EndBracket.y < 0 then
        StartBracket.y := -1;
      Exit;
    end;
  end;

  // check for bracket after caret
  if (HighlightStyle in [sbhsRightOfCursor, sbhsBoth]) then
  begin
    x := LogCaret.x ;
    if (x <= length(StartLine)) and (StartLine[x] in Brackets) then
    begin
      StartBracket := LogCaret;
      EndBracket := SynEdit.FindMatchingBracketLogical(LogCaret, False, False, False, False);
      if EndBracket.y < 0 then
        StartBracket.y := -1;
    end;
  end;
end;

end.

