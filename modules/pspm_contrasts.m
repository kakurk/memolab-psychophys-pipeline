function pspm_contrasts(modelfile)
% function for batch running contrasts in PsPM

%% 
%==========================================================================
%                   User Defined Contrasts
%==========================================================================
% User Defined Contrasts

% Inialize nContrasts to 0
nContrasts = 0;

% White Noise vs Baseline
nContrasts = nContrasts + 1;
Contrasts(nContrasts).name     = 'White-Noise_vs_Baseline'; % arbitrary name of contrast
Contrasts(nContrasts).positive = { 'WhiteNoise, bf 1' 'WhiteNoise, bf 2' }; % Parameters to be included in contrast (+)
Contrasts(nContrasts).negative = {}; % Parameters to be included in contrast (-)

% White Noise vs Tone
nContrasts = nContrasts + 1;
Contrasts(nContrasts).name     = 'White-Noise_vs_Tone'; % name of contrast
Contrasts(nContrasts).positive = { 'WhiteNoise, bf 1' 'WhiteNoise, bf 2' }; % Parameters to be included in contrast (+)
Contrasts(nContrasts).negative = { 'NeutralTone, bf 1' 'NeutralTone, bf 2' }; % Parameters to be included in contrast (-)            

% Emotional vs Neutral Trials
nContrasts = nContrasts + 1;
Contrasts(nContrasts).name     = 'Emotional-Trials_vs_Neutral-Trials'; % name of contrast
Contrasts(nContrasts).positive = { 'Negative_Trials, bf 1' 'Negative_Trials, bf 2' }; % Parameters to be included in contrast (+)
Contrasts(nContrasts).negative = { 'Neutral_Trials, bf 1' 'Neutral_Trials, bf 2'}; % Parameters to be included in contrast (-)

% Build appropriate contrast vectors, weighting everything so that it adds
% up to 1 and -1
Contrasts  = BuildContrastVectors(modelfile, Contrasts);

% set pspm parameters
matlabbatch = set_contrast_params(modelfile, Contrasts);

% run/interactive
scr_jobman('run', matlabbatch)

%%

function matlabbatch = set_contrast_params(file, contrasts)
    % set PsPM contrast parameters
    %
    % file      = model file
    % contrasts = structure array with contrast names and vectors
    
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.modelfile = {file};
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.datatype  = 'param';
    for nC = 1:length(contrasts)
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(nC).conname = contrasts(nC).name;
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(nC).convec  = contrasts(nC).vec;
    end
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.deletecon = true;
    matlabbatch{1}.pspm{1}.first_level{1}.contrast.zscored   = false;
end

function contrasts = BuildContrastVectors(file, contrasts)
   % build appropriate contrast vectors for each specified contrast

   % load the PsPM model file `file`
   glm = [];
   load(file)

   % for each specified contrast in the `contrasts` structure array...
   for nC = 1:length(contrasts)

       % positiveFilt = boolean vector with 1's where there are matches
       % between the specified positive parameters and actual
       % parameters
       % 
       % negativeFilt = boolean vector with 1's where there are matches
       % between the specified negative parameters and actual
       % parameters
       positiveFilt = ismember(glm.names, contrasts(nC).positive)';
       negativeFilt = ismember(glm.names, contrasts(nC).negative)';

       % PositiveMatchesExist = boolean, detemines if any of the
       % specified positive parameters exist in the model
       %
       % NegativeMatchesExist = boolean, determines if any of the
       % specified negative parameters exist in the model
       PositiveMatchesExist = ~isempty(find(positiveFilt, 1));
       NegativeMatchesExist = ~isempty(find(negativeFilt, 1));

       % Build contrast vectors, weighting eveything so equally so that
       % they add up to 1 and -1
       if PositiveMatchesExist && NegativeMatchesExist
            contrasts(nC).vec = positiveFilt / length(find(positiveFilt)) - negativeFilt / length(find(negativeFilt));
       elseif ~PositiveMatchesExist
            contrasts(nC).vec = -1 * negativeFilt / length(find(negativeFilt));
       elseif ~NegativeMatchesExist
            contrasts(nC).vec = positiveFilt / length(find(positiveFilt));
       end

   end

end

end