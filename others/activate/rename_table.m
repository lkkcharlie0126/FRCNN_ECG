T_rename = T_used;
for i = 1:size(T_used, 1)
    pos = findstr(T_rename{i, 1}{1}, '/s');
    pos = pos(2);
    new_path = ['D:/Win/WTMH/PAG_group/mitbih_5class/data/5sec_no_overlap/signal_resize', T_rename{i, 1}{1}(pos:end)];
    T_rename{i, 1} = {new_path};
end