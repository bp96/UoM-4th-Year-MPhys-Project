import tensorflow as tf
import keras.backend as K
import keras



def logitLossFunction(tgt, logits):
    logits_flat = K.reshape(logits, [-1, 2])
    tgt_flat = K.reshape(tgt, [-1,2])
    return tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits=logits_flat, labels=tgt_flat))


def dice_coef(y_true, y_pred, smooth=1):
    """
    Dice = (2*|X & Y|)/ (|X|+ |Y|)
         =  2*sum(|A*B|)/(sum(A^2)+sum(B^2))
    ref: https://arxiv.org/pdf/1606.04797v1.pdf
    """
    intersection = K.sum(K.abs(y_true * y_pred), axis=-1)
    return (2. * intersection + smooth) / (K.sum(K.square(y_true),-1) + K.sum(K.square(y_pred),-1) + smooth)

def dice_coef_loss(y_true, y_pred):
    """
    Defined as 'soft dice', works well for segmentation tasks with one two classes
    """
    return 1-dice_coef(y_true, y_pred)
