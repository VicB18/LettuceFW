# python Main_Lettuce_ResNetModel_Train.py
# cd C:\Users\03138529\Dropbox\Luke\FoodFields\Software
# C:\Users\03138529\AppData\Local\miniconda3\python.exe
# C:\Users\03138529\Desktop\FWF\LettuceVenv\Scripts\activate.bat
import pandas as pd
# import seaborn as sns
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.resnet import ResNet50
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, Flatten
from tensorflow.keras.optimizers import Adam
import time
import warnings
warnings.filterwarnings('ignore')
import os
os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE"


DataFolder='C:/Users/03138529/Desktop/Lettuce/'
# DataFolder=''
start_time = time.time()

# DataFolder=DataFolder+'Piikkio_2023_RGH224_au10/'
# DataSetName='Pii'# _Exp1TLWUR_
DataFolder=DataFolder+'WUR_OnlineChallenge_RGH224_au10/'
DataSetName='WUR'
# TFModel=DataFolder+'Piikkio_2023_RGH224_au10/h5/Lettuce_Pii_250.h5'
# TFModel=DataFolder+'WUR_OnlineChallenge_RGH224_au10/h5/Lettuce_WUR_250.h5'
TFModel=''
# TLModelName='TLWUR_250_'
# TLModelName='TLPii_250_'
TLModelName=''
Fold_i='_Fold4'
# Fold_i='_Exp1'
# Fold_i=''
EpochN=250
print('---------------------------------------------------------------')
print(DataSetName+', '+Fold_i+', '+TFModel)
print('---------------------------------------------------------------')

RefFileName='LettuceMassReference'

def load_train(DataFolder,RefFileName):
    labels = pd.read_csv(DataFolder + RefFileName,delimiter=';')
    train_datagen = ImageDataGenerator(validation_split=0.25, rescale=1 / 255,
                                       rotation_range=180,width_shift_range=0.2,height_shift_range=0.1)
    train_gen_flow = train_datagen.flow_from_dataframe(
        dataframe=labels,
        directory=DataFolder + '',
        x_col='FileName',
        y_col='FreshWeightRef',
        target_size=(224, 224),
        batch_size=32,
        class_mode='raw',
        subset = 'training',
        seed=12345)

    return train_gen_flow

def load_test(DataFolder,RefFileName):
    labels = pd.read_csv(DataFolder + RefFileName,delimiter=';')
    validation_datagen = ImageDataGenerator(validation_split=0.25, rescale=1/255,
                                       rotation_range=180,width_shift_range=0.2,height_shift_range=0.1)
    test_gen_flow = validation_datagen.flow_from_dataframe(
    dataframe = labels,
    directory=DataFolder +'',
    x_col="FileName",
    y_col="FreshWeightRef", 
    class_mode="raw", 
    target_size=(224,224), 
    batch_size=32,
    subset = "validation",
    seed=12345,
    )

    return test_gen_flow

def create_model(input_shape):
    # we will use ResNet50 architecture, with freezing top layers
    backbone = ResNet50(input_shape=input_shape, weights='imagenet', include_top=False)
    model = Sequential()
    model.add(backbone)
    
    #now we will add our custom layers
    #without drop layer, neural networks can easily overfit
    model.add(Dropout(0.2))
    model.add(GlobalAveragePooling2D())
    
    #final layer, since we are doing regression we will add only one neuron (unit)
    model.add(Dense(1, activation='relu'))
    optimizer = Adam(lr=0.0003)
    model.compile(optimizer=optimizer, loss='mae', metrics=['mae'])
    print(model.summary())

    return model

train_data = load_train(DataFolder,RefFileName+Fold_i+'_Train.csv')
test_data = load_test(DataFolder,RefFileName+Fold_i+'_Train.csv')

#build a model
if TFModel=='':
    model = create_model(input_shape = (224, 224, 3))
else:
    model = tf.keras.models.load_model(TFModel)#, compile=False
    # model.trainable=False
    for layer_i in range(143):
        model.layers[0].layers[layer_i].trainable=False
    # for layer in model.layers[0:20]:
    #     layer.trainable = False

    # for layer in model.layers[-20:]:
    #     layer.trainable = True

    optimizer = Adam(lr=0.0003)
    model.compile(optimizer=optimizer, loss='mae', metrics=['mae'])
    print(model.summary(expand_nested=True,show_trainable=True))

history = model.fit(train_data, validation_data=test_data, batch_size=None, 
              epochs=EpochN,steps_per_epoch=None,validation_steps=None, verbose=2)

model.save(DataFolder+'h5/Lettuce_'+TLModelName+DataSetName+Fold_i+'_'+str(EpochN)+'.h5')
print(history.history)
print(history.history['mae'])
print(history.history['val_mae'])
print(history.history['loss'])
print(history.history['val_loss'])
d={'mae':history.history['mae'],
   'val_mae':history.history['val_mae'],
   'loss':history.history['loss'],
   'val_loss':history.history['val_loss']}
pd.DataFrame(d).to_csv(DataFolder+'h5/Lettuce_TrainingHist_'+DataSetName+Fold_i+'_'+str(EpochN)+'.csv',sep=';')

import numpy as np
from PIL import Image
# model = tf.keras.models.load_model(DataFolder+'h5/Example.h5', compile=False)
labels = pd.read_csv(DataFolder + RefFileName+Fold_i+'_Valid.csv',delimiter=';')
file_name=labels['FileName']
real_age=labels['FreshWeightRef']
images = []
for i in range(len(file_name)):
    img=Image.open(DataFolder + file_name[i]).resize((224,224))
    img = np.array(img) / 255
    img = img[:, :, :3]
    img = np.expand_dims(img, axis=0)
    images.append(img)


images = np.vstack(images)
prediction = model.predict(images)
PredictedFW=[]
for p in prediction:
    PredictedFW.append(p[0])
RefFW=[]
for i in range(len(real_age)):
    RefFW.append(real_age[i])

d={'PredictedFreshWeight':PredictedFW,
   'ReferenceFreshWeight':RefFW}

pd.DataFrame(d).to_csv('Lettuce_'+TLModelName+DataSetName+Fold_i+'_Res'+'_'+str(EpochN)+'.csv',sep=';')

end_time = time.time()
elapsed_time = end_time - start_time
print("Elapsed time: ", elapsed_time)
print("Elapsed time: ", elapsed_time/60/60, " hours")

