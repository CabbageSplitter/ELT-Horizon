from __future__ import annotations

import glob
import logging
import os
from datetime import datetime

import pandas as pd
from airflow import DAG
from airflow.exceptions import AirflowException
from airflow.operators.python import PythonOperator
from airflow.providers.clickhousedb.hooks.clickhouse import ClickHouseHook
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.sensors.filesystem import FileSensor
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

from sql.create_raw import CreateRawTables

logger = logging.getLogger(__name__)

LOCAL_DIR = "/opt/airflow/data"
EXTENSIONS = ("*.csv", "*.xlsx", "*.json")
CH_CONN_ID = "clickhouse_default"
DB_NAME = "horizon"

# слово в имени файла → таблица
FILE_TABLE_MAP = {
    "cards": "raw_cards",
    "clients": "raw_clients",
    "products": "raw_products",
    "sales": "raw_sales",
    "stores": "raw_stores",
    "transactions": "raw_transactions",
    "hr": "raw_hr"
}

# если имена колонок в файле отличаются от DDL — переименовываем здесь
COLUMN_RENAME = {
    # "raw_sales": {"quantity": "oquantity", "event_time": "datetime"},
}

raw_ddl = CreateRawTables()


def list_files() -> list[str]:
    logger.info("Ищем файлы в %s по маскам %s", LOCAL_DIR, EXTENSIONS)
    if not os.path.exists(LOCAL_DIR):
        raise AirflowException(f"Папка {LOCAL_DIR} не найдена внутри контейнера Airflow!")

    found = []
    for ext in EXTENSIONS:
        found.extend(glob.glob(os.path.join(LOCAL_DIR, ext)))

    found = sorted(set(found))
    logger.info("Всего найдено файлов: %s", len(found))
    if not found:
        logger.warning("Файлов не найдено — маппинг wait/upload создаст 0 инстансов.")
    else:
        for file in found:
            if '$' in file or '~' in file:
                found.remove(file)

    return found


def resolve_table(local_path: str) -> str:
    name = os.path.basename(local_path).lower()
    for key, table in FILE_TABLE_MAP.items():
        if key in name:
            return table
    raise AirflowException(
        f"Не удалось определить таблицу для '{name}': "
        f"в имени должно быть одно из {list(FILE_TABLE_MAP)}"
    )


def read_file(local_path: str) -> pd.DataFrame:
    ext = os.path.splitext(local_path)[1].lower()
    if ext == ".csv":
        return pd.read_csv(local_path, dtype=str, sep=None, engine="python")
    if ext == ".xlsx":
        return pd.read_excel(local_path, dtype=str)
    if ext == ".json":
        return pd.read_json(local_path, dtype=str)
    raise AirflowException(f"Неподдерживаемое расширение: {ext}")


def truncate_target_tables(**kwargs) -> None:
    """Очищает ТОЛЬКО те таблицы, для которых есть файлы в этом запуске."""
    paths = kwargs["ti"].xcom_pull(task_ids="list_files") or []
    tables = sorted({resolve_table(p) for p in paths})
    if not tables:
        logger.info("Файлов нет — очищать нечего")
        return

    client = ClickHouseHook(clickhouse_conn_id=CH_CONN_ID).get_client()
    for table in tables:
        client.command(f"TRUNCATE TABLE IF EXISTS {DB_NAME}.{table}")
        logger.info("Очищена %s.%s", DB_NAME, table)


def upload_one(local_path: str, **kwargs) -> None:
    table = resolve_table(local_path)
    fname = os.path.basename(local_path)
    logger.info("Загружаем %s → %s.%s", fname, DB_NAME, table)

    df = read_file(local_path)
    if df.empty:
        logger.warning("Файл %s пуст — пропускаем", fname)
        return

    df.columns = [str(c).strip().lower() for c in df.columns]
    df = df.rename(columns=COLUMN_RENAME.get(table, {}))
    df = df.fillna("").astype(str)

    client = ClickHouseHook(clickhouse_conn_id=CH_CONN_ID).get_client()

    table_columns = [
        row[0] for row in client.query(f"DESCRIBE TABLE {DB_NAME}.{table}").result_rows
    ]
    unknown = set(df.columns) - set(table_columns)
    if unknown:
        logger.warning("Колонки %s не найдены в %s.%s — отброшены", unknown, DB_NAME, table)
    df = df[[c for c in df.columns if c in table_columns]]
    if df.empty or df.shape[1] == 0:
        raise AirflowException(f"Ни одна колонка файла {fname} не совпала с {DB_NAME}.{table}")

    client.insert_df(table=table, df=df, database=DB_NAME)
    logger.info("Загружено строк: %s", len(df))


with DAG(
    dag_id="load_files_to_raw",
    start_date=datetime(2026, 11, 21),
    schedule=None,
    catchup=False,
    tags=["dwh", "raw", "ingestion"],
    description="Шаг 1: csv/xlsx/json из /opt/airflow/data → horizon.raw_*",
    default_args={"retries": 1},
) as dag:

    create_db = SQLExecuteQueryOperator(
        task_id="create_database",
        conn_id=CH_CONN_ID,
        sql=f"CREATE DATABASE IF NOT EXISTS {DB_NAME}",
    )

    create_raw_cards = SQLExecuteQueryOperator(
        task_id="create_raw_cards", conn_id=CH_CONN_ID, sql=raw_ddl.create_cards(),
    )
    create_raw_clients = SQLExecuteQueryOperator(
        task_id="create_raw_clients", conn_id=CH_CONN_ID, sql=raw_ddl.create_clients(),
    )
    create_raw_products = SQLExecuteQueryOperator(
        task_id="create_raw_products", conn_id=CH_CONN_ID, sql=raw_ddl.create_products(),
    )
    create_raw_sales = SQLExecuteQueryOperator(
        task_id="create_raw_sales", conn_id=CH_CONN_ID, sql=raw_ddl.create_sales(),
    )
    create_raw_stores = SQLExecuteQueryOperator(
        task_id="create_raw_stores", conn_id=CH_CONN_ID, sql=raw_ddl.create_stores(),
    )
    create_raw_transactions = SQLExecuteQueryOperator(
        task_id="create_raw_transactions", conn_id=CH_CONN_ID, sql=raw_ddl.create_transactions(),
    )

    create_raw_hr = SQLExecuteQueryOperator(
    task_id="create_raw_hr", conn_id=CH_CONN_ID, sql=raw_ddl.create_hr(),
)

    create_tables = [
        create_raw_cards, create_raw_clients, create_raw_products,
        create_raw_sales, create_raw_stores, create_raw_transactions,
        create_raw_hr
    ]

    file_paths = PythonOperator(
        task_id="list_files",
        python_callable=list_files,
    ).output

    wait = FileSensor.partial(
        task_id="wait_for_file",
        poke_interval=15,
        timeout=600,
        mode="reschedule",
    ).expand(filepath=file_paths)

    truncate = PythonOperator(
        task_id="truncate_target_tables",
        python_callable=truncate_target_tables,
    )

    upload = PythonOperator.partial(
        task_id="upload_to_raw",
        python_callable=upload_one,
    ).expand(op_kwargs=file_paths.map(lambda p: {"local_path": p}))

    trigger_staging = TriggerDagRunOperator(
        task_id="trigger_raw_to_staging",
        trigger_dag_id="raw_to_staging",   
        reset_dag_run=True,                
        wait_for_completion=False,         
        poke_interval=30,
    )

    # DDL-ветка
    create_db >> create_tables
    # очистка: когда таблицы созданы И список файлов известен
    [*create_tables, file_paths] >> truncate
    # загрузка: когда файлы на месте И таблицы очищены
    file_paths >> wait
    [wait, truncate] >> upload >> trigger_staging