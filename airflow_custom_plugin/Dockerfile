FROM apache/airflow:2.9.3-python3.10

USER root

ENV AIRFLOW__CORE__LOAD_EXAMPLES="false"

COPY dist/airflow_custom_plugin-0.1.0.tar.gz /tmp/poetry_dist/dist/

COPY dags/simple_dag.py dags/__init__.py /opt/airflow/dags/
RUN chmod 777 -R /opt/airflow/dags/


USER 50000

RUN ls -la /opt/airflow/dags/


RUN pip install /tmp/poetry_dist/dist/airflow_custom_plugin-0.1.0.tar.gz --no-cache-dir