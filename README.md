<p align="center">
<img width=15% src="https://dai.lids.mit.edu/wp-content/uploads/2018/06/Logo_DAI_highres.png" alt="DAI" />
</p>

<p align="center">
<i>A project from Data to AI Lab at MIT.</i>
</p>

<p align="center">
<i> ------------------------------------</i>
</p>

<p align="center">
<img width=20% src="https://dai.lids.mit.edu/wp-content/uploads/2019/03/GreenGuard.png" alt="GreenGuard" />
</p>

<p align="center">
<i>GreenGuard is a machine learning library built for data generated by wind turbines and solar panel installations.</i>
</p>

[![PyPI Shield](https://img.shields.io/pypi/v/greenguard.svg)](https://pypi.python.org/pypi/greenguard)
[![Travis CI Shield](https://travis-ci.org/D3-AI/GreenGuard.svg?branch=master)](https://travis-ci.org/D3-AI/GreenGuard)

# GreenGuard

- Documentation: https://D3-AI.github.io/GreenGuard
- Homepage: https://github.com/D3-AI/GreenGuard

# Overview

The GreenGuard project is a collection of end-to-end solutions for machine learning problems commonly
found in monitoring wind energy production systems. Most tasks utilize sensor data
emanating from monitoring systems. We utilize the foundational innovations developed for
automation of machine Learning at Data to AI Lab at MIT.

The salient aspects of this customized project are:
* A set of ready to use, well tested pipelines for different machine learning tasks. These are
  vetted through testing across multiple publicly available datasets for the same task.
* An easy interface to specify the task, pipeline, and generate results and summarize them.
* A production ready, deployable pipeline.
* An easy interface to ``tune`` pipelines using Bayesian Tuning and Bandits library.
* A community oriented infrastructure to incorporate new pipelines.
* A robust continuous integration and testing infrastructure.
* A ``learning database`` recording all past outcomes --> tasks, pipelines, outcomes.

# Data Format

**GreenGuard Pipelines** work on time Series formatted as follows:

* A **Turbines** table that contains:
  * `turbine_id`: column with the unique id of each turbine.
  * A number of additional columns with information about each turbine.
* A **Signals** table that contains:
  * `signal_id`: column with the unique id of each signal.
  * A number of additional columns with information about each signal.
* A **Readings** table that contains:
  * `reading_id`: Unique identifier of this reading.
  * `turbine_id`: Unique identifier of the turbine which this reading comes from.
  * `signal_id`: Unique identifier of the signal which this reading comes from.
  * `timestamp`: Time where the reading took place, as an ISO formatted datetime.
  * `value`: Numeric value of this reading.
* A **Targets** table that contains:
  * `target_id`: Unique identifier of the turbine which this label corresponds to.
  * `turbine_id`: Unique identifier of the turbine which this label corresponds to.
  * `timestamp`: Time associated with this target
  * `target`: The value that we want to predict. This can either be a numerical value or a
  categorical label. This column can also be skipped when preparing data that will be used
  only to make predictions and not to fit any pipeline.

## Demo Dataset

For development and demonstration purposes, we include a dataset with data from several telemetry
signals associated with one wind energy production turbine.

This data, which has been already formatted as expected by the GreenGuard Pipelines, can be
browsed and downloaded directly from the
[d3-ai-greenguard AWS S3 Bucket](https://d3-ai-greenguard.s3.amazonaws.com/index.html).

This dataset is adapted from the one used in the project by Cohen, Elliot J.,
"Wind Analysis." Joint Initiative of the ECOWAS Centre for Renewable Energy and Energy Efficiency (ECREEE), The United Nations Industrial Development Organization (UNIDO) and the Sustainable Engineering Lab (SEL). Columbia University, 22 Aug. 2014.
[Available online here](https://github.com/Ecohen4/ECREEE)

The complete list of manipulations performed on the original dataset to convert it into the
demo one that we are using here is exhaustively shown and explained in the
[Green Guard Demo Data notebook](notebooks/Green%20Guard%20Demo%20Data.ipynb).

# Concepts

Before diving into the software usage, we briefly explain some concepts and terminology.

## Primitive

We call the smallest computational blocks used in a Machine Learning process
**primitives**, which:

* Can be either classes or functions.
* Have some initialization arguments, which MLBlocks calls `init_params`.
* Have some tunable hyperparameters, which have types and a list or range of valid values.

## Template

Primitives can be combined to form what we call **Templates**, which:

* Have a list of primitives.
* Have some initialization arguments, which correspond to the initialization arguments
  of their primitives.
* Have some tunable hyperparameters, which correspond to the tunable hyperparameters
  of their primitives.

## Pipeline

Templates can be used to build **Pipelines** by taking and fixing a set of valid
hyperparameters for a Template. Hence, Pipelines:

* Have a list of primitives, which corresponds to the list of primitives of their template.
* Have some initialization arguments, which correspond to the initialization arguments
  of their template.
* Have some hyperparameter values, which fall within the ranges of valid tunable
  hyperparameters of their template.

A pipeline can be fitted and evaluated using the MLPipeline API in MLBlocks.

## Tuning

We call tuning the process of, given a dataset and a template, find the pipeline derived from the
given template that gets the best possible score on the given dataset.

This process usually involves fitting and evaluating multiple pipelines with different hyperparameter
values on the same data while using optimization algorithms to deduce which hyperparameters are more
likely to get the best results in the next iterations.

We call each one of these tries a **tuning iteration**.

# Current tasks and pipelines

In our current phase, we are addressing two tasks - time series classification and time series
regression. To provide solutions for these two tasks we have two components.

## GreenGuardPipeline

This class is the one in charge of learning from the data and making predictions by building
[MLBlocks](https://hdi-project.github.io/MLBlocks) pipelines and later on tuning them using
[BTB](https://hdi-project.github.io/BTB/)

## GreenGuardLoader

A class responsible for loading the time series data from CSV files, and return it in the
format ready to be used by the **GreenGuardPipeline**.

# Install

## Requirements

### Python

**GreenGuard** has been developed and runs on Python 3.5, 3.6 and 3.7.

Also, although it is not strictly required, the usage of a [virtualenv](https://virtualenv.pypa.io/en/latest/)
is highly recommended in order to avoid interfering with other software installed in the system
where you are trying to run **GreenGuard**.

## Installation

The simplest and recommended way to install **GreenGuard** is using pip:

```bash
pip install greenguard
```

For development, you can also clone the repository and install it from sources

```bash
git clone git@github.com:D3-AI/GreenGuard.git
cd GreenGuard
make install-develop
```

# Quickstart

In this example we will load some demo data using the **GreenGuardLoader** and fetch it to the
**GreenGuardPipeline** for it to find the best possible pipeline, fit it using the given data
and then make predictions from it.

## 1. Load and explore the data

The first step is to load the demo data.

For this, we will import and call the `greenguard.loader.load_demo` function without any arguments:

```python
from greenguard.loader import load_demo

X, y, tables = load_demo()
```

The returned objects are:

`X`: A `pandas.DataFrame` with the `targets` table data without the `target` column.

```
   target_id  turbine_id  timestamp
0          1           1 2013-01-01
1          2           1 2013-01-02
2          3           1 2013-01-03
3          4           1 2013-01-04
4          5           1 2013-01-05
```

`y`: A `pandas.Series` with the `target` column from the `targets` table.

```
0    0.0
1    0.0
2    0.0
3    0.0
4    0.0
Name: target, dtype: float64
```

`tables`: A dictionary containing three tables in the format explained above:

the `turbines` table:

```
   turbine_id       name
0           1  Turbine 1
```

the `signals` table:

```
   signal_id                                          name
0          1  WTG01_Grid Production PossiblePower Avg. (1)
1          2  WTG02_Grid Production PossiblePower Avg. (2)
2          3  WTG03_Grid Production PossiblePower Avg. (3)
3          4  WTG04_Grid Production PossiblePower Avg. (4)
4          5  WTG05_Grid Production PossiblePower Avg. (5)
```

and the `readings` table:

```
   reading_id  turbine_id  signal_id  timestamp  value
0           1           1          1 2013-01-01  817.0
1           2           1          2 2013-01-01  805.0
2           3           1          3 2013-01-01  786.0
3           4           1          4 2013-01-01  809.0
4           5           1          5 2013-01-01  755.0
```

## 2. Split the data

If we want to split the data in train and test subsets, we can do so by splitting the
`X` and `y` variables with any suitable tool.

In this case, we will do it using the [train_test_split function from scikit-learn](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html).

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=0)
```

## 3. Finding the best Pipeline

Once we have loaded the data, we create a **GreenGuardPipeline** instance by passing:

* `template (string)`: the name of a template or the path to a template json file.
* `metric (string or function)`: The name of the metric to use or a metric function to use.
* `cost (bool)`: Whether the metric is a cost function to be minimized or a score to be maximized.

Optionally, we can also pass defails about the cross validation configuration:

* `stratify`
* `cv_splits`
* `shuffle`
* `random_state`

In this case, we will be loading the `greenguard_classification` pipeline, using
the `accuracy` metric, and using only 2 cross validation splits:

```python
from greenguard.pipeline import GreenGuardPipeline

pipeline = GreenGuardPipeline(template='greenguard_classification', metric='accuracy', cv_splits=2)
```

Once we have created the pipeline, we can call its `tune` method to find the best possible
hyperparameters for our data, passing the `X`, `y`, and `tables` variables returned by the loader,
as well as an indication of the number of tuning iterations that we want to perform.

```python
pipeline.tune(X_train, y_train, tables, iterations=10)
```

After the tuning process has finished, the hyperparameters have been already set in the classifier.

We can see the found hyperparameters by calling the `get_hyperparameters` method,

```python
pipeline.get_hyperparameters()
```

which will return a dictionary with the best hyperparameters found so far:

```
{
    "pandas.DataFrame.resample#1": {
        "rule": "1D",
        "time_index": "timestamp",
        "groupby": [
            "turbine_id",
            "signal_id"
        ],
        "aggregation": "mean"
    },
    "pandas.DataFrame.unstack#1": {
        "level": "signal_id",
        "reset_index": true
    },
    ...
```

as well as the obtained cross validation score by looking at the `score` attribute of the
`pipeline` object:

```python
pipeline.score  # -> 0.6447509660798626
```

**NOTE**: If the score is not good enough, we can call the `tune` method again as many times
as needed and the pipeline will continue its tuning process every time based on the previous
results!

## 4. Fitting the pipeline

Once we are satisfied with the obtained cross validation score, we can proceed to call
the `fit` method passing again the same data elements.

This will fit the pipeline with all the training data available using the best hyperparameters
found during the tuning process:

```python
pipeline.fit(X_train, y_train, tables)
```

## 5. Use the fitted pipeline

After fitting the pipeline, we are ready to make predictions on new data:

```python
predictions = pipeline.predict(X_test, tables)
```

And evaluate its prediction performance:

```python
from sklearn.metrics import accuracy_score

f1_score(y_test, predictions) # -> 0.6413043478260869
```

## 6. Save and load the pipeline

Since the tuning and fitting process takes time to execute and requires a lot of data, you
will probably want to save a fitted instance and load it later to analyze new signals
instead of fitting pipelines over and over again.

This can be done by using the `save` and `load` methods from the `GreenGuardPipeline`.

In order to save an instance, call its `save` method passing it the path and filename
where the model should be saved.

```python
path = 'my_pipeline.pkl'

pipeline.save(path)
```

Once the pipeline is saved, it can be loaded back as a new `GreenGuardPipeline` by using the
`GreenGuardPipeline.load` method:

```python
new_pipeline = GreenGuardPipeline.load(path)
```

Once loaded, it can be directly used to make predictions on new data.

```python
new_pipeline.predict(X_test, tables)
```


# Use your own Dataset

Once you are familiar with the **GreenGuardPipeline** usage, you will probably want to run it
on your own dataset.

Here are the necessary steps:

## 1. Prepare the data

Firt of all, you will need to prepare your data as 4 CSV files like the ones described in the
[data format](#data-format) section above.

## 2. Create a GreenGuardLoader

Once you have the CSV files ready, you will need to import the `greenguard.loader.GreenGuardLoader`
class and create an instance passing:

* `path - str`: The path to the folder where the 4 CSV files are
* `target - str, gptional`: The name of the target table. Defaults to `targets`.
* `target_column - str, optional`: The name of the target column. Defaults to `target`.
* `readings - str, optional`: The name of the readings table. Defaults to `readings`.
* `turbines - str, optional`: The name of the turbines table. Defaults to `turbines`.
* `signals - str, optional`: The name of the signals table. Defaults to `signals`.
* `readings - str, optional`: The name of the readings table. Defaults to `readings`.
* `gzip - bool, optional`: Set to True if the CSV files are gzipped. Defaults to False.

For example, here we will be loading a custom dataset which has been sorted in gzip format
inside the `my_dataset` folder, and for which the target table has a different name:

```python
from greenguard.loader import GreenGuardLoader

loader = GreenGuardLoader(path='my_dataset', target='labels', gzip=True)
```

## 3. Call the loader.load method.

Once the `loader` instance has been created, we can call its `load` method:

```python
X, y, tables = loader.load()
```

Optionally, if the dataset contains only data to make predictions and the `target` column
does not exist, we can pass it the argument `False` to skip it:

```python
X, tables = loader.load(target=False)
```

# Docker Usage

**GreenGuard** comes configured and ready to be distributed and run as a docker image which starts
a jupyter notebook already configured to use greenguard, with all the required dependencies already
installed.

## Docker Requirements

The only requirement in order to run the GreenGuard Docker image is to have Docker installed and
that the user has enough permissions to run it.

Installation instructions for any possible system compatible can be found [here](https://docs.docker.com/install/)

Additionally, the system that builds the GreenGuard Docker image will also need to have a working
internet connection that allows downloading the base image and the additional python depenedencies.

## Building the GreenGuard Docker Image

After having cloned the **GreenGuard** repository, all you have to do in order to build the GreenGuard Docker
Image is running this command:

```bash
make docker-jupyter-build
```

After a few minutes, the new image, called `greenguard-jupyter`, will have been built into the system
and will be ready to be used or distributed.

## Distributing the GreenGuard Docker Image

Once the `greenguard-jupyter` image is built, it can be distributed in several ways.

### Distributing using a Docker registry

The simplest way to distribute the recently created image is [using a registry](https://docs.docker.com/registry/).

In order to do so, we will need to have write access to a public or private registry (remember to
[login](https://docs.docker.com/engine/reference/commandline/login/)!) and execute these commands:

```bash
docker tag greenguard-jupyter:latest your-registry-name:some-tag
docker push your-registry-name:some-tag
```

Afterwards, in the receiving machine:

```bash
docker pull your-registry-name:some-tag
docker tag your-registry-name:some-tag greenguard-jupyter:latest
```

### Distributing as a file

If the distribution of the image has to be done offline for any reason, it can be achieved
using the following command.

In the system that already has the image:

```bash
docker save --output greenguard-jupyter.tar greenguard-jupyter
```

Then copy over the file `greenguard-jupyter.tar` to the new system and there, run:

```bash
docker load --input greenguard-jupyter.tar
```

After these commands, the `greenguard-jupyter` image should be available and ready to be used in the
new system.


## Running the greenguard-jupyter image

Once the `greenguard-jupyter` image has been built, pulled or loaded, it is ready to be run.

This can be done in two ways:

### Running greenguard-jupyter with the code

If the GreenGuard source code is available in the system, running the image is as simple as running
this command from within the root of the project:

```bash
make docker-jupyter-run
```

This will start a jupyter notebook using the docker image, which you can access by pointing your
browser at http://127.0.0.1:8888

In this case, the local version of the project will also mounted within the Docker container,
which means that any changes that you do in your local code will immediately be available
within your notebooks, and that any notebook that you create within jupyter will also show
up in your `notebooks` folder!

### Running greenguard-jupyter without the greenguard code

If the GreenGuard source code is not available in the system and only the Docker Image is, you can
still run the image by using this command:

```bash
docker run -ti -p8888:8888 greenguard-jupyter
```

In this case, the code changes and the notebooks that you create within jupyter will stay
inside the container and you will only be able to access and download them through the
jupyter interface.
