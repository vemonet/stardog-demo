# 🐕‍🦺💫 Create a Virtual Knowledge Graph with Stardog

Repository to demo how to create a Virtual Knowledge Graph in a Stardog triplestore using data from a PostgreSQL database.

For this demo we use the **MIMIC-IV dataset**, more details and request access at https://physionet.org/content/mimiciv/2.2/

## ➡️ Access IDS Stardog

1. Go to **https://cloud.stardog.com**

2. Connect with your Google account (or any other option)
3. Create a **New Connection** for the Stardog server deployed at IDS
   1. Provide the username and password you were given by the IDS Stardog admin (Vincent probably)
   2. And the IDS Stardog server endpoint URL: **https://stardog.137.120.31.102.nip.io**
4. You can now connect to IDS server, create database, create model, etc

In the future you will just need to reconnect to https://cloud.stardog.com with your Google account, and access IDS Stardog server from there (it will save your connections credentials)

Stardog proposes 3 main interfaces to manage your knowledge graphs:

* **Studio** to query and navigate your KG
* **Designer** to define models
* **Explorer** to do full text searches

---

## ⚛️ Create a Virtual Knowledge Graph

To federate multiple SQL databases

### 🔌 Create the data sources in Stardog Studio

Go to the [**Data** tab](https://cloud.stardog.com/u/1/studio/#/data) in **Stardog Studio**, and click the **+** button to add a data source.

**Add PostgreSQL database sources for cohort 1 and 2:**

1. Data Source Type: PostgreSQL

2. JDBC Connection URL (use `postgres-mimic-iv-2` for cohort 2):

   ```
   jdbc:postgresql://postgres-mimic-iv:5432/mimic_iv
   ```

3. JDBC username is `postgres`, and the password is the one you defined (or `passwordtochange` if you kept the default)
4. Driver Class: keep `org.postgresql.Driver`

**Add MariaDB database source for cohort 2:**

Alternatively you could also use MariaDB instead of PostgreSQL for cohort 2:

1. Data Source Type: MariaDB

2. JDBC Connection URL:

   ```
   jdbc:mariadb://mariadb-mimic-iv:3306/mimic_iv
   ```

3. JDBC username is `root`, and the password is the one you defined (or `passwordtochange` if you kept the default),

4. Driver Class: ⚠️ change to `org.mariadb.jdbc.Driver`

> ℹ️ Build scripts are available to load MIMIC-IV in various DBMS: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iv/buildmimic

---

### 🧶 Create the model

Go to the [**Models** tab](https://cloud.stardog.com/u/1/studio/#/models) in **Stardog Studio**.

Add classes with their properties from the [**OMOP Common Data Model**](https://github.com/OHDSI/CommonDataModel/blob/main/inst/csv/), e.g. Patient, Death

Through this interface you can browse the model through a tree view, and edit the model ontology as turtle RDF, making it easier if you need to import an existing ontology.

Validation that the data complies with the model can be set using SHACL: https://docs.stardog.com/data-quality-constraints

<details><summary>Model creation and mapping can also be done through the <b>Stardog Designer</b> interface, it offers limited customization of the mappings and model, but can be helpful to pre-generate mappings that are then improved manually in Stardog Studio</summary>

To create a new model and mappings manually:

* Create classes and properties of the model

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

</details>

---

### 🗺️ Define the mappings

In the [**Virtual Graphs** tab](https://cloud.stardog.com/u/1/studio/#/virtual-graphs) in **Stardog Studio**

Mappings in Stardog is done using the Stardog Mapping Syntax (SMS).

Here we provide an example of mappings from a `patients.csv` file to a Person, and it's Death, if recorded

Mapping from patients to the Person class, converting the gender from M/F to 0/1 to comply with the OMOP CDM:

```SPARQL
# Map patients to persons
PREFIX omop-cdm: <tag:stardog:designer:omop-cdm:model:>
MAPPING
FROM SQL {
  SELECT *, (CASE "gender"
    WHEN 'M' THEN '0'
    WHEN 'F' THEN '1'
  END) AS gender_id FROM patients
}
TO {
  ?Person_iri a omop-cdm:Person ;
    omop-cdm:year_of_birth ?anchor_year_integer_field ;
    omop-cdm:gender_concept_id ?gender_integer_field ;
    omop-cdm:id ?subject_id_integer_field .
}
WHERE {
  BIND(TEMPLATE("tag:stardog:designer:omop-cdm:data:Person:{subject_id}") AS ?Person_iri)
  BIND(StrDt(?anchor_year, <http://www.w3.org/2001/XMLSchema#integer>) AS ?anchor_year_integer_field)
  BIND(StrDt(?gender_id, <http://www.w3.org/2001/XMLSchema#integer>) AS ?gender_integer_field)
  BIND(StrDt(?subject_id, <http://www.w3.org/2001/XMLSchema#integer>) AS ?subject_id_integer_field)
}
```

Mapping from patients to the Death class, we only create Death entities when a `dod` is present:

```SPARQL
# Map patients to deaths
PREFIX omop-cdm: <tag:stardog:designer:omop-cdm:model:>
MAPPING
FROM SQL {
  SELECT * FROM patients WHERE dod IS NOT NULL
}
TO {
  ?Death_iri a omop-cdm:Death ;
    omop-cdm:death_date ?dod_date_field .

  ?Death_iri omop-cdm:person_id ?Person_iri .
}
WHERE {
  BIND(TEMPLATE("tag:stardog:designer:omop-cdm:data:Person:{subject_id}") AS ?Person_iri)
  BIND(TEMPLATE("tag:stardog:designer:omop-cdm:data:Death:{subject_id}") AS ?Death_iri)
  BIND(StrDt(?dod, <http://www.w3.org/2001/XMLSchema#date>) AS ?dod_date_field)
}s
```

---

### 💬 Query the virtual graphs in Stardog Studio

Go to the [**Workspace** tab](https://cloud.stardog.com/u/1/studio/#/) in **Stardog Studio**

Or directly query the SPARQL endpoint at https://stardog.137.120.31.102.nip.io/icare4cvd

**Query all virtual graphs with SPARQL**:

```sparql
SELECT *
FROM stardog:context:virtual
WHERE {
    ?s ?p ?o .
} LIMIT 10000
```

> You can also use `stardog:context:all` to query all materialized and virtual graphs.

**Query a specific virtual graph** using its name:

```sparql
SELECT *
WHERE {
  GRAPH <virtual://virtual_graph_name> {
    ?s ?p ?o .
  }
} LIMIT 10000
```

**Get all persons**:

```SPARQL
SELECT DISTINCT ?id ?gender ?year_of_birth ?death_date
FROM stardog:context:virtual
WHERE {
    ?s a omop-cdm:Person ;
        omop-cdm:id ?id ;
        omop-cdm:gender_concept_id ?gender ;
        omop-cdm:year_of_birth ?year_of_birth .
    OPTIONAL {
        ?death omop-cdm:person_id ?s ;
               omop-cdm:death_date ?death_date
    }

} LIMIT 1000000
```

**Get persons with no death date**:

```SPARQL
SELECT DISTINCT ?id ?gender ?year_of_birth
FROM stardog:context:virtual
WHERE {
    ?s a omop-cdm:Person ;
        omop-cdm:id ?id ;
        omop-cdm:gender_concept_id ?gender ;
        omop-cdm:year_of_birth ?year_of_birth .
    FILTER NOT EXISTS {?death omop-cdm:person_id ?s}

} LIMIT 1000000
```

**Get persons born after a specific date**:

```SPARQL
SELECT DISTINCT *
FROM stardog:context:virtual
WHERE {
    ?s a omop-cdm:Person ;
        omop-cdm:year_of_birth ?birthYear .
    FILTER (?birthYear > 2130)
} LIMIT 10000
```

> See the [Stardog introduction to SPARQL](https://docs.stardog.com/getting-started-series/getting-started-1) if you need to.

---

## ℹ️ Additional infos

### 🧞 Generate SQL schema for CSV files

Install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install csvkit mysql-connector-python
```

Generate schema from CSV. Note it needs to be manually fixed as they don't add `(128)` after VARCHAR

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

Requirements: docker 🐳, and you will need to get your **Stardog license** at https://www.stardog.com/license-request ⚠️

Deploys a local Stardog triplestore, a PostgreSQL database, and a MariaDB SQL database to create a Virtual Knowledge Graph (VKG).

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

