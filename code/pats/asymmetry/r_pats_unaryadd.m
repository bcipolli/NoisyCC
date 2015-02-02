function [in_pats, out_pats, pat_cls, pat_lbls, idx] = r_pats_unaryadd(sets, opt)
% Parity bit: http://en.wikipedia.org/wiki/Parity_bit

    if ~exist('opt','var'), opt = ''; end;

    inpats = 0:31;
    inpats = dec2bin(inpats) - '0'; % convert to binary
    outpats = [1:31 0];
    outpats = dec2bin(outpats) - '0'; % convert to binary

    % Split into input/output, revalue to -1 1
    in_pats  = -1+2*[inpats inpats];  % same RH and LH inputs
    out_pats = -1+2*[outpats outpats]; % same RH and LH outputs

    % Label patterns
    pat_lbls = cellfun(@(a,b) sprintf('%d => %d', a, b), num2cell(bin2dec(char(inpats + '0'))), num2cell(bin2dec(char(outpats(:,1) + '0'))), 'UniformOutput', false);
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);

    idx = []; % use default calculation for symmetric input/outputs
