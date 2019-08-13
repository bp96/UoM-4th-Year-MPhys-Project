--[[Program Goals:
1. Find Dixon image using file size.
2. Load in MR1 (DCM) image to wm. 
3. Create .nii file of scan data and output filename indicating Dixon.
4. Create .nii file of scan data and output filename indicating t2.
5. Load in RS1 (DCM) and create a binary mask.
    -- this part can be adjusted to include different delineations -> I.e. put in the choice. 
6. Create .nii file of Binary Mask and again, output correct Mask filename.
7. Loop over Steps 1-6 for Folders in directory: C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\MPhys Cervix Radiomics
]]

--[[ ** Typical errors:
  
  1. Error line 149: "attempt to concatenate field '?' (a nil value)
    Resolution: Change filesize bounds as described to get all t2 DCM files throughout visit directories.
  
** ]]

local startTime = os.time() -- Record start time

-- [[ Variables ]]

local patientDirectory = [[C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\MPhys Cervix Radiomics\848137892]]
local structCount = 0 -- Set to 0 for Dixon Structure, 1 for t2

-- Dixon Scan
local GTV_NP0, GTV_NM1, GTV_NP1, GTV_NP2, GTV_NP3 = false, false, false, false, false -- GTV_N
local GTV_N1P0, GTV_N1M1, GTV_N1P1, GTV_N1P2, GTV_N1P3 =  false, false, false, false, false-- GTV_N1
local GTV_N2P0, GTV_N2M1, GTV_N2P1, GTV_N2P2, GTV_N2P3 = false, false, false, false, false -- GTV_N2
local GTV_N3P0, GTV_N3M1, GTV_N3P1, GTV_N3P2, GTV_N3P3 = false, false, false, false, false -- GTV_N3
local GTV_N4P0, GTV_N4M1, GTV_N4P1, GTV_N4P2, GTV_N4P3 = false, false, false, false, false -- GTV_N4
local CTV_EP0, CTV_EM1, CTV_EP1, CTV_EP2, CTV_EP3 = true, true, true, true, true -- CTV_E
local CTV_NP0, CTV_NM1, CTV_NP1, CTV_NP2, CTV_NP3 = false, false, false, false, false -- CTV_N
local CTV_N1P0, CTV_N1M1, CTV_N1P1, CTV_N1P2, CTV_N1P3 = false, false, false, false, false -- CTV_N1
local CTV_N2P0, CTV_N2M1, CTV_N2P1, CTV_N2P2, CTV_N2P3 = false, false, false, false, false -- CTV_N2
local CTV_N3P0, CTV_N3M1, CTV_N3P1, CTV_N3P2, CTV_N3P3 = false, false, false, false, false -- CTV_N3
local CTV_N4P0, CTV_N4M1, CTV_N4P1, CTV_N4P2, CTV_N4P3 = false, false, false, false, false -- CTV_N4
local RECTUM, SIGMOID, BOWEL = false, false, false -- Other normal-tissue delineations
local RECTBOUNDARYP0, RECTBOUNDARYM1, RECTBOUNDARYP1, RECTBOUNDARYP2, RECTBOUNDARYP3 = false, false, false, false, false -- rectum boundary
-- t2 Scan
local GTV_TP0, GTV_TM1, GTV_TP1, GTV_TP2, GTV_TP3 = true, true, true, true, true -- GTV_T
local CTV_HRP0, CTV_HRM1, CTV_HRP1, CTV_HRP2, CTV_HRP3 = true, true, true, true, true -- CTV_HR
local CTV_IRP0, CTV_IRM1, CTV_IRP1, CTV_IRP2, CTV_IRP3 = true, true, true, true, true -- CTV_IR
local CTV_LRP0, CTV_LRM1, CTV_LRP1, CTV_LRP2, CTV_LRP3 = false, false, false, false, false -- CTV_LR

-- [[ Functions ]]

-- Returns amount of bits in file
function getFileSize(filename)
    local fp = io.open( filename )
    if fp == nil then 
 	return nil 
    end
    local filesize = fp:seek( "end" )
    fp:close()
    return filesize
end

-- Scan directory names and put into list t, additionally creates list of file sizes in directory (y), parallel to the list t.
function scandir(directory)
    local i, t, y, popen = 0, {}, {}, io.popen
    
    --loop starts at the bottom of the directory and works up.
    for filename in popen('dir "'..directory..'" /o:n /b'):lines() do
        i = i + 1

        t[i] = filename
        y[i] = getFileSize(directory.."\\"..filename)

    end
    return t, y
    
end

-- create lists for filenames and filesizes of Patient Directory
r, e = {}, {}
r, e = scandir(patientDirectory)

for j = 1, #r, 1 do -- j is the index of the folder in patientDirectory (i.e. j=1 corresponds to the folder: visit1_end)
  
  print("\n"..j.." of "..#r.."\n")
  print("Scanning visit folder: "..r[j] )
  
  -- declare visitDirectory
  local visitDirectory = patientDirectory.."\\"..r[j]
  -- declare Index variables
  local dixonIndex = 0
  local t2Index = 0 
  local dstructIndex = 0
  local tstructIndex = 0
  
  -- create lists for filenames and filesizes of files within visit Directory
  t, y = {}, {} -- t: list of filenames. y: list of filesizes.
  t, y = scandir(visitDirectory)
  
  -- list for RS1 files
  rs1ListIndex = {}

  -- [[ Find index for first Dixon and t2 files along with their respective structure files. N.B: Default Dixon fileSize should be ~ 354KB whilst T2 is ~ 203KB. ]]
  -- when read in, the list y is ordered by filesize. (N.B: filesize of t2 in visit4 folders is ~ 75KB)
  
  k = 1
  for i = 1, #y, 1 do -- Dixon files & Structure files
    if y[i] > 343000 and y[i] < 365000 and dixonIndex == 0 then
      dixonIndex = i
      --print(dixonIndex)
    end
    if string.match(t[i],"RS1") then
      rs1ListIndex[k] = i
      k = k + 1
    end
  end
  
  -- Assign larger and smaller of RS1 file index to Dixon and t2 structure indices respectively
  -- The outermost loop will check if rs1ListIndex[2] exists. If it doesn't then assign the one RS1 file index to the t2 structure index (for patient 196817750).
  
  if (y[rs1ListIndex[1]] ~= nil) and (y[rs1ListIndex[2]] ~= nil) then
    if (y[rs1ListIndex[1]]>y[rs1ListIndex[2]]) then
      dstructIndex = rs1ListIndex[1]
      tstructIndex = rs1ListIndex[2]
      --print(dstructIndex)
      --print(tstructIndex)
    else
      dstructIndex = rs1ListIndex[2]
      tstructIndex = rs1ListIndex[1]
      --print(dstructIndex)
      --print(tstructIndex)
    end
  else
      tstructIndex = rs1ListIndex[1]
  end
  
  -- For this loop, manually change the t2 DCM filesize criteria for each patient! (change orange bounds).
  
  if j < 9 then -- t2 files 
    for i = 1, #y, 1 do
      if y[i] > 192000 and y[i] < 214000 and t2Index == 0 then
        t2Index = i
        --print(t2Index)
        break
      end
    end 
  else
    for i = 1, #y, 1 do
      if y[i] > 64000 and y[i] < 86000 and t2Index == 0 then
        t2Index = i
        --print(t2Index)
        break
      end
    end
  end
  
  -- [[ Clear any current scans ]]

  for i = 1, 6, 1 do
    wm.Scan[i]:clear()
  end

  -- [[ Load in MR1 image and structure for requested scan ]]
  
  if structCount == 0 then
    wm.Scan[1]:load("DCM:"..visitDirectory.."\\"..t[dixonIndex])
    wm.Scan[1]:write_nifty(visitDirectory.."\\".."DIXON_visit".. string.match(visitDirectory, "visit(.*)")..".nii")
  elseif structCount == 1 then
    wm.Scan[1]:load("DCM:"..visitDirectory.."\\"..t[t2Index])
    wm.Scan[1]:write_nifty(visitDirectory.."\\".."t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
  end

  --[[ Scan over visit directory and create chosen Masks + export as .nii]]

  -- create masks for chosen delineations (dependent on which structure file) 
  if (structCount == 0) and (t[dstructIndex] ~= nil) then -- for first structure file
    wm.Delineation:load("DCM:"..visitDirectory.."\\"..t[dstructIndex], wm.Scan[1]) -- load structure file for Dixon  
    if BOWEL == true and (wm.Delineation.Bowel ~= nil or wm.Delineation.bowel ~= nil) then
      print('Extracting BOWEL Data...')
      if not wm.Delineation.Bowel then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.bowel, 1)
      elseif not wm.Delineation.bowel then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.Bowel, 1)
      end
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."BowelMask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
    end
    if RECTBOUNDARYP0 == true and (wm.Delineation.rectum ~= nil or wm.Delineation.Rectum ~= nil) then
      print('Extracting RECTUM Data...')
      if not wm.Delineation.Rectum then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.rectum, 1)
        if RECTBOUNDARYM1 == true then 
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[4] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.1) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4].Data:expand(-0.05)
          wm.Scan[4] = wm.Scan[4]/wm.Scan[4].Data:max()
          wm.Scan[5] = wm.Scan[3] - wm.Scan[4]
          wm.Scan[5]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryM1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP0 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.26) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP1 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.1) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP2 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.2) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP3 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.3) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
      elseif not wm.Delineation.rectum then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.Rectum, 1)
        if RECTBOUNDARYM1 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[4] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.1) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4].Data:expand(-0.05)
          wm.Scan[4] = wm.Scan[4]/wm.Scan[4].Data:max()
          wm.Scan[5] = wm.Scan[3] - wm.Scan[4]
          wm.Scan[5]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryM1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP0 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.26) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP1 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.1) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP2 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.2) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if RECTBOUNDARYP3 == true then
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.3) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[4] = wm.Scan[3] - wm.Scan[2]
          wm.Scan[4]:write_nifty(visitDirectory.."\\".."Rectum_BoundaryP3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
      end
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."RectumMask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
    end
    if SIGMOID == true and (wm.Delineation.sigmoid ~= nil or wm.Delineation.Sigmoid ~= nil) then
      print('Extracting Sigmoid Data...')
      if not wm.Delineation.Sigmoid then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.sigmoid, 1)
      elseif not wm.Delineation.sigmoid then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.Sigmoid, 1)
      end
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."SigmoidMask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
    end
    if CTV_NP0 == true and (wm.Delineation["CTV-N"] ~= nil) then
      print('Extracting CTV_N Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-N"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_NP0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_NP1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_NP1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_NP2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_NP2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_NP3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_NP3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_NM1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_NM1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_N1P0 == true and (wm.Delineation["CTV-N1"] ~= nil) then
      print('Extracting CTV_N1 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-N1"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_N1P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_N1P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N1P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N1P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N1P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N1P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N1P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N1M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N1M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_N2P0 == true and (wm.Delineation["CTV-N2"] ~= nil) then
      print('Extracting CTV_N2 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-N2"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_N2P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_N2P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N2P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N2P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N2P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N2P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N2P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N2M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N2M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_N3P0 == true and (wm.Delineation["CTV-N3"] ~= nil) then
      print('Extracting CTV_N3 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-N3"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_N3P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_N3P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N3P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N3P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N3P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N3P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N3P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N3M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N3M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_N4P0 == true and (wm.Delineation["CTV-N4"] ~= nil) then
      print('Extracting CTV_N4 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-N4"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_N4P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_N4P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N4P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N4P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N4P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N4P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N4P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_N4M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_N4M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_EP0 == true and (wm.Delineation.CTVE ~= nil or wm.Delineation["CTV-E"] ~= nil) then
      print('Extracting CTV_E Data...')
      if not wm.Delineation["CTV-E"] then
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation.CTVE, 1)
        wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_EP0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        if CTV_EP1 == true then -- expand mask by 1 voxel and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.1) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EP1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if CTV_EP2 == true then -- expand mask by 2 voxels and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.2) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EP2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if CTV_EP3 == true then -- expand mask by 3 voxels and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.3) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EP3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if CTV_EM1 == true then -- reduce mask by 1 voxel and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(-0.05) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EM1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
      else
        wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-E"], 1)
        wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_EP0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        if CTV_EP1 == true then -- expand mask by 1 voxel and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.1) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EP1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if CTV_EP2 == true then -- expand mask by 2 voxels and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.2) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EP2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if CTV_EP3 == true then -- expand mask by 3 voxels and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(0.3) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EP3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
        if CTV_EM1 == true then -- reduce mask by 1 voxel and write nifty
          wm.Scan[3] = wm.Scan[2]
          wm.Scan[3].Data:expand(-0.05) 
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
          wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_EM1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
        end
      end
    end
    if GTV_NP0 == true and (wm.Delineation["GTV-N"] ~= nil) then
      print('Extracting GTV_N Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["GTV-N"], 1) -- burn delineation as is and hold this in scan 2
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."GTV_NP0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii") -- write nifty
      if GTV_NP1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_NP1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_NP2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_NP2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_NP3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_NP3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_NM1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_NM1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end    
    end
    if GTV_N1P0 == true and (wm.Delineation["GTV-N1"] ~= nil) then
      print('Extracting GTV_N1 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["GTV-N1"], 1) -- burn delineation as is and hold this in scan 2
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."GTV_N1P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii") -- write nifty
      if GTV_N1P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N1P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N1P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N1P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N1P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N1P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N1M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        if (j ~= 7) then -- problem in wm causing error with zero-value GTV-N2 Mask (adjust j for any similar problems in different visits)
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        end
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N1M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end    
    end
    if GTV_N2P0 == true and (wm.Delineation["GTV-N2"] ~= nil) then
      print('Extracting GTV_N2 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["GTV-N2"], 1) -- burn delineation as is and hold this in scan 2
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."GTV_N2P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii") -- write nifty
      if GTV_N2P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N2P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N2P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N2P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N2P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N2P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N2M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05)
        if (j ~= 3) then -- problem in wm causing error with zero-value GTV-N2 Mask (adjust j for any similar problems in different visits)
          wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        end
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N2M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end    
    end
    if GTV_N3P0 == true and (wm.Delineation["GTV-N3"] ~= nil) then
      print('Extracting GTV_N3 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["GTV-N3"], 1) -- burn delineation as is and hold this in scan 2
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."GTV_N3P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii") -- write nifty
      if GTV_N3P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N3P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N3P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N3P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N3P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N3P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N3M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N3M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end    
    end
    if GTV_N4P0 == true and (wm.Delineation["GTV-N4"] ~= nil) then
      print('Extracting GTV_N4 Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["GTV-N4"], 1) -- burn delineation as is and hold this in scan 2
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."GTV_N4P0_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii") -- write nifty
      if GTV_N4P1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N4P1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N4P2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N4P2_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N4P3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N4P3_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_N4M1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_N4M1_Mask_DIXON_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end    
    end
  elseif (structCount == 1) and (t[tstructIndex] ~= nil) then -- for second structure file
    wm.Delineation:load("DCM:"..visitDirectory.."\\"..t[tstructIndex], wm.Scan[1]) -- load structure file for t2 
    if CTV_HRP0 == true and (wm.Delineation["CTV-HR"] ~= nil) then
      print('Extracting CTV_HR Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-HR"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_HRP0_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_HRP1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_HRP1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_HRP2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_HRP2_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_HRP3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_HRP3_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_HRM1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_HRM1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_IRP0 == true and (wm.Delineation["CTV-IR"] ~= nil) then
      print('Extracting CTV_IR Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-IR"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_IRP0_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_IRP1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_IRP1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_IRP2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_IRP2_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_IRP3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_IRP3_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_IRM1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_IRM1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if CTV_LRP0 == true and (wm.Delineation["CTV-LR"] ~= nil) then
      print('Extracting CTV_LR Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["CTV-LR"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."CTV_LRP0_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if CTV_LRP1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_LRP1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_LRP2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_LRP2_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_LRP3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_LRP3_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if CTV_LRM1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."CTV_LRM1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
    end
    if GTV_TP0 == true and (wm.Delineation["GTV-T"] ~= nil) then
      print('Extracting GTV_T Data...')
      wm.Scan[2] = wm.Scan[1]:burn(wm.Delineation["GTV-T"], 1)
      wm.Scan[2]:write_nifty(visitDirectory.."\\".."GTV_TP0_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      if GTV_TP1 == true then -- expand mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.1) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_TP1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_TP2 == true then -- expand mask by 2 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.2) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_TP2_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_TP3 == true then -- expand mask by 3 voxels and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(0.3) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_TP3_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end
      if GTV_TM1 == true then -- reduce mask by 1 voxel and write nifty
        wm.Scan[3] = wm.Scan[2]
        wm.Scan[3].Data:expand(-0.05) 
        wm.Scan[3] = wm.Scan[3]/wm.Scan[3].Data:max()
        wm.Scan[3]:write_nifty(visitDirectory.."\\".."GTV_TM1_Mask_t2_visit"..string.match(visitDirectory, "visit(.*)")..".nii")
      end   
    end
  end
  
  if j == #r then
    print("NIfTI extraction complete.")
  end

end

print("\nTime taken: "..(os.time()-startTime).."s")
