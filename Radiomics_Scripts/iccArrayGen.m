% Script to loop through created cell array and create an array with
% delineation expansion (measurement) against visits 1, 2, 3, 4.
% To be ran after CollateCsvVisits

clear all;

% Create cell array to hold data

S = load('196817750.mat');

% Check to make sure cell array is occupied
fn = fieldnames(S);

% Loop through all fieldnames (delineations) in structure
for l = 1:numel(fn)
    
    % Create array(s) to calculate icc values from and to store icc values in
    iccArrayVisit4 = zeros(5,2); iccArrayVisit3 = iccArrayVisit4; iccArrayVisit2 = iccArrayVisit3; iccArrayVisit1 = iccArrayVisit2;
    iccGrandArray = zeros(105,8);
    
    if numel(S.(fn{l})) ~= 526 
        
        delineationArray = S.(fn{l});
        visitNames = cell(1,8); % comment to stop preallocation
        for i = 1:numel(visitNames)
            visitNames{1,i} = 'NaN';
        end
        
        % find # rows and columns in fieldname
        [nr , nc] = size(delineationArray);
        % loop over first row of delineation to get cell array of visitnames
        for i = 2:nc
            visitNames{i-1} = delineationArray{1,i}{1,1};
        end
        % check for each visit and append index to local variable
        IndexC = strfind(visitNames,'visit1_end:');
        visit1_end_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit1_start:');
        visit1_start_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit2_end:');
        visit2_end_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit2_start:');
        visit2_start_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit3_end:');
        visit3_end_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit3_start:');
        visit3_start_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit4_end:');
        visit4_end_Index = find(not(cellfun('isempty',IndexC))) + 1;
        IndexC = strfind(visitNames,'visit4_start:');
        visit4_start_Index = find(not(cellfun('isempty',IndexC))) + 1;
        
        for i = 1:105
            for k = 0:4 % index for different expansions
                if  ~isempty(visit1_end_Index)
                    iccArrayVisit1(1+k,1) = delineationArray{(i+1)+k*105,visit1_end_Index};
                end
                if ~isempty(visit1_start_Index) 
                    iccArrayVisit1(1+k,2) = delineationArray{(i+1)+k*105,visit1_start_Index};
                end
                if ~isempty(visit2_end_Index) 
                    iccArrayVisit2(1+k,1) = delineationArray{(i+1)+k*105,visit2_end_Index};
                end
                if ~isempty(visit2_start_Index) 
                    iccArrayVisit2(1+k,2) = delineationArray{(i+1)+k*105,visit2_start_Index};
                end
                if ~isempty(visit3_end_Index) 
                    iccArrayVisit3(1+k,1) = delineationArray{(i+1)+k*105,visit3_end_Index};
                end
                if ~isempty(visit3_start_Index) 
                    iccArrayVisit3(1+k,2) = delineationArray{(i+1)+k*105,visit3_start_Index};
                end
                if ~isempty(visit4_end_Index) 
                    iccArrayVisit4(1+k,1) = delineationArray{(i+1)+k*105,visit4_end_Index};
                end
                if ~isempty(visit4_start_Index) 
                    iccArrayVisit4(1+k,2) = delineationArray{(i+1)+k*105,visit4_start_Index};
                end   
            end
            
            % Once all iccArrayVisits are created, find the Icc value and append to Feature vs. visit Icc array
            % Find size of iccArrayVisitx to make sure there are 2 columns.
            Size = size(iccArrayVisit1);    
            if Size(2) == 2
                [r, LB, UB] = ICC(iccArrayVisit1,'A-1',0.95,.5);
                iccGrandArray(i,1) = r;
                % Calculate standard error in icc Visit value
                err = (UB-LB)/3.92;
                iccGrandArray(i,2) = err;
            else
                iccGrandArray(i,1) = NaN; iccGrandArray(i,2) = iccGrandArray(i,1); 
            end
            Size = size(iccArrayVisit2);
            if Size(2) == 2
                [r, LB, UB] = ICC(iccArrayVisit2,'A-1',0.95,.5);
                iccGrandArray(i,3) = r;
                err = (UB-LB)/3.92;
                iccGrandArray(i,4) = err;
            else
                iccGrandArray(i,3) = NaN; iccGrandArray(i,4) = iccGrandArray(i,3);
            end
            Size = size(iccArrayVisit3);
            if Size(2) == 2    
                [r, LB, UB] = ICC(iccArrayVisit3,'A-1',0.95,.5);
                iccGrandArray(i,5) = r;
                err = (UB-LB)/3.92;
                iccGrandArray(i,6) = err;
            else
                iccGrandArray(i,5) = NaN; iccGrandArray(i,6) = iccGrandArray(i,5);
            end
            Size = size(iccArrayVisit4);
            if Size(2) == 2    
                [r, LB, UB] = ICC(iccArrayVisit4,'A-1',0.95,.5);
                iccGrandArray(i,7) = r;
                err = (UB-LB)/3.92;
                iccGrandArray(i,8) = err;
            else
                iccGrandArray(i,7) = NaN; iccGrandArray(i,8) = iccGrandArray(i,7);
            end

        end
        fprintf('    Computed iccGrandArray for %s.\n', fn{l});
        % iccGrand Array holds all the icc values and standard errors for
        % each feature across all visits. Its columns would be labelled:
        % Visit1 icc ; Visit1 icc error ; Visit2 icc ; Visit2 icc error...
        if (numel(fn{l}) == numel('CTV_IR'))
            logic = [fn{l} == 'CTV_IR'];
            if (all(logic(1,:)))
                CTV_IR_ICC = horzcat(delineationArray(2:106,1) , num2cell(iccGrandArray)); 
                fprintf('    CTV_IR_ICC Allocated.\n')
            end
        end    
        if (numel(fn{l}) == numel('CTV_HR'))
            logic = [fn{l} == 'CTV_HR'];
            if (all(logic(1,:)))
                CTV_HR_ICC = horzcat(delineationArray(2:106,1) , num2cell(iccGrandArray)); 
                fprintf('    CTV_HR_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_LR'))
            logic = [fn{l} == 'CTV_LR'];
            if (all(logic(1,:)))
                CTV_LR_ICC = horzcat(delineationArray(2:106,1) , num2cell(iccGrandArray)); 
                fprintf('    CTV_LR_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('GTV_T'))
            logic = [fn{l} == 'GTV_T'];
            if (all(logic(1,:)))
                GTV_T_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    GTV_T_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_E'))
            logic = [fn{l} == 'CTV_E'];
            if (all(logic(1,:)))
                CTV_E_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    CTV_E_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_N4'))
            logic = [fn{l} == 'CTV_N4'];
            if (all(logic(1,:)))
                CTV_N4_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    CTV_N4_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_N3'))
            logic = [fn{l} == 'CTV_N3'];
            if (all(logic(1,:)))
                CTV_N3_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    CTV_N3_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_N2'))
            logic = [fn{l} == 'CTV_N2'];
            if (all(logic(1,:)))
                CTV_N2_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    CTV_N2_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_N1'))
            logic = [fn{l} == 'CTV_N1'];
            if (all(logic(1,:)))
                CTV_N1_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    CTV_N1_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('CTV_N'))
            logic = [fn{l} == 'CTV_N'];
            if (all(logic(1,:)))
                CTV_N_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    CTV_N_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('GTV_N4'))
            logic = [fn{l} == 'GTV_N4'];
            if (all(logic(1,:)))
                GTV_N4_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    GTV_N4_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('GTV_N3'))
            logic = [fn{l} == 'GTV_N3'];
            if (all(logic(1,:)))
                GTV_N3_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray));
                fprintf('    GTV_N3_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('GTV_N2'))
            logic = [fn{l} == 'GTV_N2'];
            if (all(logic(1,:)))
                GTV_N2_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    GTV_N2_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('GTV_N1'))
            logic = [fn{l} == 'GTV_N1'];
            if (all(logic(1,:)))
                GTV_N1_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    GTV_N1_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('GTV_N')) 
            logic = [fn{l} == 'GTV_N'];
            if (all(logic(1,:)))
                GTV_N_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    GTV_N_ICC Allocated.\n')
            end
        end
        if (numel(fn{l}) == numel('RECTUM_BOUNDARY'))
            logic = [fn{l} == 'RECTUM_BOUNDARY'];
            if (all(logic(1,:)))
                RECTUM_BOUNDARY_ICC = horzcat(delineationArray(2:106,1) ,  num2cell(iccGrandArray)); 
                fprintf('    RECTUM_BOUNDARY_ICC Allocated.\n')
            end
        end
    end
    clear i j k Size logic logical nr nc delineationArray iccArrayVisit1 iccArrayVisit2 iccArrayVisit3 iccArrayVisit4 iccGrandArray visitNames IndexC;
    clear visit1_end_Index visit1_start_Index visit2_end_Index visit2_start_Index visit3_end_Index visit3_start_Index visit4_end_Index visit4_start_Index;
end

if exist('CTV_HR_ICC','var')
    % CTV_HR_ICC
    % Remove and rows which contain NaN and sort
    % CTV_HR_ICC(any(isnan(cell2mat(CTV_HR_ICC(:,2:9))),2),:) = [];
    % Find Mean and error of icc values across visits
    Mean = num2cell(nanmean(cell2mat(CTV_HR_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_HR_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_HR_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_HR_ICC(:,[2,4,6,8])),2));
    CTV_HR_ICC_Mean = horzcat(CTV_HR_ICC(:,1), Mean , sd , Range, quad);
end 
if exist('CTV_IR_ICC','var')
    % CTV_IR_ICC
    % Remove and rows which contain NaN and sort
    % CTV_IR_ICC(any(isnan(cell2mat(CTV_IR_ICC(:,2:9))),2),:) = [];
    % Find Mean and error of icc values across visits
    Mean = num2cell(nanmean(cell2mat(CTV_IR_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_IR_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_IR_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_IR_ICC(:,[2,4,6,8])),2));
    CTV_IR_ICC_Mean = horzcat(CTV_IR_ICC(:,1), Mean , sd , Range, quad);
end 
if exist('CTV_LR_ICC','var')
    % CTV_LR_ICC
    % Remove and rows which contain NaN and sort
    % CTV_LR_ICC(any(isnan(cell2mat(CTV_LR_ICC(:,2:9))),2),:) = [];
    % Find Mean and error of icc values across visits
    Mean = num2cell(nanmean(cell2mat(CTV_LR_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_LR_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_LR_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_LR_ICC(:,[2,4,6,8])),2));
    CTV_LR_ICC_Mean = horzcat(CTV_LR_ICC(:,1), Mean , sd , Range, quad);
end 
if exist('GTV_T_ICC','var') 
    % GTV_T_ICC
    % GTV_T_ICC(any(isnan(cell2mat(GTV_T_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(GTV_T_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(GTV_T_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(GTV_T_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(GTV_T_ICC(:,[2,4,6,8])),2));
    GTV_T_ICC_Mean = horzcat(GTV_T_ICC(:,1), Mean , sd , Range, quad);
end  
if exist('CTV_E_ICC','var') 
    % CTV_E_ICC
    % CTV_E_ICC(any(isnan(cell2mat(CTV_E_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(CTV_E_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_E_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_E_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_E_ICC(:,[2,4,6,8])),2));
    CTV_E_ICC_Mean = horzcat(CTV_E_ICC(:,1), Mean , sd , Range, quad);
end
if exist('CTV_N_ICC','var')  
    % CTV_N_ICC
    % CTV_N_ICC(any(isnan(cell2mat(CTV_N_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(CTV_N_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_N_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_N_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_N_ICC(:,[2,4,6,8])),2));
    CTV_N_ICC_Mean = horzcat(CTV_N_ICC(:,1), Mean , sd , Range, quad);
end
if exist('CTV_N1_ICC','var')   
    % CTV_N1_ICC
    % CTV_N1_ICC(any(isnan(cell2mat(CTV_N1_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(CTV_N1_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_N1_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_N1_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_N1_ICC(:,[2,4,6,8])),2));
    CTV_N1_ICC_Mean = horzcat(CTV_N1_ICC(:,1), Mean , sd , Range, quad);
end
if exist('CTV_N2_ICC','var')   
    % CTV_N2_ICC
    % CTV_N2_ICC(any(isnan(cell2mat(CTV_N2_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(CTV_N2_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_N2_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_N2_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_N2_ICC(:,[2,4,6,8])),2));
    CTV_N2_ICC_Mean = horzcat(CTV_N2_ICC(:,1), Mean , sd , Range, quad);
end
if exist('CTV_N3_ICC','var')   
    % CTV_N3_ICC
    % CTV_N3_ICC(any(isnan(cell2mat(CTV_N3_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(CTV_N3_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_N3_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_N3_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_N3_ICC(:,[2,4,6,8])),2));
    CTV_N3_ICC_Mean = horzcat(CTV_N3_ICC(:,1), Mean , sd , Range, quad);
end
if exist('CTV_N4_ICC','var')   
    % CTV_N4_ICC
    % CTV_N4_ICC(any(isnan(cell2mat(CTV_N4_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(CTV_N4_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(CTV_N4_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(CTV_N4_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(CTV_N4_ICC(:,[2,4,6,8])),2));
    CTV_N4_ICC_Mean = horzcat(CTV_N4_ICC(:,1), Mean , sd , Range, quad);
end
if exist('GTV_N_ICC','var')  
    % GTV_N_ICC
    % GTV_N_ICC(any(isnan(cell2mat(GTV_N_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(GTV_N_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(GTV_N_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(GTV_N_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(GTV_N_ICC(:,[2,4,6,8])),2));
    GTV_N_ICC_Mean = horzcat(GTV_N_ICC(:,1), Mean , sd , Range, quad);
end
if exist('GTV_N1_ICC','var')  
    % GTV_N1_ICC
    % GTV_N1_ICC(any(isnan(cell2mat(GTV_N1_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(GTV_N1_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(GTV_N1_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(GTV_N1_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(GTV_N1_ICC(:,[2,4,6,8])),2));
    GTV_N1_ICC_Mean = horzcat(GTV_N1_ICC(:,1), Mean , sd , Range, quad);
end
if exist('GTV_N2_ICC','var')  
    % GTV_N2_ICC
    % GTV_N2_ICC(any(isnan(cell2mat(GTV_N2_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(GTV_N2_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(GTV_N2_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(GTV_N2_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(GTV_N2_ICC(:,[2,4,6,8])),2));
    GTV_N2_ICC_Mean = horzcat(GTV_N2_ICC(:,1), Mean , sd , Range, quad);
end
if exist('GTV_N3_ICC','var')  
    % GTV_N3_ICC
    % GTV_N3_ICC(any(isnan(cell2mat(GTV_N3_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(GTV_N3_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(GTV_N3_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(GTV_N3_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(GTV_N3_ICC(:,[2,4,6,8])),2));
    GTV_N3_ICC_Mean = horzcat(GTV_N3_ICC(:,1), Mean , sd , Range, quad);
end
if exist('GTV_N4_ICC','var')  
    % GTV_N4_ICC
    % GTV_N4_ICC(any(isnan(cell2mat(GTV_N4_ICC(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(GTV_N4_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(GTV_N4_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(GTV_N4_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(GTV_N4_ICC(:,[2,4,6,8])),2));
    GTV_N4_ICC_Mean = horzcat(GTV_N4_ICC(:,1), Mean , sd , Range, quad);
end
if exist('RECTUM_BOUNDARY_ICC','var')
    % RECTUM_BOUNDARY_ICC
    % RECTUM_BOUNDARY_ICC(any(isnan(cell2mat(Rectum_Boundary(:,2:9))),2),:) = [];
    Mean = num2cell(nanmean(cell2mat(RECTUM_BOUNDARY_ICC(:,[2,4,6,8])),2));
    quad = num2cell(nanquadrat(cell2mat(RECTUM_BOUNDARY_ICC(:,[3,5,7,9]))));
    sd = num2cell(nanstd(cell2mat(RECTUM_BOUNDARY_ICC(:,[2,4,6,8])),0,2));
    Range = num2cell(range(cell2mat(RECTUM_BOUNDARY_ICC(:,[2,4,6,8])),2));
    RECTUM_BOUNDARY_ICC_Mean = horzcat(RECTUM_BOUNDARY_ICC(:,1), Mean , sd , Range, quad);
end

clear  Mean quad Range sd ans df1 df2 err F S LB p r UB l fn; %CTV_IR_ICC CTV_E_ICC CTV_N4_ICC CTV_N3_ICC CTV_N2_ICC CTV_N_ICC GTV_N4_ICC GTV_N3_ICC GTV_N2_ICC GTV_N_ICC;
