(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2018, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.TextEditor;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Contnrs,
     Math,
     PasVulkan.Types;

{-$define TpvTextEditorUsePUCU}

type TpvTextEditor=class
      public
       const NewLineCodePointSequence={$ifdef Windows}#13#10{$else}#10{$endif};
       type TUTF8DFA=class
             public                                            //0 1 2 3 4 5 6 7 8 9 a b c d e f
               const CodePointSizes:array[AnsiChar] of TpvUInt8=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 0
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 1
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 2
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 3
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 4
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 5
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 6
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 7
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 8
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // 9
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // a
                                                                 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  // b
                                                                 1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  // c
                                                                 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  // d
                                                                 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,  // e
                                                                 4,4,4,4,4,1,1,1,1,1,1,1,1,1,1,1); // f
                     StateCharClasses:array[AnsiChar] of TpvUInt8=($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                                                                   $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,
                                                                   $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,
                                                                   $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
                                                                   $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
                                                                   $08,$08,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,
                                                                   $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,
                                                                   $0a,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$04,$03,$03,
                                                                   $0b,$06,$06,$06,$05,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08);
                     StateTransitions:array[TpvUInt8] of TpvUInt8=($00,$10,$20,$30,$50,$80,$70,$10,$10,$10,$40,$60,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$00,$10,$10,$10,$10,$10,$00,$10,$00,$10,$10,$10,$10,$10,$10,
                                                                   $10,$20,$10,$10,$10,$10,$10,$20,$10,$20,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$20,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$20,$10,$10,$10,$10,$10,$10,$10,$20,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$30,$10,$30,$10,$10,$10,$10,$10,$10,
                                                                   $10,$30,$10,$10,$10,$10,$10,$30,$10,$30,$10,$10,$10,$10,$10,$10,
                                                                   $10,$30,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,
                                                                   $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10);
                      StateAccept=0;
                      StateError=16;
                      StateCharClassSingleByte=0;
            end;
            TUTF8Utils=class
             public
              const cpLATIN1=28591;
                    cpISO_8859_1=28591;
                    cpUTF16LE=1200;
                    cpUTF16BE=1201;
                    cpUTF7=65000;
                    cpUTF8=65001;
             private
              const UTF16LittleEndianBigEndianShifts:array[0..1,0..1] of TpvInt32=((0,8),(8,0));
                    UTF32LittleEndianBigEndianShifts:array[0..1,0..3] of TpvInt32=((0,8,16,24),(24,16,8,0));
             public
              class function UTF32CharToUTF8(const aCodePoint:TpvUInt32):TpVUTF8String; static;
              class function UTF8Validate(const aString:TpvUTF8String):boolean; static;
              class function UTF8Correct(const aString:TpvUTF8String):TpvUTF8String; static;
              class function RawDataToUTF8String(const aData;const aDataLength:TpvInt32;const aCodePage:TpvInt32=-1):TpvUTF8String; static;
              class function RawByteStringToUTF8String(const aString:TpvRawByteString;const aCodePage:TpvInt32=-1):TpvUTF8String; static;
              class function RawStreamToUTF8String(const aStream:TStream;const aCodePage:TpvInt32=-1):TpvUTF8String; static;
            end;
            ERope=class(Exception);
            TRope=class
             public
              type TNode=class
                    public
                     const StringSize=128;
                           MaximumHeight=60;
                           MaximumHeightMinusOne=MaximumHeight-1;
                           MaximumHeightMinusTwoBitMask=TpvUInt64((TpvUInt64(1) shl (MaximumHeight-2))-1);
                     type TNodeLink=record
                           private
                            fNode:TNode;
                            fSkipSize:TpvSizeInt;
                          end;
                          PNodeLink=^TNodeLink;
                          TNodeLinks=array of TNodeLink; // index 0 is linked-list-next
                          TNodePositionLinks=array[0..MaximumHeight-1] of TNodeLink;
                          TData=array[0..StringSize-1] of AnsiChar;
                    private
                     fData:TData;
                     fCountCodeUnits:TpvSizeInt;
                     fHeight:TpvInt32;
                     fLinks:TNodeLinks;
                     function GetData:TpvUTF8String;
                    public
                     constructor Create(const aHeight:TpvInt32); reintroduce;
                     destructor Destroy; override;
                     property Data:TpvUTF8String read GetData;
                   end;
                   TNodeEnumerator=record
                    private
                     fRope:TRope;
                     fFirst:boolean;
                     fNode:TNode;
                     function GetCurrent:TNode; inline;
                    public
                     constructor Create(const aCodeUnitsRope:TRope);
                     function MoveNext:boolean; inline;
                     property Current:TNode read GetCurrent;
                   end;
                   TCodePointEnumerator=record
                    private
                     fRope:TRope;
                     fFirst:boolean;
                     fNode:TNode;
                     fNodeCodeUnitIndex:TpvSizeInt;
                     fCodePointIndex:TpvSizeInt;
                     fStopCodePointIndex:TpvSizeInt;
                     fCodePoint:TpvUInt32;
                     fUTF8DFACharClass:TpvUInt8;
                     fUTF8DFAState:TpvUInt8;
                     function GetCurrent:TpvUInt32;
                    public
                     constructor Create(const aCodeUnitsRope:TRope;const aStartCodePointIndex:TpvSizeInt=0;const aStopCodePointIndex:TpvSizeInt=-1);
                     function CanMoveNext:boolean; inline;
                     function MoveNext:boolean;
                     property Current:TpvUInt32 read GetCurrent;
                   end;
                   TCodePointEnumeratorSource=record
                    private
                     fRope:TRope;
                     fStartCodePointIndex:TpvSizeInt;
                     fStopCodePointIndex:TpvSizeInt;
                    public
                     constructor Create(const aCodeUnitsRope:TRope;const aStartCodePointIndex:TpvSizeInt=0;const aStopCodePointIndex:TpvSizeInt=-1);
                     function GetEnumerator:TCodePointEnumerator;
                   end;
                   TRandomGenerator=record
                    private
                     fState:TpvUInt64;
                     fIncrement:TpvUInt64;
                    public
                     constructor Create(const aSeed:TpvUInt64);
                     function GetUInt32:TpvUInt32;
                     function GetUInt64:TpvUInt64;
                   end;
             private
              fCountCodePoints:TpvSizeInt;
              fCountCodeUnits:TpvSizeInt;
              fHead:TNode;
              fRandomGenerator:TRandomGenerator;
              function GetText:TpvUTF8String;
              procedure SetText(const aCodeUnits:TpvUTF8String);
              class function FindFirstSetBit(aValue:TpvUInt64):TpvUInt32; {$ifndef fpc}{$ifdef cpu386}stdcall;{$else}register;{$endif}{$endif} static;
              function GetRandomHeight:TpvInt32;
              class function GetCountCodeUnits(const aCodeUnits:PAnsiChar;const aCountCodePoints:TpvSizeInt):TpvSizeInt; static;
              class function GetCountCodePoints(const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt):TpvSizeInt; static;
              class procedure UTF8Check(const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt); static;
              function FindNodePositionAtCodePoint(const aCodePointIndex:TpvSizeInt;out aNodePositionLinks:TNode.TNodePositionLinks):TNode;
              procedure UpdateOffsetList(var aNodePositionLinks:TNode.TNodePositionLinks;const aCountCodePoints:TpvSizeInt);
              procedure InsertAt(var aNodePositionLinks:TNode.TNodePositionLinks;const aCodeUnits:PAnsiChar;const aCountCodeUnits,aCountCodePoints:TpvSizeInt);
              procedure InsertAtNodePosition(const aNode:TNode;var aNodePositionLinks:TNode.TNodePositionLinks;const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt);
              procedure DeleteAtNodePosition(const aNode:TNode;var aNodePositionLinks:TNode.TNodePositionLinks;const aCountCodePoints:TpvSizeInt);
              function ExtractAtNodePosition(const aNode:TNode;var aNodePositionLinks:TNode.TNodePositionLinks;const aCountCodePoints:TpvSizeInt):TpvUTF8String;
             public
              constructor Create; reintroduce; overload;
              constructor Create(const aCodeUnits:TpvUTF8String); reintroduce; overload;
              constructor Create(const aFrom:TRope); reintroduce; overload;
              destructor Destroy; override;
              procedure Clear;
              function GetNodeAndOffsetFromCodePointIndex(const aCodePointIndex:TpvSizeInt;out aNode:TNode;out aNodeCodeUnitIndex:TpvSizeInt):boolean;
              procedure Insert(const aCodePointIndex:TpvSizeInt;const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt); overload;
              procedure Insert(const aCodePointIndex:TpvSizeInt;const aCodeUnits:TpvUTF8String); overload;
              procedure Delete(const aCodePointIndex,aCountCodePoints:TpvSizeInt);
              function Extract(const aCodePointIndex,aCountCodePoints:TpvSizeInt):TpvUTF8String;
              function GetCodePoint(const aCodePointIndex:TpvSizeInt):TpvUInt32;
              function GetEnumerator:TNodeEnumerator;
              function GetCodePointEnumeratorSource(const aStartCodePointIndex:TpvSizeInt=0;const aStopCodePointIndex:TpvSizeInt=-1):TRope.TCodePointEnumeratorSource;
              procedure Check;
              procedure Dump;
              property CountCodePoints:TpvSizeInt read fCountCodePoints;
              property CountCodeUnits:TpvSizeInt read fCountCodeUnits;
              property Text:TpvUTF8String read GetText write SetText;
            end;
            TLineCacheMap=class
             public
              type TLine=TpvSizeInt;
                   PLine=^TLine;
                   TLines=array of TLine;
             private
              fRope:TRope;
              fLines:TLines;
              fCountLines:TpvSizeInt;
              fLineWrap:TpvSizeInt;
              fTabWidth:TpvSizeInt;
              fCountVisibleVisualCodePointsSinceNewLine:TpvSizeInt;
              fCodePointIndex:TpvSizeInt;
              fLastWasPossibleNewLineTwoCharSequence:boolean;
              fLastCodePoint:TpvUInt32;
              procedure SetLineWrap(const aLineWrap:TpvSizeInt);
              procedure SetTabWidth(const aTabWidth:TpvSizeInt);
              procedure AddLine(const aCodePointIndex:TpvSizeInt);
             public
              constructor Create(const aRope:TRope); reintroduce;
              destructor Destroy; override;
              procedure Reset;
              procedure Truncate(const aUntilCodePoint,aUntilLine:TpvSizeInt);
              procedure Update(const aUntilCodePoint,aUntilLine:TpvSizeInt);
              function GetLineIndexFromCodePointIndex(const aCodePointIndex:TpvSizeInt):TpvSizeInt;
              function GetLineIndexAndColumnIndexFromCodePointIndex(const aCodePointIndex:TpvSizeInt;out aLineIndex,aColumnIndex:TpvSizeInt):boolean;
              function GetCodePointIndexFromLineIndex(const aLineIndex:TpvSizeInt):TpvSizeInt;
              function GetCodePointIndexFromNextLineIndexOrTextEnd(const aLineIndex:TpvSizeInt):TpvSizeInt;
              function GetCodePointIndexFromLineIndexAndColumnIndex(const aLineIndex,aColumnIndex:TpvSizeInt):TpvSizeInt;
             published
              property CountLines:TpvSizeInt read fCountLines;
              property LineWrap:TpvSizeInt read fLineWrap write SetLineWrap;
              property TabWidth:TpvSizeInt read fTabWidth write SetTabWidth;
            end;
            TCoordinate=record
             public
              x:TpvSizeInt;
              y:TpvSizeInt;
            end;
            PCoordinate=^TCoordinate;
            TLineColumn=record
             public
              Line:TpvSizeInt;
              Column:TpvSizeInt;
            end;
            PLineColumn=^TLineColumn;
            TMarkState=record
             public
              StartCodePointIndex:TpvSizeInt;
              EndCodePointIndex:TpvSizeInt;
            end;
            PMarkState=^TMarkState;
            TView=class;
            TUndoRedoCommand=class;
            TUndoRedoCommandClass=class of TUndoRedoCommand;
            TUndoRedoCommand=class
             private
              fParent:TpvTextEditor;
              fUndoCursorCodePointIndex:TpvSizeInt;
              fRedoCursorCodePointIndex:TpvSizeInt;
              fUndoMarkState:TMarkState;
              fRedoMarkState:TMarkState;
              fSealed:boolean;
              fActionID:TpvUInt64;
             public
              constructor Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState); reintroduce; virtual;
              destructor Destroy; override;
              procedure Undo(const aView:TpvTextEditor.TView=nil); virtual;
              procedure Redo(const aView:TpvTextEditor.TView=nil); virtual;
            end;
            TUndoRedoCommandInsert=class(TUndoRedoCommand)
             private
              fCodePointIndex:TpvSizeInt;
              fCountCodePoints:TpvSizeInt;
              fCodeUnits:TpvUTF8String;
             public
              constructor Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState;const aCodePointIndex,aCountCodePoints:TpvSizeInt;const aCodeUnits:TpvUTF8String); reintroduce;
              destructor Destroy; override;
              procedure Undo(const aView:TpvTextEditor.TView=nil); override;
              procedure Redo(const aView:TpvTextEditor.TView=nil); override;
            end;
            TUndoRedoCommandOverwrite=class(TUndoRedoCommand)
             private
              fCodePointIndex:TpvSizeInt;
              fCountCodePoints:TpvSizeInt;
              fCodeUnits:TpvUTF8String;
              fPreviousCodeUnits:TpvUTF8String;
             public
              constructor Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState;const aCodePointIndex,aCountCodePoints:TpvSizeInt;const aCodeUnits,aPreviousCodeUnits:TpvUTF8String); reintroduce;
              destructor Destroy; override;
              procedure Undo(const aView:TpvTextEditor.TView=nil); override;
              procedure Redo(const aView:TpvTextEditor.TView=nil); override;
            end;
            TUndoRedoCommandDelete=class(TUndoRedoCommand)
             private
              fCodePointIndex:TpvSizeInt;
              fCountCodePoints:TpvSizeInt;
              fCodeUnits:TpvUTF8String;
             public
              constructor Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState;const aCodePointIndex,aCountCodePoints:TpvSizeInt;const aCodeUnits:TpvUTF8String); reintroduce;
              destructor Destroy; override;
              procedure Undo(const aView:TpvTextEditor.TView=nil); override;
              procedure Redo(const aView:TpvTextEditor.TView=nil); override;
            end;
            TUndoRedoCommandGroup=class(TUndoRedoCommand)
             private
              fClass:TUndoRedoCommandClass;
              fList:TObjectList;
             public
              constructor Create(const aParent:TpvTextEditor;const aClass:TUndoRedoCommandClass); reintroduce;
              destructor Destroy; override;
              procedure Undo(const aView:TpvTextEditor.TView=nil); override;
              procedure Redo(const aView:TpvTextEditor.TView=nil); override;
            end;
            TUndoRedoManager=class(TObjectList)
             private
              fParent:TpvTextEditor;
              fHistoryIndex:TpvSizeInt;
              fMaxUndoSteps:TpvSizeInt;
              fMaxRedoSteps:TpvSizeInt;
              fActionID:TpvUInt64;
             public
              constructor Create(const aParent:TpvTextEditor); reintroduce;
              destructor Destroy; override;
              procedure Clear; reintroduce;
              procedure IncreaseActionID;
              procedure Add(const aUndoRedoCommand:TpvTextEditor.TUndoRedoCommand); reintroduce;
              procedure GroupUndoRedoCommands(const aFromIndex,aToIndex:TpvSizeInt);
              procedure Undo(const aView:TpvTextEditor.TView=nil);
              procedure Redo(const aView:TpvTextEditor.TView=nil);
             published
              property HistoryIndex:TpvSizeInt read fHistoryIndex write fHistoryIndex;
              property MaxUndoSteps:TpvSizeInt read fMaxUndoSteps write fMaxUndoSteps;
              property MaxRedoSteps:TpvSizeInt read fMaxRedoSteps write fMaxRedoSteps;
            end;
            TSyntaxHighlighting=class
             public
              type TAttributes=class
                    public
                     const Unknown=0;
                           WhiteSpace=1;
                           Preprocessor=2;
                           Comment=3;
                           Keyword=4;
                           Type_=5;
                           Builtin=6;
                           Identifier=7;
                           Number=8;
                           Symbol=9;
                           String_=10;
                           Delimiter=11;
                           Operator=12;
                   end;
                   TState=class
                    private
                     fCodePointIndex:TpvSizeInt;
                     fAttribute:TpvUInt32;
                    public
                     property CodePointIndex:TpvSizeInt read fCodePointIndex write fCodePointIndex;
                     property Attribute:TpvUInt32 read fAttribute write fAttribute;
                   end;
                   TStates=array of TState;
             private
              fParent:TpvTextEditor;
             protected
              fStates:TStates;
              fCountStates:TpvSizeInt;
              fCodePointIndex:TpvSizeInt;
              function GetStateIndexFromCodePointIndex(const aCodePointIndex:TpvSizeInt):TpvSizeInt;
             public
              constructor Create(const aParent:TpvTextEditor); reintroduce; virtual;
              destructor Destroy; override;
              procedure Reset; virtual;
              procedure Truncate(const aUntilCodePoint:TpvSizeInt); virtual;
              procedure Update(const aUntilCodePoint:TpvSizeInt); virtual;
             published
              property Parent:TpvTextEditor read fParent;
            end;
            TGenericSyntaxHighlighting=class(TSyntaxHighlighting)
             public
              type TState=class(TSyntaxHighlighting.TState);
             public
              procedure Update(const aUntilCodePoint:TpvSizeInt); override;
            end;
            TDFASyntaxHighlighting=class(TSyntaxHighlighting)
             public
              const KeywordCharSet=[#32..#127];
              type TCharSet=set of AnsiChar;
                   PCharSet=^TCharSet;
                   TNFA=class
                    private
                     fNext:TNFA;
                     fFrom:TpvUInt32;
                     fTo:TpvUInt32;
                     fSet:TCharSet;
                   end;
                   TNFAArray=array of TNFA;
                   TNFASetArray=array of TpvUInt32;
                   TNFASet=record
                    private
                     fSet:TNFASetArray;
                    public
                     constructor Create(const aValues:array of TpvUInt32);
                     class operator Add(const aSet:TNFASet;const aValue:TpvUInt32):TNFASet;
                     class operator Add(const aSet,aOtherSet:TNFASet):TNFASet;
                     class operator Subtract(const aSet:TNFASet;const aValue:TpvUInt32):TNFASet;
                     class operator Subtract(const aSet,aOtherSet:TNFASet):TNFASet;
                     class operator Multiply(const aSet,aOtherSet:TNFASet):TNFASet;
                     class operator BitwiseAnd(const aSet,aOtherSet:TNFASet):TNFASet;
                     class operator BitwiseOr(const aSet,aOtherSet:TNFASet):TNFASet;
                     class operator BitwiseXor(const aSet,aOtherSet:TNFASet):TNFASet;
                     class operator In(const aValue:TpvUInt32;const aSet:TNFASet):boolean;
                     class operator Equal(const aSet,aOtherSet:TNFASet):boolean;
                     class operator NotEqual(const aSet,aOtherSet:TNFASet):boolean;
                   end;
                   TAccept=class
                    public
                     type TFlag=
                           (
                            IsQuick,
                            IsEnd,
                            IsPreprocessor,
                            IsKeyword
                           );
                          PFlag=^TFlag;
                          TFlags=set of TFlag;
                          PFlags=^TFlags;
                    private
                     fNext:TAccept;
                     fFlags:TFlags;
                     fState:TpvUInt32;
                     fAttribute:TpvUInt32;
                   end;
                   TDFA=class
                    public
                     type TDFASet=array[AnsiChar] of TDFA;
                          PDFASet=^TDFASet;
                    private
                     fNext:TDFA;
                     fNumber:TpvSizeInt;
                     fNFASet:TNFASet;
                     fAccept:TAccept;
                     fAcceptEnd:TAccept;
                     fWhereTo:TDFASet;
                   end;
                   TDFAArray=array of TDFA;
                   TEquivalence=array[AnsiChar] of AnsiChar;
                   PEquivalence=^TEquivalence;
                   EParserError=class(Exception);
                   EParserErrorExpectedEndOfText=class(EParserError);
                   EParserErrorUnexpectedEndOfText=class(EParserError);
                   EParserErrorExpectedRightParen=class(EParserError);
                   EParserErrorExpectedRightBracket=class(EParserError);
                   EParserErrorEmptySet=class(EParserError);
                   EParserErrorInvalidMetaChar=class(EParserError);
                   TKeyword=record
                    private
                     fKeyword:TpvRawByteString;
                     fAttribute:TpvUInt32;
                   end;
                   PKeyword=^TKeyword;
                   TKeywords=array of TKeyword;
                   TKeywordCharSet=#32..#127;
                   TKeywordCharTreeNode=class
                    public
                     type TKeywordCharTreeNodes=array[TKeywordCharSet] of TKeywordCharTreeNode;
                    private
                     fChildren:TKeywordCharTreeNodes;
                     fHasChildren:boolean;
                     fKeyword:boolean;
                     fAttribute:TpvUInt32;
                    public
                     constructor Create; reintroduce;
                     destructor Destroy; override;
                   end;
                   TState=class(TSyntaxHighlighting.TState)
                    private
                     fAccept:TAccept;
                   end;
             private
              fNFAStates:TpvSizeInt;
              fDFAStates:TpvSizeInt;
              fNFA:TNFA;
              fDFA:TDFA;
              fAccept:TAccept;
              fEquivalence:TEquivalence;
              fKeywordCharRootTreeNode:TKeywordCharTreeNode;
              fCaseInsensitive:boolean;
              procedure Clear;
              procedure BuildDFA;
             protected
              procedure Setup; virtual;
             public
              constructor Create(const aParent:TpvTextEditor); override;
              destructor Destroy; override;
              procedure AddKeyword(const aKeyword:TpvRawByteString;const aAttribute:TpvUInt32);
              procedure AddKeywords(const aKeywords:array of TpvRawByteString;const aAttribute:TpvUInt32);
              procedure AddRule(const aRule:TpvRawByteString;const aFlags:TAccept.TFlags;const aAttribute:TpvUInt32);
              procedure Update(const aUntilCodePoint:TpvSizeInt); override;
            end;
            TPascalSyntaxHighlighting=class(TDFASyntaxHighlighting)
             protected
              procedure Setup; override;
             public
            end;
            TView=class
             public
              type TBufferItem=record
                    Attribute:TpvUInt32;
                    CodePoint:TpvUInt32;
                   end;
                   PBufferItem=^TBufferItem;
                   TBufferItems=array of TBufferItem;
             private
              fParent:TpvTextEditor;
              fPrevious:TView;
              fNext:TView;
              fVisibleAreaDirty:boolean;
              fVisibleAreaWidth:TpvSizeInt;
              fVisibleAreaHeight:TpvSizeInt;
              fNonScrollVisibleAreaWidth:TpvSizeInt;
              fNonScrollVisibleAreaHeight:TpvSizeInt;
              fCodePointIndex:TpvSizeInt;
              fCursorOffset:TCoordinate;
              fCursor:TCoordinate;
              fLineColumn:TLineColumn;
              fLineWrap:TpvSizeInt;
              fVisualLineCacheMap:TLineCacheMap;
              fBuffer:TBufferItems;
              fMarkState:TMarkState;
              procedure SetVisibleAreaWidth(const aVisibleAreaWidth:TpvSizeInt);
              procedure SetVisibleAreaHeight(const aVisibleAreaHeight:TpvSizeInt);
              procedure SetNonScrollVisibleAreaWidth(const aNonScrollVisibleAreaWidth:TpvSizeInt);
              procedure SetNonScrollVisibleAreaHeight(const aNonScrollVisibleAreaHeight:TpvSizeInt);
              procedure SetLineWrap(const aLineWrap:TpvSizeInt);
              procedure SetLineColumn(const aLineColumn:TLineColumn);
              function GetMarkStartCodePointIndex:TpvSizeInt;
              procedure SetMarkStartCodePointIndex(const aMarkStartCodePointIndex:TpvSizeInt);
              function GetMarkEndCodePointIndex:TpvSizeInt;
              procedure SetMarkEndCodePointIndex(const aMarkEndCodePointIndex:TpvSizeInt);
             public
              constructor Create(const aParent:TpvTextEditor); reintroduce;
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure ClampMarkCodePointIndices;
              procedure EnsureCodePointIndexIsInRange;
              procedure EnsureCursorIsVisible(const aUpdateCursor:boolean=true;const aForceVisibleLines:TpvSizeInt=1);
              procedure UpdateCursor;
              procedure UpdateBuffer;
              procedure MarkAll;
              procedure UnmarkAll;
              procedure SetMarkStart;
              procedure SetMarkEndToHere;
              procedure SetMarkEndUntilHere;
              function HasMarkedRange:boolean;
              function GetMarkedRangeText:TpvUTF8String;
              function DeleteMarkedRange:boolean;
              function CutMarkedRangeText:TpvUTF8String;
              procedure InsertCodePoint(const aCodePoint:TpvUInt32;const aOverwrite:boolean;const aStealIt:boolean=false);
              procedure InsertString(const aCodeUnits:TpvUTF8String;const aOverwrite:boolean;const aStealIt:boolean=false);
              procedure Backspace;
              procedure Paste(const aText:TpvUTF8String);
              procedure Delete;
              procedure Enter(const aOverwrite:boolean);
              procedure MoveUp;
              procedure MoveDown;
              procedure MoveLeft;
              procedure MoveRight;
              procedure MoveToLineBegin;
              procedure MoveToLineEnd;
              procedure MovePageUp;
              procedure MovePageDown;
              procedure InsertLine;
              procedure DeleteLine;
              procedure Undo;
              procedure Redo;
              property Buffer:TBufferItems read fBuffer;
              property Cursor:TCoordinate read fCursor;
              property LineColumn:TLineColumn read fLineColumn write SetLineColumn;
             published
              property VisibleAreaWidth:TpvSizeInt read fVisibleAreaWidth write SetVisibleAreaWidth;
              property VisibleAreaHeight:TpvSizeInt read fVisibleAreaHeight write SetVisibleAreaHeight;
              property NonScrollVisibleAreaWidth:TpvSizeInt read fNonScrollVisibleAreaWidth write SetNonScrollVisibleAreaWidth;
              property NonScrollVisibleAreaHeight:TpvSizeInt read fNonScrollVisibleAreaHeight write SetNonScrollVisibleAreaHeight;
              property LineWrap:TpvSizeInt read fLineWrap write SetLineWrap;
              property MarkStartCodePointIndex:TpvSizeInt read GetMarkStartCodePointIndex write SetMarkStartCodePointIndex;
              property MarkEndCodePointIndex:TpvSizeInt read GetMarkEndCodePointIndex write SetMarkEndCodePointIndex;
            end;
       const EmptyMarkState:TMarkState=(
              StartCodePointIndex:-1;
              EndCodePointIndex:-1;
             );
      private
       fRope:TRope;
       fLineCacheMap:TLineCacheMap;
       fFirstView:TView;
       fLastView:TView;
       fUndoRedoManager:TUndoRedoManager;
       fSyntaxHighlighting:TSyntaxHighlighting;
       fCountLines:TpvSizeInt;
       function GetCountLines:TpvSizeInt;
       function GetText:TpvUTF8String;
       procedure SetText(const aText:TpvUTF8String);
       function GetLine(const aLineIndex:TpvSizeInt):TpvUTF8String;
       procedure SetLine(const aLineIndex:TpvSizeInt;const aLine:TpvUTF8String);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       function IsCodePointNewLine(const aCodePointIndex:TpvSizeInt):boolean;
       function IsTwoCodePointNewLine(const aCodePointIndex:TpvSizeInt):boolean;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure LoadFromString(const aString:TpvRawByteString);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:string);
       function SaveToString:TpvUTF8String;
       function CreateView:TpvTextEditor.TView;
       procedure LineMapTruncate(const aUntilCodePoint,aUntilLine:TpvSizeInt);
       procedure LineMapUpdate(const aUntilCodePoint,aUntilLine:TpvSizeInt);
       procedure ResetLineCacheMaps;
       procedure ResetViewCodePointIndices;
       procedure ResetViewMarkCodePointIndices;
       procedure ClampViewMarkCodePointIndices;
       procedure UpdateViewCodePointIndices(const aCodePointIndex,aDelta:TpvSizeInt);
       procedure EnsureViewCodePointIndicesAreInRange;
       procedure EnsureViewCursorsAreVisible(const aUpdateCursors:boolean=true;const aForceVisibleLines:TpvSizeInt=1);
       procedure UpdateViewCursors;
       procedure Undo(const aView:TView=nil);
       procedure Redo(const aView:TView=nil);
      public
       property Lines[const aLineIndex:TpvSizeInt]:TpvUTF8String read GetLine write SetLine; default;
      published
       property Text:TpvUTF8String read GetText write SetText;
       property CountLines:TpvSizeInt read GetCountLines;
       property UndoRedoManager:TUndoRedoManager read fUndoRedoManager;
       property SyntaxHighlighting:TSyntaxHighlighting read fSyntaxHighlighting write fSyntaxHighlighting;
     end;

implementation

{$ifdef TpvTextEditorUsePUCU}
uses PUCU;
{$endif}

class function TpvTextEditor.TUTF8Utils.UTF32CharToUTF8(const aCodePoint:TpvUInt32):TpVUTF8String;
var Data:array[0..3] of AnsiChar;
    ResultLen:TpvInt32;
begin
 if aCodePoint=0 then begin
  result:=#0;
 end else begin
  if aCodePoint<=$7f then begin
   Data[0]:=AnsiChar(TpvUInt8(aCodePoint));
   ResultLen:=1;
  end else if aCodePoint<=$7ff then begin
   Data[0]:=AnsiChar(TpvUInt8($c0 or ((aCodePoint shr 6) and $1f)));
   Data[1]:=AnsiChar(TpvUInt8($80 or (aCodePoint and $3f)));
   ResultLen:=2;
  end else if aCodePoint<=$d7ff then begin
   Data[0]:=AnsiChar(TpvUInt8($e0 or ((aCodePoint shr 12) and $0f)));
   Data[1]:=AnsiChar(TpvUInt8($80 or ((aCodePoint shr 6) and $3f)));
   Data[2]:=AnsiChar(TpvUInt8($80 or (aCodePoint and $3f)));
   ResultLen:=3;
  end else if aCodePoint<=$dfff then begin
   Data[0]:=#$ef; // $fffd
   Data[1]:=#$bf;
   Data[2]:=#$bd;
   ResultLen:=3;
  end else if aCodePoint<=$ffff then begin
   Data[0]:=AnsiChar(TpvUInt8($e0 or ((aCodePoint shr 12) and $0f)));
   Data[1]:=AnsiChar(TpvUInt8($80 or ((aCodePoint shr 6) and $3f)));
   Data[2]:=AnsiChar(TpvUInt8($80 or (aCodePoint and $3f)));
   ResultLen:=3;
  end else if aCodePoint<=$1fffff then begin
   Data[0]:=AnsiChar(TpvUInt8($f0 or ((aCodePoint shr 18) and $07)));
   Data[1]:=AnsiChar(TpvUInt8($80 or ((aCodePoint shr 12) and $3f)));
   Data[2]:=AnsiChar(TpvUInt8($80 or ((aCodePoint shr 6) and $3f)));
   Data[3]:=AnsiChar(TpvUInt8($80 or (aCodePoint and $3f)));
   ResultLen:=4;
  end else begin
   Data[0]:=#$ef; // $fffd
   Data[1]:=#$bf;
   Data[2]:=#$bd;
   ResultLen:=3;
  end;
  SetString(result,PAnsiChar(@Data[0]),ResultLen);
 end;
end;

class function TpvTextEditor.TUTF8Utils.UTF8Validate(const aString:TpvUTF8String):boolean;
var Index:TpvSizeInt;
    State:TpvUInt32;
begin
 State:=TUTF8DFA.StateAccept;
 for Index:=1 to length(aString) do begin
  State:=TUTF8DFA.StateTransitions[State+TUTF8DFA.StateCharClasses[aString[Index]]];
  if State=TUTF8DFA.StateError then begin
   break;
  end;
 end;
 result:=State=TUTF8DFA.StateAccept;
end;

class function TpvTextEditor.TUTF8Utils.UTF8Correct(const aString:TpvUTF8String):TpvUTF8String;
var CodeUnit,Len,ResultLen:TpvSizeInt;
    StartCodeUnit,Value,CharClass,State,CharValue:TpvUInt32;
    Data:PAnsiChar;
begin
 if (length(aString)=0) or UTF8Validate(aString) then begin
  result:=aString;
 end else begin
  result:='';
  CodeUnit:=1;
  Len:=length(aString);
  SetLength(result,Len*4);
  Data:=@result[1];
  ResultLen:=0;
  while CodeUnit<=Len do begin
   StartCodeUnit:=CodeUnit;
   State:=TUTF8DFA.StateAccept;
   CharValue:=0;
   while CodeUnit<=Len do begin
    Value:=ord(aString[CodeUnit]);
    inc(CodeUnit);
    CharClass:=TUTF8DFA.StateCharClasses[AnsiChar(UInt8(Value))];
    if State=TUTF8DFA.StateAccept then begin
     CharValue:=Value and ($ff shr CharClass);
    end else begin
     CharValue:=(CharValue shl 6) or (Value and $3f);
    end;
    State:=TUTF8DFA.StateTransitions[State+CharClass];
    if State<=TUTF8DFA.StateError then begin
     break;
    end;
   end;
   if State<>TUTF8DFA.StateAccept then begin
    CharValue:=ord(aString[StartCodeUnit]);
    CodeUnit:=StartCodeUnit+1;
   end;
   if CharValue<=$7f then begin
    Data[ResultLen]:=AnsiChar(TpvUInt8(CharValue));
    inc(ResultLen);
   end else if CharValue<=$7ff then begin
    Data[ResultLen]:=AnsiChar(TpvUInt8($c0 or ((CharValue shr 6) and $1f)));
    Data[ResultLen+1]:=AnsiChar(TpvUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,2);
   end else if CharValue<=$d7ff then begin
    Data[ResultLen]:=AnsiChar(TpvUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=AnsiChar(TpvUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=AnsiChar(TpvUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$dfff then begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
   end else if CharValue<=$ffff then begin
    Data[ResultLen]:=AnsiChar(TpvUInt8($e0 or ((CharValue shr 12) and $0f)));
    Data[ResultLen+1]:=AnsiChar(TpvUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+2]:=AnsiChar(TpvUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,3);
   end else if CharValue<=$1fffff then begin
    Data[ResultLen]:=AnsiChar(TpvUInt8($f0 or ((CharValue shr 18) and $07)));
    Data[ResultLen+1]:=AnsiChar(TpvUInt8($80 or ((CharValue shr 12) and $3f)));
    Data[ResultLen+2]:=AnsiChar(TpvUInt8($80 or ((CharValue shr 6) and $3f)));
    Data[ResultLen+3]:=AnsiChar(TpvUInt8($80 or (CharValue and $3f)));
    inc(ResultLen,4);
   end else begin
    Data[ResultLen]:=#$ef; // $fffd
    Data[ResultLen+1]:=#$bf;
    Data[ResultLen+2]:=#$bd;
    inc(ResultLen,3);
   end;
  end;
  SetLength(result,ResultLen);
 end;
end;

class function TpvTextEditor.TUTF8Utils.RawDataToUTF8String(const aData;const aDataLength:TpvInt32;const aCodePage:TpvInt32=-1):TpvUTF8String;
type TBytes=array[0..65535] of TpvUInt8;
     PBytes=^TBytes;
var Bytes:PBytes;
    BytesPerCodeUnit,BytesPerCodeUnitMask,StartCodeUnit,CodeUnit,
    InputLen,OutputLen:TpvSizeInt;
    LittleEndianBigEndian,PassIndex,CodePoint,Temp:TpvUInt32;
    State,CharClass,Value:TpvUInt8;
{$ifdef TpvTextEditorUsePUCU}
    CodePage:PPUCUCharSetCodePage;
    SubCodePages:PPUCUCharSetSubCodePages;
    SubSubCodePages:PPUCUCharSetSubSubCodePages;
{$endif}
begin
{$ifdef TpvTextEditorUsePUCU}
 begin
  CodePage:=nil;
  if (aCodePage>=0) and (aCodePage<=65535) then begin
   SubCodePages:=PUCUCharSetCodePages[(aCodePage shr 8) and $ff];
   if assigned(SubCodePages) then begin
    SubSubCodePages:=SubCodePages^[(aCodePage shr 4) and $f];
    if assigned(SubSubCodePages) then begin
     CodePage:=SubSubCodePages^[(aCodePage shr 0) and $f];
    end;
   end;
  end;
 end;
{$endif}
 result:='';
 Bytes:=@aData;
 if aCodePage=cpUTF16LE then begin
  // UTF16 little endian (per code page)
  BytesPerCodeUnit:=2;
  BytesPerCodeUnitMask:=1;
  LittleEndianBigEndian:=0;
  if (aDataLength>=2) and
     ((Bytes^[0]=$ff) and (Bytes^[1]=$fe)) then begin
   Bytes:=@Bytes^[2];
   InputLen:=aDataLength-2;
  end else begin
   Bytes:=@Bytes^[0];
   InputLen:=aDataLength;
  end;
 end else if aCodePage=cpUTF16BE then begin
  // UTF16 big endian (per code page)
  BytesPerCodeUnit:=2;
  BytesPerCodeUnitMask:=1;
  LittleEndianBigEndian:=1;
  if (aDataLength>=2) and
     ((Bytes^[0]=$fe) and (Bytes^[1]=$ff)) then begin
   Bytes:=@Bytes^[2];
   InputLen:=aDataLength-2;
  end else begin
   Bytes:=@Bytes^[0];
   InputLen:=aDataLength;
  end;
 end else if aCodePage=cpUTF7 then begin
  // UTF7 (per code page)
  raise Exception.Create('UTF-7 not supported');
 end else if aCodePage=cpUTF8 then begin
  // UTF8 (per code page)
  BytesPerCodeUnit:=1;
  BytesPerCodeUnitMask:=0;
  LittleEndianBigEndian:=0;
  if (aDataLength>=3) and (Bytes^[0]=$ef) and (Bytes^[1]=$bb) and (Bytes^[2]=$bf) then begin
   Bytes:=@Bytes^[3];
   InputLen:=aDataLength-3;
  end else begin
   Bytes:=@Bytes^[0];
   InputLen:=aDataLength;
  end;
{$ifdef TpvTextEditorUsePUCU}
 end else if assigned(CodePage) then begin
  // Code page
  BytesPerCodeUnit:=0;
  BytesPerCodeUnitMask:=0;
  LittleEndianBigEndian:=0;
  Bytes:=@Bytes^[0];
  InputLen:=aDataLength;
{$endif}
 end else if (aDataLength>=3) and (Bytes^[0]=$ef) and (Bytes^[1]=$bb) and (Bytes^[2]=$bf) then begin
  // UTF8
  BytesPerCodeUnit:=1;
  BytesPerCodeUnitMask:=0;
  LittleEndianBigEndian:=0;
  Bytes:=@Bytes^[3];
  InputLen:=aDataLength-3;
 end else if (aDataLength>=4) and
             (((Bytes^[0]=$00) and (Bytes^[1]=$00) and (Bytes^[2]=$fe) and (Bytes^[3]=$ff)) or
              ((Bytes^[0]=$ff) and (Bytes^[1]=$fe) and (Bytes^[2]=$00) and (Bytes^[3]=$00))) then begin
  // UTF32
  BytesPerCodeUnit:=4;
  BytesPerCodeUnitMask:=3;
  if Bytes^[0]=$00 then begin
   // Big endian
   LittleEndianBigEndian:=1;
  end else begin
   // Little endian
   LittleEndianBigEndian:=0;
  end;
  Bytes:=@Bytes^[4];
  InputLen:=aDataLength-4;
 end else if (aDataLength>=2) and
             (((Bytes^[0]=$fe) and (Bytes^[1]=$ff)) or
              ((Bytes^[0]=$ff) and (Bytes^[1]=$fe))) then begin
  // UTF16
  BytesPerCodeUnit:=2;
  BytesPerCodeUnitMask:=1;
  if Bytes^[0]=$fe then begin
   // Big endian
   LittleEndianBigEndian:=1;
  end else begin
   // Little endian
   LittleEndianBigEndian:=0;
  end;
  Bytes:=@Bytes^[2];
  InputLen:=aDataLength-2;
 end else begin
  // Latin1
  BytesPerCodeUnit:=0;
  BytesPerCodeUnitMask:=0;
  LittleEndianBigEndian:=0;
  Bytes:=@Bytes^[0];
  InputLen:=aDataLength;
 end;
 for PassIndex:=0 to 1 do begin
  CodeUnit:=0;
  OutputLen:=0;
  while (CodeUnit+BytesPerCodeUnitMask)<InputLen do begin
   case BytesPerCodeUnit of
    1:begin
     // UTF8
     CodePoint:=0;
     if (CodeUnit>=0) and (CodeUnit<InputLen) then begin
      StartCodeUnit:=CodeUnit;
      State:=TUTF8DFA.StateAccept;
      repeat
       Value:=ord(Bytes^[CodeUnit]);
       inc(CodeUnit);
       CharClass:=TUTF8DFA.StateCharClasses[AnsiChar(TpvUInt8(Value))];
       if State=TUTF8DFA.StateAccept then begin
        CodePoint:=Value and ($ff shr CharClass);
       end else begin
        CodePoint:=(CodePoint shl 6) or (Value and $3f);
       end;
       State:=TUTF8DFA.StateTransitions[State+CharClass];
      until (State<=TUTF8DFA.StateError) or (CodeUnit>=InputLen);
      if State<>TUTF8DFA.StateAccept then begin
       CodePoint:=ord(Bytes^[StartCodeUnit]);
       CodeUnit:=StartCodeUnit+1;
      end;
     end;
    end;
    2:begin
     // UTF16
     CodePoint:=(TpvUInt32(Bytes^[CodeUnit+0]) shl UTF16LittleEndianBigEndianShifts[LittleEndianBigEndian,0]) or
                (TpvUInt32(Bytes^[CodeUnit+1]) shl UTF16LittleEndianBigEndianShifts[LittleEndianBigEndian,1]);
     inc(CodeUnit,2);
     if ((CodeUnit+1)<InputLen) and ((CodePoint and $fc00)=$d800) then begin
      Temp:=(TpvUInt32(Bytes^[CodeUnit+0]) shl UTF16LittleEndianBigEndianShifts[LittleEndianBigEndian,0]) or
            (TpvUInt32(Bytes^[CodeUnit+1]) shl UTF16LittleEndianBigEndianShifts[LittleEndianBigEndian,1]);
      if (Temp and $fc00)=$dc00 then begin
       CodePoint:=(TpvUInt32(TpvUInt32(CodePoint and $3ff) shl 10) or TpvUInt32(Temp and $3ff))+$10000;
       inc(CodeUnit,2);
      end;
     end;
    end;
    4:begin
     // UTF32
     CodePoint:=(TpvUInt32(Bytes^[CodeUnit+0]) shl UTF32LittleEndianBigEndianShifts[LittleEndianBigEndian,0]) or
                (TpvUInt32(Bytes^[CodeUnit+1]) shl UTF32LittleEndianBigEndianShifts[LittleEndianBigEndian,1]) or
                (TpvUInt32(Bytes^[CodeUnit+2]) shl UTF32LittleEndianBigEndianShifts[LittleEndianBigEndian,2]) or
                (TpvUInt32(Bytes^[CodeUnit+3]) shl UTF32LittleEndianBigEndianShifts[LittleEndianBigEndian,3]);
     inc(CodeUnit,4);
    end;
    else begin
     // Latin1 or custom code page
     CodePoint:=Bytes^[CodeUnit];
     inc(CodeUnit);
{$ifdef TpvTextEditorUsePUCU}
     if assigned(CodePage) then begin
      CodePoint:=CodePage^[CodePoint and $ff];
     end;
{$endif}
    end;
   end;
   if PassIndex=0 then begin
    if CodePoint<=$7f then begin
     inc(OutputLen);
    end else if CodePoint<=$7ff then begin
     inc(OutputLen,2);
    end else if CodePoint<=$ffff then begin
     inc(OutputLen,3);
    end else if CodePoint<=$1fffff then begin
     inc(OutputLen,4);
    end else begin
     inc(OutputLen,3);
    end;
   end else begin
    if CodePoint<=$7f then begin
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8(CodePoint));
    end else if CodePoint<=$7ff then begin
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($c0 or ((CodePoint shr 6) and $1f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or (CodePoint and $3f)));
    end else if CodePoint<=$d7ff then begin
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($e0 or ((CodePoint shr 12) and $0f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or ((CodePoint shr 6) and $3f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or (CodePoint and $3f)));
    end else if CodePoint<=$dfff then begin
     inc(OutputLen);
     result[OutputLen]:=#$ef; // $fffd
     inc(OutputLen);
     result[OutputLen]:=#$bf;
     inc(OutputLen);
     result[OutputLen]:=#$bd;
    end else if CodePoint<=$ffff then begin
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($e0 or ((CodePoint shr 12) and $0f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or ((CodePoint shr 6) and $3f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or (CodePoint and $3f)));
    end else if CodePoint<=$1fffff then begin
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($f0 or ((CodePoint shr 18) and $07)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or ((CodePoint shr 12) and $3f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or ((CodePoint shr 6) and $3f)));
     inc(OutputLen);
     result[OutputLen]:=AnsiChar(TpvUInt8($80 or (CodePoint and $3f)));
    end else begin
     inc(OutputLen);
     result[OutputLen]:=#$ef; // $fffd
     inc(OutputLen);
     result[OutputLen]:=#$bf;
     inc(OutputLen);
     result[OutputLen]:=#$bd;
    end;
   end;
  end;
  if PassIndex=0 then begin
   SetLength(result,OutputLen);
  end;
 end;
end;

class function TpvTextEditor.TUTF8Utils.RawByteStringToUTF8String(const aString:TpvRawByteString;const aCodePage:TpvInt32=-1):TpvUTF8String;
var p:PAnsiChar;
begin
 if length(aString)>0 then begin
  p:=PAnsiChar(@aString[1]);
  result:=RawDataToUTF8String(p^,length(aString),aCodePage);
 end else begin
  result:='';
 end;
end;

class function TpvTextEditor.TUTF8Utils.RawStreamToUTF8String(const aStream:TStream;const aCodePage:TpvInt32=-1):TpvUTF8String;
var Memory:pointer;
    Size:TpvSizeInt;
begin
 result:='';
 if assigned(aStream) and (aStream.Seek(0,soBeginning)=0) then begin
  Size:=aStream.Size;
  GetMem(Memory,Size);
  try
   if aStream.Read(Memory^,Size)=Size then begin
    result:=RawDataToUTF8String(Memory^,Size,aCodePage);
   end;
  finally
   FreeMem(Memory);
  end;
 end;
end;

constructor TpvTextEditor.TRope.TNode.Create(const aHeight:TpvInt32);
begin
 inherited Create;
 fHeight:=aHeight;
 fCountCodeUnits:=0;
 SetLength(fLinks,MaximumHeight+1);
 fLinks[0].fNode:=nil;
 fLinks[0].fSkipSize:=0;
end;

destructor TpvTextEditor.TRope.TNode.Destroy;
begin
 inherited Destroy;
end;

function TpvTextEditor.TRope.TNode.GetData:TpvUTF8String;
begin
 SetString(result,PAnsiChar(@fData[0]),fCountCodeUnits);
end;

constructor TpvTextEditor.TRope.TNodeEnumerator.Create(const aCodeUnitsRope:TRope);
begin
 fRope:=aCodeUnitsRope;
 fFirst:=true;
 fNode:=fRope.fHead;
end;

function TpvTextEditor.TRope.TNodeEnumerator.GetCurrent:TNode;
begin
 result:=fNode;
end;

function TpvTextEditor.TRope.TNodeEnumerator.MoveNext:boolean;
begin
 result:=assigned(fNode);
 if result then begin
  if fFirst then begin
   fFirst:=false;
  end else begin
   fNode:=fNode.fLinks[0].fNode;
   result:=assigned(fNode);
  end;
 end;
end;

constructor TpvTextEditor.TRope.TCodePointEnumerator.Create(const aCodeUnitsRope:TRope;const aStartCodePointIndex:TpvSizeInt=0;const aStopCodePointIndex:TpvSizeInt=-1);
begin
 fRope:=aCodeUnitsRope;
 fFirst:=true;
 fRope.GetNodeAndOffsetFromCodePointIndex(aStartCodePointIndex,fNode,fNodeCodeUnitIndex);
 fCodePointIndex:=aStartCodePointIndex;
 fStopCodePointIndex:=aStopCodePointIndex;
 fUTF8DFAState:=TUTF8DFA.StateAccept;
 fCodePoint:=0;
end;

function TpvTextEditor.TRope.TCodePointEnumerator.GetCurrent:TpvUInt32;
begin
 result:=fCodePoint;
end;

function TpvTextEditor.TRope.TCodePointEnumerator.CanMoveNext:boolean;
begin
 result:=assigned(fNode) and
         ((fStopCodePointIndex<0) or
          (fCodePointIndex<fStopCodePointIndex));
end;

function TpvTextEditor.TRope.TCodePointEnumerator.MoveNext:boolean;
var CodeUnit:AnsiChar;
begin
 result:=false;
 if assigned(fNode) and
    ((fStopCodePointIndex<0) or
     (fCodePointIndex<fStopCodePointIndex)) then begin
  repeat
   if fNodeCodeUnitIndex>=fNode.fCountCodeUnits then begin
    fNode:=fNode.fLinks[0].fNode;
    fNodeCodeUnitIndex:=0;
    if assigned(fNode) then begin
     continue;
    end else begin
     break;
    end;
   end else begin
    CodeUnit:=fNode.fData[fNodeCodeUnitIndex];
    inc(fNodeCodeUnitIndex);
    fUTF8DFACharClass:=TUTF8DFA.StateCharClasses[CodeUnit];
    case fUTF8DFAState of
     TUTF8DFA.StateAccept..TUTF8DFA.StateError:begin
      fCodePoint:=ord(CodeUnit) and ($ff shr fUTF8DFACharClass);
     end;
     else begin
      fCodePoint:=(fCodePoint shl 6) or (ord(CodeUnit) and $3f);
     end;
    end;
    fUTF8DFAState:=TUTF8DFA.StateTransitions[fUTF8DFAState+fUTF8DFACharClass];
    if fUTF8DFAState<=TUTF8DFA.StateError then begin
     if fUTF8DFAState<>TUTF8DFA.StateAccept then begin
      fCodePoint:=$fffd;
     end;
     inc(fCodePointIndex);
     result:=true;
     break;
    end;
   end;
  until false;
 end;
end;

constructor TpvTextEditor.TRope.TCodePointEnumeratorSource.Create(const aCodeUnitsRope:TRope;const aStartCodePointIndex:TpvSizeInt=0;const aStopCodePointIndex:TpvSizeInt=-1);
begin
 fRope:=aCodeUnitsRope;
 fStartCodePointIndex:=aStartCodePointIndex;
 fStopCodePointIndex:=aStopCodePointIndex;
end;

function TpvTextEditor.TRope.TCodePointEnumeratorSource.GetEnumerator:TRope.TCodePointEnumerator;
begin
 result:=TRope.TCodePointEnumerator.Create(fRope,fStartCodePointIndex,fStopCodePointIndex);
end;

constructor TpvTextEditor.TRope.TRandomGenerator.Create(const aSeed:TpvUInt64);
begin
 fState:=TpVUInt64($853c49e6748fea9b);
 fIncrement:=TpVUInt64($da3e39cb94b95bdb);
 if aSeed<>0 then begin
  fIncrement:=((fIncrement xor aSeed) shl 1) or 1; // must be odd
  GetUInt32;
  inc(fState,{$ifdef fpc}RORQWord(aSeed,23){$else}(aSeed shr 23) or (aSeed shl 41){$endif});
  GetUInt32;
 end;
end;

function TpvTextEditor.TRope.TRandomGenerator.GetUInt32:TpvUInt32;
var OldState:TpvUInt64;
{$ifndef fpc}
    XorShifted,Rotation:TpvUInt32;
{$endif}
begin
 OldState:=fState;
 fState:=(OldState*TpvUInt64(6364136223846793005))+fIncrement;
{$ifdef fpc}
 result:=RORDWord(TpvUInt32(((OldState shr 18) xor OldState) shr 27),OldState shr 59);
{$else}
 XorShifted:=((OldState shr 18) xor OldState) shr 27;
 Rotation:=OldState shr 59;
 result:=(XorShifted shr Rotation) or (XorShifted shl (32-Rotation));
{$endif}
end;

function TpvTextEditor.TRope.TRandomGenerator.GetUInt64:TpvUInt64;
begin
 result:=(TpvUInt64(GetUInt32) shl 32) or
         (TpvUInt64(GetUInt32) shl 0);
end;

constructor TpvTextEditor.TRope.Create;
begin
 inherited Create;
 fCountCodePoints:=0;
 fCountCodeUnits:=0;
 fHead:=TNode.Create(TNode.MaximumHeight);
 fHead.fHeight:=1;
 fRandomGenerator:=TRandomGenerator.Create(TpvPtrUInt(self));
end;

constructor TpvTextEditor.TRope.Create(const aCodeUnits:TpvUTF8String);
begin
 Create;
 SetText(aCodeUnits);
end;

constructor TpvTextEditor.TRope.Create(const aFrom:TRope);
begin
 Create(aFrom.GetText);
end;

destructor TpvTextEditor.TRope.Destroy;
var Node,NextNode:TNode;
begin
 Node:=fHead.fLinks[0].fNode;
 while assigned(Node) do begin
  NextNode:=Node.fLinks[0].fNode;
  Node.Free;
  Node:=NextNode;
 end;
 fHead.Free;
 inherited Destroy;
end;

procedure TpvTextEditor.TRope.Clear;
var Node,NextNode:TNode;
begin
 Node:=fHead.fLinks[0].fNode;
 while assigned(Node) do begin
  NextNode:=Node.fLinks[0].fNode;
  Node.Free;
  Node:=NextNode;
 end;
 fHead.Free;
 fCountCodePoints:=0;
 fCountCodeUnits:=0;
 fHead:=TNode.Create(TNode.MaximumHeight);
 fHead.fHeight:=1;
end;

function TpvTextEditor.TRope.GetText:TpvUTF8String;
var Position:TpvSizeInt;
    Node:TNode;
begin
 SetLength(result,fCountCodeUnits);
 if fCountCodeUnits>0 then begin
  Position:=1;
  Node:=fHead;
  while assigned(Node) do begin
   Move(Node.fData[0],result[Position],Node.fCountCodeUnits);
   inc(Position,Node.fCountCodeUnits);
   Node:=Node.fLinks[0].fNode;
  end;
{$if defined(DebugTpvUTF8StringRope)}
  Assert(Position=(fCountCodeUnits+1));
{$ifend}
 end;
end;

procedure TpvTextEditor.TRope.SetText(const aCodeUnits:TpvUTF8String);
begin
 Clear;
 Insert(0,aCodeUnits);
end;

{$ifdef fpc}
class function TpvTextEditor.TRope.FindFirstSetBit(aValue:TpvUInt64):TpvUInt32;
begin
 if aValue=0 then begin
  result:=255;
 end else begin
  result:=BSFQWord(aValue);
 end;
end;
{$else}
{$if defined(cpu386)}
class function TpvTextEditor.TRope.FindFirstSetBit(aValue:TpvUInt64):TpvUInt32; assembler; stdcall; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,dword ptr [aValue+0]
 jnz @Done
 bsf eax,dword ptr [aValue+4]
 jz @Fail
 add eax,32
 jmp @Done
@Fail:
 mov eax,255
@Done:
end;
{$elseif defined(cpuamd64) or defined(cpux64)}
class function TpvTextEditor.TRope.FindFirstSetBit(aValue:TpvUInt64):TpvUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 bsf rax,rcx
{$else}
 bsf rax,rdi
{$ifend}
 jnz @Done
 mov eax,255
@Done:
end;
{$else}
class function TpvTextEditor.TRope.FindFirstSetBit(aValue:TpvUInt64):TpvUInt32;
const DebruijnMultiplicator:TpvUInt64=TpvUInt64($03f79d71b4cb0a89);
      DebruijnShift=58;
      DebruijnMask=63;
      DebruijnTable:array[0..63] of TpvUInt32=(0,1,48,2,57,49,28,3,61,58,50,42,38,29,17,4,62,55,59,36,53,51,43,22,45,39,33,30,24,18,12,5,
                                               63,47,56,27,60,41,37,16,54,35,52,21,44,32,23,11,46,26,40,15,34,20,31,10,25,14,19,9,13,8,7,6);
begin
 if aValue=0 then begin
  result:=255;
 end else begin
  result:=DebruijnTable[(((aValue and not (aValue-1))*DebruijnMultiplicator) shr DebruijnShift) and DebruijnMask];
 end;
end;
{$ifend}
{$endif}

function TpvTextEditor.TRope.GetRandomHeight:TpvInt32;
begin
 result:=FindFirstSetBit(not (fRandomGenerator.GetUInt64 and TNode.MaximumHeightMinusTwoBitMask))+1;
 if result>TNode.MaximumHeightMinusOne then begin
  result:=TNode.MaximumHeightMinusOne;
 end;
end;

class function TpvTextEditor.TRope.GetCountCodeUnits(const aCodeUnits:PAnsiChar;const aCountCodePoints:TpvSizeInt):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=0;
 Index:=0;
 while Index<aCountCodePoints do begin
  inc(result,TUTF8DFA.CodePointSizes[aCodeUnits[result]]);
  inc(Index);
 end;
end;

class function TpvTextEditor.TRope.GetCountCodePoints(const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt):TpvSizeInt;
var Index:TpvSizeInt;
begin
 result:=0;
 Index:=0;
 while Index<aCountCodeUnits do begin
  inc(Index,TUTF8DFA.CodePointSizes[aCodeUnits[Index]]);
  inc(result);
 end;
end;

class procedure TpvTextEditor.TRope.UTF8Check(const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt);
var Index:TpvSizeInt;
    State:TpvUInt32;
begin
 State:=TUTF8DFA.StateAccept;
 for Index:=0 to aCountCodeUnits-1 do begin
  State:=TUTF8DFA.StateTransitions[State+TUTF8DFA.StateCharClasses[aCodeUnits[Index]]];
  if State=TUTF8DFA.StateError then begin
   break;
  end;
 end;
 if State<>TUTF8DFA.StateAccept then begin
  raise ERope.Create('Invalid UTF8');
 end;
end;

function TpvTextEditor.TRope.FindNodePositionAtCodePoint(const aCodePointIndex:TpvSizeInt;out aNodePositionLinks:TNode.TNodePositionLinks):TNode;
var Height:TpvInt32;
    Offset,Skip:TpvSizeInt;
begin
{$if defined(DebugTpvUTF8StringRope)}
 Assert(aCodePointIndex<=fCountCodePoints);
{$ifend}
 FillChar(aNodePositionLinks,SizeOf(TNode.TNodePositionLinks),#0);
 result:=fHead;
 Height:=result.fHeight-1;
 Offset:=aCodePointIndex;
 repeat
  Skip:=result.fLinks[Height].fSkipSize;
  if Skip<Offset then begin
{$if defined(DebugTpvUTF8StringRope)}
   Assert((result=fHead) or (result.fCountCodeUnits>0));
{$ifend}
   dec(Offset,Skip);
   result:=result.fLinks[Height].fNode;
  end else begin
   aNodePositionLinks[Height].fSkipSize:=Offset;
   aNodePositionLinks[Height].fNode:=result;
   if Height=0 then begin
    break;
   end else begin
    dec(Height);
   end;
  end;
 until false;
{$if defined(DebugTpvUTF8StringRope)}
 Assert(Offset<=TNode.StringSize);
 Assert(aNodePositionLinks[0].fNode=result);
{$ifend}
end;

function TpvTextEditor.TRope.GetNodeAndOffsetFromCodePointIndex(const aCodePointIndex:TpvSizeInt;out aNode:TNode;out aNodeCodeUnitIndex:TpvSizeInt):boolean;
var NodePositionLinks:TRope.TNode.TNodePositionLinks;
begin
 if (aCodePointIndex>=0) and
    (aCodePointIndex<fCountCodePoints) then begin
  if aCodePointIndex=0 then begin
   aNode:=fHead;
   aNodeCodeUnitIndex:=0;
   result:=true;
  end else begin
   aNode:=FindNodePositionAtCodePoint(aCodePointIndex,NodePositionLinks);
   if assigned(aNode) then begin
    aNodeCodeUnitIndex:=TRope.GetCountCodeUnits(@aNode.fData[0],NodePositionLinks[0].fSkipSize);
    result:=true;
   end else begin
    aNodeCodeUnitIndex:=0;
    result:=false;
   end;
  end;
 end else begin
  aNode:=nil;
  aNodeCodeUnitIndex:=0;
  result:=false;
 end;
end;

procedure TpvTextEditor.TRope.UpdateOffsetList(var aNodePositionLinks:TNode.TNodePositionLinks;const aCountCodePoints:TpvSizeInt);
var Index:TpvInt32;
begin
 for Index:=0 to fHead.fHeight-1 do begin
  inc(aNodePositionLinks[Index].fNode.fLinks[Index].fSkipSize,aCountCodePoints);
 end;
end;

procedure TpvTextEditor.TRope.InsertAt(var aNodePositionLinks:TNode.TNodePositionLinks;const aCodeUnits:PAnsiChar;const aCountCodeUnits,aCountCodePoints:TpvSizeInt);
var MaximumHeight,NewHeight,Index:TpvInt32;
    NewNode:TNode;
    PreviousNodeLink:TNode.PNodeLink;
begin

 MaximumHeight:=fHead.fHeight;

 NewHeight:=GetRandomHeight;

 NewNode:=TNode.Create(NewHeight);
 NewNode.fCountCodeUnits:=aCountCodeUnits;
 Move(aCodeUnits[0],NewNode.fData[0],aCountCodeUnits);

{$if defined(DebugTpvUTF8StringRope)}
 Assert(NewHeight<TNode.MaximumHeight);
{$ifend}

 while MaximumHeight<=NewHeight do begin
  inc(fHead.fHeight);
  fHead.fLinks[MaximumHeight]:=fHead.fLinks[MaximumHeight-1];
  aNodePositionLinks[MaximumHeight]:=aNodePositionLinks[MaximumHeight-1];
  inc(MaximumHeight);
 end;

 for Index:=0 to NewHeight-1 do begin
  PreviousNodeLink:=@aNodePositionLinks[Index].fNode.fLinks[Index];
  NewNode.fLinks[Index].fNode:=PreviousNodeLink^.fNode;
  NewNode.fLinks[Index].fSkipSize:=(aCountCodePoints+PreviousNodeLink^.fSkipSize)-aNodePositionLinks[Index].fSkipSize;
  PreviousNodeLink^.fNode:=NewNode;
  PreviousNodeLink^.fSkipSize:=aNodePositionLinks[Index].fSkipSize;
  aNodePositionLinks[Index].fNode:=NewNode;
  aNodePositionLinks[Index].fSkipSize:=aCountCodePoints;
 end;

 for Index:=NewHeight to MaximumHeight-1 do begin
  inc(aNodePositionLinks[Index].fNode.fLinks[Index].fSkipSize,aCountCodePoints);
  inc(aNodePositionLinks[Index].fSkipSize,aCountCodePoints);
 end;

 inc(fCountCodeUnits,aCountCodeUnits);
 inc(fCountCodePoints,aCountCodePoints);

end;

procedure TpvTextEditor.TRope.InsertAtNodePosition(const aNode:TNode;var aNodePositionLinks:TNode.TNodePositionLinks;const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt);
var OffsetCodeUnits,Offset,CountInsertedCodePoints,CountEndCodeUnits,
    CountEndCodePoints,StringOffset,CountNewNodeCodeUnits,CountNewNodeCodePoints,
    CodePointSize,CountInsertedCodeUnits:TpvSizeInt;
    InsertHere:boolean;
    Node,NextNode:TNode;
    Index:TpvInt32;
begin

 Offset:=aNodePositionLinks[0].fSkipSize;

 if Offset<>0 then begin
{$if defined(DebugTpvUTF8StringRope)}
  Assert(Offset<=aNode.fLinks[0].fSkipSize);
{$ifend}
  OffsetCodeUnits:=GetCountCodeUnits(@aNode.fData[0],Offset);
 end else begin
  OffsetCodeUnits:=0;
 end;

 CountInsertedCodeUnits:=aCountCodeUnits;

 UTF8Check(aCodeUnits,CountInsertedCodeUnits);

 InsertHere:=(aNode.fCountCodeUnits+CountInsertedCodeUnits)<=TNode.StringSize;

 Node:=aNode;

 if (OffsetCodeUnits=Node.fCountCodeUnits) and not InsertHere then begin
  NextNode:=Node.fLinks[0].fNode;
  if assigned(NextNode) and ((NextNode.fCountCodeUnits+CountInsertedCodeUnits)<=TNode.StringSize) then begin
   Offset:=0;
   OffsetCodeUnits:=0;
   for Index:=0 to NextNode.fHeight-1 do begin
    aNodePositionLinks[Index].fNode:=NextNode;
   end;
   Node:=NextNode;
   InsertHere:=true;
  end;
 end;

 if InsertHere then begin

  if OffsetCodeUnits<Node.fCountCodeUnits then begin
   Move(Node.fData[OffsetCodeUnits],
        Node.fData[OffsetCodeUnits+CountInsertedCodeUnits],
        Node.fCountCodeUnits-OffsetCodeUnits);
  end;

  Move(aCodeUnits[0],
       Node.fData[OffsetCodeUnits],
       CountInsertedCodeUnits);
  inc(Node.fCountCodeUnits,CountInsertedCodeUnits);

  inc(fCountCodeUnits,CountInsertedCodeUnits);

  CountInsertedCodePoints:=GetCountCodePoints(@aCodeUnits[0],aCountCodeUnits);

  inc(fCountCodePoints,CountInsertedCodePoints);

  UpdateOffsetList(aNodePositionLinks,CountInsertedCodePoints);

 end else begin

  CountEndCodeUnits:=Node.fCountCodeUnits-OffsetCodeUnits;

  if CountEndCodeUnits<>0 then begin
   Node.fCountCodeUnits:=OffsetCodeUnits;
   CountEndCodePoints:=Node.fLinks[0].fSkipSize-Offset;
   UpdateOffsetList(aNodePositionLinks,-CountEndCodePoints);
   dec(fCountCodePoints,CountEndCodePoints);
   dec(fCountCodeUnits,CountEndCodeUnits);
  end else begin
   CountEndCodePoints:=0;
  end;

  StringOffset:=0;
  while StringOffset<CountInsertedCodeUnits do begin
   CountNewNodeCodeUnits:=0;
   CountNewNodeCodePoints:=0;
   while (StringOffset+CountNewNodeCodeUnits)<CountInsertedCodeUnits do begin
    CodePointSize:=TUTF8DFA.CodePointSizes[aCodeUnits[StringOffset+CountNewNodeCodeUnits]];
    if (CodePointSize+CountNewNodeCodeUnits)<=TNode.StringSize then begin
     inc(CountNewNodeCodeUnits,CodePointSize);
     inc(CountNewNodeCodePoints);
    end else begin
     break;
    end;
   end;
   InsertAt(aNodePositionLinks,@aCodeUnits[StringOffset],CountNewNodeCodeUnits,CountNewNodeCodePoints);
   inc(StringOffset,CountNewNodeCodeUnits);
  end;

  if CountEndCodeUnits>0 then begin
   InsertAt(aNodePositionLinks,@Node.fData[OffsetCodeUnits],CountEndCodeUnits,CountEndCodePoints);
  end;

 end;

end;

procedure TpvTextEditor.TRope.DeleteAtNodePosition(const aNode:TNode;var aNodePositionLinks:TNode.TNodePositionLinks;const aCountCodePoints:TpvSizeInt);
var Offset,RemainingCodePoints,CodePointsToDo,CodePointsRemoved,
    LeadingCodeUnits,RemovedCodeUnits,TrailingCodeUnits:TpvSizeInt;
    Node,NextNode:TNode;
    Index:TpvInt32;
begin
 dec(fCountCodePoints,aCountCodePoints);
 Offset:=aNodePositionLinks[0].fSkipSize;
 RemainingCodePoints:=aCountCodePoints;
 Node:=aNode;
 while RemainingCodePoints>0 do begin
  if Offset=Node.fLinks[0].fSkipSize then begin
   Node:=aNodePositionLinks[0].fNode.fLinks[0].fNode;
   Offset:=0;
  end;
  CodePointsToDo:=Node.fLinks[0].fSkipSize;
  CodePointsRemoved:=CodePointsToDo-Offset;
  if CodePointsRemoved>RemainingCodePoints then begin
   CodePointsRemoved:=RemainingCodePoints;
  end;
  if (CodePointsRemoved<CodePointsToDo) or (Node=fHead) then begin
   LeadingCodeUnits:=GetCountCodeUnits(@Node.fData[0],Offset);
   RemovedCodeUnits:=GetCountCodeUnits(@Node.fData[LeadingCodeUnits],CodePointsRemoved);
   TrailingCodeUnits:=Node.fCountCodeUnits-(LeadingCodeUnits+RemovedCodeUnits);
   if TrailingCodeUnits>0 then begin
    Move(Node.fData[LeadingCodeUnits+RemovedCodeUnits],
         Node.fData[LeadingCodeUnits],
         TrailingCodeUnits);
   end;
   dec(Node.fCountCodeUnits,RemovedCodeUnits);
   dec(fCountCodeUnits,RemovedCodeUnits);
   Index:=0;
   while Index<Node.fHeight do begin
    dec(Node.fLinks[Index].fSkipSize,CodePointsRemoved);
    inc(Index);
   end;
  end else begin
   Index:=0;
   while Index<Node.fHeight do begin
    aNodePositionLinks[Index].fNode.fLinks[Index].fNode:=Node.fLinks[Index].fNode;
    inc(aNodePositionLinks[Index].fNode.fLinks[Index].fSkipSize,Node.fLinks[Index].fSkipSize-CodePointsRemoved);
    inc(Index);
   end;
   dec(fCountCodeUnits,Node.fCountCodeUnits);
   NextNode:=Node.fLinks[0].fNode;
   Node.Free;
   Node:=NextNode;
  end;
  while Index<fHead.fHeight do begin
   dec(aNodePositionLinks[Index].fNode.fLinks[Index].fSkipSize,CodePointsRemoved);
   inc(Index);
  end;
  dec(RemainingCodePoints,CodePointsRemoved);
 end;
end;

function TpvTextEditor.TRope.ExtractAtNodePosition(const aNode:TNode;var aNodePositionLinks:TNode.TNodePositionLinks;const aCountCodePoints:TpvSizeInt):TpvUTF8String;
var Offset,RemainingCodePoints,CodePointsToDo,CodePointsExtracted,
    LeadingCodeUnits,ExtractedCodeUnits:TpvSizeInt;
    Node:TNode;
    TemporaryString:TpvUTF8String;
begin
 result:='';
 Offset:=aNodePositionLinks[0].fSkipSize;
 RemainingCodePoints:=aCountCodePoints;
 Node:=aNode;
 while RemainingCodePoints>0 do begin
  if Offset=Node.fLinks[0].fSkipSize then begin
   Node:=aNodePositionLinks[0].fNode.fLinks[0].fNode;
   Offset:=0;
  end;
  CodePointsToDo:=Node.fLinks[0].fSkipSize;
  CodePointsExtracted:=CodePointsToDo-Offset;
  if CodePointsExtracted>RemainingCodePoints then begin
   CodePointsExtracted:=RemainingCodePoints;
  end;
  if (CodePointsExtracted<CodePointsToDo) or (Node=fHead) then begin
   LeadingCodeUnits:=GetCountCodeUnits(@Node.fData[0],Offset);
   ExtractedCodeUnits:=GetCountCodeUnits(@Node.fData[LeadingCodeUnits],CodePointsExtracted);
   SetString(TemporaryString,PAnsiChar(@Node.fData[LeadingCodeUnits]),ExtractedCodeUnits);
  end else begin
   SetString(TemporaryString,PAnsiChar(@Node.fData[0]),Node.fCountCodeUnits);
  end;
  result:=result+TemporaryString;
  Offset:=0;
  Node:=Node.fLinks[0].fNode;
  dec(RemainingCodePoints,CodePointsExtracted);
 end;
end;

procedure TpvTextEditor.TRope.Insert(const aCodePointIndex:TpvSizeInt;const aCodeUnits:PAnsiChar;const aCountCodeUnits:TpvSizeInt);
var Node:TNode;
    NodePositionLinks:TNode.TNodePositionLinks;
    CodePointIndex:TpvSizeInt;
begin
{$if defined(DebugTpvUTF8StringRope)}
 Check;
{$ifend}
 if aCodePointIndex<fCountCodePoints then begin
  CodePointIndex:=aCodePointIndex;
 end else begin
  CodePointIndex:=fCountCodePoints;
 end;
 Node:=FindNodePositionAtCodePoint(CodePointIndex,NodePositionLinks);
 InsertAtNodePosition(Node,NodePositionLinks,aCodeUnits,aCountCodeUnits);
{$if defined(DebugTpvUTF8StringRope)}
 Check;
{$ifend}
end;

procedure TpvTextEditor.TRope.Insert(const aCodePointIndex:TpvSizeInt;const aCodeUnits:TpvUTF8String);
begin
 Insert(aCodePointIndex,PAnsiChar(aCodeUnits),length(aCodeUnits));
end;

procedure TpvTextEditor.TRope.Delete(const aCodePointIndex,aCountCodePoints:TpvSizeInt);
var Node:TNode;
    NodePositionLinks:TNode.TNodePositionLinks;
    CodePointIndex,CountCodePoints:TpvSizeInt;
begin
{$if defined(DebugTpvUTF8StringRope)}
 Check;
{$ifend}
 if aCodePointIndex<fCountCodePoints then begin
  CodePointIndex:=aCodePointIndex;
 end else begin
  CodePointIndex:=fCountCodePoints;
 end;
 CountCodePoints:=fCountCodePoints-CodePointIndex;
 if CountCodePoints>aCountCodePoints then begin
  CountCodePoints:=aCountCodePoints;
 end;
 Node:=FindNodePositionAtCodePoint(CodePointIndex,NodePositionLinks);
 DeleteAtNodePosition(Node,NodePositionLinks,CountCodePoints);
{$if defined(DebugTpvUTF8StringRope)}
 Check;
{$ifend}
end;

function TpvTextEditor.TRope.Extract(const aCodePointIndex,aCountCodePoints:TpvSizeInt):TpvUTF8String;
var Node:TNode;
    NodePositionLinks:TNode.TNodePositionLinks;
    CodePointIndex,CountCodePoints:TpvSizeInt;
begin
{$if defined(DebugTpvUTF8StringRope)}
 Check;
{$ifend}
 if aCodePointIndex<fCountCodePoints then begin
  CodePointIndex:=aCodePointIndex;
 end else begin
  CodePointIndex:=fCountCodePoints;
 end;
 CountCodePoints:=fCountCodePoints-CodePointIndex;
 if CountCodePoints>aCountCodePoints then begin
  CountCodePoints:=aCountCodePoints;
 end;
 Node:=FindNodePositionAtCodePoint(CodePointIndex,NodePositionLinks);
 result:=ExtractAtNodePosition(Node,NodePositionLinks,CountCodePoints);
end;

function TpvTextEditor.TRope.GetCodePoint(const aCodePointIndex:TpvSizeInt):TpvUInt32;
var Node:TNode;
    NodePositionLinks:TNode.TNodePositionLinks;
    NodeCodeUnitIndex,CodePointIndex:TpvSizeInt;
    CodeUnit:AnsiChar;
    First:boolean;
    UTF8DFAState,UTF8DFACharClass:TpvUInt8;
begin
{$if defined(DebugTpvUTF8StringRope)}
 Check;
{$ifend}
 result:=32;
 if aCodePointIndex<fCountCodePoints then begin
  CodePointIndex:=aCodePointIndex;
 end else begin
  CodePointIndex:=fCountCodePoints;
 end;
 Node:=FindNodePositionAtCodePoint(CodePointIndex,NodePositionLinks);
 if assigned(Node) then begin
  NodeCodeUnitIndex:=GetCountCodeUnits(@Node.fData[0],NodePositionLinks[0].fSkipSize);
  UTF8DFAState:=TUTF8DFA.StateAccept;
  First:=true;
  repeat
   if NodeCodeUnitIndex>=Node.fCountCodeUnits then begin
    Node:=Node.fLinks[0].fNode;
    NodeCodeUnitIndex:=0;
    if assigned(Node) then begin
     continue;
    end else begin
     break;
    end;
   end else begin
    CodeUnit:=Node.fData[NodeCodeUnitIndex];
    inc(NodeCodeUnitIndex);
    UTF8DFACharClass:=TUTF8DFA.StateCharClasses[CodeUnit];
    case UTF8DFAState of
     TUTF8DFA.StateAccept..TUTF8DFA.StateError:begin
      if First then begin
       First:=false;
       result:=ord(CodeUnit) and ($ff shr UTF8DFACharClass);
      end else begin
       break;
      end;
     end;
     else begin
      result:=(result shl 6) or (ord(CodeUnit) and $3f);
     end;
    end;
    UTF8DFAState:=TUTF8DFA.StateTransitions[UTF8DFAState+UTF8DFACharClass];
   end;
  until false;
  if UTF8DFAState<>TUTF8DFA.StateAccept then begin
   result:=$fffd;
  end;
 end else begin
  result:=32;
 end;
end;

function TpvTextEditor.TRope.GetEnumerator:TNodeEnumerator;
begin
 result:=TNodeEnumerator.Create(self);
end;

function TpvTextEditor.TRope.GetCodePointEnumeratorSource(const aStartCodePointIndex:TpvSizeInt=0;const aStopCodePointIndex:TpvSizeInt=-1):TRope.TCodePointEnumeratorSource;
begin
 result:=TRope.TCodePointEnumeratorSource.Create(self,aStartCodePointIndex,aStopCodePointIndex);
end;

procedure TpvTextEditor.TRope.Check;
{$if defined(DebugTpvUTF8StringRope)}
var Index:TpvInt32;
    Node:TNode;
    CurrentCountCodeUnits,CurrentCountCodePoints:TpvSizeInt;
    SkipOverLink:TNode.PNodeLink;
    NodePositionLinks:TNode.TNodePositionLinks;
begin
 Assert(fHead.fHeight>0);
 Assert(fCountCodeUnits>=fCountCodePoints);

 SkipOverLink:=@fHead.fLinks[fHead.fHeight-1];
 Assert(SkipOverLink^.fSkipSize=fCountCodePoints);
 Assert(not assigned(SkipOverLink^.fNode));

 FillChar(NodePositionLinks,SizeOf(TNode.TNodePositionLinks),#0);
 for Index:=0 to fHead.fHeight-1 do begin
  NodePositionLinks[Index].fNode:=fHead;
 end;

 CurrentCountCodeUnits:=0;
 CurrentCountCodePoints:=0;

 Node:=fHead;
 while assigned(Node) do begin
  Assert((Node=fHead) or (Node.fCountCodeUnits>0));
  Assert(Node.fHeight<=TNode.MaximumHeight);
  Assert(GetCountCodeUnits(@Node.fData[0],Node.fLinks[0].fSkipSize)=Node.fCountCodeUnits);
  for Index:=0 to Node.fHeight-1 do begin
   Assert(NodePositionLinks[Index].fNode=Node);
   Assert(NodePositionLinks[Index].fSkipSize=CurrentCountCodePoints);
   NodePositionLinks[Index].fNode:=Node.fLinks[Index].fNode;
   inc(NodePositionLinks[Index].fSkipSize,Node.fLinks[Index].fSkipSize);
  end;
  inc(CurrentCountCodeUnits,Node.fCountCodeUnits);
  inc(CurrentCountCodePoints,Node.fLinks[0].fSkipSize);
  Node:=Node.fLinks[0].fNode;
 end;

 for Index:=0 to fHead.fHeight-1 do begin
  Assert(not assigned(NodePositionLinks[Index].fNode));
  Assert(NodePositionLinks[Index].fSkipSize=CurrentCountCodePoints);
 end;

 Assert(fCountCodeUnits=CurrentCountCodeUnits);
 Assert(fCountCodePoints=CurrentCountCodePoints);

end;
{$else}
begin
end;
{$ifend}

procedure TpvTextEditor.TRope.Dump;
var Index,Counter:TpvInt32;
    Node:TNode;
begin
 WriteLn('Code points: ',fCountCodePoints, '    Code units: ',fCountCodeUnits,'    Height: ',fHead.fHeight);

 Write('HEAD');
 for Index:=0 to fHead.fHeight-1 do begin
  Write(' |',fHead.fLinks[Index].fSkipSize:3);
 end;
 WriteLn;

 Counter:=0;
 Node:=fHead;
 while assigned(Node) do begin
  Write(Counter:3,':');
  for Index:=0 to Node.fHeight-1 do begin
   Write(' |',Node.fLinks[Index].fSkipSize:3);
  end;
  WriteLn(' ':8,': "',Node.Data,'" (',Node.fCountCodeUnits,')');
  Node:=Node.fLinks[0].fNode;
  inc(Counter);
 end;

 WriteLn;

end;

constructor TpvTextEditor.TLineCacheMap.Create(const aRope:TRope);
begin
 inherited Create;
 fRope:=aRope;
 fLines:=nil;
 fCountLines:=0;
 fLineWrap:=0;
 fTabWidth:=8;
 Reset;
 Update(-1,-1);
end;

destructor TpvTextEditor.TLineCacheMap.Destroy;
begin
 fLines:=nil;
 inherited Destroy;
end;

procedure TpvTextEditor.TLineCacheMap.SetLineWrap(const aLineWrap:TpvSizeInt);
begin
 if fLineWrap<>aLineWrap then begin
  fLineWrap:=aLineWrap;
  Reset;
  Update(-1,-1);
 end;
end;

procedure TpvTextEditor.TLineCacheMap.SetTabWidth(const aTabWidth:TpvSizeInt);
begin
 if fTabWidth<>aTabWidth then begin
  fTabWidth:=aTabWidth;
  if fLineWrap>0 then begin
   Reset;
   Update(-1,-1);
  end;
 end;
end;

procedure TpvTextEditor.TLineCacheMap.AddLine(const aCodePointIndex:TpvSizeInt);
begin
 if length(fLines)<(fCountLines+1) then begin
  SetLength(fLines,(fCountLines+1)*2);
 end;
 fLines[fCountLines]:=aCodePointIndex;
 inc(fCountLines);
end;

procedure TpvTextEditor.TLineCacheMap.Reset;
begin
 fCountLines:=0;
 AddLine(0);
 fCodePointIndex:=0;
 fCountVisibleVisualCodePointsSinceNewLine:=0;
 fLastWasPossibleNewLineTwoCharSequence:=false;
 fLastCodePoint:=0;
end;

procedure TpvTextEditor.TLineCacheMap.Truncate(const aUntilCodePoint,aUntilLine:TpvSizeInt);
var UntilCodePointCountLines,UntilLineCountLines,NewCountLines,LineIndex:TpvSizeInt;
begin

 if aUntilCodePoint>=0 then begin
  if aUntilCodePoint>0 then begin
   LineIndex:=GetLineIndexFromCodePointIndex(aUntilCodePoint-1);
   if (LineIndex>0) and (fCountLines>(LineIndex-1)) then begin
    UntilCodePointCountLines:=LineIndex-1;
    while (UntilCodePointCountLines>0) and
          (fLines[UntilCodePointCountLines-1]>=aUntilCodePoint) do begin
     dec(UntilCodePointCountLines);
    end;
   end else begin
    UntilCodePointCountLines:=0;
   end;
  end else begin
   UntilCodePointCountLines:=0;
  end;
 end else begin
  UntilCodePointCountLines:=fCountLines;
 end;

 if (aUntilLine>=0) and
    (fCountLines>aUntilLine) then begin
  UntilLineCountLines:=aUntilLine;
 end else begin
  UntilLineCountLines:=fCountLines;
 end;

 if UntilCodePointCountLines<UntilLineCountLines then begin
  NewCountLines:=UntilCodePointCountLines;
 end else begin
  NewCountLines:=UntilLineCountLines;
 end;

 if fCountLines<>NewCountLines then begin
  while (NewCountLines>0) and ((NewCountLines+1)>=fCountLines) do begin
   dec(NewCountLines);
  end;
  if fCountLines<>NewCountLines then begin
   if (NewCountLines>0) and ((NewCountLines+1)<fCountLines) then begin
    fCodePointIndex:=fLines[NewCountLines-1];
    fCountLines:=NewCountLines;
    fCountVisibleVisualCodePointsSinceNewLine:=0;
    fLastWasPossibleNewLineTwoCharSequence:=false;
    fLastCodePoint:=0;
   end else begin
    Reset;
   end;
  end;
 end;

end;

procedure TpvTextEditor.TLineCacheMap.Update(const aUntilCodePoint,aUntilLine:TpvSizeInt);
var CodePoint:TpvUInt32;
    DoStop:TpvInt32;
    DoNewLine,DoTab:boolean;
begin

 if (fCodePointIndex<fRope.fCountCodePoints) and
    ((aUntilCodePoint<0) or (fCodePointIndex<aUntilCodePoint)) and
    ((aUntilLine<0) or (fCountLines<aUntilLine)) then begin

  DoStop:=0;

  for CodePoint in fRope.GetCodePointEnumeratorSource(fCodePointIndex,-1) do begin

   inc(fCodePointIndex);

   DoTab:=false;

   DoNewLine:=false;

   case CodePoint of
    $09:begin
     DoTab:=true;
     fLastWasPossibleNewLineTwoCharSequence:=false;
    end;
    $0a,$0d:begin
     if fLastWasPossibleNewLineTwoCharSequence and
        (((CodePoint=$0a) and (fLastCodePoint=$0d)) or
         ((CodePoint=$0d) and (fLastCodePoint=$0a))) then begin
      if fCountLines>0 then begin
       fLines[fCountLines-1]:=fCodePointIndex;
      end;
      fLastWasPossibleNewLineTwoCharSequence:=false;
     end else begin
      DoNewLine:=true;
      fLastWasPossibleNewLineTwoCharSequence:=true;
     end;
    end;
    else begin
     fLastWasPossibleNewLineTwoCharSequence:=false;
    end;
   end;

   if fLineWrap>0 then begin
    if (CodePoint<>10) and (CodePoint<>13) then begin
     if DoTab and (fTabWidth>0) then begin
      inc(fCountVisibleVisualCodePointsSinceNewLine,fTabWidth-(fCountVisibleVisualCodePointsSinceNewLine mod fTabWidth));
     end else begin
      inc(fCountVisibleVisualCodePointsSinceNewLine);
     end;
    end;
    if fCountVisibleVisualCodePointsSinceNewLine>=fLineWrap then begin
     fCountVisibleVisualCodePointsSinceNewLine:=0;
     DoNewLine:=true;
    end;
   end;

   if DoNewLine then begin
    AddLine(fCodePointIndex);
    fCountVisibleVisualCodePointsSinceNewLine:=0;
    if ((aUntilCodePoint>=0) and (fCodePointIndex>=aUntilCodePoint)) or
       ((aUntilLine>=0) and (fCountLines>=aUntilLine)) then begin
     DoStop:=2; // for as fallback for possible two-single-char-class-codepoint-width-sized newline sequences
    end;
   end;

   fLastCodePoint:=CodePoint;

   if DoStop>0 then begin
    dec(DoStop);
    if DoStop=0 then begin
     break;
    end;
   end;

  end;

 end;

end;

function TpvTextEditor.TLineCacheMap.GetLineIndexFromCodePointIndex(const aCodePointIndex:TpvSizeInt):TpvSizeInt;
var MinIndex,MaxIndex,MidIndex:TpvSizeInt;
begin
 if aCodePointIndex<=fRope.CountCodePoints then begin
  Update(aCodePointIndex+1,-1);
  MinIndex:=0;
  MaxIndex:=fCountLines-1;
  while MinIndex<MaxIndex do begin
   MidIndex:=MinIndex+((MaxIndex-MinIndex) shr 1);
   if aCodePointIndex<fLines[MidIndex] then begin
    MaxIndex:=MidIndex-1;
   end else if aCodePointIndex>=fLines[MidIndex+1] then begin
    MinIndex:=MidIndex+1;
   end else begin
    MinIndex:=MidIndex;
    break;
   end;
  end;
  result:=MinIndex;
 end else begin
  result:=-1;
 end;
end;

function TpvTextEditor.TLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(const aCodePointIndex:TpvSizeInt;out aLineIndex,aColumnIndex:TpvSizeInt):boolean;
var StartCodePointIndex,StopCodePointIndex,CurrentCodePointIndex,
    StepWidth,CurrentColumn:TpvSizeInt;
    CodePoint,LastCodePoint:TpvUInt32;
    LastWasPossibleNewLineTwoCharSequence:boolean;
begin

 result:=false;

 Update(aCodePointIndex+1,-1);

 aLineIndex:=GetLineIndexFromCodePointIndex(aCodePointIndex);

 if aLineIndex<0 then begin

  aColumnIndex:=-1;

 end else begin

  StartCodePointIndex:=GetCodePointIndexFromLineIndex(aLineIndex);

  if StartCodePointIndex<0 then begin

   aLineIndex:=-1;
   aColumnIndex:=-1;

  end else begin

   StopCodePointIndex:=GetCodePointIndexFromNextLineIndexOrTextEnd(aLineIndex);

   if StartCodePointIndex<StopCodePointIndex then begin

    CodePoint:=0;

    CurrentColumn:=0;

    CurrentCodePointIndex:=StartCodePointIndex;

    LastCodePoint:=0;

    LastWasPossibleNewLineTwoCharSequence:=false;

    for CodePoint in fRope.GetCodePointEnumeratorSource(StartCodePointIndex,StopCodePointIndex) do begin

     StepWidth:=1;

     case CodePoint of
      9:begin
       StepWidth:=Max(1,(fTabWidth-(CurrentColumn mod fTabWidth)));
       LastWasPossibleNewLineTwoCharSequence:=false;
      end;
      $0a,$0d:begin
       if LastWasPossibleNewLineTwoCharSequence and
          (((CodePoint=$0a) and (LastCodePoint=$0d)) or
           ((CodePoint=$0d) and (LastCodePoint=$0a))) then begin
        StepWidth:=0;
        LastWasPossibleNewLineTwoCharSequence:=false;
       end else begin
        LastWasPossibleNewLineTwoCharSequence:=true;
       end;
      end;
      else begin
       LastWasPossibleNewLineTwoCharSequence:=false;
      end;
     end;

     LastCodePoint:=CodePoint;

     aColumnIndex:=CurrentColumn;

     if LastWasPossibleNewLineTwoCharSequence or
        (CurrentCodePointIndex>=aCodePointIndex) then begin
      break;
     end;

     inc(CurrentColumn,StepWidth);

     inc(CurrentCodePointIndex);

    end;

    if CurrentCodePointIndex=fRope.CountCodePoints then begin
     inc(aColumnIndex);
    end;

   end else begin

    aColumnIndex:=0;

   end;

   result:=true;

  end;

 end;

end;

function TpvTextEditor.TLineCacheMap.GetCodePointIndexFromLineIndex(const aLineIndex:TpvSizeInt):TpvSizeInt;
begin
 Update(-1,aLineIndex+1);
 if (aLineIndex>=0) and (aLineIndex<fCountLines) then begin
  result:=fLines[aLineIndex];
 end else begin
  result:=-1;
 end;
end;

function TpvTextEditor.TLineCacheMap.GetCodePointIndexFromNextLineIndexOrTextEnd(const aLineIndex:TpvSizeInt):TpvSizeInt;
begin
 Update(-1,aLineIndex+2);
 if (aLineIndex>=0) and (aLineIndex<fCountLines) then begin
  if (aLineIndex+1)<fCountLines then begin
   result:=fLines[aLineIndex+1];
  end else begin
   result:=fRope.CountCodePoints;
  end;
 end else begin
  result:=-1;
 end;
end;

function TpvTextEditor.TLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(const aLineIndex,aColumnIndex:TpvSizeInt):TpvSizeInt;
var StartCodePointIndex,StopCodePointIndex,CurrentCodePointIndex,
    StepWidth,CurrentColumn:TpvSizeInt;
    CodePoint,LastCodePoint:TpvUInt32;
    LastWasPossibleNewLineTwoCharSequence:boolean;
begin

 Update(-1,aLineIndex+2);

 if (aLineIndex>=0) and (aLineIndex<fCountLines) then begin

  result:=fLines[aLineIndex];

  StartCodePointIndex:=result;

  if (aLineIndex+1)<fCountLines then begin
   StopCodePointIndex:=fLines[aLineIndex+1];
  end else begin
   StopCodePointIndex:=fRope.CountCodePoints;
  end;

  CurrentColumn:=0;

  CurrentCodePointIndex:=StartCodePointIndex;

  LastCodePoint:=0;

  LastWasPossibleNewLineTwoCharSequence:=false;

  if StartCodePointIndex<StopCodePointIndex then begin

   for CodePoint in fRope.GetCodePointEnumeratorSource(StartCodePointIndex,StopCodePointIndex) do begin

    StepWidth:=1;

    case CodePoint of
     9:begin
      StepWidth:=Max(1,(fTabWidth-(CurrentColumn mod fTabWidth)));
      LastWasPossibleNewLineTwoCharSequence:=false;
     end;
     $0a,$0d:begin
      if LastWasPossibleNewLineTwoCharSequence and
         (((CodePoint=$0a) and (LastCodePoint=$0d)) or
          ((CodePoint=$0d) and (LastCodePoint=$0a))) then begin
       StepWidth:=0;
       LastWasPossibleNewLineTwoCharSequence:=false;
      end else begin
       LastWasPossibleNewLineTwoCharSequence:=true;
      end;
     end;
     else begin
      LastWasPossibleNewLineTwoCharSequence:=false;
     end;
    end;

    LastCodePoint:=CodePoint;

    result:=CurrentCodePointIndex;

    if LastWasPossibleNewLineTwoCharSequence or
       (CurrentColumn>=aColumnIndex) then begin
     break;
    end;

    inc(CurrentColumn,StepWidth);

    inc(CurrentCodePointIndex);

   end;

   if (CurrentColumn<=aColumnIndex) and (CurrentCodePointIndex=fRope.CountCodePoints) then begin
    result:=fRope.CountCodePoints;
   end;

  end;

 end else begin

  result:=-1;

 end;

end;

constructor TpvTextEditor.TUndoRedoCommand.Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState);
begin
 inherited Create;
 fParent:=aParent;
 fUndoCursorCodePointIndex:=aUndoCursorCodePointIndex;
 fRedoCursorCodePointIndex:=aRedoCursorCodePointIndex;
 fUndoMarkState:=aUndoMarkState;
 fRedoMarkstate:=aRedoMarkState;
 fSealed:=false;
 fActionID:=aParent.fUndoRedoManager.fActionID;
end;

destructor TpvTextEditor.TUndoRedoCommand.Destroy;
begin
 inherited Destroy;
end;

procedure TpvTextEditor.TUndoRedoCommand.Redo(const aView:TpvTextEditor.TView=nil);
begin
end;

procedure TpvTextEditor.TUndoRedoCommand.Undo(const aView:TpvTextEditor.TView=nil);
begin
end;

constructor TpvTextEditor.TUndoRedoCommandInsert.Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState;const aCodePointIndex,aCountCodePoints:TpvSizeInt;const aCodeUnits:TpvUTF8String);
begin
 inherited Create(aParent,aUndoCursorCodePointIndex,aRedoCursorCodePointIndex,aUndoMarkState,aRedoMarkState);
 fCodePointIndex:=aCodePointIndex;
 fCountCodePoints:=aCountCodePoints;
 fCodeUnits:=aCodeUnits;
end;

destructor TpvTextEditor.TUndoRedoCommandInsert.Destroy;
begin
 inherited Destroy;
end;

procedure TpvTextEditor.TUndoRedoCommandInsert.Undo(const aView:TpvTextEditor.TView=nil);
begin
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 fParent.LineMapTruncate(fCodePointIndex,-1);
 fParent.fRope.Delete(fCodePointIndex,fCountCodePoints);
 fParent.UpdateViewCodePointIndices(fCodePointIndex,-fCountCodePoints);
 if assigned(aView) then begin
  aView.fCodePointIndex:=fUndoCursorCodePointIndex;
  aView.fMarkState:=fUndoMarkState;
 end;
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
end;

procedure TpvTextEditor.TUndoRedoCommandInsert.Redo(const aView:TpvTextEditor.TView=nil);
begin
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 fParent.LineMapTruncate(fCodePointIndex,-1);
 fParent.fRope.Insert(fCodePointIndex,fCodeUnits);
 fParent.UpdateViewCodePointIndices(fCodePointIndex,fCountCodePoints);
 if assigned(aView) then begin
  aView.fCodePointIndex:=fRedoCursorCodePointIndex;
  aView.fMarkState:=fRedoMarkState;
 end;
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
end;

constructor TpvTextEditor.TUndoRedoCommandOverwrite.Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState;const aCodePointIndex,aCountCodePoints:TpvSizeInt;const aCodeUnits,aPreviousCodeUnits:TpvUTF8String);
begin
 inherited Create(aParent,aUndoCursorCodePointIndex,aRedoCursorCodePointIndex,aUndoMarkState,aRedoMarkState);
 fCodePointIndex:=aCodePointIndex;
 fCountCodePoints:=aCountCodePoints;
 fCodeUnits:=aCodeUnits;
 fPreviousCodeUnits:=aPreviousCodeUnits;
end;

destructor TpvTextEditor.TUndoRedoCommandOverwrite.Destroy;
begin
 inherited Destroy;
end;

procedure TpvTextEditor.TUndoRedoCommandOverwrite.Undo(const aView:TpvTextEditor.TView=nil);
begin
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 fParent.LineMapTruncate(fCodePointIndex,-1);
 fParent.fRope.Delete(fCodePointIndex,fCountCodePoints);
 fParent.fRope.Insert(fCodePointIndex,fPreviousCodeUnits);
 if assigned(aView) then begin
  aView.fCodePointIndex:=fUndoCursorCodePointIndex;
  aView.fMarkState:=fUndoMarkState;
 end;
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
end;

procedure TpvTextEditor.TUndoRedoCommandOverwrite.Redo(const aView:TpvTextEditor.TView=nil);
begin
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 fParent.LineMapTruncate(fCodePointIndex,-1);
 fParent.fRope.Delete(fCodePointIndex,fCountCodePoints);
 fParent.fRope.Insert(fCodePointIndex,fCodeUnits);
 if assigned(aView) then begin
  aView.fCodePointIndex:=fRedoCursorCodePointIndex;
  aView.fMarkState:=fRedoMarkState;
 end;
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
end;

constructor TpvTextEditor.TUndoRedoCommandDelete.Create(const aParent:TpvTextEditor;const aUndoCursorCodePointIndex,aRedoCursorCodePointIndex:TpvSizeInt;const aUndoMarkState,aRedoMarkState:TMarkState;const aCodePointIndex,aCountCodePoints:TpvSizeInt;const aCodeUnits:TpvUTF8String);
begin
 inherited Create(aParent,aUndoCursorCodePointIndex,aRedoCursorCodePointIndex,aUndoMarkState,aRedoMarkState);
 fCodePointIndex:=aCodePointIndex;
 fCountCodePoints:=aCountCodePoints;
 fCodeUnits:=aCodeUnits;
end;

destructor TpvTextEditor.TUndoRedoCommandDelete.Destroy;
begin
 inherited Destroy;
end;

procedure TpvTextEditor.TUndoRedoCommandDelete.Undo(const aView:TpvTextEditor.TView=nil);
begin
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 fParent.LineMapTruncate(fCodePointIndex,-1);
 fParent.fRope.Insert(fCodePointIndex,fCodeUnits);
 fParent.UpdateViewCodePointIndices(fCodePointIndex,fCountCodePoints);
 if assigned(aView) then begin
  aView.fCodePointIndex:=fUndoCursorCodePointIndex;
  aView.fMarkState:=fUndoMarkState;
 end;
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
end;

procedure TpvTextEditor.TUndoRedoCommandDelete.Redo(const aView:TpvTextEditor.TView=nil);
begin
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 fParent.LineMapTruncate(fCodePointIndex,-1);
 fParent.fRope.Delete(fCodePointIndex,fCountCodePoints);
 fParent.UpdateViewCodePointIndices(fCodePointIndex,-fCountCodePoints);
 if assigned(aView) then begin
  aView.fCodePointIndex:=fRedoCursorCodePointIndex;
  aView.fMarkState:=fRedoMarkState;
 end;
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
end;

constructor TpvTextEditor.TUndoRedoCommandGroup.Create(const aParent:TpvTextEditor;const aClass:TUndoRedoCommandClass);
begin
 inherited Create(aParent,0,0,EmptyMarkState,EmptyMarkState);
 fClass:=aClass;
 fList:=TObjectList.Create;
 fList.OwnsObjects:=true;
end;

destructor TpvTextEditor.TUndoRedoCommandGroup.Destroy;
begin
 fList.Free;
 inherited Destroy;
end;

procedure TpvTextEditor.TUndoRedoCommandGroup.Undo(const aView:TpvTextEditor.TView=nil);
var Index:TpvSizeInt;
begin
 for Index:=fList.Count-1 downto 0 do begin
  TUndoRedoCommand(fList[Index]).Undo(aView);
 end;
end;

procedure TpvTextEditor.TUndoRedoCommandGroup.Redo(const aView:TpvTextEditor.TView=nil);
var Index:TpvSizeInt;
begin
 for Index:=0 to fList.Count-1 do begin
  TUndoRedoCommand(fList[Index]).Redo(aView);
 end;
end;

constructor TpvTextEditor.TUndoRedoManager.Create(const aParent:TpvTextEditor);
begin
 inherited Create;
 OwnsObjects:=true;
 fParent:=aParent;
 fHistoryIndex:=-1;
 fMaxUndoSteps:=-1;
 fMaxRedoSteps:=-1;
 fActionID:=0;
end;

destructor TpvTextEditor.TUndoRedoManager.Destroy;
begin
 inherited Destroy;
end;

procedure TpvTextEditor.TUndoRedoManager.Clear;
begin
 inherited Clear;
 fHistoryIndex:=-1;
 fActionID:=0;
end;

procedure TpvTextEditor.TUndoRedoManager.IncreaseActionID;
begin
 inc(fActionID);
end;

procedure TpvTextEditor.TUndoRedoManager.Add(const aUndoRedoCommand:TpvTextEditor.TUndoRedoCommand);
var Index:TpvSizeInt;
    UndoRedoCommand:TpvTextEditor.TUndoRedoCommand;
    UndoRedoCommandGroup:TpvTextEditor.TUndoRedoCommandGroup;
begin
 if (fHistoryIndex>=0) and (fHistoryIndex<Count) then begin
  UndoRedoCommand:=TpvTextEditor.TUndoRedoCommand(Items[fHistoryIndex]);
  if (UndoRedoCommand.fActionID=fActionID) and not UndoRedoCommand.fSealed then begin
   if UndoRedoCommand is TpvTextEditor.TUndoRedoCommandGroup then begin
    UndoRedoCommandGroup:=TpvTextEditor.TUndoRedoCommandGroup(UndoRedoCommand);
    if aUndoRedoCommand is UndoRedoCommandGroup.fClass then begin
     UndoRedoCommandGroup.fList.Add(aUndoRedoCommand);
     exit;
    end;
   end else if UndoRedoCommand is aUndoRedoCommand.ClassType then begin
    if UndoRedoCommand is TpvTextEditor.TUndoRedoCommandInsert then begin
     if (TpvTextEditor.TUndoRedoCommandInsert(UndoRedoCommand).fCodePointIndex+TpvTextEditor.TUndoRedoCommandInsert(UndoRedoCommand).fCountCodePoints)=TpvTextEditor.TUndoRedoCommandInsert(aUndoRedoCommand).fCodePointIndex then begin
      inc(TpvTextEditor.TUndoRedoCommandInsert(UndoRedoCommand).fCountCodePoints,TpvTextEditor.TUndoRedoCommandInsert(aUndoRedoCommand).fCountCodePoints);
      TpvTextEditor.TUndoRedoCommandInsert(UndoRedoCommand).fCodeUnits:=TpvTextEditor.TUndoRedoCommandInsert(UndoRedoCommand).fCodeUnits+TpvTextEditor.TUndoRedoCommandInsert(aUndoRedoCommand).fCodeUnits;
      TpvTextEditor.TUndoRedoCommandInsert(UndoRedoCommand).fRedoCursorCodePointIndex:=TpvTextEditor.TUndoRedoCommandInsert(aUndoRedoCommand).fRedoCursorCodePointIndex;
      exit;
     end;
    end else if UndoRedoCommand is TpvTextEditor.TUndoRedoCommandDelete then begin
     if (TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodePointIndex-TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCountCodePoints)=TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCodePointIndex then begin
      dec(TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodePointIndex,TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCountCodePoints);
      inc(TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCountCodePoints,TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCountCodePoints);
      TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodeUnits:=TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCodeUnits+TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodeUnits;
      TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fRedoCursorCodePointIndex:=TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fRedoCursorCodePointIndex;
      exit;
     end else if TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodePointIndex=TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCodePointIndex then begin
      inc(TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCountCodePoints,TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCountCodePoints);
      TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodeUnits:=TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fCodeUnits+TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fCodeUnits;
      TpvTextEditor.TUndoRedoCommandDelete(UndoRedoCommand).fRedoCursorCodePointIndex:=TpvTextEditor.TUndoRedoCommandDelete(aUndoRedoCommand).fRedoCursorCodePointIndex;
      exit;
     end;
    end else begin
{$ifdef fpc}
     Extract(UndoRedoCommand);
{$else}
     ExtractItem(UndoRedoCommand,TDirection.FromEnd);
{$endif}
     UndoRedoCommandGroup:=TpvTextEditor.TUndoRedoCommandGroup.Create(fParent,TpvTextEditor.TUndoRedoCommandClass(aUndoRedoCommand.ClassType));
     Insert(fHistoryIndex,UndoRedoCommandGroup);
     UndoRedoCommandGroup.fList.Add(UndoRedoCommand);
     UndoRedoCommandGroup.fList.Add(aUndoRedoCommand);
     exit;
    end;
   end;
  end;
 end;
 for Index:=Count-1 downto fHistoryIndex+1 do begin
  Delete(Index);
 end;
 if fMaxUndoSteps>0 then begin
  while Count>=fMaxUndoSteps do begin
   Delete(0);
  end;
 end;
 fHistoryIndex:=inherited Add(aUndoRedoCommand);
end;

procedure TpvTextEditor.TUndoRedoManager.GroupUndoRedoCommands(const aFromIndex,aToIndex:TpvSizeInt);
var Index:TpvSizeInt;
    UndoRedoCommand:TpvTextEditor.TUndoRedoCommand;
    UndoRedoCommandGroup:TpvTextEditor.TUndoRedoCommandGroup;
begin
 if ((aFromIndex>=0) and (aFromIndex<Count)) and
    ((aToIndex>=0) and (aToIndex<Count)) then begin
  UndoRedoCommandGroup:=TpvTextEditor.TUndoRedoCommandGroup.Create(fParent,TUndoRedoCommand);
  UndoRedoCommandGroup.fSealed:=true;
  Insert(aFromIndex,UndoRedoCommandGroup);
  for Index:=aFromIndex to aToIndex do begin
   UndoRedoCommand:=TpvTextEditor.TUndoRedoCommand(Items[aFromIndex+1]);
{$ifdef fpc}
   Extract(UndoRedoCommand);
{$else}
   ExtractItem(UndoRedoCommand,TDirection.FromEnd);
{$endif}
   UndoRedoCommandGroup.fList.Add(UndoRedoCommand);
  end;
 end;
end;

procedure TpvTextEditor.TUndoRedoManager.Undo(const aView:TpvTextEditor.TView=nil);
var UndoRedoCommand:TpvTextEditor.TUndoRedoCommand;
begin
 if (fHistoryIndex>=0) and (fHistoryIndex<Count) then begin
  UndoRedoCommand:=TpvTextEditor.TUndoRedoCommand(Items[fHistoryIndex]);
  UndoRedoCommand.fSealed:=true;
  UndoRedoCommand.Undo(aView);
  dec(fHistoryIndex);
  if fMaxRedoSteps>0 then begin
   while (fHistoryIndex+fMaxRedoSteps)<Count do begin
    Delete(Count-1);
   end;
  end;
  IncreaseActionID;
 end;
end;

procedure TpvTextEditor.TUndoRedoManager.Redo(const aView:TpvTextEditor.TView=nil);
var UndoRedoCommand:TpvTextEditor.TUndoRedoCommand;
begin
 if (fHistoryIndex>=(-1)) and ((fHistoryIndex+1)<Count) then begin
  inc(fHistoryIndex);
  UndoRedoCommand:=TpvTextEditor.TUndoRedoCommand(Items[fHistoryIndex]);
  UndoRedoCommand.fSealed:=true;
  UndoRedoCommand.Redo(aView);
  if fMaxUndoSteps>0 then begin
   while fHistoryIndex>fMaxUndoSteps do begin
    dec(fHistoryIndex);
    Delete(0);
   end;
  end;
  IncreaseActionID;
 end;
end;

constructor TpvTextEditor.Create;
begin
 inherited Create;
 fRope:=TRope.Create;
 fLineCacheMap:=TLineCacheMap.Create(fRope);
 fFirstView:=nil;
 fLastView:=nil;
 fUndoRedoManager:=TUndoRedoManager.Create(self);
 fSyntaxHighlighting:=nil;
 fCountLines:=-1;
end;

destructor TpvTextEditor.Destroy;
begin
 while assigned(fLastView) do begin
  fLastView.Free;
 end;
 fLineCacheMap.Free;
 fRope.Free;
 fUndoRedoManager.Free;
 fSyntaxHighlighting.Free;
 inherited Destroy;
end;

function TpvTextEditor.GetCountLines:TpvSizeInt;
begin
 if fCountLines<0 then begin
  fLineCacheMap.Update(-1,-1);
  fCountLines:=fLineCacheMap.fCountLines;
 end;
 result:=fCountLines;
end;

function TpvTextEditor.IsCodePointNewLine(const aCodePointIndex:TpvSizeInt):boolean;
var CodePoint:TpvUInt32;
begin
 result:=false;
 for CodePoint in fRope.GetCodePointEnumeratorSource(aCodePointIndex,aCodePointIndex+1) do begin
  case CodePoint of
   $0a,$0d:begin
    result:=true;
   end;
   else begin
    break;
   end;
  end;
 end;
end;

function TpvTextEditor.IsTwoCodePointNewLine(const aCodePointIndex:TpvSizeInt):boolean;
var CodePoint,LastCodePoint:TpvUInt32;
    LastWasPossibleNewLineTwoCharSequence:boolean;
begin
 result:=false;
 LastCodePoint:=0;
 LastWasPossibleNewLineTwoCharSequence:=false;
 for CodePoint in fRope.GetCodePointEnumeratorSource(aCodePointIndex,aCodePointIndex+2) do begin
  case CodePoint of
   $0a,$0d:begin
    if LastWasPossibleNewLineTwoCharSequence and
       (((CodePoint=$0a) and (LastCodePoint=$0d)) or
        ((CodePoint=$0d) and (LastCodePoint=$0a))) then begin
     result:=true;
     break;
    end else begin
     LastWasPossibleNewLineTwoCharSequence:=true;
    end;
   end;
   else begin
    break;
   end;
  end;
  LastCodePoint:=CodePoint;
 end;
end;

procedure TpvTextEditor.LoadFromStream(const aStream:TStream);
begin
 fUndoRedoManager.Clear;
 if assigned(aStream) then begin
  fRope.Text:=TUTF8Utils.RawStreamToUTF8String(aStream);
 end else begin
  fRope.Text:='';
 end;
 if assigned(fSyntaxHighlighting) then begin
  fSyntaxHighlighting.Reset;
 end;
 ResetLineCacheMaps;
 ResetViewCodePointIndices;
 ResetViewMarkCodePointIndices;
end;

procedure TpvTextEditor.LoadFromFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(FileStream);
 finally
  FileStream.Free;
 end;
end;

procedure TpvTextEditor.LoadFromString(const aString:TpvRawByteString);
begin
 fUndoRedoManager.Clear;
 fRope.SetText(TUTF8Utils.RawByteStringToUTF8String(aString));
 if assigned(fSyntaxHighlighting) then begin
  fSyntaxHighlighting.Reset;
 end;
 ResetLineCacheMaps;
 ResetViewCodePointIndices;
 ResetViewMarkCodePointIndices;
end;

procedure TpvTextEditor.SaveToStream(const aStream:TStream);
var TemporaryString:TpvUTF8String;
begin
 if assigned(aStream) then begin
  TemporaryString:=fRope.GetText;
  aStream.Seek(0,soBeginning);
  aStream.Size:=length(TemporaryString);
  if length(TemporaryString)>0 then begin
   aStream.Seek(0,soBeginning);
   aStream.WriteBuffer(TemporaryString[1],aStream.Size);
  end;
 end;
end;

procedure TpvTextEditor.SaveToFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(FileStream);
 finally
  FileStream.Free;
 end;
end;

function TpvTextEditor.SaveToString:TpvUTF8String;
begin
 result:=fRope.GetText;
end;

function TpvTextEditor.GetText:TpvUTF8String;
begin
 result:=fRope.GetText;
end;

procedure TpvTextEditor.SetText(const aText:TpvUTF8String);
begin
 fUndoRedoManager.Clear;
 fRope.SetText(aText);
 if assigned(fSyntaxHighlighting) then begin
  fSyntaxHighlighting.Reset;
 end;
 ResetLineCacheMaps;
 ResetViewCodePointIndices;
 ResetViewMarkCodePointIndices;
end;

function TpvTextEditor.GetLine(const aLineIndex:TpvSizeInt):TpvUTF8String;
var StartCodePointIndex,StopCodePointIndex,CodeUnitIndex:TpvSizeInt;
begin
 result:='';
 fLineCacheMap.Update(-1,aLineIndex+2);
 if (aLineIndex>=0) and (aLineIndex<fLineCacheMap.fCountLines) then begin
  StartCodePointIndex:=fLineCacheMap.GetCodePointIndexFromLineIndex(aLineIndex);
  StopCodePointIndex:=fLineCacheMap.GetCodePointIndexFromNextLineIndexOrTextEnd(aLineIndex);
  if (StartCodePointIndex>=0) and
     (StartCodePointIndex<StopCodePointIndex) then begin
   result:=fRope.Extract(StartCodePointIndex,StopCodePointIndex-StartCodePointIndex);
   for CodeUnitIndex:=length(result) downto 1 do begin
    if not (result[CodeUnitIndex] in [AnsiChar(#10),AnsiChar(#13)]) then begin
     result:=Copy(result,1,CodeUnitIndex+1);
     break;
    end;
   end;
   exit;
  end;
 end;
 raise ERangeError.Create('Line index out of bounds');
end;

procedure TpvTextEditor.SetLine(const aLineIndex:TpvSizeInt;const aLine:TpvUTF8String);
var StartCodePointIndex,StopCodePointIndex:TpvSizeInt;
begin
 fLineCacheMap.Update(-1,aLineIndex+2);
 if (aLineIndex>=0) and (aLineIndex<=fLineCacheMap.fCountLines) then begin
  StartCodePointIndex:=fLineCacheMap.GetCodePointIndexFromLineIndex(aLineIndex);
  if StartCodePointIndex>=0 then begin
   fUndoRedoManager.Clear;
   StopCodePointIndex:=fLineCacheMap.GetCodePointIndexFromNextLineIndexOrTextEnd(aLineIndex);
   if StartCodePointIndex<StopCodePointIndex then begin
    fRope.Delete(StartCodePointIndex,StopCodePointIndex-StartCodePointIndex);
   end;
   fRope.Insert(StartCodePointIndex,aLine+NewLineCodePointSequence);
   if assigned(fSyntaxHighlighting) then begin
    fSyntaxHighlighting.Truncate(StartCodePointIndex);
   end;
   LineMapTruncate(-1,Max(0,aLineIndex-1));
   exit;
  end;
 end;
 raise ERangeError.Create('Line index out of bounds');
end;

function TpvTextEditor.CreateView:TpvTextEditor.TView;
begin
 result:=TpvTextEditor.TView.Create(self);
end;

procedure TpvTextEditor.LineMapTruncate(const aUntilCodePoint,aUntilLine:TpvSizeInt);
var View:TView;
begin
 fLineCacheMap.Truncate(aUntilCodePoint,aUntilLine);
 View:=fFirstView;
 while assigned(View) do begin
  View.fVisualLineCacheMap.Truncate(aUntilCodePoint,aUntilLine);
  View:=View.fNext;
 end;
 fCountLines:=-1;
end;

procedure TpvTextEditor.LineMapUpdate(const aUntilCodePoint,aUntilLine:TpvSizeInt);
var View:TView;
begin
 fLineCacheMap.Update(aUntilCodePoint,aUntilLine);
 View:=fFirstView;
 while assigned(View) do begin
  View.fVisualLineCacheMap.Update(aUntilCodePoint,aUntilLine);
  View:=View.fNext;
 end;
 fCountLines:=-1;
end;

procedure TpvTextEditor.ResetLineCacheMaps;
var View:TView;
begin
 fLineCacheMap.Truncate(0,0);
 fLineCacheMap.Update(-1,-1);
 View:=fFirstView;
 while assigned(View) do begin
  View.fVisualLineCacheMap.Truncate(0,0);
  View.fVisualLineCacheMap.Update(-1,-1);
  View:=View.fNext;
 end;
 fCountLines:=-1;
end;

procedure TpvTextEditor.ResetViewCodePointIndices;
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  View.fCodePointIndex:=0;
  View.EnsureCodePointIndexIsInRange;
  View.EnsureCursorIsVisible(true);
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.ResetViewMarkCodePointIndices;
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  View.fMarkState.StartCodePointIndex:=-1;
  View.fMarkState.EndCodePointIndex:=-1;
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.ClampViewMarkCodePointIndices;
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  View.ClampMarkCodePointIndices;
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.UpdateViewCodePointIndices(const aCodePointIndex,aDelta:TpvSizeInt);
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  if View.fCodePointIndex>=aCodePointIndex then begin
   inc(View.fCodePointIndex,aDelta);
  end;
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.EnsureViewCodePointIndicesAreInRange;
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  View.EnsureCodePointIndexIsInRange;
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.EnsureViewCursorsAreVisible(const aUpdateCursors:boolean=true;const aForceVisibleLines:TpvSizeInt=1);
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  View.EnsureCursorIsVisible(aUpdateCursors,aForceVisibleLines);
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.UpdateViewCursors;
var View:TView;
begin
 View:=fFirstView;
 while assigned(View) do begin
  View.UpdateCursor;
  View:=View.fNext;
 end;
end;

procedure TpvTextEditor.Undo(const aView:TView=nil);
begin
 fUndoRedoManager.Undo(aView);
end;

procedure TpvTextEditor.Redo(const aView:TView=nil);
begin
 fUndoRedoManager.Redo(aView);
end;

constructor TpvTextEditor.TSyntaxHighlighting.Create(const aParent:TpvTextEditor);
begin
 inherited Create;
 fParent:=aParent;
 fStates:=nil;
 fCountStates:=0;
 fCodePointIndex:=0;
end;

destructor TpvTextEditor.TSyntaxHighlighting.Destroy;
var Index:TpvSizeInt;
begin
 for Index:=0 to length(fStates)-1 do begin
  FreeAndNil(fStates[Index]);
 end;
 fStates:=nil;
 inherited Destroy;
end;

function TpvTextEditor.TSyntaxHighlighting.GetStateIndexFromCodePointIndex(const aCodePointIndex:TpvSizeInt):TpvSizeInt;
var MinIndex,MaxIndex,MidIndex:TpvSizeInt;
begin
 if aCodePointIndex<=fParent.fRope.CountCodePoints then begin
  Update(aCodePointIndex+1);
  MinIndex:=0;
  MaxIndex:=fCountStates-1;
  while MinIndex<MaxIndex do begin
   MidIndex:=MinIndex+((MaxIndex-MinIndex) shr 1);
   if aCodePointIndex<fStates[MidIndex].fCodePointIndex then begin
    MaxIndex:=MidIndex-1;
   end else if aCodePointIndex>=fStates[MidIndex+1].fCodePointIndex then begin
    MinIndex:=MidIndex+1;
   end else begin
    MinIndex:=MidIndex;
    break;
   end;
  end;
  result:=MinIndex;
 end else begin
  result:=-1;
 end;
end;

procedure TpvTextEditor.TSyntaxHighlighting.Reset;
var Index:TpvSizeInt;
begin
 for Index:=0 to length(fStates)-1 do begin
  FreeAndNil(fStates[Index]);
 end;
 fStates:=nil;
end;

procedure TpvTextEditor.TSyntaxHighlighting.Truncate(const aUntilCodePoint:TpvSizeInt);
var LineIndex,UntilCodePoint:TpvSizeInt;
begin
 if aUntilCodePoint>=0 then begin
  LineIndex:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(aUntilCodePoint);
  if LineIndex>=0 then begin
   UntilCodePoint:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(LineIndex);
  end else begin
   UntilCodePoint:=aUntilCodePoint;
  end;
 end else begin
  UntilCodePoint:=aUntilCodePoint;
 end;
 if UntilCodePoint<0 then begin
  while fCountStates>0 do begin
   dec(fCountStates);
   FreeAndNil(fStates[fCountStates]);
  end;
  fStates:=nil;
  fCodePointIndex:=0;
 end else begin
  while (fCountStates>0) and
        (fStates[fCountStates-1].fCodePointIndex>=UntilCodePoint) do begin
   dec(fCountStates);
   fCodePointIndex:=fStates[fCountStates].fCodePointIndex;
   FreeAndNil(fStates[fCountStates]);
  end;
 if (fCountStates>0) and
    (fStates[fCountStates-1].fCodePointIndex<UntilCodePoint) then begin
   dec(fCountStates);
   fCodePointIndex:=fStates[fCountStates].fCodePointIndex;
   FreeAndNil(fStates[fCountStates]);
  end;
  if ((fCountStates*8)<length(fStates)) and (fCountStates<(fCountStates*8)) then begin
   SetLength(fStates,fCountStates);
  end;
 end;
end;

procedure TpvTextEditor.TSyntaxHighlighting.Update(const aUntilCodePoint:TpvSizeInt);
begin
end;

procedure TpvTextEditor.TGenericSyntaxHighlighting.Update(const aUntilCodePoint:TpvSizeInt);
var CodePointEnumeratorSource:TpvTextEditor.TRope.TCodePointEnumeratorSource;
    CodePoint,LastAttribute,Attribute:TpvUInt32;
    State:TSyntaxHighlighting.TState;
    OldCount:TpvSizeInt;
begin
 if fCodePointIndex<fParent.fRope.fCountCodePoints then begin
  if fCountStates>0 then begin
   State:=fStates[fCountStates-1];
   LastAttribute:=TGenericSyntaxHighlighting.TState(State).fAttribute;
  end else begin
   State:=nil;
   LastAttribute:=TSyntaxHighlighting.TAttributes.Unknown;
  end;
  CodePointEnumeratorSource:=fParent.fRope.GetCodePointEnumeratorSource(fCodePointIndex,IfThen(aUntilCodePoint<0,aUntilCodePoint,aUntilCodePoint+1));
  for CodePoint in CodePointEnumeratorSource do begin
   case CodePoint of
    0..32:begin
     Attribute:=TSyntaxHighlighting.TAttributes.WhiteSpace;
    end;
    ord('a')..ord('z'),ord('A')..ord('Z'),ord('_'):begin
     case LastAttribute of
      TSyntaxHighlighting.TAttributes.Number:begin
       Attribute:=TSyntaxHighlighting.TAttributes.Number;
      end;
      else begin
       Attribute:=TSyntaxHighlighting.TAttributes.Identifier;
      end;
     end;
    end;
    ord('0')..ord('9'):begin
     case LastAttribute of
      TSyntaxHighlighting.TAttributes.Identifier:begin
       Attribute:=TSyntaxHighlighting.TAttributes.Identifier;
      end;
      else begin
       Attribute:=TSyntaxHighlighting.TAttributes.Number;
      end;
     end;
    end;
    else begin
     Attribute:=TSyntaxHighlighting.TAttributes.Symbol;
    end;
   end;
   if LastAttribute<>Attribute then begin
    LastAttribute:=Attribute;
    OldCount:=length(fStates);
    if OldCount<(fCountStates+1) then begin
     SetLength(fStates,(fCountStates+1)*2);
     FillChar(fStates[OldCount],(length(fStates)-OldCount)*SizeOf(TSyntaxHighlighting.TState),#0);
    end;
    State:=TGenericSyntaxHighlighting.TState.Create;
    fStates[fCountStates]:=State;
    inc(fCountStates);
    TGenericSyntaxHighlighting.TState(State).fCodePointIndex:=fCodePointIndex;
    TGenericSyntaxHighlighting.TState(State).fAttribute:=Attribute;
   end;
   inc(fCodePointIndex);
  end;
 end;
end;

constructor TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Create(const aValues:array of TpvUInt32);
var Value,MaxValue:TpvUInt32;
    WordIndex:TpvSizeInt;
begin
 MaxValue:=0;
 for Value in aValues do begin
  if MaxValue<Value then begin
   MaxValue:=Value;
  end;
 end;
 SetLength(fSet,(MaxValue+32) shr 5);
 if length(fSet)>0 then begin
  FillChar(fSet[0],length(fSet)*SizeOf(TpvUInt32),#0);
 end;
 for Value in aValues do begin
  WordIndex:=Value shr 5;
  fSet[WordIndex]:=fSet[WordIndex] or (TpvUInt32(1) shl (Value and 31));
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Add(const aSet:TNFASet;const aValue:TpvUInt32):TNFASet;
var WordIndex,OldCount:TpvSizeInt;
begin
 result.fSet:=copy(aSet.fSet);
 WordIndex:=aValue shr 5;
 OldCount:=length(result.fSet);
 if OldCount<=WordIndex then begin
  SetLength(result.fSet,(WordIndex+1)*2);
  FillChar(result.fSet[OldCount],(length(result.fSet)-OldCount)*SizeOf(TpvUInt32),#0);
 end;
 result.fSet[WordIndex]:=result.fSet[WordIndex] or (TpvUInt32(1) shl (aValue and 31));
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Add(const aSet,aOtherSet:TNFASet):TNFASet;
var Index:TpvSizeInt;
    WordValue:TpvUInt32;
begin
 SetLength(result.fSet,Max(length(aSet.fSet),length(aOtherSet.fSet)));
 for Index:=0 to length(result.fSet)-1 do begin
  if Index<length(aSet.fSet) then begin
   WordValue:=aSet.fSet[Index];
  end else begin
   WordValue:=0;
  end;
  if Index<length(aOtherSet.fSet) then begin
   WordValue:=WordValue or aOtherSet.fSet[Index];
  end;
  result.fSet[Index]:=WordValue;
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Subtract(const aSet:TNFASet;const aValue:TpvUInt32):TNFASet;
var WordIndex:TpvSizeInt;
begin
 result.fSet:=copy(aSet.fSet);
 WordIndex:=aValue shr 5;
 if WordIndex<length(result.fSet) then begin
  result.fSet[WordIndex]:=result.fSet[WordIndex] and not (TpvUInt32(1) shl (aValue and 31));
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Subtract(const aSet,aOtherSet:TNFASet):TNFASet;
var Index:TpvSizeInt;
begin
 SetLength(result.fSet,length(aSet.fSet));
 for Index:=0 to length(result.fSet)-1 do begin
  result.fSet[Index]:=aSet.fSet[Index] and not aOtherSet.fSet[Index];
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Multiply(const aSet,aOtherSet:TNFASet):TNFASet;
var Index:TpvSizeInt;
begin
 SetLength(result.fSet,length(aSet.fSet));
 for Index:=0 to length(result.fSet)-1 do begin
  result.fSet[Index]:=aSet.fSet[Index] and aOtherSet.fSet[Index];
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.BitwiseAnd(const aSet,aOtherSet:TNFASet):TNFASet;
var Index:TpvSizeInt;
begin
 SetLength(result.fSet,length(aSet.fSet));
 for Index:=0 to length(result.fSet)-1 do begin
  result.fSet[Index]:=aSet.fSet[Index] and aOtherSet.fSet[Index];
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.BitwiseOr(const aSet,aOtherSet:TNFASet):TNFASet;
var Index:TpvSizeInt;
    WordValue:TpvUInt32;
begin
 SetLength(result.fSet,Max(length(aSet.fSet),length(aOtherSet.fSet)));
 for Index:=0 to length(result.fSet)-1 do begin
  if Index<length(aSet.fSet) then begin
   WordValue:=aSet.fSet[Index];
  end else begin
   WordValue:=0;
  end;
  if Index<length(aOtherSet.fSet) then begin
   WordValue:=WordValue or aOtherSet.fSet[Index];
  end;
  result.fSet[Index]:=WordValue;
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.BitwiseXor(const aSet,aOtherSet:TNFASet):TNFASet;
var Index:TpvSizeInt;
    WordValue:TpvUInt32;
begin
 SetLength(result.fSet,Max(length(aSet.fSet),length(aOtherSet.fSet)));
 for Index:=0 to length(result.fSet)-1 do begin
  if Index<length(aSet.fSet) then begin
   WordValue:=aSet.fSet[Index];
  end else begin
   WordValue:=0;
  end;
  if Index<length(aOtherSet.fSet) then begin
   WordValue:=WordValue xor aOtherSet.fSet[Index];
  end;
  result.fSet[Index]:=WordValue;
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.In(const aValue:TpvUInt32;const aSet:TNFASet):boolean;
var WordIndex:TpvSizeInt;
begin
 WordIndex:=aValue shr 5;
 result:=(WordIndex<length(aSet.fSet)) and
         ((aSet.fSet[WordIndex] and (TpvUInt32(1) shl (aValue and 31)))<>0);
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.Equal(const aSet,aOtherSet:TNFASet):boolean;
var Index:TpvSizeInt;
    WordValue,OtherWordValue:TpvUInt32;
begin
 result:=true;
 for Index:=0 to Max(length(aSet.fSet),length(aOtherSet.fSet))-1 do begin
  if Index<length(aSet.fSet) then begin
   WordValue:=aSet.fSet[Index];
  end else begin
   WordValue:=0;
  end;
  if Index<length(aOtherSet.fSet) then begin
   OtherWordValue:=aOtherSet.fSet[Index];
  end else begin
   OtherWordValue:=0;
  end;
  if WordValue<>OtherWordValue then begin
   result:=false;
   exit;
  end;
 end;
end;

class operator TpvTextEditor.TDFASyntaxHighlighting.TNFASet.NotEqual(const aSet,aOtherSet:TNFASet):boolean;
var Index:TpvSizeInt;
    WordValue,OtherWordValue:TpvUInt32;
begin
 result:=false;
 for Index:=0 to Max(length(aSet.fSet),length(aOtherSet.fSet))-1 do begin
  if Index<length(aSet.fSet) then begin
   WordValue:=aSet.fSet[Index];
  end else begin
   WordValue:=0;
  end;
  if Index<length(aOtherSet.fSet) then begin
   OtherWordValue:=aOtherSet.fSet[Index];
  end else begin
   OtherWordValue:=0;
  end;
  if WordValue<>OtherWordValue then begin
   result:=true;
   exit;
  end;
 end;
end;

constructor TpvTextEditor.TDFASyntaxHighlighting.TKeywordCharTreeNode.Create;
begin
 inherited Create;
 FillChar(fChildren,SizeOf(TKeywordCharTreeNodes),#0);
 fHasChildren:=false;
 fKeyword:=false;
 fAttribute:=TpvTextEditor.TDFASyntaxHighlighting.TAttributes.Unknown;
end;

destructor TpvTextEditor.TDFASyntaxHighlighting.TKeywordCharTreeNode.Destroy;
var CurrentChar:AnsiChar;
begin
 for CurrentChar:=Low(TKeywordCharTreeNodes) to High(TKeywordCharTreeNodes) do begin
  FreeAndNil(fChildren[CurrentChar]);
 end;
 inherited Destroy;
end;

constructor TpvTextEditor.TDFASyntaxHighlighting.Create(const aParent:TpvTextEditor);
var NFA:TNFA;
begin
 inherited Create(aParent);

 fNFAStates:=2;

 fNFA:=nil;

 fDFA:=nil;

 fAccept:=nil;

 fCaseInsensitive:=false;

 FillChar(fEquivalence,SizeOf(TEquivalence),#0);

 fKeywordCharRootTreeNode:=TKeywordCharTreeNode.Create;

 try

  Setup;

 finally

  try

   BuildDFA;

  finally

   // We don't need the original NFA states anymore, after we have built the DFA states
   fNFAStates:=0;
   while assigned(fNFA) do begin
    NFA:=fNFA.fNext;
    fNFA.Free;
    fNFA:=NFA;
   end;

  end;

 end;

end;

destructor TpvTextEditor.TDFASyntaxHighlighting.Destroy;
begin
 Clear;
 FreeAndNil(fKeywordCharRootTreeNode);
 inherited Destroy;
end;

procedure TpvTextEditor.TDFASyntaxHighlighting.Clear;
var NFA:TNFA;
    DFA:TDFA;
    Accept:TAccept;
begin
 fDFAStates:=0;
 fNFAStates:=2;
 while assigned(fNFA) do begin
  NFA:=fNFA.fNext;
  fNFA.Free;
  fNFA:=NFA;
 end;
 while assigned(fDFA) do begin
  DFA:=fDFA.fNext;
  fDFA.Free;
  fDFA:=DFA;
 end;
 while assigned(fAccept) do begin
  Accept:=fAccept.fNext;
  fAccept.Free;
  fAccept:=Accept;
 end;
end;

procedure TpvTextEditor.TDFASyntaxHighlighting.AddKeyword(const aKeyword:TpvRawByteString;const aAttribute:TpvUInt32);
var Node:TKeywordCharTreeNode;
    Index:TpvSizeInt;
    CurrentChar:ansichar;
begin
 Node:=fKeywordCharRootTreeNode;
 for Index:=1 to length(aKeyword) do begin
  CurrentChar:=aKeyword[Index];
  if CurrentChar in KeywordCharSet then begin
   if fCaseInsensitive and (CurrentChar in ['A'..'Z']) then begin
    inc(CurrentChar,ord('a')-ord('A'));
   end;
   if Node.fHasChildren and assigned(Node.fChildren[CurrentChar]) then begin
    Node:=Node.fChildren[CurrentChar];
   end else begin
    Node.fChildren[CurrentChar]:=TKeywordCharTreeNode.Create;
    Node.fHasChildren:=true;
    Node:=Node.fChildren[CurrentChar];
    Node.fHasChildren:=false;
    Node.fKeyword:=false;
    Node.fAttribute:=TpvTextEditor.TDFASyntaxHighlighting.TAttributes.Unknown;
   end;
  end else begin
   break;
  end;
 end;
 if assigned(Node) and (Node<>fKeywordCharRootTreeNode) then begin
  Node.fKeyword:=true;
  Node.fAttribute:=aAttribute;
 end;
end;

procedure TpvTextEditor.TDFASyntaxHighlighting.AddKeywords(const aKeywords:array of TpvRawByteString;const aAttribute:TpvUInt32);
var Keyword:TpvRawByteString;
begin
 for Keyword in aKeywords do begin
  AddKeyword(Keyword,aAttribute);
 end;
end;

procedure TpvTextEditor.TDFASyntaxHighlighting.AddRule(const aRule:TpvRawByteString;const aFlags:TAccept.TFlags;const aAttribute:TpvUInt32);
var IsBegin,IsEnd:boolean;
 procedure AddNFATransition(const aFrom,aTo:TpvSizeInt;const aSet:TCharSet);
 var NFA:TNFA;
     CurrentChar,EquivalenceChar:AnsiChar;
     Other:array[AnsiChar] of AnsiChar;
     InSet:TCharSet;
 begin
  NFA:=TNFA.Create;
  NFA.fNext:=fNFA;
  fNFA:=NFA;
  NFA.fSet:=aSet;
  NFA.fFrom:=aFrom;
  NFA.fTo:=aTo;
  if aSet<>[] then begin
   FillChar(Other,SizeOf(Other),#0);
   InSet:=[];
   for CurrentChar:=#0 to #255 do begin
    EquivalenceChar:=fEquivalence[CurrentChar];
    if CurrentChar=EquivalenceChar then begin
     Other[CurrentChar]:=CurrentChar;
     if CurrentChar in aSet then begin
      Include(InSet,CurrentChar);
     end;
    end else if (not (CurrentChar in aSet)) xor not (EquivalenceChar in InSet) then begin
     if Other[EquivalenceChar]=EquivalenceChar then begin
      Other[EquivalenceChar]:=CurrentChar;
     end;
     fEquivalence[CurrentChar]:=Other[EquivalenceChar];
    end;
   end;
  end;
 end;
 procedure Parse(var aStart,aEnd:TpvSizeInt);
 const LexSymbolChars=['^','$','|','*','+','?','[',']','-','.','(',')'];
 var InputText:TpvRawByteString;
     InputPosition:TpvSizeInt;
     InputLength:TpvSizeInt;
  procedure ParseLevel1(var aStart,aEnd:TpvSizeInt);
   procedure ParseLevel2(var aStart,aEnd:TpvSizeInt);
    procedure ParseLevel3(var aStart,aEnd:TpvSizeInt);
     procedure ParseLevel4(var aStart,aEnd:TpvSizeInt);
     var CharSet:TCharSet;
         Complement:boolean;
         CurrentChar,OneEndChar,OtherEndChar:AnsiChar;
     begin
      if (InputPosition<=InputLength) and (InputText[InputPosition]='(') then begin
       inc(InputPosition);
       ParseLevel1(aStart,aEnd);
       if (InputPosition<=InputLength) and (InputText[InputPosition]=')') then begin
        inc(InputPosition);
       end else begin
        raise EParserErrorExpectedRightParen.Create('Expected right paren');
       end;
      end else if InputPosition<=InputLength then begin
       CharSet:=[];
       CurrentChar:=InputText[InputPosition];
       case CurrentChar of
        '.':begin
         inc(InputPosition);
         CharSet:=[#0..#255];
        end;
        '[':begin
         inc(InputPosition);
         Complement:=(InputPosition<=InputLength) and (InputText[InputPosition]='^');
         if Complement then begin
          inc(InputPosition);
          CharSet:=[#0..#255];
         end;
         if (InputPosition<=InputLength) and (InputText[InputPosition]=']') then begin
          inc(InputPosition);
          raise EParserErrorEmptySet.Create('Empty set');
         end else begin
          while InputPosition<=InputLength do begin
           CurrentChar:=InputText[InputPosition];
           case CurrentChar of
            ']':begin
             break;
            end;
            else begin
             if CurrentChar in ([#0..#255]-LexSymbolChars) then begin
              inc(InputPosition);
              if (CurrentChar='\') and (InputPosition<=InputLength) then begin
               CurrentChar:=InputText[InputPosition];
               inc(InputPosition);
              end;
              OneEndChar:=CurrentChar;
              OtherEndChar:=CurrentChar;
              if (InputPosition<=InputLength) and (InputText[InputPosition]='-') then begin
               inc(InputPosition);
               if InputPosition<=InputLength then begin
                CurrentChar:=InputText[InputPosition];
                if CurrentChar in ([#0..#255]-LexSymbolChars) then begin
                 inc(InputPosition);
                 if (CurrentChar='\') and (InputPosition<=InputLength) then begin
                  CurrentChar:=InputText[InputPosition];
                  inc(InputPosition);
                 end;
                 OtherEndChar:=CurrentChar;
                end else begin
                 raise EParserErrorInvalidMetaChar.Create('Invalid meta-char');
                end;
               end else begin
                raise EParserErrorUnexpectedEndOfText.Create('Unexpected end of text');
               end;
              end;
              if OneEndChar=OtherEndChar then begin
               if Complement then begin
                Exclude(CharSet,OneEndChar);
               end else begin
                Include(CharSet,OneEndChar);
               end;
              end else if OtherEndChar<OneEndChar then begin
               if Complement then begin
                CharSet:=CharSet-[OtherEndChar..OneEndChar];
               end else begin
                CharSet:=CharSet+[OtherEndChar..OneEndChar];
               end;
              end else begin
               if Complement then begin
                CharSet:=CharSet-[OneEndChar..OtherEndChar];
               end else begin
                CharSet:=CharSet+[OneEndChar..OtherEndChar];
               end;
              end;
             end else begin
              raise EParserErrorInvalidMetaChar.Create('Invalid meta-char');
             end;
            end;
           end;
          end;
          if (InputPosition<=InputLength) and (InputText[InputPosition]=']') then begin
           inc(InputPosition);
          end else begin
           raise EParserErrorExpectedRightBracket.Create('Expected right bracket');
          end;
         end;
        end;
        else begin
         if CurrentChar in (([#0..#255]-LexSymbolChars)+['-']) then begin
          inc(InputPosition);
          if (CurrentChar='\') and (InputPosition<=InputLength) then begin
           CurrentChar:=InputText[InputPosition];
           inc(InputPosition);
          end;
          Include(CharSet,CurrentChar);
         end else begin
          raise EParserErrorInvalidMetaChar.Create('Invalid meta-char');
         end;
        end;
       end;
       if aStart=0 then begin
        aStart:=fNFAStates;
        inc(fNFAStates);
       end;
       if aEnd=0 then begin
        aEnd:=fNFAStates;
        inc(fNFAStates);
       end;
       AddNFATransition(aStart,aEnd,CharSet);
      end;
     end;
    var LocalStart,LocalEnd:TpvSizeInt;
    begin
     LocalStart:=0;
     LocalEnd:=0;
     ParseLevel4(LocalStart,LocalEnd);
     if InputPosition<=InputLength then begin
      case InputText[InputPosition] of
       '*':begin
        inc(InputPosition);
        AddNFATransition(LocalStart,LocalEnd,[]);
        AddNFATransition(LocalEnd,LocalStart,[]);
       end;
       '+':begin
        inc(InputPosition);
        AddNFATransition(LocalEnd,LocalStart,[]);
       end;
       '?':begin
        inc(InputPosition);
        AddNFATransition(LocalStart,LocalEnd,[]);
       end;
      end;
     end;
     if aEnd=0 then begin
      aEnd:=fNFAStates;
      inc(fNFAStates);
     end;
     AddNFATransition(LocalEnd,aEnd,[]);
     if aStart=0 then begin
      aStart:=fNFAStates;
      inc(fNFAStates);
     end;
     AddNFATransition(aStart,LocalStart,[]);
    end;
   const AllowedChars=([#0..#255]-LexSymbolChars)+['(','[','-','.'];
   var LocalStart,LocalEnd:TpvSizeInt;
   begin
    LocalEnd:=0;
    ParseLevel3(aStart,LocalEnd);
    while (InputPosition<=InputLength) and
          (InputText[InputPosition] in AllowedChars) do begin
     LocalStart:=LocalEnd;
     LocalEnd:=0;
     ParseLevel3(LocalStart,LocalEnd);
    end;
    if aEnd<>0 then begin
     AddNFATransition(LocalEnd,aEnd,[]);
    end else begin
     aEnd:=LocalEnd;
    end;
   end;
  begin
   ParseLevel2(aStart,aEnd);
   while (InputPosition<=InputLength) and (InputText[InputPosition]='|') do begin
    inc(InputPosition);
    ParseLevel2(aStart,aEnd);
   end;
  end;
 begin

  InputText:=aRule;
  InputPosition:=1;
  InputLength:=length(InputText);

  if (InputPosition<=InputLength) and (InputText[InputPosition]='^') then begin
   IsBegin:=true;
   inc(InputPosition);
  end else begin
   IsBegin:=false;
  end;

  ParseLevel1(aStart,aEnd);

  if (InputPosition<=InputLength) and (InputText[InputPosition]='$') then begin
   IsEnd:=true;
   inc(InputPosition);
  end else begin
   IsEnd:=false;
  end;

  if InputPosition<=InputLength then begin
   raise EParserErrorExpectedEndOfText.Create('Expected end of text');
  end;

 end;
var LocalStart,LocalEnd,OldNFAStates:TpvSizeInt;
    Accept:TAccept;
    OldNFA,NFA:TNFA;
begin
 LocalStart:=0;
 LocalEnd:=0;
 OldNFAStates:=fNFAStates;
 OldNFA:=fNFA;
 try
  Parse(LocalStart,LocalEnd);
  AddNFATransition(ord(IsBegin) and 1,LocalStart,[]);
  Accept:=TAccept.Create;
  Accept.fNext:=fAccept;
  fAccept:=Accept;
  Accept.fState:=LocalEnd;
  Accept.fFlags:=aFlags;
  if IsEnd then begin
   Include(Accept.fFlags,TAccept.TFlag.IsEnd);
  end;
  Accept.fAttribute:=aAttribute;
 except
  fNFAStates:=OldNFAStates;
  while assigned(fNFA) and (fNFA<>OldNFA) do begin
   NFA:=fNFA.fNext;
   fNFA.Free;
   fNFA:=NFA;
  end;
  raise;
 end;
end;

procedure TpvTextEditor.TDFASyntaxHighlighting.BuildDFA;
 procedure ComputeClosure(var aNFASet:TNFASet);
 var NFA:TNFA;
     Changed:boolean;
 begin
  repeat
   Changed:=false;
   NFA:=fNFA;
   while assigned(NFA) do begin
    if (NFA.fSet=[]) and (NFA.fFrom in aNFASet) and not (NFA.fTo in aNFASet) then begin
     Changed:=true;
     aNFASet:=aNFASet+NFA.fTo;
    end;
    NFA:=NFA.fNext;
   end;
  until not Changed;
 end;
var Tail,Next,Search:TDFA;
    Destination:TNFASet;
    CurrentChar:AnsiChar;
    DestinationEmpty:boolean;
    NFA:TNFA;
    Accept:TAccept;
begin

 Destination:=TNFASet.Create([]);

 fDFAStates:=0;

 Tail:=TDFA.Create;
 fDFA:=Tail;
 Tail.fNext:=nil;
 Tail.fNFASet:=TNFASet.Create([0]);
 Tail.fNumber:=fDFAStates;
 inc(fDFAStates);
 ComputeClosure(Tail.fNFASet);

 Tail.fNext:=TDFA.Create;
 Tail:=Tail.fNext;
 Tail.fNext:=nil;
 Tail.fNFASet:=TNFASet.Create([0,1]);
 Tail.fNumber:=fDFAStates;
 inc(fDFAStates);
 ComputeClosure(Tail.fNFASet);

 Next:=fDFA;
 while assigned(Next) do begin

  for CurrentChar:=#0 to #255 do begin

   if fEquivalence[CurrentChar]=CurrentChar then begin

    Destination:=TNFASet.Create([]);
    DestinationEmpty:=true;

    NFA:=fNFA;
    while assigned(NFA) do begin
     if (NFA.fFrom in Next.fNFASet) and
        (CurrentChar in NFA.fSet) then begin
      Destination:=Destination+NFA.fTo;
      DestinationEmpty:=false;
     end;
     NFA:=NFA.fNext;
    end;

    ComputeClosure(Destination);

    if DestinationEmpty then begin
     Search:=nil;
    end else begin
     Search:=fDFA;
     while assigned(Search) and (Search.fNFASet<>Destination) do begin
      Search:=Search.fNext;
     end;
     if not assigned(Search) then begin
      Tail.fNext:=TDFA.Create;
      Tail:=Tail.fNext;
      Search:=Tail;
      Tail.fNext:=nil;
      Tail.fNumber:=fDFAStates;
      inc(fDFAStates);
      Tail.fNFASet.fSet:=copy(Destination.fSet);
     end;
    end;

    Next.fWhereTo[CurrentChar]:=Search;

   end else begin

    Next.fWhereTo[CurrentChar]:=Next.fWhereTo[fEquivalence[CurrentChar]];

   end;

  end;

  Next.fAccept:=nil;
  Next.fAcceptEnd:=nil;

  Accept:=fAccept;
  while assigned(Accept) do begin
   if Accept.fState in Next.fNFASet then begin
    Next.fAcceptEnd:=Accept;
    if not (TAccept.TFlag.IsEnd in Accept.fFlags) then begin
     Next.fAccept:=Accept;
    end;
   end;
   Accept:=Accept.fNext;
  end;

  Next:=Next.fNext;

 end;

end;

procedure TpvTextEditor.TDFASyntaxHighlighting.Setup;
begin

end;

procedure TpvTextEditor.TDFASyntaxHighlighting.Update(const aUntilCodePoint:TpvSizeInt);
type TParserState=record
      CodePointEnumerator:TpvTextEditor.TRope.TCodePointEnumerator;
      CodePointIndex:TpvSizeInt;
      NewLine:TpvUInt8;
      Valid:boolean;
     end;
     TParserStates=array[0..3] of TParserState;
var CodePointEnumeratorSource:TpvTextEditor.TRope.TCodePointEnumeratorSource;
    CodePoint,Attribute,Preprocessor:TpvUInt32;
    LastState,State:TDFASyntaxHighlighting.TState;
    DFA:TDFA;
    OldCount:TpvSizeInt;
    Accept,LastAccept:TAccept;
    ParserStates:TParserStates;
    KeywordCharTreeNode:TKeywordCharTreeNode;
begin

 if (fCodePointIndex<fParent.fRope.fCountCodePoints) and
    ((aUntilCodePoint<0) or (fCodePointIndex<aUntilCodePoint)) then begin

  if fCountStates>0 then begin
   LastState:=TDFASyntaxHighlighting.TState(fStates[fCountStates-1]);
  end else begin
   LastState:=nil;
  end;

  CodePointEnumeratorSource:=fParent.fRope.GetCodePointEnumeratorSource(fCodePointIndex,-1);

  Preprocessor:=TpvUInt32($ffffffff);

  ParserStates[0].CodePointIndex:=fCodePointIndex;

  ParserStates[0].CodePointEnumerator:=CodePointEnumeratorSource.GetEnumerator;

  ParserStates[0].Valid:=ParserStates[0].CodePointEnumerator.MoveNext;

  if (ParserStates[0].CodePointIndex=0) or
     ((ParserStates[0].CodePointIndex>0) and
      fParent.IsCodePointNewLine(ParserStates[0].CodePointIndex-1)) then begin
   ParserStates[0].NewLine:=1;
  end else begin
   ParserStates[0].NewLine:=0;
  end;

  while ParserStates[0].Valid and
        ((aUntilCodePoint<0) or
         (ParserStates[0].CodePointIndex<aUntilCodePoint)) do begin

   if (ParserStates[0].NewLine and 1)<>0 then begin
    Preprocessor:=TpvUInt32($ffffffff);
    DFA:=fDFA.fNext;
   end else begin
    DFA:=fDFA;
   end;

   ParserStates[1]:=ParserStates[0];

   LastAccept:=nil;

   while ParserStates[1].Valid do begin

    CodePoint:=ParserStates[1].CodePointEnumerator.GetCurrent;

    ParserStates[1].Valid:=ParserStates[1].CodePointEnumerator.MoveNext;

    inc(ParserStates[1].CodePointIndex);

    ParserStates[1].NewLine:=ParserStates[1].NewLine shr 1;

    if (CodePoint in [10,13]) or
       (ParserStates[1].CodePointIndex=fParent.fRope.fCountCodePoints) then begin
     ParserStates[1].NewLine:=ParserStates[1].NewLine or 2;
    end;

    if CodePoint<128 then begin
     DFA:=DFA.fWhereTo[AnsiChar(TpvUInt8(CodePoint))];
    end else begin
     DFA:=DFA.fWhereTo[#128];
    end;

    if not assigned(DFA) then begin
     if not assigned(LastAccept) then begin
      ParserStates[1]:=ParserStates[0];
      CodePoint:=ParserStates[1].CodePointEnumerator.GetCurrent;
      ParserStates[1].Valid:=ParserStates[1].CodePointEnumerator.MoveNext;
      inc(ParserStates[1].CodePointIndex);
      if (CodePoint in [10,13]) or
         (ParserStates[1].CodePointIndex=fParent.fRope.fCountCodePoints) then begin
       ParserStates[1].NewLine:=ParserStates[1].NewLine or 2;
      end;
      ParserStates[1].NewLine:=ParserStates[1].NewLine shr 1;
     end;
     break;
    end;

    if (ParserStates[1].NewLine and 2)<>0 then begin
     Accept:=DFA.fAcceptEnd;
    end else begin
     Accept:=DFA.fAccept;
    end;

    if assigned(Accept) then begin
     LastAccept:=Accept;
     ParserStates[2]:=ParserStates[1];
     if (TAccept.TFlag.IsQuick in Accept.fFlags) or
        (((ParserStates[1].NewLine and 2)<>0) and
         (TAccept.TFlag.IsEnd in Accept.fFlags)) then begin
      break;
     end;
    end;

   end;

   if assigned(LastAccept) then begin
    Attribute:=LastAccept.fAttribute;
    if TAccept.TFlag.IsKeyword in LastAccept.fFlags then begin
     ParserStates[3]:=ParserStates[0];
     KeywordCharTreeNode:=fKeywordCharRootTreeNode;
     while ParserStates[3].Valid and
           (ParserStates[3].CodePointIndex<ParserStates[2].CodePointIndex) do begin
      CodePoint:=ParserStates[3].CodePointEnumerator.Current;
      if (CodePoint>=TpvUInt32(ord(Low(TKeywordCharSet)))) and (CodePoint<=TpvUInt32(ord(High(TKeywordCharSet)))) then begin
       if fCaseInsensitive and ((CodePoint>=TpvUInt32(ord('A'))) and (CodePoint<=TpvUInt32(ord('Z')))) then begin
        inc(CodePoint,ord('a')-ord('A'));
       end;
       if KeywordCharTreeNode.fHasChildren and
          assigned(KeywordCharTreeNode.fChildren[AnsiChar(TpvUInt8(CodePoint))]) then begin
        KeywordCharTreeNode:=KeywordCharTreeNode.fChildren[AnsiChar(TpvUInt8(CodePoint))];
        ParserStates[3].Valid:=ParserStates[3].CodePointEnumerator.MoveNext;
        inc(ParserStates[3].CodePointIndex);
        continue;
       end;
      end;
      break;
     end;
     if (assigned(KeywordCharTreeNode) and
         KeywordCharTreeNode.fKeyword) and not
        (ParserStates[3].Valid and
         (ParserStates[3].CodePointIndex<ParserStates[2].CodePointIndex)) then begin
      Attribute:=KeywordCharTreeNode.fAttribute;
     end;
    end;
    if TAccept.TFlag.IsPreprocessor in LastAccept.fFlags then begin
     Preprocessor:=LastAccept.fAttribute;
    end else if (Preprocessor<>TpvUInt32($ffffffff)) and
                (Attribute<>TpvTextEditor.TSyntaxHighlighting.TAttributes.Comment) then begin
     Attribute:=Preprocessor;
    end;
   end else begin
    if Preprocessor<>TpvUInt32($ffffffff) then begin
     Attribute:=Preprocessor;
    end else begin
     Attribute:=TpvTextEditor.TSyntaxHighlighting.TAttributes.Unknown;
    end;
   end;

   if (not assigned(LastState)) or
      ((LastState.fAccept<>LastAccept) or
       (LastState.fAttribute<>Attribute)) then begin
    OldCount:=length(fStates);
    if OldCount<(fCountStates+1) then begin
     SetLength(fStates,(fCountStates+1)*2);
     FillChar(fStates[OldCount],(length(fStates)-OldCount)*SizeOf(TSyntaxHighlighting.TState),#0);
    end;
    State:=TDFASyntaxHighlighting.TState.Create;
    fStates[fCountStates]:=State;
    inc(fCountStates);
    State.fCodePointIndex:=ParserStates[0].CodePointIndex;
    State.fAttribute:=Attribute;
    State.fAccept:=LastAccept;
    LastState:=State;
   end;

   if assigned(LastAccept) then begin
    ParserStates[0]:=ParserStates[2];
   end else begin
    ParserStates[0]:=ParserStates[1];
   end;

   if ParserStates[0].CodePointIndex>=fParent.fRope.fCountCodePoints then begin
    fCodePointIndex:=fParent.fRope.fCountCodePoints;
   end else begin
    fCodePointIndex:=ParserStates[0].CodePointIndex;
   end;

  end;

 end;

end;

procedure TpvTextEditor.TPascalSyntaxHighlighting.Setup;
begin
 fCaseInsensitive:=true;
 AddKeywords(['absolute','abstract','and','array','as','asm','assembler',
              'automated','begin','case','cdecl','class','const','constructor',
              'contains','default','deprecated','destructor','dispid',
              'dispinterface','div','do','downto','dynamic','else','end','except',
              'export','exports','external','far','file','final','finalization',
              'finally','for','forward','function','goto','helper','if',
              'implementation','implements','in','index','inherited',
              'initialization','inline','interface','is','label','library',
              'message','mod','name','near','nil','nodefault','not','object','of',
              'on','operator','or','out','overload','override','package','packed',
              'pascal','platform','private','procedure','program','property',
              'protected','public','published','raise','read','readonly','record',
              'register','reintroduce','repeat','requires','resourcestring',
              'safecall','sealed','set','shl','shr','stdcall','stored','string',
              'stringresource','then','threadvar','to','try','type','unit','until',
              'uses','var','virtual','while','with','write','writeonly','xor'],
             TpvTextEditor.TSyntaxHighlighting.TAttributes.Keyword);
 AddRule('['#32#9']+',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.WhiteSpace);
 AddRule('\(\*.*\*\)|\{.*\}',[TpvTextEditor.TDFASyntaxHighlighting.TAccept.TFlag.IsQuick],TpvTextEditor.TSyntaxHighlighting.TAttributes.Comment);
 AddRule('\(\*.*|\{.*',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.Comment);
 AddRule('//.*$',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.Comment); // or alternatively '//[^'#10#13']*['#10#13']?'
 AddRule('\#(\$[0-9A-Fa-f]*|[0-9]*)',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.String_);
 AddRule('\$[0-9A-Fa-f]*',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.Number);
 AddRule('[0-9]+(\.[0-9]+)?([Ee][\+\-]?[0-9]*)?',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.Number);
 AddRule('[A-Za-z\_][A-Za-z0-9\_]*',[TpvTextEditor.TDFASyntaxHighlighting.TAccept.TFlag.IsKeyword],TpvTextEditor.TSyntaxHighlighting.TAttributes.Identifier);
 AddRule('\@|\-|\+|\/|\*|\=|\<|\>|\<\>|\<\=|\>\=|\:\=|\^',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.Operator);
 AddRule('\}|\[|\]|\(|\)|\,|\.|\.\.|\:|\;|\?',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.Delimiter);
 AddRule('\''[^\'']*\''',[TpvTextEditor.TDFASyntaxHighlighting.TAccept.TFlag.IsQuick],TpvTextEditor.TSyntaxHighlighting.TAttributes.String_);
 AddRule('\''[^\'']*$',[],TpvTextEditor.TSyntaxHighlighting.TAttributes.String_);
end;

constructor TpvTextEditor.TView.Create(const aParent:TpvTextEditor);
begin
 inherited Create;
 fParent:=aParent;
 fVisibleAreaWidth:=0;
 fVisibleAreaHeight:=0;
 fNonScrollVisibleAreaWidth:=0;
 fNonScrollVisibleAreaHeight:=0;
 fVisibleAreaDirty:=false;
 fCodePointIndex:=0;
 fCursorOffset.x:=0;
 fCursorOffset.y:=0;
 fCursor.x:=0;
 fCursor.y:=0;
 fLineWrap:=0;
 fVisualLineCacheMap:=TLineCacheMap.Create(fParent.fRope);
 fBuffer:=nil;
 fMarkState.StartCodePointIndex:=-1;
 fMarkState.EndCodePointIndex:=-1;
end;

destructor TpvTextEditor.TView.Destroy;
begin
 FreeAndNil(fVisualLineCacheMap);
 fBuffer:=nil;
 inherited Destroy;
end;

procedure TpvTextEditor.TView.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fParent) then begin
  if assigned(fParent.fFirstView) then begin
   fParent.fFirstView.fNext:=self;
   fPrevious:=fParent.fFirstView;
  end else begin
   fParent.fFirstView:=self;
   fPrevious:=nil;
  end;
  fParent.fLastView:=self;
  fNext:=nil;
 end;
end;

procedure TpvTextEditor.TView.BeforeDestruction;
begin
 if assigned(fParent) then begin
  if assigned(fNext) then begin
   fNext.fPrevious:=fPrevious;
  end else if fParent.fLastView=self then begin
   fParent.fLastView:=fPrevious;
  end;
  if assigned(fPrevious) then begin
   fPrevious.fNext:=fNext;
  end else if fParent.fFirstView=self then begin
   fParent.fFirstView:=fNext;
  end;
  fPrevious:=nil;
  fNext:=nil;
 end;
 inherited BeforeDestruction;
end;

procedure TpvTextEditor.TView.SetVisibleAreaWidth(const aVisibleAreaWidth:TpvSizeInt);
begin
 if fVisibleAreaWidth<>aVisibleAreaWidth then begin
  fVisibleAreaWidth:=aVisibleAreaWidth;
  fVisibleAreaDirty:=true;
 end;
end;

procedure TpvTextEditor.TView.SetVisibleAreaHeight(const aVisibleAreaHeight:TpvSizeInt);
begin
 if fVisibleAreaHeight<>aVisibleAreaHeight then begin
  fVisibleAreaHeight:=aVisibleAreaHeight;
  fVisibleAreaDirty:=true;
 end;
end;

procedure TpvTextEditor.TView.SetNonScrollVisibleAreaWidth(const aNonScrollVisibleAreaWidth:TpvSizeInt);
begin
 if fNonScrollVisibleAreaWidth<>aNonScrollVisibleAreaWidth then begin
  fNonScrollVisibleAreaWidth:=aNonScrollVisibleAreaWidth;
  fVisibleAreaDirty:=true;
 end;
end;

procedure TpvTextEditor.TView.SetNonScrollVisibleAreaHeight(const aNonScrollVisibleAreaHeight:TpvSizeInt);
begin
 if fNonScrollVisibleAreaHeight<>aNonScrollVisibleAreaHeight then begin
  fNonScrollVisibleAreaHeight:=aNonScrollVisibleAreaHeight;
  fVisibleAreaDirty:=true;
 end;
end;

procedure TpvTextEditor.TView.SetLineWrap(const aLineWrap:TpvSizeInt);
begin
 if fLineWrap<>aLineWrap then begin
  fLineWrap:=aLineWrap;
  fVisualLineCacheMap.LineWrap:=aLineWrap;
  fVisualLineCacheMap.Update(-1,-1);
  if aLineWrap>0 then begin
   fCursorOffset.x:=0;
  end;
  EnsureCodePointIndexIsInRange;
  EnsureCursorIsVisible(true);
 end;
end;

procedure TpvTextEditor.TView.SetLineColumn(const aLineColumn:TLineColumn);
begin
 fCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(aLineColumn.Line,aLineColumn.Column);
 EnsureCodePointIndexIsInRange;
 EnsureCursorIsVisible(true);
end;

function TpvTextEditor.TView.GetMarkStartCodePointIndex:TpvSizeInt;
begin
 result:=fMarkState.StartCodePointIndex;
end;

procedure TpvTextEditor.TView.SetMarkStartCodePointIndex(const aMarkStartCodePointIndex:TpvSizeInt);
begin
 if fMarkState.StartCodePointIndex<>aMarkStartCodePointIndex then begin
  fMarkState.StartCodePointIndex:=Min(Max(aMarkStartCodePointIndex,-1),fParent.fRope.fCountCodePoints-1);
 end;
end;

function TpvTextEditor.TView.GetMarkEndCodePointIndex:TpvSizeInt;
begin
 result:=fMarkState.EndCodePointIndex;
end;

procedure TpvTextEditor.TView.SetMarkEndCodePointIndex(const aMarkEndCodePointIndex:TpvSizeInt);
begin
 if fMarkState.EndCodePointIndex<>aMarkEndCodePointIndex then begin
  fMarkState.EndCodePointIndex:=Min(Max(aMarkEndCodePointIndex,-1),fParent.fRope.fCountCodePoints-1);
 end;
end;

procedure TpvTextEditor.TView.ClampMarkCodePointIndices;
begin
 if (fMarkState.StartCodePointIndex>=0) and (fMarkState.EndCodePointIndex>=0) then begin
  fMarkState.StartCodePointIndex:=Min(Max(fMarkState.StartCodePointIndex,-1),fParent.fRope.fCountCodePoints-1);
  fMarkState.EndCodePointIndex:=Min(Max(fMarkState.EndCodePointIndex,-1),fParent.fRope.fCountCodePoints-1);
 end else begin
  fMarkState.StartCodePointIndex:=-1;
  fMarkState.EndCodePointIndex:=-1;
 end;
end;

procedure TpvTextEditor.TView.EnsureCodePointIndexIsInRange;
begin
 fCodePointIndex:=Min(Max(fCodePointIndex,0),fParent.fRope.CountCodePoints);
end;

procedure TpvTextEditor.TView.EnsureCursorIsVisible(const aUpdateCursor:boolean=true;const aForceVisibleLines:TpvSizeInt=1);
var CurrentLineIndex,CurrentColumnIndex:TpvSizeInt;
begin

 if fVisualLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,CurrentLineIndex,CurrentColumnIndex) then begin

  if CurrentLineIndex<fCursorOffset.y then begin
   fCursorOffset.y:=CurrentLineIndex;
  end else if (fCursorOffset.y+NonScrollVisibleAreaHeight)<(CurrentLineIndex+aForceVisibleLines) then begin
   fCursorOffset.y:=(CurrentLineIndex+aForceVisibleLines)-NonScrollVisibleAreaHeight;
  end;

  fVisualLineCacheMap.Update(-1,fVisualLineCacheMap.fCountLines+(fNonScrollVisibleAreaHeight*2));

  if fCursorOffset.y>=(fVisualLineCacheMap.fCountLines-NonScrollVisibleAreaHeight) then begin
   fCursorOffset.y:=fVisualLineCacheMap.fCountLines-fNonScrollVisibleAreaHeight;
  end;

  if fCursorOffset.y<0 then begin
   fCursorOffset.y:=0;
  end;

  if CurrentColumnIndex<fCursorOffset.x then begin
   fCursorOffset.x:=CurrentColumnIndex;
  end else if (fCursorOffset.x+NonScrollVisibleAreaWidth)<=CurrentColumnIndex then begin
   fCursorOffset.x:=(CurrentColumnIndex-NonScrollVisibleAreaWidth)+1;
  end;

  if fCursorOffset.x<0 then begin
   fCursorOffset.x:=0;
  end;

  if aUpdateCursor then begin
   fCursor.x:=CurrentColumnIndex-fCursorOffset.x;
   fCursor.y:=CurrentLineIndex-fCursorOffset.y;
  end;

 end;

 if aUpdateCursor and fParent.fLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,CurrentLineIndex,CurrentColumnIndex) then begin
  fLineColumn.Line:=CurrentLineIndex;
  fLineColumn.Column:=CurrentColumnIndex;
 end;

end;

procedure TpvTextEditor.TView.UpdateCursor;
var CurrentLineIndex,CurrentColumnIndex:TpvSizeInt;
begin
 if fVisualLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,CurrentLineIndex,CurrentColumnIndex) then begin
  fCursor.x:=CurrentColumnIndex-fCursorOffset.x;
  fCursor.y:=CurrentLineIndex-fCursorOffset.y;
 end;
 if fParent.fLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,CurrentLineIndex,CurrentColumnIndex) then begin
  fLineColumn.Line:=CurrentLineIndex;
  fLineColumn.Column:=CurrentColumnIndex;
 end;
end;

procedure TpvTextEditor.TView.UpdateBuffer;
const EmptyBufferItem:TBufferItem=
       (
        Attribute:0;
        CodePoint:32;
       );
var BufferSize,BufferBaseIndex,BufferBaseEndIndex,BufferIndex,
    CurrentLineIndex,StartCodePointIndex,StopCodePointIndex,
    CurrentCodePointIndex,StepWidth,StateIndex:TpvSizeInt;
    CodePoint,IncomingCodePoint,CurrentAttribute:TpvUInt32;
    RelativeCursor:TCoordinate;
    CodePointEnumerator:TRope.TCodePointEnumerator;
    BufferItem:PBufferItem;
begin

 ClampMarkCodePointIndices;

 EnsureCodePointIndexIsInRange;

 EnsureCursorIsVisible(true);

 BufferSize:=VisibleAreaWidth*VisibleAreaHeight;

 CodePointEnumerator.fFirst:=true; // for to suppress compiler-warning

 if BufferSize>0 then begin

  if length(fBuffer)<>BufferSize then begin
   SetLength(fBuffer,BufferSize);
  end;

  for BufferIndex:=0 to BufferSize-1 do begin
   fBuffer[BufferIndex]:=EmptyBufferItem;
  end;

  BufferBaseIndex:=0;

  RelativeCursor.y:=-fCursorOffset.y;

  CurrentCodePointIndex:=-1;

  StateIndex:=0;

  for CurrentLineIndex:=fCursorOffset.y to fCursorOffset.y+(VisibleAreaHeight-1) do begin

   StartCodePointIndex:=fVisualLineCacheMap.GetCodePointIndexFromLineIndex(CurrentLineIndex);
   if (StartCodePointIndex<0) or
      (StartCodePointIndex>=fParent.fRope.fCountCodePoints) then begin
    break;
   end;

   StopCodePointIndex:=fVisualLineCacheMap.GetCodePointIndexFromNextLineIndexOrTextEnd(CurrentLineIndex);

   BufferBaseEndIndex:=BufferBaseIndex+VisibleAreaWidth;

   if BufferBaseEndIndex>BufferSize then begin
    BufferBaseEndIndex:=BufferSize;
   end;

   BufferIndex:=BufferBaseIndex;

   RelativeCursor.x:=-fCursorOffset.x;

   if CurrentCodePointIndex<>StartCodePointIndex then begin

    CurrentCodePointIndex:=StartCodePointIndex;

    CodePointEnumerator:=TRope.TCodePointEnumerator.Create(fParent.fRope,StartCodePointIndex,-1);

   end;

   if assigned(fParent.fSyntaxHighlighting) then begin

    fParent.fSyntaxHighlighting.Update(StopCodePointIndex);

    if not (((StateIndex+1)<fParent.fSyntaxHighlighting.fCountStates) and
            (fParent.fSyntaxHighlighting.fStates[StateIndex].fCodePointIndex<=StartCodePointIndex) and
            (StartCodePointIndex<fParent.fSyntaxHighlighting.fStates[StateIndex+1].fCodePointIndex)) then begin
     StateIndex:=fParent.fSyntaxHighlighting.GetStateIndexFromCodePointIndex(StartCodePointIndex);
    end;

    if StateIndex<fParent.fSyntaxHighlighting.fCountStates then begin
     CurrentAttribute:=fParent.fSyntaxHighlighting.fStates[StateIndex].fAttribute;
    end else begin
     CurrentAttribute:=0;
    end;

   end else begin

    StateIndex:=0;

    CurrentAttribute:=0;

   end;

   while (CurrentCodePointIndex<StopCodePointIndex) and
         CodePointEnumerator.MoveNext do begin

    if assigned(fParent.fSyntaxHighlighting) then begin

     while ((StateIndex+1)<fParent.fSyntaxHighlighting.fCountStates) and
           (fParent.fSyntaxHighlighting.fStates[StateIndex+1].fCodePointIndex<=CurrentCodePointIndex) do begin
      inc(StateIndex);
      CurrentAttribute:=fParent.fSyntaxHighlighting.fStates[StateIndex].fAttribute;
     end;

    end;

    IncomingCodePoint:=CodePointEnumerator.GetCurrent;

    case IncomingCodePoint of
     $09:begin
      CodePoint:=32;
      StepWidth:=Max(1,(fVisualLineCacheMap.fTabWidth-(RelativeCursor.x mod fVisualLineCacheMap.fTabWidth)));
     end;
     $0a,$0d:begin
      CodePoint:=32;
      StepWidth:=0;
     end;
     else begin
      CodePoint:=IncomingCodePoint;
      StepWidth:=1;
     end;
    end;

    while StepWidth>0 do begin

     if RelativeCursor.x>=0 then begin

      BufferIndex:=BufferBaseIndex+RelativeCursor.x;

      if (BufferIndex>=BufferBaseIndex) and
         (BufferIndex<BufferBaseEndIndex) then begin
       BufferItem:=@fBuffer[BufferIndex];
       BufferItem^.Attribute:=CurrentAttribute;
       BufferItem^.CodePoint:=CodePoint;
      end;

     end;

     CodePoint:=0;

     inc(RelativeCursor.x);
     dec(StepWidth);

    end;

    inc(CurrentCodePointIndex);

   end;

   inc(BufferBaseIndex,VisibleAreaWidth);

   inc(RelativeCursor.y);

  end;

 end;

end;

procedure TpvTextEditor.TView.MarkAll;
begin
 if fParent.fRope.fCountCodePoints>0 then begin
  fMarkState.StartCodePointIndex:=0;
  fMarkState.EndCodePointIndex:=fParent.fRope.fCountCodePoints-1;
 end else begin
  fMarkState.StartCodePointIndex:=-1;
  fMarkState.EndCodePointIndex:=-1;
 end;
end;

procedure TpvTextEditor.TView.UnmarkAll;
begin
 fMarkState.StartCodePointIndex:=-1;
 fMarkState.EndCodePointIndex:=-1;
end;

procedure TpvTextEditor.TView.SetMarkStart;
begin
 fMarkState.StartCodePointIndex:=fCodePointIndex;
 fMarkState.EndCodePointIndex:=fCodePointIndex;
end;

procedure TpvTextEditor.TView.SetMarkEndToHere;
begin
 fMarkState.EndCodePointIndex:=fCodePointIndex;
end;

procedure TpvTextEditor.TView.SetMarkEndUntilHere;
begin
 fMarkState.EndCodePointIndex:=fCodePointIndex-1;
end;

function TpvTextEditor.TView.HasMarkedRange:boolean;
begin
 result:=((fMarkState.StartCodePointIndex>=0) and
          (fMarkState.StartCodePointIndex<fParent.fRope.fCountCodePoints)) and
         ((fMarkState.EndCodePointIndex>=0) and
          (fMarkState.EndCodePointIndex<fParent.fRope.fCountCodePoints));
end;

function TpvTextEditor.TView.GetMarkedRangeText:TpvUTF8String;
var StartCodePointIndex,EndCodePointIndex:TpvSizeInt;
begin
 if HasMarkedRange then begin
  StartCodePointIndex:=Min(fMarkState.StartCodePointIndex,fMarkState.EndCodePointIndex);
  EndCodePointIndex:=Max(fMarkState.StartCodePointIndex,fMarkState.EndCodePointIndex);
  result:=fParent.fRope.Extract(StartCodePointIndex,(EndCodePointIndex-StartCodePointIndex)+1);
 end else begin
  result:='';
 end;
end;

function TpvTextEditor.TView.DeleteMarkedRange:boolean;
var StartCodePointIndex,EndCodePointIndex,Count:TpvSizeInt;
begin
 result:=HasMarkedRange;
 if result then begin
  StartCodePointIndex:=Min(fMarkState.StartCodePointIndex,fMarkState.EndCodePointIndex);
  EndCodePointIndex:=Max(fMarkState.StartCodePointIndex,fMarkState.EndCodePointIndex);
  fCodePointIndex:=StartCodePointIndex;
  Count:=(EndCodePointIndex-StartCodePointIndex)+1;
  fParent.fUndoRedoManager.Add(TUndoRedoCommandDelete.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex,Count,fParent.fRope.Extract(fCodePointIndex,Count)));
  fParent.fRope.Delete(fCodePointIndex,Count);
  if fCodePointIndex>0 then begin
   fParent.LineMapTruncate(fCodePointIndex-1,-1);
   if assigned(fParent.fSyntaxHighlighting) then begin
    fParent.fSyntaxHighlighting.Truncate(fCodePointIndex-1);
   end;
  end else begin
   fParent.LineMapTruncate(fCodePointIndex,-1);
   if assigned(fParent.fSyntaxHighlighting) then begin
    fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
   end;
  end;
  fParent.EnsureViewCursorsAreVisible(true);
  fParent.ResetViewMarkCodePointIndices;
 end;
end;

function TpvTextEditor.TView.CutMarkedRangeText:TpvUTF8String;
var StartCodePointIndex,EndCodePointIndex,Count:TpvSizeInt;
begin
 if HasMarkedRange then begin
  StartCodePointIndex:=Min(fMarkState.StartCodePointIndex,fMarkState.EndCodePointIndex);
  EndCodePointIndex:=Max(fMarkState.StartCodePointIndex,fMarkState.EndCodePointIndex);
  fCodePointIndex:=StartCodePointIndex;
  Count:=(EndCodePointIndex-StartCodePointIndex)+1;
  fParent.fUndoRedoManager.Add(TUndoRedoCommandDelete.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex,Count,fParent.fRope.Extract(fCodePointIndex,Count)));
  result:=fParent.fRope.Extract(fCodePointIndex,Count);
  fParent.fRope.Delete(fCodePointIndex,Count);
  if fCodePointIndex>0 then begin
   fParent.LineMapTruncate(fCodePointIndex-1,-1);
   if assigned(fParent.fSyntaxHighlighting) then begin
    fParent.fSyntaxHighlighting.Truncate(fCodePointIndex-1);
   end;
  end else begin
   fParent.LineMapTruncate(fCodePointIndex,-1);
   if assigned(fParent.fSyntaxHighlighting) then begin
    fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
   end;
  end;
  fParent.EnsureViewCursorsAreVisible(true);
  fParent.ResetViewMarkCodePointIndices;
 end else begin
  result:='';
 end;
end;

procedure TpvTextEditor.TView.InsertCodePoint(const aCodePoint:TpvUInt32;const aOverwrite:boolean;const aStealIt:boolean=false);
var Count,UndoRedoHistoryIndex:TpvSizeInt;
    CodeUnits:TpvUTF8String;
    HasDeletedMarkedRange:boolean;
    UndoRedoCommand:TpvTextEditor.TUndoRedoCommand;
begin
 UndoRedoHistoryIndex:=fParent.fUndoRedoManager.fHistoryIndex;
 HasDeletedMarkedRange:=DeleteMarkedRange;
 CodeUnits:=TUTF8Utils.UTF32CharToUTF8(aCodePoint);
 fParent.LineMapTruncate(fCodePointIndex,-1);
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 if aOverwrite and (fCodePointIndex<fParent.fRope.fCountCodePoints) then begin
  if fParent.IsTwoCodePointNewLine(fCodePointIndex) then begin
   Count:=2;
  end else begin
   Count:=1;
  end;
  UndoRedoCommand:=TUndoRedoCommandOverwrite.Create(fParent,fCodePointIndex,fCodePointIndex+Count,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex,Count,CodeUnits,fParent.fRope.Extract(fCodePointIndex,Count));
  UndoRedoCommand.fSealed:=aStealIt;
  fParent.fUndoRedoManager.Add(UndoRedoCommand);
  fParent.fRope.Delete(fCodePointIndex,Count);
  fParent.fRope.Insert(fCodePointIndex,CodeUnits);
 end else begin
  UndoRedoCommand:=TUndoRedoCommandInsert.Create(fParent,fCodePointIndex,fCodePointIndex+1,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex,1,CodeUnits);
  UndoRedoCommand.fSealed:=aStealIt;
  fParent.fUndoRedoManager.Add(UndoRedoCommand);
  fParent.fRope.Insert(fCodePointIndex,CodeUnits);
 end;
 if HasDeletedMarkedRange then begin
  fParent.fUndoRedoManager.GroupUndoRedoCommands(UndoRedoHistoryIndex,fParent.fUndoRedoManager.fHistoryIndex);
 end;
 fParent.UpdateViewCodePointIndices(fCodePointIndex,1);
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
 fParent.ResetViewMarkCodePointIndices;
end;

procedure TpvTextEditor.TView.InsertString(const aCodeUnits:TpvUTF8String;const aOverwrite:boolean;const aStealIt:boolean=false);
var CountCodePoints,Count,UndoRedoHistoryIndex:TpvSizeInt;
    HasDeletedMarkedRange:boolean;
    UndoRedoCommand:TpvTextEditor.TUndoRedoCommand;
begin
 UndoRedoHistoryIndex:=fParent.fUndoRedoManager.fHistoryIndex;
 HasDeletedMarkedRange:=DeleteMarkedRange;
 CountCodePoints:=TRope.GetCountCodePoints(@aCodeUnits[1],length(aCodeUnits));
 fParent.LineMapTruncate(fCodePointIndex,-1);
 if assigned(fParent.fSyntaxHighlighting) then begin
  fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
 end;
 if aOverwrite and (fCodePointIndex<fParent.fRope.fCountCodePoints) then begin
  if fParent.IsTwoCodePointNewLine(fCodePointIndex) then begin
   Count:=2;
  end else begin
   Count:=1;
  end;
  UndoRedoCommand:=TUndoRedoCommandDelete.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,CountCodePoints,(CountCodePoints+Count)-1,fParent.fRope.Extract(fCodePointIndex,(CountCodePoints+Count)-1));
  UndoRedoCommand.fSealed:=aStealIt;
  fParent.fUndoRedoManager.Add(UndoRedoCommand);
  fParent.fRope.Delete(fCodePointIndex,(CountCodePoints+Count)-1);
  UndoRedoCommand:=TUndoRedoCommandInsert.Create(fParent,fCodePointIndex,fCodePointIndex+(CountCodePoints+Count)-1,TpvTextEditor.EmptyMarkState,fMarkState,CountCodePoints,(CountCodePoints+Count)-1,aCodeUnits);
  UndoRedoCommand.fSealed:=aStealIt;
  fParent.fUndoRedoManager.Add(UndoRedoCommand);
  fParent.fRope.Insert(fCodePointIndex,aCodeUnits);
 end else begin
  UndoRedoCommand:=TUndoRedoCommandInsert.Create(fParent,fCodePointIndex,fCodePointIndex+CountCodePoints,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex,CountCodePoints,aCodeUnits);
  UndoRedoCommand.fSealed:=aStealIt;
  fParent.fUndoRedoManager.Add(UndoRedoCommand);
  fParent.fRope.Insert(fCodePointIndex,aCodeUnits);
 end;
 if HasDeletedMarkedRange then begin
  fParent.fUndoRedoManager.GroupUndoRedoCommands(UndoRedoHistoryIndex,fParent.fUndoRedoManager.fHistoryIndex);
 end;
 fParent.UpdateViewCodePointIndices(fCodePointIndex,CountCodePoints);
 fParent.EnsureViewCodePointIndicesAreInRange;
 fParent.EnsureViewCursorsAreVisible(true);
 fParent.ResetViewMarkCodePointIndices;
end;

procedure TpvTextEditor.TView.Backspace;
var Count:TpvSizeInt;
begin
 if not DeleteMarkedRange then begin
  if (fCodePointIndex>0) and (fCodePointIndex<=fParent.fRope.fCountCodePoints) then begin
   if fparent.IsTwoCodePointNewLine(fCodePointIndex-2) then begin
    Count:=2;
   end else begin
    Count:=1;
   end;
   fParent.fUndoRedoManager.Add(TUndoRedoCommandDelete.Create(fParent,fCodePointIndex,fCodePointIndex-Count,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex-Count,Count,fParent.fRope.Extract(fCodePointIndex-Count,Count)));
   fParent.UpdateViewCodePointIndices(fCodePointIndex,-Count);
   fParent.fRope.Delete(fCodePointIndex,Count);
   if fCodePointIndex>0 then begin
    fParent.LineMapTruncate(fCodePointIndex-1,-1);
    if assigned(fParent.fSyntaxHighlighting) then begin
     fParent.fSyntaxHighlighting.Truncate(fCodePointIndex-1);
    end;
   end else begin
    fParent.LineMapTruncate(fCodePointIndex,-1);
    if assigned(fParent.fSyntaxHighlighting) then begin
     fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
    end;
   end;
  end;
  fParent.EnsureViewCodePointIndicesAreInRange;
  fParent.EnsureViewCursorsAreVisible(true);
  fParent.ResetViewMarkCodePointIndices;
 end;
end;

procedure TpvTextEditor.TView.Paste(const aText:TpvUTF8String);
begin
 InsertString(aText,false,true);
end;

procedure TpvTextEditor.TView.Delete;
var Count:TpvSizeInt;
begin
 if not DeleteMarkedRange then begin
  if fCodePointIndex<fParent.fRope.fCountCodePoints then begin
   if fParent.IsTwoCodePointNewLine(fCodePointIndex) then begin
    Count:=2;
   end else begin
    Count:=1;
   end;
   fParent.fUndoRedoManager.Add(TUndoRedoCommandDelete.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,fCodePointIndex,Count,fParent.fRope.Extract(fCodePointIndex,Count)));
   fParent.fRope.Delete(fCodePointIndex,Count);
   if fCodePointIndex>0 then begin
    fParent.LineMapTruncate(fCodePointIndex-1,-1);
    if assigned(fParent.fSyntaxHighlighting) then begin
     fParent.fSyntaxHighlighting.Truncate(fCodePointIndex-1);
    end;
   end else begin
    fParent.LineMapTruncate(fCodePointIndex,-1);
    if assigned(fParent.fSyntaxHighlighting) then begin
     fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
    end;
   end;
  end;
  fParent.EnsureViewCursorsAreVisible(true);
  fParent.ResetViewMarkCodePointIndices;
 end;
end;

procedure TpvTextEditor.TView.Enter(const aOverwrite:boolean);
begin
 if aOverwrite then begin
  MoveDown;
  MoveToLineBegin;
 end else begin
{$ifdef Windows}
  InsertString(TpvUTF8String(#13#10),aOverwrite,false);
{$else}
  InsertCodePoint(10,aOverwrite,false);
{$endif}
 end;
 fParent.UpdateViewCursors;
end;

procedure TpvTextEditor.TView.MoveUp;
var LineIndex,ColumnIndex,NewCodePointIndex:TpvSizeInt;
begin
 if fCodePointIndex<=fParent.fRope.CountCodePoints then begin
  fVisualLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,LineIndex,ColumnIndex);
  if LineIndex>=0 then begin
   NewCodePointIndex:=fVisualLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(LineIndex-1,ColumnIndex);
   if NewCodePointIndex>=0 then begin
    fCodePointIndex:=NewCodePointIndex;
   end;
  end;
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MoveDown;
var LineIndex,ColumnIndex,NewCodePointIndex:TpvSizeInt;
begin
 if fCodePointIndex<fParent.fRope.CountCodePoints then begin
  fVisualLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,LineIndex,ColumnIndex);
  if LineIndex>=0 then begin
   NewCodePointIndex:=fVisualLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(LineIndex+1,ColumnIndex);
   if NewCodePointIndex>=0 then begin
    fCodePointIndex:=NewCodePointIndex;
   end;
  end;
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MoveLeft;
var Count:TpvSizeInt;
begin
 if fCodePointIndex>0 then begin
  if fParent.IsTwoCodePointNewLine(fCodePointIndex-2) then begin
   Count:=2;
  end else begin
   Count:=1;
  end;
  dec(fCodePointIndex,Count);
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MoveRight;
var Count:TpvSizeInt;
begin
 if fCodePointIndex<fParent.fRope.CountCodePoints then begin
  if fParent.IsTwoCodePointNewLine(fCodePointIndex) then begin
   Count:=2;
  end else begin
   Count:=1;
  end;
  inc(fCodePointIndex,Count);
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MoveToLineBegin;
var LineIndex:TpvSizeInt;
begin
 if fCodePointIndex<fParent.fRope.CountCodePoints then begin
  LineIndex:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(fCodePointIndex);
  fCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromLineIndex(LineIndex);
 end else if (fCodePointIndex>0) and (fCodePointIndex>=fParent.fRope.CountCodePoints) then begin
  LineIndex:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(fParent.fRope.CountCodePoints);
  fCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromLineIndex(LineIndex);
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MoveToLineEnd;
var LineIndex,NewCodePointIndex:TpvSizeInt;
begin
 if fCodePointIndex<=fParent.fRope.CountCodePoints then begin
  LineIndex:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(fCodePointIndex);
  if LineIndex>=0 then begin
   NewCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(LineIndex,High(TpvSizeInt));
   if NewCodePointIndex>=0 then begin
    fCodePointIndex:=NewCodePointIndex;
   end;
  end;
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MovePageUp;
var LineIndex,ColumnIndex,NewCodePointIndex:TpvSizeInt;
begin
 if fCodePointIndex<=fParent.fRope.CountCodePoints then begin
  fVisualLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,LineIndex,ColumnIndex);
  if LineIndex>=0 then begin
   NewCodePointIndex:=fVisualLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(Max(0,LineIndex-fNonScrollVisibleAreaHeight),ColumnIndex);
   if NewCodePointIndex>=0 then begin
    fCodePointIndex:=NewCodePointIndex;
   end;
   if fCursorOffset.y<fNonScrollVisibleAreaHeight then begin
    fCursorOffset.y:=0;
   end else begin
    dec(fCursorOffset.y,fNonScrollVisibleAreaHeight);
   end;
  end;
  EnsureCodePointIndexIsInRange;
  EnsureCursorIsVisible(true);
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.MovePageDown;
var LineIndex,ColumnIndex,NewCodePointIndex:TpvSizeInt;
begin
 if fCodePointIndex<=fParent.fRope.CountCodePoints then begin
  fVisualLineCacheMap.GetLineIndexAndColumnIndexFromCodePointIndex(fCodePointIndex,LineIndex,ColumnIndex);
  if LineIndex>=0 then begin
   fVisualLineCacheMap.Update(-1,LineIndex+fNonScrollVisibleAreaHeight+1);
   NewCodePointIndex:=fVisualLineCacheMap.GetCodePointIndexFromLineIndexAndColumnIndex(Max(0,Min(LineIndex+fNonScrollVisibleAreaHeight,fVisualLineCacheMap.fCountLines-1)),ColumnIndex);
   if NewCodePointIndex>=0 then begin
    fCodePointIndex:=NewCodePointIndex;
   end;
   if (fCursorOffset.y+fNonScrollVisibleAreaHeight)>=fVisualLineCacheMap.fCountLines then begin
    fCursorOffset.y:=fVisualLineCacheMap.fCountLines-1;
   end else begin
    inc(fCursorOffset.y,fNonScrollVisibleAreaHeight);
   end;
  end;
  EnsureCodePointIndexIsInRange;
  EnsureCursorIsVisible(true);
 end;
 fParent.fUndoRedoManager.IncreaseActionID;
end;

procedure TpvTextEditor.TView.InsertLine;
var LineIndex,LineCodePointIndex:TpvSizeInt;
begin
 LineIndex:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(fCodePointIndex);
 if LineIndex>=0 then begin
  LineCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromLineIndex(LineIndex);
  fParent.LineMapTruncate(LineCodePointIndex,-1);
  if assigned(fParent.fSyntaxHighlighting) then begin
   fParent.fSyntaxHighlighting.Truncate(fCodePointIndex);
  end;
{$ifdef Windows}
  fParent.fUndoRedoManager.Add(TUndoRedoCommandInsert.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,LineCodePointIndex,2,#13#10));
  fParent.fRope.Insert(LineCodePointIndex,TpvUTF8String(#13#10));
  fParent.UpdateViewCodePointIndices(LineCodePointIndex,2);
{$else}
  fParent.fUndoRedoManager.Add(TUndoRedoCommandInsert.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,LineCodePointIndex,1,#10));
  fParent.fRope.Insert(LineCodePointIndex,TpvUTF8String(#10));
  fParent.UpdateViewCodePointIndices(LineCodePointIndex,1);
{$endif}
  fParent.EnsureViewCodePointIndicesAreInRange;
  fParent.EnsureViewCursorsAreVisible(true);
  fParent.ResetViewMarkCodePointIndices;
 end;
end;

procedure TpvTextEditor.TView.DeleteLine;
var LineIndex,StartCodePointIndex,StopCodePointIndex:TpvSizeInt;
begin
 LineIndex:=fParent.fLineCacheMap.GetLineIndexFromCodePointIndex(fCodePointIndex);
 if LineIndex>=0 then begin
  StartCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromLineIndex(LineIndex);
  StopCodePointIndex:=fParent.fLineCacheMap.GetCodePointIndexFromNextLineIndexOrTextEnd(LineIndex);
  if (StartCodePointIndex>=0) and
     (StartCodePointIndex<StopCodePointIndex) then begin
   fParent.fUndoRedoManager.Add(TUndoRedoCommandDelete.Create(fParent,fCodePointIndex,fCodePointIndex,TpvTextEditor.EmptyMarkState,fMarkState,StartCodePointIndex,StopCodePointIndex-StartCodePointIndex,fParent.fRope.Extract(StartCodePointIndex,StopCodePointIndex-StartCodePointIndex)));
   fParent.fRope.Delete(StartCodePointIndex,StopCodePointIndex-StartCodePointIndex);
   fParent.LineMapTruncate(Max(0,StartCodePointIndex)-1,-1);
   if assigned(fParent.fSyntaxHighlighting) then begin
    fParent.fSyntaxHighlighting.Truncate(Max(0,StartCodePointIndex)-1);
   end;
   fParent.UpdateViewCodePointIndices(fCodePointIndex,StartCodePointIndex-fCodePointIndex);
   fParent.EnsureViewCodePointIndicesAreInRange;
   fParent.EnsureViewCursorsAreVisible(true);
   fParent.ResetViewMarkCodePointIndices;
  end;
 end;
end;

procedure TpvTextEditor.TView.Undo;
begin
 fParent.Undo(self);
end;

procedure TpvTextEditor.TView.Redo;
begin
 fParent.Redo(self);
end;

end.
