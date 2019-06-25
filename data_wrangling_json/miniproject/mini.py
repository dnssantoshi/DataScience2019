import json
import pandas as pd
from pandas.io.json import json_normalize

dataframe=pd.DataFrame()
for f in sample_json_df.mjtheme_namecode:
#     print(json_normalize(f))
    dataframe = pd.concat([dataframe,json_normalize(f)])
# df.sort(['A', 'B'], ascending=[1, 0]
print(dataframe.name.unique())
print(dataframe.groupby('code')['name'])
clean_df=dataframe.groupby('code')['name'].count()
clean_df.reset_index(name='name_count')

print(type(clean_df))
print(clean_df.sort_values())