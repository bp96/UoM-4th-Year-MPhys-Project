# Code generates Numpy (.npz) arrays for use with the trainVGGSegModel
# only the file paths for training and validation data sets need to be changed for now
# THINGS TO ADJUST: FILE PATHS, SIZE OF THE NUMPY ARRAYS TO CORRESPOND TO NIFTI WIDTHS, LOOP THROUGH ALL SLICES
###########################################################
# Import libraries
###########################################################

import numpy as np
import matplotlib.pyplot as plt
import os
import SimpleITK as sitk

###########################################################
# Functions
###########################################################

def DirectoryExtract(d):
    return [os.path.join(d, f) for f in os.listdir(d)]

###########################################################
# Define training and validation folder paths - CHANGE THESE
###########################################################
# Define folder paths for training and validation. Set up as follows: Parent folder ---> Training and Validation subfolders ---> each then has a subfolder for .nii images and .nii masks
    
# Training folder paths for directory with .nii image slices and .nii mask files - CHANGE THESE
slicesListPath = r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\Training\NiiImages'
masksListPath = r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\Training\NiiMasks'
ValSlicesListPath = r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\Validation\NiiImages'
ValMasksListPath = r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\Validation\NiiMasks'
testSlicesListPath = r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\Test\NiiImages'
testMasksListPath = r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\Test\NiiMasks'

###########################################################
# Generate .npz files -DOES NOT NEED TO BE CHANGED
###########################################################

SlicesList = DirectoryExtract(slicesListPath)
MasksList = DirectoryExtract(masksListPath)

# Validation folder paths for directory with .nii image slices and .nii mask files - CHANGE THESE
ValSlicesList=DirectoryExtract(ValSlicesListPath)
ValMasksList=DirectoryExtract(ValMasksListPath)

testSlicesList=DirectoryExtract(testSlicesListPath)
testMasksList=DirectoryExtract(testMasksListPath)

# Find length of training and validation data sets 
nTrainLen = len(SlicesList)
nValLen = len(ValSlicesList)
nTestLen=len(testSlicesList)

###########################################################
# Set variables -- CHANGE THESE IF NEEDED!
###########################################################

xDim=160
yDim=160
imgChannels=3
maskChannels=2

###########################################################
# Create arrays
###########################################################

totalTrainingSlices=0
for k in range(0,nTrainLen):
    niiImg = sitk.ReadImage(SlicesList[k])
    niiSlices = sitk.GetArrayFromImage(niiImg)
    totalTrainingSlices=totalTrainingSlices+len(niiSlices)
    
totalValidationSlices=0
for l in range(0,nValLen):
    valNiiImg = sitk.ReadImage(ValSlicesList[l])
    valNiiSlices = sitk.GetArrayFromImage(valNiiImg)
    totalValidationSlices=totalValidationSlices+len(valNiiSlices)

totalTestSlices=0
for m in range(0,nTestLen):
    testNiiImg = sitk.ReadImage(testSlicesList[m])
    testNiiSlices = sitk.GetArrayFromImage(testNiiImg)
    totalTestSlices=totalTestSlices+len(testNiiSlices)
    
#    Create an empty array of the right size
slicesArray = np.zeros((totalTrainingSlices, xDim, yDim, imgChannels), dtype=np.float)
masksArray = np.zeros((totalTrainingSlices, xDim, yDim, maskChannels), dtype=np.int)

valSlicesArray = np.zeros((totalValidationSlices, xDim, yDim, imgChannels), dtype=np.float)
valMasksArray = np.zeros((totalValidationSlices, xDim, yDim, maskChannels), dtype=np.int)

testSlicesArray = np.zeros((totalTestSlices, xDim, yDim, imgChannels), dtype=np.float)
testMasksArray = np.zeros((totalTestSlices, xDim, yDim, maskChannels), dtype=np.int)

trainingOn=False
validationOn=True
testOn=True
###########################################################
# GENERATE TRAINING NUMPY ARRAYS
###########################################################

if trainingOn:
    currentArrayIndex=0
    trainingSkipped=0
    for n in range(0,nTrainLen):
    #    Load the nifty file with SimpleITK
        
        niiImg = sitk.ReadImage(SlicesList[n])
        niiContour = sitk.ReadImage(MasksList[n])
        
    #   Convert the SITK image to a numpy array 
        niiSlices = sitk.GetArrayFromImage(niiImg)
        niiMasks = sitk.GetArrayFromImage(niiContour)
        
    # Normalise the array
        niiSlices = niiSlices/np.max(niiSlices)
        niiMasks = niiMasks/np.max(niiMasks)
  
        for o in range(0,len(niiSlices)):
            selectedNiiSlice = niiSlices[o,:xDim,:yDim]
            selectedNiiMask = niiMasks[o,:xDim,:yDim]
            
        # Copy the image into the slices array
            try:
                slicesArray[currentArrayIndex,:,:,0] = selectedNiiSlice
                slicesArray[currentArrayIndex,:,:,1] = selectedNiiSlice
                slicesArray[currentArrayIndex,:,:,2] = selectedNiiSlice
                
                masksArray[currentArrayIndex,:,:,0] = np.logical_not(selectedNiiMask) 
                masksArray[currentArrayIndex,:,:,1]= selectedNiiMask
                
                currentArrayIndex=currentArrayIndex+1
            except:
                trainingSkipped=trainingSkipped+1
                continue
                
###########################################################
# GENERATE VALIDATION NUMPY ARRAYS
###########################################################

if validationOn:
    currentValArrayIndex=0
    validationSkipped=0
    for p in range(0,nValLen):
        
    #    Load the nifty file with SimpleITK   
        valNiiImg = sitk.ReadImage(ValSlicesList[p])
        valNiiContour = sitk.ReadImage(ValMasksList[p])
        
    #   Convert the SITK image to a numpy array 
        valNiiSlices = sitk.GetArrayFromImage(valNiiImg)
        valNiiMasks = sitk.GetArrayFromImage(valNiiContour)
        
    # Normalise the array
        valNiiSlices = valNiiSlices/np.max(valNiiSlices)
        valNiiMasks = valNiiMasks/np.max(valNiiMasks)
        
        for q in range(0,len(valNiiSlices)):
            selectedValNiiSlice = valNiiSlices[q,:xDim,:yDim]
            selectedlValNiiMask = valNiiMasks[q,:xDim,:yDim]
            try:
        # Copy the image into the slices array 
                valSlicesArray[currentValArrayIndex,:,:,0]= selectedValNiiSlice
                valSlicesArray[currentValArrayIndex,:,:,1] = selectedValNiiSlice
                valSlicesArray[currentValArrayIndex,:,:,2] = selectedValNiiSlice
                
                valMasksArray[currentValArrayIndex,:,:,0] = np.logical_not(selectedlValNiiMask) 
                valMasksArray[currentValArrayIndex,:,:,1] = selectedlValNiiMask
                currentValArrayIndex=currentValArrayIndex+1
            except:
                validationSkipped=validationSkipped+1
                continue
            
###########################################################
# GENERATE TEST NUMPY ARRAYS
###########################################################

if testOn:
    currentTestArrayIndex=0
    testSkipped=0
    for r in range(0,nTestLen):
        
    #    Load the nifty file with SimpleITK   
        testNiiImg = sitk.ReadImage(testSlicesList[r])
        testNiiContour = sitk.ReadImage(testMasksList[r])
        
    #   Convert the SITK image to a numpy array 
        testNiiSlices = sitk.GetArrayFromImage(testNiiImg)
        testNiiMasks = sitk.GetArrayFromImage(testNiiContour)
        
    # Normalise the array
        testNiiSlices = testNiiSlices/np.max(testNiiSlices)
        testNiiMasks = testNiiMasks/np.max(testNiiMasks)
        
        for s in range(0,len(testNiiSlices)):
            selectedTestNiiSlice = testNiiSlices[s,:xDim,:yDim]
            selectedlTestNiiMask = testNiiMasks[s,:xDim,:yDim]
            try:
        # Copy the image into the slices array 
                testSlicesArray[currentTestArrayIndex,:,:,0]= selectedTestNiiSlice
                testSlicesArray[currentTestArrayIndex,:,:,1] = selectedTestNiiSlice
                testSlicesArray[currentTestArrayIndex,:,:,2] = selectedTestNiiSlice
                
                testMasksArray[currentTestArrayIndex,:,:,0] = np.logical_not(selectedlTestNiiMask) 
                testMasksArray[currentTestArrayIndex,:,:,1] = selectedlTestNiiMask
                currentTestArrayIndex=currentTestArrayIndex+1
            except:
                testSkipped=testSkipped+1
                continue

###########################################################
# Export generated .npz arrays - DOES NOT NEED TO BE CHANGED
###########################################################

if trainingOn:
    slicesArray = slicesArray[:(totalTrainingSlices-trainingSkipped),:,:,:]
    masksArray = masksArray[:(totalTrainingSlices-trainingSkipped),:,:,:]
    np.savez(r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\slices_T2Only.npz', slicesArray)
    np.savez(r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\\masks_T2Only.npz', masksArray)
    
if validationOn:
    valSlicesArray = valSlicesArray[:(totalValidationSlices-validationSkipped),:,:,:]
    valMasksArray = valMasksArray[:(totalValidationSlices-validationSkipped),:,:,:]
    np.savez(r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\valSlices_T2Only.npz', valSlicesArray)
    np.savez(r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\valMasks_T2Only.npz', valMasksArray)
                              
if testOn:
    testSlicesArray = testSlicesArray[:(totalTestSlices-testSkipped),:,:,:]
    testMasksArray = testMasksArray[:(totalTestSlices-testSkipped),:,:,:]  
    np.savez(r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\testSlices_T2Only.npz', testSlicesArray)
    np.savez(r'C:\Users\Brijesh Patel\Desktop\MPhys Project\Sensitive\2DSegmentationUVGG-master\NiftiDataSet\testMasks_T2Only.npz', testMasksArray)
    
#   View numpy array slices using matplotlib
viewSlice = True # True False
slice = 24

if viewSlice:
    fig, axes = plt.subplots(1, 2, figsize=(12, 6),
                             subplot_kw={'xticks': np.linspace(0,160,8,endpoint=False), 'yticks': np.linspace(0,160,8,endpoint=False)})
    list = [slicesArray[slice,:,:,:], slicesArray[slice,:,:,:]]
    for ax, img in zip(axes.flat, list):
        ax.imshow(img, cmap='gray', vmin=0, vmax=1)
    img2 = plt.imshow(masksArray[slice,:,:,0], cmap='gray', alpha = 0.4)
    plt.show()

###########################################################
# End of code
###########################################################
