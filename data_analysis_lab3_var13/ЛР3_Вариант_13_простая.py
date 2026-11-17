import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from IPython.display import display
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures, StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

excel_file = '/content/regression (1).xlsx'  # Укажите путь к Excel.
salary_file = '/content/salary.csv'  # Укажите путь к CSV.

df = pd.read_excel(excel_file, sheet_name='var3')
salary = pd.read_csv(salary_file)
salary_raw = salary.copy()  # Исходные данные сохраняются отдельно.

# Одна функция для одинакового расчёта метрик всех моделей.
def metrics(y, prediction):
    mse = mean_squared_error(y, prediction)
    return {'MAE': mean_absolute_error(y, prediction),
            'MSE': mse, 'RMSE': np.sqrt(mse), 'R2': r2_score(y, prediction)}


display(df.head(20))
display(df.describe())
print('Пропуски:', df.isna().sum().to_dict())
print('Дубликаты:', df.duplicated().sum())
display(df.corr(method='pearson'))


train_index, valid_index = train_test_split(df.index, test_size=0.25, random_state=42)
y_train_reg = df.loc[train_index, 'y']
y_valid_reg = df.loc[valid_index, 'y']
linear_results = []

for feature in ['x1', 'x2']:
    model = LinearRegression()
    model.fit(df.loc[train_index, [feature]], y_train_reg)
    prediction = model.predict(df.loc[valid_index, [feature]])
    linear_results.append({'Признак': feature, **metrics(y_valid_reg, prediction)})
    print(f'{feature}: y = {model.coef_[0]:.5f} * {feature} {model.intercept_:+.5f}')
    comparison = pd.DataFrame({'Факт': y_valid_reg, 'Прогноз': prediction})
    comparison['Прогноз − факт'] = comparison['Прогноз'] - comparison['Факт']
    with pd.option_context('display.max_rows', None):
        display(comparison.sort_index())

    fig, axes = plt.subplots(1, 3, figsize=(16, 4))
    x_line = pd.DataFrame({feature: np.linspace(df[feature].min(), df[feature].max(), 200)})
    axes[0].scatter(df[feature], df['y'], s=10, alpha=0.4, label='Наблюдения')
    axes[0].plot(x_line[feature], model.predict(x_line), color='red', label='Линейная регрессия')
    axes[0].set(xlabel=feature, ylabel='y', title='Линия регрессии')
    errors = comparison.sort_index()['Прогноз − факт']
    axes[1].scatter(errors.index, errors, s=12, label='Прогноз − факт')
    axes[1].axhline(0, color='red', label='Нулевая ошибка')
    axes[1].set(xlabel='Индекс наблюдения', ylabel='Прогноз − факт', title='Ошибки валидации')
    lo = min(y_valid_reg.min(), prediction.min())
    hi = max(y_valid_reg.max(), prediction.max())
    axes[2].scatter(y_valid_reg, prediction, s=12, label='Прогнозы на валидации')
    axes[2].plot([lo, hi], [lo, hi], color='red', label='Идеальное совпадение')
    axes[2].set(xlabel='Факт', ylabel='Прогноз', title='Факт и прогноз')
    axes[2].set_aspect('equal', adjustable='box')
    for ax in axes:
        ax.legend(fontsize=8)
    plt.tight_layout()
    plt.show()

display(pd.DataFrame(linear_results))


poly_results = []
fig, axes = plt.subplots(1, 2, figsize=(12, 4))

for ax, degree in zip(axes, [2, 3]):
    poly = PolynomialFeatures(degree=degree, include_bias=False)
    X_train_poly = poly.fit_transform(df.loc[train_index, ['x2']])
    X_valid_poly = poly.transform(df.loc[valid_index, ['x2']])
    model_poly = LinearRegression()
    model_poly.fit(X_train_poly, y_train_reg)
    train_prediction = model_poly.predict(X_train_poly)
    valid_prediction = model_poly.predict(X_valid_poly)
    poly_results.append({'Степень': degree,
                         'R2 train': r2_score(y_train_reg, train_prediction),
                         'R2 valid': r2_score(y_valid_reg, valid_prediction),
                         'MAE train': mean_absolute_error(y_train_reg, train_prediction),
                         'MAE valid': mean_absolute_error(y_valid_reg, valid_prediction)})
    print('Степень:', degree)
    display(pd.DataFrame({'Факт': y_valid_reg, 'Прогноз': valid_prediction}).head(20))
    x_line = pd.DataFrame({'x2': np.linspace(df['x2'].min(), df['x2'].max(), 200)})
    ax.scatter(df['x2'], df['y'], s=10, alpha=0.4, label='Наблюдения')
    ax.plot(x_line['x2'], model_poly.predict(poly.transform(x_line)), color='red',
            label=f'Полином степени {degree}')
    ax.set(xlabel='x2', ylabel='y', title=f'Степень {degree}')
    ax.legend(fontsize=8)

plt.tight_layout()
plt.show()
poly_table = pd.DataFrame(poly_results)
display(poly_table)
print('Лучшая степень по MAE valid:', int(poly_table.loc[poly_table['MAE valid'].idxmin(), 'Степень']))


display(salary_raw.head(20))
salary_raw.info()
display(salary_raw.describe())
print('Пропуски:', salary_raw.isna().sum().to_dict())
print('Дубликаты:', salary_raw.duplicated().sum())
for column in salary_raw.select_dtypes(include='object'):
    print(column, ':', salary_raw[column].unique())

fig, axes = plt.subplots(1, 2, figsize=(12, 4))
axes[0].hist(salary_raw['salary'], bins=30, label='Все 1500 наблюдений')
axes[0].set(xlabel='Годовая зарплата', ylabel='Количество', title='Распределение salary')
salary_box = axes[1].boxplot(
    salary_raw['salary'], patch_artist=True, boxprops={'facecolor': 'lightblue'}
)
axes[0].legend(fontsize=8)
axes[1].legend([salary_box['boxes'][0]], ['Распределение salary'], fontsize=8)
axes[1].set(ylabel='Годовая зарплата', title='Boxplot salary')
plt.tight_layout()
plt.show()


# Границы рассчитываются один раз по исходному набору.
q1, q3 = salary_raw['salary'].quantile([0.25, 0.75])
iqr = q3 - q1
lower_bound = q1 - 1.5 * iqr
upper_bound = q3 + 1.5 * iqr
keep = salary_raw['salary'].between(lower_bound, upper_bound)
salary = salary_raw.loc[keep].copy()
excluded_salary = salary_raw.loc[~keep].copy()
print(f'Границы зарплаты: {lower_bound:.2f} — {upper_bound:.2f}')
print('Исходных строк:', len(salary_raw))
print('Удалено:', len(excluded_salary),
      '(снизу:', (salary_raw['salary'] < lower_bound).sum(),
      ', сверху:', (salary_raw['salary'] > upper_bound).sum(), ')')
print('Осталось после очистки:', len(salary))
assert salary['salary'].between(lower_bound, upper_bound).all()

fig, axes = plt.subplots(1, 2, figsize=(12, 4))
axes[0].hist(salary['salary'], bins=30, label=f'После очистки: {len(salary)} записей')
axes[0].set(xlabel='Годовая зарплата', ylabel='Количество', title='Salary после очистки')
axes[0].legend(fontsize=8)
clean_box = axes[1].boxplot(
    salary['salary'], patch_artist=True, boxprops={'facecolor': 'lightblue'}
)
axes[1].set(ylabel='Годовая зарплата', title='Boxplot после очистки')
axes[1].legend([clean_box['boxes'][0]], ['Очищенная выборка'], fontsize=8)
plt.tight_layout()
plt.show()

# Разбиение выполняется после очистки. Для всех моделей одни и те же строки.
X = salary.drop(columns='salary')
y = salary['salary']
X_train, X_valid, y_train, y_valid = train_test_split(
    X, y, test_size=0.25, random_state=42
)
print('Обучение:', len(y_train), 'Валидация:', len(y_valid))
assert len(y_train) + len(y_valid) == len(salary)
assert set(X_train.index).isdisjoint(X_valid.index)

# Матрица рассеяния всех числовых признаков и цели на обучающих строках.
scatter_data = X_train.select_dtypes(include='number').assign(salary=y_train)
scatter_axes = pd.plotting.scatter_matrix(
    scatter_data, figsize=(17, 17), diagonal='hist', alpha=0.2, s=5
)
scatter_figure = scatter_axes[0, 0].figure
scatter_figure.legend(
    handles=[scatter_axes[0, 1].collections[0]],
    labels=['Наблюдения train; на диагонали — гистограммы'],
    loc='upper center', fontsize=10
)
scatter_figure.subplots_adjust(top=0.96)
plt.show()

numeric_columns = X_train.select_dtypes(include='number').columns
X_train = pd.get_dummies(X_train, drop_first=True, dtype=int)
X_valid = pd.get_dummies(X_valid, drop_first=True, dtype=int)
X_valid = X_valid.reindex(columns=X_train.columns, fill_value=0)

scaler = StandardScaler()
X_train[numeric_columns] = scaler.fit_transform(X_train[numeric_columns])
X_valid[numeric_columns] = scaler.transform(X_valid[numeric_columns])
display(X_train.head())


models = {'Линейная регрессия': LinearRegression(),
          'kNN': KNeighborsRegressor(n_neighbors=5),
          'Дерево решений': DecisionTreeRegressor(max_depth=5, random_state=42)}
results = []
predictions = {}

for name, model in models.items():
    model.fit(X_train, y_train)
    prediction = model.predict(X_valid)
    predictions[name] = prediction
    results.append({'Модель': name, **metrics(y_valid, prediction)})

result_table = pd.DataFrame(results).set_index('Модель')
display(result_table)
comparison = pd.DataFrame({'Факт salary': y_valid})
for name, prediction in predictions.items():
    comparison[name] = prediction
with pd.option_context('display.max_rows', None):
    display(comparison.sort_index())


coefficients = pd.DataFrame({'Признак': X_train.columns,
                             'Коэффициент': models['Линейная регрессия'].coef_})
coefficients['Модуль'] = coefficients['Коэффициент'].abs()
display(coefficients.sort_values('Модуль', ascending=False))
print('Свободный член:', models['Линейная регрессия'].intercept_)
print('Базовые категории:')
for column in salary.select_dtypes(include='object'):
    print(column, ':', sorted(salary.loc[y_train.index, column].unique())[0])


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
for ax, (name, prediction) in zip(axes, predictions.items()):
    ax.scatter(y_valid, prediction, s=15, alpha=0.5, label='Прогнозы на валидации')
    lo = min(y_valid.min(), prediction.min())
    hi = max(y_valid.max(), prediction.max())
    ax.plot([lo, hi], [lo, hi], color='red', label='Идеальное совпадение')
    ax.set(xlabel='Фактическая зарплата', ylabel='Прогноз зарплаты', title=name)
    ax.set_aspect('equal', adjustable='box')
    ax.legend(fontsize=8)
plt.tight_layout()
plt.show()

order = np.argsort(y_valid.to_numpy())
plt.figure(figsize=(12, 5))
plt.plot(y_valid.to_numpy()[order], color='black', label='Факт')
for name, prediction in predictions.items():
    plt.scatter(np.arange(len(order)), prediction[order], s=9, alpha=0.5, label=name)
plt.xlabel('Наблюдения в порядке роста фактической зарплаты')
plt.ylabel('Годовая зарплата')
plt.legend()
plt.show()


best = result_table['MAE'].idxmin()
print('Наименьшая MAE:', best)
print('MAE:', round(result_table.loc[best, 'MAE'], 2))
print('R2:', round(result_table.loc[best, 'R2'], 4))
print('Наименьшая RMSE:', result_table['RMSE'].idxmin())
print('Три самых больших по модулю коэффициента среди числовых признаков:')
display(coefficients[coefficients['Признак'].isin(numeric_columns)].nlargest(3, 'Модуль'))
