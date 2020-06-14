# NOTES: this needs to be run after the NiftiToNumpy.py file which will generate .npz arrays. 
# THINGS TO ADJUST: STEPS PER EPOCH, NUMBER OF EPOCHS, LEARNING RATE (LR)
# training: slices=832 ; validation: slices=158
######################################################################################################
# Import libraries
####################################################################################################
import keras
import keras.backend as K
from keras.preprocessing.image import ImageDataGenerator
from keras.optimizers import Adam, Nadam, SGD#, RMSProp
from keras.callbacks import TensorBoard, ModelCheckpoint, ReduceLROnPlateau, EarlyStopping
import tensorflow as tf
import numpy as np
import sys
import matplotlib.pyplot as plt
sys.path.append(r'C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master')
 
from createVGGSegModel import buildModel
import json
import time
from segmentationLosses import dice_coef_loss ## Use this as default, soft dice may be more appropriate

start_time=time.time()
######################################################################################################
# Set default values - ONLY TRAINING MODE NEEDS TO BE TURNED ON OR OFF
######################################################################################################

vggWeightsFile = r'C:\Users\Sam\.keras\vgg16_weights_tf_dim_ordering_tf_kernels_notop.h5'  #### default weights file
logdir = "./logs" ### save logs
training = True ### training mode on or off, ie True or False

#######################################################################################################
# Set paths for the training and validation data set folders - CHANGE THESE
#######################################################################################################

slicesPath = r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\GTV\slices_T2Only.npz" # set path for  training .npz slices file
masksPath = r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\GTV\masks_T2Only.npz" # set path for training .npz mask file 

valSlicesPath = r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\GTV\valSlices_T2Only.npz" # set path for validation .npz slices file
valMasksPath = r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\GTV\valMasks_T2Only.npz" # set path for validation .npz training file

testSlicesPath = r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\GTV\testSlices_T2Only.npz" # set path for test .npz slices file
testMasksPath = r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\NiftiDataSet\CTVcrop\GTV\testMasks_T2Only.npz" # set path for test .npz masks file

######################################################################################################
# Model generation and training 
######################################################################################################

slices = np.load(slicesPath)['arr_0']
masks = np.load(masksPath)['arr_0']

valSlices = np.load(valSlicesPath)['arr_0']
valMasks = np.load(valMasksPath)['arr_0']

testSlices = np.load(testSlicesPath)['arr_0']
testMasks = np.load(testMasksPath)['arr_0']

datagen = ImageDataGenerator()#rotation_range=15, zoom_range=0.1, horizontal_flip=True, fill_mode='nearest')   
maskgen = ImageDataGenerator()#rotation_range=15, zoom_range=0.1, horizontal_flip=True, fill_mode='nearest')   

valsgen = ImageDataGenerator()
valmgen = ImageDataGenerator()

seed = 1234
sliceGenerator = datagen.flow(slices,  seed=seed, batch_size=16) #default batch size is 16
maskGenerator = maskgen.flow(masks,  seed=seed, batch_size=16) # default batch size is 16

valSliceGenerator = valsgen.flow(valSlices, seed=seed+1)
valMaskGenerator  = valmgen.flow(valMasks, seed=seed+1)
train_generator = zip(sliceGenerator, maskGenerator)
val_generator = zip(valSliceGenerator, valMaskGenerator)

# BELOW - TRAINING PARAMETER: steps_per_epoch should typically be equal to the number of unique samples of your training dataset divided by the batch size
if training:
    
    model = buildModel(vggWeightsFile)

    logging = TensorBoard(log_dir=logdir)
    checkpoint = ModelCheckpoint(logdir + 'ep{epoch:03d}-loss{loss:.3f}-val_loss{val_loss:.3f}.h5', monitor='val_loss', save_weights_only=True, save_best_only=True, period=3)
    reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=3, verbose=1)
    early_stopping = EarlyStopping(monitor='val_loss', min_delta=0, patience=10, verbose=1)

    print(model.summary())
    
    LR_1=0.001
    LR_2=0.0001
    
    model.compile(optimizer=SGD(lr=LR_1), loss=dice_coef_loss, metrics=['accuracy']) # default lr=0.001 - can be increased with more data or decreased with less
    
    history = model.fit_generator(train_generator, steps_per_epoch=52, epochs=10, validation_data=val_generator, validation_steps=30, initial_epoch=0, callbacks=[logging, checkpoint])     
    plt.plot(history.history['acc'])
    plt.plot(history.history['val_acc'])
    plt.title('Model accuracy')
    plt.ylabel('Accuracy')
    plt.xlabel('Epoch')
    plt.legend(['Train', 'Validation'], loc='upper left')
    
    plt.savefig(r'C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\Models_and_predictions\Model_Accuracy_'+str(LR_1)+'.png')
    plt.show()
    
    # Plot training & validation loss values
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('Model loss')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    plt.legend(['Train', 'Validation'], loc='upper left')
    
    plt.savefig(r'C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\Models_and_predictions\Model_Loss_'+str(LR_1)+'.png')
    plt.show()
    
    #### default values: stages per epoch=100, validation steps=30, epochs=10.
    ## at this point, maybe make some layers trainable again?
    modelJSON = model.to_json()
    with open("vgg16_UNet.json", 'w') as mjsn:
        mjsn.write(modelJSON)
    model.save_weights("vgg16_UNet_stage1.h5")

    for i in range(len(model.layers)):
            model.layers[i].trainable = True
    model.compile(optimizer=SGD(lr=LR_2), loss=dice_coef_loss, metrics=['accuracy'])
    history = model.fit_generator(train_generator, steps_per_epoch=52, epochs=20, validation_data=val_generator, validation_steps=30, initial_epoch=10, callbacks=[checkpoint, reduce_lr, early_stopping])  #### original steps per epoch=100, validation steps=30, epochs=100
    plt.plot(history.history['acc'])
    plt.plot(history.history['val_acc'])
    plt.title('Model accuracy')
    plt.ylabel('Accuracy')
    plt.xlabel('Epoch')
    plt.legend(['Train', 'Validation'], loc='upper left')
    
    plt.savefig(r'C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\Models_and_predictions\Model_Accuracy_'+str(LR_2)+'.png')
    plt.show()
    
    # Plot training & validation loss values
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('Model loss')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    plt.legend(['Train', 'Validation'], loc='upper left')
    
    plt.savefig(r'C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\Models_and_predictions\Model_Loss_'+str(LR_2)+'.png')
    plt.show()
    model.save_weights("vgg16_UNet_stage2.h5")
    keras.models.save_model(model, "vgg16_UNet.hdf5")

#######################################################################################################################################################################################
# Print and save results - DOES NOT NEED TO BE CHANGED FOR NOW
#######################################################################################################################################################################################

    predictions_1 = model.predict(valSlices)
    np.save(r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\Models_and_predictions\predictions_val.npy", predictions_1)
    
    predictions_2 = model.predict(testSlices)
    np.save(r"C:\Users\Sam\Desktop\Sam\2DSegmentationUVGG-master\Models_and_predictions\predictions_test.npy", predictions_2)
    
    time_elapsed=time.time()-start_time
    print(model.evaluate(x=valSlices, y=valMasks))
    print("Time elapsed: ", time_elapsed)

################# End of code #########################################################################################################################################################

