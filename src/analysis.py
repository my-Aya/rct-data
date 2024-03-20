import pandas as pd

# =============================================================================
# FUNCTIONS
# =============================================================================

def get_alcohol(df,showall=False):
    subset = df[[
        'alcohol_frequency',
        'alcohol_amount',
        'alcohol_binge',
        ]].copy()
    subset.iloc[:,0].replace({
            'Never': 0,
            'Monthly or less': 1,
            '2-4 times per month': 2,
            '2-3 times per week': 3,
            '4 or more times a week': 4
            },inplace=True)
    subset.iloc[:,1].replace({
            '0 to 2': 0,
            '3 to 4': 1,
            '5 to 6': 2,
            '7 to 9': 3,
            '10 or more': 4
            },inplace=True)
    subset.iloc[:,2].replace({
            'Never': 0,
            'Less than monthly': 1,
            'Monthly': 2,
            'Weekly': 3,
            'Daily or almost daily': 4
            },inplace=True)
    subset.fillna(0, inplace=True)
    if showall:
        return subset
    else:
        return subset.sum(axis=1)

def get_drugs(df,showall=False):
    subset = df[[
        'drugs_recent',
        'drugs_frequency',
        'drugs_concern'
        ]].copy().replace({'Yes': True, 'No': False})
    if showall:
        return subset
    else:
        return subset.sum(axis=1)
    
def get_alena_usage(df):
    subset = df.copy()[[
        "used_alena",
        "done_fishing_game",
        "done_impostor_game",
        "done_replica_game",
        "done_museum_game"
    ]].copy()
    subset = ~subset.isna()
    return subset.any(axis=1)

# =============================================================================
# MAIN
# =============================================================================

def participant_retention(rct_name,df):
    N = {'screened': len(df.index)}
    N['spin_exclusions'] = (df['spin_screening'] <= 30).sum()
    if rct_name=='rct_2022':
        N['other_exclusions'] = ((df['spin_screening'] > 30) & \
                                    ((df['therapy']=='Yes') | \
                                    (df['os']=='No') | \
                                    (df['changed_medication']=='Yes') |  \
                                    (get_alcohol(df) >= 8) | \
                                    (get_drugs(df) >= 2))
                                ).sum()
    elif rct_name=='rct_2023':
        N['other_exclusions'] = ((df['spin_screening'] > 30) & \
                                    ((df['therapy']!='No') | \
                                    (df['internet']=='No') | \
                                    (df['changed_medication']=='Yes') | \
                                    (get_alena_usage(df)) | \
                                    (get_alcohol(df) >= 8) | \
                                    (get_drugs(df) >= 2))
                                ).sum()
    N['eligible'] = N['screened'] - N['spin_exclusions'] - N['other_exclusions']
    N['invited'] = {}
    for group in ['waitlist','treatment']:
        with open(f'data/{rct_name}/invited_{group}.txt','r') as f:
            N['invited'][group] = len(f.read().split(', '))
    cols = [col for col in df.columns if 'spin_week' in col]
    for col in cols:
        label = col.split('spin_')[1]
        N[label] = {}
        for group in ['waitlist','treatment']:
            N[label][group] = len(df.loc[(df['group']==group) & (df['in_trial']),col].dropna())
    return N

def summarise_demographics(df,demographic,variable_type,grouping):
    if demographic=='alcohol':
        df['alcohol'] = get_alcohol(df)
    elif demographic=='drugs':
        df['drugs'] = get_drugs(df)>0
    elif demographic in ['ever_had_therapy_week0','taking_medication','used_apps_before_week0']:
        df[demographic] = df[demographic]!='No'
    match variable_type:
        case 'continuous':
            summary = df.groupby(grouping).agg({demographic: ['mean','std']}).reset_index()
            summary.columns = grouping + ['mean','std']
        case 'categorical':
            summary = df.groupby(grouping+[demographic]).agg({'pid': 'count'}).reset_index().rename(columns={'pid':'count'})
        case 'binary':
            summary = df.groupby(grouping).agg({demographic: 'sum'}).reset_index()
            summary.columns = grouping + ['count']
        case _:
            raise ValueError(f'Unknown demographic: {demographic}')
    return summary
