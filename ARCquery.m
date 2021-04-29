function ARCquery

fnm = 'scan.mat';
if ~exist(fnm, 'file')
    error('Unable to find %s, make sure it is in the same folder as %s', fnm, mfilename);
end
m = load(fnm);
behavnm = 'behavior.mat';
if ~exist(behavnm, 'file')
    behav = [];
    warning('Unable to find %s\n', behavnm);
else
    behav = load(behavnm);
end
criteria = [];
%criteria.PixDim.min = [0,0,0,2];
%criteria.PixDim.max = [Inf,Inf,Inf,1.8];
while true
    [nSubj, nSess, nScan, val, visitTxt, taskTxt] = FilterVisits(m, behav, criteria);
    clc;
    fprintf('Participants: %d Visits: %d Scans: %d\n', nSubj, nSess, nScan);
    PrintCriteria(criteria);
    fprintf(' AgeAtInjury (n: %d) min: %g mean: %g max: %g\n', val.AgeAtInjury.known, val.AgeAtInjury.min, val.AgeAtInjury.mean, val.AgeAtInjury.max);
    fprintf(' DaysPostInjury min: %g max: %g\n', val.DaysPostInjury.min, val.DaysPostInjury.max);
    fprintf(' Gender (n: %d) Women: %d Men %d\n', val.Gender.known, val.Gender.women, val.Gender.men);
    fprintf(' %d Modalities:', numel(val.modalities));
    for i = 1 : numel(val.modalities)
        fprintf(' %s', val.modalities{i})
    end
    fprintf('\n');
    fprintf(' %d Tasks:', numel(val.behav));
    for i = 1 : numel(val.behav)
        fprintf(' %s', val.behav{i})
    end
    fprintf('\n');
    fprintf(' %d Unique Notes\n', numel(val.notes));
    fprintf(' Resolution: %.1f..%.1fx%.1f..%.1fx%.1f..%.1fx%.1f..%.1f\n', val.PixDim.min(1), val.PixDim.max(1), val.PixDim.min(2), val.PixDim.max(2), val.PixDim.min(3), val.PixDim.max(3), val.PixDim.min(4), val.PixDim.max(4));
    fprintf(' %d Studies:', numel(val.studies));
    for i = 1 : numel(val.studies)
        fprintf(' %s', val.studies{i})
    end
    fprintf('\n');
    fprintf(' Voxels: %d..%dx%d..%dx%d..%dx%d..%d\n', val.Dim.min(1), val.Dim.max(1), val.Dim.min(2), val.Dim.max(2), val.Dim.min(3), val.Dim.max(3), val.Dim.min(4), val.Dim.max(4));
    
    fprintf('Commands\n');
    fprintf(' a: age at injury\n');
    fprintf(' d: days post injury\n');
    fprintf(' g: gender\n');
    fprintf(' l: longitudinal\n');    
    fprintf(' m: modality\n');
    fprintf(' n: notes\n');
    fprintf(' r: resolution\n');
    fprintf(' s: study\n');
    fprintf(' t: task\n');
    fprintf(' v: voxels\n');
    fprintf(' q: quit\n');
    cmd = input( 'Enter Command\n', 's' );
    if lower(cmd) == 'a'
       clc;
       criteria.AgeAtInjury.min = input(sprintf( 'Enter minimum age at injury (%g..%g)\n', val.AgeAtInjury.min,  val.AgeAtInjury.max));
       criteria.AgeAtInjury.max = input(sprintf( 'Enter maximum age at injury (%g..%g)\n', val.AgeAtInjury.min,  val.AgeAtInjury.max));
    end
    if lower(cmd) == 'd'
       clc;
       criteria.DaysPostInjury.min = input(sprintf( 'Enter minimum days post injury (%g..%g)\n', val.DaysPostInjury.min,  val.DaysPostInjury.max));
       criteria.DaysPostInjury.max = input(sprintf( 'Enter maximum age days post injury (%g..%g)\n', val.DaysPostInjury.min,  val.DaysPostInjury.max));
    end
    if lower(cmd) == 'g'
       clc;
       gender = input('Enter inclusion gender (m/f/b for male/female/both)\n', 's');
       criteria.Gender = lower(gender);
    end
    if lower(cmd) == 'l'
        clc;
        criteria.Longitudinal = input( 'Minimum visits per person (1=cross-sectional, >1=longitudinal)\n');
    end
    if lower(cmd) == 'm'
       str = input('Enter modality inclusion (e.g. "T1 DTI" to require either T1 or DTI in session)\n', 's');
       criteria.Modality = strsplit(str)';
    end
    if lower(cmd) == 'n'
        clc;
        fprintf(' %d Notes:\n', numel(val.notes));
        for i = 1 : numel(val.notes)
            fprintf(' %s\n', val.notes{i})
        end
        str = input('Enter note inclusion (e.g. "pCASL" will require pCASL in note)\n', 's');
        if isempty(str) && isfield(criteria, 'NotesInclude') 
            criteria = rmfield(criteria, 'NotesInclude');
        elseif ~isempty(str)
            criteria.NotesInclude  = strsplit(str)'; 
        end
        str = input('Enter note exclusion (e.g. "cmrr PA" will omit images with "cmrr" or "_PA" in notes)\n', 's');
        if isempty(str) && isfield(criteria, 'NotesExclude') 
            criteria = rmfield(criteria, 'NotesExclude');
        elseif ~isempty(str)
            criteria.NotesExclude  = strsplit(str)'; 
        end
    end
    if lower(cmd) == 'r'
        str = input('Enter minimum resolution (e.g. "0 0 0 7" to require at a TR >=7 seconds)\n', 's');
        criteria.PixDim.min = str2num(str); %#ok<ST2NM>
        %criteria.PixDim.min = [0,0,0,2];
        if numel(criteria.PixDim.min) ~= 4
            warning('No mininum: Expected 4 values');
            criteria.PixDim = rmfield(criteria.PixDim, 'min');
        end
        str = input('Enter maximum resolution (e.g. "Inf Inf Inf 7" to require a TR  <=7 seconds)\n', 's');
        criteria.PixDim.max = str2num(str); %#ok<ST2NM>
        if numel(criteria.PixDim.max) ~= 4
             warning('No maximum: Expected 4 values');
             criteria.PixDim = rmfield(criteria.PixDim, 'max');
        end
    end
    if lower(cmd) == 's'
       str = input('Enter study inclusion (e.g. "POLAR R01" to restrict to either of these two studies)\n', 's');
       criteria.Study = strsplit(str)';
    end
    if lower(cmd) == 't'
       str = input('Enter task inclusion (e.g. "wab_aphasia_type wab_aq" to require both tasks)\n', 's');
       if isempty(str) && isfield(criteria, 'Task') 
            criteria = rmfield(criteria, 'Task');
       elseif ~isempty(str)
            criteria.Task = strsplit(str)'; 
       end
    end
    if lower(cmd) == 'v'
        str = input('Enter minimum voxels (e.g. "0 0 0 200" to require at least 200 volumes)\n', 's');
        criteria.Dim.min = str2num(str); %#ok<ST2NM>
        if numel(criteria.Dim.min) ~= 4
            warning('No mininum: Expected 4 values');
            criteria.Dim = rmfield(criteria.Dim, 'min');
        end
        str = input('Enter maximum voxels (e.g. "Inf Inf Inf 200" to require no more than 200 volumes)\n', 's');
        criteria.Dim.max = str2num(str); %#ok<ST2NM>
        if numel(criteria.Dim.max) ~= 4
             warning('No maximum: Expected 4 values');
             criteria.Dim = rmfield(criteria.Dim, 'max');
        end
    end
    if lower(cmd) == 'q'
       break; 
    end
end
clc;
PrintCriteria(criteria);
fprintf('\n');
[nSubj, nSess, nScan, val, visitTxt, taskTxt] = FilterVisits(m, behav, criteria, false);   

%fprintf('ID\tAgeAtInjury\tGender\n');
%for i = 1 : numel(visitTxt)
%    fprintf(visitTxt{i});
%end
if ~isempty(visitTxt)
    T = cell2table(visitTxt,'VariableNames',{'ID','AgeAtInjury','Gender'});
    fnm = 'images.xls';
    if exist(fnm, 'file')
        delete(fnm);
    end
    writetable(T,fnm);
end
if ~isempty(taskTxt)
    T = cell2table(taskTxt,'VariableNames',{'ID','Task','DaysPostInjury','Score'});
    fnm = 'behavior.xls';
    if exist(fnm, 'file')
        delete(fnm);
    end
    writetable(T,fnm);
end
%end findMatSessions() 

function PrintCriteria(criteria)
if isempty(criteria)
   return 
end
txt = [];
if isfield(criteria, 'AgeAtInjury')
    txt = [txt, sprintf('AgeAtInjury:%g..%g ', criteria.AgeAtInjury.min, criteria.AgeAtInjury.max)];
end
if isfield(criteria, 'DaysPostInjury')
    txt = [txt, sprintf('DaysPostInjury:%g..%g ', criteria.DaysPostInjury.min, criteria.DaysPostInjury.max)];
end
if isfield(criteria, 'Longitudinal')
    txt = [txt,  sprintf('Longitudinal:%d ', criteria.Longitudinal)];
end
if isfield(criteria, 'Gender')
    txt = [txt, sprintf('Gender:%s ', criteria.Gender)];
end
if  isfield(criteria, 'Dim') && isfield(criteria.Dim, 'min')
    txt = [txt, sprintf('VoxMin:%dx%dx%dx%d ', criteria.Dim.min(1), criteria.Dim.min(2), criteria.Dim.min(3), criteria.Dim.min(4))];
end
if  isfield(criteria, 'Dim') && isfield(criteria.Dim, 'max')
    txt = [txt, sprintf('VoxMax:%dx%dx%dx%d ', criteria.Dim.max(1), criteria.Dim.max(2), criteria.Dim.max(3), criteria.Dim.max(4))];
end
if  isfield(criteria, 'PixDim') && isfield(criteria.PixDim, 'min')
    txt = [txt, sprintf('ResMin:%dx%dx%dx%d ', criteria.PixDim.min(1), criteria.PixDim.min(2), criteria.PixDim.min(3), criteria.PixDim.min(4))];
end
if  isfield(criteria, 'PixDim') && isfield(criteria.PixDim, 'max')
    txt = [txt, sprintf('ResMax:%dx%dx%dx%d ', criteria.PixDim.max(1), criteria.PixDim.max(2), criteria.PixDim.max(3), criteria.PixDim.max(4))];
end
if isfield(criteria, 'Modality')
    txt = [txt, 'Modality:'];
    for i = 1 : numel(criteria.Modality)
        txt = [txt, criteria.Modality{i}];
        if i < numel(criteria.Modality)
           txt = [txt, ',']; 
        end
    end
    txt = [txt, ' '];
end
if isfield(criteria, 'Study')
    txt = [txt, 'Study:'];
    for i = 1 : numel(criteria.Study)
        txt = [txt, criteria.Study{i}];
        if i < numel(criteria.Study)
           txt = [txt, ',']; 
        end
    end
    txt = [txt, ' '];
end
if isfield(criteria, 'Task')
    txt = [txt, 'Task:'];
    for i = 1 : numel(criteria.Task)
        txt = [txt, criteria.Task{i}];
        if i < numel(criteria.Task)
           txt = [txt, ',']; 
        end
    end
    txt = [txt, ' '];
end
if isfield(criteria, 'NotesInclude')
    txt = [txt, 'TypeInclude:'];
    for i = 1 : numel(criteria.NotesInclude)
        txt = [txt, criteria.NotesInclude{i}];
        if i < numel(criteria.NotesInclude)
           txt = [txt, ',']; 
        end
    end 
    txt = [txt, ' '];
end
if isfield(criteria, 'NotesExclude')
    txt = [txt, 'TypeExclude:'];
    for i = 1 : numel(criteria.NotesExclude)
        txt = [txt, criteria.NotesExclude{i}];
        if i < numel(criteria.NotesExclude)
           txt = [txt, ',']; 
        end
    end
    txt = [txt, ' '];
end
fprintf('Criteria: %s\n', txt);
%end PrintCriteria()

function [nSubj, nVisit, nScan, val, VisitTxt, TaskTxt] = FilterVisits(m, behav, criteria, isFast)
if ~exist('isFast', 'var')
   isFast = true; 
end
subjs = fieldnames(m);
nSubj = 0;
nVisit = 0;
nScan = 0;
ageSum = 0;
val = [];
val.Gender.men = 0;
val.Gender.women = 0;
val.Gender.known = 0;
val.Dim.min = [Inf,Inf,Inf,Inf];
val.Dim.max = [0,0,0,0];
val.PixDim.min = [Inf,Inf,Inf,Inf];
val.PixDim.max = [0,0,0,0];
val.AgeAtInjury.min = Inf;
val.AgeAtInjury.mean = 0;
val.AgeAtInjury.max = 0;
val.AgeAtInjury.known = 0;
val.DaysPostInjury.min = Inf;
val.DaysPostInjury.max = 0;
val.modalities = [];
val.notes = [];
val.studies = [];
val.behav = [];
VisitTxt = [];
TaskTxt = [];
VisitCell = {};
minVisits = 1;
if isfield(criteria, 'Longitudinal')
    minVisits = criteria.Longitudinal;
end
visitPasses = 1;
if minVisits > 1
    visitPasses = 2;
end
if minVisits < 0
    visitPasses = 2;
end

for s = 1 : numel(subjs)
    Gender = -1;
    if isfield(m.(subjs{s}), 'Gender')
        Gender = m.(subjs{s}).Gender;
    end
    if isfield(criteria, 'Gender') && (criteria.Gender ~= 'b')
        if ((criteria.Gender == 'm') && (Gender ~= 1))
            continue;
        end
        if ((criteria.Gender == 'f') && (Gender ~= 0))
            continue;
        end    
    end
    AgeAtInjury = -1;
    if isfield(m.(subjs{s}), 'AgeAtInjury')
        AgeAtInjury = m.(subjs{s}).AgeAtInjury;
        if isfield(criteria, 'AgeAtInjury') && isfield(criteria.AgeAtInjury,'min')
            if AgeAtInjury < criteria.AgeAtInjury.min
               continue; 
            end
        end
        if isfield(criteria, 'AgeAtInjury') && isfield(criteria.AgeAtInjury,'max')
            if AgeAtInjury > criteria.AgeAtInjury.max
               continue; 
            end
        end
    else
        %fprintf('No age at injury %s\n', subjs{s});
    end
    
    beh = [];
    if isfield(behav,subjs{s})
        visits = fieldnames(behav.(subjs{s}));
        for v = 1 : numel(visits)
            b = fieldnames(behav.(subjs{s}).(visits{v}));
            if isempty(beh)
                beh = b;
            else
                beh = unique([beh; b]);
            end
        end
    end
    if isfield(criteria, 'Task')
        %for tast exclusion
        % if any(strcmp(criteria.Task,beh))
        %task inclusion:
        if ~any(strcmp(criteria.Task,beh)) 
           continue; 
        end
    end    
    subjOK = false;
    if ~isfield(m.(subjs{s}), 'Visit'); continue; end
    visits = fieldnames(m.(subjs{s}).Visit);
    numVisitOK = 0;
    firstVisit = inf;
    for pass = 1 : visitPasses    
        for v = 1 : numel(visits)
            visitOK = false;
            images = fieldnames(m.(subjs{s}).Visit.(visits{v}) );
            for i = 1 : numel(images)
                if ~isfield(m.(subjs{s}).Visit.(visits{v}).(images{i}), 'modality')
                   continue; 
                end
                if ~isfield(m.(subjs{s}).Visit.(visits{v}).(images{i}), 'notes')
                   continue; 
                end
                study = m.(subjs{s}).Visit.(visits{v}).(images{i}).study;
                if isfield(criteria, 'Study')
                    if ~any(strcmp(criteria.Study,study))
                       continue; 
                    end
                end
                modality = m.(subjs{s}).Visit.(visits{v}).(images{i}).modality;
                if isfield(criteria, 'Modality')
                    if ~any(strcmp(criteria.Modality,modality))
                       continue; 
                    end
                end
                DaysPostInjury = str2num(visits{v}(2:end));
                if isfield(criteria, 'DaysPostInjury')
                    if isfield(criteria, 'DaysPostInjury') && isfield(criteria.DaysPostInjury,'min')
                        if DaysPostInjury < criteria.DaysPostInjury.min
                           continue; 
                        end
                    end   
                    if isfield(criteria, 'DaysPostInjury') && isfield(criteria.DaysPostInjury,'max')
                        if DaysPostInjury > criteria.DaysPostInjury.max
                           continue; 
                        end
                    end   
                end  
                notes = m.(subjs{s}).Visit.(visits{v}).(images{i}).notes;
                %only unique notes, e.g. 1 session per sequence
                %if ~isempty(val.notes) && max(contains(val.notes, notes))
                %    continue;
                %end
                if  isfield(criteria, 'NotesInclude')
                    includeAny = false;
                    for n = 1 : numel(criteria.NotesInclude)
                        if contains(notes, criteria.NotesInclude{n})
                            includeAny = true;
                        end
                    end
                    if ~includeAny
                        continue;
                    end
                end
                if  isfield(criteria, 'NotesExclude')
                    excludeAny = false;
                    for n = 1 : numel(criteria.NotesExclude)
                        if contains(notes, criteria.NotesExclude{n})
                            excludeAny = true;
                        end
                    end
                    if ~excludeAny
                        continue;
                    end
                end
                dim = m.(subjs{s}).Visit.(visits{v}).(images{i}).dim;
                if  isfield(criteria, 'Dim') && isfield(criteria.Dim, 'min')
                    if any(dim < criteria.Dim.min)
                       continue; 
                    end
                end
                if  isfield(criteria, 'Dim') && isfield(criteria.Dim, 'max')
                    if any(dim > criteria.Dim.max)
                       continue; 
                    end
                end                
                pixdim = m.(subjs{s}).Visit.(visits{v}).(images{i}).pixdim;
                %
                if isfield(criteria, 'PixDim') && isfield(criteria.PixDim, 'min')
                    if any(pixdim < criteria.PixDim.min)
                       continue; 
                    end
                end
                if isfield(criteria, 'PixDim') && isfield(criteria.PixDim, 'max')
                    if any(pixdim > criteria.PixDim.max)
                       continue; 
                    end
                end                 
                
                %if we get here: this series is acceptable
                if pass < visitPasses %first pass of longitudinal filter
                    firstVisit = min(firstVisit, DaysPostInjury); 
                    numVisitOK = numVisitOK + 1;
                    break;
                end
                if (visitPasses > 1) && (minVisits < 0)
                    if (DaysPostInjury > firstVisit) 
                        break;
                    end
                end
                if isempty(val.behav)
                    val.behav = beh;    
                else
                    val.behav = unique([beh; val.behav]);
                end
                val.DaysPostInjury.min = min(val.DaysPostInjury.min, DaysPostInjury);
                val.DaysPostInjury.max = max(val.DaysPostInjury.max, DaysPostInjury);
                if isempty(val.studies) || ~max(contains(val.studies, study))
                    val.studies = [val.studies, {study}];
                end
                if isempty(val.modalities) || ~max(contains(val.modalities, modality))
                    val.modalities = [val.modalities, {modality}];
                end
                modality = m.(subjs{s}).Visit.(visits{v}).(images{i}).modality;
                if isempty(val.modalities) || ~max(contains(val.modalities, modality))
                    val.modalities = [val.modalities, {modality}];
                end
                if isempty(val.notes) || ~max(contains(val.notes, notes))
                    val.notes = [val.notes, {notes}];
                end
                val.Dim.min = min(dim, val.Dim.min);
                val.Dim.max = max(dim, val.Dim.max);
                val.PixDim.min = min(pixdim, val.PixDim.min);
                val.PixDim.max = max(pixdim, val.PixDim.max);
                %dt = m.(subjs{s}).Visit.(visits{v}).(images{i}).date;
                %fprintf('%s\n', modality);
                %if ~contains(modality, 'T1') 
                %    continue;
                %end

                %notes = [notes; {[m.(subjs{s}).Visit.(visits{v}).(images{i}).modality m.(subjs{s}).Visit.(visits{v}).(images{i}).notes]}];
                %exemplars = [exemplars; {[subjs{s}, '/', visits{v}]}];
                nScan = nScan + 1;


                if ~visitOK
                    nVisit = nVisit + 1;
                    if ~isFast
                        %uncomment conditional to print date
                        dt = '';
                        isDate = false;
                        if isDate 
                            if isfield(m.(subjs{s}).Visit.(visits{v}).(images{i}), 'date')
                                 dt = m.(subjs{s}).Visit.(visits{v}).(images{i}).date;
                                 dt = sprintf('_%d', yyyymmdd(dt));
                            end
                            txt = sprintf('%s_%s%s\t%g\t%g', subjs{s}, visits{v}, dt, AgeAtInjury, Gender );
                        else
                            txt = sprintf('%s_%s\t%g\t%g', subjs{s}, visits{v}, AgeAtInjury, Gender );
                        end
                        txt = strsplit(txt);
                        VisitTxt = [VisitTxt; txt]; %#ok<AGROW>
                    end
                    visitOK = true;
                end            
                if ~subjOK
                    nSubj = nSubj + 1;
                    subjOK = true;
                    if isfield(m.(subjs{s}), 'AgeAtInjury')
                        age = m.(subjs{s}).AgeAtInjury;
                        val.AgeAtInjury.min = min(age, val.AgeAtInjury.min);
                        val.AgeAtInjury.max = max(age, val.AgeAtInjury.max);
                        val.AgeAtInjury.known = val.AgeAtInjury.known + 1;
                        ageSum = ageSum + age;
                    end
                    if isfield(m.(subjs{s}), 'Gender')
                       val.Gender.known = val.Gender.known + 1;
                       if m.(subjs{s}).Gender == 1
                        val.Gender.men = val.Gender.men + 1;
                       elseif m.(subjs{s}).Gender == 0
                        val.Gender.women = val.Gender.women + 1;
                       else
                           val.Gender.known = val.Gender.known - 1;
                       end
                    end
                end %if SubOK           
            end %for each image

        end %for each visit
        %fprintf('%d\n', numVisitOK);
        if (visitPasses > 1) && (numVisitOK < minVisits) 
            break;
        end
    end %for each pass
    if ~subjOK || isFast
        continue;
    end
    %filter behavior
    if isfield(behav,subjs{s})
        visits = fieldnames(behav.(subjs{s}));
        for v = 1 : numel(visits)
            beh = fieldnames(behav.(subjs{s}).(visits{v}));
            if isfield(criteria, 'Task')
                beh = intersect(beh, criteria.Task);
            end
            if isempty(beh)
                continue;
            end
            for b = 1 : numel(beh)
                days = str2num(visits{v}(2:end));
                txt = sprintf('%s\t%s\t%g\t%g', subjs{s}, beh{b}, days, behav.(subjs{s}).(visits{v}).(beh{b}) );
                txt = strsplit(txt);
                TaskTxt = [TaskTxt; txt]; %#ok<AGROW>
                    
            end
        end
    end
     
    
    
end %for each subject
if val.AgeAtInjury.known > 0
    val.AgeAtInjury.mean = ageSum / val.AgeAtInjury.known;
end
%end FilterVisits()