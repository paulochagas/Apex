/*
Get Handler for Generate reports from ORDS to excel using webquery


*/

    DECLARE
        --
        l_sql    CLOB := 'SELECT * FROM xsech_item_summary WHERE organization_id = :organization_id and ( item_code = '':item_code'' OR '':item_code'' = ''%'')';
        l_tsv    CLOB;
        l_offset PLS_INTEGER := 1;
        l_chunk  VARCHAR2(32767);
        l_chunk_size CONSTANT PLS_INTEGER := 32767;
        l_line        VARCHAR2(32767 CHAR);      
        --
        l_start       PLS_INTEGER := 1;
        l_end         PLS_INTEGER;
        l_tsv_len     PLS_INTEGER;     
        l_user        VARCHAR2(100);             
        
    BEGIN
        --
        --l_user := ORDS.get_headers('X-User');

        --
        l_sql := REPLACE(l_sql, ':organization_id', :organization_id);
        l_sql := REPLACE(l_sql, ':item_code', REPLACE(:item_code, '''', ''''''));
        --
        sys.htp.init;
        -- Generate TSV
        l_tsv       := apps.xxx_utils_ords.get_tsv_with_header(l_sql);
        l_tsv_len   := DBMS_LOB.getlength(l_tsv);        

        -- HTTP Header
        owa_util.mime_header('text/csv; charset=UTF-8', FALSE);
        htp.p('Content-Disposition: attachment; filename="item_summary.csv"');
        owa_util.http_header_close;

        -- Manual loop line by line
        WHILE l_start <= l_tsv_len 
        LOOP
            l_end := DBMS_LOB.INSTR(l_tsv, CHR(10), l_start);
            --
            IF l_end = 0 THEN
                l_line := DBMS_LOB.SUBSTR(l_tsv, 32767, l_start);
              htp.prn(l_line);
              EXIT;
            ELSE
              l_line := DBMS_LOB.SUBSTR(l_tsv, l_end - l_start + 1, l_start);
              htp.prn(l_line);
              l_start := l_end + 1;
            END IF;
        END LOOP;


    END;
