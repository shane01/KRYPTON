#!/bin/bash
export ARCH=arm
export CROSS_COMPILE=~/Android/KRYPTON/arm-eabi-4.9-sm/bin/arm-eabi-
echo "Clean directories? y/n"
read instruct
if [ "$instruct" = "y" ]
then
echo "Wait" 
make clean 
echo "Done"
fi

if [ -e "./arch/arm/boot/dt.img" ]; then
rm ./arch/arm/boot/dt.img
fi
if [ -e "./arch/arm/boot/msm8226-v1-jagnm.dtb" ]; then
rm ./arch/arm/boot/msm8226-v1-jagnm.dtb
rm ./arch/arm/boot/msm8226-v2-jagnm.dtb
fi

echo "Make new defconfig? y/n" 
read defconfig
if [ "$defconfig" = "y" ]
then
ARCH=arm CROSS_COMPILE=~/arm-eabi-4.9-sm/bin/arm-eabi- make jagnm_cyanogenmod_defconfig
fi

echo "Configure kernel? y/n"
read config
if [ "$config" = "y" ]
then 
make ARCH=arm CROSS_COMPILE=~/arm-eabi-4.9-sm/bin/arm-eabi- menuconfig 
fi
echo "Build kernel? y/n"
read build
if [ "$build" = "y" ]
then 
make -j4
fi

echo "Make flashable zip? y/n"
read zip
if [ "$zip" = "y" ]
then

./dtbToolCM -2 -s 2048 -p ./scripts/dtc/ -o ./arch/arm/boot/dt.img ./arch/arm/boot/
echo "Copying files to respective folder"

		cd ./RAMDISK/D722/
		./cleanup.sh
		./unpackimg.sh boot.img
		cp ../boot.img-ramdiskcomp ./split_img/boot.img-ramdiskcomp
		cp ../fstab.qcom ./ramdisk/fstab.qcom
		cp ../../arch/arm/boot/zImage ./split_img/boot.img-zImage
                cp ../../arch/arm/boot/dt.img ./split_img/boot.img-dtb
		echo "Repacking Kernel"
		./repackimg.sh
		echo "Signing Kernel"
		./bump.py image-new.img
                cd ../../
		echo "Moving Kernel to output folder"
		mv ./RAMDISK/D722/image-new_bumped.img ./Output/D722.img



echo "Copying image to root of unzipped directory renaming it boot."

        cp ./Output/D722.img ./Output/KRYPTON/boot.img
	
echo "Changing the directory to root of KRYPTON directory."
    cd ./Output/KRYPTON
echo "Creating flashable zip."
zip -r KRYPTONKernel-$(date +%F).zip . -x ".*"

    echo "Moving zipped file to output folder."

    mv *.zip  ../../Release
echo " Kernel is found at Release folder"
fi


