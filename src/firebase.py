import os
import json
import pandas as pd
import firebase_admin
from firebase_admin import credentials, initialize_app, auth, db

def authorise_firebase(project):
    if not firebase_admin._apps:
        try:
            match project:
                case 'comp-psych-games':
                    cred = credentials.Certificate('src/private/firebase-comp-psych-key.json')
                    initialize_app(cred, {'databaseURL': "https://comp-psych-games-default-rtdb.firebaseio.com"})
                    print('Authorising comp-psych-games')
                case 'alena-prod':
                    cred = credentials.Certificate('src/private/firebase-prod-key.json')
                    initialize_app(cred, {'databaseURL': "https://alena-prod-default-rtdb.europe-west1.firebasedatabase.app"})
                    print('Authorising alena-prod')
                case 'alena-dev':
                    cred = credentials.Certificate('src/private/firebase-dev-key.json')
                    initialize_app(cred, {'databaseURL': "https://alena-dev-default-rtdb.firebaseio.com"})
                    print('Authorising alena-dev')
                case _:
                    raise ValueError('Project "' + project + '" not recognised')
        except:
            raise Exception('Could not initialise Firebase app for project ' + project)
    else:
        for app_name in list(firebase_admin._apps.keys()):
            firebase_admin.delete_app(firebase_admin.get_app(name=app_name))
        authorise_firebase(project)

def fetch_users(dbname,uids=None,emails=None):
    authorise_firebase(dbname)
    users = pd.DataFrame(columns=['db','uid','email'])
    cc = -1
    for user in auth.list_users().iterate_all():
        if (uids is None and emails is None) or (uids is not None and user.uid in uids) or (emails is not None and user.email in emails):
            cc += 1
            users = pd.concat([users, pd.DataFrame({'db':dbname,'uid':user.uid,'email':user.email},index=[cc])])
    return users

def fetch_component_state(dbname,uids):
    if isinstance(uids,str):
        uids = [uids]
    filename = f'data/{dbname}_componentState.json'
    connect_to_firebase = True
    if os.path.isfile(filename):
        connect_to_firebase = False
        with(open(filename,'r')) as f:
            component_state = json.load(f)
    else:
        authorise_firebase(dbname)
        component_state = {}
    states = pd.DataFrame()
    for uid in uids:
        user_states = None
        if connect_to_firebase:
            user_states = db.reference('/componentState/' + uid + '/').get()
        elif uid in component_state.keys():
            user_states = component_state[uid]
        if user_states is not None:
            component_state[uid] = user_states
            modules = user_states.keys()
            for module in modules:
                for exercise in user_states[module].keys():
                    typeform_exercise = exercise
                    if (exercise=='M2E1'):
                        typeform_exercise = 'M1E2'
                    elif (exercise=='M1E2'):
                        typeform_exercise = 'M1E1'
                    elif (exercise=='M1E4'):
                        typeform_exercise = 'M1E3'
                    elif (exercise=='M2E3a'):
                        typeform_exercise = 'M2E3'
                    elif (exercise=='M3C1'):
                        typeform_exercise = 'M4E1'
                    elif (exercise=='M3E1'):
                        typeform_exercise = 'M4E2'
                    elif (exercise=='M3E2'):
                        typeform_exercise = 'M4E3'
                    elif (exercise=='M3E4'):
                        typeform_exercise = 'M4E4'
                    elif (exercise=='M4E1'):
                        typeform_exercise = 'M3E1'
                    elif (exercise=='M4E2'):
                        typeform_exercise = 'M3E2'
                    elif (exercise=='M4E3'):
                        typeform_exercise = 'M3E3'
                    row = pd.DataFrame({'id': uid, 'module': module, 'exercise': typeform_exercise, 'completions': user_states[module][exercise]['numberOfCompletions']},index=[len(states)])
                    states = pd.concat([states, row])
    if connect_to_firebase:
        with(open(f'data/{dbname}_componentState.json','w')) as f:
            json.dump(component_state,f)
    return states

def fetch_app_usage(ids):
    # See which IDs have an account on comp-psych-games
    comp_psych_games = fetch_users('comp-psych-games',ids)
    print(f"{len(comp_psych_games)} users detected on correct comp-psych-games database")
    # See which IDs have an account on alena-prod
    alena_prod = fetch_users('alena-prod',None,[x+"@alena.com" for x in ids])
    print(f"{len(alena_prod)} users detected on incorrect alena-prod database")
    alena_prod['pid'] = [x.split('@')[0] for x in alena_prod['email']]
    # Note which database each ID is on
    info = pd.DataFrame({'pid':ids, 'database': [None]*len(ids)})
    for id in comp_psych_games['uid']:
        info.loc[info['pid']==id,'database'] = 'comp-psych-games'
    for id in alena_prod['pid']:
        info.loc[info['pid']==id,'database'] = 'alena-prod'
    # Fetch app usage data for each ID
    insert1 = fetch_component_state('comp-psych-games',comp_psych_games['uid'].tolist())
    insert2 = fetch_component_state('alena-prod',alena_prod['uid'].tolist())
    for id in insert2['id'].unique():
        insert2.loc[insert2['id']==id,'id'] = alena_prod.loc[alena_prod['uid']==id,'pid'].values[0]
    usage_data = pd.concat([
        insert1,
        insert2,
    ])
    usage_data.reset_index(drop=True,inplace=True)
    # Return data
    return usage_data, info
