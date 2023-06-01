import pandas as pd
import os
import numpy as np
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
from sys import platform
from pathlib import Path

dir = '/Users/paul/Documents_local/rct-data/rct-2023-03/'


# Load the data.csv file into a pandas dataframe
i_filter = pd.read_csv(dir + "raw_data/intervention_pids.csv")
w_filter = pd.read_csv(dir + "raw_data/waitlist_pids.csv")
filter = pd.concat([i_filter, w_filter], axis=0)

# Screening data
screen = pd.read_csv(dir + "raw_data/screening.csv")
screen = screen[screen['pid'].isin(filter['pid'])]
columns_to_keep = ['pid', 'Score']
screen = screen[columns_to_keep]
screen.rename(columns={'Score': 'spintot_w0'}, inplace=True)
screen = screen.drop_duplicates(subset='pid', keep='first')

# Load the intervention and waitlist group csv files into pandas dataframes
i_bl = pd.read_csv(dir + "raw_data/intervention_baseline.csv")
w_bl = pd.read_csv(dir + "raw_data/waitlist_baseline.csv")

# Filter the main dataframe to keep only rows where the pid is in the list
w_bl = w_bl[w_bl['pid'].isin(filter['pid'])]
w_bl['group'] = ['Waitlist' for i in range(len(w_bl))]

i_bl = i_bl[i_bl['pid'].isin(filter['pid'])]
i_bl['group'] = ['Intervention' for i in range(len(i_bl))]

i_bl = i_bl.drop_duplicates(subset='pid', keep='first')
bl_temp = pd.concat([i_bl, w_bl], axis=0)

bl = pd.merge(bl_temp, screen, on='pid', how='inner')


# Remove irrelevant columns and rename relevant ones
bl.rename(columns={'What is your ethnic group?': 'eth_original','What is your employment status?': 'employ_original', 
                   'What is the *highest* level of education you have completed?': 'edu_original', 
                   'Have you ever used any mental health apps before?': 'apps_original', 
                   'Have you ever had any therapy for your mental health?': 'thpy_original', 
                   'How successful do you expect the Alena app will be in reducing your social anxiety symptoms?': 'expect_original',
                   'Because of my social anxiety, my *ability to work* is impaired.': 'wsas1_w0',
       'Because of my social anxiety, my *home management* (cleaning, tidying, shopping, cooking, looking after home or children, paying bills) is impaired.': 'wsas2_w0',
       'Because of my social anxiety, my *social leisure activities* (with other people, e.g. parties, bars, clubs, outings, visits, dating, home entertaining) are impaired. ': 'wsas3_w0',
       'Because of my social anxiety, my *private leisure activities* (done alone, such as reading, gardening, collecting, sewing, walking alone) are impaired.': 'wsas4_w0',
       'Because of my social anxiety, my ability to form and maintain *close relationships *with others, including those I live with, is impaired.': 'wsas5_w0',
       'What operating system does your phone use?' : 'operating_sys'}, inplace=True)
bl.drop(['#', 'I confirm that I am over 18 years old',
       'My English language skills are good enough to read, write, and talk about my social anxiety in a way that feels honest and accurate.',
       'I have read the Participant Information Sheet (on the previous screen) and understand what this study involves.',
       'I have been given the opportunity to ask questions by email and I am satisfied with any answers received.',
       'I understand that my anonymised personal data can be shared with others for future research, shared in public databases and in scientific reports. I understand that this does not include any data input into the app as part of the therapy.',
       'I understand that I am free to withdraw from this study at any time without giving a reason, but that if I do so any data I have already provided will be retained and cannot be withdrawn. I understand that my legal rights will not be affected.',
       'I understand that I will receive regular emails with motivational and educational content while I have access to the app as part of the study. I understand that I will need to share my email address to receive these emails.',
       'I give my consent to participate in this study.',
       'In order to receive emails about which exercises to do when, you will need to share your email address. This is a required part of the study.\n\nTo keep your email address anonymous and unlinked from your Prolific ID, *please send an email to **[study@alena.com](mailto:study@alena.com)*. (You can do this by clicking on the email address, or copy-pasting it into your email app)\n\n*Please do this now*, and then come back here and proceed with the survey.',
       'What is your age?', 'randomisation', 'Start Date (UTC)', 'Submit Date (UTC)', 'Network ID', 'Tags','environment',
       'In order to receive emails about which exercises to do when, you will need to share your email address. This is a required part of the study.\n\nTo keep your email address anonymous and unlinked from your Prolific ID, *please send an email to **[study+alena@alena.com](mailto:study+alena@alena.com)*. (You can do this by clicking on the email address, or copy-pasting it into your email app)\n\n*Please do this now*, and then come back here and proceed with the survey.'], axis=1, inplace=True)

# Compute SPIN - Map responses to numerical values

# Filter columns with '_temp' suffix
filtered_cols_wsas = bl.filter(regex='^wsas[1-5]_w0$')

# Sum all values in filtered columns
bl['wsastot_w0'] = filtered_cols_wsas.sum(axis=1)

# Load demographics and filter (Prolific data)
w_demogr = pd.read_csv(dir + "raw_data/waitlist_demographics_baseline.csv")
w_demogr = w_demogr[w_demogr['Participant id'].isin(filter['pid'])]
i_demogr = pd.read_csv(dir + "raw_data/intervention_demographics_baseline.csv")
i_demogr = i_demogr[i_demogr['Participant id'].isin(filter['pid'])]


# Extract age and sex from prolific data
demogr = pd.concat([i_demogr, w_demogr], axis=0)
demogr.rename(columns={'Participant id': 'pid', 'Age': 'age', 'Sex': 'sex'}, inplace=True)
demogr.drop(['Submission id', 'Status','Started at','Completed at','Reviewed at','Archived at','Time taken','Completion code','Total approvals','Country of birth','Country of residence','Nationality','Language','Ethnicity simplified','Student status','Employment status'], axis=1, inplace=True)

# Merge demographic with baseline data. Set how to 'inner' to remove participants who did not complete baseline (timed-out on prolific). Set how to 'outer' to keep all participants.
merged_df = pd.merge(demogr, bl, on='pid', how='outer')

# Loop over weeks and merge
for i in range(1, 11):
    i_filename = 'intervention_week' + str(i) + '.csv'
    w_filename = 'waitlist_week' + str(i) + '.csv'
    
    # Check if data files exist for this particular week
    if os.path.exists(os.path.join(dir, 'raw_data/', i_filename)) and os.path.exists(os.path.join(dir, 'raw_data/', w_filename)):
        print('Week ' + str(i) + '...')
    
        i_week = pd.read_csv(os.path.join(dir, 'raw_data/', i_filename))
        w_week = pd.read_csv(os.path.join(dir, 'raw_data', w_filename))
        
        w_week.rename(columns={
                            'We are sorry to hear this. Please describe the negative effect(s) you have experienced during the past week.': 'We are sorry to hear this. Please describe the negative effect(s) you have experienced during the last week.', 
                            "Do you think any of these negative effect(s) were due to your participation in this study?": "Do you think that any of these negative effect(s) were due to your participation in this study?"}, inplace=True)
        
        # i_week = i_week[i_week['pid'].isin(i_filter['pid'])]
        # w_week = w_week[w_week['pid'].isin(w_filter['pid'])]
        week = pd.concat([i_week, w_week], axis=0)
        
        week.drop(['#', 'Nothing - I completed the exercises',
            'I did not feel like it was helping or would help me',
            'I forgot to use it',
            'I experienced technical difficulties (e.g. the app crashed)',
            'I found it boring',
            'The app was not enjoyable to use (e.g. too repetitive)',
            'I did not have access to a smartphone or the internet',
            'I was too busy or didn’t have time',
            'I did not feel emotionally able to complete it',
            'I found it too hard/challenging to complete',
            'I just didn’t feel like it', 'Other','phq', 'wsas', 'Start Date (UTC)', 'Submit Date (UTC)',"Score",
            'Network ID', 'Tags'], axis=1, inplace=True)

        week.rename(columns={'How satisfied or dissatisfied are you with using the Alena app overall?': 'satis_original_w'+str(i),
                            'How helpful have you found the Alena app?': 'help_original_w'+str(i),
                            'How likely are you to recommend the Alena app to a person who experiences similar problems?' : 'recc_original_w'+str(i),
                            'How easy to use have you found the Alena app?' : 'easy_original_w'+str(i),
                            "Did you get to the end of this week's recommended activities in the app?": 'end_original_w'+str(i),
                            'Have you experienced any new, serious negative health effects in the past week?': 'advhealth_original_w'+str(i),
                            'We are sorry to hear this. Please describe the negative effect(s) you have experienced during the last week.': 'advhealth_qual_w'+str(i),
                            'Please rate the severity of the negative effect(s) you have experienced.': 'advhealth_sev_w'+str(i),
                            'Do you think that any of these negative effect(s) were due to your participation in this study?': 'advhealth_study_w'+str(i),
                            'Have you experienced any negative effects from using the Alena app?': 'advapp_original_w'+str(i),
                            'We are sorry to hear this. Please describe the negative effect(s) you have experienced from using the Alena app.': 'advapp_qual_w'+str(i),
                            'Please rate the severity of the negative effect(s) you have experienced from using the Alena app.': 'advapp_sev_w'+str(i),
                            'Do you have any comments or feedback about the Alena app, in particular anything that could be improved?': 'improve_original_w'+str(i),
                            'I am afraid of people in authority.': 'spin1_original_w'+str(i),
                            ' I am bothered by blushing in front of people.': 'spin2_original_w'+str(i),
                            'Parties and social events scare me.': 'spin3_original_w'+str(i),
                            "I avoid talking to people I don't know.": 'spin4_original_w'+str(i),
                            'Being criticized scares me a lot.': 'spin5_original_w'+str(i),
                            'I avoid doing things or speaking to people for fear of embarrassment.': 'spin6_original_w'+str(i),
                            'Sweating in front of people causes me distress.': 'spin7_original_w'+str(i),
                            'I avoid going to parties.': 'spin8_original_w'+str(i),
                            'I avoid activities in which I am the center of attention.': 'spin9_original_w'+str(i),
                            'Talking to strangers scares me.': 'spin10_original_w'+str(i),
                            'I avoid having to give speeches.': 'spin11_original_w'+str(i),
                            'I would do anything to avoid being criticized.': 'spin12_original_w'+str(i),
                            'Heart palpitations bother me when I am around people.': 'spin13_original_w'+str(i),
                            'I am afraid of doing things when people might be watching.': 'spin14_original_w'+str(i),
                            'Being embarrassed or looking stupid are among my worst fears.': 'spin15_original_w'+str(i),
                            'I avoid speaking to anyone in authority.': 'spin16_original_w'+str(i),
                            'Trembling or shaking in front of others is distressing to me.': 'spin17_original_w'+str(i),
                            'Because of my social anxiety, my *ability to work* is impaired.': 'wsas1_w'+str(i),
                            'Because of my social anxiety, my *home management* (cleaning, tidying, shopping, cooking, looking after home or children, paying bills) is impaired.': 'wsas2_w'+str(i),
                            'Because of my social anxiety, my *social leisure activities* (with other people, e.g. parties, bars, clubs, outings, visits, dating, home entertaining) are impaired.': 'wsas3_w'+str(i),
                            'Because of my social anxiety, my *private leisure activities* (done alone, such as reading, gardening, collecting, sewing, walking alone) are impaired.': 'wsas4_w'+str(i),
                            'Because of my social anxiety, my ability to form and maintain *close relationships *with others, including those I live with, is impaired. ': 'wsas5_w'+str(i),
                            'Have you experienced any negative effects from taking part in this study? ': 'advall_original_w'+str(i),
                            'We are sorry to hear this. Please describe the negative effect(s) you have experienced from taking part in this study.': 'advall_qual_w'+str(i),
                            'Please rate the severity of the negative effect(s) you have experienced from taking part in this study.': 'advall_sev_w'+str(i)
                            }, inplace=True)
        
        
        # Compute SPIN - Map responses to numerical values
        response_mapping = {'Not at all': 0, 'A little bit': 1, 'Somewhat': 2, 'Very much': 3, 'Extremely': 4}
        for c in range(1, 18):
            col_name = 'spin{}_original_w{}'.format(c, i)
            week[col_name+'_temp_spin'] = week[col_name].map(response_mapping)
        
        # Filter columns with '_temp' suffix
        filtered_cols_spin = week.filter(regex='_temp_spin$')
        week.drop(filtered_cols_spin.columns, axis=1, inplace=True)
        week['spintot_w'+str(i)] = filtered_cols_spin.sum(axis=1)


        # Filter columns with '_temp' suffix
        filtered_cols_wsas = week.filter(regex='^wsas[1-5]_w{}$'.format(i))
        week['wsastot_w'+str(i)] = filtered_cols_wsas.sum(axis=1)
        
        merged_df = pd.merge(merged_df, week, on='pid', how='outer')

merged_df = merged_df.drop_duplicates(subset='pid', keep='first')


# Completion data - taken from firebase
## RCT app
cred1 = credentials.Certificate('/Users/paul/games/conditional_beliefs/src/private/firebase-key.json')
app1 = firebase_admin.initialize_app(cred1, {
  'databaseURL': "https://comp-psych-games-default-rtdb.firebaseio.com",
}, name='app1')

path = '/'.join(['componentState'])
print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
ref1 = db.reference(path, app=app1)
d = ref1.get()
ids = d.keys()

## Some users downloaded the main app instead - collect their data from the corresponding database
# load IDs of users who downloaded the main app
main_app_users = pd.read_csv(dir + "raw_data/prolificinprod.csv")

cred2 = credentials.Certificate('/Users/paul/games/conditional_beliefs/src/private/alena-prod-firebase-adminsdk-hjq6d-0a843ddf1d.json')
app2 = firebase_admin.initialize_app(cred2, {
  'databaseURL': "https://alena-prod-default-rtdb.europe-west1.firebasedatabase.app/",
}, name='app2')

path = '/'.join(['componentState'])
print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
ref2 = db.reference(path, app=app2)
d_main = ref2.get()
ids = d_main.keys()

def get_module_completion_counts(pid):

    module_counts = {'AC1P1': 0, 'AC1P2': 0, 'AC1P3': 0, 'M0A1': 0, 'M0E1': 0, 'M0E2': 0, 'M0E3': 0,
                    'AC2P1': 0, 'AC2P2': 0, 'M1A1': 0, 'M1E2': 0, 'M1E4': 0, 
                    'AC3P1a': 0, 'AC3P2': 0, 'M2A1': 0, 'M2E1': 0, 'M2E2a': 0, 'M2E2b': 0, 'M2E3a': 0, 'M2E4': 0, 
                    'AC4P1': 0, 'AC4P2': 0, 'M4A1': 0, 'M4E1': 0, 'M4E2': 0, 'M4E3': 0, 
                    'AC5P1': 0, 'AC5P2': 0, 'M3A1': 0, 'M3C1': 0, 'M3E1': 0, 'M3E2': 0, 'M3E4': 0, 
                    'total_exercises_completed': 0, 'app_version': 'none'    }

    temp = main_app_users[main_app_users['Prolific ID'] == pid]['UID']
    if not temp.empty:
        uid = temp.values[0]
        # run the statement you want to execute if the output is not empty
        # for example:
        print("UID found:", uid)
        if uid in d_main:
            
            total = 0
            for runID, data in d_main[uid].items():
                for module, dt in d_main[uid][runID].items():
                    if 'numberOfCompletions' in dt:
                        module_counts[module] += dt['numberOfCompletions']
                        total += dt['numberOfCompletions']
                    elif 'completed' in dt and dt['completed']:
                        module_counts[module] += 1
                        total += 1
            module_counts['total_exercises_completed'] = total
            module_counts['app_version'] = 'main_app'
            print(total)

    if pid in d:
        total = 0
        for runID, data in d[pid].items():
            for module, dt in d[pid][runID].items():
                if 'numberOfCompletions' in dt:
                    module_counts[module] += dt['numberOfCompletions']
                    total += dt['numberOfCompletions']
                elif 'completed' in dt and dt['completed']:
                    module_counts[module] += 1
                    total += 1
        module_counts['total_exercises_completed'] = total
        module_counts['app_version'] = 'rct_app'
    
    
    
    return pd.Series(module_counts)


new_cols_df = merged_df['pid'].apply(get_module_completion_counts)
merged_df[new_cols_df.columns] = new_cols_df


columns_to_check = ['AC1P1', 'AC1P2', 'AC1P3', 'M0A1', 'M0E1', 'M0E2', 'M0E3']
merged_df['M0_completed'] = merged_df[columns_to_check].gt(0).all(axis=1).astype(int)
merged_df['M0_any'] = merged_df[columns_to_check].gt(0).any(axis=1).astype(int)
merged_df['total_M0'] = merged_df[columns_to_check].sum(axis=1)

columns_to_check = ['AC2P1', 'AC2P2', 'M1A1', 'M1E2', 'M1E4', 'M2E1']
merged_df['M1_completed'] = merged_df[columns_to_check].gt(0).all(axis=1).astype(int)
merged_df['M1_any'] = merged_df[columns_to_check].gt(0).any(axis=1).astype(int)
merged_df['total_M1'] = merged_df[columns_to_check].sum(axis=1)

columns_to_check = ['AC3P1a', 'AC3P2', 'M2A1', 'M2E2a', 'M2E2b', 'M2E3a', 'M2E4']
merged_df['M2_completed'] = merged_df[columns_to_check].gt(0).all(axis=1).astype(int)
merged_df['M2_any'] = merged_df[columns_to_check].gt(0).any(axis=1).astype(int)
merged_df['total_M2'] = merged_df[columns_to_check].sum(axis=1)

columns_to_check = ['AC4P1', 'AC4P2', 'M4A1', 'M4E1', 'M4E2', 'M4E3']
merged_df['M4_completed'] = merged_df[columns_to_check].gt(0).all(axis=1).astype(int)
merged_df['M4_any'] = merged_df[columns_to_check].gt(0).any(axis=1).astype(int)
merged_df['total_M4'] = merged_df[columns_to_check].sum(axis=1)

columns_to_check = ['AC5P1', 'AC5P2', 'M3A1', 'M3C1', 'M3E1', 'M3E2', 'M3E4']
merged_df['M5_completed'] = merged_df[columns_to_check].gt(0).all(axis=1).astype(int)
merged_df['M5_any'] = merged_df[columns_to_check].gt(0).any(axis=1).astype(int)
merged_df['total_M5'] = merged_df[columns_to_check].sum(axis=1)


merged_df['edu_original'] = merged_df['edu_original'].replace('Postgraduate degree or equivalent', 'Post-graduate degree or equivalent')
merged_df.to_csv('../preprocessed_data/merged.csv', index=False)
