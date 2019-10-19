
    raw0 = csvread('./matrix-0-optime.csv');
    raw2 = csvread('./matrix-2-optime.csv');
    raw7 = csvread('./matrix-7-optime.csv');
    raw22 = csvread('./matrix-22-optime.csv');
    raw63 = csvread('./matrix-63-optime.csv');
    raw110 = csvread('./matrix-110-optime.csv');
    raw361 = csvread('./matrix-361-optime.csv');
    raw886 = csvread('./matrix-886-optime.csv');
    raw1000 = csvread('./matrix-1000-optime.csv');
    
    nsecpertsc_all = [  raw0(2:end,1) ./ raw0(2:end,2) ; ...
                        raw2(2:end,1) ./ raw2(2:end,2) ; ...
                        raw7(2:end,1) ./ raw7(2:end,2) ; ...
                        raw22(2:end,1) ./ raw22(2:end,2) ; ...
                        raw63(2:end,1) ./ raw63(2:end,2) ; ...
                        raw110(2:end,1) ./ raw110(2:end,2) ; ...
                        raw361(2:end,1) ./ raw361(2:end,2) ; ...
                        raw886(2:end,1) ./ raw886(2:end,2) ; ...
                        raw1000(2:end,1) ./ raw1000(2:end,2) ];

    nsecpertsc_all = sort(nsecpertsc_all);
    len = length(nsecpertsc_all)
    nsecpertsc_mean= mean(nsecpertsc_all)
    nsecpertsc_std = std(nsecpertsc_all)
    nsecpertsc_orderstats = [nsecpertsc_all(1:floor(len/10):end); max(nsecpertsc_all)]

    sort0 = sort(raw0(2:end,3));
    len0 = length(sort0)
    mean0 = mean(sort0)
    std0  = std(sort0)
    var0  = var(sort0)
    orderstats0 = [sort0(1:floor(len0/10):end); max(sort0)]

    raw_csv_out(:, 1) = [0; len0; mean0; std0; 0; 0; 0; orderstats0];
    
    sort2 = sort(raw2(2:end,3));
    len2 = length(sort2)
    mean2= mean(sort2)
    std2 = std(sort2)
    opestimate2 = 2*2+2*1
    scaled_mean2 = (mean2 - mean0) / opestimate2
    scaled_var2  = (var(sort2) - var0) / opestimate2
    orderstats2 = [sort2(1:floor(len2/10):end); max(sort2)]

    raw_csv_out(:, 2) = [2; len2; mean2; std2; opestimate2; scaled_mean2; scaled_var2; orderstats2];
    
    sort7 = sort(raw7(2:end,3));
    len7 = length(sort7)
    mean7= mean(sort7)
    std7 = std(sort7)
    opestimate7 = 7*7+7*6
    scaled_mean7 = (mean7 - mean0) / (scaled_mean2 *opestimate7)
    scaled_var7  = (var(sort7) - var0) / (scaled_var2 *opestimate7) 
    orderstats7 = [sort7(1:floor(len7/10):end); max(sort7)]

    raw_csv_out(:, 3) = [7; len7; mean7; std7; opestimate7; scaled_mean7; scaled_var7; orderstats7];
    
    sort22 = sort(raw22(2:end,3));
    len22 = length(sort22)
    mean22= mean(sort22)
    std22 = std(sort22)
    opestimate22 = 22*22+22*21
    scaled_mean22 = (mean22 - mean0) / (scaled_mean2 *opestimate22)
    scaled_var22  = (var(sort22) - var0) / (scaled_var2 *opestimate22) 
    orderstats22 = [sort22(1:floor(len22/10):end); max(sort22)]

    raw_csv_out(:, 4) = [22; len22; mean22; std22; opestimate22; scaled_mean22; scaled_var22; orderstats22];
    
    sort63 = sort(raw63(2:end,3));
    len63 = length(sort63)
    mean63= mean(sort63)
    std63 = std(sort63)
    opestimate63 = 63*63+63*62
    scaled_mean63 = (mean63 - mean0) / (scaled_mean2 *opestimate63)
    scaled_var63  = (var(sort63) - var0) / (scaled_var2 *opestimate63) 
    orderstats63 = [sort63(1:floor(len63/10):end); max(sort63)]

    raw_csv_out(:, 5) = [63; len63; mean63; std63; opestimate63; scaled_mean63; scaled_var63; orderstats63];
    
    sort110 = sort(raw110(2:end,3));
    len110 = length(sort110)
    mean110= mean(sort110)
    std110 = std(sort110)
    opestimate110 = 110*110+110*109
    scaled_mean110 = (mean110 - mean0) / (scaled_mean2 *opestimate110)
    scaled_var110  = (var(sort110) - var0) / (scaled_var2 *opestimate110) 
    orderstats110 = [sort110(1:floor(len110/10):end); max(sort110)]

    raw_csv_out(:, 6) = [110; len110; mean110; std110; opestimate110; scaled_mean110; scaled_var110; orderstats110];
    
    sort361 = sort(raw361(2:end,3));
    len361 = length(sort361)
    mean361= mean(sort361)
    std361 = std(sort361)
    opestimate361 = 361*361+361*360
    scaled_mean361 = (mean361 - mean0) / (scaled_mean2 *opestimate361)
    scaled_var361  = (var(sort361) - var0) / (scaled_var2 *opestimate361) 
    orderstats361 = [sort361(1:floor(len361/10):end); max(sort361)]

    raw_csv_out(:, 7) = [361; len361; mean361; std361; opestimate361; scaled_mean361; scaled_var361; orderstats361];
    
    sort886 = sort(raw886(2:end,3));
    len886 = length(sort886)
    mean886= mean(sort886)
    std886 = std(sort886)
    opestimate886 = 886*886+886*885
    scaled_mean886 = (mean886 - mean0) / (scaled_mean2 *opestimate886)
    scaled_var886  = (var(sort886) - var0) / (scaled_var2 *opestimate886) 
    orderstats886 = [sort886(1:floor(len886/10):end); max(sort886)]

    raw_csv_out(:, 8) = [886; len886; mean886; std886; opestimate886; scaled_mean886; scaled_var886; orderstats886];
    
    sort1000 = sort(raw1000(2:end,3));
    len1000 = length(sort1000)
    mean1000= mean(sort1000)
    std1000 = std(sort1000)
    opestimate1000 = 1000*1000+1000*999;
    scaled_mean1000 = (mean1000 - mean0) / (scaled_mean2 *opestimate1000)
    scaled_var1000  = (var(sort1000) - var0) / (scaled_var2 *opestimate1000) 
    orderstats1000 = [sort1000(1:floor(len1000/10):end); max(sort1000)]

    raw_csv_out(:, 9) = [1000; len1000; mean1000; std1000; opestimate1000; scaled_mean1000; scaled_var1000; orderstats1000];
    
    csvwrite('./matrix-summary-optime.csv', raw_csv_out);
    
