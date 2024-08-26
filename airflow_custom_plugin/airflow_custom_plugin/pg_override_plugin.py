import logging
from airflow.plugins_manager import AirflowPlugin
import sqlalchemy

class CustomDatabasePlugin(AirflowPlugin):

    logger = logging.getLogger("CustomDatabasePlugin")
    log_enabled = True

    name = "custom_database_plugin"

    @classmethod
    def on_load(cls, *args, **kwargs):
        CustomDatabasePlugin.logger.info("Installing DB password provider")

        from azure.identity import DefaultAzureCredential
        az_id_logger = logging.getLogger("azure.identity")
        az_id_logger.setLevel(logging.WARN)

        identity = DefaultAzureCredential()

        @sqlalchemy.event.listens_for(sqlalchemy.engine.base.Engine, "do_connect")
        def provide_token(dialect, conn_rec, cargs, cparams):
            user: str = cparams.get("user")
            if user and user.startswith("test_keda_airflow_uami_airflow_keda"):
                CustomDatabasePlugin.logger.info("getting DB password")
                token = identity.get_token("https://ossrdbms-aad.database.windows.net/.default")
                cparams["password"] = token.token
                CustomDatabasePlugin.logger.info("set DB password")
                if CustomDatabasePlugin.log_enabled:
                    CustomDatabasePlugin.log_enabled = False
                    az_id_logger.setLevel(logging.WARN)

        CustomDatabasePlugin.logger.info("Installed DB password provider")
