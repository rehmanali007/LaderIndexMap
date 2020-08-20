#!/bin/bash
######################
cd /home/ubuntu/API_Calls/gdalmerge/ned_tif
ls  -U  *.tiff | sort |   head -9000 > tiff9000.txt
gdal_merge.py -n -999999999999999   -o merged9000.tif  --optfile   tiff9000.txt
gdal_translate -a_nodata -999999999999999 -co COMPRESS=LZW -co JPEG_QUALITY=50 merged9000.tif merged9001.tif
rm merged9000.tif && zip merged9001.zip merged9001.tif
gdal_calc.py  -A gdal_calc.py -A merged9001.tif --outfile=merged9003.tif --calc="300*=A>0)" --NoDataValue=0
rm merged9001.tif && zip merged9003.zip merged9003.tif

gdalwarp  -t_srs EPSG:3857 -tr 300 300 -overwrite  merged9003.tif merged9004.tif
rm merged9004.zip merged9004.tif
rm merged9003.tif
gdal_translate -a_nodata -999999999999999 -co COMPRESS=LZW -co JPEG_QUALITY=50 merged9004.tif ../merged9005.tif
rm merged9004.tif
cd /home/ubuntu/API_Calls/gdalmerge/


# I want to loop these command below.


1 Maine.tif       Maine_17.tif         17
2 Deleware.tif 	  Connecticut_06.tif    6
3 Deleware.tif    Deleware_07.tif       7
4 Maryland.tif    Maryland_18.tif      18 
5 NewYork.tif     NewYork_30.tif       30
6 Iowa.tif        Iowa_13.tif          13

gdal_calc.py -A gdal_calc.py \  # This is an inline Bash comment
	     --NoDataValue=0 \
	     --outfile=F_temp.tif \
	     -A Iowa.tif          \
             --calc="13*(A>0)"

gdalwarp     -tr 300 300 
             -dstnodata 0 
             -te -13887126.77 2814162.483 -7430226.771 6360162.483 
             -t_srs EPSG:3857 
             -overwrite 
             -r bilinear  
             F_temp.tif  
             G_temp.tif 

rm F_temp.tif

saga_cmd     grid_tools "Reclassify Grid Values" 
             -INPUT=G_temp.tif 
             -RESULT=H_temp.sdat 
             -RETAB=matrix.txt 
             -METHOD=0 
             -OLD=0.0 
             -NEW=0.0 
             -SOPERATOR=0 
             -MIN=0.0 
             -MAX=1.0 
             -RNEW=2.0 
             -ROPERATOR=0 
             -RETAB  
             -OTHEROPT=false 
             -OTHERS=0.0 


saga_cmd     io_gdal  
             "Export GeoTIFF" 
             -GRIDS=H_temp.sdat  
             -TOPERATOR=0      
             -NODATAOPT=true     
             -FILE=J_Temp.tif 

rm H_temp.* G_temp.tif 

gdal_translate -tr 300 300  
               -a_nodata 0  
               -co  COMPRESS=LZW 
               -co JPEG_QUALITY=80 
               J_Temp.tif  
               Iowa_13_.tif       
rm J_Temp.tif     



####### Ignore data below here




            























gdalwarp -tr 300 300 -srcnodata 0 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear  Maine_17.tif        o_Maine_17.tif       
gdalwarp -tr 300 300 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear  Deleware_07.tif     o_Deleware_07.tif 
gdalwarp -tr 300 300 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear  Connecticut_06.tif  o_Connecticut_06.tif 
gdalwarp -tr 300 300 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear  Maryland_18.tif     o_Maryland_18.tif 
gdalwarp -tr 300 300 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear  NewYork_30.tif      o_NewYork_30.tif
gdalwarp -tr 300 300 -dstnodata 0 -te -13887126.77 2814162.483 -7430226.771 6360162.483 -t_srs EPSG:3857 -overwrite -r bilinear  Iowa_13.tif         o_Iowa_13.tif
zip o_states.zip o_Maine_17.tif o_Deleware_07.tif o_Connecticut_06.tif o_Maryland_18.tif o_NewYork_30.tif o_Iowa_13.tif
rm n_*.tif

gdal_translate -a_nodata 0 -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 o_Maine_17.tif         p_Maine_17_.tif 
gdal_translate -a_nodata 0 -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 o_Deleware_07.tif      p_Deleware_07_.tif 
gdal_translate -a_nodata 0 -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 o_Connecticut_06.tif   p_Connecticut_06_.tif
gdal_translate -a_nodata 0 -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 o_Maryland_18.tif      p_Maryland_18_.tif
gdal_translate -a_nodata 0 -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 o_NewYork_30.tif       p_NewYork_30_.tif
gdal_translate -a_nodata 0 -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 o_Iowa_13.tif          p_Iowa_13_.tif

zip p_states.zip p_Maine_17_.tif p_Deleware_07_.tif p_Connecticut_06_.tif p_Maryland_18_.tif p_NewYork_30_.tif p_Iowa_13_.tif

gdal_translate -a_nodata 0.0 -of GTiff 

rm p_states o_Maine_17.tif o_Deleware_07.tif o_Connecticut_06.tif o_Maryland_18.tif o_NewYork_30.tif o_Iowa_13.tif



gdal_calc.py -A merged9005.tif -B p_Maine_17_.tif -C p_Deleware_07_.tif -D p_Connecticut_06_.tif -E p_Maryland_18_.tif -F p_NewYork_30_.tif -G p_Iowa_13_.tif --outfile=Merged_all.tif  --calc="A+B+C+D+E+F+G" 
zip merged9005.zip merged9005.tif
rm p_*.tif merged9005.tif



gdal_translate -co COMPRESS=LZW -co JPEG_QUALITY=50 Merged_all.tif Merged_all2.tif

rm Merged_all.tif
zip Merged_all2.zip Merged_all2.tif



-RETAB=matrix.txt

saga_cmd grid_tools "Reclassify Grid Values" -INPUT=p_Maine_17.tif -MAX=1 -METHOD=0 -MIN=0 -NEW=1 -NODATA=0 -NODATAOPT=True -OLD=0 -OTHEROPT=False -OTHERS=0 -RESULT=p_Maine_17.sdat  -RNEW=2 -ROPERATOR=0 -SOPERATOR=0 -TOPERATOR=0 



gdal_calc.py -A gdal_calc.py -A Iowa.tif       --NoDataValue=0 --outfile=G_temp.tif          --calc="13*=A>0)"  
saga_cmd grid_tools "Reclassify Grid Values" -INPUT=G_temp.tif     \
	-RESULT=H_temp.sdat -RETAB=matrix.txt -METHOD=0 -OLD=0.0 -NEW=1.0 -SOPERATOR=0 -MIN=0.0 -MAX=1.0 -RNEW=2.0 -ROPERATOR=0 -RETAB  \
	-TOPERATOR=0 -NODATAOPT=true -NODATA=0.0 -OTHEROPT=false -OTHERS=0.0   
saga_cmd io_gdal  "Export GeoTIFF" -GRIDS=H_temp.sdat -FILE=J_Temp.tif &&rm H_temp.sdat
gdal_translate  -tr 300 300 -co  COMPRESS=LZW -co JPEG_QUALITY=80 J_Temp.tif s_Iowa_13_.tif
rm J_Temp.tif
zip s_Iowa_13_.zip s_Iowa_13_.tif
rm s_Iowa_13_.tif




grid_tools "Reclassify Grid Values" 





saga_cmd io_gdal 0 -TRANSFORM 1 -RESAMPLING 3 -GRIDS=TEXT.sgrd -FILES=n_Maine_17.tif
	 -TOPERATOR=0 -NODATAOPT=true -NODATA=0.0 -OTHEROPT=true -OTHERS=0.0 -RESULT=q_Maine_17.sdat
saga_cmd io_gdal  "Export GeoTIFF" -GRIDS=q_Maine_17.sdat -FILE=q_Maine_17.tif


saga_cmd grid_tools "Reclassify Grid Values" -INPUT=p_Maine_17.tif -RESULT=q_Maine_17.sdat 





















saga_cmd reclassify_values -INPUT o_Maine_17.tif', 'MAX' : 1, 'METHOD' : 0, 'MIN' : 0, 'NEW' : 1, 'NODATA' : 0, 'NODATAOPT ' : True, 'OLD' : 0, 'OTHEROPT ' : False, 'OTHERS' : 0, 'RESULT' : 'C:'q_Maine_17.tif', 'RETAB' : [0,0,0,0,0,0,0,0,0], 'RNEW' : 2, 'ROPERATOR' : 0, 'SOPERATOR' : 0, 'TOPERATOR' : 0 


saga_cmd grid_tools 15 -INPUT:o_Maine_17.tif -MAX: 1 -METHOD 0 -MIN: 0 -NEW: 1 -NODATA: 0 -NODATAOPT: True -OLD: 0 -OTHEROPT: False -OTHERS: 0 -RESULT: q_Maine_17.tif -RNEW: 2 -ROPERATOR: 0 -SOPERATOR: 0 -TOPERATOR: 0 
