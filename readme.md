# Server-side GTM BigQuery Event Tag
## Stream events directly to BigQuery using the tag template

The template uses the BigQuery Streaming Insert API to send events directly to a BigQuery table.

The BigQuery table and the correct schema will need to be defined before starting to send events. Use the schema from the schema.txt file when creating the table to define the correct schema.

The schema is similar to the GA4 schema for event_params. It allows defining new events without having to adjust the schema in BigQuery first.

Related blog post: https://tanelytics.com/send-events-from-server-side-tag-manager-to-bigquery/