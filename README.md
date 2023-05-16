# 🦮💫 Create a Virtual Knowledge Graph with Stardog

Repository to demo how to create a Virtual Knowledge Graph in a Stardog triplestore using data from a PostgreSQL database.

## 🚀 Deploy the stack

Requirements: docker 🐳 

Deploys a local Stardog triplestore, a PostgreSQL database, and a MariaDB SQL database to create a Virtual Knowledge Graph (VKG).

⚠️ You will need to get your Stardog license at https://www.stardog.com/license-request

Place the `stardog-license-key.bin` file in the root folder of this repository.

Download the JDBC drivers in the `drivers/` folder by running this script:

```bash
./prepare.sh
```

> Optionally create a `.env` file with the password for the SQL database, otherwise the default is `passwordtochange`:
>
> ```bash
> echo "PASSWORD=yourpassword" > .env
> ```
>

Start Stardog and postgreSQL:

```bash
docker-compose up -d
```

> ℹ️ The PostgreSQL database will be automatically initialized using the schema and data in `sql-vkg/`

## 🧑‍💻 Create a SQL VKG

### 🔌 Create the data sources in Stardog Studio

Go to the [**Data** tab in **Stardog Studio**](https://cloud.stardog.com/u/1/studio/#/data), and click the **+** button to add a data source.

**Add PostgreSQL cohort1:**

1. Data Source Type: PostgreSQL

2. JDBC Connection URL:

   ```
   jdbc:postgresql://stroke-prediction-postgres-cohort1:5432/stroke_prediction_dataset_cohort1
   ```

3. JDBC username is `postgres`, and the password is the one you defined (or `passwordtochange` if you kept the default)
4. Driver Class: keep `org.postgresql.Driver` 

**Add MariaDB cohort2:**

1. Data Source Type: MariaDB

2. JDBC Connection URL:

   ```
   jdbc:mariadb://stroke-prediction-mariadb-cohort2:3306/stroke_prediction_dataset_cohort2
   ```

3. JDBC username is `root`, and the password is the one you defined (or `passwordtochange` if you kept the default), 

4. Driver Class: Change to `org.mariadb.jdbc.Driver`

### 🧶 Create the model in Stardog Designer

Go to the [**Stardog Designer**](https://cloud.stardog.com/u/1/designer/#/)

You can either import the model and mappings we created with the `sql-vkg/patient-model/Heart_Failure_DB.stardogdesigner` file.

Or you can create a new project and mappings manually:

* Add a **Patient** with properties `age`, `gender`, `stroke`
* Create a new project resource > New Virtual Graph > PostgreSQL > Select the `stroke_data` table
* Provide a name for the resource, and click create
* On the canvas click the newly created resource, and click **Add mapping** to map it to the **Patient** model
* In the mapping interface connect the 3 properties of our Patient to the right columns in the SQL table. 

Finally publish your model to the database of your choice in Stardog

### 🏁 Query the Virtual Graph in Stardog Studio

Go to the [**Workspace** tab in **Stardog Studio**](https://cloud.stardog.com/u/1/studio/#/)

To query all VKGs with SPARQL:

```sparql
SELECT *
FROM stardog:context:virtual
WHERE {
    ?s ?p ?o .
} LIMIT 1000
```

Or a specific VKG using its name, e.g.:

```sparql
SELECT *
WHERE {
  GRAPH <virtual://Heart_Failure_DB__data__heart_failure_demo> {
    ?s ?p ?o .
  }
} LIMIT 1000
```

Directly query the SPARQL endpoint at https://stardog.137.120.31.102.nip.io/stroke-prediction-demo

## 🔩 Create a VKG with Apache Drill

SQL query:

```sql
SELECT COLUMNS[0] AS id, COLUMNS[1] AS age FROM dfs.`/data/stroke-prediction-cohort1.csv` LIMIT 3
```

> TODO

## ℹ️ Additional infos

### 📊 Input data

For this demo we use a dataset splitted in 2 to simulate 2 cohorts: https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset

> Other potential datasets: https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction, or with unstructured data: https://zenodo.org/record/1421616#.Y5iWerKZOLo

### 🧞 Generate SQL schema

Install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install csvkit mysql-connector-python
```

Generate schema from CSV. Note it needs to be manually fixed as they don't add `(128)` after the VARCHAR

```bash
csvsql --db mysql://user:password@localhost:3306/heart-failure-db --insert stroke-prediction-cohort1.csv
```

### 🔒️ Change the Stardog admin password

Fix the password, cf. https://docs.stardog.com/stardog-admin-cli-reference/user/user-passwd

```bash
docker-compose exec stardog stardog-admin user passwd --username admin admin
```


### 🔗 Links

* Example docker-compose for cluster: https://github.com/stardog-union/pystardog/blob/develop/docker-compose.cluster.yml

* APIs docs: https://stardog-union.github.io/http-docs/

