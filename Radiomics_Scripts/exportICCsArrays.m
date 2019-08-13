% Script to write the created ICC_Mean data cells arrays to .csv's

clear all;

% Load .mat file into structure
load('196817750MeanICCs.mat');
S = load('196817750MeanICCs.mat');
variableNames = {'Featurename' 'Mean_ICC' 'StdDev' 'Range' 'CI_Errors_Quad'};

% Get fieldnames of structure
fn = fieldnames(S);

for l = 1:numel(fn)
    % Check to make sure cell array is correct one
    if (numel(fn{l}) == numel('CTV_E_ICC_Mean'))
        logic = [fn{l} == 'CTV_E_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_E_ICC_Mean.csv\n');
            % Create table and then write to .csv
            CTV_E_Table = cell2table(CTV_E_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_E_Table,'CTV_E_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_LR_ICC_Mean'))
        logic = [fn{l} == 'CTV_LR_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_LR_ICC_Mean.csv\n');
            CTV_LR_Table = cell2table(CTV_LR_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_LR_Table,'CTV_LR_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_IR_ICC_Mean'))
        logic = [fn{l} == 'CTV_IR_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_IR_ICC_Mean.csv\n');
            CTV_IR_Table = cell2table(CTV_IR_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_IR_Table,'CTV_IR_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_HR_ICC_Mean'))
        logic = [fn{l} == 'CTV_HR_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_HR_ICC_Mean.csv\n');
            CTV_HR_Table = cell2table(CTV_HR_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_HR_Table,'CTV_HR_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('GTV_T_ICC_Mean'))
        logic = [fn{l} == 'GTV_T_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing GTV_T_ICC_Mean.csv\n');
            GTV_T_Table = cell2table(GTV_T_ICC_Mean, 'VariableNames', variableNames);
            writetable(GTV_T_Table,'GTV_T_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('RECTUM_BOUNDARY_ICC_Mean'))
        logic = [fn{l} == 'RECTUM_BOUNDARY_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing RECTUM_BOUNDARY_ICC_Mean.csv\n');
            RECTUM_BOUNDARY_Table = cell2table(RECTUM_BOUNDARY_ICC_Mean, 'VariableNames', variableNames);
            writetable(RECTUM_BOUNDARY_Table,'RECTUM_BOUNDARY_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_N4_ICC_Mean'))
        logic = [fn{l} == 'CTV_N4_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_N4_ICC_Mean.csv\n');
            CTV_N4_Table = cell2table(CTV_N4_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N4_Table,'CTV_N4_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_N3_ICC_Mean'))
        logic = [fn{l} == 'CTV_N3_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_N3_ICC_Mean.csv\n');
            CTV_N3_Table = cell2table(CTV_N3_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N3_Table,'CTV_N3_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_N2_ICC_Mean'))
        logic = [fn{l} == 'CTV_N2_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_N2_ICC_Mean.csv\n');
            CTV_N2_Table = cell2table(CTV_N2_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N2_Table,'CTV_N2_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_N1_ICC_Mean'))
        logic = [fn{l} == 'CTV_N1_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_N1_ICC_Mean.csv\n');
            CTV_N1_Table = cell2table(CTV_N1_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N1_Table,'CTV_N1_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('CTV_N_ICC_Mean'))
        logic = [fn{l} == 'CTV_N_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing CTV_N_ICC_Mean.csv\n');
            CTV_N_Table = cell2table(CTV_N_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N_Table,'CTV_N_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('GTV_N4_ICC_Mean'))
        logic = [fn{l} == 'GTV_N4_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing GTV_N4_ICC_Mean.csv\n');
            GTV_N4_Table = cell2table(GTV_N4_ICC_Mean, 'VariableNames', variableNames);
            writetable(GTV_N4_Table,'GTV_N4_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('GTV_N3_ICC_Mean'))
        logic = [fn{l} == 'GTV_N3_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing GTV_N3_ICC_Mean.csv\n');
            GTV_N3_Table = cell2table(GTV_N3_ICC_Mean, 'VariableNames', variableNames);
            writetable(GTV_N3_Table,'GTV_N3_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('GTV_N2_ICC_Mean'))
        logic = [fn{l} == 'GTV_N2_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing GTV_N2_ICC_Mean.csv\n');
            GTV_N2_Table = cell2table(GTV_N2_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N2_Table,'GTV_N2_ICC_Mean.csv');
        end
    end
    if (numel(fn{l}) == numel('GTV_N1_ICC_Mean'))
        logic = [fn{l} == 'GTV_N1_ICC_Mean'];
        if (all(logic(1,:)))
            fprintf('   Writing GTV_N1_ICC_Mean.csv\n');
            GTV_N1_Table = cell2table(GTV_N1_ICC_Mean, 'VariableNames', variableNames);
            writetable(CTV_N1_Table,'GTV_N1_ICC_Mean.csv');
        end
    end
end           
fprintf('   All CSVs Exported.\n');
clear all;
