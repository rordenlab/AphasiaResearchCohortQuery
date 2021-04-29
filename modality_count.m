function modality_count
modalities = {'T1', 'ASL', 'Rest', 'DTI', 'T2', 'fMRI'};

for m = 1 : numel(modalities)
    reportModality(modalities{m});
end
if system('which python3') == 0
    pth = fileparts(mfilename);
    if isempty(pth)
        pth = pwd;
    end
    system(fullfile(pth, 'graph.py'));
else
    fprintf('The Python script "graph.py" and generate plots\n');
end

function reportModality(modality)
%modality = 'fMRI';
matname = 'scan.mat';
m = load(matname);
subjs = fieldnames(m);
%subjs = {'M2012'};
fprintf('%s: %d participants\n', modality, numel(subjs));
nvisits = zeros(numel(subjs), 1);
maxvisits = 32;
subjDaysSinceInjury = zeros(numel(subjs), maxvisits);
ageAtInjury = zeros(numel(subjs), 1);
dates = datetime(zeros(numel(subjs), maxvisits), 0, 0);
for s = 1 : numel(subjs)
    if ~isfield(m.(subjs{s}), 'Visit'); continue; end
    visits = fieldnames(m.(subjs{s}).Visit);
    if ~isfield(m.(subjs{s}), 'AgeAtInjury'); continue; end
    
    ageAtInjury(s) = m.(subjs{s}).AgeAtInjury;
    for v = 1 : numel(visits)  
        images = fieldnames(m.(subjs{s}).Visit.(visits{v}) );
        %fieldname "d201" if 201 days since injury
        daysSinceInjury = str2num(visits{v}(2:end) );
        %fprintf('%s %d\n',visits{v}, daysSinceInjury );
        is1st = true;         
        for i = 1 : numel(images)
            %fprintf('%s\n', m.(subjs{s}).(visits{v}).(images{i}).modality );
            if strcmpi(m.(subjs{s}).Visit.(visits{v}).(images{i}).modality, modality)
                if is1st 
                    nvisits(s) = nvisits(s) + 1;
                    subjDaysSinceInjury(s, nvisits(s)) =  daysSinceInjury;
                    %fprintf('%s: %s\n', subjs{s}, m.(subjs{s}).Visit.(visits{v}).(images{i}).study)
                    is1st = false;
                end
                
                
            end
        end
    end
    %if nvisits(s) == 0
    %    fprintf('%s\n', subjs{s});
    %end
end
maxv = max(max(nvisits(:)), 1);
for v = 1 : maxv
    nv = sum(nvisits(:) >= v); 
    fprintf('%d people had %s on at least %d separate visits\n', nv, modality, v);
end
fprintf('\n');
%create tab file
fid = fopen([modality '.tab'],'w');
fprintf(fid,'ID\tAgeAtInjury\tVisitDaysPostInjury\n');
for s = 1 : numel(subjs)
    if nvisits(s) < 1
        continue;
    end
    fprintf(fid,'%s',subjs{s});
    fprintf(fid,'\t%g', ageAtInjury(s)); 
    for v = 1 : nvisits(s) 
        fprintf(fid,'\t%d', subjDaysSinceInjury(s, v) );
    end
    fprintf(fid,'\n');
end
fclose(fid);

