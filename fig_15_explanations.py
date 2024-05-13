# -*- coding: utf-8 -*-
"""fig_15_explanations.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1QQFqBvSKMo4yMqX-DK5z2fJbN-2NHrFr
"""

import pandas as pd
import matplotlib.pyplot as plt
from pandas.plotting import table

# Load data
# data = pd.read_csv('fig2Interv.csv')
data = pd.read_csv('fig2Aggr.csv')

# Replace 'unknown' with empty strings
data.replace('unknown', '', inplace=True)


# Function to format each row with column names and values
def format_explanation(row, exclude_cols):
    items = []
    for col, value in row.items():
        if col not in exclude_cols and value != '':
            items.append(f"{col}={value}")
    return ', '.join(items)

# Apply the function to create a new 'explanation' column
data['explanation'] = data.apply(lambda row: format_explanation(row, ['interv', 'aggr','podscount','sigmodcount']), axis=1)

# Create the final table with 'explanation' and 'interv' columns
# final_table = data[['explanation', 'interv']]
final_table = data[['explanation', 'aggr']]

# Create a plot figure with appropriate size
fig, ax = plt.subplots(figsize=(8, 4))  # Adjust the size as necessary
ax.axis('tight')
ax.axis('off')

# Create the table
the_table = table(ax, final_table, loc='center', cellLoc='center',colWidths=[0.8, 0.2])

# Optional: Adjust properties and styles
the_table.auto_set_font_size(False)
the_table.set_fontsize(9)
the_table.scale(1.2, 1.2)  # You can adjust the scale for better fitting

# Show the plot
plt.show()