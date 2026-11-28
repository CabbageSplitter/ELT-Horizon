FROM python:3.11-slim
RUN pip install --no-cache-dir "dbt-core~=1.10.0" "dbt-clickhouse~=1.10.3"
WORKDIR /usr/app/dbt
COPY . /usr/app/dbt
RUN dbt deps --project-dir /usr/app/dbt --profiles-dir /usr/app/dbt