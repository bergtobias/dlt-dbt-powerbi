import os
import dlt
from dotenv import load_dotenv
from extract.jsonplaceholder import source as jsonplaceholder_source
from extract.dummyjson import source as dummyjson_source

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
    creds = build_credentials()

    jp = dlt.pipeline(
        pipeline_name="jsonplaceholder",
        destination=dlt.destinations.mssql(credentials=creds),
        dataset_name="raw",
    )
    print(jp.run(jsonplaceholder_source()))

    dj = dlt.pipeline(
        pipeline_name="dummyjson",
        destination=dlt.destinations.mssql(credentials=creds),
        dataset_name="dummyjson",
    )
    print(dj.run(dummyjson_source()))


if __name__ == "__main__":
    main()
