"""
Python code takes ICC values for each patient for each delineation, and then counts them. A .csv file is exported at the end showing the count (where first column is features and the header is the delineation such as CTV-N1, GTV-N etc). Note: the list of features in the .csv file imported for a delineation may be shorter than the total list of features theoretically available of 105 (e.g. due to missing data) but this is accounted for.
"""
###############################################################################
# Import libraries
###############################################################################
import csv
import os
import time

# start the clock
start_time = time.time()
###############################################################################
# Variables
###############################################################################

# Dixon Scan
GTV_N, GTV_N1, GTV_N2, GTV_N3, GTV_N4  = [0]*105, [0]*105, [0]*105, [0]*105, [0]*105 # GTV mask empty lists
CTV_N, CTV_N1, CTV_N2, CTV_N3, CTV_N4, CTV_E,  = [0]*105,[0]*105,[0]*105,[0]*105,[0]*105,[0]*105  # CTV mask empty lists
BLADDER, RECTUM, Rectum_Boundary, SIGMOID, BOWEL = [0]*105,[0]*105,[0]*105,[0]*105,[0]*105  # Other delineation empty lists. Rectum-Boundary is the only one used but the others may be used in the future

# t2 Scan
GTV_T, CTV_HR, CTV_IR, CTV_LR =[0]*105,[0]*105,[0]*105,[0]*105

# create counts for occurances of each delineation
GTV_NC  = 0
CTV_NC, CTV_EC = 0, 0
Rectum_BoundaryC, GTV_TC, CTV_HRC, CTV_IRC, CTV_LRC = 0, 0, 0, 0, 0

# mean limits - may need to be adapted
excellentMeanLimit=0.9
goodMeanLimit=0.8
moderateMeanLimit=0.7
poorMeanLimit=0.5

# standard deviation limits - may need to be adapted
excellentSDLimit=0.2
goodSDLimit=0.4
moderateSDLimit=0.6
poorSDLimit=0.8

# range limits - may need to be adapted
excellentRangesLimit=0.2
goodRangesLimit=0.3
moderateRangesLimit=0.4
poorRangesLimit=0.5

# initialise feature list
features=['original_shape_Elongation','original_shape_Flatness','original_shape_LeastAxis','original_shape_MajorAxis','original_shape_Maximum2DDiameterColumn','original_shape_Maximum2DDiameterRow','original_shape_Maximum2DDiameterSlice','original_shape_Maximum3DDiameter','original_shape_MinorAxis','original_shape_Sphericity','original_shape_SurfaceArea','original_shape_SurfaceVolumeRatio','original_shape_Volume','original_firstorder_10Percentile','original_firstorder_90Percentile','original_firstorder_Energy','original_firstorder_Entropy','original_firstorder_InterquartileRange','original_firstorder_Kurtosis','original_firstorder_Maximum','original_firstorder_MeanAbsoluteDeviation','original_firstorder_Mean','original_firstorder_Median','original_firstorder_Minimum','original_firstorder_Range','original_firstorder_RobustMeanAbsoluteDeviation','original_firstorder_RootMeanSquared','original_firstorder_Skewness','original_firstorder_TotalEnergy','original_firstorder_Uniformity','original_firstorder_Variance','original_glcm_Autocorrelation','original_glcm_ClusterProminence','original_glcm_ClusterShade','original_glcm_ClusterTendency','original_glcm_Contrast','original_glcm_Correlation','original_glcm_DifferenceAverage','original_glcm_DifferenceEntropy','original_glcm_DifferenceVariance','original_glcm_Id','original_glcm_Idm','original_glcm_Idmn','original_glcm_Idn','original_glcm_Imc1','original_glcm_Imc2','original_glcm_InverseVariance','original_glcm_JointAverage','original_glcm_JointEnergy','original_glcm_JointEntropy','original_glcm_MaximumProbability','original_glcm_SumAverage','original_glcm_SumEntropy','original_glcm_SumSquares','original_gldm_DependenceEntropy','original_gldm_DependenceNonUniformity','original_gldm_DependenceNonUniformityNormalized','original_gldm_DependenceVariance','original_gldm_GrayLevelNonUniformity','original_gldm_GrayLevelVariance','original_gldm_HighGrayLevelEmphasis','original_gldm_LargeDependenceEmphasis','original_gldm_LargeDependenceHighGrayLevelEmphasis','original_gldm_LargeDependenceLowGrayLevelEmphasis','original_gldm_LowGrayLevelEmphasis','original_gldm_SmallDependenceEmphasis','original_gldm_SmallDependenceHighGrayLevelEmphasis','original_gldm_SmallDependenceLowGrayLevelEmphasis','original_glrlm_GrayLevelNonUniformity','original_glrlm_GrayLevelNonUniformityNormalized','original_glrlm_GrayLevelVariance','original_glrlm_HighGrayLevelRunEmphasis','original_glrlm_LongRunEmphasis','original_glrlm_LongRunHighGrayLevelEmphasis','original_glrlm_LongRunLowGrayLevelEmphasis','original_glrlm_LowGrayLevelRunEmphasis','original_glrlm_RunEntropy','original_glrlm_RunLengthNonUniformity','original_glrlm_RunLengthNonUniformityNormalized','original_glrlm_RunPercentage','original_glrlm_RunVariance','original_glrlm_ShortRunEmphasis','original_glrlm_ShortRunHighGrayLevelEmphasis','original_glrlm_ShortRunLowGrayLevelEmphasis','original_glszm_GrayLevelNonUniformity','original_glszm_GrayLevelNonUniformityNormalized','original_glszm_GrayLevelVariance','original_glszm_HighGrayLevelZoneEmphasis','original_glszm_LargeAreaEmphasis','original_glszm_LargeAreaHighGrayLevelEmphasis','original_glszm_LargeAreaLowGrayLevelEmphasis','original_glszm_LowGrayLevelZoneEmphasis','original_glszm_SizeZoneNonUniformity','original_glszm_SizeZoneNonUniformityNormalized','original_glszm_SmallAreaEmphasis','original_glszm_SmallAreaHighGrayLevelEmphasis','original_glszm_SmallAreaLowGrayLevelEmphasis','original_glszm_ZoneEntropy','original_glszm_ZonePercentage','original_glszm_ZoneVariance','original_ngtdm_Busyness','original_ngtdm_Coarseness','original_ngtdm_Complexity','original_ngtdm_Contrast','original_ngtdm_Strength']

###############################################################################
# Functions
###############################################################################
# Extracts the directory list into an array
def DirectoryExtract(d):
    return [os.path.join(d, f) for f in os.listdir(d)]

##############################################################################
# Main Code 
##############################################################################

# directory containing patient folders
MasterDirectoryList=DirectoryExtract(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\ICCsForPatients')

# begin loop around all the patient folders
for i in range(0,len(MasterDirectoryList)):
    
    if '.csv' in MasterDirectoryList[i]:
        continue
    elif '.xlsx' in MasterDirectoryList[i]:
        continue
    else:
        # patient selected
        DirectoryList=DirectoryExtract(MasterDirectoryList[i])
        
        # loop in current patient directory, extracting the filenames
        for index in range(0,len(DirectoryList)):
        
            # obtains filepath of file in this patient folder
            fileName=DirectoryList[index]
            
            # add to the appropriate counter
            if 'GTV_N_' in fileName:
                GTV_NC = GTV_NC + 1
            elif 'GTV_N1_' in fileName:
                GTV_NC = GTV_NC + 1
            elif 'GTV_N2_' in fileName:
                GTV_NC = GTV_NC + 1
            elif 'GTV_N3_' in fileName:
                GTV_NC = GTV_NC + 1
            elif 'GTV_N4_' in fileName:
                GTV_NC = GTV_NC + 1
            elif 'CTV_N_' in fileName:
                CTV_NC = CTV_NC + 1
            elif 'CTV_N1_' in fileName:
                CTV_NC = CTV_NC + 1
            elif 'CTV_N2_' in fileName:
                CTV_NC = CTV_NC + 1
            elif 'CTV_N3_' in fileName:
                CTV_NC = CTV_NC + 1
            elif 'CTV_N4_' in fileName:
                CTV_NC = CTV_NC + 1
            elif 'CTV_E_' in fileName:
                CTV_EC = CTV_EC + 1
            elif 'GTV_T_' in fileName:
                GTV_TC = GTV_TC + 1
            elif 'CTV_HR_' in fileName:
                CTV_HRC = CTV_HRC + 1
            elif 'CTV_IR_' in fileName:
                CTV_IRC = CTV_IRC + 1
            elif 'CTV_LR_' in fileName:
                CTV_LRC = CTV_LRC + 1
            elif 'RECTUM_BOUNDARY_' in fileName:
                Rectum_BoundaryC = Rectum_BoundaryC + 1

            
            # open this file
            readFile=open(fileName)
            
            # initialise empty variables to store data
            FeatureNames=[]
            MeanICCs=[]
            SDs=[]
            Ranges=[]
            CIErrors=[]
            
            # load in arrays from csv and store each column into arrays
            for line in readFile:
                if 'Range' in line:
                    continue
                else:
                    splitUp=line.split(',')
                    FeatureNames.append(splitUp[0])
                    MeanICCs.append(float(splitUp[1]))
                    SDs.append(float(splitUp[2]))
                    Ranges.append(float(splitUp[3]))
                    CIErrors.append(float(splitUp[4]))
             
            # look at each value in the extracted list (may be shorter than the features list outside)
            for j in range(0,len(FeatureNames)):   
                
                currentFeatureName=FeatureNames[j] #grab the feature name when conditions satisfied 
                indexOfFeatureOutside= features.index(currentFeatureName) # locate what index this is in the features list outside
#------------------------------------------------------------------------------------------------------------------------------          
                if 'GTV_N_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        GTV_N[indexOfFeatureOutside]=GTV_N[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        GTV_N[indexOfFeatureOutside]=GTV_N[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        GTV_N[indexOfFeatureOutside]=GTV_N[indexOfFeatureOutside]+2
                    else:
                        GTV_N[indexOfFeatureOutside]=GTV_N[indexOfFeatureOutside]+1
                       
                if 'GTV_N1_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        GTV_N1[indexOfFeatureOutside]=GTV_N1[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        GTV_N1[indexOfFeatureOutside]=GTV_N1[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        GTV_N1[indexOfFeatureOutside]=GTV_N1[indexOfFeatureOutside]+2
                    else:
                        GTV_N1[indexOfFeatureOutside]=GTV_N1[indexOfFeatureOutside]+1
                        
                if 'GTV_N2_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        GTV_N2[indexOfFeatureOutside]=GTV_N2[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        GTV_N2[indexOfFeatureOutside]=GTV_N2[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        GTV_N2[indexOfFeatureOutside]=GTV_N2[indexOfFeatureOutside]+2
                    else:
                        GTV_N2[indexOfFeatureOutside]=GTV_N2[indexOfFeatureOutside]+1
                        
                if 'GTV_N3_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        GTV_N3[indexOfFeatureOutside]=GTV_N3[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        GTV_N3[indexOfFeatureOutside]=GTV_N3[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        GTV_N3[indexOfFeatureOutside]=GTV_N3[indexOfFeatureOutside]+2
                    else:
                        GTV_N3[indexOfFeatureOutside]=GTV_N3[indexOfFeatureOutside]+1
                        
                if 'GTV_N4_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        GTV_N4[indexOfFeatureOutside]=GTV_N4[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        GTV_N4[indexOfFeatureOutside]=GTV_N4[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        GTV_N4[indexOfFeatureOutside]=GTV_N4[indexOfFeatureOutside]+2
                    else:
                        GTV_N4[indexOfFeatureOutside]=GTV_N4[indexOfFeatureOutside]+1
 #----------------------------------------------------------------------------------------------------------------------------------                   
                if 'CTV_N_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_N[indexOfFeatureOutside]=CTV_N[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_N[indexOfFeatureOutside]=CTV_N[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_N[indexOfFeatureOutside]=CTV_N[indexOfFeatureOutside]+2
                    else:
                        CTV_N[indexOfFeatureOutside]=CTV_N[indexOfFeatureOutside]+1
                        
                if 'CTV_N1_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_N1[indexOfFeatureOutside]=CTV_N1[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_N1[indexOfFeatureOutside]=CTV_N1[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_N1[indexOfFeatureOutside]=CTV_N1[indexOfFeatureOutside]+2
                    else:
                        CTV_N1[indexOfFeatureOutside]=CTV_N1[indexOfFeatureOutside]+1
                    
                if 'CTV_N2_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_N2[indexOfFeatureOutside]=CTV_N2[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_N2[indexOfFeatureOutside]=CTV_N2[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_N2[indexOfFeatureOutside]=CTV_N2[indexOfFeatureOutside]+2
                    else:
                        CTV_N2[indexOfFeatureOutside]=CTV_N2[indexOfFeatureOutside]+1
                        
                if 'CTV_N3_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_N3[indexOfFeatureOutside]=CTV_N3[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_N3[indexOfFeatureOutside]=CTV_N3[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_N3[indexOfFeatureOutside]=CTV_N3[indexOfFeatureOutside]+2
                    else:
                        CTV_N3[indexOfFeatureOutside]=CTV_N3[indexOfFeatureOutside]+1
                        
                if 'CTV_N4_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_N4[indexOfFeatureOutside]=CTV_N4[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_N4[indexOfFeatureOutside]=CTV_N4[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_N4[indexOfFeatureOutside]=CTV_N4[indexOfFeatureOutside]+2
                    else:
                        CTV_N4[indexOfFeatureOutside]=CTV_N4[indexOfFeatureOutside]+1
                    
                if 'CTV_E_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_E[indexOfFeatureOutside]=CTV_E[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_E[indexOfFeatureOutside]=CTV_E[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_E[indexOfFeatureOutside]=CTV_E[indexOfFeatureOutside]+2
                    else:
                        CTV_E[indexOfFeatureOutside]=CTV_E[indexOfFeatureOutside]+1
                       
                    
                if 'RECTUM_BOUNDARY_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        Rectum_Boundary[indexOfFeatureOutside]=Rectum_Boundary[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        Rectum_Boundary[indexOfFeatureOutside]=Rectum_Boundary[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        Rectum_Boundary[indexOfFeatureOutside]=Rectum_Boundary[indexOfFeatureOutside]+2
                    else:
                        Rectum_Boundary[indexOfFeatureOutside]=Rectum_Boundary[indexOfFeatureOutside]+1
                    
                if 'GTV_T_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        GTV_T[indexOfFeatureOutside]=GTV_T[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        GTV_T[indexOfFeatureOutside]=GTV_T[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        GTV_T[indexOfFeatureOutside]=GTV_T[indexOfFeatureOutside]+2
                    else:
                        GTV_T[indexOfFeatureOutside]=GTV_T[indexOfFeatureOutside]+1
                                            
                if 'CTV_HR_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_HR[indexOfFeatureOutside]=CTV_HR[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                        print("Patient Folder: ",i," File number: ",(index+1)," Appended score: 4")
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_HR[indexOfFeatureOutside]=CTV_HR[indexOfFeatureOutside]+3 
                        print("Patient Folder: ",i," File number: ",(index+1)," Appended score: 3")
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_HR[indexOfFeatureOutside]=CTV_HR[indexOfFeatureOutside]+2
                        print("Patient Folder: ",i," File number: ",(index+1)," Appended score: 2")
                    else:
                        CTV_HR[indexOfFeatureOutside]=CTV_HR[indexOfFeatureOutside]+1
                        print("Patient Folder: ",i," File number: ",(index+1)," Appended score: 1")
                    
                if 'CTV_IR_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_IR[indexOfFeatureOutside]=CTV_IR[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_IR[indexOfFeatureOutside]=CTV_IR[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_IR[indexOfFeatureOutside]=CTV_IR[indexOfFeatureOutside]+2
                    else:
                        CTV_IR[indexOfFeatureOutside]=CTV_IR[indexOfFeatureOutside]+1
                    
                if 'CTV_LR_' in fileName:

                    if MeanICCs[j]>=excellentMeanLimit and abs(SDs[j]<=excellentSDLimit) and Ranges[j]<=excellentRangesLimit: 
                        CTV_LR[indexOfFeatureOutside]=CTV_LR[indexOfFeatureOutside]+4 #grab this value in the GTV-N0 list outside etc  
                    elif MeanICCs[j]>=goodMeanLimit and abs(SDs[j]<=goodSDLimit) and Ranges[j]<=goodRangesLimit:
                        CTV_LR[indexOfFeatureOutside]=CTV_LR[indexOfFeatureOutside]+3 
                    elif MeanICCs[j]>=moderateMeanLimit and abs(SDs[j]<=moderateSDLimit) and Ranges[j]<=moderateRangesLimit:
                        CTV_LR[indexOfFeatureOutside]=CTV_LR[indexOfFeatureOutside]+2
                    else:
                        CTV_LR[indexOfFeatureOutside]=CTV_LR[indexOfFeatureOutside]+1
                                
    # print the loop number completed
    print ("\n\nLoop: ", i+1, "of", len(MasterDirectoryList), " Completed (Note: .csv files in MasterDirectory will be skipped)\n\n")         

################################################################################
# End of loop, print results
################################################################################
            
# print the time taken for code to run       
print("Time taken: ", time.time()-start_time, "s\n")

# create headers for the .csv file and zip together all the lists for the delineations 
headers=['Features','GTV_N', 'GTV_N1', 'GTV_N2', 'GTV_N3', 'GTV_N4','CTV_N', 'GTV_T', 'CTV_N1', 'CTV_N2', 'CTV_N3', 'CTV_N4', 'CTV_E', 'CTV_HR', 'CTV_IR', 'CTV_LR', 'Rectum_Boundary']
rows=zip(features, GTV_N, GTV_N1, GTV_N2, GTV_N3, GTV_N4, CTV_N, GTV_T, CTV_N1, CTV_N2, CTV_N3, CTV_N4, CTV_E, CTV_HR, CTV_IR, CTV_LR, Rectum_Boundary)

# create .csv file containing all the delineations and their counts within the specified ranges
with open((r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\ICCsForPatients\ICCValueCounter.csv'), 'w',newline='') as f:
        writer = csv.writer(f, delimiter=',')
        writer.writerow(i for i in headers)
        for row in rows:
            writer.writerow(row) 
#------------------------------------------------------------------------------
            
# create normalised version of above .csv 
            
# normalise lists
GTV_N[:] = [(2*x)/GTV_NC for x in GTV_N]
GTV_N1[:] = [(2*x)/GTV_NC for x in GTV_N1]
GTV_N2[:] = [(2*x)/GTV_NC for x in GTV_N2]
GTV_N3[:] = [(2*x)/GTV_NC for x in GTV_N3]
GTV_N4[:] = [(2*x)/GTV_NC for x in GTV_N4]
GTV_T[:] = [(2*x)/GTV_NC for x in GTV_T]
CTV_N[:] = [(2*x)/CTV_NC for x in CTV_N]
CTV_N1[:] = [(2*x)/CTV_NC for x in CTV_N1]
CTV_N2[:] = [(2*x)/CTV_NC for x in CTV_N2]
CTV_N3[:] = [(2*x)/CTV_NC for x in CTV_N3]
CTV_N4[:] = [(2*x)/CTV_NC for x in CTV_N4]
CTV_E[:] = [(2*x)/CTV_EC for x in CTV_E]
CTV_HR[:] = [(2*x)/CTV_HRC for x in CTV_HR]
CTV_IR[:] = [(2*x)/CTV_IRC for x in CTV_IR]
CTV_LR[:] = [(2*x)/CTV_LRC for x in CTV_LR]
Rectum_Boundary[:] = [(2*x)/Rectum_BoundaryC for x in Rectum_Boundary]

normRows=zip(features, GTV_N, GTV_N1, GTV_N2, GTV_N3, GTV_N4, CTV_N, GTV_T, CTV_N1, CTV_N2, CTV_N3, CTV_N4, CTV_E, CTV_HR, CTV_IR, CTV_LR, Rectum_Boundary)

with open((r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\ICCsForPatients\ICCValueCounterNormalised.csv'), 'w',newline='') as g:
        writer = csv.writer(g, delimiter=',')
        writer.writerow(i for i in headers)
        for normRow in normRows:
            writer.writerow(normRow) 

###############################################################################






