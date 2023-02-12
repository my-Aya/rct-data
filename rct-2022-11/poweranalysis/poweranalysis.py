from IPython.display import Markdown
import pandas as pd
import matplotlib
import json 
import matplotlib.pyplot as plt
import numpy as np
import scipy 
import warnings
import math  
import sklearn.metrics 
import os
import statsmodels.api as sm

data = pd.read_csv('../merged.csv')
weeks = ['spintot_0','spintot_w1','spintot_w2','spintot_w3','spintot_w4','spintot_w6']

nsample=1000
sizerange = range(20,401,30)

plt.figure(1)
plt.show()
plt.ion()
plt.clf()
plt.subplot(231)
plt.show()
m = data[["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group"]].groupby("group").mean().T
s = data[["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group"]].groupby("group").sem().T
m= np.array(m)
s= np.array(s)

ptt= []
preg = []
cohd = []
pregst = []
for i in range(6): 
    j = ~data[weeks[i]].isna()
    gw = data[weeks[i]][(data.group=='Waitlist') & j]
    ga = data[weeks[i]][(data.group=='Intervention') & j]
    print('Week %i'%i)
    ptt.append(scipy.stats.ttest_ind(gw,ga))
    cohd.append((gw.mean()-ga.mean())/np.sqrt( ((len(gw)-1)*gw.var() + (len(ga)-1)*ga.var())/(len(ga)+len(gw)-2)))

    y = data[weeks[i]]
    j = ~y.isna()
    y = y[j]
    X = data[j][['group','spintot_0','age']]
    X['group'] = X['group'].apply(lambda x: .5 if x=='Intervention' else -.5)
    reg = sm.OLS(y,X).fit()
    preg.append(reg.pvalues['group'])


    y = data[weeks[i]]
    j = ~y.isna()
    y = y[j]
    X = data[j][['group','spintot_0','age']]
    X['group'] = X['group'].apply(lambda x: .5 if x=='Intervention' else -.5)
    y = (y-y.mean())/y.std()
    X = X.add(-X.mean())
    X = X.div(X.std())
    reg = sm.OLS(y,X).fit()
    pregst.append(reg.params['group'])
    # extract beta parameters for power calculations from effect for week 4: 
    if i==4: beta = reg.params


print(ptt)

x = np.array([0,1,2,3,4,6])
for i in range(2):
    plt.errorbar(x,m[:,i],yerr=s[:,i])
for i in range(6):
    plt.annotate(f'p={ptt[i].pvalue:.3f}\nd={cohd[i]:.3f}',(x[i],52),ha='center',fontsize='x-small')
    plt.annotate(f'p={preg[i]:.3f}\nb={pregst[i]:.3f}',(x[i],49),ha='center',fontsize='x-small')
yl=plt.ylim()
plt.ylim((yl[0],55))
plt.title('ITT analysis - allcomers')

# simulate to examine power 
# extracted normalized beta values from one of the analyses above as 'beta'
# vector, and use these beta values to simulate outcomes and examine the power 

plt.subplot(234)

j=0
frac=[]
for ss in sizerange:
    n = [0,0]
    j = j+1
    Xg = np.r_[-.5*np.ones((int(ss/2),1)),.5*np.ones((int(ss/2),1))]
    for i in range(nsample):
        X = np.c_[Xg,np.random.randn(ss,1),np.random.randn(ss,1)]
        X = (X-np.mean(X,axis=0))/np.std(X,axis=0)
        y = (X@beta.T + np.random.randn(1,ss)).T
        reg = sm.OLS(y,X).fit()
        if reg.pvalues[0]<.05: 
            n[0]=n[0]+1
        else: 
            n[1]=n[1]+1
        print('ss=%i, it=%i'%(ss,i),end='\r')
    frac.append(n[0]/nsample)

plt.cla()
plt.plot(sizerange,np.array(frac)*100,'.-')
plt.plot([np.min(sizerange),np.max(sizerange)],[90,90],'r--')
plt.xlabel('Sample size')
plt.ylabel('Power')
plt.title(f'b(group)={beta["group"]:.3f}')#,(sizerange[1],95),ha='left')

# y = data['spintot_w4']
# nsj = len(y)
# X = np.ones((nsj,1))
# X = np.c_[X,data['group']=='Intervention',data['spintot_0'],data['age']]
# i = ~np.any(np.isnan(np.c_[y,X]),axis=1)
# reg = LinearRegression().fit(X[i,:], y[i])


plt.subplot(232)

compl = (data.completed==1) | (data.group=='Waitlist')
m = data[compl][["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group"]].groupby("group").mean().T
s = data[compl][["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group"]].groupby("group").sem().T
m= np.array(m)
s= np.array(s)

ptt= []
preg = []
pregst = []
cohd = []
for i in range(6): 
    j = ~data[weeks[i]].isna()
    gw = data[weeks[i]][(data.group=='Waitlist') & j]
    ga = data[weeks[i]][(data.group=='Intervention') & (data.completed==1)& j]
    print('Week %s'%(weeks[i]))
    ptt.append(scipy.stats.ttest_ind(gw,ga))
    cohd.append((gw.mean()-ga.mean())/np.sqrt( ((len(gw)-1)*gw.var() + (len(ga)-1)*ga.var())/(len(ga)+len(gw)-2)))

    y = data[compl][weeks[i]]
    j = ~y.isna()
    y = y[j]
    X = data[compl][j][['group','spintot_0','age']]
    X['group'] = X['group'].apply(lambda x: .5 if x=='Intervention' else -.5)
    reg = sm.OLS(y,X).fit()
    preg.append(reg.pvalues['group'])

    y = data[compl][weeks[i]]
    j = ~y.isna()
    y = y[j]
    X = data[compl][j][['group','spintot_0','age']]
    X['group'] = X['group'].apply(lambda x: .5 if x=='Intervention' else -.5)
    y = (y-y.mean())/y.std()
    X = X.add(-X.mean())
    X = X.div(X.std())
    reg = sm.OLS(y,X).fit()
    pregst.append(reg.params['group'])
    # extract beta parameters for power calculations from effect for week 4: 
    if i==4: beta = reg.params

print(ptt)

x = np.array([0,1,2,3,4,6])
for i in range(2):
    plt.errorbar(x,m[:,i],yerr=s[:,i])
for i in range(6):
    plt.annotate(f'p={ptt[i].pvalue:.3f}\nd={cohd[i]:.3f}',(x[i],52),ha='center',fontsize='x-small')
    plt.annotate(f'p={preg[i]:.3f}\nb={pregst[i]:.3f}',(x[i],49),ha='center',fontsize='x-small')
yl=plt.ylim()
plt.ylim((yl[0],55))
plt.title('PP analysis - allcomers')

plt.subplot(235)

j=0
frac=[]
for ss in sizerange:
    n = [0,0]
    j = j+1
    Xg = np.r_[-.5*np.ones((int(ss/2),1)),.5*np.ones((int(ss/2),1))]
    for i in range(nsample):
        X = np.c_[Xg,np.random.randn(ss,1),np.random.randn(ss,1)]
        X = (X-np.mean(X,axis=0))/np.std(X,axis=0)
        y = (X@beta.T + np.random.randn(1,ss)).T
        reg = sm.OLS(y,X).fit()
        if reg.pvalues[0]<.05: 
            n[0]=n[0]+1
        else: 
            n[1]=n[1]+1
        print('ss=%i, it=%i'%(ss,i),end='\r')
    frac.append(n[0]/nsample)

plt.cla()
plt.plot(sizerange,np.array(frac)*100,'.-')
plt.plot([np.min(sizerange),np.max(sizerange)],[90,90],'r--')
plt.xlabel('Sample size')
plt.ylabel('Power')
plt.title(f'b(group)={beta["group"]:.3f}')#,(sizerange[1],95),ha='left')

plt.subplot(233)

compl = (data.completed==1) | (data.group=='Waitlist')
tmp = data[compl][["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group",'age']]
for k in weeks[::-1]: 
    tmp[k] = (tmp[k] - tmp[weeks[0]])
m = tmp[compl][["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group"]].groupby("group").mean().T
s = tmp[compl][["spintot_0","spintot_w1",'spintot_w2','spintot_w3',"spintot_w4","spintot_w6","group"]].groupby("group").sem().T
m= np.array(m)
s= np.array(s)

p= []
ptt = []
pregst = []
cohd = []
for i in range(6): 
    j = ~tmp[weeks[i]].isna()
    gw = tmp[weeks[i]][(data.group=='Waitlist') & j]
    ga = tmp[weeks[i]][(data.group=='Intervention') & (data.completed==1)& j]
    print('Week %s'%(weeks[i]))
    ptt.append(scipy.stats.ttest_ind(gw,ga))
    cohd.append((gw.mean()-ga.mean())/np.sqrt( ((len(gw)-1)*gw.var() + (len(ga)-1)*ga.var())/(len(ga)+len(gw)-2)))

    y = tmp[weeks[i]]
    j = ~y.isna()
    y = y[j]
    X = tmp[j][['group','spintot_0','age']]
    X['group'] = X['group'].apply(lambda x: .5 if x=='Intervention' else -.5)
    reg = sm.OLS(y,X).fit()
    preg.append(reg.pvalues['group'])

    y = tmp[compl][weeks[i]]
    j = ~y.isna()
    y = y[j]
    X = tmp[compl][j][['group','spintot_0','age']]
    X['group'] = X['group'].apply(lambda x: .5 if x=='Intervention' else -.5)
    y = (y-y.mean())/y.std()
    X = X.add(-X.mean())
    X = X.div(X.std())
    y[y.isna()]=0
    X[X.isna()]=0
    reg = sm.OLS(y,X).fit()
    pregst.append(reg.params['group'])
    # extract beta parameters for power calculations from effect for week 4: 
    if i==4: beta = reg.params
print(ptt)

x = np.array([0,1,2,3,4,6])
for i in range(2):
    plt.errorbar(x,m[:,i],yerr=s[:,i])
for i in range(6):
    plt.annotate(f'p={ptt[i].pvalue:.3f}\nd={cohd[i]:.3f}',(x[i],4),ha='center',fontsize='x-small')
    plt.annotate(f'p={preg[i]:.3f}\nb={pregst[i]:.3f}',(x[i],1),ha='center',fontsize='x-small')
yl=plt.ylim()
plt.ylim((yl[0],6))
plt.title('PP analysis - subtract baseline')



plt.subplot(236)

j=0
frac=[]
for ss in sizerange:
    n = [0,0]
    j = j+1
    Xg = np.r_[-.5*np.ones((int(ss/2),1)),.5*np.ones((int(ss/2),1))]
    for i in range(nsample):
        X = np.c_[Xg,np.random.randn(ss,1),np.random.randn(ss,1)]
        X = (X-np.mean(X,axis=0))/np.std(X,axis=0)
        y = (X@beta.T + np.random.randn(1,ss)).T
        reg = sm.OLS(y,X).fit()
        if reg.pvalues[0]<.05: 
            n[0]=n[0]+1
        else: 
            n[1]=n[1]+1
        print('ss=%i, it=%i'%(ss,i),end='\r')
    frac.append(n[0]/nsample)

plt.cla()
plt.plot(sizerange,np.array(frac)*100,'.-')
plt.plot([np.min(sizerange),np.max(sizerange)],[90,90],'r--')
plt.xlabel('Sample size')
plt.ylabel('Power')
plt.title(f'b(group)={beta["group"]:.3f}')#,(sizerange[1],95),ha='left')


plt.savefig('RCT_poweranalysis.pdf',format='pdf')

#reg = data['age']
#reg = np.c_[reg, data['edu']]

