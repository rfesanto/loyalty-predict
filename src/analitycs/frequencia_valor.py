#%%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
# %%
# abre conexao com o database
engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
# %%
# 
# funçao para importar query de arquivo externo
def import_query(path):
    with open(path, 'r') as file:
        query = file.read()
    return query
#%%
# query imporatada de arquivo externo
query = import_query("frequencia_valor.sql")
print(query)
# %%
# executa a query e armazena o resultado em um dataframe
df = pd.read_sql_query(query, engine)
# remover os valores de qtd de pontos maiores que 5000
df = df[df['qtdePontosPos'] <= 5000]

Standardscaler = StandardScaler()

X = Standardscaler.fit_transform(df[['qtdeFrequencia', 'qtdePontosPos']])
# %%
df.plot(['qtdeFrequencia'], ['qtdePontosPos']
        , grid=True
        , kind='scatter'
        , xlabel='Frequência'
        , ylabel='Valor'
        , title='Frequência x Valor'
        )

# %%
kmeans = KMeans(n_clusters=5, random_state=42)
y_pred = kmeans.fit_predict(X)
y_pred is kmeans.labels_
df['cluster_calc'] = y_pred


sns.scatterplot(data=df, 
                x='qtdeFrequencia', 
                y='qtdePontosPos',
                hue='cluster_calc',
                palette='Set1')
plt.title('Frequência x Valor com Clusters')
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.grid(True)
# %%
sns.scatterplot(data=df, 
                x='qtdeFrequencia', 
                y='qtdePontosPos',
                hue='cluster',
                palette='Set1')
plt.title('Frequência x Valor com Clusters')
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.legend(bbox_to_anchor=(0.5, -0.2), loc='upper center', borderaxespad=0.)
plt.grid(True)
# %%
