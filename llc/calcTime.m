function [result] = calcTime (frame, orig_size, fs, hop)
    result = (frame - orig_size)*hop/fs;