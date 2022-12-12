{# Given a list of feature columns -- encodes them into a json type column called feature_json #}

{% macro feature_json(feature_columns) %}
    {%- if feature_columns is not none -%}
        {% if target.type == 'redshift' %}
            object(
                {%- for column in feature_columns -%}
                    '{{column}}', "{{column}}"{% if not loop.last %}, {% endif %}
                {%- endfor -%}
            )
        {% elif target.type == 'bigquery' %}
            to_json(struct({{ feature_columns|join(', ') }}))
        {% elif target.type == 'snowflake' %}
            object_construct(
                {%- for column in feature_columns -%}
                    '{{column}}', {{column}}{% if not loop.last %}, {% endif %}
                {%- endfor -%}
            )
        {% elif target.type == 'postgres' %}
            json_build_object(
                {%- for column in feature_columns -%}
                    '{{column}}', "{{column}}"{% if not loop.last %}, {% endif %}
                {%- endfor -%}
            )
        {% else %}
            {{ exceptions.raise_compiler_error(target.type ~" not supported in this project") }}
        {% endif %}
        as feature_json
    {%- endif -%}
{% endmacro %}