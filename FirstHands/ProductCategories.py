import os
import pandas as pd

script_dir = os.getcwd()
file = 'flipkart_sample.csv'
cat_data = pd.read_csv(os.path.normcase(os.path.join(script_dir, file)))
cat_data["product_category"] =cat_data["product_category_tree"].str.strip('["').str.strip('"]').str.split('>>').str[0]
print(cat_data[["product_category","product_category_tree"]])
print("=================================================================================")
print("=================================================================================")
print("Unique Product Categories =" + str(sorted(cat_data.product_category.unique())))
print("=================================================================================")
print("=================================================================================")
print("Total no. of Unique Product Categories =" + str(len(cat_data.product_category.unique()))) #266