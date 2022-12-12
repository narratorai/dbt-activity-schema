{# Adds feature json and activity columns to a cte
   Usage: select * from {{ activity_schema.make_activity('final') }} #}

{# Feature Columns
   Specify feature columns like this {{ config(features=['tag', 'subject']) }}
   If not specified the feature_json column will be skipped 
#}

{% macro make_activity(cte_name) %}
    {%- set feature_columns = config.get('features') or none -%}
    {%- set core_columns = ['activity', 'activity_id', 'ts', 'customer', 'anonymous_customer_id', 'link', 'revenue_impact'] -%}
    (
        select
            {{ core_columns|join(',\n    ')}},
        {% if feature_columns is not none %}
            {{ activity_schema.feature_json(feature_columns) }},
        {% else %}
            {{ log('No feature columns specified. Skipping building the feature json column') }}
        {% endif %}
        {{ activity_schema.activity_occurrence() }}
        
        from {{ cte_name }}
        order by ts asc
    )
{% endmacro %}