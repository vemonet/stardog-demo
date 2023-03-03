# 💫🦮 Create a Virtual Knowledge Graph with Stardog

## 🚀 Deploy the stack

Requirements: docker, docker-compose

With a local Stardog triplestore and a PostgreSQL database to create a Virtual Knowledge Graph (VKG).

⚠️ You will need to get your Stardog license at https://www.stardog.com/license-request

Place the `stardog-license-key.bin` file in the root folder of this repository.

Download the JDBC drivers by running this script:

```bash
./prepare.sh
```

> Optionally create a `.env` file with the password for the SQL database, otherwise the default is `password1234`:
>
> ```bash
> echo "PASSWORD=yourpassword" > .env
> ```
>

Start Stardog and postgreSQL:

```bash
docker-compose up -d
```

> ℹ️ The PostgreSQL database will be automatically initialized with the schema and data in `sql-vkg/`

## 🧑‍💻 Create a SQL VKG

Tutorial to create a Virtual Knowledge Graph (VKG) from data in a PostgreSQL database.

### 📊 Input data

For this tutorial we will use the stroke prediction dataset: https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset

Other potential datasets:

* https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction
* Unstructured: https://zenodo.org/record/1421616#.Y5iWerKZOLo

### 🔌 Create the data source in Stardog Studio

Go to the [**Data** tab in Stardog Studio](https://cloud.stardog.com/u/1/studio/#/data), and click the **+** button to add a data source.

Select PostgreSQL for the **Data Source Type**

Use the JDBC Connection URL:

```bash
jdbc:postgresql://heart-failure-postgres:5432/heart_failure_db
```

The JDBC username is `postgres`, and the password is the one you defined or `password1234` if you let the default, keep `org.postgresql.Driver` as Driver Class.

### 🧶 Create the model in Stardog Designer

Go to the [Stardog Designer](https://cloud.stardog.com/u/1/designer/#/)

You can either import the model and mappings we created with the `sql-vkg/patient-model/Heart_Failure_DB.stardogdesigner` file.

Or you can create a new project and mappings manually:

* Add a **Patient** with properties `age`, `gender`, `stroke`
* Create a new project resource > New Virtual Graph > PostgreSQL > Select the `stroke_data` table
* Provide a name for the resource, and click create
* On the canvas click the newly created resource, and click **Add mapping** to map it to the **Patient** model
* In the mapping interface connect the 3 properties of our Patient to the right columns in the SQL table. 

Finally publish your model to the database of your choice in Stardog

### 🏁 Query the Virtual Graph in Stardog

Go to the **Workspace** tab in **Stardog Studio**

To query all VKGs with SPARQL:

```sparql
SELECT *
FROM stardog:context:virtual
WHERE {
    ?s ?p ?o .
} LIMIT 1000
```

Or a specific VKG:

```sparql
SELECT *
WHERE {
  GRAPH <virtual://Heart_Failure_DB__data__heart_failure_demo> {
    ?s ?p ?o .
  }
} LIMIT 1000
```

## 🔩 Create a VKG with Apache Drill

SQL query:

```sql
SELECT COLUMNS[0] AS id, COLUMNS[1] AS age FROM dfs.`/data/stroke-data.csv` LIMIT 3
```

> TODO

## ℹ️ Additional infos

### 🧞 Generate SQL schema

Install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install csvkit mysql-connector-python
```

Generate schema from CSV. Note it needs to be manually fixed as they don't add `(128)` after the VARCHAR

```bash
csvsql --db mysql://user:password@localhost:3306/heart-failure-db --insert stroke-data.csv
```

### 🔒️ Change the Stardog admin password

Fix the password, cf. https://docs.stardog.com/stardog-admin-cli-reference/user/user-passwd

```bash
docker-compose exec stardog stardog-admin user passwd --username admin admin
```


### 🔗 Links

Example docker-compose for cluster: https://github.com/stardog-union/pystardog/blob/develop/docker-compose.cluster.yml

APIs docs: https://stardog-union.github.io/http-docs/

