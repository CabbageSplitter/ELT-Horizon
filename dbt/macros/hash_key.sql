{% macro hash_key(columns) -%}
lower(hex(MD5(concat_ws('|',
    {%- for col in columns %}
    coalesce(toString({{ col }}), ''){{ ", " if not loop.last }}
    {%- endfor %}
))))
{%- endmacro %}