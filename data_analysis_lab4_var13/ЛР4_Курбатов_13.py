import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from IPython.display import display
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans, AgglomerativeClustering
from sklearn.metrics import (silhouette_score, calinski_harabasz_score,
                             davies_bouldin_score, adjusted_rand_score,
                             adjusted_mutual_info_score)
from sklearn.metrics.cluster import contingency_matrix
from scipy.cluster.hierarchy import linkage, dendrogram

file_path = '/content/ecommerce_fraud.csv'
RANDOM_STATE = 42
sns.set_theme(style='whitegrid')
pd.set_option('display.max_columns', 40)

def cluster_metrics(X, labels, truth=None):
    result = {'Silhouette': silhouette_score(X, labels),
              'Calinski_Harabasz': calinski_harabasz_score(X, labels),
              'Davies_Bouldin': davies_bouldin_score(X, labels)}
    if truth is not None:
        result['ARI'] = adjusted_rand_score(truth, labels)
        result['AMI'] = adjusted_mutual_info_score(truth, labels)
    return result

def make_data(n, seed):
    np.random.seed(seed)
    shift_matrix = np.array([[3, 3], [6, 9], [9, 3]])
    data = np.random.randn(3, 2, n) + shift_matrix.reshape((3, 2, 1))
    data = np.swapaxes(data, 1, 2)
    data = data.reshape((-1, 2))
    data *= np.array([[20, 0.5]])
    df = pd.DataFrame({'x': data[:, 0], 'y': data[:, 1]}, columns=['x', 'y'])
    df = df.sample(frac=1.0)
    return df

synthetic = make_data(n=100, seed=RANDOM_STATE)
synthetic_scaler = StandardScaler()
synthetic_scaled = synthetic_scaler.fit_transform(synthetic)
print('Размер:', synthetic.shape)
display(synthetic.head())
display(pd.DataFrame({'Среднее z': synthetic_scaled.mean(axis=0),
                      'Стандартное отклонение z': synthetic_scaled.std(axis=0)},
                     index=synthetic.columns))

synthetic_models = {}
synthetic_rows = []
fig, axes = plt.subplots(1, 3, figsize=(16, 4))
for ax, k in zip(axes, [3, 2, 4]):
    model = KMeans(n_clusters=k, n_init=20, random_state=RANDOM_STATE)
    labels = model.fit_predict(synthetic_scaled)
    synthetic_models[k] = model
    centers = synthetic_scaler.inverse_transform(model.cluster_centers_)
    for cluster in range(k):
        points = synthetic.loc[labels == cluster]
        ax.scatter(points['x'], points['y'], s=18, label=f'Кластер {cluster}')
    ax.scatter(centers[:, 0], centers[:, 1], c='black', marker='X',
               s=120, label='Центры')
    score = silhouette_score(synthetic_scaled, labels)
    synthetic_rows.append({'k': k, 'Silhouette': score, 'Inertia': model.inertia_})
    ax.set(title=f'k = {k}, силуэт = {score:.3f}', xlabel='x', ylabel='y')
    ax.legend(fontsize=7)
plt.tight_layout()
plt.show()
synthetic_results = pd.DataFrame(synthetic_rows).sort_values('k')
display(synthetic_results.round(4))

elbow_rows = []
for k in range(1, 11):
    model = KMeans(n_clusters=k, n_init=20, random_state=RANDOM_STATE)
    model.fit(synthetic_scaled)
    elbow_rows.append({'k': k, 'Inertia': model.inertia_})
elbow_synthetic = pd.DataFrame(elbow_rows)
plt.figure(figsize=(8, 4))
plt.plot(elbow_synthetic['k'], elbow_synthetic['Inertia'], 'o-', label='Inertia')
plt.axvline(3, color='red', linestyle='--', label='Три исходные группы')
plt.xlabel('Число кластеров k')
plt.ylabel('Сумма квадратов расстояний')
plt.title('Метод локтя: искусственные данные')
plt.xticks(range(1, 11))
plt.legend()
plt.tight_layout()
plt.show()
print('Лучший силуэт среди k=2,3,4:',
      int(synthetic_results.loc[synthetic_results['Silhouette'].idxmax(), 'k']))

raw = pd.read_csv(file_path)
print('Исходный размер:', raw.shape)
display(raw.head(10))
raw.info()
display(raw.describe(include='all'))
print('Пропуски:', raw.isna().sum().to_dict())
print('Полные дубликаты:', raw.duplicated().sum())
display(raw['Fraud'].value_counts().rename('Количество').to_frame())

data = raw.drop_duplicates().copy()
numeric_columns = ['transaction_amount', 'num_items', 'time_on_site_sec',
                   'hour_of_day', 'account_age_days']
category_columns = ['device_type', 'browser', 'payment_method', 'country',
                    'is_first_purchase', 'referral']
for column in category_columns:
    data[column] = data[column].astype('string').str.strip().fillna('Unknown')
repairs = []
for column in numeric_columns:
    values = pd.to_numeric(data[column], errors='coerce')
    invalid = values < 0
    if column == 'num_items':
        invalid |= (values < 1) | (values > 7) | (values % 1 != 0)
    if column == 'hour_of_day':
        invalid |= (values > 23) | (values % 1 != 0)
    values = values.mask(invalid)
    missing = int(values.isna().sum())
    median = values.median()
    if pd.isna(median):
        raise ValueError(f'В {column} нет допустимых числовых значений')
    data[column] = values.fillna(median)
    repairs.append({'Признак': column, 'Исправлено': missing, 'Медиана': median})
assert data['Fraud'].isin([0, 1]).all()
assert not data[numeric_columns + category_columns].isna().any().any()
print('Удалено полных дубликатов:', len(raw) - len(data))
display(pd.DataFrame(repairs))
print('Строк после обработки:', len(data))

y = data['Fraud'].astype(int).copy()
pair_data = data[numeric_columns].copy()
pair_data['Класс'] = y.map({0: 'Обычная', 1: 'Мошенническая'})
grid = sns.pairplot(pair_data, vars=numeric_columns, hue='Класс',
                    diag_kind='hist', corner=True,
                    palette={'Обычная': 'steelblue', 'Мошенническая': 'crimson'},
                    plot_kws={'s': 9, 'alpha': 0.45},
                    diag_kws={'bins': 25})
grid.fig.suptitle('Числовые признаки и известные классы: все строки', y=1.02)
plt.show()

transformed = data[numeric_columns].copy()
for column in ['transaction_amount', 'time_on_site_sec']:
    transformed[column] = np.log1p(transformed[column])
scaler = StandardScaler()
X_numeric = pd.DataFrame(scaler.fit_transform(transformed),
                         columns=numeric_columns, index=data.index)
X_categories = pd.get_dummies(data[category_columns], dtype=float)
X = pd.concat([X_numeric, X_categories], axis=1)
assert 'Fraud' not in X.columns and np.isfinite(X.to_numpy()).all()
print('Матрица признаков:', X.shape)
display(X.head())
display(X_numeric.agg(['mean', 'std']).round(4))
print('Стандартное отклонение ddof=0:', X_numeric.std(ddof=0).round(4).tolist())

kmeans_models = {}
selection_rows = []
for k in range(2, 11):
    model = KMeans(n_clusters=k, n_init=20, random_state=RANDOM_STATE)
    labels = model.fit_predict(X)
    kmeans_models[k] = model
    selection_rows.append({'k': k, 'Inertia': model.inertia_,
                           **cluster_metrics(X, labels)})
selection = pd.DataFrame(selection_rows).set_index('k')
best_k = int(selection['Silhouette'].idxmax())
kmeans = kmeans_models[best_k]
km_labels = kmeans.labels_
display(selection.round(4))
print('Выбранное k по силуэту:', best_k)
fig, axes = plt.subplots(1, 2, figsize=(12, 4))
for ax, column in zip(axes, ['Inertia', 'Silhouette']):
    ax.plot(selection.index, selection[column], 'o-', label=column)
    ax.axvline(best_k, color='red', linestyle='--', label=f'Выбрано k={best_k}')
    ax.set(xlabel='Количество кластеров', ylabel=column, title=f'K-means: {column}')
    ax.legend()
plt.tight_layout()
plt.show()

def describe_clusters(labels):
    profile_data = pd.concat([data[numeric_columns], X_categories], axis=1)
    profile_data['Кластер'] = labels
    means = profile_data.groupby('Кластер').mean()
    summary = pd.DataFrame({'Кластер': labels, 'Fraud': y.to_numpy()})
    summary = summary.groupby('Кластер').agg(Размер=('Fraud', 'size'),
                                           Fraud_count=('Fraud', 'sum'),
                                           Fraud_rate=('Fraud', 'mean'))
    return summary, means

km_summary, km_means = describe_clusters(km_labels)
display(km_summary.round(4))
display(km_means.round(3))
assignments = data.copy()
assignments['KMeans_cluster'] = km_labels
display(assignments.head(20))
km_metrics = cluster_metrics(X, km_labels, y)
display(pd.Series(km_metrics, name='K-means').to_frame().round(4))

linked = linkage(X.to_numpy(), method='ward', metric='euclidean')
ag_models = {}
ag_rows = []
for k in range(2, 11):
    model = AgglomerativeClustering(n_clusters=k, linkage='ward', metric='euclidean')
    labels = model.fit_predict(X)
    ag_models[k] = model
    ag_rows.append({'k': k, **cluster_metrics(X, labels)})
ag_selection = pd.DataFrame(ag_rows).set_index('k')
best_ag_k = int(ag_selection['Silhouette'].idxmax())
agglomerative = ag_models[best_ag_k]
ag_labels = agglomerative.labels_
cut_height = (linked[-best_ag_k, 2] + linked[-best_ag_k + 1, 2]) / 2
plt.figure(figsize=(13, 5))
dendrogram(linked, truncate_mode='lastp', p=25, show_leaf_counts=True,
           color_threshold=cut_height)
plt.axhline(cut_height, color='red', linestyle='--', label=f'Разрез на {best_ag_k} кластеров')
plt.xlabel('Свёрнутые узлы и отдельные объекты')
plt.ylabel('Расстояние объединения Ward')
plt.title('Дендрограмма: все строки, показаны последние 25 узлов')
plt.legend()
plt.tight_layout()
plt.show()
display(ag_selection.round(4))
print('Выбранное число кластеров Ward:', best_ag_k)
ag_summary, ag_means = describe_clusters(ag_labels)
display(ag_summary.round(4))
display(ag_means.round(3))
assignments['Ward_cluster'] = ag_labels
ag_metrics = cluster_metrics(X, ag_labels, y)
comparison = pd.DataFrame([km_metrics, ag_metrics], index=['K-means', 'Ward'])
display(comparison.round(4))

pairs = [('transaction_amount', 'time_on_site_sec'), ('num_items', 'account_age_days')]
fig, axes = plt.subplots(1, 2, figsize=(13, 4))
for ax, (first, second) in zip(axes, pairs):
    for cluster in range(best_k):
        points = assignments.loc[km_labels == cluster]
        ax.scatter(points[first], points[second], s=10, alpha=0.4,
                   label=f'Кластер {cluster}')
        ax.scatter(points[first].mean(), points[second].mean(),
                   c='black', marker='X', s=90,
                   label='Средние координаты' if cluster == 0 else None)
    ax.set(xlabel=first, ylabel=second, title='Проекция кластеров K-means')
    ax.legend(fontsize=7)
plt.tight_layout()
plt.show()
for name, labels in [('K-means', km_labels), ('Ward', ag_labels)]:
    table = pd.DataFrame(contingency_matrix(y, labels),
                         index=['Обычная', 'Мошенническая'])
    table.columns = [f'Кластер {i}' for i in range(table.shape[1])]
    print(name, '— строки: классы, столбцы: кластеры')
    display(table)

numeric_models = {}
numeric_scores = []
for k in range(2, 11):
    model = KMeans(n_clusters=k, n_init=20, random_state=RANDOM_STATE)
    labels = model.fit_predict(X_numeric)
    numeric_models[k] = model
    numeric_scores.append({'k': k, 'Silhouette': silhouette_score(X_numeric, labels)})
numeric_selection = pd.DataFrame(numeric_scores).set_index('k')
numeric_k = int(numeric_selection['Silhouette'].idxmax())
numeric_metrics = cluster_metrics(X_numeric, numeric_models[numeric_k].labels_, y)
encoding_comparison = pd.DataFrame([numeric_metrics, km_metrics],
                                  index=['Числовые признаки', 'Числовые + категории'])
encoding_comparison['k'] = [numeric_k, best_k]
display(encoding_comparison.round(4))

preferred = comparison['Silhouette'].idxmax()
conclusion = (f'Искусственные данные: лучший силуэт среди 2,3,4 кластеров у k='
              f'{int(synthetic_results.loc[synthetic_results.Silhouette.idxmax(), "k"])}. '
              f'Транзакции: исходно {len(raw)}, после обработки {len(data)} строк. '
              f'K-means: k={best_k}, силуэт={km_metrics["Silhouette"]:.4f}, '
              f'ARI={km_metrics["ARI"]:.4f}; Ward: k={best_ag_k}, '
              f'силуэт={ag_metrics["Silhouette"]:.4f}, ARI={ag_metrics["ARI"]:.4f}. '
              f'По силуэту предпочтителен {preferred}. '
              'Кластеры описывают сходство транзакций и не являются готовым '
              'классификатором мошенничества. Для новых транзакций требуется '
              'отдельная проверка обобщения; Ward не имеет обычного predict.')
print(conclusion)
comparison.to_csv('Метрики_ЛР4.csv', encoding='utf-8-sig')
assignments.to_csv('Транзакции_с_кластерами.csv', index=True, index_label='Исходный_индекс',
                   encoding='utf-8-sig')
km_means.to_csv('Профили_KMeans.csv', encoding='utf-8-sig')
ag_means.to_csv('Профили_Ward.csv', encoding='utf-8-sig')