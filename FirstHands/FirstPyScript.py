import pandas as pd

print("Hello Data Enthusiasts!!")
# Creating DataFrame from Dictionary
demodictionary = {"cols": [1, 2, 2]}
# from pandas DataFrame
demodataframe = pd.DataFrame(demodictionary)
# Setting the row labels using .index = [list of row labels]
demodataframe.index = ['one', 'two', 'twos']
# Displaying dataframe
print(demodataframe[["cols"]])

#Output
#       cols
# one      1
# two      2
# twos     2