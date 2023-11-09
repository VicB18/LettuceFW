# LettuceFW
Estimation of the lettuce fresh weight during growing based on 3D imaging.
# Data folder structure

- j
- g
- f

Lettuce
  Piikkio_2023
  2023_03_09_Day_23
    0 calibrations
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
In the Pii dataset the RGBD data is collected in .ply format at the folder `2023_03_09_Day_23` and in .bag format at the folders `2023_04_04_Day_21` and `2023_05_16_Day_21`.
