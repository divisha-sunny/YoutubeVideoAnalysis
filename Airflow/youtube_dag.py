from datetime import timedelta, datetime
import pendulum
from airflow import DAG
from airflow.operators.python import PythonOperator
from youtube_etl import run_youtube_etl  # your ETL function

# -----------------------------
# DAG default args
# -----------------------------
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': pendulum.datetime(2023, 10, 1, tz="UTC"),
    'email': ['chowdavaramdivisha@gmail.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1)
}

# -----------------------------
# DAG definition
# -----------------------------
dag = DAG(
    'youtube_dag',
    default_args=default_args,
    description='A DAG to extract YouTube data'
)

# -----------------------------
# Task: run_youtube_etl
# -----------------------------
run_etl = PythonOperator(
    task_id='run_youtube_etl',
    python_callable=run_youtube_etl,
    dag=dag
)