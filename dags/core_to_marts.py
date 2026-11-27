from __future__ import annotations

import os
from datetime import datetime

from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator

DBT_IMAGE = "horizon-dbt:latest"
NETWORK = "horizon_net"
DBT_ENV = {
    "DBT_PROFILES_DIR": "/usr/app/dbt",
    "DBT_CH_HOST": "clickhouse",
    "DBT_CH_USER": os.environ.get("CLICKHOUSE_USER", "clickhouse"),
    "DBT_CH_PASSWORD": os.environ.get("CLICKHOUSE_PASSWORD", "clickhouse"),
}


def dbt_command(args: str) -> str:
    return f"dbt {args} --project-dir /usr/app/dbt --profiles-dir /usr/app/dbt"


with DAG(
    dag_id="core_to_marts",
    start_date=datetime(2026, 11, 21),
    schedule=None,
    catchup=False,
    tags=["dwh", "marts", "dbt"],
    description="core -> marts через dbt",
    default_args={"retries": 1},
) as dag:

    dbt_run_marts = DockerOperator(
        task_id="dbt_run_marts",
        image=DBT_IMAGE,
        command=dbt_command("run --select tag:marts"),
        network_mode=NETWORK,
        environment=DBT_ENV,
        docker_url="unix://var/run/docker.sock",
        mount_tmp_dir=False,
        auto_remove="success",
        api_version="auto",
        tty=True,
    )

    dbt_test_marts = DockerOperator(
        task_id="dbt_test_marts",
        image=DBT_IMAGE,
        command=dbt_command("test --select tag:marts"),
        network_mode=NETWORK,
        environment=DBT_ENV,
        docker_url="unix://var/run/docker.sock",
        mount_tmp_dir=False,
        auto_remove="success",
        api_version="auto",
        tty=True,
    )

    dbt_run_marts >> dbt_test_marts