function [score] = emoRecogTrain(imgLocation)
% EMOTIONAL RECOGNITION BY SUPERHEROES
%   Pass parameter image.
setDir = fullfile('../ImagesUncropped');
imds = imageDatastore(setDir,'IncludeSubfolders',true,'LabelSource','foldernames');
imds.ReadFcn = @faceDetection;
imds = shuffle(imds);
[trainingSet,testSet] = splitEachLabel(imds,0.7,'randomize');
bag = bagOfFeatures(trainingSet);
options = templateSVM('KernelFunction', 'polynomial'); % 'gaussian', 'linear', 'polynomial'
categoryClassifier = trainImageCategoryClassifier(trainingSet,bag,'LearnerOptions',options);
img = faceDetection(fullfile('../ImagesUncropped/Sad/', imgLocation));
[labelIdx, score] = predict(categoryClassifier,img);  % test it
label = categoryClassifier.Labels(labelIdx)           % test it 
imshow(img);
confMatrix = evaluate(categoryClassifier,testSet)     % 
mean(diag(confMatrix)) 
end

