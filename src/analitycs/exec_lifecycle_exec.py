# %%

import pandas as pd
import sqlalchemy
# %%
def import_query(path):
    with open(path, 'r') as file:
        query = file.read()
    return query

query = import_query("life_cycle.sql")
print(query)

# caminho do banco de dados do sistema
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db") 

# caminho do banco de dados de analytics para ser gravado os dados
engine_analytics = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db") 

# %%
date = [
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01',
    '2025-10-01',
    '2025-11-01',
]

for d in date:
    #create a query to delete a row on life_cycle table to a specific date
    delete_query = f"DELETE FROM life_cycle WHERE dtRef = date('{d}', '-1 day')"

    with engine_analytics.connect() as conn:
        conn.execute(sqlalchemy.text(delete_query))
        conn.commit()

    date_query = query.format(date=d)
    df = pd.read_sql_query(date_query, engine_app)
    df.to_sql("life_cycle", engine_analytics, if_exists='append', index=False)

# %%
