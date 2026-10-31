#!/usr/bin/env python3
"""Read a supplied DTP CSV, audit event grain and compute only supported event-level summaries."""
import argparse,csv,io,json,tempfile
from pathlib import Path
from collections import defaultdict,Counter
from datetime import datetime

def audit(path):
    raw=Path(path).read_bytes()
    try:text=raw.decode('utf-8-sig');encoding='utf-8-sig'
    except UnicodeDecodeError:text=raw.decode('cp1251');encoding='cp1251'
    try:delimiter=csv.Sniffer().sniff(text[:8000],delimiters=';,\t').delimiter
    except csv.Error:delimiter=';'
    r=csv.DictReader(io.StringIO(text),delimiter=delimiter)
    if not r.fieldnames:raise ValueError('No header')
    r.fieldnames=[x.strip() for x in r.fieldnames]
    required={'accident_id','dead_count','injured_count'}
    if not required.issubset(r.fieldnames):raise ValueError('Missing columns: '+str(required-set(r.fieldnames)))
    rows=list(r)
    if any(None in row for row in rows):raise ValueError('Extra CSV cells; verify delimiter/quoting')
    events=defaultdict(list);missing_id=0
    for row in rows:
        event_id=(row.get('accident_id') or '').strip()
        if not event_id:missing_id+=1;continue
        events[event_id].append(row)
    event_fields=[f for f in ['region','datetime','category','accident_category','road_conditions','road_condition','light','latitude','longitude','dead_count','injured_count'] if f in r.fieldnames]
    conflicts=[];prepared=[];invalid_counts=[]
    for event_id,group in events.items():
        conflict={f:sorted({(row.get(f) or '').strip() for row in group}) for f in event_fields if len({(row.get(f) or '').strip() for row in group})>1}
        if conflict:conflicts.append({'accident_id':event_id,'fields':conflict});continue
        record={f:(group[0].get(f) or '').strip() for f in event_fields};record['accident_id']=event_id
        valid=True
        for f in ['dead_count','injured_count']:
            value=record[f]
            if not value.isdigit():invalid_counts.append({'accident_id':event_id,'field':f,'value':value});valid=False
            else:record[f]=int(value)
        if valid:prepared.append(record)
    complete=not conflicts and not invalid_counts and not missing_id
    result={'source_file':Path(path).name,'encoding':encoding,'delimiter':delimiter,'rows':len(rows),
      'unique_accident_ids':len(events),'missing_id_rows':missing_id,'repeated_event_ids':sum(len(v)>1 for v in events.values()),
      'event_conflicts':conflicts,'invalid_or_missing_counts':invalid_counts,'fully_validated_event_totals':complete,
      'status':'Computed from supplied CSV; not a DataLens GUI verification'}
    if complete:
        by_region=defaultdict(lambda:{'accidents':0,'dead':0,'injured':0});by_light=Counter();month=Counter();weekday=Counter();hour=Counter();unparsed=0
        for rec in prepared:
            reg=rec.get('region') or '(не указан)';by_region[reg]['accidents']+=1;by_region[reg]['dead']+=rec['dead_count'];by_region[reg]['injured']+=rec['injured_count']
            by_light[rec.get('light') or '(не указано)']+=1
            if rec.get('datetime'):
                try:dt=datetime.fromisoformat(rec['datetime'].replace('Z','+00:00'));month[dt.month]+=1;weekday[dt.isoweekday()]+=1;hour[dt.hour]+=1
                except ValueError:unparsed+=1
        result.update({'dead_total':sum(x['dead_count'] for x in prepared),'injured_total':sum(x['injured_count'] for x in prepared),
          'by_region':dict(by_region),'by_light':dict(by_light),'by_month':dict(sorted(month.items())),
          'by_weekday_iso':dict(sorted(weekday.items())),'by_hour':dict(sorted(hour.items())),
          'unparsed_timestamps':unparsed,'time_note':'Hours retained in source datetime representation; confirm its timezone before interpretation'})
    else:result['totals_note']='Person totals withheld: resolve conflicting/missing event fields before aggregation.'
    return result

def selftest():
    with tempfile.TemporaryDirectory() as td:
        p=Path(td)/'test.csv';header='accident_id;region;dead_count;injured_count;participant_gender\n'
        p.write_text(header+'A;Район 1;1;2;М\nA;Район 1;1;2;Ж\nB;Район 2;0;1;М\n',encoding='utf-8')
        r=audit(p);assert r['rows']==3 and r['unique_accident_ids']==2 and r['repeated_event_ids']==1
        assert r['dead_total']==1 and r['injured_total']==3
        p.write_text(header+'A;Район 1;1;2;М\nA;Район 1;1;5;Ж\n',encoding='utf-8')
        r=audit(p);assert not r['fully_validated_event_totals'] and 'injured_total' not in r
    print('PASS: deduplication by accident_id, participant repeats, conflict detection; synthetic self-test only')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('csv',nargs='?');p.add_argument('--out',default='dtp_audit.json');p.add_argument('--self-test',action='store_true');a=p.parse_args()
    if a.self_test:selftest();return
    if not a.csv:p.error('Provide your actual source CSV')
    result=audit(a.csv);Path(a.out).write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');print('Saved audit:',a.out,'; actual source rows:',result['rows'])
if __name__=='__main__':main()
