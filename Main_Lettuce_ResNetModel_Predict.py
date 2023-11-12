import pandas as pd
# import seaborn as sns
# import matplotlib.pyplot as plt
import tensorflow as tf
# from tensorflow.keras.preprocessing.image import ImageDataGenerator
# from tensorflow.keras.applications.resnet import ResNet50
# from tensorflow.keras.models import Sequential
# from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, Flatten
# from tensorflow.keras.optimizers import Adam
# import warnings
# warnings.filterwarnings('ignore')
import numpy as np
from PIL import Image

ModelFileName='WUR_OnlineChallenge_RGH224_au10/h5/Lettuce_WUR_250.h5'
# TrainDataSetName='TLPii_WUR'
TrainDataSetName='WUR_250'
# ModelFileName='Piikkio_2023_RGH224_au10/h5/Lettuce_Pii_Fold2.h5'
# TrainDataSetName='Pii'

ValidDataFolderList=[]
ValidDataNameList=[]
RefFileNameList=[]
ValidDataFolderList.append('Piikkio_2023_RGH224_au10/')
ValidDataNameList.append('Pii')
RefFileNameList.append('LettuceMassReference_Valid.csv')
ValidDataFolderList.append('WUR_OnlineChallenge_RGH224_au10/')
ValidDataNameList.append('WUR')
RefFileNameList.append('LettuceMassReference_Valid.csv')
"""ValidDataFolderList.append('Piikkio_2023_RGH224_au10/')
ValidDataNameList.append('Pii_Exp1')
RefFileNameList.append('LettuceMassReference_Exp1_Valid.csv')
ValidDataFolderList.append('Piikkio_2023_RGH224_au10/')
ValidDataNameList.append('Pii_Exp2')
RefFileNameList.append('LettuceMassReference_Exp2_Valid.csv')
ValidDataFolderList.append('Piikkio_2023_RGH224_au10/')
ValidDataNameList.append('Pii_Exp3')
RefFileNameList.append('LettuceMassReference_Exp3_Valid.csv')
"""

"""
ValidDataFolderList.append('Piikkio_2023_RGH224_au10/')
ValidDataNameList.append('Pii_Fold2')
RefFileNameList.append('LettuceMassReference_Fold2_Valid.csv')"""

# ValidDataFolder='Piikkio_2023_RGH224_au10/'
# ValidDataName='Pii_Exp3'
# ValidDataFolder='WUR_OnlineChallenge_RGH224_au10/'
# ValidDataName='WUR'

# RefFileName='LettuceMassReference_Valid.csv'
# RefFileName='LettuceMassReference_Exp3_Train.csv'

model = tf.keras.models.load_model(ModelFileName)

for i in range(len(ValidDataFolderList)):
    ValidDataFolder=ValidDataFolderList[i]
    ValidDataName=ValidDataNameList[i]
    RefFileName=RefFileNameList[i]
    
    labels = pd.read_csv(ValidDataFolder + RefFileName,delimiter=';')
    file_name=labels['FileName']
    real_age=labels['FreshWeightRef']
    images = []
    for i in range(len(file_name)):
        img=Image.open(ValidDataFolder + file_name[i]).resize((224,224))
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

    pd.DataFrame(d).to_csv('Lettuce_Train'+TrainDataSetName+'_Valid'+ValidDataName+'_Res.csv',sep=';')
