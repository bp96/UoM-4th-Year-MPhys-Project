# Code to input the predictions Numpy .npy array, allow thresholding of the 
# elements and produce a new binary array depending on the threshold.
# It will then compare this with the original (clinician-drawn) masks array 
# and generate a ROC curve including its AUC.

#   Import modules   #

import numpy as np
import matplotlib.pyplot as plt
import copy as cp
from sklearn import metrics
#import nibabel as nib
#import matplotlib.animation as animation

#   Define functions   #

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
    
#    intersection = K.sum(K.abs(y_true * y_pred), axis=-1)
#    return (2. * intersection + smooth) / (K.sum(K.square(y_true),-1) + K.sum(K.square(y_pred),-1) + smooth)

# Input prediction data and return binary array based on threshold cutoff
def threshold(prediction, threshold):
    
    predictMask = cp.deepcopy(prediction)
    
    for i in range(0, predictMask.shape[0]):
        for j in range(0, predictMask.shape[1]):
            for k in range(0, predictMask.shape[2]):
                    if (predictMask[i,j,k,1] > threshold):
                        predictMask[i,j,k,1] = 1
                    else:
                        predictMask[i,j,k,1] = 0

    return predictMask

def plot_roc_curve(fpr, tpr, slice, auc):  
    plt.plot(fpr, tpr, label='ROC')
    plt.plot([0, 1], [0, 1], color='darkblue', linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.1])
    plt.xlabel('False Positive Rate (1 - Specificity)', fontsize=12)
    plt.ylabel('True Positive Rate (Sensitivity)', fontsize=12)
    plt.title('Receiver Operating Characteristic (ROC) Curve for slice: ' + str(slice), y = 1.03)
    plt.grid(True)
    plt.legend(loc='upper left')
    plt.text(0.9,0.1,('AUC='+str(round(auc, 4))),fontsize=12,
    horizontalalignment='center',
    verticalalignment='center')
    
def evaluate_threshold(threshold):
    print('Sensitivity:', tpr[thresholds>threshold][-1])
    print('Specificity:', fpr[thresholds > threshold][-1])

# Input array directories

predictPathTest = r"C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Adam_tanh\CTV_cCTV\training_true_0.001_0.0001_0.00001_stps52_valstps_30_epochs_10_20_50_CTV\predictions_test.npy"
predictPathVal = r"C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Adam_tanh\CTV_cCTV\training_true_0.001_0.0001_stps52_valstps_30_epochs_10_20_(2)_CTV\predictions_val.npy"
originalPathTest = r"C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\CTV\testMasks_T2Only.npz"
originalPathVal = r"C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\CTV\valMasks_T2Only.npz"
originalimagePathTest = r"C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\CTV\testSlices_T2Only.npz"

# Read in both predictions and original array

predictMaskTest = np.load(predictPathTest)
predictMaskVal = np.load(predictPathVal)
originalMaskTest = np.load(originalPathTest)['arr_0']
originalMaskVal = np.load(originalPathVal)['arr_0']
originalImageTest = np.load(originalimagePathTest)['arr_0']

# Enable ROC printing for Test, Val or both

ROC_Test = True
ROC_Val = False

slice = 20

# Plot ROC for Test masks
if ROC_Test:
    
    fig = plt.figure(figsize=(10, 7), dpi=300)
    # Vectorize Test mask Prediction and original
    predictTestVec = predictMaskTest[slice-1, :, :, 1].ravel()
    originalTestVec = originalMaskTest[slice-1, :, :, 1].ravel()
    
    # Get parameters for ROC curve - first arg true values, second predicted probabilities
    fpr, tpr, thresholds = metrics.roc_curve(originalTestVec, predictTestVec)
    auc = metrics.roc_auc_score(originalTestVec, predictTestVec)
    #evaluate_threshold(0.1)
    
    # Display ROC curve
    plot_roc_curve(fpr, tpr, slice, auc)
    
    # Plot True mask and then Prediction
#        fig2 = plt.figure(figsize=(7, 7), dpi=300)
#        plt.imshow(originalMaskTest[sliceList[i]-1,:,:,1], cmap='gray')
#        plt.show()
#        
#        #predictMaskTest = threshold(predictMaskTest,0.5) # Uncomment to print threshold
#        fig3 = plt.figure(figsize=(7, 7), dpi=300)
#        plt.imshow(predictMaskTest[sliceList[i]-1,:,:,1], cmap='gray')
#        plt.show()
        
    # Save figures?
    saveFigs = True
        
    if saveFigs:
        fig.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Test_ROC_'+str(slice)+'.png')
        #fig2.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Original_Mask_Test_'+str(slice)+'.png', bbox_inches='tight')
        #fig3.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Test_'+str(slice)+'.png', bbox_inches='tight')
        #predictMaskTest = threshold(predictMaskTest,0.3)
        #new_image = nib.Nifti1Image(predictMaskTest[:,:,:,1], affine=np.eye(4))
        #nib.save(new_image, r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Test_'+str(slice)+'.nii')
        
        # Produce overlayed images
    #    fig4 = plt.figure(figsize=(7, 7), dpi=300)
    #    plt.imshow(originalImageTest[slice-1,:,:,1], cmap='gray')
    #    plt.imshow(originalMaskTest[slice-1,:,:,1], cmap='Reds', alpha=0.3)
    #    predictMaskTest = threshold(predictMaskTest,0.00001)
    #    plt.imshow(predictMaskTest[slice-1,:,:,1], cmap='Greens', alpha=0.3)
    #    plt.show()
    
        
# Plot ROC for Val masks
if ROC_Val:
    
    # Vectorize Test mask Prediction and original
    predictValVec = predictMaskVal[slice-1, :, :, 1].ravel()
    originalValVec = originalMaskVal[slice-1, :, :, 1].ravel()
    
    # Get parameters for ROC curve - first arg true values, second predicted probabilities
    fpr, tpr, thresholds = metrics.roc_curve(originalValVec, predictValVec)
    auc = metrics.roc_auc_score(originalValVec, predictValVec)
    
    # Display ROC curve
    fig = plt.figure(figsize=(10, 7), dpi=300)
    plot_roc_curve(fpr, tpr, slice, auc)
    
    # Plot True mask and then Prediction
    fig2 = plt.figure(figsize=(7, 7), dpi=300)
    plt.imshow(originalMaskVal[slice-1,:,:,1], cmap='gray')
    plt.show()
    
    #predictMaskTest = threshold(predictMaskTest,0.5) # Uncomment to print threshold
    fig3 = plt.figure(figsize=(7, 7), dpi=300)
    plt.imshow(predictMaskVal[slice-1,:,:,1], cmap='gray')
    plt.show()
    
    # Save figures?
    saveFigs = True
    
    if saveFigs:
        fig.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Val_ROC_'+str(slice)+'.png')
        #fig2.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Original_Mask_Val_'+str(slice)+'.png', bbox_inches='tight', transparent=True)
        #fig3.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Val_'+str(slice)+'.png', bbox_inches='tight')


# Print all true and predictions

print_all_val = False
print_all_test = False

if print_all_val:
    # Test
    for i in range(0,originalMaskVal.shape[0]):
        print(i)
        plt.imshow(originalMaskVal[i,:,:,1], cmap='gray')
        plt.show()
        plt.imshow(predictMaskVal[i,:,:,1], cmap='gray')
        plt.show()
        print(dice_coef(originalMaskVal[i,:,:,1], predictMaskVal[i,:,:,1]))
        

if print_all_test:
    #https://stackoverflow.com/questions/37419661/python-anim-save-mencoder-download-install
    #fig = plt.figure()
    #imsTest = []
    nSlice = originalMaskTest.shape[0]
    arrDice = np.array([[],[]])
    # Test
    for i in range(0,originalMaskTest.shape[0]):
#        print(i)
#        plt.imshow(originalMaskTest[i,:,:,1], cmap='gray')
#        plt.show()
#        predictMaskTest = threshold(predictMaskTest,0.1)
#        plt.imshow(predictMaskTest[i,:,:,1], cmap='gray')
#        plt.show()
        x = dice_coef(originalMaskTest[i,:,:,1], predictMaskTest[i,:,:,1])
#        print(x)
        tempArray = np.array([[i],[x]])
        arrDice = np.append(arrDice, tempArray, axis=1)
    
    # Sort arrDice
    arrDice = arrDice[:, np.argsort( arrDice[1] ) ]
                      
    # Print and save Top + Bottom three
    for index_1 in range(0,3):
        fig1 = plt.figure(figsize=(7, 7), dpi=300)
        plt.imshow(originalMaskTest[int(arrDice[0][index_1]),:,:,1], cmap='gray')
        plt.show()
      #      predictMaskTest = threshold(predictMaskTest,0.1)
        fig2 = plt.figure(figsize=(7, 7), dpi=300)
        plt.imshow(predictMaskTest[int(arrDice[0][index_1]),:,:,1], cmap='gray')
        plt.text(140,10,('Dice: '+str(round(arrDice[1][index_1],4))),fontsize=12,
    horizontalalignment='center', verticalalignment='center',bbox=dict(facecolor='white', alpha=0.9))
        plt.text(150,150,(str(nSlice-index_1)),fontsize=12,
    horizontalalignment='center', verticalalignment='center',bbox=dict(facecolor='white', alpha=0.9))
        plt.show()
        print(arrDice[0][index_1])
        print(arrDice[1][index_1])
        print('################################################')
        fig1.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Original_Mask_Test_'+str(index_1)+'.png', bbox_inches='tight')
        fig2.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Test_'+str(index_1)+'.png', bbox_inches='tight')
    
    for index_2 in range(nSlice-3,nSlice):
        fig1 = plt.figure(figsize=(7, 7), dpi=300)
        plt.imshow(originalMaskTest[int(arrDice[0][index_2]),:,:,1], cmap='gray')
        plt.show()
      #      predictMaskTest = threshold(predictMaskTest,0.1)
        fig2 = plt.figure(figsize=(7, 7), dpi=300)
        plt.imshow(predictMaskTest[int(arrDice[0][index_2]),:,:,1], cmap='gray')
        plt.text(140,10,('Dice: '+str(round(arrDice[1][index_2],4))),fontsize=12,
    horizontalalignment='center', verticalalignment='center',bbox=dict(facecolor='white', alpha=0.9))
        plt.text(150,150,(str(nSlice-index_2)),fontsize=12,
    horizontalalignment='center', verticalalignment='center',bbox=dict(facecolor='white', alpha=0.9))
        plt.show()
        print(arrDice[0][index_2])
        print(arrDice[1][index_2])
        print('################################################')
        fig1.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Original_Mask_Test_'+str(index_2)+'.png', bbox_inches='tight')
        fig2.savefig(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\Python_Scripts\2DSegmentationUVGG-master\Models_and_predictions\Predicted_Mask_Test_'+str(index_2)+'.png', bbox_inches='tight')
    
        
        #im = plt.imshow(originalMaskTest[i,:,:,1], cmap='gray', animated='True')
        #imsTest.append([im])
        
    #ani = animation.ArtistAnimation(fig, imsTest, interval=50, blit=True, repeat_delay=1000)
    #ani.save('dynamic_images.mp4')
        
        
        
        
        
        
        
        
        
        
        
        