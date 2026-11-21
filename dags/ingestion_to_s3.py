from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.sensors.filesystem import FileSensor
from airflow.exceptions import AirflowException
from datetime import datetime
import os, glob, botocore, logging, traceback

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

LOCAL_DIR = '/opt/airflow/data'
BUCKET = 'raw-data'
EXTENSIONS = ('*.csv', '*.xlsx', '*.json')

def list_files():
    """
        сканирует папку и возвращает списко абсолютных путей ко всем файлам с форматом, указанным в EXTTENSIONS
    """
    logger.info(f"=== НАЧАЛО list_files ===")
    logger.info(f"Ищем файлы в папке: {LOCAL_DIR}")
    logger.info(f"Расширения: {EXTENSIONS}")
    try:
        if not os.path.exists(LOCAL_DIR):
                logger.error(f"ПАПКА НЕ СУЩЕСТВУЕТ: {LOCAL_DIR}")
                raise AirflowException(f"Папка {LOCAL_DIR} не найдена внутри контейнера Airflow!")

        found = []
        for ext in EXTENSIONS:
            found.extend(glob.glob(os.path.join(LOCAL_DIR, ext)))
            logger.info(f"Найдено файлов с расширением {ext}: {len(glob.glob(os.path.join(LOCAL_DIR, ext)))}")

        logger.info(f"Всего найдено файлов: {len(found)}")
        if len(found) == 0:
            logger.warning("⚠️ Файлов не найдено! Задачи wait и upload не будут созданы.")
        
        logger.info(f"=== КОНЕЦ list_files ===")
        return sorted(found)
    except Exception as e:
        logger.error(f"ОШИБКА в list_files: {str(e)}")
        logger.error(traceback.format_exc())
        raise

def ensure_bucket(bucket):
    """
    создает бакет в s3, если его нет
    """
    hook=S3Hook(aws_conn_id='s3_default')
    try:
        hook.get_conn().head_bucket(Bucket=bucket)
    except botocore.exceptions.ClientError:
        hook.get_conn().create_bucket(Bucket=bucket)

def upload_one(local_path, **kwargs):
    bucket = kwargs["templates_dict"][1]
    logger.info(f"=== НАЧАЛО upload_one ===")
    logger.info(f"Бакет: {bucket}")
    for path in local_path:
        try:
            if not os.path.exists(path):
                logger.error(f"ФАЙЛ НЕ НАЙДЕН: {path}")
                raise AirflowException(f"Файл {path} не существует!")

            filename = os.path.basename(path)
            ext = filename.rsplit('.', 1)[-1].lower()
            s3_key = f'landing/{ext}/{filename}'

            logger.info(f"Ключ в S3: {s3_key}")

            hook = S3Hook(aws_conn_id = 's3_default')

            logger.info(f"Начинаем загрузку в s3://{bucket}/{s3_key}...")
            hook.load_file(
                filename=path,
                key=s3_key,
                bucket_name = bucket,
                replace=True
            )
            logger.info(f"✅ УСПЕХ: {path} -> s3://{bucket}/{s3_key}")
            
        except Exception as e:
            logger.error(f"ОШИБКА в upload_one: {str(e)}")
            logger.error(traceback.format_exc())
            raise
    
    logger.info(f"=== КОНЕЦ upload_one ===")

with DAG(
    dag_id = 'upload_local_to_s3',
    start_date = datetime(2026, 11, 21),
    schedule_interval = None,
    catchup=False,
    tags=['dwh', 's3', 'ingestion'],
    description='Ожидание и загрузка csv/xlsx/json в SeaweedFS S3'
) as dag:

    file_paths = PythonOperator(
        task_id = 'list_files',
        python_callable = list_files
    ).output

    wait = FileSensor.partial(
        task_id='wait_for_file',
        poke_interval=15,
        timeout=600,
        mode='reschedule',
        soft_fail=False
    ).expand(filepath=file_paths)

    create_bucket = PythonOperator(
        task_id='ensure_bucket',
        python_callable=ensure_bucket,
        op_args=[BUCKET]
    )

    upload=PythonOperator.partial(
        task_id='upload_to_s3',
        python_callable=upload_one,
        op_kwargs={'local_path': file_paths},
        
    ).expand(templates_dict = {'bucket': BUCKET})

    file_paths >> wait
    file_paths >> create_bucket
    [wait, create_bucket] >> upload
    