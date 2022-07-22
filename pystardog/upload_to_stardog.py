import os

import stardog

conn_details = {
  'endpoint': 'https://stardog.137.120.31.102.nip.io',
  'username': 'admin',
  'password': os.getenv('STARDOG_PASSWORD', 'admin')
}

with stardog.Admin(**conn_details) as admin:
  # db = admin.new_database('db')

  with stardog.Connection('covid19', **conn_details) as conn:
    conn.begin()
    conn.add(stardog.content.File('./example.ttl'))
    conn.commit()
    results = conn.select('select * { ?s ?p ?o }')

  # db.drop()