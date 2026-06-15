create streaming table if not exists branze_raw_orders
comment "Raw orders data"
as
select * from cloud_files(r"/Volumes/dlt/default/dlt_folders/orders/", 'json',
map(
    'cloudFiles.inferColumnTypes', 'true',
    'cloudFiles.includeExistingFiles','true',
    'cloudFiles.schemaEvolutionMode', 'addNewColumns'
)
);

create materialized view if not exists silver_orders
comment "Curated orders (Completed only) with quality checks"
as
select 
    order_id,
    customer_id,
    country,
    cast(amount as double) as amount,
    status,
    cast(order_ts as timestamp) as order_ts
    from branze_raw_orders where status ='Completed';

create view golden_orders
comment "Curated orders based on country india"
as
select * from silver_orders where lower(country) = 'in';

