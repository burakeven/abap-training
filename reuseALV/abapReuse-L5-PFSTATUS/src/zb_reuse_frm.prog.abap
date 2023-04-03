*&---------------------------------------------------------------------*
*& Include          ZB_REUSE_FRM
*&---------------------------------------------------------------------*

FORM set_getdata .
  SELECT sbook~carrid, sbook~connid, sbook~fldate, sflight~price, sbook~loccurkey
    FROM sbook
    INNER JOIN sflight ON sbook~carrid = sflight~carrid AND
                    sbook~connid = sflight~connid AND
                    sbook~fldate = sflight~fldate AND
                    sbook~loccurkey = sflight~currency INTO CORRESPONDING FIELDS OF TABLE @gt_list.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name   = sy-repid "Program adini yazmaktansa bunu yaziyoruz.
      "i_internal_tabname = 'GT_LIST'
      i_structure_name = 'ZBK_EGT_0022_S'
      i_inclname       = sy-repid
    CHANGING
      ct_fieldcat      = gt_field_catalog.


*  PERFORM: set_fc_sub USING 'Ucak' 'Ucak Grup' 'Ucak Gruplandırma' 'X' 'CONNID', "Buradaki X abap_true anlamina gelir.
*           set_fc_sub USING 'Bolum' 'Bolum Grup' 'Bolum Gruplandırma' 'X' 'CARRID',
*           set_fc_sub USING 'Fiyat' 'Fiyat Ü.' 'Fiyat Açıklaması' '' 'PRICE', "Buradaki '' abap_false anlamina gelir.
*           set_fc_sub USING 'Tarih' 'Uçuş Ta.' 'Uçus Tarihi' '' 'FLDATE'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_lay .
  gs_layout-window_titlebar = 'YENI TEST REUSE ALV'. "Adi ustunde title-bar atar.
  gs_layout-zebra = abap_true. "Satir renkleri zebra desenini aldi.
  "gs_layout-colwidth_optimize = abap_true. "Sistematik sekilde satir ici uzunluklara gore genislikleri belirler.
  "gs_layout-edit = abap_true. "Tiklanilabilir yapar, tum hucre icleri beyaz olur.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
  gs_event-name = slis_ev_top_of_page.
  gs_event-form = 'TOP_OF_PAGE'.
  APPEND gs_event TO gt_events.
  gs_event-name = slis_ev_end_of_list.
  gs_event-form = 'END_OF_LIST'.
  APPEND gs_event TO gt_events.

  gs_event-name = slis_ev_pf_status_set.
  gs_event-form = 'PF_STATUS_SET'.
  APPEND gs_event TO gt_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      i_callback_program = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = 'PF_STATUS_SET'
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      is_layout          = gs_layout
      it_fieldcat        = gt_field_catalog
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     IT_SORT            =
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = ' '
*     IS_VARIANT         =
      it_events          = gt_events
*     IT_EVENT_EXIT      =
*     IS_PRINT           =
*     IS_REPREP_ID       =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  = 0
*     I_HTML_HEIGHT_END  = 0
*     IT_ALV_GRAPHICS    =
*     IT_HYPERLINK       =
*     IT_ADD_FIELDCAT    =
*     IT_EXCEPT_QINFO    =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab           = gt_list
* EXCEPTIONS
*     PROGRAM_ERROR      = 1
*     OTHERS             = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM top_of_page .
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader,
        lv_date type char10.

  data: lv_lines type i,
        lv_lines_c type char4.

  CLEAR: ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Uçak bilet mevzusu'.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Tarih:'.
*  ls_header-info = '31.03.2023'. "Boyle oldugu vakit dinamik olmuyor.
  CONCATENATE sy-datum+6(2)
              '.'
              sy-datum+4(2)
              '.'
              sy-datum+0(4) INTO lv_date.
   ls_header-info = lv_date.
  APPEND ls_header TO lt_header.

  CLEAR: ls_header.

  DESCRIBE TABLE gt_list LINES lv_lines. "gt_list tablosunda kac satir oldugunu lv_lines icerisine bunun bilgisini verir.
  lv_lines_c = lv_lines. "concatenate'de lv_lines'ı kullanamiyoruz cunku integer
  "... bunu char4 olarak atayip o sekilde gosterim yapiyoruz.

  ls_header-typ = 'A'.
*  ls_header-info = 'Raporda 50 adet bilet alımı vardır.'.
  CONCATENATE 'Raporda'
              lv_lines_c
              'adet bilet alımı vardır.' INTO ls_header-info SEPARATED BY space.

  APPEND ls_header TO lt_header.

*  ls_header-typ = 'H'.
*  ls_header-info = 'Uçak bilet mevzusu'.
*  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header
*     I_LOGO             =
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .
ENDFORM.
FORM end_of_list .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_FC_SUB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fc_sub USING p_seltext_s.
*                      p_seltext_m
*                      p_seltext_l
*                      p_key
*                      p_fieldname.
*  CLEAR: gs_field_catalog.
*  gs_field_catalog-seltext_s = p_seltext_s.
*  gs_field_catalog-seltext_m = p_seltext_m.
*  gs_field_catalog-seltext_l = p_seltext_l.
*  gs_field_catalog-key = p_key.
*  gs_field_catalog-fieldname = p_fieldname.
*  APPEND gs_field_catalog TO gt_field_catalog.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pf_status_set USING p_extab TYPE slis_t_extab .
    set PF-STATUS '0300'.
ENDFORM.
