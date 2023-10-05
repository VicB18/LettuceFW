import pandas as pd
import tensorflow as tf
import numpy as np
from PIL import Image

# ModelFileName='WUR_OnlineChallenge_ResNet50_RGH/h5/Lettuce_WUR.h5'
# TrainDataSetName='WUR'
# ModelFileName='Piikkio_2023_ResNet50_RGH/h5/Lettuce_Pii.h5'
# TrainDataSetName='Pii'
ModelFileName='Piikkio_2023_ResNet50_RGH_au/h5/Lettuce_Pii_1000.h5'
TrainDataSetName='Pii'

ValidDataFolderList=[]
ValidDataNameList=[]
RefFileNameList=[]
ValidDataFolderList.append('Piikkio_2023_ResNet50_RGH_au/')
ValidDataNameList.append('Pii_Exp3')
RefFileNameList.append('LettuceMassReference_Exp3_Valid.csv')

ValidDataFolder='Piikkio_2023_ResNet50_RGH/'
ValidDataName='Pii_Exp3'
# ValidDataFolder='WUR_OnlineChallenge_ResNet50_RGH_au/'
# ValidDataName='WUR'

# RefFileName='LettuceMassReference_Valid.csv'
RefFileName='LettuceMassReference_Exp3_Train.csv'

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
