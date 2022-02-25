function sync
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 1, 'PrimaryAddress', 13, 'Tag', '');
buff=[nan nan];
while isnan(buff(1)*buff(2));
    ask{1} = query(obj1, 'I1?');
    ask{2} = query(obj1, 'I2?');
    for k = 1:2
        switch (upper(ask{k}([1 2])))
            case 'AR'
                buff(k) = 0;
            case 'F+'
                buff(k) = +1;
            case 'F-'
                buff(k) = -1;
            case 'DE'
                buff(k) = nan;
            case 'RO'
                buff(k) = nan;
        end
    end
end
