data = pd.read_csv('cleaned_district_Jan_5.csv')
data.sort_values(by = ['id', 'year'], inplace = True)
data['lag_lianjia'] = data.groupby('id')['lianjia_420'].shift(1)
data['lag_lianjia'] = data['lag_lianjia'].fillna(data['lianjia_420'])
data[['id', 'lianjia_420', 'lag_lianjia']]
data['entry'] = (data['lianjia_420'] > data['lag_lianjia']).astype(int)
data.sort_values(by = ['id', 'year'], inplace = True)
data['lag_lianjia1'] = data.groupby('id')['lianjia_5'].shift(1)
data['lag_lianjia1'] = data['lag_lianjia1'].fillna(data['lianjia_5'])
data[['id', 'lianjia_5', 'lag_lianjia']]
data['entry1'] = (data['lianjia_5'] > data['lag_lianjia1']).astype(int)
n = 3
for i in range(1, n + 1):
    data[f'post{i}'] = data.groupby('id')['entry'].shift(i).fillna(0)
for i in range(1, n + 1):
    data[f'pre{i}'] = data.groupby('id')['entry'].shift(-i).fillna(0)
n = 3
for i in range(1, n + 1):
    data[f'postr{i}'] = data.groupby('id')['entry1'].shift(i).fillna(0)
for i in range(1, n + 1):
    data[f'prer{i}'] = data.groupby('id')['entry1'].shift(-i).fillna(0)
data.to_csv('cleaned_district_Jan_6.csv', index = None)
