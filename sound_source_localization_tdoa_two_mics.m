% This script visualizes the propagation of sound waves from a source and the detection by two microphones.
% It demonstrates the calculation of the time difference of arrival (TDOA) and the localization of the sound source.
% The animation shows the expanding wavefront and plots the signals received by the microphones.
% Additionally, it calculates and displays the hyperbola of possible sound source positions based on TDOA.
%
% Patrick Marmaroli

clear all, close all, clc

addpath("helpers\")
% Parameters
radius_max = 50; % Maximum radius of the wave
sound_speed = 343; %m/s
refresh_time_sec = 5e-4; %animation refresh time, in seconds
total_time_sec = 0.16; %animation total time, in seconds
num_frames = floor(total_time_sec/refresh_time_sec); % animation total number of frames

center = [10, 15]; % sound source position (ground truth)

% for displaying wave expansion
theta = linspace(0, 2*pi, 100);
radius = 0;

% Microphone positions, in meters
mic1 = [0, 0];
mic2 = [-15, -5];

% Set up the figure
fig = figure;
waveaxis = axes('parent',fig);
axis equal;
xlim([-20, 20]);
ylim([-20, 20]);
xlabel('X / m');
ylabel('Y / m');
hold on;

tta = findall(gca,'type','axes');
set(tta,'fontname','Segoe UI','fontsize',14)
ttf = findall(gcf,'type','text');
set(ttf,'fontsize',14)
set(ttf,'fontname','Segoe UI');
grid on;
set(gcf,'color','w','units','normalized');
box on;

set(gcf,'position',[ 0.1567    0.0977    0.7416    0.6081]);
set(gca,'position',[0.0779    0.1219    0.8259    0.8012]);

% Plot the center point
plot(center(1), center(2), 'ro', 'MarkerFaceColor', 'r','MarkerSize', 20)

% Plot the microphones
plot(mic1(1), mic1(2), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 12);
plot(mic2(1), mic2(2), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 12);

% Initial plot for the wave
x = center(1) + radius * cos(theta);
y = center(2) + radius * sin(theta);
pwave = plot(x, y, 'r-', 'LineWidth', 2);

% Create textbox
annotation(fig,'textbox',...
    [0.274386711414759 0.829822093101159 0.164596468097007 0.10142075803809],...
    'Color',[1 0 0],...
    'String',['sound source',sprintf('\n'),'(to localize)'],...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');


annotation(fig,'textbox',...
    [0.205716369011946 0.430125405787304 0.164596468097007 0.101420758038091],...
    'Color',[0 0 1],...
    'String',{'microphone 1'},...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');



annotation(fig,'textbox',...
    [0.205716369011946 0.430125405787304 0.164596468097007 0.101420758038091],...
    'Color',[0 0 1],...
    'String',{'microphone 1'},...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');


annotation(fig,'textbox',...
    [0.0409075472451952 0.325062276550519 0.164596468097007 0.101420758038091],...
    'Color',[0 0 1],...
    'String','microphone 2',...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');



% calculate min distance to mic
minDistToMic1 = Inf;
minDistToMic2 = Inf;
signal_vt_ms = zeros(num_frames,1);

for k = 1:num_frames

    signal_vt_ms(k,1) = k*refresh_time_sec*1000;
    radius =  signal_vt_ms(k,1)/1000*sound_speed; %sec, refresh time

    % Update the x and y data for the wave
    x = center(1) + radius * cos(theta);
    y = center(2) + radius * sin(theta);

    distToMic1 = abs(radius - sqrt((mic1(1) - center(1))^2 + (mic1(2) - center(2))^2));

    if distToMic1 < minDistToMic1
        minDistToMic1 = distToMic1;
    end

    distToMic2 = abs(radius - sqrt((mic2(1) - center(1))^2 + (mic2(2) - center(2))^2));

    if distToMic2 < minDistToMic2
        minDistToMic2 = distToMic2;
    end

end


% Create subplots for microphone signals
mic1_axis = axes('parent',fig);
title('Microphone 1 Signal');
xlabel('Time / ms');
ylabel('Amplitude');
ylim([-1 1]*1.5)
xlim([0 total_time_sec]*1000)
hold on;
mic1_signal = zeros(1, num_frames);
pmic1 = plot(signal_vt_ms,mic1_signal, 'b-','LineWidth',2);
box on

mic2_axis = axes('parent',fig);
title('Microphone 2 Signal');
xlabel('Time / ms');
ylabel('Amplitude');
ylim([-1 1]*1.5)
xlim([0 total_time_sec]*1000)
hold on;
mic2_signal = zeros(1, num_frames);
pmic2 = plot(signal_vt_ms,mic2_signal, 'b-','LineWidth',2);
box on

set(waveaxis,'position',[   -0.1264    0.1288    0.8259    0.8012]);
set(mic1_axis,'position',[     0.5382    0.7126    0.4054    0.2124]);
set(mic2_axis,'position',[  0.5391    0.4020    0.4054    0.2124]);

drawnow





% Create the animated plot
for k = 1:num_frames

    % Calculate the current radius
    radius =  signal_vt_ms(k,1)/1000*sound_speed; %sec, refresh time


    % Update the x and y data for the wave
    x = center(1) + radius * cos(theta);
    y = center(2) + radius * sin(theta);
    set(pwave, 'XData', x, 'YData', y);

    % distance between each mic and wave front
    distToMic1 = abs(radius - sqrt((mic1(1) - center(1))^2 + (mic1(2) - center(2))^2));
    distToMic2 = abs(radius - sqrt((mic2(1) - center(1))^2 + (mic2(2) - center(2))^2));

    if distToMic1 == minDistToMic1 %when wave front hits first mic
        mic1_signal(k) = 1;
        t1 = signal_vt_ms(k,1)/1000;

    else
        mic1_signal(k) = randn(1)/20;
    end

    if distToMic2 == minDistToMic2 %when swave front hits seconds mic
        mic2_signal(k) = 1;
        t2 = signal_vt_ms(k,1)/1000;
    else
        mic2_signal(k) = randn(1)/20;
    end

    set(pmic1, 'YData', mic1_signal);
    set(pmic2, 'YData', mic2_signal);

    % Pause to create animation effect
    pause(0.05);
end

annotation(fig,'textbox',...
    [0.681248551680051 0.858271848562919 0.2 0.05],...
    'String',{sprintf('t_{1} = %3.2f ms',t1*1000)},...
    'FontSize',14,...
    'FitBoxToText','off','EdgeColor','none');

pause(1)


annotation(fig,'textbox',...
    [0.780832367786701 0.550453080938199 0.2 0.05],...
    'String',{sprintf('t_{2} = %3.2f ms',t2*1000)},...
    'FontSize',14,...
    'FitBoxToText','off','EdgeColor','none');

pause(1)

% time difference of arrial (TDOA)
tdiff = t2-t1;
annotation(fig,'textbox',...
    [0.0841906721536348 0.773835078294872 0.246631973577316 0.05],...
    'String',{sprintf('t_{diff} = %3.2f - %3.2f = %3.2f ms',t2*1000,t1*1000,tdiff*1000)},...
    'FontSize',14,...
    'FitBoxToText','off','EdgeColor','none');

% calculate hyperbola of possible positions
xmic1 = mic1(1);
xmic2 = mic2(1);
ymic1 = mic1(2);
ymic2 = mic2(2);

aperture = sqrt((xmic1 - xmic2)^2 + (ymic1 - ymic2)^2);
mic_theta = atan2(ymic1 - ymic2,xmic1 - xmic2);

xbary = 0.5*(xmic1 + xmic2);
ybary = 0.5*(ymic1 + ymic2);

if abs(xbary) <= eps
    xbary = 0;
end

if abs(ybary) <= eps
    ybary = 0;
end

% hyperbola parameters
c = aperture/2;
a = sound_speed*tdiff/2;
b = sign(tdiff)*sqrt(c^2 - a^2);

t = linspace(-10,10,10000); % distance support
xinit = a*cosh(t);
yinit = b*sinh(t);

hyp_x = cos(mic_theta)*xinit - sin(mic_theta)*yinit + xbary;
hyp_y = sin(mic_theta)*xinit + cos(mic_theta)*yinit + ybary;


% Create arrow
annotation(fig,'arrow',[0.276467630881511 0.313091813496344],...
    [0.775767874435857 0.695067209949631]);

plot(waveaxis,real(hyp_x.'),real(hyp_y.'),'linewidth',2,'color','g')

pause(1)

% Create textbox
annotation(fig,'textbox',...
    [0.0841906721536353 0.555744364657373 0.183537096967517 0.153190995633029],...
    'Color',[0 1 0],...
    'String',{'The sound source is','somewhere on this line;','one 3rd mic. is required','to triangulate.'},...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none',...
    'BackgroundColor',[0 0 0]);
