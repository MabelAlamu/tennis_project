{% macro clean_entry_code(entry_col, seed_col) %}
coalesce(
    nullif(upper(trim(case when {{ entry_col }} like '%/%' then split_part({{ entry_col }}, '/', 2) else {{ entry_col }} end)), ''),
    case
        when try_to_number(trim({{ seed_col }})) is null
            and nullif(trim({{ seed_col }}), '') is not null
        then upper(trim({{ seed_col }}))
    end
)
{% endmacro %}