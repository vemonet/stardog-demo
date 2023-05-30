# 🐕‍🦺💫 Create a Virtual Knowledge Graph with Stardog

Repository to demo how to create a Virtual Knowledge Graph in a Stardog triplestore using data from a PostgreSQL database.

## ➡️ Access IDS Stardog

1. Go to **https://cloud.stardog.com**

2. Connect with your Google account (or any other option)
3. Create a **New Connection** for the Stardog server deployed at IDS
   1. Provide the username and password you were given by the IDS Stardog admin (Vincent probably)
   2. And the IDS Stardog server endpoint URL: **https://stardog.137.120.31.102.nip.io**
4. You can now connect to IDS server, create database, create model, etc

In the future you will just need to reconnect to https://cloud.stardog.com with your Google account, and access IDS Stardog server from there (it will save your connections credentials)

Stardog proposes 3 main interfaces to manage your knowledge graphs:

* **Designer** to define models

* **Studio** to query and navigate your KG

* **Explorer** to do full text searches

---

## ⚛️ Create a Virtual Knowledge Graph

To federate SQL databases

### 🔌 Create the data sources in Stardog Studio

Go to the [**Data** tab in **Stardog Studio**](https://cloud.stardog.com/u/1/studio/#/data), and click the **+** button to add a data source.

**Add PostgreSQL database sources for cohort 1 and 2:**

1. Data Source Type: PostgreSQL

2. JDBC Connection URL (change 1 to 2 for cohort 2):

   ```
   jdbc:postgresql://postgres-patients-cohort1:5432/patients_dataset_cohort1
   ```

3. JDBC username is `postgres`, and the password is the one you defined (or `passwordtochange` if you kept the default)
4. Driver Class: keep `org.postgresql.Driver`

**Add MariaDB database source for cohort 3:**

1. Data Source Type: MariaDB

2. JDBC Connection URL:

   ```
   jdbc:mariadb://mariadb-patients-cohort3:3306/patients_dataset_cohort3
   ```

3. JDBC username is `root`, and the password is the one you defined (or `passwordtochange` if you kept the default),

4. Driver Class: ⚠️ change to `org.mariadb.jdbc.Driver`

---

### 🧶 Create the model and mappings in Stardog Designer

Go to the [**Stardog Designer**](https://cloud.stardog.com/u/1/designer/#/)

To create a new model and mappings manually:

* Add **classes with their properties** from the [OMOP Common Data Model](https://github.com/OHDSI/CommonDataModel/blob/main/inst/csv/), e.g. Patient, Death

* Create a **new project resource** > New Virtual Graph > PostgreSQL

  * Select the `patients` table if the option is available,

  * Otherwise provide the following custom SQL query to retrieve the patients table:

    ```sql
    SELECT * FROM patients
    ```

* Provide a **name for the resource**, such as `cohort1`,and click create

* On the canvas click the newly created resource, and click **Add mapping** to map it to the **Patient** model

* In the mapping interface connect the 3 properties of our Patient to the right columns in the SQL table.

Finally publish your model to the database of your choice in Stardog

> Alternatively you can import the model and mappings previously created from the `.stardogdesigner` file in the `virtual-kg/` folder.

You can manually edit the generated mappings to **define more complex transformations**. For example here we convert the gender from M/F to 0/1 to comply with the OMOP CDM:

```SPARQL
# cohort1
MAPPING
FROM SQL {
  SELECT *, (CASE "gender"
    WHEN 'M' THEN '0'
    WHEN 'F' THEN '1'
  END) AS gender_id FROM "patients_dataset_cohort1"."public"."patients"
}
TO {
  ?Death_iri a <tag:stardog:designer:omop-cdm:model:Death> ;
    <tag:stardog:designer:omop-cdm:model:death_date> ?dod_date_field .

  ?Person_iri a <tag:stardog:designer:omop-cdm:model:Person> ;
    <tag:stardog:designer:omop-cdm:model:year_of_birth> ?dob_integer_field ;
    <tag:stardog:designer:omop-cdm:model:gender_concept_id> ?gender_integer_field ;
    <tag:stardog:designer:omop-cdm:model:person_id> ?subject_id_integer_field .

  ?Death_iri <tag:stardog:designer:omop-cdm:model:person_id_1> ?Person_iri .
}
WHERE {
  BIND(TEMPLATE("tag:stardog:designer:omop-cdm:data:Person:{subject_id}") AS ?Person_iri)
  BIND(StrDt(?dob, <http://www.w3.org/2001/XMLSchema#integer>) AS ?dob_integer_field)
  BIND(StrDt(?gender_id, <http://www.w3.org/2001/XMLSchema#integer>) AS ?gender_integer_field)
  BIND(StrDt(?subject_id, <http://www.w3.org/2001/XMLSchema#integer>) AS ?subject_id_integer_field)
  BIND(TEMPLATE("tag:stardog:designer:omop-cdm:data:Death:{subject_id}") AS ?Death_iri)
  BIND(StrDt(?dod, <http://www.w3.org/2001/XMLSchema#date>) AS ?dod_date_field)
}
```

---

### 💬 Query the virtual graph in Stardog Studio

Go to the [**Workspace** tab in **Stardog Studio**](https://cloud.stardog.com/u/1/studio/#/)

Or directly query the SPARQL endpoint at https://stardog.137.120.31.102.nip.io/icare4cvd

**Query all virtual graphs with SPARQL**:

```sparql
SELECT *
FROM stardog:context:virtual
WHERE {
    ?s ?p ?o .
} LIMIT 10000
```

**Query a specific virtual graph** using its name:

```sparql
SELECT *
WHERE {
  GRAPH <virtual://omop-cdm__data__postgres_patients_cohort1> {
    ?s ?p ?o .
  }
} LIMIT 10000
```

**Get properties/values for all persons** in the graph:

```SPARQL
SELECT *
FROM stardog:context:virtual
WHERE {
    ?s a omop-cdm:Person ;
        ?p ?o .
} LIMIT 10000
```

> You can also use `stardog:context:all` to query all materialized and virtual graphs.

**Visualize a Person in the graph** with a construct query generated by Stardog:

```SPARQL
# Expand From IRIs
CONSTRUCT {
  ?iri ?predicate ?object .
  ?object a ?object_type .
  ?object <tag:stardog:studio:label> ?object_label_0 .
  ?object rdfs:label ?object_label_1 .
  ?object <http://purl.org/dc/elements/1.1/title> ?object_label_2 .
  ?subject ?predicate_2 ?iri .
  ?subject a ?subject_type .
  ?subject <tag:stardog:studio:label> ?subject_label_0 .
  ?subject rdfs:label ?subject_label_1 .
  ?subject <http://purl.org/dc/elements/1.1/title> ?subject_label_2 .
}
FROM stardog:context:all
WHERE {
  VALUES (?iri) {
    (<tag:stardog:designer:omop-cdm:data:Person:10006>)
  }
  {
    ?iri ?predicate ?object .
    OPTIONAL { ?object a ?object_type . }
    OPTIONAL { ?object <tag:stardog:studio:label> ?object_label_0 . }
    OPTIONAL { ?object rdfs:label ?object_label_1 . }
    OPTIONAL { ?object <http://purl.org/dc/elements/1.1/title> ?object_label_2 . }
  }
  UNION {
    ?subject ?predicate_2 ?iri .
    OPTIONAL { ?subject a ?subject_type . }
    OPTIONAL { ?subject <tag:stardog:studio:label> ?subject_label_0 . }
    OPTIONAL { ?subject rdfs:label ?subject_label_1 . }
    OPTIONAL { ?subject <http://purl.org/dc/elements/1.1/title> ?subject_label_2 . }
  }
}
LIMIT 1000
```

> See the [Stardog introduction to SPARQL](https://docs.stardog.com/getting-started-series/getting-started-1) if you need to.

---

## ℹ️ Additional infos

### 📦️ Input data

For this demo we use the MIMIC-III dataset downloaded from https://www.kaggle.com/datasets/asjad99/mimiciii?resource=download

> Other potential datasets:
>
> * splitted in 2 to simulate 2 cohorts: https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset
> * https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction,
> * or with unstructured data: https://zenodo.org/record/1421616#.Y5iWerKZOLo

### 🧞 Generate SQL schema for CSV files

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

### 🗺️ Convert SMS mappings to R2RML

To run in the Stardog docker container:

```bash
docker-compose exec stardog stardog-admin virtual mappings -f r2rml virtualgraph
```

### 🔩 Create a VKG with Apache Drill

> TODO

```sql
SELECT COLUMNS[0] AS id, COLUMNS[1] AS age FROM dfs.`/data/stroke-prediction-cohort1.csv` LIMIT 3
```

### 🔗 Links

The Stardog documentation is quite consequent, please look into it when you want to do something: **https://docs.stardog.com**

* Docs to easily load CSV/JSON through the UI: https://docs.stardog.com/virtual-graphs/importing-json-csv-files

* Docs to access the SPARQL, HTTP, GRAPHQL APIs: https://stardog-union.github.io/http-docs/

Community forum: https://community.stardog.com

Example docker-compose for cluster: https://github.com/stardog-union/pystardog/blob/develop/docker-compose.cluster.yml

---

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

Start Stardog and postgreSQL:

```bash
docker-compose up -d
```

> ℹ️ The PostgreSQL database will be automatically initialized using the schema and data in `virtual-kg/`

