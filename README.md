# LettuceFW
Estimation of the lettuce fresh weight during growing based on 3D imaging. The software represents a supplemental material for the paper [Bloch et al., 2023](). The data collected in this study is stored at [https://zenodo.org/](https://zenodo.org/uploads/8410252).

![Plant top view](/Figures/Fig2a.png)
![Plant point cloud top view](/Figures/Fig2b.png)
![Plant side view](/Figures/Fig2c.png)
![Plant point cloud side view](/Figures/Fig2d.png)

# Raw data preparation
All data folders contain point clouds in `.ply` format and RGB images in `.png` format which represent one RGBD frame recorded by 3D RealSence D405 cameras. In the folder `2023_03_09_Day_23` the frames were saved by the cameras to `.ply` and `.png` files. In the folders `2023_04_04_Day_21` and `2023_05_16_Day_21` the frames were extracted from the `.bag` video recorded by the cameras, when the first video frame was extracted from each video. (To process `.bag` videos and extract `.ply` point clouds and RGB images, run `Main_Bag2Ply.m`. [RealSense SDK](https://www.intelrealsense.com/sdk-2/) must be installed.)

The RGBD frames of the **3rd Autonomous Greenhouse Challenge: Online Challenge Lettuce Images** [Hemming et al., 2022](https://data.4tu.nl/articles/_/15023088/1) were extracted to the folder `WUR_OnlineChallenge`.

# Calibration of cameras
The parameters for the 6DOF space transformations for each camera for each recording session are saved in the file `CameraCalibration.csv`. (To find the parameters, run `Main_Cam3D_Pos_Calibration.m`. Manual area selection is required.)

# Volume calculation
The point clouds are prepared, their surface is reconstructed by different methods and the volume is calculated by running `Main_LettuceVolume.m`. The poin clouds are saved in `.mat` format. The calculated volumes are written in the files `CalculatedPlantVolume_Top.csv` for the point clouds constucted from the top view RGBD frames and in the file `CalculatedPlantVolume_All.csv` for the point clouds constructed from the side and top RBGD frames.

# Preparing data for ResNet50

## Image resizing and creating RGH frames
The original RGB images are resized to the 224x224 pixels size fitting to the ResNet50 by running `Main_RGH_Frames.m`. The resizing factors are calculated according to the 3D camera FOV, resolution and distance to the object. The B color channel is ommited since it is assumed that it does not add significant information. Instead of the channel B, the channel H is added to the frames. The channel H represents the height of the plant related to a reference plane (plant pot edge) measured in mm multiplyed by the factor 0.5 gray scale unit / mm.

<img src="https://github.com/VicB18/LettuceFW/blob/main/Figures/Piikkio_2023_2023_03_09_Day_23_1_Cam4_RGB.png" width="224">

![RGH image fittef to 224x224 ResNet50 format.](/Figures/Piikkio_2023_2023_03_09_Day_23_1_Cam4_RGH.png)

## Splitting data for 10 fold validation
The RGH frames in the `Piikkio_2023_RGH224` and `WUR_OnlineChallenge_RGH224` folders are slit into training and validation lists for 10 fold validation by running  `Main_DataSplit10Fold_ResNet.m`.

## Augmentation
Since the RGH frames are constructed from inconsistent channels (colora and height), the color augmentation implemented in python libraries cannot be applyed on them. The light intencity, sharpening and bluring augmentation for the R and G channels is done by running `Main_RGHAugmentation.m`, where combination of these augmentation types multiplies the frame number by factor 11. The lists of the training frames are updated as well.

# ResNet50 training and prediction
The ResNet50 based model is trained by running `Main_Lettuce_ResNetModel_Train.py`. The model consists of the ResNet50V2 network and regression layers similar to [this example](https://www.kaggle.com/code/amanabdullayev/age-prediction-from-photo-using-cnn-resnet50/notebook). The followign training parameters are defined in the file: training dataset, training fold, epoch number, pretrained model for transfer learning. If a model is trained for a dataset fold, it is also validated by this fold. The results of the prediction are saved in `Lettuce_..._Fold..._Res.csv` files.

FW predicting model using and external validation are done by running `Main_Lettuce_ResNetModel_Predict.py`. In the file the predicting model and datasets are defined. The results of the prediction are saved in `Lettuce_Train..._Valid..._Res.csv` files.

# Performance analysis
In the `Main_Analysis_Volume.m` the FW prediction accuracy is evaluated for the volume calculating methods. The regression models are built and validated externally and by self 10 fold validation. Their robustness is evaluated. Accuracy of different surface reconstraction metods are compared (proposed Vacuum package method, Alpha sapes method, Ball pivoting method). The robustness inside a same dataset is tested. Accuracy of the FW prediction using only the top camera view and four top and side camera views is compared.

In the `Main_Analysis_ResNet.m` the FW prediction accuracy is evaluated for the ResNet based models. The models are validated externally and by self 10 fold validation. The robustness inside a same dataset is tested. Their robustness is evaluated. 

# Data folder structure
- Lettuce
  - Piikkio_2023
  - 2023_03_09_Day_23
    - 0 calibrations
        - Cam1_1.ply
        - ...
        - Cam4_4.ply
      - 1
        - Cam1.ply
        - Cam1.png
        - ...
      - ...
      - 132
    - 2023_04_04_Day_21
      - 0calibrations
      - 1
        - 20230404_120204.bag
        - ...
    - 2023_05_16_Day_21
    - CalculatedPlantVolume_All.csv
    - CalculatedPlantVolume_Top.csv
    - LettuceMassReference_2023_03_09.csv
    - LettuceMassReference_2023_04_04.csv
    - LettuceMassReference_2023_05_16.csv
  - Piikkio_2023_ResNet50_RGH
  - ResNet50_Results
  - WUR_OnlineChallenge
    - DepthImages
    - GroundTruth
    - RGBImages
  - WUR_OnlineChallenge_RGH224
