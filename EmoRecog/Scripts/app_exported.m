classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        UIAxes            matlab.ui.control.UIAxes
        NOFACEFOUNDLabel  matlab.ui.control.Label
        storageFolder = './captures';
        cam;
        files;
        frameCount = 0;
        faceDetector;
        mouthDetector;
        noseDetector;
        mouthThreshold = 64;
        noseThreshold = 10;
    end
    methods (Access = private)

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            clear('cam');
            delete(app.UIFigure);
        end
    end
    % Component initialization
    methods (Access = private)
        % Create UIFigure and components
        function createComponents(app)

            app.cam = webcam(1);

            app.faceDetector = vision.CascadeObjectDetector('MinSize', [100,100]);
            app.mouthDetector = vision.CascadeObjectDetector('Mouth', 'MergeThreshold', app.mouthThreshold);
            app.noseDetector = vision.CascadeObjectDetector('Nose', 'MergeThreshold', app.noseThreshold);
            
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
        
        function deleteAllFiles(app)
            for k = 1 : length(app.files)
                baseFileName = app.files(k).name;
                fullFileName = fullfile(app.storageFolder, baseFileName);
                delete(fullFileName);
            end
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            deleteAllFiles(app);
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            while (1)
                
                try
                    img = snapshot(app.cam);
                    
                    %videoOut = img;

                    %img = flip(img);

                   imshow(app.cam,'Parent',app.UIAxes);

                    %imshow(videoOut);
                    drawnow();
                    app.frameCount = app.frameCount + 1;
                catch ME
                    break;
                end
            end
        end
    end
end