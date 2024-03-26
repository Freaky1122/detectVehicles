% function tracks=updateUnassignedTracks(unassignedTracks)
% Mark each unassigned track as invisible, and increase its age by 1.
% Inputs:   
%           unassignedTracks:          array
% Outputs:
%           tracks:                    struct
function tracks=updateUnassignedTracks(unassignedTracks)
    global obj;
    global tracks;
    for i = 1:length(unassignedTracks)
        ind = unassignedTracks(i);
    	tracks(ind).age = tracks(ind).age + 1;
    	tracks(ind).consecutiveInvisibleCount = ...
            tracks(ind).consecutiveInvisibleCount + 1;
	end
end