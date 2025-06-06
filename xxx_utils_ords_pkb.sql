create or replace PACKAGE body xxx_utils_ords
IS
   --
   FUNCTION clean_csv_field(p_text VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
     RETURN REPLACE(REPLACE(REPLACE(p_text, CHR(13), ''), CHR(10), ''), CHR(9), ' ');
   END;
   --   
   FUNCTION get_tsv_with_header (
     p_query IN CLOB
   ) RETURN CLOB IS
     l_cursor   INTEGER;
     l_col_cnt  INTEGER;
     l_desc_tab DBMS_SQL.DESC_TAB2;
     l_header   CLOB := '';
     l_result   VARCHAR2(32767);
     l_line     VARCHAR2(32767);
     l_dummy    NUMBER;
   BEGIN
     -- Abrir cursor
     l_cursor := DBMS_SQL.open_cursor;
     DBMS_SQL.parse(l_cursor, p_query, DBMS_SQL.NATIVE);

     -- Descrever colunas
     DBMS_SQL.describe_columns2(l_cursor, l_col_cnt, l_desc_tab);

     -- Definir colunas para leitura
     FOR i IN 1..l_col_cnt LOOP
        IF l_desc_tab(i).col_type NOT IN (112, 113, 114, 23, 24) THEN
           DBMS_SQL.define_column(l_cursor, i, l_result, 32767);
        END IF;   
     END LOOP;

     -- Montar cabeçalho com colunas entre aspas, separado por TAB
     FOR i IN 1..l_col_cnt LOOP
        IF l_desc_tab(i).col_type NOT IN (112, 113, 114, 23, 24) THEN
           --
           l_header := l_header || '"' || l_desc_tab(i).col_name || '"';
           IF i < l_col_cnt THEN
              l_header := l_header || CHR(9); -- tab
           END IF;
        END IF;   
     END LOOP;
     l_header := l_header || CHR(10); -- nova linha

     -- Executar query
     l_dummy := DBMS_SQL.execute(l_cursor);

     -- Ler linhas
     WHILE DBMS_SQL.fetch_rows(l_cursor) > 0 LOOP
       l_line := '';
       FOR i IN 1..l_col_cnt LOOP
          IF l_desc_tab(i).col_type NOT IN (112, 113, 114, 23, 24) THEN
             --
             DBMS_SQL.column_value(l_cursor, i, l_result);

             -- Tratar tabs e quebras de linha
             l_result := REPLACE(l_result, CHR(9), ' ');
             l_result := REPLACE(l_result, CHR(10), ' ');
             l_result := REPLACE(l_result, CHR(13), ' ');

             -- Escapar aspas duplas
             l_result := REPLACE(l_result, '"', '""');

             -- Envolver em aspas duplas
             l_line := l_line || '"' || l_result || '"';

             IF i < l_col_cnt THEN
                l_line := l_line || CHR(9);
             END IF;
          --   
          END IF;     
       END LOOP;

       -- Remover o último tab e adicionar nova linha
       l_line := RTRIM(l_line, CHR(9)) || CHR(10);

       l_header := l_header || l_line;
     END LOOP;

     DBMS_SQL.close_cursor(l_cursor);
     RETURN l_header;

   EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.is_open(l_cursor) THEN
         DBMS_SQL.close_cursor(l_cursor);
       END IF;
       RAISE;
   END;
--
end xxx_utils_ords;
