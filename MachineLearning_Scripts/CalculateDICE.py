#######################################################
# Import modules
#######################################################

import keras.backend as K
import numpy as np
import matplotlib.pyplot as plt

#######################################################
# Functions
#######################################################

def dice_coef(y_true, y_pred):
    """
    Dice = (2*|X & Y|)/ (|X|+ |Y|)
         =  2*sum(|A*B|)/(sum(A^2)+sum(B^2))
    ref: https://arxiv.org/pdf/1606.04797v1.pdf
    """
    X=y_true
    Y=y_pred
    
    intersection=np.sum(X*Y)
    modX=np.sum(X*X)
    modY=np.sum(Y*Y)
    
    dice=(2*intersection)/(modX+modY)
    return dice
    
#######################################################
# Set directories
#######################################################

loadTest=True  ######### LOAD TEST FILES
loadVal=False  ########## LOAD VALIDATION FILES ---ONLY SET ONE OF THESE TO TRUE!

if loadTest:
    SlicesPath = r"C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\testSlices_T2Only.npz" # set path for test .npz slices file
    MasksPath = r"C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\testMasks_T2Only.npz" # set path for test .npz masks file
    PredictionsPath=r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\predictions_test.npy' # test path for predictions

if loadVal:
    SlicesPath = r"C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\valSlices_T2Only.npz" # set path for test .npz slices file
    MasksPath = r"C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\valMasks_T2Only.npz" # set path for test .npz masks file
    PredictionsPath=r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\predictions_val.npy' # test path for predictions
    
#######################################################
# Generate arrays
#######################################################

Slices = np.load(SlicesPath)['arr_0']
Masks = np.load(MasksPath)['arr_0']
Predictions = np.load(PredictionsPath)

#######################################################
# Dice calculation
#######################################################

calcDice=True ## this will calculate Dice average
if calcDice:
    allDiceVals=[]
    diceAvg=0
    sizeOfSet=Predictions.shape[0]
    for i in range(0, Predictions.shape[0]):
        actualVal=Masks[i,:,:,1]
        predictVal=Predictions[i,:,:,1]
        diceVal=dice_coef(actualVal, predictVal)
        allDiceVals.append(diceVal)
        diceAvg=diceAvg+diceVal/sizeOfSet
    
    print("Dice avg: ", diceAvg)
    print("Max Dice val: ", max(allDiceVals))
    print("Min Dice val: ", min(allDiceVals))
    
    showSlice=True  ## THIS WILL DISPLAY ONE OF THE SLICES IF TRUE
    if showSlice:
        sliceNumber=np.argmax(allDiceVals) # select slice number
        plt.imshow(Slices[sliceNumber,:,:,1], cmap='gray', alpha=1.0)
        plt.imshow(Masks[sliceNumber,:,:,1], cmap='Greens', alpha=0.9)
        plt.imshow(Predictions[sliceNumber,:,:,1], cmap='jet', alpha=0.8)
        plt.colorbar()
        
#######################################################
# End of code
#######################################################        
