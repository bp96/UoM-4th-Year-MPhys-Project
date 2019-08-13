% Script to import patient Mask .csv data and collate it into the following
% Column structure: Featurename ; visit 1 start ; visit 1 end ; 
% visit 2 start ; visit 2 end ...
% N.B: *** Make sure current working directory is the PATIENT directory 
% before running script! ***
% I.e. "C:\Users\Harry\Documents\University\4th_Year\MPhys_Project\MPhys
% Cervix Radiomics\196817750" for example.

clear all; % Clears all variables in Workspace
close all; % Closes all figures
format long; % Formats long decimals

% Mask variables
% Resulting concatenated cells will be labelled A1 for GTV_N, A2 for
% GTV_N1... mirroring the variables below.
% Choose necessary delineations for generated patient .csvs:

A1v = {1}; % set = 1 for GTV_N 
A2v = {0}; % set = 1 for GTV_N1
A3v = {0}; % set = 1 for GTV_N2
A4v = {0}; % set = 1 for GTV_N3
A5v = {0}; % set = 1 for GTV_N4
A6v = {1}; % set = 1 for CTV_N
A7v = {0}; % set = 1 for CTV_N1
A8v = {0}; % set = 1 for CTV_N2
A9v = {0}; % set = 1 for CTV_N3
A10v = {0}; % set = 1 for CTV_N4
A11v = {1}; % set = 1 for CTV_E
A12v = {0}; % set = 1 for RECTUM
A13v = {1}; % set = 1 for RECTUM_BOUNDARY
A14v = {1}; % set = 1 for GTV_T
A15v = {1}; % set = 1 for CTV_HR
A16v = {1}; % set = 1 for CTV_IR
A17v = {0}; % set = 1 for CTV_LR

% remembers patient directory
patientDirectory = pwd;

% Read the patient directory subfolder info into a Structure array
patientVisitStruct = dir; 

% Create a blank row cell with dimensions equal to the # of visits 
patientVisits = cell(1,(length(patientVisitStruct)-2));

% Occupy patientVisits cell with subfolder names
for i = 3:length(patientVisitStruct)
   
    patientVisits{1,(i-2)} = patientVisitStruct(i).name;
    
end

% Creates first column with all Radiomics featurenames
M = [{'Feature Name:'};'original_shape_Elongation';'original_shape_Flatness';'original_shape_LeastAxis';'original_shape_MajorAxis';'original_shape_Maximum2DDiameterColumn';'original_shape_Maximum2DDiameterRow';'original_shape_Maximum2DDiameterSlice';'original_shape_Maximum3DDiameter';'original_shape_MinorAxis';'original_shape_Sphericity';'original_shape_SurfaceArea';'original_shape_SurfaceVolumeRatio';'original_shape_Volume';'original_firstorder_10Percentile';'original_firstorder_90Percentile';'original_firstorder_Energy';'original_firstorder_Entropy';'original_firstorder_InterquartileRange';'original_firstorder_Kurtosis';'original_firstorder_Maximum';'original_firstorder_MeanAbsoluteDeviation';'original_firstorder_Mean';'original_firstorder_Median';'original_firstorder_Minimum';'original_firstorder_Range';'original_firstorder_RobustMeanAbsoluteDeviation';'original_firstorder_RootMeanSquared';'original_firstorder_Skewness';'original_firstorder_TotalEnergy';'original_firstorder_Uniformity';'original_firstorder_Variance';'original_glcm_Autocorrelation';'original_glcm_ClusterProminence';'original_glcm_ClusterShade';'original_glcm_ClusterTendency';'original_glcm_Contrast';'original_glcm_Correlation';'original_glcm_DifferenceAverage';'original_glcm_DifferenceEntropy';'original_glcm_DifferenceVariance';'original_glcm_Id';'original_glcm_Idm';'original_glcm_Idmn';'original_glcm_Idn';'original_glcm_Imc1';'original_glcm_Imc2';'original_glcm_InverseVariance';'original_glcm_JointAverage';'original_glcm_JointEnergy';'original_glcm_JointEntropy';'original_glcm_MaximumProbability';'original_glcm_SumAverage';'original_glcm_SumEntropy';'original_glcm_SumSquares';'original_gldm_DependenceEntropy';'original_gldm_DependenceNonUniformity';'original_gldm_DependenceNonUniformityNormalized';'original_gldm_DependenceVariance';'original_gldm_GrayLevelNonUniformity';'original_gldm_GrayLevelVariance';'original_gldm_HighGrayLevelEmphasis';'original_gldm_LargeDependenceEmphasis';'original_gldm_LargeDependenceHighGrayLevelEmphasis';'original_gldm_LargeDependenceLowGrayLevelEmphasis';'original_gldm_LowGrayLevelEmphasis';'original_gldm_SmallDependenceEmphasis';'original_gldm_SmallDependenceHighGrayLevelEmphasis';'original_gldm_SmallDependenceLowGrayLevelEmphasis';'original_glrlm_GrayLevelNonUniformity';'original_glrlm_GrayLevelNonUniformityNormalized';'original_glrlm_GrayLevelVariance';'original_glrlm_HighGrayLevelRunEmphasis';'original_glrlm_LongRunEmphasis';'original_glrlm_LongRunHighGrayLevelEmphasis';'original_glrlm_LongRunLowGrayLevelEmphasis';'original_glrlm_LowGrayLevelRunEmphasis';'original_glrlm_RunEntropy';'original_glrlm_RunLengthNonUniformity';'original_glrlm_RunLengthNonUniformityNormalized';'original_glrlm_RunPercentage';'original_glrlm_RunVariance';'original_glrlm_ShortRunEmphasis';'original_glrlm_ShortRunHighGrayLevelEmphasis';'original_glrlm_ShortRunLowGrayLevelEmphasis';'original_glszm_GrayLevelNonUniformity';'original_glszm_GrayLevelNonUniformityNormalized';'original_glszm_GrayLevelVariance';'original_glszm_HighGrayLevelZoneEmphasis';'original_glszm_LargeAreaEmphasis';'original_glszm_LargeAreaHighGrayLevelEmphasis';'original_glszm_LargeAreaLowGrayLevelEmphasis';'original_glszm_LowGrayLevelZoneEmphasis';'original_glszm_SizeZoneNonUniformity';'original_glszm_SizeZoneNonUniformityNormalized';'original_glszm_SmallAreaEmphasis';'original_glszm_SmallAreaHighGrayLevelEmphasis';'original_glszm_SmallAreaLowGrayLevelEmphasis';'original_glszm_ZoneEntropy';'original_glszm_ZonePercentage';'original_glszm_ZoneVariance';'original_ngtdm_Busyness';'original_ngtdm_Coarseness';'original_ngtdm_Complexity';'original_ngtdm_Contrast';'original_ngtdm_Strength'];

% Repeat feature names 5 times for expansions about delineations M1, P0,
% P1, P2, P3
M = [M ; M(2:end,1) ; M(2:end,1) ; M(2:end,1) ; M(2:end,1)];

% Set as first column of concatenated Mask cells
CTV_LR = M; CTV_IR = CTV_LR; CTV_HR = CTV_IR; GTV_T = CTV_HR; RECTUM_BOUNDARY = GTV_T; RECTUM = RECTUM_BOUNDARY; CTV_E = RECTUM; CTV_N4 = CTV_E; CTV_N3 = CTV_N4; CTV_N2 = CTV_N3; CTV_N1 = CTV_N2; CTV_N = CTV_N1; GTV_N4 = CTV_N; GTV_N3 = GTV_N4; GTV_N2 = GTV_N3; GTV_N1 = GTV_N2; GTV_N = GTV_N1;

% Create loop over all patient visit names
for i = 1:length(patientVisits)
    

    
    % Clear csvList & csvListNames befor each visit
    csvList = {};
    csvListNames = {};
    
    % Directory of visit i in patientVisits
    visitDirectory = char(strcat(pwd,{'\'},patientVisits{i}));
    
    % Change directory to visit directory
    cd(visitDirectory);
    
    % Within visit dir, create list of all .csv files *****NOT SURE IF THIS
    % WILL WORK FOR THE RECTUM MASKS AS THEY'RE NOT OF THE FORM GTV_T_ -
    % INSTEAD, THEY WILL REQUIRE "ans(1)" IN THE CODE BELOW.***** - FIXED
    % 15/12/2018
    csvListStruct = dir('*csv');
    for j = 1:length(csvListStruct)
   
        csvList{1,j} = csvListStruct(j).name;
        l = strfind(csvList{j},'_');
        csvListNames{1,j} = csvList{j}(1:l(2));
    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create cell arrays for each requested mask variables 
    if isequal(A1v{1},1) && isequal(any(strcmp(csvListNames,'GTV_NM1_')),1)
        
        % Look for index in csvList with 'GTV_NM1_'
        k = strfind(csvListNames,'GTV_NM1_');
        j = find(~cellfun(@isempty,k));
        
        % dummy name variable for mask .csv filepath
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % 'csvread(name,a,b);' reads file into array starting at row offset a and 
            % column offset b.
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'GTV_NP0_'
        k = strfind(csvListNames,'GTV_NP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        % Look for index in csvList with 'GTV_NP1_'
        k = strfind(csvListNames,'GTV_NP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        % Look for index in csvList with 'GTV_NP2_'
        k = strfind(csvListNames,'GTV_NP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        % Look for index in csvList with 'GTV_NP3_'
        k = strfind(csvListNames,'GTV_NP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        
        % Concat expansion csv cells arrays into N
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        
        % Append the visit name to the top of the N cell array
        N{1} = strcat(patientVisits{i},{':'});

        % Concatenate cell arrays M and N together
        GTV_N = [GTV_N N];
        
    end
    if isequal(A2v{1},1) && isequal(any(strcmp(csvListNames,'GTV_N1M1_')),1)
        
        % Change directory back to visit directory
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'GTV_N1M1_'
        k = strfind(csvListNames,'GTV_N1M1_');
        j = find(~cellfun(@isempty,k));
        
        % dummy name variable for mask .csv filepath
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % 'csvread(name,a,b);' reads file into array starting at row offset a and 
            % column offset b.
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;

        % Look for index in csvList with 'GTV_N1P0_'
        k = strfind(csvListNames,'GTV_N1P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        % Look for index in csvList with 'GTV_N1P1_'
        k = strfind(csvListNames,'GTV_N1P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        % Look for index in csvList with 'GTV_N1P2_'
        k = strfind(csvListNames,'GTV_N1P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        % Look for index in csvList with 'GTV_N1P3_'
        k = strfind(csvListNames,'GTV_N1P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);

        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});

        % Concatenate cell arrays M and N together
        GTV_N1 = [GTV_N1 N];
        
    end
    if isequal(A3v{1},1) && isequal(any(strcmp(csvListNames,'GTV_N2M1_')),1)
        
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'GTV_N2M1_'
        k = strfind(csvListNames,'GTV_N2M1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'GTV_N2P0_'
        k = strfind(csvListNames,'GTV_N2P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'GTV_N2P1_'
        k = strfind(csvListNames,'GTV_N2P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'GTV_N2P2_'
        k = strfind(csvListNames,'GTV_N2P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'GTV_N2P3_'
        k = strfind(csvListNames,'GTV_N2P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        GTV_N2 = [GTV_N2 N];
        
    end
    if isequal(A4v{1},1) && isequal(any(strcmp(csvListNames,'GTV_N3M1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'GTV_N3M1_'
        k = strfind(csvListNames,'GTV_N3M1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'GTV_N3P0_'
        k = strfind(csvListNames,'GTV_N3P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'GTV_N3P1_'
        k = strfind(csvListNames,'GTV_N3P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'GTV_N3P2_'
        k = strfind(csvListNames,'GTV_N3P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'GTV_N3P3_'
        k = strfind(csvListNames,'GTV_N3P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        GTV_N3 = [GTV_N3 N];
        
    end
    if isequal(A5v{1},1) && isequal(any(strcmp(csvListNames,'GTV_N4M1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'GTV_N4M1_'
        k = strfind(csvListNames,'GTV_N4M1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'GTV_N4P0_'
        k = strfind(csvListNames,'GTV_N4P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'GTV_N4P1_'
        k = strfind(csvListNames,'GTV_N4P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'GTV_N4P2_'
        k = strfind(csvListNames,'GTV_N4P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'GTV_N4P3_'
        k = strfind(csvListNames,'GTV_N4P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        GTV_N4 = [GTV_N4 N];
        
    end
    if isequal(A6v{1},1) && isequal(any(strcmp(csvListNames,'CTV_NM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_NM1_'
        k = strfind(csvListNames,'CTV_NM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_NP0_'
        k = strfind(csvListNames,'CTV_NP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_NP1_'
        k = strfind(csvListNames,'CTV_NP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_NP2_'
        k = strfind(csvListNames,'CTV_NP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_NP3_'
        k = strfind(csvListNames,'CTV_NP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_N = [CTV_N N];
        
    end
    if isequal(A7v{1},1) && isequal(any(strcmp(csvListNames,'CTV_N1M1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_N1M1_'
        k = strfind(csvListNames,'CTV_N1M1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_N1P0_'
        k = strfind(csvListNames,'CTV_N1P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_N1P1_'
        k = strfind(csvListNames,'CTV_N1P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_N1P2_'
        k = strfind(csvListNames,'CTV_N1P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_N1P3_'
        k = strfind(csvListNames,'CTV_N1P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_N1 = [CTV_N1 N];
        
    end
    if isequal(A8v{1},1) && isequal(any(strcmp(csvListNames,'CTV_N2M1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_N2M1_'
        k = strfind(csvListNames,'CTV_N2M1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_N2P0_'
        k = strfind(csvListNames,'CTV_N2P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_N2P1_'
        k = strfind(csvListNames,'CTV_N2P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_N2P2_'
        k = strfind(csvListNames,'CTV_N2P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_N2P3_'
        k = strfind(csvListNames,'CTV_N2P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_N2 = [CTV_N2 N];
        
    end
    if isequal(A9v{1},1) && isequal(any(strcmp(csvListNames,'CTV_N3M1_')),1)
    
        % Change directory back to visit directory
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_N3M1_'
        k = strfind(csvListNames,'CTV_N3M1_');
        j = find(~cellfun(@isempty,k));
        
        % dummy name variable for mask .csv filepath
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % 'csvread(name,a,b);' reads file into array starting at row offset a and 
            % column offset b.
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;

        % Look for index in csvList with 'CTV_N3P0_'
        k = strfind(csvListNames,'CTV_N3P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        % Look for index in csvList with 'CTV_N3P1_'
        k = strfind(csvListNames,'CTV_N3P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        % Look for index in csvList with 'CTV_N3P2_'
        k = strfind(csvListNames,'CTV_N3P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        % Look for index in csvList with 'CTV_N3P3_'
        k = strfind(csvListNames,'CTV_N3P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);

        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});

        % Concatenate cell arrays M and N together
        CTV_N3 = [CTV_N3 N];
        
    end
    if isequal(A10v{1},1) && isequal(any(strcmp(csvListNames,'CTV_N4M1_')),1)
    
        % Change directory back to visit directory
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_N4M1_'
        k = strfind(csvListNames,'CTV_N4M1_');
        j = find(~cellfun(@isempty,k));
        
        % dummy name variable for mask .csv filepath
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % 'csvread(name,a,b);' reads file into array starting at row offset a and 
            % column offset b.
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;

        % Look for index in csvList with 'CTV_N4P0_'
        k = strfind(csvListNames,'CTV_N4P0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        % Look for index in csvList with 'CTV_N4P1_'
        k = strfind(csvListNames,'CTV_N4P1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        % Look for index in csvList with 'CTV_N4P2_'
        k = strfind(csvListNames,'CTV_N4P2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        % Look for index in csvList with 'CTV_N4P3_'
        k = strfind(csvListNames,'CTV_N4P3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);

        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});

        % Concatenate cell arrays M and N together
        CTV_N4 = [CTV_N4 N];
        
    end 
    if isequal(A11v{1},1) && isequal(any(strcmp(csvListNames,'CTV_EM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_EM1_'
        k = strfind(csvListNames,'CTV_EM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_EP0_'
        k = strfind(csvListNames,'CTV_EP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_EP1_'
        k = strfind(csvListNames,'CTV_EP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_EP2_'
        k = strfind(csvListNames,'CTV_EP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_EP3_'
        k = strfind(csvListNames,'CTV_EP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_E = [CTV_E N];
        
    end
    if isequal(A12v{1},1) && isequal(any(strcmp(csvListNames,'RECTUM_')),1)
    
        % Change directory back to visit directory
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'RECTUM_'
        k = strfind(csvListNames,'RECTUM_');
        j = find(~cellfun(@isempty,k));
        
        % dummy name variable for mask .csv filepath
        name = char(strcat(pwd,{'\'},csvList{j}));

        % 'csvread(name,a,b);' reads file into array starting at row offset a and 
        % column offset b.
        N = csvread(name,13,1);
        N = num2cell(N);

        % Append the visit name to the top of the N cell array
        N{1} = strcat(patientVisits{i},{':'});

        % Concatenate cell arrays M and N together
        RECTUM = [RECTUM N];
        
    end
    if isequal(A13v{1},1) && isequal(any(strcmp(csvListNames,'Rectum_BoundaryM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'Rectum_BoundaryM1_'
        k = strfind(csvListNames,'Rectum_BoundaryM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'Rectum_BoundaryP0_'
        k = strfind(csvListNames,'Rectum_BoundaryP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'Rectum_BoundaryP1_'
        k = strfind(csvListNames,'Rectum_BoundaryP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'Rectum_BoundaryP2_'
        k = strfind(csvListNames,'Rectum_BoundaryP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'Rectum_BoundaryP3_'
        k = strfind(csvListNames,'Rectum_BoundaryP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});

        RECTUM_BOUNDARY = [RECTUM_BOUNDARY N];
        
    end
    if isequal(A14v{1},1) && isequal(any(strcmp(csvListNames,'GTV_TM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'GTV_TM1_'
        k = strfind(csvListNames,'GTV_TM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'GTV_TMP0_'
        k = strfind(csvListNames,'GTV_TP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'GTV_TP1_'
        k = strfind(csvListNames,'GTV_TP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'GTV_TP2_'
        k = strfind(csvListNames,'GTV_TP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'GTV_TP3_'
        k = strfind(csvListNames,'GTV_TP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        GTV_T = [GTV_T N];
        
    end
    if isequal(A15v{1},1) && isequal(any(strcmp(csvListNames,'CTV_HRM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_HRM1_'
        k = strfind(csvListNames,'CTV_HRM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_HRP0_'
        k = strfind(csvListNames,'CTV_HRP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_HRP1_'
        k = strfind(csvListNames,'CTV_HRP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_HRP2_'
        k = strfind(csvListNames,'CTV_HRP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_HRP3_'
        k = strfind(csvListNames,'CTV_HRP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_HR = [CTV_HR N];
        
    end
    if isequal(A16v{1},1) && isequal(any(strcmp(csvListNames,'CTV_IRM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_IRM1_'
        k = strfind(csvListNames,'CTV_IRM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_IRP0_'
        k = strfind(csvListNames,'CTV_IRP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_IRP1_'
        k = strfind(csvListNames,'CTV_IRP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_IRP2_'
        k = strfind(csvListNames,'CTV_IRP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_IRP3_'
        k = strfind(csvListNames,'CTV_IRP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_IR = [CTV_IR N];
        
    end
    if isequal(A17v{1},1) && isequal(any(strcmp(csvListNames,'CTV_LRM1_')),1)
    
        cd(visitDirectory);
        clear N M1 P0 P1 P2 P3;
        
        % Look for index in csvList with 'CTV_LRM1_'
        k = strfind(csvListNames,'CTV_LRM1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        s = dir(name);
        if s.bytes == 0
            % empty file
            M1 = zeros(106,1);
            M1 = num2cell(M1);
        else
            % open the file and read it
            M1 = csvread(name,13,1);
            M1 = num2cell(M1);
        end;
        
        % Look for index in csvList with 'CTV_LRP0_'
        k = strfind(csvListNames,'CTV_LRP0_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P0 = csvread(name,14,1);
        P0 = num2cell(P0);
        
        % Look for index in csvList with 'CTV_LRP1_'
        k = strfind(csvListNames,'CTV_LRP1_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P1 = csvread(name,14,1);
        P1 = num2cell(P1);
        
        % Look for index in csvList with 'CTV_LRP2_'
        k = strfind(csvListNames,'CTV_LRP2_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P2 = csvread(name,14,1);
        P2 = num2cell(P2);
        
        % Look for index in csvList with 'CTV_LRP3_'
        k = strfind(csvListNames,'CTV_LRP3_');
        j = find(~cellfun(@isempty,k));
        name = char(strcat(pwd,{'\'},csvList{j}));
        P3 = csvread(name,14,1);
        P3 = num2cell(P3);
        N = [M1 ; P0 ; P1 ; P2 ; P3];
        N{1} = strcat(patientVisits{i},{':'});
        CTV_LR = [CTV_LR N];
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % Revert to patient Directory
    cd(patientDirectory);
    
    fprintf('   patientVisit element %1.0d...\n',i);

end

fclose('all');

fprintf('   Mask Data Concatenation Complete.\n');

% Clear all unwanted variables for tidyness
clear ans A1v A2v A3v A4v A5v A6v A7v A8v A9v A10v A11v A12v A13v A14v A15v A16v A17v ans csvList csvListStruct csvListNames i j k l S s M M1 P0 P1 P2 P3 N name patientVisits patientVisitStruct patientDirectory visitList RECTUM visitDirectory
