object Form1: TForm1
  Left = 252
  Top = 125
  Width = 892
  Height = 635
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077': '#1089#1090#1088#1077#1083#1082#1080', ESC - '#1089#1084#1077#1085#1072' '#1088#1077#1078#1080#1084#1072' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 16
  object PanelL: TPanel
    Left = 10
    Top = 10
    Width = 70
    Height = 50
    BevelOuter = bvNone
    Caption = 'click me'
    Color = clRed
    TabOrder = 0
    OnClick = PanelClick
  end
  object PanelR: TPanel
    Left = 89
    Top = 10
    Width = 70
    Height = 50
    BevelOuter = bvNone
    Caption = 'click me'
    Color = clBlue
    TabOrder = 1
    OnClick = PanelClick
  end
  object ColorDialog1: TColorDialog
    Left = 504
    Top = 104
  end
end
