# %% [markdown]
# # Лабораторная работа №3. Регрессионный анализ
# ФИО: __________________  
# Группа: __________________  
# Вариант: **13**, лист **var3** по согласованному циклическому правилу.
# 
# **Цель работы:** изучить простую и полиномиальную регрессию, сравнить несколько методов прогнозирования зарплаты.

# %% [markdown]
# ## Загрузка файлов и библиотек

# %%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from IPython.display import display
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures, StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# В Colab выберите два файла: regression (1).xlsx и salary.csv.
try:
    from google.colab import files
    files.upload()
except ImportError:
    pass

excel_file = next(Path('.').glob('regression*.xlsx'))
df = pd.read_excel(excel_file, sheet_name='var3')
salary = pd.read_csv('salary.csv')

# Одна функция для одинакового расчёта метрик всех моделей.
def metrics(y, prediction):
    mse = mean_squared_error(y, prediction)
    return {'MAE': mean_absolute_error(y, prediction),
            'MSE': mse, 'RMSE': np.sqrt(mse), 'R2': r2_score(y, prediction)}


# %% [markdown]
# ## Часть 1. Простая линейная регрессия
# ### 1. Описание данных и корреляции
# `x1` и `x2` — числовые признаки, `y` — целевая переменная. Предметный смысл и единицы измерения в задании не указаны.

# %%
display(df.head(20))
display(df.describe())
print('Пропуски:', df.isna().sum().to_dict())
print('Дубликаты:', df.duplicated().sum())
display(df.corr(method='pearson'))


# %% [markdown]
# В наборе 1000 строк, пропусков и дубликатов нет. Корреляция `x1` и `y` близка к нулю (0,0003). Для `x2` и `y` она равна примерно 0,85: линейная связь сильная и положительная. Слабая корреляция сама по себе не исключает нелинейную связь.

# %% [markdown]
# ### 2–9. Обучение двух моделей, прогнозы и графики
# Для обеих моделей использую одно разбиение: 75% строк для обучения, 25% для валидации. Модели сравниваются на одинаковых наблюдениях.
# 
# MAE — средняя абсолютная ошибка, MSE — средняя квадратичная ошибка, RMSE — её корень в единицах целевой переменной. Чем меньше эти ошибки, тем лучше. R² показывает качество относительно прогноза среднего на оцениваемой выборке: максимум равен 1, значение может быть отрицательным.

# %%
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
    axes[0].scatter(df[feature], df['y'], s=10, alpha=0.4)
    axes[0].plot(x_line[feature], model.predict(x_line), color='red')
    axes[0].set(xlabel=feature, ylabel='y', title='Линия регрессии')
    errors = comparison.sort_index()['Прогноз − факт']
    axes[1].scatter(errors.index, errors, s=12)
    axes[1].axhline(0, color='red')
    axes[1].set(xlabel='Индекс наблюдения', ylabel='Прогноз − факт', title='Ошибки валидации')
    lo = min(y_valid_reg.min(), prediction.min())
    hi = max(y_valid_reg.max(), prediction.max())
    axes[2].scatter(y_valid_reg, prediction, s=12)
    axes[2].plot([lo, hi], [lo, hi], color='red')
    axes[2].set(xlabel='Факт', ylabel='Прогноз', title='Факт и прогноз')
    axes[2].set_aspect('equal', adjustable='box')
    plt.tight_layout()
    plt.show()

display(pd.DataFrame(linear_results))


# %% [markdown]
# ### 10. Вывод
# Модель по `x2` точнее: MAE около 0,697 и R² около 0,730. Для `x1` MAE около 1,455, R² отрицательный. Поэтому из двух парных моделей выбираю модель по `x2`. На графике её прогнозы ближе к диагонали идеального совпадения.

# %% [markdown]
# ## Часть 2. Полиномиальная регрессия
# ### 1–6. Сравнение степеней 2 и 3
# Выбираю `x2`: в первой части он оказался полезнее для прогноза `y`. Проверю, улучшит ли добавление степеней этого признака качество по сравнению с прямой. Использую те же обучающие и валидационные строки. Степень сравниваю по MAE и R² на валидации.

# %%
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
    ax.scatter(df['x2'], df['y'], s=10, alpha=0.4)
    ax.plot(x_line['x2'], model_poly.predict(poly.transform(x_line)), color='red')
    ax.set(xlabel='x2', ylabel='y', title=f'Степень {degree}')

plt.tight_layout()
plt.show()
poly_table = pd.DataFrame(poly_results)
display(poly_table)
print('Лучшая степень по MAE valid:', int(poly_table.loc[poly_table['MAE valid'].idxmin(), 'Степень']))


# %% [markdown]
# ### 7. Вывод
# Степень выбираю по качеству на валидации, а не только на обучении. Слишком низкая степень может не описать изгиб зависимости, слишком высокая — подстроиться под шум. Для этого листа полиномы дают результат, близкий к линейной модели. Если улучшение мало, разумнее оставить более простую модель. Численные результаты двух степеней приведены в таблице выше.
# 
# Среди двух полиномов меньше MAE у степени 2: MAE valid = 0.6982, R² valid = 0.7292. Существенного преимущества перед прямой нет.

# %% [markdown]
# ## Часть 3. Прогноз зарплаты
# ### 1–2. Обзор данных и целевая переменная
# Целевая переменная — `salary`, годовая зарплата. `income` означает доход до текущей работы и используется как признак.
# 
# Числовые признаки: возраст (`age`), предыдущий доход (`income`), опыт (`experience`), результат теста (`score_test`), рабочие часы (`hours_worked`), расстояние до работы (`distance_to_work`), сбережения (`savings`), долги (`debt`). Категориальные: образование (`education`), город (`city`), сфера работы (`job_type`), семейное положение (`marital_status`), автомобиль (`car`), удалённая работа (`remote_work`).

# %%
display(salary.head(20))
salary.info()
display(salary.describe())
print('Пропуски:', salary.isna().sum().to_dict())
print('Дубликаты:', salary.duplicated().sum())
for column in salary.select_dtypes(include='object'):
    print(column, ':', salary[column].unique())

fig, axes = plt.subplots(1, 2, figsize=(12, 4))
axes[0].hist(salary['salary'], bins=30)
axes[0].set(xlabel='Годовая зарплата', ylabel='Количество', title='Распределение salary')
axes[1].boxplot(salary['salary'])
axes[1].set(ylabel='Годовая зарплата', title='Boxplot salary')
plt.tight_layout()
plt.show()


# %% [markdown]
# ### 3–6. Подготовка данных
# В файле 1500 строк, пропусков и дубликатов нет. На гистограмме видны редкие очень большие зарплаты. В учебном эксперименте исключаю из **обучающей части** значения зарплаты за границами 1,5 IQR. Границы считаю только на train, а валидацию сохраняю полностью. Так проверяется и качество на редких больших зарплатах. Такое удаление — принятое правило подготовки, а не доказательство ошибки в исходных строках.
# 
# Разбиение выполняю до обработки, чтобы информация из валидации не влияла на обучение. Категории кодирую через `get_dummies(drop_first=True)`. Числовые признаки стандартизирую по train. Масштабирование особенно важно для kNN.

# %%
X = salary.drop(columns='salary')
y = salary['salary']
X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.25, random_state=42)

q1, q3 = y_train.quantile([0.25, 0.75])
iqr = q3 - q1
keep = y_train.between(q1 - 1.5 * iqr, q3 + 1.5 * iqr)
print('Строк до обработки:', len(y_train))
print('Исключено из train:', (~keep).sum())
X_train = X_train.loc[keep].copy()
y_train = y_train.loc[keep].copy()
print('После обработки:', len(y_train), 'Валидация:', len(y_valid))

fig, axes = plt.subplots(1, 2, figsize=(12, 4))
axes[0].hist(y_train, bins=30)
axes[0].set(xlabel='Годовая зарплата', ylabel='Количество', title='Train после обработки')
axes[1].boxplot(y_train)
axes[1].set(ylabel='Годовая зарплата', title='Train после обработки')
plt.tight_layout()
plt.show()

# Матрица рассеяния всех числовых признаков и цели на обучающих строках.
scatter_data = X_train.select_dtypes(include='number').assign(salary=y_train)
pd.plotting.scatter_matrix(scatter_data, figsize=(17, 17), diagonal='hist', alpha=0.2, s=5)
plt.show()

numeric_columns = X_train.select_dtypes(include='number').columns
X_train = pd.get_dummies(X_train, drop_first=True, dtype=int)
X_valid = pd.get_dummies(X_valid, drop_first=True, dtype=int)
X_valid = X_valid.reindex(columns=X_train.columns, fill_value=0)

scaler = StandardScaler()
X_train[numeric_columns] = scaler.fit_transform(X_train[numeric_columns])
X_valid[numeric_columns] = scaler.transform(X_valid[numeric_columns])
display(X_train.head())


# %% [markdown]
# ### 7–9, 12–13. Обучение и сравнение трёх методов
# Использую линейную регрессию, kNN с пятью соседями и дерево с максимальной глубиной 5. Это заданные параметры для сравнения, подбор оптимальных параметров в обязательную часть не входит. Все три метода обучаю и проверяю на одинаковых строках.

# %%
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


# %% [markdown]
# ### 10. Коэффициенты линейной регрессии
# Коэффициент числового признака показывает изменение прогноза при росте признака на одно стандартное отклонение, остальные признаки фиксированы. Коэффициент категории — разницу с базовой категорией. Эти два типа коэффициентов имеют разный смысл, поэтому их модули нельзя безусловно считать общим рейтингом важности. Связь с прогнозом не доказывает причинное влияние.
# 
# Среди числовых признаков наибольшие по модулю коэффициенты у experience, income, score_test. Их вклад сравнивается после стандартизации.

# %%
coefficients = pd.DataFrame({'Признак': X_train.columns,
                             'Коэффициент': models['Линейная регрессия'].coef_})
coefficients['Модуль'] = coefficients['Коэффициент'].abs()
display(coefficients.sort_values('Модуль', ascending=False))
print('Свободный член:', models['Линейная регрессия'].intercept_)
print('Базовые категории:')
for column in salary.select_dtypes(include='object'):
    print(column, ':', sorted(salary.loc[y_train.index, column].unique())[0])


# %% [markdown]
# ### 11, 13. Визуализация факта и прогноза
# Красная диагональ — идеальное совпадение. Чем ближе к ней точки, тем точнее прогноз.

# %%
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
for ax, (name, prediction) in zip(axes, predictions.items()):
    ax.scatter(y_valid, prediction, s=15, alpha=0.5)
    lo = min(y_valid.min(), prediction.min())
    hi = max(y_valid.max(), prediction.max())
    ax.plot([lo, hi], [lo, hi], color='red')
    ax.set(xlabel='Фактическая зарплата', ylabel='Прогноз зарплаты', title=name)
    ax.set_aspect('equal', adjustable='box')
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


# %% [markdown]
# ### 14. Вывод по задаче зарплаты
# Сравниваю методы по общей валидационной выборке. При выборе по MAE предпочтительна модель с наименьшей средней абсолютной ошибкой. Если R² отрицательный, модель по квадрату ошибки хуже прогноза среднего на оцениваемой выборке. Даже небольшая MAE для обычных зарплат не гарантирует точного прогноза редких высоких значений.
# 
# По MAE выбираю метод «Линейная регрессия»: MAE = 20703.27, R² = -0.0141. У всех трёх методов R² отрицателен: большие зарплаты на графиках остаются недооценёнными. Поэтому этот выбор относится к средней абсолютной ошибке, а не к хорошему прогнозу всего диапазона зарплат.

# %%
best = result_table['MAE'].idxmin()
print('Наименьшая MAE:', best)
print('MAE:', round(result_table.loc[best, 'MAE'], 2))
print('R2:', round(result_table.loc[best, 'R2'], 4))
print('Наименьшая RMSE:', result_table['RMSE'].idxmin())
print('Три самых больших по модулю коэффициента среди числовых признаков:')
display(coefficients[coefficients['Признак'].isin(numeric_columns)].nlargest(3, 'Модуль'))


# %% [markdown]
# ## Общий вывод
# В работе выполнены простая и полиномиальная регрессия для листа var3, а также прогноз годовой зарплаты. В первой части признак x2 оказался полезнее x1: R² линейной модели составил около 0,73. Во второй части сравнены полиномы второй и третьей степени, их результаты сопоставлены с прямой.
# 
# Для salary проверены пропуски и дубликаты, обработаны крайние зарплаты только в обучающей части, категории преобразованы в числовые столбцы, числовые признаки стандартизированы. Сравнены линейная регрессия, kNN и дерево решений по четырём метрикам. Лучший метод по MAE и его показатели приведены выше. Редкие высокие зарплаты затрудняют прогноз, поэтому качество необходимо оценивать вместе по таблице метрик и графикам.
# 
# В данных также встречаются неправдоподобные сочетания возраста и опыта. Без сведений об источнике они не исправлялись по предположению. Для практического применения потребовалась бы проверка качества исходных данных.