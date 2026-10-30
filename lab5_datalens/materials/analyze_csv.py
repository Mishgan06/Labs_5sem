#!/usr/bin/env python3
"""Independent analysis of the assigned CSV. No networking and no fabricated input data."""
import argparse,csv,io,json,re,tempfile
from collections import defaultdict,Counter
from pathlib import Path

def missing_periods(years):
    ordered=sorted(set(years))
    gaps=[{'start':a+1,'end':b-1,'years':b-a-1} for a,b in zip(ordered,ordered[1:]) if b-a>1]
    if not gaps:return []
    maximum=max(g['years'] for g in gaps)
    return [g for g in gaps if g['years']==maximum]

def ranking(groups):
    return [{'value':str(k),'count':len(v)} for k,v in sorted(groups.items(),key=lambda x:(-len(x[1]),str(x[0])))]

def leaders(ranked):
    return [r for r in ranked if r['count']==ranked[0]['count']] if ranked else []

def analyze(path,encoding='auto'):
    raw=Path(path).read_bytes()
    if encoding=='auto':
        try:text=raw.decode('utf-8-sig');encoding='utf-8-sig'
        except UnicodeDecodeError:text=raw.decode('cp1251');encoding='cp1251'
    else:text=raw.decode(encoding)
    reader=csv.DictReader(io.StringIO(text),delimiter=';')
    if not reader.fieldnames:raise ValueError('CSV has no header')
    names=[s.strip().lstrip('\ufeff') for s in reader.fieldnames]
    if len(set(names))!=len(names):raise ValueError('Duplicate header names')
    reader.fieldnames=names
    required={'movie title','year_release','country','producer'}
    if not required.issubset(names):raise ValueError('Missing columns: '+', '.join(sorted(required-set(names)))+'; check delimiter ; and header')
    by_year=defaultdict(set);by_country=defaultdict(set);by_director=defaultdict(set);russia=defaultdict(set);titles=Counter();quality=Counter();rows=0
    variants={'country':defaultdict(set),'producer':defaultdict(set)}
    for line,row in enumerate(reader,2):
        if None in row:raise ValueError(f'Extra cells at CSV line {line}; inspect separators/quoting')
        rows+=1;title=row.get('movie title') or ''
        for field in variants:
            value=row.get(field) or ''
            variants[field][value.strip().casefold()].add(value)
        if not title.strip():quality['missing_title']+=1;continue
        titles[title]+=1
        country=row.get('country') or '';director=row.get('producer') or ''
        if country:by_country[country].add(title)
        else:quality['missing_country']+=1
        if director:by_director[director].add(title)
        else:quality['missing_producer']+=1
        yeartext=(row.get('year_release') or '').strip()
        if not re.fullmatch(r'\d{4}',yeartext):quality['invalid_or_missing_year']+=1;continue
        year=int(yeartext);by_year[year].add(title)
        if country=='Россия':russia[year].add(title)
    yr,cr,dr,rr=map(ranking,[by_year,by_country,by_director,russia])
    return {'source_file':Path(path).name,'encoding_used':encoding,'delimiter':';','rows':rows,'unique_titles':len(titles),
        'metric':'COUNTD(movie title); nonempty titles; raw country/producer strings, no splitting or silent normalization',
        'year_range':[min(by_year),max(by_year)] if by_year else None,'year_maximum':leaders(yr),
        'longest_internal_missing_periods':missing_periods(by_year),'countries_ranked':cr,'directors_ranked':dr,
        'country_leaders':leaders(cr),'director_leaders':leaders(dr),'russia_year_maximum':leaders(rr),
        'russia_exact_rows_present':bool(russia),'russia_definition':'country exactly equals Россия; СССР and coproduction strings are not merged',
        'years_ranked':yr,'russia_years_ranked':rr,'quality':dict(quality),
        'repeated_title_values':{k:v for k,v in titles.items() if v>1},
        'normalization_candidates':{f:[sorted(v) for k,v in g.items() if len(v)>1] for f,g in variants.items()},
        'status':'Computed from supplied file; not a DataLens GUI validation'}

def answer_text(r):
    def fmt(items):return '; '.join(f"{x['value']} — {x['count']}" for x in items) or 'Нет данных'
    gaps=r['longest_internal_missing_periods'];gap='; '.join(f"{g['start']}–{g['end']}: {g['years']} лет" for g in gaps) or 'Внутренних пропусков между наблюдаемыми годами нет'
    return '\n'.join(['# Ответы по предоставленному CSV',f"Файл: {r['source_file']}; строк: {r['rows']}; уникальных названий: {r['unique_titles']}.",
        '1. Максимум по году: '+fmt(r['year_maximum']), '2. Самый длинный внутренний пропуск: '+gap,
        'Пропуск относится только к данной выборке, а объяснение причины требует отдельного обоснования.',
        '3. Лидирующие страны: '+fmt(r['country_leaders']), 'Первые 10 категорий: '+fmt(r['countries_ranked'][:10]),
        '4. Лидирующие режиссёры: '+fmt(r['director_leaders']), 'Первые 10 категорий: '+fmt(r['directors_ranked'][:10]),
        '5. Максимум для country = Россия: '+fmt(r['russia_year_maximum']),
        'СССР и составные названия стран не объединены с Россией. Считаются уникальные названия, как в задании; сравните с исходными строками и диагностикой качества.',
        'Полная диагностика и равные максимумы сохранены в analysis.json.'])+'\n'

def self_test():
    assert missing_periods([])==[]
    assert missing_periods([2000])==[]
    assert missing_periods([2000,2001,2002])==[]
    assert missing_periods([2000,2003,2006])==[{'start':2001,'end':2002,'years':2},{'start':2004,'end':2005,'years':2}]
    assert leaders(ranking({'A':{1},'B':{1,2},'C':{3,4}}))==[{'value':'B','count':2},{'value':'C','count':2}]
    with tempfile.TemporaryDirectory() as folder:
        p=Path(folder)/'selftest.csv'
        sample='movie title;year_release;country;producer\nА;2000;Россия;Р1\nБ;2003;США;Р1\nА;2000;Россия;Р1\nВ;2003;Россия;Р2\n'
        p.write_bytes(sample.encode('cp1251'));r=analyze(p)
        assert r['unique_titles']==3 and r['rows']==4 and r['year_maximum']==[{'value':'2003','count':2}]
        assert r['russia_year_maximum']==[{'value':'2000','count':1},{'value':'2003','count':1}]
    print('PASS: gap boundaries, tied maxima, cp1251/semicolon import and COUNTD semantics on synthetic self-test data; assigned CSV not analyzed')

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('csv',nargs='?');parser.add_argument('--encoding',default='auto');parser.add_argument('--out',default='kinopoisk_analysis');parser.add_argument('--self-test',action='store_true');args=parser.parse_args()
    if args.self_test:self_test();return
    if not args.csv:parser.error('Provide the actual kinopoisk-top250.csv')
    result=analyze(args.csv,args.encoding);out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    (out/'analysis.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (out/'answers.md').write_text(answer_text(result),encoding='utf-8')
    print(answer_text(result))
if __name__=='__main__':main()
