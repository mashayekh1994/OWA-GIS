clear
% Define the input image file paths
file_paths = {
    'E:\dissertation\shapefiles\input\road.tif', 
    'E:\dissertation\shapefiles\input\lake.tif', 
    'E:\dissertation\shapefiles\input\soil.tif', 
    'E:\dissertation\shapefiles\input\prec.tif',
    'E:\dissertation\shapefiles\input\dem_again.tif', 
    'E:\dissertation\shapefiles\input\slope_fixed.tif',
    'E:\dissertation\shapefiles\input\river.tif',
    'E:\dissertation\shapefiles\input\CN.tif',
    'E:\dissertation\shapefiles\input\lulc.tif'
};

% Read and preprocess the images
images = cell(1, numel(file_paths));
for k = 1:numel(file_paths)
    img = imread(file_paths{k});
    a = img(1,1);
    img(img == a) = NaN;  % Replace specific values with NaN
    images{k} = img;
end

% Weights for different cases
weights = {
    [0.0735479452054794, 0.174, 0.185755707762557, 0.159353881278539, 0.0386598173515982, 0.0216872146118721, 0.0452602739726027, 0.130123287671233, 0.171611872146119],  % w_slope_p
    [0.0824520547945205, 0.0740000000000000, 0.208244292237443, 0.178646118721461, 0.0433401826484018, 0.0243127853881279, 0.0507397260273973, 0.145876712328767, 0.192388127853881],  % w_slope_m
    [0.0828567870485679, 0.131721046077210, 0.147000000000000, 0.179523038605230, 0.0435529265255293, 0.0244321295143213, 0.0509887920298879, 0.146592777085928, 0.193332503113325],  % prec_minus0.05
    [0.0731432129514321, 0.116278953922790, 0.247000000000000, 0.158476961394770, 0.0384470734744707, 0.0215678704856787, 0.0450112079701121, 0.129407222914072, 0.170667496886675],  % prec_plus0.05
    [0.0733068592057762, 0.116539109506619, 0.185146811070999, 0.219000000000000, 0.0385330926594465, 0.0216161251504212, 0.0451119133574007, 0.129696750902527, 0.171049338146811],  % CN_plus0.05
    [0.0826931407942238, 0.131460890493381, 0.208853188929001, 0.119000000000000, 0.0434669073405536, 0.0243838748495788, 0.0508880866425993, 0.146303249097473, 0.192950661853189],  % CN_minus0.05
    [0.082524361948956, 0.131192575406033, 0.208426914153132, 0.178802784222738, 0.043378190255220, 0.024334106728538, 0.050784222737819, 0.088, 0.192556844547564],  % ULC_minus0.05
    [0.073475638051044, 0.116807424593968, 0.185573085846868, 0.159197215777262, 0.038621809744780, 0.021665893271462, 0.045215777262181, 0.188000000000000, 0.171443155452436],  % ULC_plus0.05
    [0.073232273838631, 0.116420537897311, 0.184958435207824, 0.158669926650367, 0.038493887530562, 0.021594132029340, 0.045066014669927, 0.129564792176039, 0.232000000000000],  % oil_plus0.05
    [0.082767726161369, 0.131579462102689, 0.209041564792176, 0.179330073349633, 0.043506112469438, 0.024405867970660, 0.050933985330073, 0.146435207823961, 0.132000000000000]   % oil_minus0.05
};

a_values = [0.0001, 0.1, 0.5, 1, 2, 10, 100];

% Initialize result matrices
result_matrices = struct('At_least_one', [], 'At_least_a_few', [], 'A_few', [], 'WLC', [], 'Most', [], 'Almost_All', [], 'All', []);
fields = fieldnames(result_matrices);

% Define a function to process the matrices
function result = process_matrices(images, weights, a, s)
    result = zeros(s(1), s(2));
    for i = 1:s(1)
        for j = 1:s(2)
            cell = [images{5}(i,j), images{6}(i,j), images{3}(i,j), images{8}(i,j), images{7}(i,j), images{1}(i,j), images{2}(i,j), images{9}(i,j), images{4}(i,j)];
            [sorted_values, sorted_index] = sort(cell, 'descend');
            a_values = zeros(1, 9);
            for k = 1:9
                a_values(k) = sum(weights(sorted_index(1:k)))^a;
            end
            result(i,j) = sum(arrayfun(@(k) (a_values(k) - (k > 1)*a_values(k-1)) * cell(sorted_index(k)), 1:9));
        end
    end
end

% Process each case
for i = 1:numel(a_values)
    for j = 1:numel(weights)
        result_matrices.(fields{j})(:, :) = process_matrices(images, weights{j}, a_values(i), size(images{1}));
    end
end
