import os
import dlt
from dotenv import load_dotenv
from pipeline.jsonplaceholder import source

load_dotenv()


def build_credentials() -> str:
    h  = os.environ["MSSQL_HOST"]
    p  = os.environ["MSSQL_PORT"]
    u  = os.environ["MSSQL_USER"]
    pw = os.environ["MSSQL_SA_PASSWORD"]
    db = os.environ["MSSQL_DB"]
    return (
        f"mssql://{u}:{pw}@{h}:{p}/{db}"
        "?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes"
    )


def main():
    pipeline = dlt.pipeline(
        pipeline_name="jsonplaceholder",
        destination=dlt.destinations.mssql(credentials=build_credentials()),
        dataset_name="raw",
    )
    info = pipeline.run(source())
    print(info)


if __name__ == "__main__":
    main()
