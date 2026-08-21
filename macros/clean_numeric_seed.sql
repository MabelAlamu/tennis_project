{% macro clean_numeric_seed(seed_col, entry_col) %}
coalesce(
    try_to_number(trim({{ seed_col }})),
    case
        when {{ entry_col }} like '%/%'
        then try_to_number(split_part({{ entry_col }}, '/', 1))
    end
)
{% endmacro %}