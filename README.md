# Activity Schema

This dbt package contains macros for building an [activity schema](https://www.activityschema.com). 

The macros can help write models for use directly as activity stream tables, particularly if they need to be warehouse-independent.

## Usage

Call the **make_activity** macro in your models to get the feature_json and activity occurrence columns. 

```sql
{{ config(features=['tag', 'subject']) }}

with final as (
  ...
)

select * from {{ activity_schema.make_activity('final') }}
```

<br>

### Warehouse Support

Works on the following warehouses

- Bigquery
- Postgres
- Redshift
- Snowflake


<br>

## Macros

**make_activity** ([source](macros/make_activity.sql))
This macro takes a cte name and adds the feature json and activity occurrence columns to it.

To properly add the feature_json column it takes a list of feature column names as a configuration variable. 

Example usage

```sql

{{ config(features=['tag', 'subject']) }}

with final as (
  select 
    id as activity_id,
    created_at as ts ,

    'received_email' as activity,

    email as customer,
    null as anonymous_customer_id,

    tag as tag,
    subject as subject,

    null as link,
    null as revenue_impact
  from emails
)

select * from {{ make_activity('final') }}

```

<br>

**feature_json** ([source](macros/feature_json.sql))

Helps build a warehouse-independent feature_json column. This works by taking a list of columns containing the feature values and selecting them together into a single json object.

This isn't really necessary if your model only targets a single warehouse. It might be easier to simply write your CTE with a feature_json directly, like so (e.g. for Redshift)

```sql
object('tag', tag, 'subject', subject, 'content', preview ) as feature_json,
```


<br>

**activity_occurrence** ([source](macros/activity_occurrence.sql))
Builds the two activity occurrence columns, `activity_occurrence` and `activity_repeated_at`. These are used in the querying of an activity stream to efficiently query Nth and last activities for a given customer.

<br>

## Resources:
- Activity schema [github page](https://github.com/ActivitySchema/ActivitySchema)
- Discussion on the activity schema [dbt slack](https://getdbt.slack.com/archives/modeling-activity-schema)
- [Narrator](https://www.narratordata.com) - a service for maintaining & querying activity schemas
