import pandas as pd
import matplotlib.pyplot as plt

# Assume the files are named 'podsCount.csv' and 'sigmodCount.csv'
# and both have columns named 'country' and 'count'
pods_df = pd.read_csv('podsCount.csv')
sigmod_df = pd.read_csv('sigmodCount.csv')

# Merge the DataFrames on the 'country' column
merged_df = pd.merge(pods_df, sigmod_df, on='country', suffixes=('_pods', '_sigmod'))

# Calculate the total and percentages for the stacked bar chart
merged_df['total'] = merged_df['count_pods'] + merged_df['count_sigmod']
merged_df['percentage_pods'] = merged_df['count_pods'] / merged_df['total'] * 100
merged_df['percentage_sigmod'] = merged_df['count_sigmod'] / merged_df['total'] * 100

# Plotting the 100% stacked bar chart
fig, ax = plt.subplots()
merged_df.set_index('country')[['percentage_sigmod', 'percentage_pods']].plot(kind='bar', stacked=True, color=['blue', 'violet'], ax=ax)
ax.set_xlabel('Country')
ax.set_ylabel('Percentage of publications (%)')
ax.set_title('100% Stacked Bar Chart of SIGMOD and PODS Publications by Country')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
