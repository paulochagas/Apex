create or replace PACKAGE xxx_utils_ords
IS

   FUNCTION get_tsv_with_header (
        p_query IN CLOB
      ) RETURN CLOB;

end xxx_utils_ords;
