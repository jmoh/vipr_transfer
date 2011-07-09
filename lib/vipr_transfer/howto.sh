# If there is a VIPR scan, it will be stored on cn6.
# Note: cn0 and cn6 require the "old" hospital password.
# Shell onto cn0 via miho.
ssh raw@miho
ssh sterling@cn0
# Navigate to the CLINICAL directory and list contents to verify the correct files are present.
cd /data/data_flow/CLINICAL_IN
ls
# Note the name of the VIPR directory to be transferred. Typically, the files are named with the format: <YYMMDD>_E<exam#>_S####
# Copy the directory to /data/sterling with the following naming convention: <YYMMDD>_E<exam#>_<subjID>
cp -r <YYMMDD>_E<exam#>_S#### /data/sterling/<YYMMDD>_E<exam#>_<subjID>
# Navigate to the directory just copied into /data/sterling.
cd /data/sterling/<YYMMDD>_E<exam#>_<subjID>
# Zip the P-file.
bzip2 P#####.#
# Exit from cn0.
exit
# You should now be back to raw@miho. Navigate to the appropriate raw directory.
cd /Data/vtrak1/raw/<study_protocol>/<subjID>_<exam#>_<MMDDYYYY>
# Make a new directory called "vipr" and go into it.
mkdir vipr
cd vipr
# Copy over the data.
scp -r sterling@cn0:/data/sterling/<subjID>_<exam#>_<MMDDYYYY> .