import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.resnet import ResNet50
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, Flatten
from tensorflow.keras.optimizers import Adam
import warnings
warnings.filterwarnings('ignore')

# DataFolder='Piikkio_2023_ResNet50_RGH_au/'
# DataSetName='Pii'#TLWUR_ _Exp1
DataFolder='WUR_OnlineChallenge_ResNet50_RGH_au/'
DataSetName='WUR'
# TFModel='Piikkio_2023_ResNet50_RGH_au/h5/Lettuce_Pii_1000.h5'
TFModel='WUR_OnlineChallenge_ResNet50_RGH_au/h5/Lettuce_TLPii_WUR_250.h5'
# TFModel=''
# TLModelName='TLWUR_'
TLModelName='TLPii_'
# TLModelName=''
# Fold_i='_Fold2'
# Fold_i='_Exp1'
Fold_i=''
EpochN=250
print('---------------------------------------------------------------')
print(DataSetName+', '+Fold_i+', '+TFModel)
print('---------------------------------------------------------------')

RefFileName='LettuceMassReference'
# labels = pd.read_csv(DataFolder+RefFileName+Fold_i+'_Train.csv',delimiter=';')
# # labels = pd.read_csv('F:/Lettuce/final_files/labels.csv')
# # labels = pd.read_csv('C:/Users/03138529/Desktop/Piikkio_2023_ResNet50_RGH/LettuceMassReference1.csv')
# labels.head()

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
    print(model.summary())

history = model.fit(train_data, validation_data=test_data, batch_size=None, 
              epochs=EpochN,steps_per_epoch=None,validation_steps=None, verbose=2)

model.save(DataFolder+'h5/Lettuce_'+TLModelName+DataSetName+Fold_i+'.h5')
print(history.history)
print(history.history['mae'])
print(history.history['val_mae'])
print(history.history['loss'])
print(history.history['val_loss'])
d={'mae':history.history['mae'],
   'val_mae':history.history['val_mae'],
   'loss':history.history['loss'],
   'val_loss':history.history['val_loss']}
pd.DataFrame(d).to_csv(DataFolder+'h5/Lettuce_TrainingHist_'+DataSetName+Fold_i+'.csv',sep=';')

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

pd.DataFrame(d).to_csv('Lettuce_'+TLModelName+DataSetName+Fold_i+'_Res.csv',sep=';')
