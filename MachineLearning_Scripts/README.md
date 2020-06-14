# MPhys_Project_S2_MachineLearning

See below descriptions of each script, numbered in the correct order to be compiled necessary to generate and train a machine learning model (based on a VGG16 based, UNet-like segmentation network model).

1. NiftiToNumpy.py: Script to convert NiFTi files into Numpy files for use in the machine learning code.

2. CalculateDICE.py: Used during the training of the model in 6. to calculate the Dice similarity coefficient for a given slice.

3. extraAugmentations.py: Used in the training of the model in 6. to augment the Numpy files with noise in order to artificially increase the size of the training data set.

4. segmentationLosses.py: Functions to calculate the Dice coefficient, the soft Dice or the logistic loss between prediction and target values.

5. createVGGSegModel.py: Function to build and return a keras model for segmentation. The model is based on parts of a pre-trained VGG16 model returns a VGG16 based, UNet-like segmentation network model which uses the preloaded weights to generate predictions.

6. trainVGGSegModel.py: Uses 5. to train the VGG16 model, generating a file containing weights which can be used to provide predictions. Training, validation and test data sets are required.

7. ROC_analysis.py: Code to input the predictions Numpy array, allow thresholding and compare with the original target array, generating a Receiver Operating Characteristic (ROC) curve as well as calculating the Area Under Curve (AUC) value.
