import keras
from keras.applications.vgg16 import VGG16
from keras.layers import Input, Conv2D, MaxPooling2D, BatchNormalization, Conv2DTranspose, Concatenate
from keras.models import Model

def buildModel(vggWeightsPath, inputShape=(160,160,3), freezeVGGLayers=True, nClasses=2):
    """
    Function to build and return a keras model for segmentation. The model is based on parts of a pre-trained
    VGG16 model, so the layer names are important. We will load the model weights from file at the end. By 
    default, the segmenter only segments one foreground and background, this can be changed by setting nClasses.

    Arguments:
        - vggWeightsPath: Full or relative path to the VGG16 weights file that can be downloaded by Keras.
        - freezeVGGLayers: Flag to freeze training of the imported layers, defaults to true for transfer learning.
        - nClasses: The number of classes in the image. Defaults to 2 (object and background)

    Returns:
        - model: a VGG16 based, UNet-like segmentation network model.
    """
    inputLayer = Input(name="input_1", shape=inputShape)

    b1_c1 = Conv2D(64, (3,3), name="block1_conv1", padding='same', activation='tanh')(inputLayer)
    b1_c2 = Conv2D(64, (3,3), name="block1_conv2", padding='same', activation='tanh')(b1_c1) ## Skip connection 1 from here
    b1_pool = MaxPooling2D(name="block1_pool")(b1_c2)

    b2_c1 = Conv2D(128, (3,3), name="block2_conv1", padding='same', activation='tanh')(b1_pool)
    b2_c2 = Conv2D(128, (3,3), name="block2_conv2", padding='same', activation='tanh')(b2_c1) ## Skip connection 2 from here
    b2_pool = MaxPooling2D(name="block2_pool")(b2_c2)

    b3_c1 = Conv2D(256, (3,3), name="block3_conv1", padding='same', activation='tanh')(b2_pool)
    b3_c2 = Conv2D(256, (3,3), name="block3_conv2", padding='same', activation='tanh')(b3_c1) ## Skip connection 3 from here
    b3_pool = MaxPooling2D(name="block3_pool")(b3_c2)

    b4_c1 = Conv2D(512, (3,3), name="block4_conv1", padding='same', activation='tanh')(b3_pool)
    b4_c2 = Conv2D(512, (3,3), name="block4_conv2", padding='same', activation='tanh')(b4_c1) ## Skip connection 4 from here
    b4_pool = MaxPooling2D(name="block4_pool")(b4_c2)

    b5_c1 = Conv2D(1024, (3,3), name="nblock5_conv1", padding='same', activation='tanh')(b4_pool)
    b5_tc1 = Conv2DTranspose(512, (3,3), strides=(2,2), padding='same', activation='tanh')(b5_c1)

    sk4 = Concatenate(name="skip4")([b4_c2, b5_tc1])

    nb4_c1 = Conv2D(512, (3,3), name="nblock4_conv1", padding='same', activation='tanh')(sk4)
    nb4_c2 = Conv2D(512, (3,3), name="nblock4_conv2", padding='same', activation='tanh')(nb4_c1)
    nb4_tc1 = Conv2DTranspose(256, (3,3), strides=(2,2), padding='same', name="nblock4_tconv1")(nb4_c2)

    sk3 = Concatenate(name="skip3")([b3_c2, nb4_tc1])

    nb3_c1 = Conv2D(256, (3,3), name="nblock3_conv1", padding='same', activation='tanh')(sk3)
    nb3_c2 = Conv2D(256, (3,3), name="nblock3_conv2", padding='same', activation='tanh')(nb3_c1)
    nb3_tc1 = Conv2DTranspose(128, (3,3), strides=(2,2), padding='same', name="nblock3_tconv1")(nb3_c2)

    sk2 = Concatenate(name="skip2")([b2_c2, nb3_tc1])

    nb2_c1 = Conv2D(128, (3,3), name="nblock2_conv1", padding='same', activation='tanh')(sk2)
    nb2_c2 = Conv2D(128, (3,3), name="nblock2_conv2", padding='same', activation='tanh')(nb2_c1)
    nb2_tc1 = Conv2DTranspose(64, (3,3), strides=(2,2), padding='same', name="nblock2_tconv1")(nb2_c2)

    sk1 = Concatenate(name="skip1")([b1_c2, nb2_tc1])

    finalConv = Conv2DTranspose(nClasses, (3,3), strides=(1,1), padding='same', name="output_tconv", activation='softmax')(sk1)

    model = Model(inputs=[inputLayer], outputs=[finalConv])

    model.load_weights(vggWeightsPath, by_name=True)

    if freezeVGGLayers:
        for layer in model.layers[:12]:
            layer.trainable=False
    return model