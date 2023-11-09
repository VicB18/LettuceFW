# LettuceFW
Estimation of the lettuce fresh weight during growing based on 3D imaging.
# Data folder structure
- Lettuce
  - Piikkio_2023
  - 2023_03_09_Day_23
    - 0 calibrations
        - Cam1_1.ply
        - ...
        - Cam4_4.ply
      - 1
        -Cam1.ply
        -Cam1.png
        ...
      ...
      -132
    -2023_04_04_Day_21
      -0calibrations
      -1
        -20230404_120204.bag
        -...
    -2023_05_16_Day_21
    -CalculatedPlantVolume_All.csv
    -CalculatedPlantVolume_Top.csv
    -LettuceMassReference_2023_03_09.csv
    -LettuceMassReference_2023_04_04.csv
    -LettuceMassReference_2023_05_16.csv
  -Piikkio_2023_ResNet50_RGH
  -ResNet50_Results
  -WUR_OnlineChallenge
    DepthImages
    GroundTruth
    RGBImages
  WUR_OnlineChallenge_RGH224

# Raw data preparation
All data folders contain point clouds in `.ply` format and RGB images in `.png` format which represent one RGBD frame recorded by 3D RealSence D405 cameras. In the folder `2023_03_09_Day_23` the frames were saved by the cameras to `.ply` and `.png` files. In the folders `2023_04_04_Day_21` and `2023_05_16_Day_21` the frames were extracted from the `.bag` video recorded by the cameras, when the first video frame was extracted from each video. (To process `.bag` videos and extract `.ply` point clouds and RGB images, run `Main_Bag2Ply.m`. [RealSense SDK](https://www.intelrealsense.com/sdk-2/) must be installed.)

The RGBD frames of the **3rd Autonomous Greenhouse Challenge: Online Challenge Lettuce Images** [Hemming et al., 2022](https://data.4tu.nl/articles/_/15023088/1) were extracted to the folder `WUR_OnlineChallenge`.
