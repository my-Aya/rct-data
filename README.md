# Alena RCT Analysis

This folder contains analysis code for two RCTs conducted by Alena:

* **RCT #1 (2022)**: A pilot study involving 102 female participants aged between 18 and 35.
* **RCT #2 (2023)**: A more extensive study with 267 participants (64% females, 36% males), aged between 18 and 75.

The entry point for this code is the `main.ipynb` file, which is a Jupyter Notebook containing the analysis code for both RCT #1 and RCT #2. 

This file uses scripts from within the `src` folder, including a `preprocessing.py` Python script with functions for preprocessing the data for each RCT. 

The raw data from Typefrom and from Firebase is saved within the `data` folder and its subfolders.

The `results` folder contains the output of the main Jupyter notebook, including CSV files with aggregated data and a `figures` folder containing figures created for the white paper.

## Instructions

### 1. Source the Virtual Environment

Open a command prompt or terminal and navigate to the top directory (where this README.md file is located). Then, create a new virtual environment by running:

```
source env/bin/activate
```

If you are running this from within Visual Studio Code, then select your Python interpreter as: `env/bin/python3.10`

### 2. Install Dependencies

Install the required dependencies using the requirements.txt file:

```
pip install -r requirements.txt
```

### 3. Run the Jupyter Notebook

If you don't have Jupyter installed, you can install it via pip:

```
pip install notebook
```

You can then either open `main.ipynb` from within Visual Studio Code, or you can launch Jupyter Notebook in your web browser by executing the following command in the terminal:

```
jupyter notebook
```

and then navigate to `main.ipynb` in the Jupyter Notebook interface and open it.

You can then run each part of the analysis by executing cells within the notebook.

## Support

If you run into any trouble, then please contact Jessica McFadyen at jmcfadyen@alena.com or drjessicajean@gmail.com