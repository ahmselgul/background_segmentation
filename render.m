function [result] = render(frame, mask, bg, render_mode)
    % Render the mask onto the image
    % Paramters:
    %     frame: Original image
    %     mask: Mask calculated by the segmentation function
    %     bg: Background image if the mode is substitue
    %     render_mode: The mode of the rendering
    
    if ~exist('frame', 'var') || ~exist('mask', 'var') || ~exist('render_mode', 'var')
        error('frame, mask, and mode parameters are required for the rendering.');
    end
    
    switch(render_mode)
        case 'foreground'
            % Apply the mask.
            result = frame .* uint8(mask);
        case 'background'
            % Apply the negated mask.
            result = frame .* uint8(~mask);
        case 'overlay'
            % We maximize the first channel of the foreground.
            out1 = frame(:, :, 1);
            out1(mask) = 180;

            % We maximize the second channel of the background.
            out2 = frame(:, :, 2);
            out2(~mask) = 180;

            % We combine the three channels.
            result = cat(3, out1, out2, frame(:, :, 3));
        case 'substitute'
            if ~exist('bg', 'var')
                error('You should specify a background for the substitute mode.');
            end
            % We combine both images
            result = (frame .* uint8(mask)) + (bg .* uint8(~mask));
        otherwise
            error("The mode '" + render_mode + "' is not valid.");
    end

end
