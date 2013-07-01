function [ all_cv_accuracy_results ] = run_xval_two_classes( varargin )
% [  ] = RUN_CROSS_VALIDATION(varargin)
% Purpose
% 
% This function will run cross-validation
%
% INPUT
%
% classifier type
%
% OUTPUT
% 
% 
%
% EXAMPLE USAGE:
%
% 
% run_cross_validation('classifier','train_logreg')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

expm_settings;
% TODO: Add support for starting for-loops at a specific index the first time
subjects = list_subjects();
regularization_values = [ 1];
%feature_selection_thresholds = [ 0.00000005 0.0000005 0.00005 0.0005];
feature_selection_thresholds = [ 0.00005 ];
subjects_dir = '/jukebox/norman/lpiloto/workspace/MATLAB/DF/scripts/neuropipe/subjects/%s/';
subjects_script_dir = '/jukebox/norman/lpiloto/workspace/MATLAB/DF/scripts/neuropipe/subjects/%s/scripts';

params.feat_dir = 'IMG_LOCALIZERS.feat/';
params.mask_filename = 'temporal_occipital_mask_transformed_brain_extracted.nii';
params.classifier_fn_name = 'train_logreg';
params.feature_select_fn_name = 'statmap_anova';
%img_localizers = {{'scenes_versus_scrambled' [12 14] } { 'objects_versus_scrambled' [13 14] } { 'scenes_versus_objects' [12 13] }};
img_localizers = {{'scenes_versus_scrambled' [12 14] } { 'objects_versus_scrambled' [13 14] } { 'scenes_versus_objects' [12 13] }};
all_cv_accuracy_results = zeros(numel(subjects),numel(feature_selection_thresholds),numel(regularization_values),numel(img_localizers));

for subject_idx = 1:numel(subjects)
	params.subject = subjects{subject_idx};

	subject_dir = sprintf(subjects_dir,params.subject);
	subject_script_dir = sprintf(subjects_script_dir,params.subject);

	% switch to subject's script directory so we're running the correct matlab scripts
	old_dir = pwd;
	cd(subject_script_dir);
	addpath(pwd);

	for feature_select_thresh_idx = 1 : numel(feature_selection_thresholds)
		params.feature_select_thresh = feature_selection_thresholds(feature_select_thresh_idx);

		for regularization_value_idx = 1 : numel(regularization_values)

			params.regularization_value = regularization_values(regularization_value_idx);

			class_args.train_funct_name = params.classifier_fn_name;
			class_args.test_funct_name = strrep(params.classifier_fn_name,'train','test');
			class_args.penalty = params.regularization_value;

			for img_localizers_idx = 1 : numel(img_localizers)
				%try

					params.img_localizer_idcs = img_localizers{img_localizers_idx};

					[subj output.results] = xval_localizer_two_classes(params.subject,subject_dir,'class_args',class_args,'feature_select_thresh',params.feature_select_thresh,'feat_dir',fullfile(subject_dir,'analysis','firstlevel',params.feat_dir),'mask_filename',params.mask_filename,'img_localizer_idcs',params.img_localizer_idcs{2});
					%mean_num_voxels_selected = 
					output.mean_cv_accuracy = mean([output.results.iterations(:).perf]);

					[saved_filename] = expm_save_output(expmt,output,params);
					display(['Completed writing output to: ' saved_filename]);

					all_cv_accuracy_results(subject_idx,feature_select_thresh_idx,regularization_value_idx,img_localizers_idx) = output.mean_cv_accuracy;
                %catch err
				%	all_cv_accuracy_results(subject_idx,feature_select_thresh_idx,regularization_value_idx) = NaN;
				%end
			end
		end
    end

    display(['Finished subject: ' params.subject]);
	
	% return to original directory
	cd(old_dir);
end




% output.wavelet_eeg = [1];
% [saved_filename] = expm_save_output(expmt, output,params);


end
