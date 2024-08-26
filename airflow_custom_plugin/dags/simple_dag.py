from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

#Define default arguments
default_args = {
    'owner': 'your_name',
    'start_date': datetime (2023, 9, 29),
    'retries': 0,
}

# Define tasks
def task1():
    print ("Executing Task 1")

def task2():
    print ("Executing Task 2")

# Instantiate your DAG
with DAG (
    'my_first_dag',
    default_args=default_args,
    schedule_interval="15 * * * *",
    catchup=False
) as dag:
    task_1 = PythonOperator(
        task_id='task_1',
        python_callable=task1,
        dag=dag,
    )
    task_2 = PythonOperator(
        task_id='task_2',
        python_callable=task2,
        dag=dag,
    )

    task_11 = PythonOperator(
        task_id='task_11',
        python_callable=task2,
        dag=dag,
        queue="kubernetes"
    )

    # Set task dependencies
    task_1 >> task_2 >> task_11

dag