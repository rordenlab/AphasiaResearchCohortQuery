#!/usr/bin/env python3


import numpy as np
import matplotlib.pyplot as plt
import os
import sys

def plot(fnm):
    """line-plot showing how compression level impacts file size and conpression speed
    Parameters
    ----------
    results_file : str
        name of pickle format file to plot  
    """
    
    basenm = os.path.basename(fnm)
    basenm = os.path.splitext(basenm)[0]
    print('Plotting '+basenm)
    s = 0;
    fig, ax = plt.subplots()
    ax.set_title(basenm)
    ax.set_xlabel('Days Since Injury')
    ax.set_ylabel('Age At Injury')
    with open(fnm,'r') as source:
        #next() skips first line (header information)
        next(source)
        for line in source:
            fields = line.split('\t')
            s += 1
            #-2: ignore 1st column (id): M2004 70.2 131 222
            #-2: ignore 2nd column (age): M2004 70.2 131 222
            nvisits = len(fields) - 2
            ageAtInjury = float(fields[1]);
            x, y = np.random.random(size=(2,nvisits))
            for v in range(nvisits):
                days = int(fields[v+2])
                #y[v] = s;
                y[v] = ageAtInjury;
                x[v] = days;
                #print(ageAtInjury, days)
            #ax.plot(x, y, 'r+-')
            if nvisits == 1:
                ax.plot(x, y, 'r+-')
            elif nvisits == 2:
                ax.plot(x, y, 'b+-')
            else:
                ax.plot(x, y, 'g+-')
    #plt.show()
    #plt.savefig(basenm + '.pdf')
    plt.savefig(basenm + '.png')
    
if __name__ == '__main__':
    """Plot multiple sessions for each modality
    Parameters
    ----------
    fnm : str
        (optional) .tab file to view  
    """
    if len(sys.argv) > 1:
        plot(sys.argv[1])
        quit()
    pth = os.getcwd()
    for file in os.listdir(pth):
        if file.startswith('.'):
            continue;
        fnm = os.path.join(pth, file);
        if not os.path.isfile(fnm):
            continue;
        if file.endswith(".tab"):
            plot(fnm)
            
