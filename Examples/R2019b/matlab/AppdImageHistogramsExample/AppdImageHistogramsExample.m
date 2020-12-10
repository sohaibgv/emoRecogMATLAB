%% Create App that Uses Multiple Axes to Display Results of Image Analysis
% This app shows how to configure multiple axes components in App Designer.
% The app displays an image in one axes component, and displays histograms of the red, 
% green, and blue pixels in the other three.
%
% This example also demonstrates the following app building tasks:
%
% * Managing multiple axes
% * Reading and displaying images
% * Browsing the user&rsquo;s file system using the <docid:matlab_ref#f52-579241> function
% * Displaying an in-app alert for invalid input (in this case, an unsupported image file)
% * Writing a |StartupFcn| callback to initialize the app with a default image
%
% <<../image_histograms_screenshot.png>>

% Copyright 2018 The MathWorks, Inc.