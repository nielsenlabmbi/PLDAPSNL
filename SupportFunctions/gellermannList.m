function valid_seq = gellermannList(n)

    % PyGellermann series matlab implementation:
    % (pseudorandom binary sequences)
    % Jadoul, Y., Duengen, D., & Ravignani, A. (2023). 
    % PyGellermann: a Python tool to generate pseudorandom series for human and 
    % non-human animal behavioural experiments. BMC Research Notes, 16(1), 135. 
    % https://doi.org/10.1186/s13104-023-06396-x

    % n = length of sequences to generate
    % intractable for > 100 sequence length 
    % ~12 second search for n =100
    % best to stitch together two n = 100 sequences 

    % fufills 5 criteria:
    % equal number A/B
    % at most 3As or 3Bs in a row
    % at least 20% As and Bs within both first and last half
    % at most N/2 reversals
    % must provide a correct response rate close to 50% chance 
    % when responses are provided as simple alternation (ABAB...) 
    % or double alternation (AABBAA... and ABBAAB...)
    if mod(n,2) ~= 0
        disp('Desired Gellermann series must be even!')
        return
    end
    rng("shuffle")

    if ~exist("tolerance", "var")
        tolerance = 0.1;
    end

    seq = createGellerman(n);

    valid_seq = [];
    while isempty(valid_seq)
        if balanced_elements(seq) && ...
                ~three_more(seq) && ...
                at_least_20_percent_per_half(seq) && ...
                less_than_half_reversals(seq) && ...
                close_to_fifty_alternation(seq, tolerance)
            valid_seq=seq;
        else
            seq = createGellerman(n);
        end
    end
    
    %create sequence
    function seq = createGellerman(n)
        seq = repmat([true false], 1, floor(n/2));
        seq = seq(randperm(length(seq)));
    end

    %condition 1
    %Check if a boolean sequence has equal number of True and False elements
    function c1 = balanced_elements(seq)
        len = length(seq);
        if mod(len,2) == 0  && sum(seq) == floor(len/2)
            c1 = true;
        else
            c1 = false;
        end
    end
    
    %condition 2
    %Check if a boolean sequence has more than three True or False elements in a row
    function c2 = three_more(seq)
        successive = seq(1:end-1) == seq(2:end);
        c2 = any(successive(1:end-2) & successive(2:end-1) & successive(3:end));
    end
    
    %condition 3
    %Check if a boolean sequence has at least 20% True or False elements in both halves
    function c3 = at_least_20_percent_per_half(seq)
        len = length(seq);
        mid = floor(len/2);
        p = floor(len/5); % 20%
        if sum(seq(1:mid)) >= p &&... %The first half trues
           sum(~seq(1:mid)) >= p &&... %flip and look at second half falses
           sum(seq(mid:end)) >= p &&... %The first half trues
           sum(~seq(mid:end)) >= p %flip and look at second half falses
            
            c3 = true;
        else
            c3 = false;
        end
    end
    
    %condition 4
    %Check if a boolean sequence has less than half True-False or False-True reversals
    function c4 = less_than_half_reversals(seq)
        c4 = sum(seq(1:end-1) ~= seq(2:end)) <= floor(length(seq)/2);
    end

    %condition 5
    %Check if a boolean sequence matches the single or double alternation criterion.

    %Checks if matches single or double alternating sequences sufficiently close to 50% chance
    %level, +/- tolerance
    function c5 = close_to_fifty_alternation(seq, tolerance)
        len = length(seq);

        s_alt = repmat([true, false], 1, floor((len+1)/2));
        d_alt1 = repmat([true, true, false, false], 1, floor((len+3)/4));
        d_alt2 = repmat([true, false, false, true], 1, floor((len+3)/4));

        c5 = close_to_fifty(s_alt(1:len), tolerance, seq) & close_to_fifty(d_alt1(1:len), tolerance, seq) & close_to_fifty(d_alt2(1:len), tolerance, seq);

    end
    function ctf = close_to_fifty(alternation, tolerance, seq)
        len = length(seq);
        ctf = ((0.5 - tolerance) <= (sum(alternation == seq)) / len) & ((sum(alternation == seq) / len) <= (0.5 + tolerance));
    end


end
