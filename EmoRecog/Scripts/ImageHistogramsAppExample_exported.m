classdef ImageHistogramsAppExample_exported < matlab.apps.AppBase
    % Create public variables for app
    properties (Access = public)
        % UI elements
        UIFigure matlab.ui.Figure
        UIAxes matlab.ui.control.UIAxes
        NOFACEFOUNDLabel matlab.ui.control.Label
        % Other elements
        storageFolder = './captures';
        cam;
        files;
        faceDetector;
        mouthDetector;
        noseDetector;
        mouthThreshold = 64;
        noseThreshold = 20;
    end
    methods (Access = private)
        % This function runs when the app is closed
        function UIFigureCloseRequest(app, event)
            % Clears the cam object (stops the webcam)
            clear('cam');
            % Deletes the UI
            delete(app.UIFigure);
        end
    end
    % Component initialization
    methods (Access = private)
        % Create components
        function createComponents(app)
            % Creates webcam object.
            % Webcam index (1) can be changed to specify
            % other webcams connected to the computer
            app.cam = webcam(1);
            % Face detector object with pre-trained model ?Face? (default model)
            app.faceDetector = vision.CascadeObjectDetector('MinSize', [100,100]);
            % Mouth detector object with pre-trained model 'Mouth'
            app.mouthDetector = vision.CascadeObjectDetector('Mouth', 'MergeThreshold',
            app.mouthThreshold);
            % Nose detector object with pre-trained model 'Nose'
            app.noseDetector = vision.CascadeObjectDetector('Nose', 'MergeThreshold',
            app.noseThreshold);
            % Creates path to captures/*jpg (so all .jpg files in captures folder)
            filePattern = fullfile(app.storageFolder, '*.jpg');
            app.files = dir(filePattern);
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';
            % Create NOFACEFOUNDLabel
            app.NOFACEFOUNDLabel = uilabel(app.UIFigure);
            app.NOFACEFOUNDLabel.BackgroundColor = [0.902 0.902 0.902];
            app.NOFACEFOUNDLabel.HorizontalAlignment = 'center';
            app.NOFACEFOUNDLabel.FontName = 'MS UI Gothic';
            app.NOFACEFOUNDLabel.FontSize = 30;
            app.NOFACEFOUNDLabel.FontWeight = 'bold';
            app.NOFACEFOUNDLabel.Position = [1 398 640 83];
            app.NOFACEFOUNDLabel.Text = 'NO FACE FOUND';
            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.TickLength = [0 0];
            app.UIAxes.Box = 'on';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.ZTick = [];
            app.UIAxes.Color = 'none';
            app.UIAxes.Position = [0 0 640 400];
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        % Function to delete all .jpg files in the captures folder
        function deleteAllFiles(app)
            % Iterate over all files
            for k = 1 : length(app.files)
                % Get file path
                baseFileName = app.files(k).name;
                fullFileName = fullfile(app.storageFolder, baseFileName);
                % Delete file
                delete(fullFileName);
            end
        end
    end
    % App creation
    methods (Access = public)
        % Construct app
        function app = app_exported
            % Create components
            createComponents(app)
            % Deletes all .jpg files in the captures folder
            deleteAllFiles(app);
            % Register the app for MATLAB App Designer integration
            registerApp(app, app.UIFigure)
            while (1)
                try
                    % Take snapshot of current frame of webcam
                    img = snapshot(app.cam);
                    % Flips the image. On certain webcams this might not be necessary
                    img = flip(img);
                    % Assign videoOut to the current frame, for later use
                    videoOut = img;
                    % Create array of bounding boxes of faces found in the frame
                    bbox_faces = step(app.faceDetector, img);
                    % Count how many faces were found (y-axis = count)
                    [faces,~] = size(bbox_faces);
                    % Initial status
                    status = -1;
                    % If any face is found in the image
                    if faces > 0
                        % Iterate over all faces found
                        for c = 1:faces
                            % Get's bounding box of current face
                            bbox_face = bbox_faces(c,:);
                            % Crop face from frame
                            face = imcrop(img, bbox_face);
                            % Get bottom half of face
                            [y,x] = size(face);
                            bottomFace = face(floor(y/2):y,1:x);
                            % Find mouths in bottom half of face
                            bbox_mouths = step(app.mouthDetector, bottomFace);
                            % Find noses in face
                            bbox_noses = step(app.noseDetector, face);
                            % Count amount of noses
                            [noses,~] = size(bbox_noses);
                            % Count amount of mouths
                            [mouths,~] = size(bbox_mouths);
                            % Create unique string for file name (based on time)
                            t = num2str(now * 10000000000);
                            % No mouth or nose found -> wearing mask
                            if (noses == 0 && mouths == 0)
                                % Add rectangle around person's face with informative text and color
                                videoOut =
                                insertObjectAnnotation(videoOut,'rectangle',bbox_face,'WEARING MASK', 'Color', 'green');
                                % Update status for later use
                                status = 0;
                                % Both mouth and nose is visible -> no mask
                            elseif (noses > 0 && mouths > 0)
                                % Add rectangle around person's face with informative text and color
                                videoOut = insertObjectAnnotation(videoOut,'rectangle',bbox_face,'NOT WEARING MASK', 'Color', 'red');
                                % Write image to disk of person's face
                                imwrite(face, ['captures/NOT_WEARING' t '.jpg']);
                                % Update status for later use
                                status = 1;
                                % Either nose or mouth is visible -> not properly wearing mask
                            elseif (noses > 0 || mouths > 0)
                                % Add rectangle around person's face with informative text and color
                                videoOut = insertObjectAnnotation(videoOut,'rectangle',bbox_face,'NOT WEARING MASK PROPERLY', 'Color', 'red');
                                % Write image to disk of person's face
                                imwrite(face, ['captures/NOT_PROPERLY' t '.jpg']);
                                % Update status for later use
                                status = 2;
                            end
                        end
                    end
                    % Person is wearing mask
                    if (status == 0)
                        % Set label background color to green
                        app.NOFACEFOUNDLabel.BackgroundColor = [0 1 0];
                        % Update label text
                        app.NOFACEFOUNDLabel.Text = ["WEARING MASK" "Thank You!"];
                        % Person is not wearing mask
                    elseif (status == 1)
                        % Set label background color to red
                        app.NOFACEFOUNDLabel.BackgroundColor = [1 0 0];
                        % Update label text
                        app.NOFACEFOUNDLabel.Text = ["NOT WEARING MASK" "Please wear a mask"];
                        % Person is not wearing mask properly
                    elseif (status == 2)
                        % Set label background color to orange
                        app.NOFACEFOUNDLabel.BackgroundColor = [1 0.55 0.1];
                        % Update label text
                        app.NOFACEFOUNDLabel.Text = ["NOT WEARING MASK PROPERLY"
                            "Cover up Your nose"];
                        % No person found in frame
                    else
                        % Set label background color to grey
                        app.NOFACEFOUNDLabel.BackgroundColor = [0.902 0.902 0.902];
                        % Update label text
                        app.NOFACEFOUNDLabel.Text = ["NO FACE FOUND" "Please remove glasses and stare at the camera"];
                    end
                    % Show the updated frame in the axes of the UI
                    imshow(videoOut,'Parent',app.UIAxes);
                    % Render the current frame
                    drawnow();
                catch ME
                    break;
                end
            end
        end
    end
end