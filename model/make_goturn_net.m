% input:
%       -target :227*227*3
%       -image :227*227*3
% output:
%       -bbox :4*1*1

run vl_setupnn.m ;
net = dagnn.DagNN() ;
net.meta.normalization.averageImage = reshape(single([104,117,123]),[1,1,3]);
net.meta.normalization.imageSize = [227,227,3];
%% target

conv1 = dagnn.Conv('size', [11 11 3 96], 'pad', 0, 'stride', 4, 'hasBias', true) ;
net.addLayer('conv1', conv1, {'target'}, {'conv1'}, {'filters1', 'biases1'}) ;
net.addLayer('relu1', dagnn.ReLU(), {'conv1'}, {'conv1x'});
pool1 = dagnn.Pooling('method', 'max', 'poolSize', [3 3],'pad', 0, 'stride', 2);
net.addLayer('pool1', pool1, {'conv1x'}, {'pool1'});
norm1 = dagnn.LRN('param', [5 1 0.0001/5 0.75]);
net.addLayer('norm1', norm1, {'pool1'}, {'norm1'});

conv2 = dagnn.Conv('size', [5 5 48 256], 'pad', 2, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv2', conv2, {'norm1'}, {'conv2'}, {'filters2', 'biases2'}) ;
net.addLayer('relu2', dagnn.ReLU(), {'conv2'}, {'conv2x'});
pool2 = dagnn.Pooling('method', 'max', 'poolSize', [3 3],'pad', 0, 'stride', 2);
net.addLayer('pool2', pool2, {'conv2x'}, {'pool2'});
norm2 = dagnn.LRN('param', [5 1 0.0001/5 0.75]);
net.addLayer('norm2', norm2, {'pool2'}, {'norm2'});

conv3 = dagnn.Conv('size', [3 3 256 384], 'pad', 1, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv3', conv3, {'norm2'}, {'conv3'}, {'filters3', 'biases3'}) ;
net.addLayer('relu3', dagnn.ReLU(), {'conv3'}, {'conv3x'});

conv4 = dagnn.Conv('size', [3 3 192 384], 'pad', 1, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv4', conv4, {'conv3x'}, {'conv4'}, {'filters4', 'biases4'}) ;
net.addLayer('relu4', dagnn.ReLU(), {'conv4'}, {'conv4x'});

conv5 = dagnn.Conv('size', [3 3 192 256], 'pad', 1, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv5', conv5, {'conv4x'}, {'conv5'}, {'filters5', 'biases5'}) ;
net.addLayer('relu5', dagnn.ReLU(), {'conv5'}, {'conv5x'});
pool5 = dagnn.Pooling('method', 'max', 'poolSize', [3 3],'pad', 0, 'stride', 2);
net.addLayer('pool5', pool5, {'conv5x'}, {'pool5'});

%% image

conv1_p = dagnn.Conv('size', [11 11 3 96], 'pad', 0, 'stride', 4, 'hasBias', true) ;
net.addLayer('conv1_p', conv1_p, {'image'}, {'conv1_p'}, {'filters1p', 'biases1p'}) ;
net.addLayer('relu1_p', dagnn.ReLU(), {'conv1_p'}, {'conv1x_p'});
pool1_p = dagnn.Pooling('method', 'max', 'poolSize', [3 3],'pad', 0, 'stride', 2);
net.addLayer('pool1_p', pool1_p, {'conv1x_p'}, {'pool1_p'});
norm1_p = dagnn.LRN('param', [5 1 0.0001/5 0.75]);
net.addLayer('norm1_p', norm1_p, {'pool1_p'}, {'norm1_p'});

conv2_p = dagnn.Conv('size', [5 5 48 256], 'pad', 2, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv2_p', conv2_p, {'norm1_p'}, {'conv2_p'}, {'filters2p', 'biases2p'}) ;
net.addLayer('relu2_p', dagnn.ReLU(), {'conv2_p'}, {'conv2x_p'});
pool2_p = dagnn.Pooling('method', 'max', 'poolSize', [3 3],'pad', 0, 'stride', 2);
net.addLayer('pool2_p', pool2_p, {'conv2x_p'}, {'pool2_p'});
norm2_p = dagnn.LRN('param', [5 1 0.0001/5 0.75]);
net.addLayer('norm2_p', norm2_p, {'pool2_p'}, {'norm2_p'});

conv3_p = dagnn.Conv('size', [3 3 256 384], 'pad', 1, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv3_p', conv3_p, {'norm2_p'}, {'conv3_p'}, {'filters3p', 'biases3p'}) ;
net.addLayer('relu3_p', dagnn.ReLU(), {'conv3_p'}, {'conv3x_p'});

conv4_p = dagnn.Conv('size', [3 3 192 384], 'pad', 1, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv4_p', conv4_p, {'conv3x_p'}, {'conv4_p'}, {'filters4p', 'biases4p'}) ;
net.addLayer('relu4_p', dagnn.ReLU(), {'conv4_p'}, {'conv4x_p'});

conv5_p = dagnn.Conv('size', [3 3 192 256], 'pad', 1, 'stride', 1, 'hasBias', true) ;
net.addLayer('conv5_p', conv5_p, {'conv4x_p'}, {'conv5_p'}, {'filters5p', 'biases5p'}) ;
net.addLayer('relu5_p', dagnn.ReLU(), {'conv5_p'}, {'conv5x_p'});
pool5_p = dagnn.Pooling('method', 'max', 'poolSize', [3 3],'pad', 0, 'stride', 2);
net.addLayer('pool5_p', pool5_p, {'conv5x_p'}, {'pool5_p'});

%% concat

net.addLayer('concat' , dagnn.Concat(), {'pool5','pool5_p'}, {'pool5_concat'}) ;

%% fc

fc6_new = dagnn.Conv('size', [6 6 512 4096], 'pad', 0, 'stride', 1, 'hasBias', true) ;%need fix
net.addLayer('fc6_new', fc6_new, {'pool5_concat'}, {'fc6'}, {'filters6', 'biases6'}) ;
net.addLayer('relu6', dagnn.ReLU(), {'fc6'}, {'fc6x'});
drop6 = dagnn.DropOut('rate', 0.5);
net.addLayer('drop6',drop6,{'fc6x'},{'fc6x_dropout'});

fc7_new = dagnn.Conv('size', [1 1 4096 4096], 'pad', 0, 'stride', 1, 'hasBias', true) ;
net.addLayer('fc7_new', fc7_new, {'fc6x_dropout'}, {'fc7'}, {'filters7', 'biases7'}) ;
net.addLayer('relu7', dagnn.ReLU(), {'fc7'}, {'fc7x'});
drop7 = dagnn.DropOut('rate', 0.5);
net.addLayer('drop7',drop7,{'fc7x'},{'fc7x_dropout'});

fc7_newb = dagnn.Conv('size', [1 1 4096 4096], 'pad', 0, 'stride', 1, 'hasBias', true) ;
net.addLayer('fc7_newb', fc7_newb, {'fc7x_dropout'}, {'fc7b'}, {'filters7b', 'biases7b'}) ;
net.addLayer('relu7b', dagnn.ReLU(), {'fc7b'}, {'fc7bx'});
drop7b = dagnn.DropOut('rate', 0.5);
net.addLayer('drop7b',drop7b,{'fc7bx'},{'fc7bx_dropout'});

fc8_shapes = dagnn.Conv('size', [1 1 4096 4], 'pad', 0, 'stride', 1, 'hasBias', true) ;
net.addLayer('fc8_shapes', fc8_shapes, {'fc7bx_dropout'}, {'fc8'}, {'filters8', 'biases8'}) ;


%% params
% load('./tracker_conv1.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters1')).value = weight;
% net.params(net.getParamIndex('biases1')).value = bias;
% 
% load('./tracker_conv2.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters2')).value = weight;
% net.params(net.getParamIndex('biases2')).value = bias;
% 
% load('./tracker_conv3.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters3')).value = weight;
% net.params(net.getParamIndex('biases3')).value = bias;
% 
% load('./tracker_conv4.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters4')).value = weight;
% net.params(net.getParamIndex('biases4')).value = bias;
% 
% load('./tracker_conv5.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters5')).value = weight;
% net.params(net.getParamIndex('biases5')).value = bias;
% 
% 
% load('./tracker_conv1_p.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters1p')).value = weight;
% net.params(net.getParamIndex('biases1p')).value = bias;
% 
% load('./tracker_conv2_p.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters2p')).value = weight;
% net.params(net.getParamIndex('biases2p')).value = bias;
% 
% load('./tracker_conv3_p.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters3p')).value = weight;
% net.params(net.getParamIndex('biases3p')).value = bias;
% 
% load('./tracker_conv4_p.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters4p')).value = weight;
% net.params(net.getParamIndex('biases4p')).value = bias;
% 
% load('./tracker_conv5_p.mat');
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters5p')).value = weight;
% net.params(net.getParamIndex('biases5p')).value = bias;
% 
% load('./tracker_fc6-new.mat');
% weight = reshape(weight,[4096,512,6,6]);
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters6')).value = weight;
% net.params(net.getParamIndex('biases6')).value = bias;
% 
% load('./tracker_fc7-new.mat');
% weight = reshape(weight,[4096,4096,1,1]);
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters7')).value = weight;
% net.params(net.getParamIndex('biases7')).value = bias;
% 
% load('./tracker_fc7-newb.mat');
% weight = reshape(weight,[4096,4096,1,1]);
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters7b')).value = weight;
% net.params(net.getParamIndex('biases7b')).value = bias;
% 
% load('./tracker_fc8-shapes.mat');
% weight = reshape(weight,[4,4096,1,1]);
% weight = permute(weight,[4,3,2,1]);
% bias = bias';
% net.params(net.getParamIndex('filters8')).value = weight;
% net.params(net.getParamIndex('biases8')).value = bias;

load('./goturn_train.mat');


net.params(net.getParamIndex('filters1')).value = params(1).value;
net.params(net.getParamIndex('biases1')).value = params(2).value;

net.params(net.getParamIndex('filters2')).value = params(3).value;
net.params(net.getParamIndex('biases2')).value = params(4).value;

net.params(net.getParamIndex('filters3')).value = params(5).value;
net.params(net.getParamIndex('biases3')).value = params(6).value;

net.params(net.getParamIndex('filters4')).value = params(7).value;
net.params(net.getParamIndex('biases4')).value = params(8).value;

net.params(net.getParamIndex('filters5')).value = params(9).value;
net.params(net.getParamIndex('biases5')).value = params(10).value;

net.params(net.getParamIndex('filters1p')).value = params(1).value;
net.params(net.getParamIndex('biases1p')).value = params(2).value;

net.params(net.getParamIndex('filters2p')).value = params(3).value;
net.params(net.getParamIndex('biases2p')).value = params(4).value;

net.params(net.getParamIndex('filters3p')).value = params(5).value;
net.params(net.getParamIndex('biases3p')).value = params(6).value;

net.params(net.getParamIndex('filters4p')).value = params(7).value;
net.params(net.getParamIndex('biases4p')).value = params(8).value;

net.params(net.getParamIndex('filters5p')).value = params(9).value;
net.params(net.getParamIndex('biases5p')).value = params(10).value;

net.params(net.getParamIndex('filters6')).value = params(11).value;
net.params(net.getParamIndex('biases6')).value = params(12).value;

net.params(net.getParamIndex('filters7')).value = params(13).value;
net.params(net.getParamIndex('biases7')).value = params(14).value;

net.params(net.getParamIndex('filters7b')).value = params(15).value;
net.params(net.getParamIndex('biases7b')).value = params(16).value;

net.params(net.getParamIndex('filters8')).value = params(17).value;
net.params(net.getParamIndex('biases8')).value = params(18).value;



%% save
netStruct = net.saveobj() ;
save('./GOTURN_net.mat', '-struct', 'netStruct') ;
clear netStruct ;


%% test

% netStruct = load('./GOTURN_net.mat') ;
% net = dagnn.DagNN.loadobj(netStruct) ;
% clear netStruct ;
% 
% net.mode = 'test' ;
% 
% tic
% im = imread('peppers.png');
% box = [119  246   70   62];
% target = im(box(1)-box(3):box(1)+box(3), box(2)-box(4):box(2)+box(4), :);
% image = im(box(1)-box(3)-5:box(1)+box(3)-5, box(2)-box(4):box(2)+box(4), :);
% 
% target_ = imresize(single(target), net.meta.normalization.imageSize(1:2)) ;
% target_ = bsxfun(@minus, target_, net.meta.normalization.averageImage) ;
% 
% image_ = imresize(single(image), net.meta.normalization.imageSize(1:2)) ;
% image_ = bsxfun(@minus, image_, net.meta.normalization.averageImage) ;
% 
% net.eval({'target', target_,'image', image_}) ;
% output = net.vars(net.getVarIndex('fc8')).value ;
% output(3:4) = min(1.5,max(output(3:4),0.6));
% 
% predict = [box(1)+box(3)*output(1),box(2)+box(4)*output(2),...
%     box(3)*output(3),box(4)*output(4)];
% 
% imshow(im);
% predict(1) = predict(1)+5;
% rectangle('Position',predict,'EdgeColor',[1 0 0],'LineWidth',2);
% toc