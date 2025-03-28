function get_result_for_image = getResult(ori_image_name, attack_image_name, net, nnvNet)
    % Define base paths
    base_original = '/Users/hardikkhandelwal/desktop/college/image_star/mnist_detection/test/images/';
    base_corrupted = '/Users/hardikkhandelwal/desktop/mnistod/';

    % Construct dynamic file paths
    ori_img_path = sprintf('%s%s', base_original, ori_image_name);
    corr_img_path = sprintf('%s%s', base_corrupted, attack_image_name);

    ori_img = imread(ori_img_path);
    corr_img = imread(corr_img_path);
    corr_img = rgb2gray(corr_img);

    fprintf('\n\n=============================FETCHING TRUE OUTPUT ======================\n');
    target = predict(net, ori_img) * 300;

    % ori_img = corr_img;




    fprintf('\n\n=========CONSTRUCT INPUT SET (AN IMAGESTAR SET) =============\n');

    dif_img = double(corr_img) - double(ori_img);

    % IM = double(ori_img);
    % UB = double(dif_img);
    % LB = -1 * double(dif_img);


    V(:,:,:,1) = double(ori_img);
    V(:,:,:,2) = double(dif_img);

    % l = [0.5 0.8 0.95 0.97 0.98 0.98999];
    l = 0.98;
    delta = 0.0000002;
    n = length(l);

    pred_lb = zeros(n, 1);
    pred_ub = zeros(n, 1);

    robust_exact = zeros(n, 1);
    robust_approx = zeros(n, 1);
    VT_exact = zeros(n, 1);
    VT_approx = zeros(n, 1);

    for i = 1:n
        pred_lb(i) = l(i);
        pred_ub(i) = l(i) + delta;
    
        C = [1;-1];   % pred_lb % <= alpha <= pred_ub percentage of FGSM attack
        d = [pred_ub(i); -pred_lb(i)]; 
        IS = ImageStar(V, C, d, pred_lb(i), pred_ub(i));
        % IS = ImageStar(IM, LB, UB);
    
        % fprintf('\n\n=================== VERIFYING ROBUSTNESS FOR l = %.5f, delta = %.8f ====================\n', l(i), delta);
        % exact-star
        reachOptions = struct;
        reachOptions.reachMethod = 'approx-star';
        t = tic;
        robust_exact(i) = nnvNet.verify_robustness_regression(IS, reachOptions, target);
        VT_exact(i) = toc(t);
        get_result_for_image = robust_exact(i);
        return;


        % approx-star
        % reachOptions = struct;
        % reachOptions.reachMethod = 'approx-star';
        % t = tic; 
        % robust_approx(i) = nnvNet.verify_robustness(IS, reachOptions, correct_id);
        % VT_approx(i) = toc(t);
    end


end

fprintf('\n\n=============================LOADING MODEL ======================\n');

net = load('trainedModel1.mat').trainedModel;

fprintf(['\n\n============' ...
    '============ PARSING MODEL =======================\n']);
nnvNet = matlab2nnv(net);

imageSize = 300;

attacks2 = {};

attacks1 = {'defocus_blur', 'pixelate', 'glass_blur', 'elastic_transform', 'zoom_blur', 'motion_blur'};

attacks = { ...
    'brightness', ...
    'contrast', ...
    'defocus_blur', ...
    'elastic_transform', ...
    'fog', ...
    'frost', ...
    'gaussian_noise', ...
    'glass_blur', ...
    'impulse_noise', ...
    'jpeg_compression', ...
    'motion_blur', ...
    'pixelate', ...
    'shot_noise', ...
    'snow', ...
    'zoom_blur' ...
};

severity = 5;
image_count = 1;
results = struct();
timepass = struct();
for i = 1:length(attacks1)  % Loop through each attack
    attack_name = attacks1{i};  
    for j = 1:severity  % Loop through each severity level
        for k = 0:image_count - 1  % Loop through each image index
            fprintf('\nAttack: %d  Severity: %d', i, j);
            key = sprintf('img_%d_%s_%d', k, attack_name, j);
            attack_image_name = sprintf('%d_%s_%d.png', k, attack_name, j);
            ori_image_name = sprintf('%d.png', k);
            t = tic;
            try
                results.(key) = getResult(ori_image_name, attack_image_name, net, nnvNet);
            catch ME
                results.(key) = 2;
            end
            timepass.(key) = toc(t);
        end
    end
end

disp(results);
disp(timepass);










