"""
Python code extracts radiomics features of the t2 masks (CTV-IR, CTV-HR, GTV-T) and the Dixon masks (CTV-N1,CTV-N2, CTV-E, GTV-N1, GTV-N2) into corresponding .csv files

"""

###############################################################################
# Import libraries
###############################################################################
import radiomics
import csv
import os
from radiomics import featureextractor
import time

# start the clock
start_time = time.time()

###############################################################################
# Variables
###############################################################################

# Dixon Scan
GTV_N, GTV_N1, GTV_N2, GTV_N3, GTV_N4  = False, False, False, False, False # Select GTV mask
CTV_N, CTV_N1, CTV_N2, CTV_N3, CTV_N4, CTV_E,  = False, False, False, False, False, True # Select CTV mask
BLADDER, RECTUM, Rectum_Boundary, SIGMOID, BOWEL = False, False, False, False, False # Select other delineations
# t2 Scan
GTV_T, CTV_HR, CTV_IR, CTV_LR = False, False, False, False

###############################################################################
# Functions
###############################################################################
# Extracts the directory list into an array
def DirectoryExtract(d):
    return [os.path.join(d, f) for f in os.listdir(d)]

# Performs radiomics calculations which are then written into a csv file
def RadiomicsCalculator(parameterpath,image,mask, filename):
    extractor = featureextractor.RadiomicsFeaturesExtractor(parameterpath)
 #   print("Calculating features")
    featureVector = extractor.execute(image, mask)
    featureNameArray=[]
    featureVectorArray=[]
    
    for featureName in featureVector.keys():
 #     print("Computed %s: %s" % (featureName, featureVector[featureName]))
      featureNameArray.append(featureName)
      featureVectorArray.append(featureVector[featureName])
    
    with open((paramPath+'\\'+filename+'.csv'), 'w',newline='') as f:
        writer = csv.writer(f, delimiter=',')
        writer.writerows(zip(featureNameArray,featureVectorArray))

# Finds a specific mask (value) within a List
def FindMask(List,value):
    for text in List:
        if ((value in text) and (".nii" in text)):
            return text

# Finds either the DIXON image or the t2 image 
def FindImage(List,value):
    for text in List:
        if ((value in text) and ("Mask" not in text) and (".nii" in text)):
            if (("t2" in value) and ("DIXON" in text)): 
                continue                                     # ignore file and perform next loop if you're looking for t2, but DIXON is found instead
            elif (("t2" in value) and ("DIXON" not in text)): 
                return text                                  # returns the t2 file
            elif (("DIXON" in value) and ("DIXON" in text)):
                return text                                   # returns the DIXON file


##############################################################################
# Main Code 
##############################################################################

MasterMasterDirectoryList=DirectoryExtract(r'C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\MPhys Cervix Radiomics')

# loops through all the patient directories
for i in range(7,8): #len(MasterMasterDirectoryList) - replace this with '0', which is first patient, to loop over all patients (Choose 1 for the second patient in the list etc...)
    
    # extracts the patient number
    patientNumber=MasterMasterDirectoryList[i].split('MPhys Cervix Radiomics\\',1)[1]
    
    #Extract all the patient visit directories into a list
    MasterDirectoryList=DirectoryExtract(MasterMasterDirectoryList[i])
    
    # For each visit, extract the CTV_IR, CTV_HR, CTV_N1, CTV_N2, CTVE, GTV_T, GTV_N1 and GTV_N2 radiomics data (using the RadiomicsCalculator)
    for index in range(0,len(MasterDirectoryList)):
        
        #obtain list of all the files for a patient visit
        SubDirectoryList=DirectoryExtract(MasterDirectoryList[index])
        
        # obtains filepath of current patient directory
        paramPath=MasterDirectoryList[index]
        
        # obtains image files for t2 and Dixon
        t2_Image=FindImage(SubDirectoryList,'t2')
        Dixon_Image=FindImage(SubDirectoryList,'DIXON')
            
############ CTV-HR Mask ############################################################################           
        if CTV_HR == True:
            
            CTVHRP0_Mask=FindMask(SubDirectoryList,'CTV_HRP0')
            if CTVHRP0_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVHRP0_Mask,("CTV_HRP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVHRP1_Mask=FindMask(SubDirectoryList,'CTV_HRP1')
            if CTVHRP1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVHRP1_Mask,("CTV_HRP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVHRP2_Mask=FindMask(SubDirectoryList,'CTV_HRP2')
            if CTVHRP2_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVHRP2_Mask,("CTV_HRP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVHRP3_Mask=FindMask(SubDirectoryList,'CTV_HRP3')
            if CTVHRP3_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVHRP3_Mask,("CTV_HRP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVHRM1_Mask=FindMask(SubDirectoryList,'CTV_HRM1')
            if CTVHRM1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVHRM1_Mask,("CTV_HRM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))

############ CTV-IR Mask ############################################################################           
        if CTV_IR == True:
            
            CTVIRP0_Mask=FindMask(SubDirectoryList,'CTV_IRP0')
            if CTVIRP0_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVIRP0_Mask,("CTV_IRP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVIRP1_Mask=FindMask(SubDirectoryList,'CTV_IRP1')
            if CTVIRP1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVIRP1_Mask,("CTV_IRP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVIRP2_Mask=FindMask(SubDirectoryList,'CTV_IRP2')
            if CTVIRP2_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVIRP2_Mask,("CTV_IRP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVIRP3_Mask=FindMask(SubDirectoryList,'CTV_IRP3')
            if CTVIRP3_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVIRP3_Mask,("CTV_IRP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVIRM1_Mask=FindMask(SubDirectoryList,'CTV_IRM1')
            if CTVIRM1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVIRM1_Mask,("CTV_IRM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))

############ GTV-T Mask ##############################################################################       
        if GTV_T == True:
        
            GTVTP0_Mask=FindMask(SubDirectoryList,'GTV_TP0')
            if GTVTP0_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,GTVTP0_Mask,("GTV_TP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVTP1_Mask=FindMask(SubDirectoryList,'GTV_TP1')
            if GTVTP1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,GTVTP0_Mask,("GTV_TP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVTP2_Mask=FindMask(SubDirectoryList,'GTV_TP2')
            if GTVTP2_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,GTVTP2_Mask,("GTV_TP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVTP3_Mask=FindMask(SubDirectoryList,'GTV_TP3')
            if GTVTP3_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,GTVTP3_Mask,("GTV_TP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVTM1_Mask=FindMask(SubDirectoryList,'GTV_TM1')
            if GTVTM1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,GTVTP0_Mask,("GTV_TM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))

############ CTV-LR Mask ############################################################################           
        if CTV_LR == True:
            
            CTVLRP0_Mask=FindMask(SubDirectoryList,'CTV_LRP0')
            if CTVLRP0_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVLRP0_Mask,("CTV_LRP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVLRP1_Mask=FindMask(SubDirectoryList,'CTV_LRP1')
            if CTVLRP1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVLRP1_Mask,("CTV_LRP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVLRP2_Mask=FindMask(SubDirectoryList,'CTV_LRP2')
            if CTVLRP2_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVLRP2_Mask,("CTV_LRP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVLRP3_Mask=FindMask(SubDirectoryList,'CTV_LRP3')
            if CTVLRP3_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVLRP3_Mask,("CTV_LRP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                    
            CTVLRM1_Mask=FindMask(SubDirectoryList,'CTV_LRM1')
            if CTVLRM1_Mask is not None:
                RadiomicsCalculator(paramPath,t2_Image,CTVLRM1_Mask,("CTV_LRM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
############ CTV-N Mask #################################################################################         
        if CTV_N == True:
        
            CTVNP0_Mask=FindMask(SubDirectoryList,'CTV_NP0')
            if CTVNP0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVNP0_Mask,("CTV_NP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVNP1_Mask=FindMask(SubDirectoryList,'CTV_NP1')
            if CTVNP1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVNP1_Mask,("CTV_NP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVNP2_Mask=FindMask(SubDirectoryList,'CTV_NP2')
            if CTVNP2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVNP2_Mask,("CTV_NP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVNP3_Mask=FindMask(SubDirectoryList,'CTV_NP3')
            if CTVNP3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVNP3_Mask,("CTV_NP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVNM1_Mask=FindMask(SubDirectoryList,'CTV_NM1')
            if CTVNM1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVNP3_Mask,("CTV_NM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))


############ CTV-N1 Mask #################################################################################         
        if CTV_N1 == True:
        
            CTVN1P0_Mask=FindMask(SubDirectoryList,'CTV_N1P0')
            if CTVN1P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN1P0_Mask,("CTV_N1P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVN1P1_Mask=FindMask(SubDirectoryList,'CTV_N1P1')
            if CTVN1P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN1P1_Mask,("CTV_N1P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN1P2_Mask=FindMask(SubDirectoryList,'CTV_N1P2')
            if CTVN1P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN1P2_Mask,("CTV_N1P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVN1P3_Mask=FindMask(SubDirectoryList,'CTV_N1P3')
            if CTVN1P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN1P3_Mask,("CTV_N1P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN1M1_Mask=FindMask(SubDirectoryList,'CTV_N1M1')
            if CTVN1M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN1P3_Mask,("CTV_N1M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            
############## CTV-N2 #####################################################################################            
        if CTV_N2 == True:
                
            CTVN2P0_Mask=FindMask(SubDirectoryList,'CTV_N2P0')
            if CTVN2P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN2P0_Mask,("CTV_N2P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVN2P1_Mask=FindMask(SubDirectoryList,'CTV_N2P1')
            if CTVN2P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN2P1_Mask,("CTV_N2P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN2P2_Mask=FindMask(SubDirectoryList,'CTV_N2P2')
            if CTVN2P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN2P2_Mask,("CTV_N2P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN2P3_Mask=FindMask(SubDirectoryList,'CTV_N2P3')
            if CTVN2P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN2P3_Mask,("CTV_N2P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN2M1_Mask=FindMask(SubDirectoryList,'CTV_N2M1')
            if CTVN2M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN2M1_Mask,("CTV_N2M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
############# CTV-N3 #####################################################################################
        if CTV_N3 == True:
                        
            CTVN3P0_Mask=FindMask(SubDirectoryList,'CTV_N3P0')
            if CTVN3P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN3P0_Mask,("CTV_N3P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVN3P1_Mask=FindMask(SubDirectoryList,'CTV_N3P1')
            if CTVN3P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN3P1_Mask,("CTV_N3P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN3P2_Mask=FindMask(SubDirectoryList,'CTV_N3P2')
            if CTVN3P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN3P2_Mask,("CTV_N3P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN3P3_Mask=FindMask(SubDirectoryList,'CTV_N3P3')
            if CTVN3P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN3P3_Mask,("CTV_N3P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN3M1_Mask=FindMask(SubDirectoryList,'CTV_N3M1')
            if CTVN3M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN3M1_Mask,("CTV_N3M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))


############# CTV-N4 #####################################################################################
        if CTV_N4 == True:
                        
            CTVN4P0_Mask=FindMask(SubDirectoryList,'CTV_N4P0')
            if CTVN4P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN4P0_Mask,("CTV_N4P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVN4P1_Mask=FindMask(SubDirectoryList,'CTV_N4P1')
            if CTVN4P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN4P1_Mask,("CTV_N4P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN4P2_Mask=FindMask(SubDirectoryList,'CTV_N4P2')
            if CTVN4P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN4P2_Mask,("CTV_N4P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN4P3_Mask=FindMask(SubDirectoryList,'CTV_N4P3')
            if CTVN4P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN4P3_Mask,("CTV_N4P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVN4M1_Mask=FindMask(SubDirectoryList,'CTV_N4M1')
            if CTVN4M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVN4M1_Mask,("CTV_N4M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
############# CTV-E #####################################################################################
        if CTV_E == True:
                        
            CTVEP0_Mask=FindMask(SubDirectoryList,'CTV_EP0')
            if CTVEP0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVEP0_Mask,("CTV_EP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            CTVEP1_Mask=FindMask(SubDirectoryList,'CTV_EP1')
            if CTVEP1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVEP1_Mask,("CTV_EP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVEP2_Mask=FindMask(SubDirectoryList,'CTV_EP2')
            if CTVEP2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVEP2_Mask,("CTV_EP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVEP3_Mask=FindMask(SubDirectoryList,'CTV_EP3')
            if CTVEP3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVEP3_Mask,("CTV_EP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            CTVEM1_Mask=FindMask(SubDirectoryList,'CTV_EM1')
            if CTVEM1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,CTVEM1_Mask,("CTV_EM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))  
############### GTV-N Mask ###############################################################################
        if GTV_N == True:
        
            GTVNP0_Mask=FindMask(SubDirectoryList,'GTV_NP0')
            if GTVNP0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVNP0_Mask,("GTV_NP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            GTVNP1_Mask=FindMask(SubDirectoryList,'GTV_NP1')
            if GTVNP1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVNP1_Mask,("GTV_NP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVNP2_Mask=FindMask(SubDirectoryList,'GTV_NP2')
            if GTVNP2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVNP2_Mask,("GTV_NP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVNP3_Mask=FindMask(SubDirectoryList,'GTV_NP3')
            if GTVNP3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVNP3_Mask,("GTV_NP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVNM1_Mask=FindMask(SubDirectoryList,'GTV_NM1')
            if GTVNM1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVNM1_Mask,("GTV_NM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
############### GTV-N1 Mask ##############################################################################
        if GTV_N1 == True:
        
            GTVN1P0_Mask=FindMask(SubDirectoryList,'GTV_N1P0')
            if GTVN1P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN1P0_Mask,("GTV_N1P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            GTVN1P1_Mask=FindMask(SubDirectoryList,'GTV_N1P1')
            if GTVN1P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN1P1_Mask,("GTV_N1P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN1P2_Mask=FindMask(SubDirectoryList,'GTV_N1P2')
            if GTVN1P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN1P2_Mask,("GTV_N1P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN1P3_Mask=FindMask(SubDirectoryList,'GTV_N1P3')
            if GTVN1P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN1P3_Mask,("GTV_N1P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN1M1_Mask=FindMask(SubDirectoryList,'GTV_N1M1')
            if GTVN1M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN1M1_Mask,("GTV_N1M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
        
        
############### GTV-N2 ######################################################################################        
        if GTV_N2 == True:
        
            GTVN2P0_Mask=FindMask(SubDirectoryList,'GTV_N2P0')
            if GTVN2P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN2P0_Mask,("GTV_N2P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            GTVN2P1_Mask=FindMask(SubDirectoryList,'GTV_N2P1')
            if GTVN2P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN2P1_Mask,("GTV_N2P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN2P2_Mask=FindMask(SubDirectoryList,'GTV_N2P2')
            if GTVN2P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN2P2_Mask,("GTV_N2P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN2P3_Mask=FindMask(SubDirectoryList,'GTV_N2P3')
            if GTVN2P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN2P3_Mask,("GTV_N2P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN2M1_Mask=FindMask(SubDirectoryList,'GTV_N2M1')
            if GTVN2M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN2M1_Mask,("GTV_N2M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
############### GTV-N3 ######################################################################################        
        if GTV_N3 == True:
        
            GTVN3P0_Mask=FindMask(SubDirectoryList,'GTV_N3P0')
            if GTVN3P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN3P0_Mask,("GTV_N3P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            GTVN3P1_Mask=FindMask(SubDirectoryList,'GTV_N3P1')
            if GTVN3P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN3P1_Mask,("GTV_N3P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN3P2_Mask=FindMask(SubDirectoryList,'GTV_N3P2')
            if GTVN3P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN3P2_Mask,("GTV_N3P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN3P3_Mask=FindMask(SubDirectoryList,'GTV_N3P3')
            if GTVN3P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN3P3_Mask,("GTV_N3P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN3M1_Mask=FindMask(SubDirectoryList,'GTV_N3M1')
            if GTVN3M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN3M1_Mask,("GTV_N3M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))

############### GTV-N4 ######################################################################################        
        if GTV_N4 == True:
        
            GTVN4P0_Mask=FindMask(SubDirectoryList,'GTV_N4P0')
            if GTVN4P0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN4P0_Mask,("GTV_N4P0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            GTVN4P1_Mask=FindMask(SubDirectoryList,'GTV_N4P1')
            if GTVN4P1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN4P1_Mask,("GTV_N4P1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN4P2_Mask=FindMask(SubDirectoryList,'GTV_N4P2')
            if GTVN4P2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN4P2_Mask,("GTV_N4P2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN4P3_Mask=FindMask(SubDirectoryList,'GTV_N4P3')
            if GTVN4P3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN4P3_Mask,("GTV_N4P3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            GTVN4M1_Mask=FindMask(SubDirectoryList,'GTV_N4M1')
            if GTVN4M1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,GTVN4M1_Mask,("GTV_N4M1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))                
                
############### Rectum_Boundary ######################################################################################        
        if Rectum_Boundary == True:
        
            Rectum_BoundaryP0_Mask=FindMask(SubDirectoryList,'Rectum_BoundaryP0')
            if Rectum_BoundaryP0_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,Rectum_BoundaryP0_Mask,("Rectum_BoundaryP0_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
            
            Rectum_BoundaryP1_Mask=FindMask(SubDirectoryList,'Rectum_BoundaryP1')
            if Rectum_BoundaryP1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,Rectum_BoundaryP1_Mask,("Rectum_BoundaryP1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            Rectum_BoundaryP2_Mask=FindMask(SubDirectoryList,'Rectum_BoundaryP2')
            if Rectum_BoundaryP2_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,Rectum_BoundaryP2_Mask,("Rectum_BoundaryP2_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            Rectum_BoundaryP3_Mask=FindMask(SubDirectoryList,'Rectum_BoundaryP3')
            if Rectum_BoundaryP3_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,Rectum_BoundaryP3_Mask,("Rectum_BoundaryP3_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))
                
            Rectum_BoundaryM1_Mask=FindMask(SubDirectoryList,'Rectum_BoundaryM1')
            if Rectum_BoundaryM1_Mask is not None:
                RadiomicsCalculator(paramPath,Dixon_Image,Rectum_BoundaryM1_Mask,("Rectum_BoundaryM1_"+patientNumber+"_"+paramPath.split(patientNumber+'\\',1)[1]))                
                
###############################################################################################################    
        
        # print the loop number completed
        print ("\n\nLoop: ", index+1, "of", len(MasterDirectoryList), " Completed\n\n")         
        
# print the time taken for code to run       
print("Time taken: ", time.time()-start_time, "s")

###############################################################################