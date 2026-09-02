{% macro deduplicate_matches(relation, winner_id_column, loser_id_column) %}
with classified as (
    select
        *,
        -- Number of score versions recorded for the apparent match.
        count(distinct coalesce(score, 'null score')) -- distinct usually ignores nulls, using coalesce to account for nulls in the score column
        over (
            partition by
                tourney_id,
                tourney_date,
                {{winner_id_column}},
                {{loser_id_column}},
                round
        ) as score_version_count,

        -- Rank repeated rows so the earliest match number is retained.
        row_number() over (
            partition by
                tourney_id,
                tourney_date,
                {{winner_id_column}},
                {{loser_id_column}},
                round,
                score
            order by tourney_match_num asc
        ) as duplicate_row_number

    from {{relation}}
),
final as (
    select
        * exclude (score_version_count, duplicate_row_number)
    from classified
    -- Remove every apparent match with conflicting score versions.
    where score_version_count = 1
    -- For identical score versions, retain the earliest match number.
      and duplicate_row_number = 1
)

select * from final
{% endmacro %}