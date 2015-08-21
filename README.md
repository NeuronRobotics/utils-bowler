# utils-bowler
Utilities for working with the DyIO and other Bowler devices

To publish a release of the Bowler system you use the script 

https://github.com/NeuronRobotics/utils-bowler/blob/master/publish/archive/publish.sh

First you cd into the directory:

 cd utils-bowler/publish/archive/
 
Then tag a version in each repositor. For this example we will use the numbers below:

 BowlerStudio (0.4.4)
 
 DyIO (3.14.4)
 
 java-bowler (3.14.11)
 
In BowlerStudio Github Repository, you next create a release with the tag you just created. This will be where the script uploads the files

with the tags and release created, the rest of the steps are automatic, run:

 bash publish.sh 3.14.11 0.4.4 3.14.4
 
 Which means:
 
  bash publish.sh <java-bowler tag numbeer> <BowlerStudio tag number> <DyIO tag number>
  
It will prompt you to install dependancies and dowmload zip files of the binaries we bundle (openCV and Slic3r for example) from:

 https://github.com/NeuronRobotics/ZipArchive/releases

