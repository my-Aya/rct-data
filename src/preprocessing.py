""" Preprocessing scripts."""
import os
import json
import pandas as pd
import numpy as np
from src.firebase import fetch_app_usage

# =============================================================================
# VARIABLES
# =============================================================================

# Experiment variables
with open('src/config_experiment.json','r') as f:
    config_data = json.load(f)
WEEKS = config_data['WEEKS']
WEEK_STARTS = config_data['WEEK_STARTS']

# Questionnaire variables
with open('src/config_survey.json','r') as f:
    config_data = json.load(f)
SPIN_QUESTIONS = config_data['SPIN_QUESTIONS']
SPIN_MAPPING = config_data['SPIN_MAPPING']
WSAS_QUESTIONS = config_data['WSAS_QUESTIONS']
PHQ9_QUESTIONS = config_data['PHQ9_QUESTIONS']
PHQ9_MAPPING = config_data['PHQ9_MAPPING']
BASELINE_QUESTIONS = config_data['BASELINE_QUESTIONS']
BASELINE_MAPPING = config_data['BASELINE_MAPPING']
SAFETY_QUESTIONS = config_data['SAFETY_QUESTIONS']
SAFETY_MAPPING = config_data['SAFETY_MAPPING']
WEEKLY_QUESTIONS = config_data['WEEKLY_QUESTIONS']
WEEKLY_MAPPING = config_data['WEEKLY_MAPPING']
SCREENING_QUESTIONS = config_data['SCREENING_QUESTIONS']

# Therapy varaibles
with open('src/config_exercises.json','r') as f:
    config_data = json.load(f)
TYPEFORMS = config_data['TYPEFORMS']
GAMES = config_data['GAMES']

# =============================================================================
# FUNCTIONS
# =============================================================================

def check_rct_name(rct_name):
    if rct_name not in ['rct_2022','rct_2023']:
        raise ValueError('Invalid rct_name')

def getSPIN(df):
    subset = df[[y for x in SPIN_QUESTIONS for y in df.columns if x in y]].copy()
    subset.replace(SPIN_MAPPING,inplace=True)
    return subset.sum(axis=1)

def getWSAS(df):
    subset = df[[y for x in WSAS_QUESTIONS for y in df.columns if x in y]].copy()
    return subset.sum(axis=1)

def getPHQ9(df):
    subset = df[[y for x in PHQ9_QUESTIONS for y in df.columns if x in y]].copy()
    subset.replace(PHQ9_MAPPING,inplace=True)
    return subset.sum(axis=1)

def load_screening(rct_name):
    check_rct_name(rct_name)
    # Load CSV
    screening = pd.read_csv(f'data/{rct_name}/questionnaires/screening.csv').sort_values(by='Submit Date (UTC)',ascending=True)
    # Drop duplicates (keep earliest entry)
    idx = screening['pid'].drop_duplicates(keep='first').index
    screening = screening.loc[idx,:].reset_index(drop=True)
    # Drop invalid ids
    idx = ['str' in str(type(x)) for x in screening['pid']]
    screening = screening.loc[idx,:].reset_index(drop=True)
    # Only get prolific ids
    valid_ids = [len(x)==24 for x in screening['pid']]
    screening = screening.loc[valid_ids,:]
    # Return
    return screening

def assign_demographics(rct_name,df):
    check_rct_name(rct_name)
    # Load demographics and match to data frame
    df['age_prolific'] = None
    df['sex'] = None
    files = [x for x in os.listdir(f'data/{rct_name}/demographics') if '.csv' in x]
    for file in files:
        csv = pd.read_csv(f'data/{rct_name}/demographics/' + file)
        for pid in csv['Participant id']:
            idx = df['pid']==pid
            if any(idx):
                df.loc[idx,'age_prolific'] = csv.loc[csv['Participant id']==pid,'Age'].values[0]
                df.loc[idx,'sex'] = csv.loc[csv['Participant id']==pid,'Sex'].values[0]

def get_group_allocation(rct_name,df):
    check_rct_name(rct_name)
    group_allocation = pd.DataFrame({'pid': df['pid'].unique()})
    group_allocation['treatment'] = False
    group_allocation['waitlist'] = False
    for group in ['waitlist','treatment']:
        csv = pd.read_csv(f'data/{rct_name}/questionnaires/week0_' + group + '.csv')
        for pid in csv['pid']:
            idx = group_allocation['pid']==pid
            if any(idx):
                group_allocation.loc[idx,group] = True
    group_allocation['double'] = group_allocation[['treatment','waitlist']].sum(axis=1)>1
    if group_allocation['double'].sum() > 0:
        print('Number of subjects in both groups: ' + str(group_allocation['double'].sum()))
    return group_allocation

def assign_final_trial(rct_name,df):
    df['in_trial'] = False
    for group in ['waitlist','treatment']:
        with open(f'data/{rct_name}/sample_{group}.txt','r') as f:
            invited = f.read().split(', ')
        for pid in invited:
            idx = df['pid']==pid
            if any(idx):
                df.loc[idx,'in_trial'] = True

def get_weekly_data(rct_name,df):
    check_rct_name(rct_name)
    for week in WEEKS[rct_name]:
        for group in ['waitlist','treatment']:
            csv = pd.read_csv(f'data/{rct_name}/questionnaires/week{week}_{group}.csv').sort_values(by=['pid','Submit Date (UTC)'],ascending=True)
            csv['spin'] = getSPIN(csv)
            csv['wsas'] = getWSAS(csv)
            csv['phq9'] = getPHQ9(csv)
            cols = ['spin','wsas','phq9']
            for question_type in ['baseline','safety','weekly']:
                match question_type:
                    case 'baseline':
                        questions = BASELINE_QUESTIONS
                        mapping = BASELINE_MAPPING
                    case 'safety':
                        questions = SAFETY_QUESTIONS[rct_name]
                        mapping = SAFETY_MAPPING
                    case 'weekly':
                        questions = WEEKLY_QUESTIONS[rct_name]
                        mapping = WEEKLY_MAPPING
                for new_col,col in questions.items():
                    if not isinstance(col,str):
                        if new_col=='age':
                            col = questions[new_col][rct_name]
                        else:
                            for c in col:
                                if c in csv.columns:
                                    col = c
                                    break
                            if not isinstance(col,str):
                                col = ''
                    if col in csv.columns:
                        csv = csv.rename(columns={col:new_col})
                        if mapping is not None:
                            if new_col in mapping.keys():
                                csv[new_col].replace(mapping[new_col],inplace=True)
                        cols += [new_col]
            for pid in csv['pid']:
                df_idx = df['pid']==pid
                csv_idx = csv['pid']==pid
                if any(df_idx):
                    for col in cols:
                        df.loc[df_idx,f"{col}_week{week}"] = csv.loc[csv_idx,col].values[0]

def fix_mistakes(df):
    mistakes = {
        "Post-graduate degree or equivalent": "Postgraduate degree or equivalent",
        "No quailfications": "No qualifications"
    }
    for mistake,correction in mistakes.items():
        df = df.replace(mistake,correction)

def get_activity_log(rct_name):
    check_rct_name(rct_name)
    typeforms = TYPEFORMS[rct_name]
    activity_log = pd.DataFrame()
    # Get activity log from weekly surveys
    for week in WEEKS[rct_name]:
        for group in ['waitlist','treatment']:
            csv = pd.read_csv(f'data/{rct_name}/questionnaires/week' + str(week) + '_' + group + '.csv')
            for pid in csv['pid'].unique():
                if isinstance(pid,str):
                    activity_log = pd.concat([activity_log,pd.DataFrame({
                        'pid': pid,
                        'week': week,
                        'module': None,
                        'activity': 'weekly_survey',
                        'date': pd.Timestamp(csv.loc[csv['pid']==pid,'Submit Date (UTC)'].values[0])
                    },index=[len(activity_log)])])
    # Get activity log from typeforms
    for form in typeforms.keys():
        csv = pd.read_csv(f'data/{rct_name}/typeforms/'+form+'.csv')
        if 'uid' in csv.columns:
            for pid in csv['uid'].unique():
                if isinstance(pid,str):
                    date = pd.Timestamp(csv.loc[csv['uid']==pid,'Submit Date (UTC)'].values[0])
                    week = [x for x in WEEKS[rct_name] if date>=pd.Timestamp(WEEK_STARTS[rct_name][str(x)])]
                    if len(week)>0:
                        week = week[-1]
                    else:
                        week = 0
                    activity_log = pd.concat([activity_log,pd.DataFrame({
                        'pid': pid,
                        'week': week,
                        'module': typeforms[form]['module'],
                        'activity': form,
                        'date': date
                    },index=[len(activity_log)])])
        else:
            print(f"WARNING: UID was not passed to this typeform: {form}")
    # Return log
    return activity_log

def add_app_usage(df,activity_log):
    # Get app usage data from Firebase
    usage_data, db_info = fetch_app_usage(df.loc[df['in_trial'],'pid'].unique())
    # Note which database each user is on
    df['database'] = None
    for pid in db_info.dropna()['pid'].unique():
        df.loc[df['pid']==pid,'database'] = db_info.loc[db_info['pid']==pid,'database'].values[0]
    summary = df.loc[df['in_trial'],].groupby(['group','database'])['pid'].count().unstack().reset_index().iloc[:,1:]
    print("Number of participants in each group and database")
    print(summary)
    # Add to activity log
    for i in usage_data.index:
        pid = usage_data.loc[i,'id']
        module = usage_data.loc[i,'module']
        exercise = usage_data.loc[i,'exercise']
        idx = (activity_log['pid']==pid) & (activity_log['activity']==exercise)
        if not any(idx):
            for n in range(usage_data.loc[i,'completions']):
                activity_log = pd.concat([activity_log,pd.DataFrame({
                    'pid': pid,
                    'week': None,
                    'module': module,
                    'activity': exercise,
                    'date': None
                },index=[len(activity_log)])])
    return activity_log

def find_age(df):
    df['age'] = None
    for i in df.index:
        prolific_age = str(df.loc[i,'age_prolific'])
        reported_age = str(df.loc[i,'age_week0'])
        if prolific_age=='nan':
            prolific_age = None
        elif len(prolific_age)>3:
            prolific_age = None
        if prolific_age is not None:
            prolific_age = int(float(prolific_age))
        
        if reported_age=='nan':
            reported_age = None
        elif reported_age=='Over 35':
            reported_age = '36'
        if reported_age is not None:
            reported_age = int(float(reported_age))
            
        if (prolific_age is not None):
            df.loc[i,'age'] = prolific_age
        else:
            if reported_age is not None:
                df.loc[i,'age'] = reported_age

# =============================================================================
# MAIN
# =============================================================================

def preprocess_data(rct_name):
    check_rct_name(rct_name)
    # Get data from screening Typeform
    screening = load_screening(rct_name)
    # Create fresh data frame
    df = pd.DataFrame({
        'pid': screening['pid'],
        'spin_screening': getSPIN(screening)
        })
    # Note who was in the final sample (invited each week)
    assign_final_trial(rct_name,df)
    # Add columns from demographics and screening questions
    assign_demographics(rct_name,df)
    # Add in screening questions
    for key,value in SCREENING_QUESTIONS[rct_name].items():
        df[key] = screening[value]
    # Add group allocation
    groups = get_group_allocation(rct_name,df)
    df['group'] = None
    for group in ['waitlist','treatment']:
        pids = groups.loc[groups[group],'pid']
        for pid in pids:
            df.loc[df['pid']==pid,'group'] = group
    # Add data from each week
    get_weekly_data(rct_name,df)
    # Make adjustments
    fix_mistakes(df)
    find_age(df)
    if df['spin_week0'].sum()==0:
        df['spin_week0'] = df['spin_screening']
    # Get exercise engagement
    activity_log = get_activity_log(rct_name)
    if rct_name == 'rct_2023':
        activity_log = add_app_usage(df,activity_log)
    # Return data frame and activity log
    return df, activity_log
